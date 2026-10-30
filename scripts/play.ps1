# Syncs the FTAM Nostalgia Prism instance with this repo and starts the game.
# Runs on Windows PowerShell 5.1 and PowerShell 7.

$ErrorActionPreference = 'Stop'

$InstanceId    = 'FTAM-Nostalgia'
$InstanceName  = 'FTAM Nostalgia'
$Minecraft     = '1.7.10'
$Forge         = '10.13.4.1614'
$Lwjgl         = '2.9.4-nightly-20150209'
$MaxMemoryMb   = 6144

$Repo = Split-Path -Parent $PSScriptRoot

# Any branch but main (dev builds) gets its own instance, so it never touches the players' one.
$Branch = git -C $Repo rev-parse --abbrev-ref HEAD
if ($Branch -ne 'main') {
    $InstanceId   = "$InstanceId-$Branch"
    $InstanceName = "$InstanceName ($Branch)"
}

function Fail([string]$Message) {
    Write-Host $Message -ForegroundColor Red
    exit 1
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
    Fail 'Prism Launcher not found. Install it from https://prismlauncher.org and sign in once.'
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

function Update-Repo {
    Write-Host 'Pulling latest pack...' -ForegroundColor Cyan
    # server.cmd pulls the same repo, so a run started alongside it can briefly hit git's lock.
    foreach ($attempt in 1..5) {
        git -C $Repo pull --ff-only
        if ($LASTEXITCODE -eq 0) { return }
        Start-Sleep -Seconds 2
    }
    Fail 'git pull failed. Resolve it in the repo, then run this again.'
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
    }
}

function Write-Utf8([string]$Path, [string]$Text) {
    # Prism can't parse files that start with a BOM, which PowerShell 5.1 adds by default.
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding $false))
}

function Get-GameDir([string]$Dir) {
    if (Test-Path "$Dir\.minecraft") { return "$Dir\.minecraft" }
    return "$Dir\minecraft"
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
            elseif ((Get-FileHash -LiteralPath $source).Hash -ne (Get-FileHash -LiteralPath $target).Hash) {
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

$prism = Find-Prism
$instanceDir = Join-Path (Find-InstancesDir $prism) $InstanceId

Update-Repo
Write-InstanceFiles $instanceDir
Sync-Mods (Join-Path (Get-GameDir $instanceDir) 'mods')

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
