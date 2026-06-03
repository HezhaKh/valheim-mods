#!/bin/sh
# sync-back.sh — copy the game's CURRENT mod state back into this repo (mods/), so you can
# review and commit it. Useful when you edited a config from the in-game menu, or dropped a
# mod straight into the game folder. Runtime files (caches, logs, vplus-data) are not pulled.
#
# After running:  git status  ->  git add -A  ->  git commit -m "..."
#
# Override the game location:   VALHEIM_DIR="/path/to/Valheim" ./sync-back.sh
set -eu

REPO_DIR=$(cd "$(dirname "$0")" && pwd)
DST="$REPO_DIR/mods"
GAME="${VALHEIM_DIR:-$HOME/Library/Application Support/Steam/steamapps/common/Valheim}"

if [ ! -d "$GAME/BepInEx" ]; then echo "sync-back.sh: no BepInEx at $GAME" >&2; exit 1; fi
mkdir -p "$DST/BepInEx/plugins" "$DST/BepInEx/config" "$DST/BepInEx/core" "$DST/doorstop_libs"

echo "game: $GAME"
echo "repo: $DST"
echo

rsync -a --delete --exclude='.DS_Store' "$GAME/BepInEx/plugins/" "$DST/BepInEx/plugins/"
rsync -a --delete --exclude='.DS_Store' "$GAME/BepInEx/config/"  "$DST/BepInEx/config/"
rsync -a            --exclude='.DS_Store' "$GAME/BepInEx/core/"    "$DST/BepInEx/core/"
if [ -d "$GAME/BepInEx/patchers" ]; then rsync -a --exclude='.DS_Store' "$GAME/BepInEx/patchers/" "$DST/BepInEx/patchers/"; fi
rsync -a --exclude='.DS_Store' "$GAME/doorstop_libs/" "$DST/doorstop_libs/"
for f in doorstop_config.ini start_game_bepinex.sh start_server_bepinex.sh .doorstop_version winhttp.dll; do
  if [ -f "$GAME/$f" ]; then rsync -a "$GAME/$f" "$DST/$f"; fi
done

echo "Synced game -> repo. Review with:  git -C \"$REPO_DIR\" status"
