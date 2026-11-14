// MCHeli vehicles: three of each kind craftable with MCHeli's own recipes (one light, two low-tier fighters).
// Craftable helicopters: Fl 282 (unarmed), MH-60G, MH-60L DAP. Planes: F-4A, F-14D, MiG-29.
// Boats: Zodiac (unarmed), Mk.5, Project 1204. Ground: MIM-23 and Mk29 (the only two, both AA launchers).
// Everything else comes from crates.
import minetweaker.item.IItemStack;

val crateOnly = [
    <mcheli:ah-1z>, <mcheli:ah-64>, <mcheli:mi28>, <mcheli:penetrator>,
    <mcheli:mh-6>, <mcheli:uh-1c>, <mcheli:ec665>,
    <mcheli:a-10>, <mcheli:ac-130>, <mcheli:b-2a>, <mcheli:f22a>, <mcheli:f-35a>, <mcheli:f-35c>, <mcheli:fa18f>,
    <mcheli:tornado-gr4>, <mcheli:tornado-ids>, <mcheli:x-47b>, <mcheli:emb314>, <mcheli:a6m2>,
    <mcheli:cb90>
] as IItemStack[];
for v in crateOnly {
    recipes.remove(v);
}
