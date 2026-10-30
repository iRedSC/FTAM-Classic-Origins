# FTAM Nostalgia

Minecraft 1.7.10, Forge 10.13.4.1614.

## Play

Install [Prism Launcher](https://prismlauncher.org) and sign in once, then run `play.cmd`.

It pulls this repo, creates or updates the `FTAM Nostalgia` Prism instance, mirrors `mods/shared` and `mods/client` into it, and starts the game. Anything else in the instance's mods folder is removed.

## Dev builds

The `dev` branch has the newest builds of our mods plus dev-only tools. Run `git switch dev`, then `play.cmd`; it plays in a separate `FTAM Nostalgia (dev)` instance. `git switch main` to go back.

## Server

Run `scripts/server.sh` on Linux, or `server.cmd` on Windows (needs Git for Windows). It needs Java 8 and finds most installs on its own; set `JAVA8` if it doesn't.

It pulls this repo, installs Forge into `server/` (or the folder you pass as the first argument), mirrors `mods/shared` and `mods/server` into it, and starts the server. On `dev` it uses `server-dev/` instead. `FTAM_SERVER_MEMORY` sets the max heap (default `6G`). Running it accepts the [Minecraft EULA](https://aka.ms/MinecraftEULA).

## Mods

- `mods/shared`: client and server
- `mods/client`: client only
- `mods/server`: server only

## Settings

`game/` holds the pack's settings: mod configs, MineTweaker `scripts/` and ContentTweaker `contentScripts/`. `play.cmd` and the server script copy each file in it over the game folder's copy every time they run, so edit them here, not in the instance or server. Files `game/` doesn't have, such as your own options, are left alone.
