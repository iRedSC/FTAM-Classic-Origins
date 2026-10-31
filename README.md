# FTAM Nostalgia

Minecraft 1.7.10, Forge 10.13.4.1614.

## Play

Install [Prism Launcher](https://prismlauncher.org) and sign in once, then run `play.cmd`.

It pulls this repo, creates or updates the `FTAM Nostalgia` Prism instance, mirrors `mods/shared` and `mods/client` into it, and starts the game. Anything else in the instance's mods folder is removed.

After that, **Play** in Prism works too: the instance's pre-launch command pulls and syncs the pack first, and Prism stops the launch if that fails. Keep this checkout where it is, and on the branch the instance belongs to. Close Prism the first time you run `play.cmd`, or it may keep its old copy of the instance's settings.

### CurseForge

Without Prism, `play.cmd` uses the CurseForge app instead (`play.cmd curseforge` picks it when both are installed). The first run opens CurseForge and a generated `FTAM Nostalgia.zip`: import it with **Create Custom Profile > Import**, and the script fills the new profile with the pack's mods and settings. After that, run `play.cmd` before playing to update, then press **Play** in CurseForge. It can't launch the game or update on its own.

## Dev builds

The `dev` branch has the newest builds of our mods plus dev-only tools. Run `git switch dev`, then `play.cmd`; it plays in a separate `FTAM Nostalgia (dev)` instance. `git switch main` to go back.

## Server

Run `scripts/server.sh` on Linux, or `server.cmd` on Windows (needs Git for Windows). It needs Java 8 and finds most installs on its own; set `JAVA8` if it doesn't.

It pulls this repo, installs Forge into `server/` (or the folder you pass as the first argument), mirrors `mods/shared` and `mods/server` into it, and starts the server. On `dev` it uses `server-dev/` instead. `FTAM_SERVER_MEMORY` sets the max heap (default `6G`). Running it accepts the [Minecraft EULA](https://aka.ms/MinecraftEULA).

## Mods

- `mods/shared`: client and server
- `mods/client`: client only
- `mods/server`: server only

`mods/shared/CraftTweaker-addons.jar` fills two gaps in CraftTweaker 3.4.8:

- One empty IndustrialCraft 2 class (`ic2.api.crops.CropCard`, source inside). CraftTweaker's built-in registry references it, and without it skips the whole registry, so every `<ore:...>` and `<liquid:...>` in the scripts fails.
- CraftTweaker 3.1.0's MineFactoryReloaded module (`minetweaker.mods.mfr`), unchanged. 3.4.8 still loads it if present but no longer ships it, and `scripts/MFR.zs` needs it for the laser drill and harvester.

Remove it only alongside a CraftTweaker that covers both.

## Settings

`game/` holds the pack's settings: mod configs, MineTweaker `scripts/`, ContentTweaker `contentScripts/` and Flan's Mod content packs (`Flan/`: MPACK guns, GREYLIGHT armor and injectors). `play.cmd` and the server script copy each file in it over the game folder's copy every time they run, so edit them here, not in the instance or server. Files `game/` doesn't have, such as your own options, are left alone.

### Banned items

`game/scripts/banneditems.zs` is the one ban list. An item tagged with a red `§4` tooltip there loses its recipe and its NEI entry, and the server script turns every tagged item into Item Blacklist's `config/ItemBlacklist.json`, so players can't hold, place or use it (ops can). `<mod:item>` without a meta bans every variant; write `:0` to ban only the base one. A name the game doesn't know stops the server on start.
