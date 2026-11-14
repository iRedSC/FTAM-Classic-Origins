val enderConduit = <EnderIO:itemPowerConduit:2>;
val conduitBinder = <EnderIO:itemMaterial:1>;
val enderium = <ThermalFoundation:material:76>;

recipes.remove(enderConduit);
recipes.addShaped(enderConduit,[[conduitBinder, conduitBinder, conduitBinder], [enderium, enderium, enderium], [conduitBinder, conduitBinder, conduitBinder]]);


recipes.addShaped(<appliedenergistics2:item.ItemMultiMaterial:38>, [[<ore:dustElectrum>, <appliedenergistics2:item.ItemMultiMaterial:24>, <ore:dustElectrum>], [<appliedenergistics2:item.ItemMultiMaterial:37>, <appliedenergistics2:tile.BlockQuartzGlass>, <appliedenergistics2:item.ItemMultiMaterial:37>], [<ore:dustLumium>, <appliedenergistics2:item.ItemMultiMaterial:37>, <ore:dustLumium>]]);
recipes.addShaped(<appliedenergistics2:tile.BlockCondenser>, [[<ore:ingotElectricalSteel>, <appliedenergistics2:tile.BlockQuartzGlass>, <ore:ingotElectricalSteel>], [<ore:crystalPureFluix>, <EnderIO:itemMaterial:6>, <ore:crystalPureFluix>], [<ore:ingotElectricalSteel>, <appliedenergistics2:tile.BlockQuartzGlass>, <ore:ingotElectricalSteel>]]);
mods.thermalexpansion.Smelter.addRecipe(800, <EnderIO:itemPowderIngot:7> * 2, <appliedenergistics2:item.ItemMultiMaterial:2> * 2, <appliedenergistics2:tile.BlockQuartzGlass> * 2, <appliedenergistics2:tile.BlockQuartzGlass>, 20);
// The one chunk loader: one per faction, loading only on its land (Factions enforces it).
recipes.addShaped(<DimensionalAnchors:chunkloader>, [
    [<minecraft:diamond_block>, <minecraft:ender_eye>, <minecraft:diamond_block>],
    [<minecraft:ender_eye>, <minecraft:nether_star>, <minecraft:ender_eye>],
    [<minecraft:diamond_block>, <minecraft:ender_eye>, <minecraft:diamond_block>]]);
