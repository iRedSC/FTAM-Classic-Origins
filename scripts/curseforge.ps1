# The CurseForge half of play.ps1, which dot-sources it after pulling and supplies the pack settings,
# Fail, Sync-Mods, Sync-Game, Get-Hash and Write-Utf8. CurseForge can't be told what a profile contains or to
# launch one, so a new player imports a generated modpack once. play.cmd then gives the profile ftam-sync.jar,
# which syncs it on every Play, like Prism's pre-launch command.

$CurseForgeInstances = "$env:USERPROFILE\curseforge\minecraft\Instances"

function Find-CurseForge {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\CurseForge Windows\CurseForge.exe",
        "$env:ProgramFiles\CurseForge Windows\CurseForge.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path -LiteralPath $path) { return $path }
    }
    return $null
}

function Read-CurseForgeProfile([string]$Dir) {
    # The import names the profile's manifest after the pack, and that name survives renaming the profile.
    $file = Join-Path $Dir 'minecraftinstance.json'
    if (-not (Test-Path -LiteralPath $file)) { return $null }
    $text = [System.IO.File]::ReadAllText($file)
    if (-not ($text.Contains($InstanceName) -or $text.Contains($OldName))) { return $null }
    try { $info = $text | ConvertFrom-Json } catch { return $null }
    if ($info.manifest -and ($info.manifest.name -eq $InstanceName -or $info.manifest.name -eq $OldName)) {
        return [pscustomobject]@{ Dir = (Resolve-Path -LiteralPath $Dir).Path.TrimEnd('\'); Info = $info }
    }
    return $null
}

function Find-CurseForgeProfile {
    if (-not (Test-Path -LiteralPath $CurseForgeInstances)) { return $null }
    foreach ($dir in Get-ChildItem -Directory -LiteralPath $CurseForgeInstances) {
        $found = Read-CurseForgeProfile $dir.FullName
        if ($found) { return $found }
    }
    return $null
}

function Assert-ProfileVersions($Found) {
    # The import pins the versions, so a pack that moved to new ones needs a fresh profile.
    $loader = $Found.Info.baseModLoader
    if ($Found.Info.gameVersion -ne $Minecraft -or ($loader -and $loader.name -notlike "*$Forge*")) {
        Fail "CurseForge profile '$($Found.Info.name)' doesn't run Minecraft $Minecraft with Forge $Forge. Delete it in CurseForge and run play.cmd again."
    }
}

function Sync-CurseForgeProfile([string]$Dir) {
    # ftam-sync.jar runs this as CurseForge starts the profile, before Forge loads the mods.
    $found = Read-CurseForgeProfile $Dir
    if (-not $found) {
        Fail "This profile isn't one of the pack's. Run play.cmd curseforge to set the pack up."
    }
    Assert-ProfileVersions $found
    # ftam-sync.jar runs play.ps1 from here; profiles set up before .channels pointed at the player's checkout.
    Write-Utf8 (Join-Path $found.Dir 'ftam-sync.repo') $Repo
    Sync-Mods (Join-Path $found.Dir 'mods')
    Sync-Game $found.Dir
    Write-Host 'Pack ready.' -ForegroundColor Green
}

# CurseForge keeps every profile's settings in this cache and writes minecraftinstance.json from it,
# so a setting only sticks when it's in both, written while CurseForge is closed.
$CurseForgeCache = "$env:APPDATA\CurseForge\agent\GameInstances\MinecraftGameInstance.json"
# CurseForge starts Java in the profile folder and passes quotes through literally, so the jar sits there
# under a name without spaces.
$PlayHook = '-javaagent:ftam-sync.jar'

function Find-JavaArgs([string]$Text, [string]$Guid) {
    # The profile's javaArgsOverride: the last one before its guid, after any earlier profile's guid.
    $id = [regex]::Match($Text, '"guid"\s*:\s*"' + [regex]::Escape($Guid) + '"')
    if (-not $id.Success) { return $null }
    $before = $Text.Substring(0, $id.Index)
    $overrides = [regex]::Matches($before, '"javaArgsOverride"\s*:\s*(null|"(?:[^"\\]|\\.)*")')
    if ($overrides.Count -eq 0) { return $null }
    $match = $overrides[$overrides.Count - 1]
    $previous = [regex]::Matches($before, '"guid"\s*:\s*"')
    if ($previous.Count -gt 0 -and $previous[$previous.Count - 1].Index -gt $match.Index) { return $null }
    return $match
}

function Get-ProfileFiles($Found) {
    return @($CurseForgeCache, (Join-Path $Found.Dir 'minecraftinstance.json')) | Where-Object { Test-Path -LiteralPath $_ }
}

function Test-PlayHook($Found) {
    foreach ($file in Get-ProfileFiles $Found) {
        $match = Find-JavaArgs ([System.IO.File]::ReadAllText($file)) $Found.Info.guid
        if (-not $match -or -not $match.Value.Contains($PlayHook)) { return $false }
    }
    return $true
}

function Install-PlayHook($Found) {
    # Play in CurseForge loads ftam-sync.jar, which syncs the profile before the game starts.
    $jar = Join-Path $Found.Dir 'ftam-sync.jar'
    $source = "$PSScriptRoot\ftam-sync.jar"
    if (-not (Test-Path -LiteralPath $jar) -or (Get-Hash $source) -ne (Get-Hash $jar)) {
        # A running game holds it open; the next run with the game closed updates it.
        try { Copy-Item -LiteralPath $source -Destination $jar -Force } catch [System.IO.IOException] { }
    }
    Write-Utf8 (Join-Path $Found.Dir 'ftam-sync.repo') $Repo

    if (Test-PlayHook $Found) { return $false }
    if (Get-Process -Name CurseForge -ErrorAction SilentlyContinue) {
        Write-Host 'Quit CurseForge (tray icon > Quit) so Play can update the pack. Waiting...' -ForegroundColor Yellow
        $deadline = (Get-Date).AddMinutes(15)
        while (Get-Process -Name CurseForge -ErrorAction SilentlyContinue) {
            if ((Get-Date) -gt $deadline) { Fail 'CurseForge is still open. Quit it from the tray, then run this again.' }
            Start-Sleep -Seconds 2
        }
        # It writes its cache on the way out.
        Start-Sleep -Seconds 2
    }
    foreach ($file in Get-ProfileFiles $Found) {
        $text = [System.IO.File]::ReadAllText($file)
        $match = Find-JavaArgs $text $Found.Info.guid
        if (-not $match) { Fail "Couldn't find the profile's Java arguments in $file. CurseForge may have changed its format." }
        if ($match.Value.Contains($PlayHook)) { continue }
        # Keep any arguments the player set. The hook has no characters JSON needs escaped.
        $value = $match.Groups[1].Value
        $value = if ($value -eq 'null') { "`"$PlayHook`"" } else { $value.Substring(0, $value.Length - 1) + " $PlayHook`"" }
        $line = $match.Value.Substring(0, $match.Groups[1].Index - $match.Index) + $value
        $text = $text.Substring(0, $match.Index) + $line + $text.Substring($match.Index + $match.Length)
        Write-Utf8 $file $text
    }
    Write-Host 'Play in CurseForge now updates the pack first.' -ForegroundColor Green
    return $true
}

function Rename-OldProfile($Found) {
    # A profile still on the old name gets the new one; a name the player chose is left alone.
    # A running CurseForge would write its own copy back, so this waits for a run with it closed.
    if ($Found.Info.name -ne $OldName) { return }
    if (Get-Process -Name CurseForge -ErrorAction SilentlyContinue) { return }
    # A text edit, so the rest of CurseForge's files stays exactly as it wrote them.
    $pattern = '"name"(\s*):(\s*)"' + [regex]::Escape($OldName) + '"'
    foreach ($file in Get-ProfileFiles $Found) {
        $text = [regex]::Replace([System.IO.File]::ReadAllText($file), $pattern,
            [System.Text.RegularExpressions.MatchEvaluator]{ param($m) '"name"' + $m.Groups[1].Value + ':' + $m.Groups[2].Value + '"' + $InstanceName + '"' })
        Write-Utf8 $file $text
    }
    $Found.Info.name = $InstanceName
    Write-Host "Renamed CurseForge profile '$OldName' to '$InstanceName'" -ForegroundColor Green
}

function New-CurseForgeImport {
    $manifest = [ordered]@{
        minecraft = [ordered]@{
            version = $Minecraft
            modLoaders = @([ordered]@{ id = "forge-$Forge"; primary = $true })
            recommendedRam = $MaxMemoryMb
        }
        manifestType = 'minecraftModpack'
        manifestVersion = 1
        name = $InstanceName
        version = $Branch
        author = 'FTAM'
        files = @()
        overrides = 'overrides'
    }
    # Only the profile: play.cmd copies the mods in once CurseForge has created it.
    # Windows file names can't hold some characters a pack name can, such as the colon.
    $fileName = ($InstanceName.Split([System.IO.Path]::GetInvalidFileNameChars()) -join '') -replace '\s+', ' '
    $zip = Join-Path $env:TEMP "$fileName.zip"
    Add-Type -AssemblyName System.IO.Compression
    $stream = [System.IO.File]::Open($zip, [System.IO.FileMode]::Create)
    try {
        $archive = New-Object System.IO.Compression.ZipArchive($stream, [System.IO.Compression.ZipArchiveMode]::Create)
        $writer = New-Object System.IO.StreamWriter($archive.CreateEntry('manifest.json').Open(), (New-Object System.Text.UTF8Encoding $false))
        $writer.Write(($manifest | ConvertTo-Json -Depth 5))
        $writer.Dispose()
        $archive.CreateEntry('overrides/') | Out-Null
        $archive.Dispose()
    }
    finally {
        $stream.Dispose()
    }
    return $zip
}

function Start-CurseForge {
    $exe = Find-CurseForge
    $found = Find-CurseForgeProfile
    if (-not $found) {
        if (-not $exe) {
            Fail 'CurseForge not found. Install it, or Prism Launcher from https://prismlauncher.org, sign in once, and run this again.'
        }
        $zip = New-CurseForgeImport
        Set-Clipboard -Value $zip
        Start-Process -FilePath $exe
        Start-Process -FilePath explorer.exe -ArgumentList "/select,`"$zip`""
        Write-Host "First run: in CurseForge, open Minecraft, then Create Custom Profile > Import, and pick" -ForegroundColor Yellow
        Write-Host "  $zip" -ForegroundColor Yellow
        Write-Host '(its path is on your clipboard). Waiting for the profile to appear...' -ForegroundColor Yellow
        $deadline = (Get-Date).AddMinutes(15)
        while (-not $found) {
            if ((Get-Date) -gt $deadline) { Fail 'No FTAM profile appeared in CurseForge. Import the zip, then run this again.' }
            Start-Sleep -Seconds 2
            $found = Find-CurseForgeProfile
        }
        Write-Host "Found CurseForge profile '$($found.Info.name)'" -ForegroundColor Green
    }

    Assert-ProfileVersions $found
    if (Install-PlayHook $found) { New-DesktopShortcut $exe }
    Rename-OldProfile $found

    Sync-Mods (Join-Path $found.Dir 'mods')
    Sync-Game $found.Dir

    # What CurseForge's own desktop shortcuts open; it starts CurseForge if needed, then the game.
    Write-Host 'Starting Minecraft in CurseForge...' -ForegroundColor Cyan
    Start-Process -FilePath "curseforge://launch-game?instanceId=$($found.Info.guid)&gameId=432"
}
