// Atomic Alloy is infused with obsidian again, as in stock Mekanism. Mekanism CE's EnableBoPProgression (on by default,
// with Biomes O' Plenty installed) switched it to ender infusion from Ender Amethyst. That option stays on, because
// turning it off also unregisters Compressed Ender, and every one players hold would vanish at the next boot.
mods.mekanism.Infuser.removeRecipe(<Mekanism:AtomicAlloy>, <Mekanism:ReinforcedAlloy>, "ENDER");
mods.mekanism.Infuser.addRecipe("OBSIDIAN", 10, <Mekanism:ReinforcedAlloy>, <Mekanism:AtomicAlloy>);
