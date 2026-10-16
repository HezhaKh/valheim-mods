# Valheim mods (BepInEx) — Windows and macOS

Version-controlled home for the mod profile shared by my Windows PC and MacBookPro14,3.
The canonical files live in `mods/`. Windows uses the bundled `winhttp.dll` loader;
macOS uses `deploy.sh` and the bundled shell launcher.

## Current status: Valheim 1.0.20

Updated and startup-tested on Windows on **2026-10-16**: Steam build **25909357**,
Valheim **1.0.20**, network version **41**, BepInExPack **5.4.2351**, and ValheimPlus
package **10.3.0** / plugin **0.10.3.0**. The other mods remain on their latest published
stable versions. A graphical test using a disposable save directory loaded all five
plugins (**5 loaded, 0 skipped, 0 failed**), initialized the main-menu scene, and logged
no errors or exceptions. No character, world or server was selected during that test.
See [MODS.md](MODS.md) for versions, release sources, preserved settings and test limits.

To join the same server, its game and every modded client must also use **Valheim 1.0.20
(network 41)** and **ValheimPlus 0.10.3.0**. The existing `enforceMod = true` setting
rejects a mismatched ValheimPlus version; keep enforcement enabled. Multiplayer with
this updated profile has not yet been tested. The successful **2026-10-13** session,
including saves and normal logout reviewed on **2026-10-14**, used the earlier
Valheim **1.0.17** / ValheimPlus **0.10.2.0** profile.

Back up characters and worlds before the first real login. EquipmentAndQuickSlots 3.x
automatically migrates the old 2.x slot data when a character is loaded, and that saved
migration has no downgrade path. Keep modded clients on the same profile revision and
matching game version. With `serverSyncsConfig = true`, ValheimPlus receives the server's
settings after joining; those runtime overrides can differ from the local config file.

## Windows installation, step by step

These steps reproduce the installation at `G:\SteamLibrary\steamapps\common\Valheim`.
Use your own Steam game folder on another PC.

1. **Close Valheim and back up saves.** Copy `%USERPROFILE%\AppData\LocalLow\IronGate\Valheim`
   to a separate backup location. Also back up any Steam Cloud characters/worlds through
   the game's Manage Saves controls; the local folder alone may not contain cloud saves.
2. **Get this repository.** Use GitHub's **Code → Download ZIP** and extract it, or run:

   ```powershell
   git clone https://github.com/HezhaKh/valheim-mods.git
   ```

   Keep all files from the same revision. This profile targets Valheim **1.0.20**
   (network **41**) and ValheimPlus **0.10.3.0**. Update the game through Steam and
   coordinate the same versions with the server before joining. Later game updates
   need a fresh compatibility check.
3. **Open the game folder.** In Steam, right-click **Valheim → Properties → Installed Files → Browse**.
   Confirm that `valheim.exe` is directly inside the folder.
4. **Back up an existing mod installation.** If `BepInEx` is already present, move it into
   a separate backup folder outside the game directory. Copy any existing `winhttp.dll`,
   `doorstop_config.ini`, and `.doorstop_version` into that backup too. Using a clean
   `BepInEx` folder prevents old or duplicate plugin DLLs from loading alongside this set.
5. **Install the Windows payload.** Copy these items from the extracted repository's
   `mods` folder directly into the folder containing `valheim.exe`:

   - `BepInEx` (the entire folder, including `core`, `plugins`, and `config`)
   - `winhttp.dll`
   - `doorstop_config.ini`
   - `.doorstop_version`

   The result must be `Valheim\BepInEx\plugins\*.dll`, not `Valheim\mods\BepInEx\plugins\*.dll`.
   The `.sh` launchers and `doorstop_libs` are for other platforms and are not needed on Windows.
6. **Set Windows launch options.** Steam → Valheim → Properties → General → Launch Options
   can be empty. Remove any copied macOS `start_game_bepinex.sh` command. Start Valheim
   normally from Steam; `winhttp.dll` activates BepInEx automatically.
7. **Verify the first launch.** Open `BepInEx\LogOutput.log` in the game folder and look for:

   ```text
   Valheim Version: 1.0.20
   Loading [Craft From Containers 4.0.7]
   Loading [Jotunn 2.30.2]
   Loading [Smart Containers Mod 1.8.3]
   Loading [Valheim Plus 0.10.3.0]
   Loading [Equipment and Quick Slots 3.1.3]
   Chainloader startup complete (5 loaded, 0 skipped, 0 failed)
   ```

   The real loading lines also contain each plugin's GUID. Investigate missing plugins,
   exceptions, or version mismatches before loading a character with extra-slot items.
