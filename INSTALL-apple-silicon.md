# Installing these Valheim mods on an Apple Silicon Mac (e.g. M2 MacBook Air)

> **Handoff note for the Claude session doing this install.** This repo was first set up on an
> Intel **MacBookPro14,3**. The **mods themselves are identical and portable** — only the
> *loader/launch* differs on Apple Silicon. Read the **"Why"** section before changing anything;
> it encodes facts that were expensive to verify and easy to get wrong.
>
> **Status: verified working on an Apple-Silicon M3 (June 2026)** — all 4 plugins load under
> Rosetta. The committed launcher **auto-detects the hardware**, so the *same* `start_game_bepinex.sh`
> is correct on both Intel and Apple Silicon (M1/M2/M3); no per-machine edit is needed.

## What's different on Apple Silicon (the whole story)

Valheim ships a **universal binary** (x86_64 + arm64), but this BepInEx pack's injector
`doorstop_libs/libdoorstop_x64.dylib` is **x86_64-only**. On Apple Silicon the game launches
**arm64** by default, so the x86_64 dylib gets rejected (`incompatible architecture, have
'x86_64' need 'arm64'`) and **no mods load** — usually the game just boots vanilla.

**Fix: force the game process to run x86_64 under Rosetta 2 — *and* make sure the `DYLD_*`
injection vars survive the switch.** Forcing x86_64 is necessary but **not sufficient**: the
obvious `arch -x86_64` wrapper strips `DYLD_*` (see step 2), so the vars must be re-asserted
after it. That architecture-plus-`DYLD_*` dance is the only Apple-Silicon delta. Everything else
(entitlements, SIP, quarantine, `executable_name`, launch option) is the same as Intel.

## Prerequisites
- Valheim installed via Steam. Game folder (confirm it exists, don't assume another user's path):
  `"$HOME/Library/Application Support/Steam/steamapps/common/Valheim"` — it contains `valheim.app`.
- This repo cloned locally:
  `git clone git@github.com:HezhaKh/valheim-mods-macbookpro14-3.git`

## Steps

1. **Install Rosetta 2** (Apple Silicon only — needed for the x86_64 injector):
   ```sh
   softwareupdate --install-rosetta --agree-to-license
   ```
   (On Intel, skip this — there's no Rosetta and nothing to force.)

2. **Launcher: nothing to edit — it auto-detects (Apple Silicon vs Intel).** The committed
   `mods/start_game_bepinex.sh` ends with a hardware check and does the right thing on each machine,
   so the same file is correct on both Macs:
   ```sh
   if [ "$(/usr/sbin/sysctl -n hw.optional.arm64 2>/dev/null)" = "1" ]; then
       # Apple Silicon: force the x86_64 slice under Rosetta, re-asserting DYLD_* after the arch hop
       exec /usr/bin/arch -x86_64 /usr/bin/env \
           "DYLD_LIBRARY_PATH=${doorstop_directory}" \
           "DYLD_INSERT_LIBRARIES=${doorstop_directory}/${doorstop_name}" \
           "$executable_path" "$@"
   else
       # Intel / native x86_64 / Linux: launch directly (upstream-proven path)
       exec "$executable_path" "$@"
   fi
   ```
   **Why each piece matters (verified the hard way on an M3, June 2026):**
   - *Detect the hardware, not the process arch.* It uses `sysctl hw.optional.arm64` rather than
     `uname -m`, because if Steam or the shell spawns this script under Rosetta, `uname -m` lies
     (reports `x86_64` on an M-chip); the hardware flag is always truthful. Absolute `/usr/sbin/sysctl`
     in case Steam hands the script a minimal `PATH`.
   - *Force x86_64 on Apple Silicon.* The bundled doorstop is x86_64-only, so the game must run its
     x86_64 slice (→ Rosetta), else the dylib is rejected and the game boots vanilla.
   - *Re-assert `DYLD_*` after `arch`.* `/usr/bin/arch` is an Apple hardened-runtime binary whose
     dyld **strips every `DYLD_*` variable** before it execs the game — so the naive
     `exec /usr/bin/arch -x86_64 "$executable_path"` boots vanilla. Re-adding them via `/usr/bin/env`
     **after** the `arch` hop restores injection: the process stays x86_64 across the `env` exec,
     `env` sets the vars fresh (absolute dylib path, so it doesn't rely on `DYLD_LIBRARY_PATH`
     resolution), and Valheim — entitled with `com.apple.security.cs.allow-dyld-environment-variables`
     on **both** slices — honors them.
   - *Intel is untouched.* On an x86_64 host the check is false → direct `exec` with the `DYLD_*`
     vars exported earlier in the script — exactly the original upstream behavior.
   *Alternative if a launch ever misbehaves:* in Finder, right-click `valheim.app` → **Get Info** →
   tick **"Open using Rosetta"**. Note this only affects Finder/LaunchServices (`open`) launches —
   **not** the script's direct `exec` or Steam-spawned processes — so it's an unreliable fallback.

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
   the path has spaces; `%command%` must be present). **Without this, launching from Steam runs
   vanilla** — Steam never goes through the mod-loader script.

5. **Launch from Steam.** First modded launch is slow (BepInEx builds its cache).

