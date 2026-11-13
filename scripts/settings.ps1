# The pack's lines in settings files players also own: settings\always\<path> and settings\once\<path>, where <path>
# is under the game folder (config\..., options.txt). Dot-sourced by play.ps1; scripts/merge-settings.awk does the same
# for servers, and scripts/test-settings.sh checks the two agree. Runs on Windows PowerShell 5.1 and PowerShell 7.
#
# A line's identity is its section (an INI [header], or the path of Forge `name {` categories) and its key: the text
# before = (or : in .txt files such as options.txt), or what a `# key: <key>` comment on the line above says, for files
# whose lines share a first word (Xaero's `interface:<name>:...`). A player's line has a key when it starts with it and
# then the separator. The pack owns every identity its files name: their lines replace all of the
# player's lines with that identity, where the first of them was, so a key repeated as a list is replaced as a whole.
# An identity the player's file lacks goes at the end of its section, or a new INI section at the end.
# always lines are put back on every launch. once lines are put in the first time the pack ships that exact line,
# then left to the player; the game folder's .ftam-settings-once remembers which. always wins over once.

function Get-SettingTrim([string]$s) { return $s.Trim(" `t`r".ToCharArray()) }

function Get-SettingKey([string]$t, [string]$Sep) {
    if ($t -eq '' -or $t.StartsWith(';') -or $t.StartsWith('#') -or $t.StartsWith('//')) { return '' }
    $i = $t.IndexOf($Sep)
    if ($i -le 0) { return '' }
    return (Get-SettingTrim $t.Substring(0, $i))
}

# Each line with Kind (ini, open, close, key, other), Sec, SecKind (ini or forge), Id, Closed and Indent.
function Split-SettingLines([string[]]$Lines, [string]$Sep) {
    $sec = ''; $secKind = ''; $stack = New-Object System.Collections.Generic.List[string]
    $rows = New-Object System.Collections.Generic.List[object]
    foreach ($line in $Lines) {
        $t = Get-SettingTrim $line
        $kind = 'other'; $key = ''; $closed = ''
        if ($t -match '^\[.+\]$') {
            $sec = $t.Substring(1, $t.Length - 2); $secKind = 'ini'; $kind = 'ini'
        } elseif ($t.EndsWith('{')) {
            $stack.Add((Get-SettingTrim $t.Substring(0, $t.Length - 1)).Replace('"', ''))
            $sec = $stack -join '.'; $secKind = 'forge'; $kind = 'open'
        } elseif ($t -eq '}' -and $stack.Count -gt 0) {
            $closed = $sec; $stack.RemoveAt($stack.Count - 1); $sec = $stack -join '.'; $kind = 'close'
        } else {
            $key = Get-SettingKey $t $Sep
            if ($key -ne '') { $kind = 'key' }
        }
        $id = ''
        if ($kind -eq 'key') { $id = $sec.ToLowerInvariant() + "`t" + $key.ToLowerInvariant() }
        $indent = ([regex]::Match($line, '^[ \t]*')).Value
        $rows.Add([pscustomobject]@{ Line = $line; Trim = $t; Kind = $kind; Sec = $sec; SecKind = $secKind; Id = $id
            Key = $key; Closed = $closed; Indent = $indent })
    }
    return , $rows
}

# The pack's identities in one settings file, in order: Id, Sec, SecKind, Key, Lines.
function Read-OwnedSettings([string[]]$Lines, [string]$Sep) {
    $owned = [ordered]@{}
    $named = ''
    foreach ($row in (Split-SettingLines $Lines $Sep)) {
        if ($row.Trim -match '^#\s*key:\s*(.*)$') { $named = Get-SettingTrim $Matches[1]; continue }
        if ($row.Kind -ne 'key') { continue }
        $key = $row.Key
        if ($named -ne '') { $key = $named; $named = '' }
        $id = $row.Sec.ToLowerInvariant() + "`t" + $key.ToLowerInvariant()
        if (-not $owned.Contains($id)) {
            $owned[$id] = [pscustomobject]@{ Id = $id; Sec = $row.Sec; SecKind = $row.SecKind; Key = $key
                Lines = (New-Object System.Collections.Generic.List[string]) }
        }
        $owned[$id].Lines.Add($row.Trim)
    }
    return $owned
}

# The pack identity a player's line has: the longest pack key in its section it starts with, then the separator.
# $Keys holds every pack key for the file, once lines already applied included, longest first.
function Get-SettingOwner($Row, $Keys, [string]$Sep) {
    foreach ($o in $Keys) {
        if ($o.Sec -ne $Row.Sec) { continue }
        if (-not $Row.Trim.StartsWith($o.Key, [StringComparison]::OrdinalIgnoreCase)) { continue }
        $rest = $Row.Trim.Substring($o.Key.Length).TrimStart(" `t".ToCharArray())
        if ($rest.StartsWith($Sep)) { return $o.Id }
    }
    return ''
}

