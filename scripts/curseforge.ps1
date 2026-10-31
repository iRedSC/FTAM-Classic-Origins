# The CurseForge half of play.ps1, which dot-sources it after pulling and supplies the pack settings,
# Fail, Sync-Mods and Sync-Game. CurseForge can't be told what a profile contains or to launch one,
# so a new player imports a generated modpack once, and play.cmd syncs that profile on every run.

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

function Find-CurseForgeProfile {
    # The import names the profile's manifest after the pack, and that name survives renaming the profile.
    if (-not (Test-Path -LiteralPath $CurseForgeInstances)) { return $null }
    foreach ($dir in Get-ChildItem -Directory -LiteralPath $CurseForgeInstances) {
        $file = Join-Path $dir.FullName 'minecraftinstance.json'
        if (-not (Test-Path -LiteralPath $file)) { continue }
        $text = [System.IO.File]::ReadAllText($file)
        if (-not ($text.Contains($InstanceName) -or $text.Contains($OldName))) { continue }
        try { $info = $text | ConvertFrom-Json } catch { continue }
        if ($info.manifest -and ($info.manifest.name -eq $InstanceName -or $info.manifest.name -eq $OldName)) {
            return [pscustomobject]@{ Dir = $dir.FullName; Info = $info }
        }
    }
    return $null
}

function Rename-OldProfile($Found) {
    # A profile still on the old name gets the new one; a name the player chose is left alone.
    # A running CurseForge would write its own copy back, so this waits for a run with it closed.
    if ($Found.Info.name -ne $OldName) { return }
    if (Get-Process -Name CurseForge -ErrorAction SilentlyContinue) { return }
    $file = Join-Path $Found.Dir 'minecraftinstance.json'
    # A text edit, so the rest of CurseForge's file stays exactly as it wrote it.
    $pattern = '"name"(\s*):(\s*)"' + [regex]::Escape($OldName) + '"'
    $text = [regex]::Replace([System.IO.File]::ReadAllText($file), $pattern,
        [System.Text.RegularExpressions.MatchEvaluator]{ param($m) '"name"' + $m.Groups[1].Value + ':' + $m.Groups[2].Value + '"' + $InstanceName + '"' })
    [System.IO.File]::WriteAllText($file, $text, (New-Object System.Text.UTF8Encoding $false))
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

    Rename-OldProfile $found

    # The import pins the versions, so a pack that moved to new ones needs a fresh profile.
    $loader = $found.Info.baseModLoader
    if ($found.Info.gameVersion -ne $Minecraft -or ($loader -and $loader.name -notlike "*$Forge*")) {
        Fail "CurseForge profile '$($found.Info.name)' doesn't run Minecraft $Minecraft with Forge $Forge. Delete it in CurseForge and run this again."
    }

    Sync-Mods (Join-Path $found.Dir 'mods')
    Sync-Game $found.Dir

    if ($exe -and -not (Get-Process -Name CurseForge -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath $exe
    }
    Write-Host "Pack ready. Press Play on '$($found.Info.name)' in CurseForge." -ForegroundColor Green
}
