#!/usr/bin/env bash
# Starts FTAM Classic: Origins on a Pterodactyl server at the pack's latest GitHub release, the same one the Technic
# pack downloads, or at the release tag in PACK_RELEASE.
#
# The egg's install step clones the pack into ./pack and puts this file at ./start.sh. Each start replaces it with the
# newest copy from the pack's main branch, so fixes here reach servers without importing the egg again.
# ./pack is managed: every start resets it to the release, so edits made there are lost.

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELF="$HERE/$(basename "${BASH_SOURCE[0]}")"
PACK="$HERE/pack"
PACK_URL=https://github.com/iRedSC/FTAM-Classic-Origins
WANT="${PACK_RELEASE:-latest}"
[ -n "$WANT" ] || WANT=latest

say() { printf '\033[36m%s\033[0m\n' "$*"; }
warn() { printf '\033[33m%s\033[0m\n' "$*"; }
fail() {
    printf '\033[31m%s\033[0m\n' "$*" >&2
    exit 1
}

[ -d "$PACK/.git" ] || fail "No pack in $PACK. Reinstall the server from the panel (Settings > Reinstall Server)."

# Install clones as root and the server runs as the container user, so git may call the checkout unsafe.
git config --global --get-all safe.directory 2>/dev/null | grep -qxF '*' || git config --global --add safe.directory '*'

online=1
git -C "$PACK" fetch -q --tags --force origin || {
    online=0
    warn "Couldn't reach GitHub, so the pack can't update this start."
}

# A newer copy of this script on main replaces this one and runs instead. It's written to a new file and renamed,
# never edited in place, because bash is still reading this file as it runs.
if [ "$online" = 1 ] && [ -z "${FTAM_START_UPDATED:-}" ]; then
    new="$HERE/.start.sh.new"
    if git -C "$PACK" show origin/main:pterodactyl/start.sh > "$new" 2>/dev/null && [ -s "$new" ] && ! cmp -s "$new" "$SELF"; then
        mv -f "$new" "$SELF"
        say "Updated start.sh from the pack's main branch."
        FTAM_START_UPDATED=1 exec bash "$SELF" "$@"
    fi
    rm -f "$new"
fi

# The release that ran last, so a start without GitHub can run it again.
running="$(git -C "$PACK" config --get ftam.release || true)"

if [ "$WANT" = latest ]; then
    tag=""
    if [ "$online" = 1 ]; then
        # GitHub redirects /releases/latest to /releases/tag/<tag>, or to /releases when there are none.
        url="$(curl -fsSL -o /dev/null -w '%{url_effective}' "$PACK_URL/releases/latest" || true)"
        case "$url" in */releases/tag/?*) tag="${url##*/releases/tag/}" ;; esac
    fi
    if [ -z "$tag" ]; then
        [ -n "$running" ] || fail "Couldn't find the pack's latest release at $PACK_URL/releases, and none has run here before."
        warn "Couldn't find the pack's latest release; running $running again."
        tag="$running"
    fi
else
    tag="$WANT"
fi

git -C "$PACK" rev-parse -q --verify "refs/tags/$tag^{commit}" > /dev/null \
    || fail "The pack has no release $tag. Pick one from $PACK_URL/releases, or set Pack release to latest."

# The checkout is a local branch whose upstream is the release tag itself, so the server script's own
# `git pull --ff-only` finds nothing to pull instead of failing on a detached HEAD or pulling past the release.
git -C "$PACK" checkout -q -f -B release "refs/tags/$tag" || fail "Couldn't check out release $tag in $PACK."
git -C "$PACK" config branch.release.remote .
git -C "$PACK" config branch.release.merge "refs/tags/$tag"
git -C "$PACK" config ftam.release "$tag"

if [ "$WANT" = latest ]; then
    say "FTAM Classic: Origins $tag (latest release)"
else
    say "FTAM Classic: Origins $tag (pinned by Pack release)"
fi
[ -z "$running" ] || [ "$running" = "$tag" ] || say "Was $running."

# Pterodactyl's memory limit covers the whole container, and Java needs room outside its heap.
if [ "${SERVER_MEMORY:-0}" -gt 0 ] 2>/dev/null; then
    export FTAM_SERVER_MEMORY="$((SERVER_MEMORY * 85 / 100))M"
fi

exec bash "$PACK/scripts/server.sh" "$HERE"
