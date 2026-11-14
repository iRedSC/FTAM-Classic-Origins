// DefenseTech weapons can't be made: missiles and grenades come only from crates, envoy supply drops and bosses
// (forge-1.7.10-mods's crates.json and phatloots.json). The explosive blocks behind the kept missiles and the bomb
// carts are banned in forge-1.7.10-mods's houserules.json, which writes banned-*.zs: no recipe, marked banned in
// NEI, and House Rules confiscates them. Their explosives stay on in DefenseTech.cfg, since the missiles go off with
// them.
// Launchers, radar and the other machines keep their recipes.
// Meta is DefenseTech's explosive id, in its registration order.

// Every missile and grenade loses its recipe, the missile module (only a crafting part) too. Where the kept ones
// come from is in their tooltips, sent by forge-1.7.10-mods's Lore plugin (lore.json).
recipes.remove(<DefenseTech:missile:*>);
recipes.remove(<DefenseTech:grenade:*>);