8. **Join the same server once its versions match.** Confirm that the server uses Valheim
   **1.0.20 / network 41** and ValheimPlus **0.10.3.0**, then use its existing address and
   password. Check the log for matching versions and receipt of the server config.
   Do not disable version enforcement to connect to the old profile. Verify your equipment
   and quick slots (`I`, `O`, `P`) after spawning, then check crafting and container behavior.
   The current profile has passed startup testing; server play and individual mechanics
   still need an in-game check. The **2026-10-13** successful spawn was on the older profile.

## Layout

- `mods/` — the shared deployable payload
  - `BepInEx/plugins/` — the mods (`*.dll`) ← **swap these to update**
  - `BepInEx/config/`  — mod config files (`*.cfg`)
  - `BepInEx/core/`    — BepInEx framework (rarely changes)
  - `winhttp.dll`, `doorstop_config.ini`, `.doorstop_version` — the Windows loader
  - `doorstop_libs/`, `start_game_bepinex.sh`, `start_server_bepinex.sh` — native libraries and shell launchers
- `deploy.sh`    — push `mods/` → macOS Steam game folder
- `sync-back.sh` — pull the macOS game folder's current state → `mods/`
- `MODS.md`      — versions, compatibility findings, and upstream sources
- `SHA256SUMS`   — verify payload integrity with `shasum -a 256 -c SHA256SUMS`

The shell helpers target macOS; they are not Windows deployment tools.
Mac game folder (auto-detected): `~/Library/Application Support/Steam/steamapps/common/Valheim`
Override with `VALHEIM_DIR="/path/to/Valheim" ./deploy.sh` on another machine.

## macOS Steam launch option

Steam → Valheim → Properties → Launch Options:
```
"/Users/hkh/Library/Application Support/Steam/steamapps/common/Valheim/start_game_bepinex.sh" %command%
```

## Everyday workflows on macOS

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

## Two macOS deploy modes

- **Copy (default):** `./deploy.sh` copies `mods/` into the game folder. Predictable, and
  survives Steam's "Verify integrity of game files". Re-run after each change.
- **Symlink:** `./deploy.sh --link` links the game folder at `mods/`, so edits go live with
  **no re-deploy** — the repo becomes the single source of truth. Runtime files the game writes
  (caches/logs) are git-ignored.

`deploy.sh` only ever touches the mod files (`BepInEx/`, `doorstop_*`, the loader). It never
deletes `valheim.app`.

## Restore vanilla

On **Windows**, close Valheim and rename the game-local `winhttp.dll` to
`winhttp.dll.disabled`. Rename it back to re-enable this profile. Clearing Steam launch
options alone does not disable the Windows loader.

On **macOS**, clear the shell launcher from Steam Launch Options to bypass the mod loader.
If game files need repair,
also use Steam → Valheim → Properties → Installed Files → **Verify integrity of game files**.
Verification alone does not clear launch options or remove third-party mods. Test
vanilla with a fresh character; an existing EquipmentAndQuickSlots character needs
working extra-slot support to preserve those items.

## GitHub backup / sync across machines

The canonical remote is [HezhaKh/valheim-mods](https://github.com/HezhaKh/valheim-mods).
After reviewing and committing changes, run `git push origin main`. Keep character
and world backups separately; this repo does not contain saves.

On Windows, capture intentional settings changes while the game is closed by copying
the five matching `.cfg` files from the game's `BepInEx\config` into
`mods\BepInEx\config`. Review `git diff` before committing. BepInEx may rewrite line
endings, blank lines, or empty-value spacing without changing a setting. Server-synced
ValheimPlus values are applied at runtime and should not be mistaken for edits to the
local config. Do not copy logs, caches, saves, or `valheim_plus.cfg.migrated` into Git.

## Installing on another Mac

1. Close Valheim and back up local and Steam Cloud characters/worlds.
2. Clone this repository, then open Terminal in the cloned directory.
3. Run `./deploy.sh --dry-run`, review its output, then run `./deploy.sh`.
4. Set Steam Launch Options to `"/your/actual/Valheim/start_game_bepinex.sh" %command%`.
5. Start from Steam and check the same five plugin versions in `BepInEx/LogOutput.log`.

The launcher (`mods/start_game_bepinex.sh`) auto-detects the chip for Intel and Apple
Silicon Macs. The current profile was validated on Windows; macOS runtime validation
still needs to be performed on the destination Mac.

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
