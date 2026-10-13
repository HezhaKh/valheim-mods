# Mod compatibility — Valheim 1.0.17

Reviewed **2026-10-13** against the running Windows Steam install: build
**25730771**, Valheim **1.0.17** (network version 40), Unity
**6000.0.75.2503836**.

This revision records the installed profile, rather than claiming the latest upstream
releases. All five plugin DLLs and the Windows framework/native loader files match the
repository by SHA-256. All five local `.cfg` files have the same section/key/value settings
as the repository; runtime rewriting only changed formatting.

The **2026-10-13** session loaded all five plugins and joined a multiplayer world.
ValheimPlus exchanged matching versions, synchronized the server's settings, and the
player spawned. No mod exception or failed patch was found in the reviewed session log.
The **2026-10-06** disposable graphical test remains the earlier startup validation.
Individual equipment contents, old-save migration, crafting and container behavior
still require direct gameplay checks. macOS execution has not been tested here.

## Versions and sources

| Component | Version in this repo | Decision and source |
|---|---:|---|
| BepInExPack_Valheim | **5.4.2351** / BepInEx **5.4.23.5** | Installed pack, confirmed by the running log. It adds clearer GUID/count logging and the restored early Valheim-version line. [Thunderstore](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/) |
| UnityDoorstop | Windows/macOS **4.4.0**; Linux **4.5.0** | Windows and macOS loaders are unchanged upstream. The Linux library is the stock 4.5.0 build from pack 5.4.2351. The repo's custom Intel/Rosetta macOS launcher is preserved. |
| Jotunn | **2.30.2** | New dependency of EquipmentAndQuickSlots 3.x; includes Valheim 1.0 and build-menu fixes. [Thunderstore](https://thunderstore.io/c/valheim/p/ValheimModding/Jotunn/) |
| ValheimPlus (Grantapher) | package **10.2.0** / plugin **0.10.2.0** | Replaces 0.9.17.1. This is the maintained Deep North/Valheim 1.0 fork and includes an Apple Silicon repatching fix. [Thunderstore](https://thunderstore.io/c/valheim/p/Grantapher/ValheimPlus_Grantapher_Temporary/) |
| EquipmentAndQuickSlots (RandyKnapp/MidnightsFX) | **3.1.3** | Replaces 2.1.14. The 3.x rewrite supports Deep North, migrates old slot storage, and fixes item duplication. [Thunderstore](https://thunderstore.io/c/valheim/p/RandyKnapp/EquipmentAndQuickSlots/) |
| CraftFromContainers (aedenthorn/UnderHeiz port) | package **4.0.70** / plugin **4.0.7** | Replaces 3.8.3 with the active Valheim 1.0 port while retaining GUID `aedenthorn.CraftFromContainers` and its config path. [Thunderstore](https://thunderstore.io/c/valheim/p/UnderHeiz/CraftFromContainers/) |
| SmartContainers (Flueno/PONEIS port) | **1.8.3** | Replaces 1.7.0 with the active Unity 6/Valheim 1.0 port. It retains GUID `flueno.SmartContainers` and the existing config. [Thunderstore](https://thunderstore.io/c/valheim/p/PONEIS/SmartContainers/) |

The original Flueno and aedenthorn Thunderstore packages are deprecated. The selected
ports retain their plugin identities and config locations instead of introducing
similarly named, unrelated replacements.

## Preserved settings and migrations

- EquipmentAndQuickSlots preserved the `I`, `O`, and `P` quick-slot keys. Version 3.x
  adds a trinket slot, supports up to six quick slots, and automatically migrates 2.x
  character slot data on first login. **There is no downgrade path after that character
  is saved.** The mod creates an automatic slot backup and provides
  `eaqs_restorebackup`, but a normal DLL rollback will not restore the old format.
- ValheimPlus imported all 448 legacy settings into
  `BepInEx/config/org.bepinex.plugins.valheim_plus.cfg`. The obsolete
  `valheim_plus.cfg` is no longer shipped. The Server section remains enabled with
  `enforceMod = true` and `serverSyncsConfig = true`; `difficultyScaleRange = 200` was
  preserved but does not apply while the Game section is disabled.
- CraftFromContainers kept `aedenthorn.CraftFromContainers.cfg`. The new fuel, ore,
  and cooking pull switches are enabled, preserving the old profile's behavior.
- SmartContainers kept `flueno.SmartContainers.cfg` and its routing/group settings.
  The new protect/favorite shortcut is enabled on `LeftAlt` + right-click.

## Validation performed

Two disposable-save startup tests were run on **2026-10-06** against the installed Windows game:

1. A no-graphics loader test verified config migration and dependency resolution.
2. A graphical test loaded the `start.unity` scene, initialized the NVIDIA GPU,
   Steam and PlayFab, and reached the main-menu save list.

Both tests reported:

```text
Valheim Version: 1.0.17
Loading [Craft From Containers 4.0.7]
Loading [Jotunn 2.30.2]
Loading [Smart Containers Mod 1.8.3]
Loading [Valheim Plus 0.10.2.0]
Loading [Equipment and Quick Slots 3.1.3]
Chainloader startup complete (5 loaded, 0 skipped, 0 failed)
```

No plugin error, exception, failed patch, skipped plugin, or incompatibility was logged.
The graphical test emitted two vanilla warnings while populating the character list
(`Trying to add item to occupied slot 0, 4`), without an exception or mod stack trace.
No character/world was selected during those disposable tests. The later running-session
review below establishes multiplayer connection and spawning, but does not audit item
migration or individual crafting/container features.

### Running-session review — 2026-10-13

The existing live session was inspected without restarting or modifying the game.
The log contains the same five plugin versions shown above, followed by:

```text
Received Valheim Plus version 0.10.2.0 and minimum version 0.10.2.0 from the server.
Received 435 configs and 0 custom values from the server for mod Valheim Plus
Network version check, their:40, mine:40
Received config from the server, re-applying patches.
36 settings changed since patches were last applied:
Spawned after 8.019993
```

The original lines include logger prefixes and timestamps. Server addresses, account
identifiers, character names and raw logs are deliberately excluded from this repository.
There was an earlier server-list address/port mismatch error, followed by the successful
connection and spawn. It was not a plugin load or version failure. The log also contains
vanilla character-ID and missing-attachment warnings; none proves an item migration
failure or successful preservation of every equipment item.

ValheimPlus applied these **36** runtime changes supplied by the connected server:

| Section | Values after server sync that differed from the local config |
|---|---|
| Beehive | `enabled = true`, `autoDeposit = true`, `autoDepositRange = 50` |
| EitrRefinery | `enabled = true`, `maximumSap = 10`, `autoRange = 5` |
| Fermenter | `enabled = true`, `autoDeposit = true`, `autoFuel = true`, `autoRange = 50` |
| FireSource | `enabled = true`, `autoFuel = true`, `autoRange = 50` |
| Furnace | `enabled = true`, `autoDeposit = true`, `autoFuel = true`, `autoRange = 50`, `allowAllOres = true` |
| Game | `gameDifficultyHealthScale = 40` |
| Kiln | `enabled = true`, `autoDeposit = true`, `autoFuel = true` |
| Player | `enabled = true`, `autoRepair = true`, `autoPickUpWhenEncumbered = true` |
| Smelter | `enabled = true`, `autoDeposit = true`, `autoFuel = true`, `autoRange = 50` |
| SpinningWheel | `enabled = true`, `autoDeposit = true`, `autoFuel = true`, `ignorePrivateAreaCheck = false` |
| Windmill | `enabled = true`, `autoDeposit = true`, `autoFuel = true` |

This table records the changes logged in this session, not the entire server config.
The versioned local config remains the client's baseline; joining the server with
`serverSyncsConfig = true` supplies its overrides automatically. Copying these runtime
values into the local config would also change offline or other-server behavior.

Valheim 1.0.17 itself is a small hotfix for chunk splitting, invalid item styles,
placeholder text, and credits; see the [official patch notes](https://www.valheimgame.com/news/patch-1-0-17/).

## First real launch and server checklist

1. Back up local and Steam/cloud characters and worlds.
2. Deploy this exact revision and start Valheim. Confirm all five plugin versions and
   `Chainloader startup complete (5 loaded, 0 skipped, 0 failed)` in
   `BepInEx/LogOutput.log` before selecting a character.
3. Open an existing EquipmentAndQuickSlots character once, verify every equipment and
   quick slot, then quit normally so the migrated save and its backup are written.
4. Test crafting/building, fuel/ore/cooking pulls, and SmartContainers routing on a
   disposable or backed-up world.
5. Keep every modded client on this same profile and matching game version. Coordinate
   server mod changes separately; do not replace its authoritative config with the client
   baseline. Jotunn checks its exact version when present on both sides, and ValheimPlus
   enforces its version/config. The reviewed server session used ValheimPlus **0.10.2.0**.

## Integrity

From the repo root, run:

```sh
shasum -a 256 -c SHA256SUMS
```

`SHA256SUMS` covers the runtime framework, plugins and native loaders. Editable configs
remain versioned in Git but are excluded so intentional settings changes are practical.
`.gitattributes` preserves payload bytes across Git checkouts and keeps shell launchers
at LF line endings on Windows, avoiding checksum failures caused by newline conversion.
