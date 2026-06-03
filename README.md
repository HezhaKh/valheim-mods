# Valheim mods (BepInEx) — local repo

Version-controlled home for my Valheim mod setup on this MacBook Pro. The canonical files
live in `mods/`; `deploy.sh` pushes them into the Steam game folder. Update a mod by swapping
its file in `mods/`, commit, and redeploy.

## Layout
- `mods/` — the full deployable payload (everything that sits next to `valheim.app`)
  - `BepInEx/plugins/` — the mods (`*.dll`) ← **swap these to update**
  - `BepInEx/config/`  — mod config files (`*.cfg`)
  - `BepInEx/core/`    — BepInEx framework (rarely changes)
  - `doorstop_libs/`, `doorstop_config.ini`, `start_game_bepinex.sh` — the macOS loader
- `deploy.sh`    — push `mods/` → Steam game folder
- `sync-back.sh` — pull the game folder's current state → `mods/`
- `MODS.md`      — what's installed + where to get updates

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
3. `git add -A && git commit -m "update <mod> to <version>"`

**Remove a mod** — delete its `.dll` from `mods/BepInEx/plugins/`, then `./deploy.sh`, then commit.

**Roll back to a previous version**
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
Blank the Steam Launch Options, and/or Steam → Valheim → Properties → Installed Files →
**Verify integrity of game files**.

## Back it up / sync across machines (optional)
This repo is local-only. To push it to GitHub for backup or a second Mac:
```
gh repo create valheim-mods --private --source . --push   # needs gh + GitHub auth
```

## Installing on another Mac
- **Apple Silicon (M1/M2/M3, e.g. the M2 MacBook Air):** see
  [`INSTALL-apple-silicon.md`](INSTALL-apple-silicon.md). The mods are identical; the only
  difference is the game must be forced to run x86_64 under Rosetta 2 (the bundled injector is
  x86_64-only). Clone this repo there and follow that file.
- **Another Intel Mac:** clone, `./deploy.sh`, set the launch option with that machine's path.

## Alternative: a mod manager
If you'd rather click-to-update than manage files by hand, **r2modman** or **Gale** are free,
open-source Valheim mod managers (Thunderstore, macOS) with one-click updates, version pinning,
and profile import/export. Say the word and I can set one up instead of (or alongside) this repo.
