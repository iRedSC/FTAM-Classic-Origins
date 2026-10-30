# FTAM Nostalgia

Minecraft 1.7.10, Forge 10.13.4.1614.

## Play

Install [Prism Launcher](https://prismlauncher.org) and sign in once, then run `play.cmd`.

It pulls this repo, creates or updates the `FTAM Nostalgia` Prism instance, mirrors `mods/shared` and `mods/client` into it, and starts the game. Anything else in the instance's mods folder is removed.

## Dev builds

The `dev` branch has the newest builds of our mods plus dev-only tools. Run `git switch dev`, then `play.cmd`; it plays in a separate `FTAM Nostalgia (dev)` instance. `git switch main` to go back.

## Mods

- `mods/shared`: client and server
- `mods/client`: client only
- `mods/server`: server only
