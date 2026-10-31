# Syncs the FTAM Classic: Origins Prism instance (or CurseForge profile, see curseforge.ps1) with a branch of this repo
# and starts the game. Runs on Windows PowerShell 5.1 and PowerShell 7.
# `play.cmd curseforge` or `play.cmd prism` picks the launcher; `-Branch dev` plays that branch (default main).
# -SyncOnly is Prism's pre-launch command: it updates and syncs the instance Prism is about to start, without launching.
# -SyncProfile <folder> is the same for CurseForge, run by ftam-sync.jar when Play starts that profile.
#
# The pack always comes from GitHub's copy of the branch, kept in .channels\<branch>, a checkout only this script
# touches. Which branch this checkout is on, and any edits in it, never change what a player gets.

param([ValidateSet('prism', 'curseforge')][string]$Launcher, [string]$Branch, [switch]$SyncOnly, [string]$SyncProfile,
      # Set when this runs from the branch's freshly updated .channels copy, which does the actual work.
      [switch]$Ready)

$ErrorActionPreference = 'Stop'

function Fail([string]$Message) {
    Write-Host $Message -ForegroundColor Red
    exit 1
}

function Resolve-Branch {
    if ($Branch) { return $Branch }
    # Hooks made before -Branch existed: the instance or profile they start says which branch it plays.
    if ($SyncOnly) {
        if ($env:INST_ID -match '^FTAM-Nostalgia-(.+)$') { return $Matches[1] }
        return 'main'
    }
    if ($SyncProfile) {
        $file = Join-Path $SyncProfile 'minecraftinstance.json'
        if (Test-Path -LiteralPath $file) {
            try { $name = ([System.IO.File]::ReadAllText($file) | ConvertFrom-Json).manifest.name } catch { $name = $null }
            if ($name -match '\(([^()]+)\)$') { return $Matches[1] }
        }
    }
    return 'main'
}

# The instance's folder, which Prism launches it by. It predates the rename from FTAM Nostalgia and stays,
# so players keep their instance and everything in it.
$InstanceId    = 'FTAM-Nostalgia'
$InstanceName  = 'FTAM Classic: Origins'
# Instances and CurseForge profiles made before the rename still carry this name.
$OldName       = 'FTAM Nostalgia'
$Minecraft     = '1.7.10'
$Forge         = '10.13.4.1614'
$Lwjgl         = '2.9.4-nightly-20150209'
$MaxMemoryMb   = 6144

# This script's checkout: the player's own, or with -Ready, the branch's .channels copy, which the pack is read from.
$Repo = Split-Path -Parent $PSScriptRoot
# The player's checkout, which holds the .channels folder whichever copy this runs from.
$Base = Split-Path -Parent (git -C $Repo rev-parse --path-format=absolute --git-common-dir)
if ($LASTEXITCODE -ne 0) { Fail "$Repo isn't a git checkout of the pack. Download it again." }

