// Guns from scrap. Scrap comes from bosses, supply drops, spawn chests and (rarely) pulverizing obsidian; a quarter of
// the guns build from it, up to Epic, fewer at each tier. Scrap is the key (1 to 4 per gun); what goes with it climbs:
//   Common (5):   1 scrap, iron
//   Uncommon (4): 2 scrap, steel, a basic control circuit
//   Rare (2):     3 scrap, steel blocks, an advanced control circuit
//   Epic (1):     4 scrap, diamond blocks, elite control circuits

val scrap = <contenttweaker:scrap_metal>;
val iron = <ore:ingotIron>;
val steel = <ore:ingotSteel>;
val steelBlock = <ore:blockSteel>;
val diamondBlock = <minecraft:diamond_block>;
val basic = <Mekanism:ControlCircuit>;
val advanced = <Mekanism:ControlCircuit:1>;
val elite = <Mekanism:ControlCircuit:2>;

// Obsidian's pulverizing now turns up scrap, very rarely: 1 in 100.
mods.thermalexpansion.Pulverizer.removeRecipe(<minecraft:obsidian>);
mods.thermalexpansion.Pulverizer.addRecipe(4000, <minecraft:obsidian>, <ThermalFoundation:material:4> * 4, scrap, 1);

// Common: 1 scrap; pistols 4 or 5 iron, rifles 7.
recipes.addShaped(<flansmod:g17>, [[iron, iron, iron], [null, scrap, iron], [null, null, iron]]);
recipes.addShaped(<flansmod:j941>, [[iron, iron, iron], [null, iron, scrap], [null, null, iron]]);
recipes.addShaped(<flansmod:lebman>, [[iron, iron, iron], [null, scrap, iron], [null, iron, null]]);
recipes.addShaped(<flansmod:xm8>, [[iron, iron, iron], [iron, scrap, iron], [iron, iron, null]]);
recipes.addShaped(<flansmod:vss>, [[iron, iron, iron], [iron, scrap, iron], [iron, null, iron]]);

// Uncommon: 2 scrap, steel and a basic circuit.
recipes.addShaped(<flansmod:m4a1>, [[steel, steel, steel], [scrap, basic, scrap], [null, steel, null]]);
recipes.addShaped(<flansmod:mp5k>, [[steel, steel, null], [scrap, basic, scrap], [null, steel, null]]);
recipes.addShaped(<flansmod:m500p>, [[steel, steel, steel], [scrap, basic, scrap], [steel, null, null]]);
recipes.addShaped(<flansmod:thompson>, [[steel, steel, steel], [scrap, basic, scrap], [null, null, steel]]);

// Rare: 3 scrap, 3 steel blocks and an advanced circuit.
recipes.addShaped(<flansmod:hk416>, [[scrap, scrap, scrap], [steelBlock, advanced, steelBlock], [null, steelBlock, null]]);
recipes.addShaped(<flansmod:dragunov>, [[steelBlock, scrap, steelBlock], [scrap, advanced, scrap], [null, steelBlock, null]]);

// Epic: 4 scrap, 3 diamond blocks and 2 elite circuits.
recipes.addShaped(<flansmod:kar98k>, [[scrap, diamondBlock, scrap], [elite, diamondBlock, elite], [scrap, diamondBlock, scrap]]);
