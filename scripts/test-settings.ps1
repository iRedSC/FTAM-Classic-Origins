# The play.ps1 half of scripts/test-settings.sh: repeats its launches with settings.ps1 and checks each file comes out
# byte for byte as merge-settings.awk wrote it. Takes the folder test-settings.sh set up.
param([Parameter(Mandatory)][string]$T)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'settings.ps1')
function Write-Host { }  # Sync output isn't part of the test.
$fail = 0
$state = New-Object System.Collections.Generic.HashSet[string]

function Merge-Copy([string]$Rel, [string]$From, [string]$To, $State) {
    if ($From -ne '') { Copy-Item -LiteralPath $From -Destination $To -Force }
    $new = New-Object System.Collections.Generic.List[string]
    Set-OwnedSettings $T $Rel $To $State $new | Out-Null
    foreach ($s in $new) { $State.Add($s) | Out-Null }
}

function Test-Same([string]$Name, [string]$Ps, [string]$Awk) {
    $a = [IO.File]::ReadAllBytes($Ps); $b = [IO.File]::ReadAllBytes($Awk)
    if ([Convert]::ToBase64String($a) -ceq [Convert]::ToBase64String($b)) { [Console]::WriteLine("PASS play.ps1 agrees: $Name") }
    else { [Console]::WriteLine("FAIL play.ps1 differs: $Name"); $script:fail = 1 }
}

Merge-Copy 'config/a.cfg' "$T/player.cfg" "$T/p1" $state
Test-Same 'first launch' "$T/p1" "$T/a1"
Copy-Item "$T/a1b" "$T/p2"
Merge-Copy 'config/a.cfg' '' "$T/p2" $state
Test-Same 'player rebinds a once key' "$T/p2" "$T/a2"
Copy-Item "$T/p2" "$T/p3"
Merge-Copy 'config/a.cfg' '' "$T/p3" $state
Test-Same 'third launch' "$T/p3" "$T/a3"
Merge-Copy 'config/a.cfg' '' "$T/pfresh" (New-Object System.Collections.Generic.HashSet[string])
Test-Same 'fresh install' "$T/pfresh" "$T/fresh"
Merge-Copy 'options.txt' "$T/options.txt" "$T/po1" $state
Test-Same 'options.txt' "$T/po1" "$T/o1"
Merge-Copy 'config/forge.cfg' "$T/forge.cfg" "$T/pf1" $state
Test-Same 'Forge categories' "$T/pf1" "$T/f1"
Merge-Copy 'config/a.cfg' "$T/spread.cfg" "$T/ps1" (New-Object System.Collections.Generic.HashSet[string])
Test-Same 'a matching list stays spread' "$T/ps1" "$T/s1"
exit $fail