$Branch = Resolve-Branch
$Channel = Join-Path $Base ('.channels\' + ($Branch -replace '[\\/:*?"<>|]', '-'))

# Any branch but main (dev builds) gets its own instance, so it never touches the players' one.
if ($Branch -ne 'main') {
    $InstanceId   = "$InstanceId-$Branch"
    $InstanceName = "$InstanceName ($Branch)"
    $OldName      = "$OldName ($Branch)"
}

function Find-Prism {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\PrismLauncher\prismlauncher.exe",
        "$env:ProgramFiles\PrismLauncher\prismlauncher.exe",
        "$env:USERPROFILE\scoop\apps\prismlauncher\current\prismlauncher.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }
    $cmd = Get-Command prismlauncher -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Find-InstancesDir([string]$PrismExe) {
    # A portable install keeps its data next to the exe; otherwise it lives in AppData.
    $exeDir = Split-Path -Parent $PrismExe
    $dataDir = if (Test-Path "$exeDir\portable.txt") { $exeDir } else { "$env:APPDATA\PrismLauncher" }
    $instanceDir = 'instances'
    $cfg = "$dataDir\prismlauncher.cfg"
    if (Test-Path $cfg) {
        $line = Select-String -Path $cfg -Pattern '^InstanceDir=(.+)$' | Select-Object -First 1
        if ($line) { $instanceDir = $line.Matches[0].Groups[1].Value }
    }
    if ([System.IO.Path]::IsPathRooted($instanceDir)) { return $instanceDir }
    return Join-Path $dataDir $instanceDir
}

function Update-Channel {
    Write-Host "Updating the $Branch pack..." -ForegroundColor Cyan
    # server.cmd fetches into the same repo, so a run started alongside it can briefly hit git's lock.
    $ref = "refs/remotes/origin/$Branch"
    foreach ($attempt in 1..5) {
        git -C $Base fetch -q origin "+refs/heads/${Branch}:$ref"
        if ($LASTEXITCODE -eq 0) { break }
        if ($attempt -eq 5) { Fail "Couldn't get the '$Branch' pack from GitHub. Check your connection and that the branch exists, then run this again." }
        Start-Sleep -Seconds 2
    }
    # The channel is this script's alone, so it's reset to GitHub's copy rather than merged.
    if (Test-Path -LiteralPath "$Channel\.git") {
        git -C $Channel reset -q --hard $ref
        if ($LASTEXITCODE -ne 0) { Fail "Couldn't update the '$Branch' pack in $Channel. Close Minecraft and run this again." }
        return
    }
    git -C $Base worktree prune
    if (Test-Path -LiteralPath $Channel) { Remove-Item -Recurse -Force -LiteralPath $Channel }
    git -C $Base worktree add -q --detach $Channel $ref
    if ($LASTEXITCODE -ne 0) { Fail "Couldn't set up the '$Branch' pack in $Channel." }
}

function Rename-OldInstance([string]$Dir) {
    # An instance still on the old name gets the new one. A name the player chose is left alone.
    # A running Prism keeps showing the old name until it restarts.
    $cfg = "$Dir\instance.cfg"
    if (-not (Test-Path -LiteralPath $cfg)) { return }
    $text = [System.IO.File]::ReadAllText($cfg)
    $pattern = '(?m)^name="?' + [regex]::Escape($OldName) + '"?(\r?)$'
    if (-not [regex]::IsMatch($text, $pattern)) { return }
    $text = [regex]::Replace($text, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) "name=$InstanceName" + $m.Groups[1].Value })
    Write-Utf8 $cfg $text
    Write-Host "Renamed Prism instance '$OldName' to '$InstanceName'" -ForegroundColor Green
}

function Write-InstanceFiles([string]$Dir) {
    New-Item -ItemType Directory -Force -Path $Dir | Out-Null

    # The repo owns the Minecraft/Forge versions, so this is rewritten every run.
    $pack = [ordered]@{
        formatVersion = 1
        components = @(
            [ordered]@{ uid = 'org.lwjgl'; version = $Lwjgl; dependencyOnly = $true },
            [ordered]@{ uid = 'net.minecraft'; version = $Minecraft; important = $true },
            [ordered]@{ uid = 'net.minecraftforge'; version = $Forge }
        )
    }
    Write-Utf8 "$Dir\mmc-pack.json" ($pack | ConvertTo-Json -Depth 5)

    # Settings are only seeded once so changes made in Prism stick.
    Rename-OldInstance $Dir
    $cfg = "$Dir\instance.cfg"
    if (-not (Test-Path $cfg)) {
        Write-Utf8 $cfg ((@(
            '[General]',
            'ConfigVersion=1.2',
            'InstanceType=OneSix',
            "name=$InstanceName",
            'iconKey=default',
            'OverrideMemory=true',
            "MaxMemAlloc=$MaxMemoryMb",
            'MinMemAlloc=1024'
        ) -join "`r`n") + "`r`n")
        Write-Host "Created Prism instance '$InstanceName'" -ForegroundColor Green
        New-DesktopShortcut $prism
    }

    # Prism's Play runs the branch's copy of this script with -SyncOnly first, so launching from Prism also updates the pack.
    $command = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "{0}" -SyncOnly -Branch {1}' -f $PSCommandPath, $Branch
    # Qt's INI format needs a quoted value with escaped inner quotes. Raw quotes
    # are parsed as INI syntax and can swallow the space before -SyncOnly.
    $settings = [ordered]@{
        OverrideCommands = 'true'
        PreLaunchCommand = '"' + $command.Replace('\', '/').Replace('"', '\"') + '"'
        LogPrePostOutput = 'true'
    }
    $text = [System.IO.File]::ReadAllText($cfg)
    foreach ($key in $settings.Keys) {
        $line = "$key=$($settings[$key])"
        $pattern = '(?m)^' + [regex]::Escape($key) + '=[^\r\n]*'
        $text = if ([regex]::IsMatch($text, $pattern)) {
            [regex]::Replace($text, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $line })
        } else {
            $text.TrimEnd() + "`r`n$line`r`n"
        }
    }
    Write-Utf8 $cfg $text
}

function New-DesktopShortcut([string]$Icon) {
    # Made once, when the pack is first set up, so a shortcut the player deleted stays deleted.
    $name = ($InstanceName.Split([System.IO.Path]::GetInvalidFileNameChars()) -join '') -replace '\s+', ' '
    $path = Join-Path ([Environment]::GetFolderPath('Desktop')) "$name.lnk"
    if ($env:FTAM_NO_SHORTCUT -or (Test-Path -LiteralPath $path)) { return }
    $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($path)
    $shortcut.TargetPath = "$Base\play.cmd"
    $shortcut.Arguments = "-Branch $Branch"
    $shortcut.WorkingDirectory = $Base
    if ($Icon) { $shortcut.IconLocation = "$Icon,0" }
    $shortcut.Save()
    Write-Host "Added '$name' to your desktop: it updates the pack and starts the game." -ForegroundColor Green
}

function Write-Utf8([string]$Path, [string]$Text) {
    # Prism can't parse files that start with a BOM, which PowerShell 5.1 adds by default.
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding $false))
}

