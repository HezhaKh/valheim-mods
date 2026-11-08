# Mod compatibility — Valheim 1.0.21

Updated **2026-11-06** against the installed Windows Steam game: build **26249040**,
Valheim **1.0.21** (network version **41**), Unity **6000.0.75.2503836**.

Steam had already installed this stable game release before the mod update. Iron Gate
published it on **2026-10-28** and explicitly retained crossplay during the staged
platform rollout; see the [official 1.0.21 patch notes](https://www.valheimgame.com/news/patch-1-0-21/).
Both 1.0.20 and 1.0.21 use network version **41**.

Published stable releases were checked on **2026-11-06**. The only newly published
component is EquipmentAndQuickSlots **3.2.0**, replacing **3.1.3**. The game, framework,
native loaders and other four plugins remain current and unchanged. Its published
Thunderstore DLL was installed; all **37** pre-update local config values, including
the `I`, `O`, `P` hotkeys, were retained and **12** defaults were added (**49** total).
The other four config files' settings are unchanged: ValheimPlus **497** entries,
BepInEx **24**, CraftFromContainers **28** and SmartContainers **47**. All five files
therefore contain **645** section/key/value entries in total.

A graphical startup test using disposable saves loaded all five plugins with
**5 loaded, 0 skipped, 0 failed** and no errors or exceptions. No character, world
or server was selected. The exact **1.0.21 + BepInExPack 5.4.2360 + ValheimPlus 10.4.0.0**
combination is locally startup-tested, not listed in the author's published compatibility
matrix. Multiplayer, equipment contents, old-save migration, crafting/container behavior
and macOS execution have not been verified for this update. Startup testing also does
not verify EquipmentAndQuickSlots' full-inventory rescue or death/gravestone behavior.
The October 29 and October 16 startup tests and October 13 multiplayer session below
describe older profiles.

## Versions and sources

| Component | Version in this repo | Decision and source |
|---|---:|---|
| BepInExPack_Valheim | **5.4.2360** / BepInEx **5.4.23.6** | Latest installed pack, confirmed in the startup log. Includes a Windows buffer fix and native Apple Silicon support with updated loaders. [Thunderstore](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/) |
| UnityDoorstop | Windows/macOS/Linux **4.6.0** | Updated native loaders from pack 5.4.2360; the macOS dylib is universal arm64 + x86_64. The repository preserves its custom Intel/Rosetta launcher behavior instead of switching Apple Silicon to native execution. macOS runtime remains untested. |
| Jotunn | **2.30.2** | New dependency of EquipmentAndQuickSlots 3.x; includes Valheim 1.0 and build-menu fixes. [Thunderstore](https://thunderstore.io/c/valheim/p/ValheimModding/Jotunn/) |
| ValheimPlus (Grantapher) | package **10.4.0** / plugin **10.4.0.0** | Replaces 0.10.3.0; upstream dropped the leading 0 in the plugin version. Manifest requires BepInExPack 5.4.2351, satisfied by installed 5.4.2360. [Release notes](https://github.com/Grantapher/ValheimPlus/releases/tag/10.4.0.0), [Thunderstore](https://thunderstore.io/c/valheim/p/Grantapher/ValheimPlus_Grantapher_Temporary/) |
| EquipmentAndQuickSlots (RandyKnapp/MidnightsFX) | **3.2.0** | Published stable update from 3.1.3. Adds container-window controls, controller combinations and optional favorite marks, with rescue and build-menu key fixes. Requires Jotunn 2.30.2 and BepInExPack 5.4.2360, both already installed. [Thunderstore](https://thunderstore.io/c/valheim/p/RandyKnapp/EquipmentAndQuickSlots/v/3.2.0/), [changelog](https://thunderstore.io/c/valheim/p/RandyKnapp/EquipmentAndQuickSlots/changelog/) |
| CraftFromContainers (aedenthorn/UnderHeiz port) | package **4.0.70** / plugin **4.0.7** | Replaces 3.8.3 with the active Valheim 1.0 port while retaining GUID `aedenthorn.CraftFromContainers` and its config path. [Thunderstore](https://thunderstore.io/c/valheim/p/UnderHeiz/CraftFromContainers/) |
| SmartContainers (Flueno/PONEIS port) | **1.8.3** | Replaces 1.7.0 with the active Unity 6/Valheim 1.0 port. It retains GUID `flueno.SmartContainers` and the existing config. [Thunderstore](https://thunderstore.io/c/valheim/p/PONEIS/SmartContainers/) |

The original Flueno and aedenthorn Thunderstore packages are deprecated. The selected
ports retain their plugin identities and config locations instead of introducing
similarly named, unrelated replacements.

EquipmentAndQuickSlots uses the published **3.2.0** package, not an unreleased source
build. Jotunn **2.30.2** remains the latest stable
[GitHub release](https://github.com/Valheim-Modding/Jotunn/releases/tag/v2.30.2).

## EquipmentAndQuickSlots 3.2.0 changes — 2026-11-06

The [published package](https://thunderstore.io/c/valheim/p/RandyKnapp/EquipmentAndQuickSlots/v/3.2.0/)
was released on **2026-10-30 at 03:40 UTC** (**2026-10-29 at 23:40 Toronto time**).
The [changelog](https://thunderstore.io/c/valheim/p/RandyKnapp/EquipmentAndQuickSlots/changelog/)
includes overlapping-item rescue fixes, dropping rescued items on the ground when the
inventory is full, build-menu key-search handling, clamped/draggable chest windows and
controller button combinations. These gameplay paths were not exercised in the menu test.
The published documentation supports client-only installation; an optional server
installation synchronizes and controls balance settings. ValheimPlus version
enforcement remains a separate server/client requirement.

The actual runtime config grew from **37** to **49** entries. All existing values were
preserved, including quick-slot hotkeys **I**, **O**, **P**. The **12** additions are:

| Section | Added entries and defaults |
|---|---|
| Container Window | `Container Position = {"x":0.0,"y":0.0}`, `Container Draggable = false`, `Container Drag Key = LeftAlt` |
| Controller | `Quick slot controller modifier = LeftBumper`; buttons 1–4 are `DPadUp`, `DPadRight`, `DPadDown`, `DPadLeft`; buttons 5–6 are `None` |
| Gravestone | `Dont drop hotbar equipment on death = false` |
| Quick Slots | `Show favorite marks = true` |

Favorite marks integrate with the optional Item Favorite Framework. That framework is
not installed and is not required for EquipmentAndQuickSlots. The new gravestone option
is disabled, so this update does not enable keeping hotbar equipment on death.

The installed `EquipmentAndQuickSlots.dll` from the published package is **658,432 bytes**,
with SHA-256 `0e213b7bce1f13d3adcdbed6c879f8277336fcceefd191c38298993eecdab22c`.
The framework, loaders and other plugin binaries were not updated in this refresh.

## ValheimPlus 10.4.0.0 changes

The latest [stable release](https://github.com/Grantapher/ValheimPlus/releases/tag/10.4.0.0)
was published on **2026-10-25 at 03:42 UTC** (**2026-10-24 at 23:42 Toronto time**).
Package **10.4.0** contains plugin **10.4.0.0**, not `0.10.4.0`.

It adds optional map-pin sharing, adrenaline controls, Deep North gathering/container
options, armor-mould drop modifiers and an oat-flour auto-fuel threshold. It also fixes
partial auto-deposit duplication, gathering drop-chance behavior, placement rotation
after patch reapplication and some tameable/procreation errors. Shared-pin deletion
affects everyone when that optional feature is enabled.

The **26** generated settings have these defaults:

| Section | Added entries and defaults |
|---|---|
| Adrenaline | `enabled = false`; `gainMultiplier`, `decayMultiplier`, `trinketCostMultiplier`, `surgeDurationMultiplier` all `0` |
| Gathering | `timberwood`, `petrifiedTissue`, `obsidian`, `ice`, `softTissue` all `0` |
| Inventory | `graustenChestColumns = 8`, `graustenChestRows = 5`, `wardrobeColumns = 5`, `wardrobeRows = 10`, `barrelColumns = 6`, `barrelRows = 2`, `drakkarInventoryColumns = 8`, `drakkarInventoryRows = 4` |
| LootDrop | `callerMouldDropChanceMultiplier`, `vanguardMouldDropChanceMultiplier`, `protectorMouldDropChanceMultiplier` all `0` |
| Map | `syncPins = false` |
| Pickable | `seeds`, `moltenCores`, `frostCores` all `0` |
| Windmill | `stopAutoFuelOatThreshold = 0` (ignored) |

Seeds now use `Pickable.seeds` rather than `Pickable.flowersAndIngredients`. The retained
local `Pickable` section is disabled and `flowersAndIngredients = 0`, so no previous
seed boost needs migrating for this profile. Map-pin sharing and the new Adrenaline
section remain disabled. A server's authoritative settings can still override the
client baseline after joining.

The [tagged compatibility matrix](https://github.com/Grantapher/ValheimPlus/blob/10.4.0.0/COMPATIBILITY.md)
lists **Valheim 1.0.20 / network 41 + BepInExPack 5.4.2351 + ValheimPlus 10.4.0.0**.
The manifest's framework dependency is met by **5.4.2360**, but the newer game/framework
combination is supported here by the Windows startup result, not by an upstream
certification or a new server-play test.

The [standalone DLL](https://github.com/Grantapher/ValheimPlus/releases/download/10.4.0.0/ValheimPlus.dll)
is **507,392 bytes**, with SHA-256
`9f6070177a0c58a2edb598b78a7e444dab533d87855c5ecc476e2be244aaae6b`.

### Historical ValheimPlus 0.10.3.0 update — 2026-10-16

The [upstream compatibility matrix](https://github.com/Grantapher/ValheimPlus/blob/0.10.3.0/COMPATIBILITY.md)
explicitly supports Valheim **1.0.20 (network 41)** with BepInExPack **5.4.2351** and
ValheimPlus **0.10.3.0**. The stable release was published on **2026-10-16 at 01:39 UTC**
(**2026-10-15 at 21:39 Toronto time**). Its [release notes](https://github.com/Grantapher/ValheimPlus/releases/tag/0.10.3.0)
describe these changes:

- Production auto-deposit now reads station cheat flags the same way as Valheim 1.0.20.
  Items marked as cheated before this fix remain marked; the update does not repair
  their achievement status retroactively.
- `LootDrop` preserves the game's independent star-level drop-chance behavior instead
  of incorrectly multiplying the affected item amounts.
- `Furnace.allowAllOres` discovers ores from the smelter prefab instead of a hardcoded list.
- `Experience.dodge` adds a dodge-experience modifier, defaulting to zero.

The [standalone DLL](https://github.com/Grantapher/ValheimPlus/releases/download/0.10.3.0/ValheimPlus.dll)
is **455,680 bytes**, with SHA-256
`92e60b10256d036b81ff4b0dc2db206c3b975106d7287aba4eded1090172f3c6`.
Only the plugin and its config schema needed updating; the existing framework and
platform loaders were preserved.

## Preserved settings and migrations

- EquipmentAndQuickSlots **3.2.0** retained all **37** pre-update local values and added
  **12** defaults (**49** total), preserving the `I`, `O`, and `P` quick-slot keys.
  The older **2.x → 3.x** character-data migration caution still applies: version 3.x
  adds a trinket slot, supports up to six quick slots, and automatically migrates 2.x
  character slot data on first login. **There is no downgrade path after that character
  is saved.** The mod creates an automatic slot backup and provides
  `eaqs_restorebackup`, but a normal DLL rollback will not restore the old format.
- The earlier ValheimPlus upgrade imported all **448** legacy settings into
  `BepInEx/config/org.bepinex.plugins.valheim_plus.cfg`. The **2026-10-16** update
  retained all **470** values in the pre-update local config and added only `Experience.dodge = 0`
  (**471** total). The obsolete `valheim_plus.cfg` is no longer shipped. The Server
  section remains enabled with `enforceMod = true` and `serverSyncsConfig = true`;
  `difficultyScaleRange = 200` was preserved but does not apply while the Game section
  is disabled. On **2026-10-29**, all **471** pre-update local values were retained and
  **26** defaults were added (**497** total). Its **497** values are unchanged on November 6.
- CraftFromContainers kept `aedenthorn.CraftFromContainers.cfg`. The new fuel, ore,
  and cooking pull switches are enabled, preserving the old profile's behavior.
- SmartContainers kept `flueno.SmartContainers.cfg` and its routing/group settings.
  The new protect/favorite shortcut is enabled on `LeftAlt` + right-click.
  On **2026-11-08**, `[General] hudMessageEnabled = false` was set to hide the
  routed-item HUD notification. Routing, transfer sounds and chest highlighting stay
  enabled. Restart Valheim after changing this option to apply it.

The October 29 snapshot also captures three pre-existing local `FireSource` settings:
`enabled = true`, `autoFuel = true`, and `autoRange = 50`. They differ from the previous
repository snapshot but were already present in the local backup before this update;
the migration did not enable them. CraftFromContainers `[General] ContainerRange = 0`
and SmartContainers `[General] range = 99` remain unchanged. Those range values were
captured on October 16, when the older repository values were **10** and **14**.

## Validation performed

### Current profile startup — 2026-11-06

A graphical Windows startup test used a disposable save directory. It initialized the
NVIDIA GPU, Steam and PlayFab, and loaded the `start.unity` main-menu scene. The fresh
log identified BepInEx **5.4.23.6** / pack **5.4.2360** and reported:

```text
Valheim Version: 1.0.21
Loading [Craft From Containers 4.0.7]
Loading [Jotunn 2.30.2]
Loading [Smart Containers Mod 1.8.3]
Loading [Valheim Plus 10.4.0.0]
Loading [Equipment and Quick Slots 3.2.0]
Chainloader startup complete (5 loaded, 0 skipped, 0 failed)
```

No error or exception matched in the fresh log. No character, world or server was
selected, and only the test process was stopped. The config check retained all **37**
old EquipmentAndQuickSlots values and added the **12** defaults above; the other four
config files remained unchanged. This verifies startup and config loading, not item
rescue, full-inventory handling, controller input, death/gravestone behavior or server play.

### Historical profile startup — 2026-10-29

A graphical Windows startup test used a disposable save directory. It initialized the
NVIDIA GPU, Steam and PlayFab, and loaded the `start.unity` main-menu scene. The fresh
log identified BepInEx **5.4.23.6** / pack **5.4.2360** and reported:

```text
Valheim Version: 1.0.21
Loading [Craft From Containers 4.0.7]
Loading [Jotunn 2.30.2]
Loading [Smart Containers Mod 1.8.3]
Loading [Valheim Plus 10.4.0.0]
Loading [Equipment and Quick Slots 3.1.3]
Chainloader startup complete (5 loaded, 0 skipped, 0 failed)
```

No error or exception matched in the fresh log. No character, world or server was
selected, and only the test process was stopped. All pre-update local config values
were preserved, with the 26 new ValheimPlus entries at defaults. This verifies startup
and config loading; current multiplayer and individual gameplay features remain untested.

### Historical profile startup — 2026-10-16

A graphical Windows startup test used a disposable save directory. It initialized the
NVIDIA GPU, Steam and PlayFab, and loaded the `start.unity` main-menu scene. The fresh
BepInEx log reported:

```text
Valheim Version: 1.0.20
Loading [Craft From Containers 4.0.7]
Loading [Jotunn 2.30.2]
Loading [Smart Containers Mod 1.8.3]
Loading [Valheim Plus 0.10.3.0]
Loading [Equipment and Quick Slots 3.1.3]
Chainloader startup complete (5 loaded, 0 skipped, 0 failed)
```

No error or exception appeared. No character, world or server was selected, and only
the test process was stopped. This validates startup and config loading, but does not
establish multiplayer compatibility, equipment preservation or individual gameplay
features for the updated profile.

### Historical gameplay observation before the October 16 update

The most recent gameplay log from Valheim **1.0.20** with the older ValheimPlus
**0.10.2.0** contained repeated `ShadowPerson1` Standard-shader/property errors. They
were not reproduced during the later main-menu tests. Their cause has not been diagnosed,
and menu-only tests do not demonstrate that the gameplay issue is fixed. No new
character/world play test was performed on October 29 or November 6.

### Historical startup tests — 2026-10-06

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

### Historical running-session review — 2026-10-13

This session used Valheim **1.0.17 / network 40** and ValheimPlus **0.10.2.0**;
it does not validate the current **1.0.21 / 10.4.0.0** profile. The existing live session
was inspected without restarting or modifying the game. The log contains the same
five plugin versions shown in the historical startup test above, followed by:

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

This table records the changes logged in that historical session, not the entire or
current server config.
The versioned local config remains the client's baseline; joining the server with
`serverSyncsConfig = true` supplies its overrides automatically. Copying these runtime
values into the local config would also change offline or other-server behavior.

### Historical completed-session follow-up — 2026-10-14

The completed **2026-10-13** log was reviewed through the end of the session, without
launching a new game. All **26** Windows framework/plugin/native-loader payload files
still match the repository by SHA-256, and the five config files still have identical
section/key/value settings. No binary or effective config update was needed.

Character cloud-save writes were logged during play and again at logout, with an
automatic character backup created at **19:30:44**. Network shutdown and disconnect
occurred at **20:42:40**, followed by return to the main menu and Steam/mod cleanup at
**20:42:46**. These timestamps use the PC's Toronto local time. No additional mod
exception, failed patch or incompatibility message appeared in the completed log.

On disconnect, ValheimPlus logged `Config source changed, re-applying patches.` and
restored all **36** server-provided changes to the client's baseline. This confirms
that the server settings documented above were temporary runtime overrides, rather
than changes that need to be copied into the versioned local config.

The save/write and shutdown messages do not verify every item in a character's
equipment slots or establish that an old-format character migration succeeded.
Those checks, individual crafting/container features and macOS execution remain
outside the completed log review.

The earlier Valheim 1.0.17 release was a small hotfix for chunk splitting, invalid item styles,
placeholder text, and credits; see the [official patch notes](https://www.valheimgame.com/news/patch-1-0-17/).

## First real launch and server checklist

1. Back up local and Steam/cloud characters and worlds.
2. Deploy this exact revision and start Valheim. Confirm all five plugin versions and
   `Chainloader startup complete (5 loaded, 0 skipped, 0 failed)` in
   `BepInEx/LogOutput.log` before selecting a character.
3. Load a backed-up character, verify every equipment and quick slot, then quit normally
   to save. For an old 2.x character, follow the **2.x → 3.x** migration caution above.
4. Test crafting/building, fuel/ore/cooking pulls, and SmartContainers routing on a
   disposable or backed-up world.
5. Keep modded clients on this profile and coordinate server changes separately, with
   game network version **41** and matching **ValheimPlus 10.4.0.0** on server and clients.
   Its minimum required plugin version is
   also **10.4.0.0**; the enabled `enforceMod` check rejects older **0.10.3.0** clients
   or servers. Keep enforcement enabled. Valheim 1.0.20 and 1.0.21 share network 41;
   an exact 1.0.21 game version is not a new network gate. Coordinate server changes
   separately and preserve its authoritative config rather than replacing it with the
   client baseline.
6. Verify a new connection and server-config receipt with the current profile. The
   previous **1.0.17 / 0.10.2.0** connection is historical, and no updated server was
   joined during this update. Jotunn checks exact major/minor/patch equality when
   installed on both sides; its own `VersionCheckOnly` policy does not require it on
   a server where it is absent. See the [Jotunn policy declaration](https://github.com/Valheim-Modding/Jotunn/blob/v2.30.2/JotunnLib/Main.cs),
   [policy semantics](https://github.com/Valheim-Modding/Jotunn/blob/v2.30.2/JotunnLib/Documentation/tutorials/networkcompatibility.md),
   and [ValheimPlus version/config enforcement](https://github.com/Grantapher/ValheimPlus/blob/10.4.0.0/README.md#server-config--version-control-about-version-enforcement).

## Integrity

From the repo root, run:

```sh
shasum -a 256 -c SHA256SUMS
```

`SHA256SUMS` covers the runtime framework, plugins and native loaders. Editable configs
remain versioned in Git but are excluded so intentional settings changes are practical.
`.gitattributes` preserves payload bytes across Git checkouts and keeps shell launchers
at LF line endings on Windows, avoiding checksum failures caused by newline conversion.

The **2026-11-06** verification passed all **30** checksum entries, matched all **26**
Windows runtime payload files to the local installation, and matched **645** effective
settings across five config files. Only the EquipmentAndQuickSlots binary changed
in the checksum manifest during this refresh.
