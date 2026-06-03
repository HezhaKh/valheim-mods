# Installing these Valheim mods on an Apple Silicon Mac (e.g. M2 MacBook Air)

> **Handoff note for the Claude session doing this install.** This repo was first set up on an
> Intel **MacBookPro14,3**. The **mods themselves are identical and portable** — only the
> *loader/launch* differs on Apple Silicon. Read the **"Why"** section before changing anything;
> it encodes facts that were expensive to verify and easy to get wrong.

## What's different on Apple Silicon (the whole story)

Valheim ships a **universal binary** (x86_64 + arm64), but this BepInEx pack's injector
`doorstop_libs/libdoorstop_x64.dylib` is **x86_64-only**. On Apple Silicon the game launches
**arm64** by default, so the x86_64 dylib gets rejected (`incompatible architecture, have
'x86_64' need 'arm64'`) and **no mods load** — usually the game just boots vanilla.

**Fix: force the game process to run x86_64 under Rosetta 2.** That's the only Apple-Silicon
delta. Everything else (entitlements, SIP, quarantine, `executable_name`, launch option) is the
same as Intel.

## Prerequisites
- Valheim installed via Steam. Game folder (confirm it exists, don't assume another user's path):
  `"$HOME/Library/Application Support/Steam/steamapps/common/Valheim"` — it contains `valheim.app`.
- This repo cloned locally:
  `git clone git@github.com:HezhaKh/valheim-mods-macbookpro14-3.git`

## Steps

1. **Install Rosetta 2** (needed for the x86_64 injector):
   ```sh
   softwareupdate --install-rosetta --agree-to-license
   ```

2. **Force x86_64 in the launcher (the Apple-Silicon-only edit).** In the cloned repo, change the
   final line of `mods/start_game_bepinex.sh` from:
   ```sh
   exec "$executable_path" "$@"
   ```
   to:
   ```sh
   exec /usr/bin/arch -x86_64 "$executable_path" "$@"
   ```
   This selects the x86_64 slice (→ Rosetta) at the exact moment the game is launched, so the
   exported `DYLD_INSERT_LIBRARIES` injection still applies. It is **harmless on Intel** (just
   selects the already-native slice), so it's safe to `git commit` back for both machines once
   verified here.
   *Alternative if you'd rather not edit the script:* in Finder, right-click `valheim.app` →
   **Get Info** → tick **"Open using Rosetta"**. (Less reliable for Steam-spawned processes than
   the `arch` edit, so prefer the edit; use this as a fallback.)

3. **Deploy the mods** into the game folder:
   ```sh
   cd <repo>
   ./deploy.sh
   ```
   `deploy.sh` auto-detects the game folder from `$HOME`, copies `BepInEx/`, `doorstop_libs/`,
   `doorstop_config.ini`, and `start_game_bepinex.sh` next to `valheim.app`, makes the launcher
   executable, and clears Gatekeeper quarantine.

4. **Set the Steam launch option.** Get the absolute path on THIS machine:
   ```sh
   echo "\"$HOME/Library/Application Support/Steam/steamapps/common/Valheim/start_game_bepinex.sh\" %command%"
   ```
   Paste the printed string into Steam → Valheim → Properties → Launch Options (quotes included —
   the path has spaces; `%command%` must be present).

5. **Launch from Steam.** First modded launch is slow (BepInEx builds its cache).

6. **Verify it actually loaded** (ground truth — don't trust "the window opened"):
   ```sh
   LOG="$HOME/Library/Application Support/Steam/steamapps/common/Valheim/BepInEx/LogOutput.log"
   find "$LOG" -mmin -10 -print && tail -n 20 "$LOG"
   ```
   Success = the log was just written and shows `Loading [ValheimPlus ...]` plus the other 3
   plugins. In-game, the inventory shows EquipmentAndQuickSlots' equipment + quick slots.

## Troubleshooting
- **`incompatible architecture (have 'x86_64', need 'arm64')`, or game boots vanilla** → the
  process is still arm64. Confirm Rosetta is installed (step 1) and the `arch -x86_64` edit (step 2)
  is in the *deployed* script (`grep arch "$HOME/Library/Application Support/Steam/steamapps/common/Valheim/start_game_bepinex.sh"`). Re-run `./deploy.sh` after editing.
- **Game exits immediately / never appears** → the `SteamLaunch` handler in the script didn't
  match the game path. The repo's script already sets `executable_name="valheim.app"`; if Steam
  on this machine passes the inner binary instead, set it to `Valheim`. Isolate the pack from
  Steam wiring by running directly (no SteamLaunch token → clean path):
  ```sh
  cd "$HOME/Library/Application Support/Steam/steamapps/common/Valheim"
  ./start_game_bepinex.sh "$PWD/valheim.app/Contents/MacOS/Valheim"
  ```
- **No `BepInEx/LogOutput.log` at all** → doorstop didn't inject. Re-clear quarantine
  (`xattr -dr com.apple.quarantine BepInEx doorstop_libs start_game_bepinex.sh`) and check the
  launch option is quoted.

## Why — do NOT skip (verified the hard way on the Intel machine)
- **Do NOT re-sign or otherwise modify `valheim.app`.** Despite the hardened runtime, Coffee Stain
  ships it with the entitlements `com.apple.security.cs.allow-dyld-environment-variables` +
  `com.apple.security.cs.disable-library-validation` — exactly what lets the **unsigned** x86_64
  doorstop dylib be injected under hardened runtime. Re-signing strips these and **breaks** modding.
  Verify with: `codesign -d --entitlements :- "$HOME/Library/Application Support/Steam/steamapps/common/Valheim/valheim.app"`
- **Do NOT disable SIP.** SIP only strips `DYLD_*` for protected *system* binaries; Valheim is a
  user-space third-party app, unaffected. (Hardened-runtime processes also strip `DYLD_*` *unless*
  entitled — and Valheim *is* entitled, which is why injection works.)
- **The only real Apple-Silicon variable is architecture** (Rosetta), because the bundled doorstop
  is x86_64-only. If a future pack ever ships `libdoorstop_arm64.dylib`, native arm64 could work
  without Rosetta — but this pack does not.
- **macOS/Steam/Rosetta interaction is the genuinely uncertain part — verify on the actual machine**
  with the LogOutput.log check rather than assuming. If the `arch -x86_64` script edit doesn't take,
  fall back to the Finder "Open using Rosetta" flag, and confirm via the log either way.

## Note on this repo
The repo name references the original Intel Mac, but `mods/` is shared and portable. Use the same
`./deploy.sh` here. The machine-specific bits (the Rosetta force + the absolute launch-option path)
live in the script/Steam/Finder settings, not in `mods/` data, so nothing conflicts between the two
Macs. After you confirm the `arch -x86_64` edit works, committing it makes the launcher cross-platform.