# Where a line of this section goes when the target lacks it: after this row (0-based, -1 means before the first),
# or $null when the section itself is missing.
function Get-SettingInsertAt($Rows, [string]$Sec, [string]$SecKind) {
    $n = $Rows.Count
    if ($Sec -eq '') {
        $last = -1
        for ($i = 0; $i -lt $n; $i++) {
            if ($Rows[$i].Kind -eq 'ini' -or $Rows[$i].Kind -eq 'open') { break }
            if ($Rows[$i].Trim -ne '') { $last = $i }
        }
        return $last
    }
    if ($SecKind -eq 'forge') {
        for ($i = 0; $i -lt $n; $i++) {
            if ($Rows[$i].Kind -eq 'close' -and $Rows[$i].Closed -eq $Sec) { return $i - 1 }
        }
        return $null
    }
    $h = -1
    for ($i = 0; $i -lt $n; $i++) { if ($Rows[$i].Kind -eq 'ini' -and $Rows[$i].Sec -eq $Sec) { $h = $i; break } }
    if ($h -lt 0) { return $null }
    $last = $h
    for ($i = $h + 1; $i -lt $n -and $Rows[$i].Kind -ne 'ini'; $i++) { if ($Rows[$i].Trim -ne '') { $last = $i } }
    return $last
}

# The target's lines with the owned identities put in. $Owned is an ordered list from Read-OwnedSettings; $Keys every
# pack key for the file (see Get-SettingOwner).
function Merge-Settings([string[]]$Target, $Owned, $Keys, [string]$Sep, [string]$File) {
    $rows = Split-SettingLines $Target $Sep
    foreach ($row in $rows) { if ($row.Kind -eq 'key') { $row.Id = Get-SettingOwner $row $Keys $Sep } }
    $first = @{}; $drop = @{}; $rep = @{}; $have = @{}
    # An identity whose lines already read as the pack's, in order, stays where it is, even spread apart.
    foreach ($row in $rows) {
        if ($row.Id -eq '' -or -not $Owned.Contains($row.Id)) { continue }
        if ($have.ContainsKey($row.Id)) { $have[$row.Id] += "`n" + $row.Trim } else { $have[$row.Id] = $row.Trim }
    }
    for ($i = 0; $i -lt $rows.Count; $i++) {
        $id = $rows[$i].Id
        if ($id -eq '' -or -not $Owned.Contains($id)) { continue }
        if ($have[$id] -ceq ($Owned[$id].Lines -join "`n")) { $first[$id] = $i; continue }
        if ($first.ContainsKey($id)) { $drop[$i] = $true } else { $first[$id] = $i; $rep[$i] = $id }
    }
    $after = @{}
    $tails = New-Object 'System.Collections.Generic.Dictionary[string,System.Collections.Generic.List[string]]'
    $tailOrder = New-Object System.Collections.Generic.List[string]
    foreach ($o in $Owned.Values) {
        if ($first.ContainsKey($o.Id)) { continue }
        $at = Get-SettingInsertAt $rows $o.Sec $o.SecKind
        if ($null -ne $at) {
            $pad = ''
            if ($o.SecKind -eq 'forge') { $pad = ' ' * (4 * $o.Sec.Split('.').Count) }
            if (-not $after.ContainsKey($at)) { $after[$at] = New-Object System.Collections.Generic.List[string] }
            foreach ($l in $o.Lines) { $after[$at].Add($pad + $l) }
            continue
        }
        if ($o.SecKind -eq 'forge') {
            Write-Host "  settings: $File has no category $($o.Sec) for $($o.Lines[0]); skipped" -ForegroundColor Yellow
            continue
        }
        $sec = [string]$o.Sec
        if (-not $tails.ContainsKey($sec)) {
            $tails.Add($sec, (New-Object System.Collections.Generic.List[string]))
            $tailOrder.Add($sec)
        }
        foreach ($l in $o.Lines) { $tails[$sec].Add($l) }
    }
    $out = New-Object System.Collections.Generic.List[string]
    if ($after.ContainsKey(-1)) { $out.AddRange($after[-1]) }
    for ($i = 0; $i -lt $rows.Count; $i++) {
        if (-not $drop.ContainsKey($i)) {
            if ($rep.ContainsKey($i)) {
                foreach ($l in $Owned[$rep[$i]].Lines) { $out.Add($rows[$i].Indent + $l) }
            } else {
                $out.Add($rows[$i].Line)
            }
        }
        if ($after.ContainsKey($i)) { $out.AddRange($after[$i]) }
    }
    $j = 0
    foreach ($sec in $tailOrder) {
        if ($rows.Count -gt 0 -or $j -gt 0) { $out.Add('') }
        $out.Add("[$sec]")
        $out.AddRange($tails[$sec])
        $j++
    }
    return , $out
}

