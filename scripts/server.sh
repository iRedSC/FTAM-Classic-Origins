#!/usr/bin/env bash
# Installs or updates an FTAM Classic: Origins Forge server from this repo and starts it.
# Runs on Linux and in Git Bash on Windows.
#
#   scripts/server.sh [server-dir]
#
# server-dir defaults to ./server in the repo, or ./server-<branch> off main (both gitignored).
# FTAM_SERVER_MEMORY sets the max heap (default 6G); JAVA8 points at a Java 8 binary.

set -euo pipefail

MINECRAFT=1.7.10
FORGE=10.13.4.1614
FORGE_FULL="$MINECRAFT-$FORGE-$MINECRAFT"
FORGE_JAR="forge-$FORGE_FULL-universal.jar"
INSTALLER_URL="https://maven.minecraftforge.net/net/minecraftforge/forge/$FORGE_FULL/forge-$FORGE_FULL-installer.jar"
MEMORY="${FTAM_SERVER_MEMORY:-6G}"

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Any branch but main (dev builds) gets its own server folder, so it never touches the main world.
BRANCH="$(git -C "$REPO" rev-parse --abbrev-ref HEAD)"
if [ "$BRANCH" = main ]; then DEFAULT_SERVER="$REPO/server"; else DEFAULT_SERVER="$REPO/server-$BRANCH"; fi
SERVER="${1:-$DEFAULT_SERVER}"

fail() {
    printf '\033[31m%s\033[0m\n' "$*" >&2
    exit 1
}

say() {
    printf '\033[36m%s\033[0m\n' "$*"
}

is_java8() {
    [ -x "$1" ] && "$1" -version 2>&1 | head -n 1 | grep -q '"1\.8\.'
}

# Forge 1.7.10 only runs on Java 8, and most machines have something newer on PATH.
find_java8() {
    local candidate
    for candidate in "${JAVA8:-}" "$(command -v java || true)" \
        "$HOME"/.gradle/jdks/*-8-*/bin/java \
        "$HOME"/.local/jdks/*8u*/bin/java \
        /usr/lib/jvm/*-8-*/bin/java /usr/lib/jvm/*8*/jre/bin/java \
        "/c/Program Files/Java/"jre1.8*/bin/java.exe "/c/Program Files/Java/"jdk1.8*/bin/java.exe \
        "/c/Program Files/Eclipse Adoptium/"jdk-8*/bin/java.exe "/c/Program Files/Eclipse Adoptium/"jre-8*/bin/java.exe \
        "/c/Program Files/Zulu/"zulu-8*/bin/java.exe; do
        if [ -n "$candidate" ] && is_java8 "$candidate"; then
            echo "$candidate"
            return
        fi
    done
    fail 'Java 8 not found. Install Temurin 8, or set JAVA8 to its bin/java.'
}

update_repo() {
    say 'Pulling latest pack...'
    # play.cmd pulls the same repo, so a run started alongside it can briefly hit git's lock.
    local attempt
    for attempt in 1 2 3 4 5; do
        git -C "$REPO" pull --ff-only && return
        sleep 2
    done
    fail 'git pull failed. Resolve it in the repo, then run this again.'
}

install_forge() {
    # The marker records which Forge is installed, so changing FORGE above reinstalls it.
    if [ -f "$SERVER/$FORGE_JAR" ] && [ "$(cat "$SERVER/.forge-version" 2>/dev/null)" = "$FORGE_FULL" ]; then
        return
    fi
    say "Installing Forge $FORGE_FULL..."
    local installer="$SERVER/forge-installer.jar"
    curl -fsSL -o "$installer" "$INSTALLER_URL" || fail "Couldn't download the Forge installer from $INSTALLER_URL"
    (cd "$SERVER" && "$JAVA" -jar forge-installer.jar --installServer > forge-installer.log 2>&1) \
        || fail "Forge install failed. See $SERVER/forge-installer.log"
    rm -f "$installer" "$SERVER/forge-installer.log" "$SERVER/forge-installer.jar.log"
    echo "$FORGE_FULL" > "$SERVER/.forge-version"
}

