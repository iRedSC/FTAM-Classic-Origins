import mods.mfr.MiningLaser;
import mods.mfr.Harvester;

//Add BOP Flowers into harvestables
Harvester.addHarvestable(<BiomesOPlenty:flowers:*>,"tree");

//Drills

//Remove ores from drill
MiningLaser.removeOre(<minecraft:emerald_ore>);
MiningLaser.removeOre(<minecraft:diamond_ore>);
MiningLaser.removeOre(<minecraft:gold_ore>);
MiningLaser.removeOre(<minecraft:iron_ore>);
MiningLaser.removeOre(<minecraft:redstone_ore>);
MiningLaser.removeOre(<minecraft:coal_ore>);
MiningLaser.removeOre(<minecraft:lapis_ore>);
MiningLaser.removeOre(<minecraft:glowstone>);
MiningLaser.removeOre(<minecraft:quartz_ore>);
MiningLaser.removeOre(<denseores:block0:*>);
MiningLaser.removeOre(<NetherOres:tile.netherores.ore.0:*>);
MiningLaser.removeOre(<NetherOres:tile.netherores.ore.1:*>);
MiningLaser.removeOre(<ThermalFoundation:Ore:*>);
MiningLaser.removeOre(<Mekanism:OreBlock:*>);
MiningLaser.removeOre(<BiomesOPlenty:gemOre:*>);
MiningLaser.removeOre(<BigReactors:YelloriteOre>);
MiningLaser.removeOre(<appliedenergistics2:tile.OreQuartz>);
MiningLaser.removeOre(<roadstuff:bitumenOre>);
MiningLaser.removeOre(<ore:oreAluminum>);
MiningLaser.removeOre(<ore:oreArdite>);
MiningLaser.removeOre(<ore:oreCobalt>);

//Add ores to drill
MiningLaser.addOre(<minecraft:iron_ingot>);
MiningLaser.addOre(<minecraft:emerald>);
MiningLaser.addOre(<minecraft:gold_ingot>);
MiningLaser.addOre(<minecraft:diamond>);
MiningLaser.addOre(<minecraft:dye:4>);
MiningLaser.addOre(<minecraft:coal>);
MiningLaser.addOre(<minecraft:glowstone_dust>);
MiningLaser.addOre(<minecraft:quartz>);
MiningLaser.addOre(<minecraft:redstone>);
MiningLaser.addOre(<ThermalFoundation:material:64>);
MiningLaser.addOre(<ThermalFoundation:material:65>);
MiningLaser.addOre(<ThermalFoundation:material:66>);
MiningLaser.addOre(<ThermalFoundation:material:67>);
MiningLaser.addOre(<ThermalFoundation:material:68>);
MiningLaser.addOre(<Mekanism:Ingot:1>);
MiningLaser.addOre(<appliedenergistics2:item.ItemMultiMaterial:0>);
MiningLaser.addOre(<appliedenergistics2:item.ItemMultiMaterial:1>);
MiningLaser.addOre(<BigReactors:BRIngot:0>);
MiningLaser.addOre(<appliedenergistics2:tile.BlockSkyStone>);
MiningLaser.addOre(<ThermalFoundation:material:69>);

//Remove old focusses
MiningLaser.removePreferredOre(0, <NetherOres:tile.netherores.ore.1:13>);
MiningLaser.removePreferredOre(0, <minecraft:quartz_ore>);
MiningLaser.removePreferredOre(0, <NetherOres:tile.netherores.ore.1:14>);

MiningLaser.removePreferredOre(1, <ThermalFoundation:Ore>);
MiningLaser.removePreferredOre(1, <NetherOres:tile.netherores.ore.0:6>);
MiningLaser.removePreferredOre(1, <BiomesOPlenty:gemOre:14>);
MiningLaser.removePreferredOre(1, <NetherOres:tile.netherores.ore.1:11>);
MiningLaser.removePreferredOre(1, <minecraft:iron_ingot>);

MiningLaser.removePreferredOre(3, <minecraft:diamond_ore>);
MiningLaser.removePreferredOre(3, <NetherOres:tile.netherores.ore.0:1>);
MiningLaser.removePreferredOre(3, <Mekanism:OreBlock>);
MiningLaser.removePreferredOre(3, <NetherOres:tile.netherores.ore.1:4>);
MiningLaser.removePreferredOre(3, <ThermalFoundation:Ore:5>);
MiningLaser.removePreferredOre(3, <NetherOres:tile.netherores.ore.1>);

MiningLaser.removePreferredOre(4, <minecraft:glowstone>);
MiningLaser.removePreferredOre(4, <minecraft:gold_ore>);
MiningLaser.removePreferredOre(4, <NetherOres:tile.netherores.ore.0:2>);
MiningLaser.removePreferredOre(4, <NetherOres:tile.netherores.ore.1:5>);
MiningLaser.removePreferredOre(4, <BigReactors:YelloriteOre>);

MiningLaser.removePreferredOre(5, <minecraft:emerald_ore>);
MiningLaser.removePreferredOre(5, <NetherOres:tile.netherores.ore.0:8>);
MiningLaser.removePreferredOre(5, <NetherOres:tile.netherores.ore.0:11>);

MiningLaser.removePreferredOre(6, <roadstuff:bitumenOre>);

