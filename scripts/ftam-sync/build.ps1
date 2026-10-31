# Rebuilds scripts/ftam-sync.jar from FtamSync.java. Needs a JDK 9 or newer on PATH, or its folder in JDK_HOME;
# the jar targets Java 8, which Minecraft 1.7.10 runs on.

$ErrorActionPreference = 'Stop'

$javac = if ($env:JDK_HOME) { Join-Path $env:JDK_HOME 'bin\javac.exe' } else { (Get-Command javac).Source }
$jar = Join-Path (Split-Path -Parent $javac) 'jar.exe'
$out = Join-Path $env:TEMP "ftam-sync-build-$PID"
$classes = Join-Path $out 'classes'
New-Item -ItemType Directory -Path $classes | Out-Null
try {
    & $javac --release 8 -nowarn -d $classes "$PSScriptRoot\FtamSync.java"
    if ($LASTEXITCODE -ne 0) { exit 1 }
    Set-Content -LiteralPath "$out\manifest.txt" -Value 'Premain-Class: FtamSync' -Encoding Ascii
    & $jar cfm "$PSScriptRoot\..\ftam-sync.jar" "$out\manifest.txt" -C $classes .
    if ($LASTEXITCODE -ne 0) { exit 1 }
}
finally {
    Remove-Item -Recurse -Force -LiteralPath $out
}
Write-Host 'Built scripts\ftam-sync.jar' -ForegroundColor Green
