Status: investigação concluída na 0.2.11-dev após receber o PAK original.
Ver docs/BEE_EXCHANGE_0_2_11.md e tools/ic_upstream.json.
O texto abaixo e native-ui.patch preservam a investigação anterior.

# Storage compatibility investigation — not applied

Target: Improved Containers 2.11 original (Workshop 729427606), confirmed by user
and supplied starbound.log. The OpenStarbound Post-Load Mega-Patch is not installed.

The current Bee Exchange uses a private copy of the native chest16 window.
native-ui.patch prepares its migration to /interface/chests/chest16.config so
native container UI patches can reach it. This change is intentionally not in the
PAK until the matching IC object integration can be checked against actual source.
GUI callbacks can depend on the IC object scripts; changing only the window may
produce a broken interface, so it cannot be treated as complete compatibility.

Public integration example audited:
https://github.com/amirmiked12/ImmersiveProps-ImprovedContainer-Patch
commit ac9437fc9ffddf3ae2c5cc37693cec6252cf96b8:
objects/shop/storage/orestorage.object.patch appends
/scripts/v6/improvedcontainer.lua and configures
/scripts/v6/improvedcontainerrotting.lua as itemAgingScripts, plus smashOnBreak.
interface/chests/imbstorage128.config.patch adds GUI callbacks and
/scripts/v6/improvedcontainergui.lua.
This third-party patch is evidence of integration points, not IC 2.11 source.
Do not copy its 128-slot widget positions into the 16-slot machine.

Need the original Improved Containers 2.11 contents.pak (or its unpacked source)
to verify lifecycle chaining, sorting/quick stack, renaming and retained contents
against Bee Exchange pending rewards/destruction recovery. No IC script is bundled,
no hard dependency is added, and no placeholder hook is invoked in the current PAK.

Independent checks E37/E38 exercise actual Bee Exchange controller behavior when
another storage UI reorders slots, inserts stacks or takes all items. They use
simulated engine bindings; they do not execute IC and do not establish compatibility.