function Read-SettingFileLines([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return , @() }
    $text = [IO.File]::ReadAllText($Path)
    if ($text -eq '') { return , @() }
    $lines = $text -split "`r?`n"
    if ($text.EndsWith("`n")) { $lines = $lines[0..($lines.Count - 2)] }
    return , [string[]]$lines
}

# Applies one settings path to the file at $Target. Returns whether the file changed. $State is the once record
# (a HashSet of signatures); new signatures go into $NewState.
function Set-OwnedSettings([string]$Root, [string]$Rel, [string]$Target, $State, $NewState) {
    $sep = '='
    if ($Rel.EndsWith('.txt', [StringComparison]::OrdinalIgnoreCase)) { $sep = ':' }
    $always = Read-OwnedSettings (Read-SettingFileLines (Join-Path $Root "settings/always/$Rel")) $sep
    $onceAll = Read-OwnedSettings (Read-SettingFileLines (Join-Path $Root "settings/once/$Rel")) $sep
    # Longest keys first, ties in the order the pack's files name them (as merge-settings.awk does).
    $keys = New-Object System.Collections.Generic.List[object]
    $listed = @{}
    foreach ($o in @($always.Values) + @($onceAll.Values)) {
        if ($listed.ContainsKey($o.Id)) { continue }
        $listed[$o.Id] = $true
        $j = $keys.Count
        while ($j -gt 0 -and $keys[$j - 1].Key.Length -lt $o.Key.Length) { $j-- }
        $keys.Insert($j, $o)
    }
    $owned = [ordered]@{}
    foreach ($o in $always.Values) { $owned[$o.Id] = $o }
    foreach ($o in $onceAll.Values) {
        if ($always.Contains($o.Id)) { continue }
        $sig = (($Rel -replace '\\', '/'), $o.Sec, $o.Id, ($o.Lines -join [char]0x1f)) -join "`t"
        if ($State.Contains($sig)) { continue }
        $owned[$o.Id] = $o
        $NewState.Add($sig) | Out-Null
    }
    if ($owned.Count -eq 0) { return $false }
    $before = Read-SettingFileLines $Target
    $after = Merge-Settings $before $owned $keys $sep $Rel
    if (($before -join "`n") -ceq ($after -join "`n") -and (Test-Path -LiteralPath $Target)) { return $false }
    $newline = "`n"
    if ((Test-Path -LiteralPath $Target) -and ([IO.File]::ReadAllText($Target)).Contains("`r`n")) { $newline = "`r`n" }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
    [IO.File]::WriteAllText($Target, (($after -join $newline) + $newline), (New-Object System.Text.UTF8Encoding $false))
    return $true
}

# Every file under settings\always and settings\once, put into the game folder.
function Sync-Settings([string]$Root, [string]$GameDir) {
    $rels = New-Object System.Collections.Generic.SortedSet[string]
    foreach ($mode in 'always', 'once') {
        $dir = Join-Path $Root "settings/$mode"
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        $full = (Resolve-Path -LiteralPath $dir).Path
        foreach ($f in Get-ChildItem -File -Recurse -LiteralPath $full) { $rels.Add($f.FullName.Substring($full.Length + 1)) | Out-Null }
    }
    $stateFile = Join-Path $GameDir '.ftam-settings-once'
    $state = New-Object System.Collections.Generic.HashSet[string]
    foreach ($l in (Read-SettingFileLines $stateFile)) { $state.Add($l) | Out-Null }
    $count = 0
    foreach ($rel in $rels) {
        $new = New-Object System.Collections.Generic.List[string]
        if (Set-OwnedSettings $Root $rel (Join-Path $GameDir $rel) $state $new) {
            Write-Host "  ~ $rel" -ForegroundColor Cyan
            $count++
        }
        # Recorded only once the file is written, so a failed write tries again next launch.
        if ($new.Count -gt 0) { [IO.File]::AppendAllText($stateFile, (($new -join "`n") + "`n")) }
    }
    Write-Host "Pack lines: $count files updated"
}

# Whether a game path is one settings\ manages; Sync-Game leaves those to Sync-Settings.
function Test-OwnedSettingPath([string]$Root, [string]$Rel) {
    return (Test-Path -LiteralPath (Join-Path $Root "settings/always/$Rel")) -or
        (Test-Path -LiteralPath (Join-Path $Root "settings/once/$Rel"))
}
