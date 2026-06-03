#!/bin/sh
# deploy.sh — push this repo's mod payload (mods/) into the Steam Valheim game folder.
#
#   ./deploy.sh             Copy mode (default): rsync mods/ -> game dir.
#   ./deploy.sh --link      Symlink mode: link mods/ into the game dir so edits go live
#                           with no re-deploy (the repo becomes the single source of truth).
#   ./deploy.sh --dry-run   Show what would change without touching anything.
#   ./deploy.sh --help      This help.
#
# Override the game location:   VALHEIM_DIR="/path/to/Valheim" ./deploy.sh
set -eu

REPO_DIR=$(cd "$(dirname "$0")" && pwd)
SRC="$REPO_DIR/mods"
GAME="${VALHEIM_DIR:-$HOME/Library/Application Support/Steam/steamapps/common/Valheim}"

MODE=copy
DRY=""
for a in "$@"; do
  case "$a" in
    --link)    MODE=link ;;
    --dry-run) DRY="--dry-run" ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "deploy.sh: unknown argument '$a' (try --help)" >&2; exit 2 ;;
  esac
done

if [ ! -d "$SRC" ]; then echo "deploy.sh: no payload at $SRC" >&2; exit 1; fi
if [ ! -d "$GAME/valheim.app" ]; then
  echo "deploy.sh: Valheim not found at: $GAME" >&2
  echo "  Set VALHEIM_DIR=\"/path/to/Valheim\" and retry." >&2
  exit 1
fi

echo "repo: $SRC"
echo "game: $GAME"
echo "mode: $MODE${DRY:+  (dry-run)}"
echo

if [ "$MODE" = link ]; then
  if [ -z "$DRY" ]; then
    echo "WARNING: --link deletes the game's current BepInEx/doorstop files and replaces them"
    echo "with symlinks into this repo. Run ./sync-back.sh first if the game folder has changes"
    echo "you haven't captured yet."
    printf "Continue? [y/N] "
    read -r ans
    case "$ans" in y|Y|yes|YES) ;; *) echo "aborted."; exit 0 ;; esac
  fi
  for item in BepInEx doorstop_libs doorstop_config.ini start_game_bepinex.sh start_server_bepinex.sh .doorstop_version winhttp.dll; do
    if [ -e "$SRC/$item" ]; then
      if [ -n "$DRY" ]; then echo "  link  $item"; else rm -rf "$GAME/$item"; ln -sfn "$SRC/$item" "$GAME/$item"; fi
    fi
  done
else
  # Copy mode. Only named sub-paths are synced, so valheim.app is never at risk.
  # plugins/ and config/ use --delete, so mods/configs removed in the repo also leave the game.
  echo "syncing:"
  rsync -a $DRY --delete --exclude='.DS_Store' "$SRC/BepInEx/plugins/" "$GAME/BepInEx/plugins/"
  rsync -a $DRY --delete --exclude='.DS_Store' "$SRC/BepInEx/config/"  "$GAME/BepInEx/config/"
  rsync -a $DRY            --exclude='.DS_Store' "$SRC/BepInEx/core/"    "$GAME/BepInEx/core/"
  if [ -d "$SRC/BepInEx/patchers" ]; then rsync -a $DRY --exclude='.DS_Store' "$SRC/BepInEx/patchers/" "$GAME/BepInEx/patchers/"; fi
  rsync -a $DRY --exclude='.DS_Store' "$SRC/doorstop_libs/" "$GAME/doorstop_libs/"
  for f in doorstop_config.ini start_game_bepinex.sh start_server_bepinex.sh .doorstop_version winhttp.dll; do
    if [ -f "$SRC/$f" ]; then rsync -a $DRY "$SRC/$f" "$GAME/$f"; fi
  done
fi

if [ -n "$DRY" ]; then echo; echo "(dry-run — nothing changed)"; exit 0; fi

# Make launcher runnable + clear Gatekeeper quarantine on the injected files.
chmod +x "$GAME/start_game_bepinex.sh" 2>/dev/null || true
if [ -f "$GAME/start_server_bepinex.sh" ]; then chmod +x "$GAME/start_server_bepinex.sh" 2>/dev/null || true; fi
xattr -dr com.apple.quarantine "$GAME/BepInEx" "$GAME/doorstop_libs" "$GAME/start_game_bepinex.sh" 2>/dev/null || true

echo
echo "Deployed ($MODE). Launch Valheim from Steam."