function Get-GameDir([string]$Dir) {
    if (Test-Path "$Dir\.minecraft") { return "$Dir\.minecraft" }
    return "$Dir\minecraft"
}

function Get-Hash([string]$Path) {
    # Get-FileHash's module isn't always loaded in the PowerShell Prism starts for the pre-launch command.
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try { return [System.BitConverter]::ToString($sha.ComputeHash($stream)) }
    finally { $stream.Dispose(); $sha.Dispose() }
}

function Sync-Mods([string]$ModsDir) {
    $wanted = @{}
    foreach ($side in 'shared', 'client') {
        foreach ($jar in Get-ChildItem -File -Path "$Repo\mods\$side" -Filter '*.jar') {
            if ($wanted.ContainsKey($jar.Name)) {
                Fail "$($jar.Name) is in both mods\shared and mods\client. Keep one."
            }
            $wanted[$jar.Name] = $jar.FullName
        }
    }

    New-Item -ItemType Directory -Force -Path $ModsDir | Out-Null
    $added = 0; $updated = 0; $removed = 0

    try {
        # The mods folder mirrors the repo exactly; anything else is removed.
        foreach ($existing in Get-ChildItem -File -Path $ModsDir) {
            if (-not $wanted.ContainsKey($existing.Name)) {
                Remove-Item -LiteralPath $existing.FullName
                Write-Host "  - $($existing.Name)" -ForegroundColor DarkYellow
                $removed++
            }
        }
        foreach ($name in ($wanted.Keys | Sort-Object)) {
            $source = $wanted[$name]
            $target = Join-Path $ModsDir $name
            if (-not (Test-Path -LiteralPath $target)) {
                Copy-Item -LiteralPath $source -Destination $target
                Write-Host "  + $name" -ForegroundColor Green
                $added++
            }
            elseif ((Get-Hash $source) -ne (Get-Hash $target)) {
                Copy-Item -LiteralPath $source -Destination $target -Force
                Write-Host "  ~ $name" -ForegroundColor Cyan
                $updated++
            }
        }
    }
    catch [System.IO.IOException] {
        Fail "Couldn't change the mods folder: $($_.Exception.Message)`nClose Minecraft and run this again."
    }

    Write-Host ("Mods: {0} total, {1} added, {2} updated, {3} removed" -f $wanted.Count, $added, $updated, $removed)
}

