#!/usr/bin/env bash
# What ftam-server.jar runs. It does the egg's install step (clone the pack, put start.sh beside it), finds or
# downloads Java 8, then hands off to start.sh, which updates to the latest release and starts Forge.
# For panels whose egg can't be changed: their startup is `java -jar <jar>` on whatever Java the image has.

set -uo pipefail

HERE="$(pwd)"
PACK="$HERE/pack"
PACK_URL=https://github.com/iRedSC/FTAM-Classic-Origins.git
JDKS="$HERE/.local/jdks"

say() { printf '\033[36m%s\033[0m\n' "$*"; }
fail() {
    printf '\033[31m%s\033[0m\n' "$*" >&2
    exit 1
}

command -v git > /dev/null || fail "This server's image has no git, which the pack needs to update. Pick a Java image that has it (Startup > Docker Image)."
git config --global --get-all safe.directory 2>/dev/null | grep -qxF '*' || git config --global --add safe.directory '*'

if [ ! -d "$PACK/.git" ]; then
    say "Downloading the pack..."
    rm -rf "$PACK"
    git clone -q "$PACK_URL" "$PACK" || fail "Couldn't clone $PACK_URL."
fi
if [ ! -s "$HERE/start.sh" ]; then
    git -C "$PACK" fetch -q --tags --force origin
    git -C "$PACK" show origin/main:pterodactyl/start.sh > "$HERE/start.sh" || fail "Couldn't read start.sh from the pack."
fi

is_java8() { [ -x "$1" ] && "$1" -version 2>&1 | head -n 1 | grep -q '"1\.8\.'; }

java8=""
for candidate in "${JAVA8:-}" "$(command -v java || true)" "$JDKS"/*8u*/bin/java; do
    if [ -n "$candidate" ] && is_java8 "$candidate"; then java8="$candidate"; break; fi
done
if [ -z "$java8" ]; then
    # Forge 1.7.10 runs only on Java 8, and the image's Java is newer, so fetch a Temurin 8 JRE once.
    case "$(uname -m)" in
        x86_64) arch=x64 ;;
        aarch64) arch=aarch64 ;;
        *) fail "No Java 8 download for $(uname -m)." ;;
    esac
    say "This image's Java isn't 8, which Forge 1.7.10 needs. Downloading Temurin 8 ($arch) once..."
    mkdir -p "$JDKS"
    tmp="$JDKS/.download"
    rm -rf "$tmp" && mkdir -p "$tmp"
    curl -fsSL "https://api.adoptium.net/v3/binary/latest/8/ga/linux/$arch/jre/hotspot/normal/eclipse" \
        | tar -xz -C "$tmp" || fail "Couldn't download Java 8 from adoptium.net."
    dir="$(ls "$tmp")"
    rm -rf "${JDKS:?}/$dir" && mv "$tmp/$dir" "$JDKS/$dir" && rm -rf "$tmp"
    java8="$JDKS/$dir/bin/java"
    is_java8 "$java8" || fail "The Java 8 download didn't run."
fi
export JAVA8="$java8"

exec bash "$HERE/start.sh"
