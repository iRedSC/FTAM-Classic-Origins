// DefenseTech missile ladder recipes. Each tier is the tier below, the TNT that keeps its cost in step with the wall
// power factions gives it (missiles.tiers in factions.cfg: 1.25 TNT in per TNT of power at tier 1, 0.25 more each
// tier up), and one manufactured material that gets harder to make each tier.
//   tier  explosive     power  TNT in  ratio  target  material
//   1     condensed     4      5       1.25   1.25    Enriched Alloy
//   2     sonic         6.5    10      1.54   1.50    Reinforced Alloy
//   3     thermobaric   9      16      1.78   1.75    Atomic Alloy
//   4     hypersonic    11.5   23      2.00   2.00    Ultimate Control Circuit
//   5     nuclear       14     31      2.21   2.25    Blutonium (a Big Reactors reactor's)
// Nuclear carries its extra TNT as a condensed explosive (5 TNT) and 3 TNT, since a crafting grid holds only 9.
// Explosive block meta is DefenseTech's registry id, in its registration order.

val tnt = <minecraft:tnt>;
val condensed = <DefenseTech:explosives:0>;
val sonic = <DefenseTech:explosives:10>;
val thermobaric = <DefenseTech:explosives:13>;
val nuclear = <DefenseTech:explosives:15>;
val hypersonic = <DefenseTech:explosives:20>;

recipes.remove(condensed);
recipes.remove(sonic);
recipes.remove(thermobaric);
recipes.remove(nuclear);
recipes.remove(hypersonic);

recipes.addShapeless(condensed, [tnt, tnt, tnt, tnt, tnt, <ore:alloyAdvanced>]);
recipes.addShapeless(sonic, [condensed, tnt, tnt, tnt, tnt, tnt, <ore:alloyElite>]);
recipes.addShapeless(thermobaric, [sonic, tnt, tnt, tnt, tnt, tnt, tnt, <ore:alloyUltimate>]);
recipes.addShapeless(hypersonic, [thermobaric, tnt, tnt, tnt, tnt, tnt, tnt, tnt, <ore:circuitUltimate>]);
recipes.addShapeless(nuclear, [hypersonic, condensed, tnt, tnt, tnt, <ore:ingotBlutonium>]);

// Gas and EMP come only as missiles, each a nuke's explosive turned special at the missile step with loot-only
// pack items (Chemicals and Car Batteries come from loot chests) and something hard to make.
val module = <DefenseTech:missile:23>;
val chemicals = <contenttweaker:Chemicals>;
val battery = <contenttweaker:CarBattery>;
val debilitationMissile = <DefenseTech:missile:3>;
val chemicalMissile = <DefenseTech:missile:4>;
val contagiousMissile = <DefenseTech:missile:9>;
val empMissile = <DefenseTech:missile:16>;
recipes.remove(debilitationMissile);
recipes.remove(chemicalMissile);
recipes.remove(contagiousMissile);
recipes.remove(empMissile);
recipes.addShapeless(debilitationMissile, [module, nuclear, chemicals, chemicals, <minecraft:fermented_spider_eye>,
        <minecraft:fermented_spider_eye>, <minecraft:fermented_spider_eye>, <minecraft:fermented_spider_eye>]);
recipes.addShapeless(chemicalMissile, [module, nuclear, chemicals, chemicals, <DefenseTech:poisonPowder>,
        <DefenseTech:poisonPowder>, <DefenseTech:poisonPowder>, <DefenseTech:poisonPowder>]);
recipes.addShapeless(contagiousMissile, [module, nuclear, chemicals, chemicals, chemicals, <minecraft:skull:1>,
        <minecraft:skull:1>]);
recipes.addShapeless(empMissile, [module, nuclear, battery, battery, <EnderIO:itemBasicCapacitor:2>,
        <EnderIO:itemBasicCapacitor:2>]);
