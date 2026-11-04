// DefenseTech missile ladder recipes. Each ladder explosive costs TNT in proportion to the wall power factions gives
// it (missiles.tiers in factions.cfg): 1.25 TNT in per TNT of power at tier 1, 0.25 more each tier up.
//   tier  explosive     power  TNT in  ratio
//   1     condensed     4      5       1.25
//   2     sonic         6.5    10      1.54
//   3     thermobaric   9      16      1.78
//   4     hypersonic    11.5   23      2.00
//   5     nuclear       14     32      2.29
// Explosive block meta is DefenseTech's registry id, in its registration order.

val tnt = <minecraft:tnt>;
val condensed = <DefenseTech:explosives:0>;
val repulsive = <DefenseTech:explosives:6>;
val sonic = <DefenseTech:explosives:10>;
val thermobaric = <DefenseTech:explosives:13>;
val nuclear = <DefenseTech:explosives:15>;
val hypersonic = <DefenseTech:explosives:20>;

recipes.remove(condensed);
recipes.remove(repulsive);
recipes.remove(sonic);
recipes.remove(thermobaric);
recipes.remove(nuclear);
recipes.remove(hypersonic);

// 5 TNT.
recipes.addShaped(condensed, [[tnt, tnt, tnt], [tnt, <minecraft:redstone>, tnt]]);
// Repulsive can't go off; it only goes into gas and EMP, which keep costing about one TNT.
recipes.addShapeless(repulsive, [tnt, <minecraft:gunpowder>]);
// 2 condensed: 10 TNT.
recipes.addShaped(sonic, [[<ore:ingotBronze>, <minecraft:noteblock>, <ore:ingotBronze>],
        [condensed, null, condensed],
        [<ore:ingotBronze>, <minecraft:noteblock>, <ore:ingotBronze>]]);
// 3 condensed and a TNT: 16 TNT.
recipes.addShaped(thermobaric, [[<ore:dustSulfur>, condensed, <ore:dustSulfur>],
        [condensed, <minecraft:lava_bucket>, condensed],
        [<ore:dustSulfur>, tnt, <ore:dustSulfur>]]);
// 2 sonic and 3 TNT: 23 TNT.
recipes.addShaped(hypersonic, [[<ore:blockBronze>, sonic, <ore:blockBronze>],
        [tnt, tnt, tnt],
        [null, sonic, null]]);
// 2 thermobaric: 32 TNT. Yellorium counts as uranium.
recipes.addShaped(nuclear, [[<ore:ingotUranium>, thermobaric, <ore:ingotUranium>],
        [<ore:ingotUranium>, null, <ore:ingotUranium>],
        [null, thermobaric, null]]);