6. **Verify it actually loaded** (ground truth — don't trust "the window opened"):
   ```sh
   LOG="$HOME/Library/Application Support/Steam/steamapps/common/Valheim/BepInEx/LogOutput.log"
   find "$LOG" -mmin -10 -print && tail -n 20 "$LOG"
   ```
   Success = the log was just written and shows `Loading [ValheimPlus ...]` plus the other 3
   plugins, ending in `Chainloader startup complete`. In-game, the inventory shows
   EquipmentAndQuickSlots' equipment + quick slots.

   *Verifying without Steam (isolates the pack from Steam wiring — exercises the exact same
   injection path):*
   ```sh
   cd "$HOME/Library/Application Support/Steam/steamapps/common/Valheim"
   ./start_game_bepinex.sh "$PWD/Valheim.app/Contents/MacOS/Valheim"
   ```
   Then check the same log. To confirm the running game is actually x86_64 with doorstop injected
   (note: match the *inner binary*, not the launcher shell, whose argv also contains the path):
   ```sh
   PID=$(pgrep -f Valheim.app/Contents/MacOS/Valheim | tail -1)
   vmmap "$PID" | grep -E 'Code Type|libdoorstop_x64.dylib'
   ```
   Expect `X86-64 (translated)` **and** `libdoorstop_x64.dylib` mapped. (On Intel you'd expect
   `X86-64` *not* translated, and the same dylib mapped.)

## Troubleshooting
- **Game boots vanilla / no `BepInEx/LogOutput.log`** → mods didn't inject. Two distinct causes:
  - *Process is still arm64* (you may also see `incompatible architecture (have 'x86_64', need
    'arm64')`): confirm Rosetta is installed (step 1) and the auto-detect block (step 2) survived in
    the *deployed* script
    (`grep -n 'hw.optional.arm64' "$HOME/Library/Application Support/Steam/steamapps/common/Valheim/start_game_bepinex.sh"`).
    Re-run `./deploy.sh` after any change.
  - *Process is x86_64 but still vanilla* → the `DYLD_*` injection vars were stripped because the
    launcher was reduced to a **bare** `exec arch -x86_64 "$executable_path"` without the
    `/usr/bin/env` re-assert (`/usr/bin/arch` scrubs `DYLD_*` before exec'ing the game). Restore the
    step-2 block and re-deploy. `BepInEx/LogOutput.log` appearing with `Chainloader startup complete`
    is the ground-truth confirmation.
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

## Why — do NOT skip (verified the hard way on the Intel machine, re-verified on M3)
- **Do NOT re-sign or otherwise modify `valheim.app`.** Despite the hardened runtime, Coffee Stain
  ships it with the entitlements `com.apple.security.cs.allow-dyld-environment-variables` +
  `com.apple.security.cs.disable-library-validation` — exactly what lets the **unsigned** x86_64
  doorstop dylib be injected under hardened runtime. Re-signing strips these and **breaks** modding.
  Verify with: `codesign -d --entitlements :- "$HOME/Library/Application Support/Steam/steamapps/common/Valheim/valheim.app"`
  (both the x86_64 and arm64 slices carry these entitlements — check a specific slice with
  `codesign -d --entitlements :- --arch x86_64 ".../Valheim.app/Contents/MacOS/Valheim"`).
- **Do NOT disable SIP.** SIP only strips `DYLD_*` for protected *system* binaries; Valheim is a
  user-space third-party app, unaffected. (Hardened-runtime processes also strip `DYLD_*` *unless*
  entitled — and Valheim *is* entitled, which is why injection works.)
- **`arch -x86_64` alone is NOT enough — it strips `DYLD_*`.** The `arch` wrapper is an Apple
  hardened binary whose dyld scrubs `DYLD_*` before exec'ing the game, so step 2 routes the launch
  through `/usr/bin/env` to re-assert them *after* the `arch` hop. This is the single most
  expensive-to-discover fact in this doc — and the reason the Apple-Silicon launch differs from a
  one-line `arch` prefix.
- **The only real Apple-Silicon variable is architecture** (Rosetta), because the bundled doorstop
  is x86_64-only. If a future pack ever ships `libdoorstop_arm64.dylib`, native arm64 could work
  without Rosetta (and without the `arch`/`env` dance entirely) — but this pack does not.
- **A benign `DllNotFoundException: AppleCoreNativeMac` appears in the log under Rosetta.** It's an
  arm64-only Unity/Apple native plugin that can't load into the x86_64 process; it does not affect
  gameplay or mod loading. Expected, ignore it.
- **macOS/Steam/Rosetta interaction is the genuinely uncertain part — verify on the actual machine**
  with the LogOutput.log check rather than assuming. If a launch misbehaves, fall back to the Finder
  "Open using Rosetta" flag, and confirm via the log either way.

## Note on this repo
The repo name references the original Intel Mac, but `mods/` is shared and portable. Use the same
`./deploy.sh` on both machines. The machine-specific bits (the Rosetta force + the absolute
launch-option path) are handled automatically or live in Steam settings, not in `mods/` data, so
nothing conflicts between the two Macs. The launcher **auto-detects the hardware**
(`sysctl hw.optional.arm64`): on Apple Silicon it forces x86_64 under Rosetta and re-asserts `DYLD_*`
after the `arch` hop; on Intel it launches directly. The same committed file works on both —
verified on an Apple-Silicon M3 (June 2026) and unchanged from upstream behavior on Intel.
