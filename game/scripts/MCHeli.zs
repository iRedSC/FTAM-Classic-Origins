// MCHeli vehicles: one unarmed helicopter on MCHeli's own recipe (Fl 282), and one armed helicopter (MH-60G),
// plane (F-4A) and ground vehicle (MIM-23 HAWK, as the pack has no tanks) on hard recipes built around parts that only
// come from crates, supply drops and dungeon loot (GPU, Chemicals, Car Battery, chip, LCD display).
// Everything else comes from crates.
import minetweaker.item.IItemStack;

val crateOnly = [
    <mcheli:ah-1z>, <mcheli:ah-64>, <mcheli:mi28>, <mcheli:penetrator>,
    <mcheli:mh-6>, <mcheli:uh-1c>, <mcheli:ec665>, <mcheli:mh-60l_dap>,
    <mcheli:a-10>, <mcheli:ac-130>, <mcheli:b-2a>, <mcheli:f22a>, <mcheli:f-35a>, <mcheli:f-35c>, <mcheli:fa18f>,
    <mcheli:tornado-gr4>, <mcheli:tornado-ids>, <mcheli:x-47b>, <mcheli:emb314>, <mcheli:a6m2>,
    <mcheli:f14d>, <mcheli:mig29>,
    <mcheli:cb90>, <mcheli:zodiac>, <mcheli:mark5>, <mcheli:project1204>,
    <mcheli:sea_sparrow>
] as IItemStack[];
for v in crateOnly {
    recipes.remove(v);
}

val gpu = <contenttweaker:Graphics_Card>;
val chemicals = <contenttweaker:Chemicals>;
val battery = <contenttweaker:CarBattery>;
val ironBlock = <minecraft:iron_block>;

recipes.remove(<mcheli:mh-60g>);
recipes.addShaped(<mcheli:mh-60g>, [
    [gpu, ironBlock, gpu],
    [ironBlock, battery, ironBlock],
    [chemicals, ironBlock, chemicals]]);

recipes.remove(<mcheli:f4a>);
recipes.addShaped(<mcheli:f4a>, [
    [chemicals, ironBlock, chemicals],
    [ironBlock, gpu, ironBlock],
    [battery, <minecraft:diamond_block>, battery]]);

recipes.remove(<mcheli:mim-23>);
recipes.addShaped(<mcheli:mim-23>, [
    [<contenttweaker:chip>, <contenttweaker:lcd_display>, <contenttweaker:chip>],
    [ironBlock, gpu, ironBlock],
    [chemicals, <minecraft:redstone_block>, chemicals]]);
