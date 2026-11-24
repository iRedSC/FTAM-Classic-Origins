// Items whose crafting grid another recipe took first, so they could never be crafted. Foundation lists any new ones
// in the server's logs/recipe-clashes.txt at every start.

// RoadStuff gives both Y crossings of a colour the same grid, either way round. Now each points the way it's drawn.
recipes.remove(<roadstuff:asphaltYCross>);
recipes.remove(<roadstuff:asphaltYCross:1>);
recipes.addShaped(<roadstuff:asphaltYCross> * 5, [[<roadstuff:asphaltLine>, null, <roadstuff:asphaltLine>], [null, <roadstuff:asphaltLine>, <roadstuff:asphaltLine>], [null, null, <roadstuff:asphaltLine>]]);
recipes.addShaped(<roadstuff:asphaltYCross:1> * 5, [[<roadstuff:asphaltLine>, null, <roadstuff:asphaltLine>], [<roadstuff:asphaltLine>, <roadstuff:asphaltLine>, null], [<roadstuff:asphaltLine>, null, null]]);
recipes.remove(<roadstuff:asphaltYCrossYellow>);
recipes.remove(<roadstuff:asphaltYCrossYellow:1>);
recipes.addShaped(<roadstuff:asphaltYCrossYellow> * 5, [[<roadstuff:asphaltLine:1>, null, <roadstuff:asphaltLine:1>], [null, <roadstuff:asphaltLine:1>, <roadstuff:asphaltLine:1>], [null, null, <roadstuff:asphaltLine:1>]]);
recipes.addShaped(<roadstuff:asphaltYCrossYellow:1> * 5, [[<roadstuff:asphaltLine:1>, null, <roadstuff:asphaltLine:1>], [<roadstuff:asphaltLine:1>, <roadstuff:asphaltLine:1>, null], [<roadstuff:asphaltLine:1>, null, null]]);
recipes.remove(<roadstuff:concreteYCross>);
recipes.remove(<roadstuff:concreteYCross:1>);
recipes.addShaped(<roadstuff:concreteYCross> * 5, [[<roadstuff:concreteLine>, null, <roadstuff:concreteLine>], [null, <roadstuff:concreteLine>, <roadstuff:concreteLine>], [null, null, <roadstuff:concreteLine>]]);
recipes.addShaped(<roadstuff:concreteYCross:1> * 5, [[<roadstuff:concreteLine>, null, <roadstuff:concreteLine>], [<roadstuff:concreteLine>, <roadstuff:concreteLine>, null], [<roadstuff:concreteLine>, null, null]]);
recipes.remove(<roadstuff:concreteYCrossYellow>);
recipes.remove(<roadstuff:concreteYCrossYellow:1>);
recipes.addShaped(<roadstuff:concreteYCrossYellow> * 5, [[<roadstuff:concreteLine:1>, null, <roadstuff:concreteLine:1>], [null, <roadstuff:concreteLine:1>, <roadstuff:concreteLine:1>], [null, null, <roadstuff:concreteLine:1>]]);
recipes.addShaped(<roadstuff:concreteYCrossYellow:1> * 5, [[<roadstuff:concreteLine:1>, null, <roadstuff:concreteLine:1>], [<roadstuff:concreteLine:1>, <roadstuff:concreteLine:1>, null], [<roadstuff:concreteLine:1>, null, null]]);

// Garden Stuff's lattice used Thermal's iron gear grid: an X of iron instead.
recipes.remove(<GardenStuff:lattice>);
recipes.addShaped(<GardenStuff:lattice> * 16, [[<ore:ingotIron>, null, <ore:ingotIron>], [null, <ore:ingotIron>, null], [<ore:ingotIron>, null, <ore:ingotIron>]]);

// Extra Utilities' curtains used Malisis' curtain grid: hung from a rod of sticks instead.
recipes.remove(<ExtraUtilities:curtains>);
recipes.addShaped(<ExtraUtilities:curtains> * 12, [[<ore:stickWood>, <ore:stickWood>, <ore:stickWood>], [<minecraft:wool:*>, <minecraft:wool:*>, <minecraft:wool:*>], [<minecraft:wool:*>, <minecraft:wool:*>, <minecraft:wool:*>]]);

// Military Base Decor's button used its own reinforced concrete's grid: a stone button reinforced with it instead.
recipes.remove(<militarybasedecor:reinforced_button>);
recipes.addShapeless(<militarybasedecor:reinforced_button>, [<militarybasedecor:reinforced_concrete>, <minecraft:stone_button>]);

// Two sandstone slabs make chiseled sandstone stacked and a double slab side by side, so these never made sandstone.
recipes.removeShapeless(<minecraft:sandstone>, [<minecraft:stone_slab:1>, <minecraft:stone_slab:1>]);

// Mekanism's bronze tools and armour share Thermal's grids, so the grid always made Thermal's. Only Thermal's show.
recipes.remove(<MekanismTools:BronzePickaxe>);
recipes.remove(<MekanismTools:BronzeAxe>);
recipes.remove(<MekanismTools:BronzeShovel>);
recipes.remove(<MekanismTools:BronzeHoe>);
recipes.remove(<MekanismTools:BronzeSword>);
recipes.remove(<MekanismTools:BronzeHelmet>);
recipes.remove(<MekanismTools:BronzeChestplate>);
recipes.remove(<MekanismTools:BronzeLeggings>);
recipes.remove(<MekanismTools:BronzeBoots>);
