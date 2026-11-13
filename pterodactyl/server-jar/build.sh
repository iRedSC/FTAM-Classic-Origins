#!/usr/bin/env bash
# Rebuilds pterodactyl/ftam-server.jar from Bootstrap.java and bootstrap.sh. Needs a JDK 8 javac (JAVAC=...).
set -euo pipefail
cd "$(dirname "$0")"
out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT
"${JAVAC:-javac}" -source 8 -target 8 -d "$out" Bootstrap.java
cp bootstrap.sh "$out/"
printf 'Main-Class: Bootstrap\n' > "$out/manifest.txt"
"$(dirname "$(command -v "${JAVAC:-javac}")")/jar" cfm ../ftam-server.jar "$out/manifest.txt" -C "$out" Bootstrap.class -C "$out" bootstrap.sh
echo "wrote pterodactyl/ftam-server.jar"