function Sync-Game([string]$GameDir) {
    # game\ holds the pack's settings: mod configs and MineTweaker scripts. Each file in it replaces the
    # instance's copy on every launch; files it doesn't have, such as your own options, are left alone.
    $source = (Resolve-Path -LiteralPath "$Repo\game").Path
    $count = 0
    try {
        foreach ($file in Get-ChildItem -File -Recurse -LiteralPath $source) {
            $target = Join-Path $GameDir $file.FullName.Substring($source.Length + 1)
            if ((Test-Path -LiteralPath $target) -and
                (Get-Hash $file.FullName) -eq (Get-Hash $target)) {
                continue
            }
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $target -Force
            $count++
        }
    }
    catch [System.IO.IOException] {
        Fail "Couldn't change the game's settings: $($_.Exception.Message)`nClose Minecraft and run this again."
    }
    Write-Host "Settings: $count updated from game\"
}

# Prism names the instance it's launching. Refuse before updating if this hook is for another instance's branch.
if ($SyncOnly -and $env:INST_ID -ne $InstanceId) {
    Fail "This instance's hook plays the '$Branch' pack, which belongs to '$InstanceName'. Run play.cmd -Branch <this instance's branch> once to fix it."
}

# The branch's updated copy of this script does the work, so it always matches the pack it syncs.
if (-not $Ready) {
    Update-Channel
    $forward = @{} + $PSBoundParameters
    $forward.Branch = $Branch
    $forward.Ready = $true
    & "$Channel\scripts\play.ps1" @forward
    exit $LASTEXITCODE
}

if ($SyncOnly) {
    Rename-OldInstance $env:INST_DIR
    Sync-Mods (Join-Path (Get-GameDir $env:INST_DIR) 'mods')
    Sync-Game (Get-GameDir $env:INST_DIR)
    Write-Host 'Pack ready.' -ForegroundColor Green
    exit 0
}

. "$PSScriptRoot\curseforge.ps1"
if ($SyncProfile) {
    Sync-CurseForgeProfile $SyncProfile
    exit 0
}

# Keep the launcher that already has the pack. A new player gets Prism if it's installed, else CurseForge.
$prism = Find-Prism
$instanceDir = if ($prism) { Join-Path (Find-InstancesDir $prism) $InstanceId }
if (-not $Launcher) {
    $Launcher = if ($prism -and ((Test-Path -LiteralPath $instanceDir) -or -not (Find-CurseForgeProfile))) { 'prism' } else { 'curseforge' }
}
if ($Launcher -eq 'curseforge') {
    Start-CurseForge
    exit 0
}
if (-not $prism) {
    Fail 'Prism Launcher not found. Install it from https://prismlauncher.org and sign in once.'
}

Write-InstanceFiles $instanceDir
Sync-Mods (Join-Path (Get-GameDir $instanceDir) 'mods')
Sync-Game (Get-GameDir $instanceDir)

if (Get-Process -Name prismlauncher -ErrorAction SilentlyContinue) {
    # A running Prism only rescans when the instances folder itself changes, so poke it
    # and give it a moment; otherwise it rejects the launch for an instance it hasn't seen.
    $poke = Join-Path (Split-Path -Parent $instanceDir) ".rescan-$PID"
    New-Item -ItemType Directory -Path $poke | Out-Null
    Remove-Item -LiteralPath $poke
    Start-Sleep -Seconds 2
}

Write-Host 'Starting Minecraft...' -ForegroundColor Cyan
Start-Process -FilePath $prism -ArgumentList '--launch', $InstanceId
