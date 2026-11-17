// Guns from scrap. Scrap comes from bosses, supply drops, spawn chests and (rarely) pulverizing obsidian; a quarter of
// the guns build from it, up to Epic, fewer at each tier and each tier far dearer than the last:
//   Common (5):   6 to 8 scrap and iron                    (crafting table)
//   Uncommon (4): 3 bundles (27 scrap), steel                (crafting table)
//   Rare (2):     6 bundles (54 scrap), steel blocks, a circuit (crafting table)
//   Epic (1):     32 bundles (288 scrap) and 2 diamond blocks (Induction Smelter)

val scrap = <contenttweaker:scrap_metal>;
val bundle = <militarybasedecor:barbed_bundled_wire>; // "Bundle of Scraps" (DisplayName.zs)
val iron = <ore:ingotIron>;
val steel = <ore:ingotSteel>;
val steelBlock = <ore:blockSteel>;
val circuit = <Mekanism:ControlCircuit>;

// 9 scrap to a bundle, and back.
recipes.remove(bundle);
recipes.addShapeless(bundle, [scrap, scrap, scrap, scrap, scrap, scrap, scrap, scrap, scrap]);
recipes.addShapeless(scrap * 9, [bundle]);

// Obsidian's pulverizing now turns up scrap, very rarely: 1 in 100.
mods.thermalexpansion.Pulverizer.removeRecipe(<minecraft:obsidian>);
mods.thermalexpansion.Pulverizer.addRecipe(4000, <minecraft:obsidian>, <ThermalFoundation:material:4> * 4, scrap, 1);

// Common: pistols 6 scrap and an iron ingot, rifles 8 scrap and 2.
recipes.addShaped(<flansmod:g17>, [[scrap, scrap, scrap], [null, iron, scrap], [null, null, scrap]]);
recipes.addShaped(<flansmod:j941>, [[scrap, scrap, scrap], [null, scrap, iron], [null, null, scrap]]);
recipes.addShaped(<flansmod:lebman>, [[scrap, scrap, scrap], [null, iron, scrap], [null, scrap, null]]);
recipes.addShaped(<flansmod:xm8>, [[scrap, scrap, scrap], [iron, scrap, iron], [scrap, scrap, scrap]]);
recipes.addShaped(<flansmod:vss>, [[scrap, scrap, scrap], [scrap, iron, scrap], [scrap, iron, scrap]]);

// Uncommon: 3 bundles and steel.
recipes.addShaped(<flansmod:m4a1>, [[bundle, bundle, bundle], [steel, steel, steel], [null, steel, null]]);
recipes.addShaped(<flansmod:mp5k>, [[bundle, bundle, bundle], [null, steel, steel], [null, steel, null]]);
recipes.addShaped(<flansmod:m500p>, [[bundle, bundle, bundle], [steel, steel, steel], [steel, null, null]]);
recipes.addShaped(<flansmod:thompson>, [[bundle, bundle, bundle], [steel, null, steel], [null, steel, null]]);

// Rare: 6 bundles, steel blocks and a control circuit.
recipes.addShaped(<flansmod:hk416>, [[bundle, bundle, bundle], [steelBlock, circuit, steelBlock], [bundle, bundle, bundle]]);
recipes.addShaped(<flansmod:dragunov>, [[bundle, steelBlock, bundle], [bundle, circuit, bundle], [bundle, steelBlock, bundle]]);

// Epic: more scrap than a crafting grid holds, so the Induction Smelter builds it.
mods.thermalexpansion.Smelter.addRecipe(40000, bundle * 32, <minecraft:diamond_block> * 2, <flansmod:kar98k>);
