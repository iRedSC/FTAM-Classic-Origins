// DefenseTech weapons can't be made: missiles and grenades come only from crates, envoy supply drops and bosses
// (forge-1.7.10-mods's crates.json and phatloots.json). The explosive blocks behind the kept missiles and the bomb
// carts are banned in forge-1.7.10-mods's houserules.json, which writes banned-*.zs: no recipe, marked banned in
// NEI, and House Rules confiscates them. Their explosives stay on in DefenseTech.cfg, since the missiles go off with
// them.
// Launchers, radar and the other machines keep their recipes.
// Meta is DefenseTech's explosive id, in its registration order.

// Every missile and grenade loses its recipe, the missile module (only a crafting part) too; the kept ones say
// where they come from.
recipes.remove(<DefenseTech:missile:*>);
recipes.remove(<DefenseTech:grenade:*>);

<DefenseTech:missile:0>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // conventional
<DefenseTech:missile:3>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // debilitation
<DefenseTech:missile:4>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // chemical
<DefenseTech:missile:9>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // contagious
<DefenseTech:missile:10>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // sonic
<DefenseTech:missile:13>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // thermobaric
<DefenseTech:missile:15>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // nuclear
<DefenseTech:missile:16>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // EMP
<DefenseTech:missile:20>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // hypersonic
<DefenseTech:grenade:0>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // conventional
<DefenseTech:grenade:3>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // debilitation
<DefenseTech:grenade:4>.addTooltip("§6§l* §7Dropped by Envoy and Bosses"); // chemical
