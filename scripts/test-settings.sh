#!/usr/bin/env bash
# Checks the settings merge: scripts/merge-settings.awk (servers) and play.ps1's Merge-Settings (players) give the same
# result over a few launches. Needs pwsh for the second half; without it only the awk half runs.
set -euo pipefail
cd "$(dirname "$0")/.."
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
fail=0
check() { if [ "$2" = "$3" ]; then echo "PASS $1"; else echo "FAIL $1: expected [$3], got [$2]"; fail=1; fi; }

# game/ overwrites a whole file, which would undo every once line, so a path lives in one or the other.
both="$(cd settings 2>/dev/null && find always once -type f | sed 's#^[^/]*/##' | sort -u | while read -r f; do
    [ -e "../game/$f" ] && echo "$f"; done || true)"
check "no file is in both game/ and settings/" "$both" ""

mkdir -p "$T/settings/always/config" "$T/settings/once/config"
cat > "$T/settings/always/config/a.cfg" <<'EOF'
[General]
Ammo = false
List = 1
List = 2, extra
[Keys]
Menu = 0
EOF
cat > "$T/settings/once/config/a.cfg" <<'EOF'
[Keys]
Up = 17
Menu = 50
EOF
cat > "$T/settings/once/options.txt" <<'EOF'
key_key.xaero_open_map:50
EOF
cat > "$T/settings/always/config/forge.cfg" <<'EOF'
general {
    B:enabled=false
}
EOF
cat > "$T/player.cfg" <<'EOF'
[General]
Ammo = true
List = 9
Mine = 3
List = 8

[Keys]
Up = 200
Menu = 50
EOF
printf 'fov:0.5\r\nkey_key.xaero_open_map:21\r\n' > "$T/options.txt"
cat > "$T/forge.cfg" <<'EOF'
general {
    B:enabled=true
    I:other=4
}
EOF

awk_merge() { # <rel> <sep> <target> <state>
    local always="$T/settings/always/$1" once="$T/settings/once/$1"
    [ -f "$always" ] || always=/dev/null
    [ -f "$once" ] || once=/dev/null
    touch "$4"
    awk -v SEP="$2" -v FILE="$1" -v NEWSTATE="$4.new" -f scripts/merge-settings.awk \
        part=state "$4" part=once "$once" part=always "$always" part=target "$3"
    [ ! -f "$4.new" ] || { cat "$4.new" >> "$4"; rm -f "$4.new"; }
}

# Launch 1: the player's file gets every pack line; once lines apply the first time.
awk_merge config/a.cfg = "$T/player.cfg" "$T/state" > "$T/a1"
check "always lines replace the player's" "$(grep '^Ammo' "$T/a1")" "Ammo = false"
check "a repeated key is replaced as a whole" "$(grep '^List' "$T/a1" | tr '\n' '|')" "List = 1|List = 2, extra|"
check "lines the pack doesn't name stay" "$(grep '^Mine' "$T/a1")" "Mine = 3"
check "always beats once" "$(grep '^Menu' "$T/a1")" "Menu = 0"
check "once applies the first time" "$(grep '^Up' "$T/a1")" "Up = 17"
# A list already matching the pack's, spread apart as a mod wrote it, is left where it is.
printf '[General]\nList = 1\nAmmo = false\nList = 2, extra\n' > "$T/spread.cfg"
awk_merge config/a.cfg = "$T/spread.cfg" "$T/state-spread" > "$T/s1"
check "a matching list isn't regrouped" "$(sed -n 1,4p "$T/s1" | tr '\n' '|')" "[General]|List = 1|Ammo = false|List = 2, extra|"
# Launch 2: the player rebinds Up; it stays theirs.
sed 's/^Up = 17/Up = 72/' "$T/a1" > "$T/a1b"
awk_merge config/a.cfg = "$T/a1b" "$T/state" > "$T/a2"
check "a once line the player changed stays changed" "$(grep '^Up' "$T/a2")" "Up = 72"
awk_merge config/a.cfg = "$T/a2" "$T/state" > "$T/a3"
check "a third launch changes nothing" "$(cmp -s "$T/a2" "$T/a3" && echo same)" "same"
# A fresh install: the file doesn't exist yet.
awk_merge config/a.cfg = /dev/null "$T/state-fresh" > "$T/fresh"
check "a fresh file lists sections in the pack's order" "$(grep '^\[' "$T/fresh" | tr '\n' '|')" "[General]|[Keys]|"
# options.txt keeps CRLF and its own lines.
awk_merge options.txt : "$T/options.txt" "$T/state" > "$T/o1"
check "options.txt keeps CRLF" "$(grep -c $'\r$' "$T/o1")" "2"
check "options.txt gets the once key" "$(grep -a xaero "$T/o1" | tr -d '\r')" "key_key.xaero_open_map:50"
# Forge categories.
awk_merge config/forge.cfg = "$T/forge.cfg" "$T/state" > "$T/f1"
check "Forge category lines keep their indent" "$(grep enabled "$T/f1")" "    B:enabled=false"

# A CRLF file: a once line the player changes stays changed (the state file must match across line endings).
printf '[Keys]\r\nUp = 200\r\n' > "$T/crlf.cfg"
awk_merge config/a.cfg = "$T/crlf.cfg" "$T/state-crlf" > "$T/c1"
check "CRLF: once applies the first time" "$(grep -a '^Up' "$T/c1" | tr -d '\r')" "Up = 17"
sed 's/^Up = 17/Up = 72/' "$T/c1" > "$T/c1b"
awk_merge config/a.cfg = "$T/c1b" "$T/state-crlf" > "$T/c2"
check "CRLF: the player's change stays" "$(grep -a '^Up' "$T/c2" | tr -d '\r')" "Up = 72"
check "the state file has no CR" "$(grep -c $'\r' "$T/state-crlf")" "0"

# Xaero's lines share a first word: `# key:` names the one the pack owns, and the others stay.
mkdir -p "$T/settings/once/config"
cat > "$T/settings/once/config/xaerominimap.txt" <<'EOF2'
# key: interface:gui.xaero_minimap
interface:gui.xaero_minimap:0:0:false:false:false:false
EOF2
cat > "$T/xaerominimap.txt" <<'EOF2'
minimap:true
interface:dummy:0:0:true:false:false:false
interface:gui.xaero_minimap:120:40:false:false:true:false
interface:dummy:0:36:true:false:false:false
EOF2
awk_merge config/xaerominimap.txt : "$T/xaerominimap.txt" "$T/state-x" > "$T/x1"
check "only the minimap's interface line moves" "$(tr '\n' '|' < "$T/x1")" \
    "minimap:true|interface:dummy:0:0:true:false:false:false|interface:gui.xaero_minimap:0:0:false:false:false:false|interface:dummy:0:36:true:false:false:false|"
sed 's/gui.xaero_minimap:0:0:false:false:false:false/gui.xaero_minimap:5:5:false:false:true:true/' "$T/x1" > "$T/x1b"
awk_merge config/xaerominimap.txt : "$T/x1b" "$T/state-x" > "$T/x2"
check "a player who moves the minimap keeps it there" "$(grep xaero_minimap "$T/x2")" "interface:gui.xaero_minimap:5:5:false:false:true:true"

if command -v pwsh >/dev/null; then
    pwsh -NoProfile -File scripts/test-settings.ps1 "$T" || fail=1
else
    echo "SKIP play.ps1 half: no pwsh"
fi
exit $fail
