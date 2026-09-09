# Mod compatibility — Valheim 1.0.7

Checked **2026-09-09** on the Intel MacBookPro14,3: Steam build **25185596**,
Unity **6000.0.75f1**. The previous game was 0.221.12.

**This profile is not ready for gameplay on 1.0.7.** BepInEx has been updated,
but all four gameplay mods reference APIs changed or removed by the game update.
The launcher remains available for manual testing. The original DLLs and configurations
are preserved, including the `I` / `O` / `P` quick-slot keys. Use a fresh test character
and world; keep existing extra-slot characters backed up until compatible mods are available.

## Versions and sources

| Component | Version in this repo | Decision and source |
|---|---|---|
| BepInExPack_Valheim | **5.4.2350** / BepInEx **5.4.23.5** | Updated from 5.4.2333 / 5.4.23.3. [Maintainer changelog](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/changelog/) includes macOS preloader and Unity logging fixes. |
| UnityDoorstop | **4.4.0** | Unchanged upstream native libraries; the custom Intel/Rosetta launcher is preserved. |
| ValheimPlus (Grantapher) | **0.9.17.1** | Retained, incompatible. The newer **0.10.0.0-alpha01** also targets obsolete game APIs. [Releases](https://github.com/Grantapher/ValheimPlus/releases). |
| EquipmentAndQuickSlots (RandyKnapp) | **2.1.14** | Retained, incompatible. Latest **3.0.2** is also incompatible; it introduces a Jotunn dependency and a character-storage migration. [Versions](https://thunderstore.io/c/valheim/p/RandyKnapp/EquipmentAndQuickSlots/versions/). |
| CraftFromContainers (aedenthorn) | **3.8.3** | Already the latest author release. Binary matches [Pineapple's CraftBuildSmeltCookFuelPullFromContainers package](https://thunderstore.io/c/valheim/p/Pineapple/CraftBuildSmeltCookFuelPullFromContainers/). [Author's Nexus page](https://www.nexusmods.com/valheim/mods/40). |
| SmartContainers (flueno) | **1.7.0** | Already the latest author release. Binary matches [Roses' SmarterContainers package](https://thunderstore.io/c/valheim/p/Roses/SmarterContainers/). [Author's Nexus page](https://www.nexusmods.com/valheim/mods/332). |

The old aedenthorn/flueno Thunderstore URLs were not the correct package sources.
Some other mirrors contain older binaries; they are not upgrades.

## What was verified

A disposable profile and a separate empty save directory were used with the installed
game executable. No existing character or world was selected.

- BepInEx 5.4.23.5 injected successfully, detected Unity 6000.0.75f1 and Valheim
  1.0.7, and completed chainloader startup.
- ValheimPlus 0.9.17.1 reported `Failed to apply patches`: its
  `SEMan.AddStatusEffect(StatusEffect, bool, int, float)` target no longer exists.
  The game's overload adds a `short` parameter. The latest alpha still uses the
  [old target](https://github.com/Grantapher/ValheimPlus/blob/0.10.0.0-alpha01/ValheimPlus/GameClasses/SEMan.cs).
- A graphical startup test of EquipmentAndQuickSlots 2.1.14 raised a
  `TypeLoadException` for the removed `InventoryGrid.Element` type. Static inspection
  of the released 3.0.2 binary found the same obsolete type reference, plus changed
  inventory/status-effect APIs. Installing Jotunn cannot restore those game APIs.
- CraftFromContainers and SmartContainers logged startup successfully, but binary
  inspection found obsolete calls to `Character.Message` (now has an extra `bool`).
  SmartContainers also calls the old `Inventory.Changed()` and `EffectList.Create`
  signatures. CraftFromContainers also invokes `Inventory.Changed` through
  reflection without its new arguments, affecting crafting/building and resource
  transfers. A loading message therefore does not establish working gameplay.

The headless trial also produced graphics-upload errors; it was used only to inspect
loader startup. The graphical trial logged an Apple native-library error that also
appeared in the pre-update game log. Neither trial certifies gameplay or multiplayer.
See also [Iron Gate's 1.0 FAQ](https://www.valheimgame.com/support/valheim-1-0-faq/).

## Manual testing and future updates

1. Obtain releases explicitly adapted to Valheim 1.0 and check their dependencies.
   Do not replace these mods with similarly named older mirrors.
2. Back up local saves **and** Steam's cached/cloud character files. Do not load an
   EquipmentAndQuickSlots character without working extra-slot support: removing
   the mod can lose those items. EQS 3.x also changes character storage, so a normal
   DLL rollback alone cannot undo a saved migration.
3. Test the updated profile with disposable saves. Check patch errors, equipment
   and quick slots, container crafting/transfers, and multiplayer requirements.
4. When compatible releases are available and those checks pass, update this
   document and `SHA256SUMS`, then run `./deploy.sh`.

## Integrity

From the repo root, run `shasum -a 256 -c SHA256SUMS`. This covers the framework,
plugins, and loaders. Editable configs are versioned in Git
but excluded from checksums so in-game setting changes remain possible.

Framework download: [BepInExPack_Valheim 5.4.2350](https://thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.2350/).
`BepInEx/core/` matches that archive exactly; the obsolete standalone `.pdb` files
were removed. `Mono.Cecil.Pdb.dll` remains because upstream still supplies it.
