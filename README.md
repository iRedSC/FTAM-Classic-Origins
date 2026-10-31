# FTAM Classic: Origins

Minecraft 1.7.10, Forge 10.13.4.1614.

## Play

New player: download [`FTAM Classic Origins.cmd`](https://raw.githubusercontent.com/iRedSC/FTAM-Classic-Origins/main/FTAM%20Classic%20Origins.cmd), or [`FTAM Classic Origins (dev).cmd`](https://raw.githubusercontent.com/iRedSC/FTAM-Classic-Origins/main/FTAM%20Classic%20Origins%20(dev).cmd) for dev builds, put it on your desktop and double-click it. It installs Git if needed, downloads this repo to `%USERPROFILE%\FTAM-Classic-Origins`, and runs `play.cmd` below for its branch. Double-click it again to play; it updates the pack every time.

Install [Prism Launcher](https://prismlauncher.org) and sign in once, then run `play.cmd` (main) or `play.cmd -Branch dev`.

It fetches that branch from GitHub into `.channels\<branch>`, a checkout only the script touches, creates or updates the `FTAM Classic: Origins` Prism instance, mirrors `mods/shared` and `mods/client` into it, and starts the game. Anything else in the instance's mods folder is removed.

After that, **Play** in Prism works too: the instance's pre-launch command updates and syncs the pack first, and Prism stops the launch if that fails. Each instance remembers its branch, so it doesn't matter which branch this checkout is on or what you edit in it; keep the checkout where it is. Close Prism the first time you run `play.cmd`, or it may keep its old copy of the instance's settings.

The first run also puts an `FTAM Classic Origins` shortcut to `play.cmd` on the desktop.

### CurseForge

Without Prism, `play.cmd` uses the CurseForge app instead (`play.cmd curseforge` picks it when both are installed). The first run opens CurseForge and a generated `FTAM Classic Origins.zip`: import it with **Create Custom Profile > Import**. Then quit CurseForge from its tray icon when asked: the script can only change a profile's Java arguments while CurseForge is closed. It adds `-javaagent:ftam-sync.jar` to them, fills the profile with the pack's mods and settings, and starts the game.

From then on, **Play** in CurseForge updates the pack first, like Prism's pre-launch command: `ftam-sync.jar` runs `play.ps1 -SyncProfile` before Forge loads, shows a small window while it works, and asks whether to quit or play anyway if the update fails. `play.cmd` and the desktop shortcut also start the game through CurseForge.

`scripts/ftam-sync.jar` is built from `scripts/ftam-sync/` by `scripts/ftam-sync/build.ps1` (needs a JDK 9+). Rebuild it after changing the source.

### Setting up with an AI agent

Tell your agent: *"Set up the FTAM Classic: Origins pack from github.com/iRedSC/FTAM-Classic-Origins following its README."* For the agent:

1. Needs Git. Clone the repo somewhere permanent, such as `%USERPROFILE%\FTAM-Classic-Origins`; the launcher runs scripts from this checkout on every Play, so it must not be moved or deleted.
2. Run `play.cmd -Branch main` (or `-Branch dev` for dev builds; add `curseforge` or `prism` to pick the launcher). It's non-interactive apart from what it prints in yellow, which is for the human: with CurseForge, the one-time Import and quitting CurseForge. It waits up to 15 minutes for each.
3. Done when it prints `Starting Minecraft`. The human then plays from the desktop shortcut or the launcher's Play, both of which update the pack first.

## Dev builds

The `dev` branch has the newest builds of our mods plus dev-only tools. `play.cmd -Branch dev`, or the dev desktop file, plays it in a separate `FTAM Classic: Origins (dev)` instance or profile; the main one is untouched. No `git switch` needed.

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

Two jars are patched in place, each by rewriting one string in its class files:

- `mods/shared/ThermalTinkering-1.7.10-1.2.1-gtnhmantle.jar` requires any `Mantle` instead of `Mantle@[1.7.10-0.3.2,)`. GTNH's Mantle is versioned `0.5.4`, which FML sorts below that, so the original refuses to load.
- `mods/server/BlockEditor.jar` catches `Throwable` where it caught `Exception`. Its scan of every block class hit MalisisDoors fields whose types only exist on the client, and the resulting `NoClassDefFoundError` stopped the server. Those blocks are now skipped and logged.

`mods/client/World-Stripper-*.jar` stays client only: its strip packet has no permission check, so on a server any player could clear blocks around them. Without it on the server, it only works in single player.

## Settings

`game/` holds the pack's settings: mod configs, MineTweaker `scripts/`, ContentTweaker `contentScripts/` and Flan's Mod content packs (`Flan/`: MPACK guns, GREYLIGHT armor and injectors). `play.cmd` and the server script copy each file in it over the game folder's copy every time they run, so edit them here, not in the instance or server. Files `game/` doesn't have, such as your own options, are left alone.

### Banned items

`game/scripts/banneditems.zs` is the one ban list. An item tagged with a red `§4` tooltip there loses its recipe and its NEI entry, and the server script turns every tagged item into Item Blacklist's `config/ItemBlacklist.json`, so players can't hold, place or use it (ops can). `<mod:item>` without a meta bans every variant; write `:0` to ban only the base one. A name the game doesn't know stops the server on start.
