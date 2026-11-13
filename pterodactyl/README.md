# Pterodactyl

`egg-ftam-classic-origins.json` runs the pack's server on a [Pterodactyl](https://pterodactyl.io) panel. Every start updates it to the pack's latest GitHub release, the same one the Technic pack downloads.

## Set up

1. **Import the egg.** Admin > Nests > Import Egg, pick `egg-ftam-classic-origins.json`, and put it in a nest such as Minecraft.
2. **Create a server** with that egg. Give it at least 6 GB of memory; the server's heap is 85% of whatever it gets. One port is enough.
3. **Start it.** Installing only downloads the pack. The first start also downloads Forge and copies the mods, so it takes a few minutes before `Done`.

## Updating

**Restart the server** to update it. Each start looks up the newest release, checks it out in `pack/`, and syncs Forge, mods, plugins and settings from it. The console's first lines say which release is running and which ran before.

To **roll back**, set the server's **Pack release** variable (Startup tab) to an older tag from the [releases page](https://github.com/iRedSC/FTAM-Classic-Origins/releases) and restart. Set it back to `latest` to follow new releases again.

If GitHub can't be reached, the server starts on the release it ran last.

## Files

- `start.sh`, which the egg runs, replaces itself with the newest copy from this repo's `main` on each start, so changes to it never need the egg imported again. Changes to the egg itself do.
- `pack/` is the pack checkout. Every start resets it to the release, so don't edit it; the server's own `config/`, `world/` and other files are where changes go.
- The pack's mods, plugins and `game/` settings overwrite the server's copies on every start. Files the pack doesn't ship are left alone.