MiningLaser.removePreferredOre(7, <NetherOres:tile.netherores.ore.1:2>);
MiningLaser.removePreferredOre(7, <ThermalFoundation:Ore:2>);
MiningLaser.removePreferredOre(7, <NetherOres:tile.netherores.ore.0:9>);

MiningLaser.removePreferredOre(8, <ThermalFoundation:Ore:1>);
MiningLaser.removePreferredOre(8, <NetherOres:tile.netherores.ore.0:7>);
MiningLaser.removePreferredOre(8, <ThermalFoundation:Ore:4>);
MiningLaser.removePreferredOre(8, <NetherOres:tile.netherores.ore.1:1>);

MiningLaser.removePreferredOre(9, <appliedenergistics2:tile.OreQuartz>);
MiningLaser.removePreferredOre(9, <BiomesOPlenty:gemOre:10>);

MiningLaser.removePreferredOre(10, <ThermalFoundation:Ore:3>);
MiningLaser.removePreferredOre(10, <NetherOres:tile.netherores.ore.0:10>);
MiningLaser.removePreferredOre(10, <BiomesOPlenty:gemOre:8>);

MiningLaser.removePreferredOre(11, <minecraft:lapis_ore>);
MiningLaser.removePreferredOre(11, <NetherOres:tile.netherores.ore.0:4>);
MiningLaser.removePreferredOre(11, <ThermalFoundation:Ore:6>);
MiningLaser.removePreferredOre(11, <NetherOres:tile.netherores.ore.1:7>);
MiningLaser.removePreferredOre(11, <BiomesOPlenty:gemOre:12>);
MiningLaser.removePreferredOre(11, <NetherOres:tile.netherores.ore.0:15>);

MiningLaser.removePreferredOre(12, <minecraft:iron_ore>);
MiningLaser.removePreferredOre(12, <NetherOres:tile.netherores.ore.0:3>);
MiningLaser.removePreferredOre(12, <BiomesOPlenty:gemOre:6>);

MiningLaser.removePreferredOre(13, <BiomesOPlenty:gemOre:4>);
MiningLaser.removePreferredOre(13, <NetherOres:tile.netherores.ore.0:14>);

MiningLaser.removePreferredOre(14, <minecraft:redstone_ore>);
MiningLaser.removePreferredOre(14, <NetherOres:tile.netherores.ore.0:5>);
MiningLaser.removePreferredOre(14, <BiomesOPlenty:gemOre:2>);
MiningLaser.removePreferredOre(14, <NetherOres:tile.netherores.ore.0:13>);

MiningLaser.removePreferredOre(15, <minecraft:coal_ore>);
MiningLaser.removePreferredOre(15, <NetherOres:tile.netherores.ore.0>);

//Add new items into focusses
MiningLaser.addPreferredOre(0, <minecraft:quartz>);

MiningLaser.addPreferredOre(1, <ThermalFoundation:material:64>);

MiningLaser.addPreferredOre(3, <minecraft:diamond>);
MiningLaser.addPreferredOre(3, <Mekanism:Ingot:1>);
MiningLaser.addPreferredOre(3, <ThermalFoundation:material:66>);

MiningLaser.addPreferredOre(4, <minecraft:glowstone_dust>);
MiningLaser.addPreferredOre(4, <minecraft:gold_ingot>);
MiningLaser.addPreferredOre(4, <BigReactors:BRIngot:0>);
MiningLaser.addPreferredOre(4, <ThermalFoundation:material:68>);

MiningLaser.addPreferredOre(5, <minecraft:emerald>);

MiningLaser.addPreferredOre(8, <ThermalFoundation:material:65>);

MiningLaser.addPreferredOre(9, <appliedenergistics2:item.ItemMultiMaterial:0>);
MiningLaser.addPreferredOre(9, <appliedenergistics2:item.ItemMultiMaterial:1>);

MiningLaser.addPreferredOre(10, <ThermalFoundation:material:67>);

MiningLaser.addPreferredOre(11, <minecraft:dye:4>);

MiningLaser.addPreferredOre(12, <minecraft:iron_ingot>);

MiningLaser.addPreferredOre(14, <minecraft:redstone>);

MiningLaser.addPreferredOre(15, <minecraft:coal>);

<MineFactoryReloaded:laserfocus:0>.addTooltip("§aMaterials: Quartz");
<MineFactoryReloaded:laserfocus:1>.addTooltip("§aMaterials: Copper");
<MineFactoryReloaded:laserfocus:3>.addTooltip("§aMaterials: Diamond/Osmium/Silver");
<MineFactoryReloaded:laserfocus:4>.addTooltip("§aMaterials: Glowstone/Gold/Yellorium/Ferrous");
<MineFactoryReloaded:laserfocus:5>.addTooltip("§aMaterials: Emerald");
<MineFactoryReloaded:laserfocus:8>.addTooltip("§aMaterials: Tin");
<MineFactoryReloaded:laserfocus:9>.addTooltip("§aMaterials: Certus Quartz/Charged Certus Quartz");
<MineFactoryReloaded:laserfocus:10>.addTooltip("§aMaterials: Lead, Electrotine");
<MineFactoryReloaded:laserfocus:11>.addTooltip("§aMaterials: Lapis");
<MineFactoryReloaded:laserfocus:12>.addTooltip("§aMaterials: Iron");
<MineFactoryReloaded:laserfocus:14>.addTooltip("§aMaterials: Redstone");
<MineFactoryReloaded:laserfocus:15>.addTooltip("§aMaterials: Coal");