# Valheim mods (BepInEx) — MacBookPro14,3

Version-controlled home for my Valheim mod setup on this MacBook Pro. The canonical files
live in `mods/`; `deploy.sh` pushes them into the Steam game folder. Update a mod by swapping
its file in `mods/`, commit, and redeploy.

## Current status: Valheim 1.0.17

The profile was refreshed and startup-tested on **2026-10-06** against Steam build
**25730771** (Valheim **1.0.17**, network version 40). BepInEx loaded all five plugins
with no skipped or failed plugins, and the graphical test reached the main menu without
mod exceptions. See [MODS.md](MODS.md) for exact package versions, sources, migrations,
and the remaining gameplay/server checks.

Back up characters and worlds before the first real login. EquipmentAndQuickSlots 3.x
automatically migrates the old 2.x slot data when a character is loaded, and that saved
migration has no downgrade path. All server players should deploy this exact revision;
ValheimPlus and Jotunn enforce matching multiplayer versions/configuration.

## Layout
- `mods/` — the full deployable payload (everything that sits next to `valheim.app`)
  - `BepInEx/plugins/` — the mods (`*.dll`) ← **swap these to update**
  - `BepInEx/config/`  — mod config files (`*.cfg`)
  - `BepInEx/core/`    — BepInEx framework (rarely changes)
  - `doorstop_libs/`, `doorstop_config.ini`, `start_game_bepinex.sh` — the macOS loader
- `deploy.sh`    — push `mods/` → Steam game folder
- `sync-back.sh` — pull the game folder's current state → `mods/`
- `MODS.md`      — versions, compatibility findings, and upstream sources
- `SHA256SUMS`   — verify payload integrity with `shasum -a 256 -c SHA256SUMS`

Game folder (auto-detected): `~/Library/Application Support/Steam/steamapps/common/Valheim`
Override with `VALHEIM_DIR="/path/to/Valheim" ./deploy.sh` on another machine.

## Steam launch option (already set on this Mac)
Steam → Valheim → Properties → Launch Options:
```
"/Users/hkh/Library/Application Support/Steam/steamapps/common/Valheim/start_game_bepinex.sh" %command%
```

## Everyday workflows

**Update / add a mod**
1. Drop the new `.dll` into `mods/BepInEx/plugins/` (and any `.cfg` into `mods/BepInEx/config/`).
2. `./deploy.sh`
3. Update `MODS.md` and `SHA256SUMS`, then commit the reviewed changes.

**Remove a mod** — first check its save-data requirements (especially EquipmentAndQuickSlots), then delete its `.dll`, update the inventory/checksums, deploy, and commit.

**Roll back to a previous version**

Older profile revisions require their matching game version. Rolling back only the mods
does not undo save or EquipmentAndQuickSlots 3.x character migrations.
```
git log --oneline
git checkout <commit> -- mods/
./deploy.sh
```

**Captured a change in-game?** (edited a config from the in-game menu, etc.)
```
./sync-back.sh
git add -A && git commit -m "capture in-game config changes"
```

**Preview a deploy without changing anything:** `./deploy.sh --dry-run`

## Two deploy modes
- **Copy (default):** `./deploy.sh` copies `mods/` into the game folder. Predictable, and
  survives Steam's "Verify integrity of game files". Re-run after each change.
- **Symlink:** `./deploy.sh --link` links the game folder at `mods/`, so edits go live with
  **no re-deploy** — the repo becomes the single source of truth. Runtime files the game writes
  (caches/logs) are git-ignored.

`deploy.sh` only ever touches the mod files (`BepInEx/`, `doorstop_*`, the loader). It never
deletes `valheim.app`.

## Restore vanilla
Clear the Steam Launch Options to bypass the mod loader. If game files need repair,
also use Steam → Valheim → Properties → Installed Files → **Verify integrity of game files**.
Verification alone does not clear launch options or remove third-party mods. Test
vanilla with a fresh character; an existing EquipmentAndQuickSlots character needs
working extra-slot support to preserve those items.

## GitHub backup / sync across machines

The canonical remote is [HezhaKh/valheim-mods-macbookpro14-3](https://github.com/HezhaKh/valheim-mods-macbookpro14-3).
After reviewing and committing changes, run `git push origin main`. Keep character
and world backups separately; this repo does not contain saves.

## Installing on another Mac
Clone the repo, run `./deploy.sh`, and set the Steam launch option with that machine's path. The
launcher (`mods/start_game_bepinex.sh`) auto-detects the chip, so the same files work everywhere:
- **Apple Silicon (M1/M2/M3):** first install Rosetta 2
  (`softwareupdate --install-rosetta --agree-to-license`) — the bundled injector is x86_64-only, so
  the launcher forces the game to run x86_64 under Rosetta. Don't re-sign `valheim.app` or disable
  SIP; neither change is needed, and re-signing can remove the entitlements that permit injection. (The launcher's inline comments
  explain the `arch`/`DYLD_*` mechanics.)
- **Intel:** nothing extra — the launcher runs the game directly.

## Alternative: a mod manager
If you'd rather click-to-update than manage files by hand, **r2modman** or **Gale** are free,
open-source Valheim mod managers (Thunderstore, macOS) with one-click updates, version pinning,
and profile import/export. Say the word and I can set one up instead of (or alongside) this repo.