sync_mods() {
    local mods="$SERVER/mods" side jar name
    declare -A wanted=()
    for side in shared server; do
        for jar in "$REPO/mods/$side"/*.jar; do
            [ -e "$jar" ] || continue
            name="$(basename "$jar")"
            [ -z "${wanted[$name]:-}" ] || fail "$name is in both mods/shared and mods/server. Keep one."
            wanted[$name]="$jar"
        done
    done

    mkdir -p "$mods"
    local added=0 updated=0 removed=0 existing

    # The top level of mods mirrors the repo exactly. Subfolders like mods/1.7.10 belong
    # to CodeChickenCore's dependency loader and are left alone.
    for existing in "$mods"/*; do
        [ -f "$existing" ] || continue
        name="$(basename "$existing")"
        if [ -z "${wanted[$name]:-}" ]; then
            rm -f "$existing"
            printf '\033[33m  - %s\033[0m\n' "$name"
            removed=$((removed + 1))
        fi
    done
    while IFS= read -r name; do
        if [ ! -f "$mods/$name" ]; then
            cp "${wanted[$name]}" "$mods/$name"
            printf '\033[32m  + %s\033[0m\n' "$name"
            added=$((added + 1))
        elif ! cmp -s "${wanted[$name]}" "$mods/$name"; then
            cp "${wanted[$name]}" "$mods/$name"
            printf '\033[36m  ~ %s\033[0m\n' "$name"
            updated=$((updated + 1))
        fi
    done < <(printf '%s\n' "${!wanted[@]}" | sort)

    echo "Mods: ${#wanted[@]} total, $added added, $updated updated, $removed removed"
}

sync_game() {
    # game/ holds the server's settings: mod configs and MineTweaker scripts. Each file in it replaces the
    # server's copy on every start; files it doesn't have, such as ones mods write themselves, are left alone.
    # NEI is client only, and one mods.nei call the server can't resolve makes MineTweaker skip the whole
    # script, so scripts reach the server without those lines.
    local file count=0 tmp
    tmp="$(mktemp)"
    while IFS= read -r -d '' file; do
        mkdir -p "$SERVER/$(dirname "$file")"
        case "$file" in
            *.zs) grep -v '^[[:space:]]*mods\.nei\.' "$REPO/game/$file" > "$tmp" || true ;;
            *) cp "$REPO/game/$file" "$tmp" ;;
        esac
        cmp -s "$tmp" "$SERVER/$file" && continue
        cp "$tmp" "$SERVER/$file"
        printf '\033[36m  ~ %s\033[0m\n' "$file"
        count=$((count + 1))
    done < <(cd "$REPO/game" && find . -type f -printf '%P\0')
    rm -f "$tmp"
    echo "Settings: $count updated from game/"
}

sync_bans() {
    # Item Blacklist enforces exactly what scripts/banneditems.zs tags "§4...", so that file is the one ban list.
    # <mod:item> without a meta bans every variant, which covers damaged tools and armor. Item Blacklist stops
    # the server over a name it doesn't know, so a typo there fails loudly on start instead of banning nothing.
    local entries
    entries="$(sed -n 's/^<\([^>]*\)>\.addTooltip("§4.*/\1/p' "$REPO/game/scripts/banneditems.zs" | awk -F: '
        !seen[$0]++ { printf "%s    {\"item\": \"%s:%s\", \"damage\": \"%s\"}", (n++ ? ",\n" : ""), $1, $2, (NF > 2 ? $3 : "*") }')"
    [ -n "$entries" ] || fail "game/scripts/banneditems.zs bans nothing, so Item Blacklist would let everything through."
    mkdir -p "$SERVER/config"
    printf '{\n  "__GLOBAL__": [\n%s\n  ]\n}\n' "$entries" > "$SERVER/config/ItemBlacklist.json"
    echo "Bans: $(grep -c '"item"' "$SERVER/config/ItemBlacklist.json") items from banneditems.zs"
}

mkdir -p "$SERVER"
JAVA="$(find_java8)"

# A pull that changed this script reruns it, so the new version does this run's work.
if [ -z "${FTAM_PULLED:-}" ]; then
    before="$(git -C "$REPO" hash-object "${BASH_SOURCE[0]}")"
    update_repo
    [ "$(git -C "$REPO" hash-object "${BASH_SOURCE[0]}")" = "$before" ] || FTAM_PULLED=1 exec bash "${BASH_SOURCE[0]}" "$@"
fi
install_forge
sync_mods
sync_game
sync_bans

# Running this script is agreeing to the Minecraft EULA: https://aka.ms/MinecraftEULA
[ -f "$SERVER/eula.txt" ] || echo 'eula=true' > "$SERVER/eula.txt"

say "Starting server with $JAVA ($MEMORY)..."
cd "$SERVER"
exec "$JAVA" -Xms1G "-Xmx$MEMORY" -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 \
    -XX:+DisableExplicitGC -jar "$FORGE_JAR" nogui
