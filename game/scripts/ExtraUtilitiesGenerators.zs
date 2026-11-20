// Extra Utilities' generators can't be crafted: every kind, and the 8x and 64x compressed ones. Generators already
// built or held keep working, so they aren't banned and stay listed in NEI. The shop, crates, envoy bags and kits no
// longer hand them out either (forge-1.7.10-mods: dev/value/skip.json and the configs).
recipes.remove(<ExtraUtilities:generator:*>);
recipes.remove(<ExtraUtilities:generator.8:*>);
recipes.remove(<ExtraUtilities:generator.64:*>);
