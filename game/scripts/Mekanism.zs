// Four Biomass enrich into one Mud Ball, smelted into the Mud Bricks tier 1 hardened walls need.
mods.mekanism.Enrichment.addRecipe(<Mekanism:BioFuel> * 4, <BiomesOPlenty:mudball>);

// Bituminous Coal smelts into a Graphite Bar, like Charcoal does. Mekanism keeps its own smelter list,
// so the Energized Smelter and Smelting Factories get the recipe separately from the furnace.
furnace.addRecipe(<BigReactors:BRIngot:2>, <militarybasedecor:bituminous_coal>);
mods.mekanism.Smelter.addRecipe(<militarybasedecor:bituminous_coal>, <BigReactors:BRIngot:2>);
