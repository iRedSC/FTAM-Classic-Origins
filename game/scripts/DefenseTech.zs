// DefenseTech missile ladder recipes. Each tier is the tier below, the TNT that keeps its cost in step with the wall
// power factions gives it (missiles.tiers in factions.cfg: 1.25 TNT in per TNT of power at tier 1, 0.25 more each
// tier up), and one manufactured material that gets harder to make each tier.
//   tier  explosive     power  TNT in  ratio  target  material
//   1     condensed     4      5       1.25   1.25    Enriched Alloy
//   2     sonic         6.5    10      1.54   1.50    Reinforced Alloy
//   3     thermobaric   9      16      1.78   1.75    Atomic Alloy
//   4     hypersonic    11.5   23      2.00   2.00    Ultimate Control Circuit
//   5     nuclear       14     30      2.14   2.25    Blutonium (a Big Reactors reactor's)
// Nuclear falls short of its target because a crafting grid holds 9: the hypersonic, 7 TNT and the blutonium.
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

recipes.addShapeless(condensed, [tnt, tnt, tnt, tnt, tnt, <ore:alloyAdvanced>]);
recipes.addShapeless(sonic, [condensed, tnt, tnt, tnt, tnt, tnt, <ore:alloyElite>]);
recipes.addShapeless(thermobaric, [sonic, tnt, tnt, tnt, tnt, tnt, tnt, <ore:alloyUltimate>]);
recipes.addShapeless(hypersonic, [thermobaric, tnt, tnt, tnt, tnt, tnt, tnt, tnt, <ore:circuitUltimate>]);
recipes.addShapeless(nuclear, [hypersonic, tnt, tnt, tnt, tnt, tnt, tnt, tnt, <ore:ingotBlutonium>]);

// Repulsive can't go off; it only goes into gas and EMP, which keep costing about one TNT.
recipes.addShapeless(repulsive, [tnt, <minecraft:gunpowder>]);
