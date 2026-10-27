# Overload Apiary — 0.2.20-dev

The Overload Apiary is a powered variant of the Frackin Universe Apiary. It
keeps FU's native container, genetics, frames, biome and flower rules, and uses
the FU power network for a continuous draw of **12 W**.

## Behavior

- With 12 W available, resource production and drone breeding are multiplied by **1.2**.
- Without power, resources and drones continue at their normal production rates.
- The queen loses lifespan at **1 / 0.7** the normal rate, resulting in 70% of
  her normal working life.
- Queen aging continues without power at the same accelerated rate.
- It never releases random capturable bee entities, whether the queen is native
  or hybrid. Drones and queen larvae remain inventory items.
- Crafting is unlocked by researching Abusive Apiaries in FU Agriculture.
  The recipe stays at the Bee Station: one Normal Apiary,
  one AI Chip, and five Durasteel Bars.

The object keeps FU's native interface and animation states. Its base and
inventory sprites now use native-resolution overload variants. The item ID is
`fubeesgenetics_overloadapiary`.

## Implementation notes

The addon script loads `/bees/apiary.lua` and wraps its callbacks, so FU retains
ownership of the bee lifecycle and storage behavior. Resource output scales the
genetic base production while preserving frame bonuses. Drone breeding scales
the queen's decoded drone-breeding stat. Power is drawn through
`/scripts/fupower.lua` at the object's five-tick update interval.

12 W is the initial balance value, chosen as a moderate industrial draw below
the FU Centrifuge's documented 24 W. It can be adjusted after in-game balance
review without changing the bee mechanics.

## Large variant (0.2.26-dev)

The Overload Large Apiary upgrades one FU Large Apiary (`normalalveary`) with
one AI Chip and five Durasteel Bars at the Bee Station. Its item ID is
`fubeesgenetics_overloadlargeapiary`. It retains the native large interface,
20 slots, two drone slots and two frame slots. The same overload script gives
the 1.2 resource and drone bonus when 12 W is available, normal production
without power, 70% queen lifespan, and no random capturable bee spawns.

## Native sprite adaptation (0.2.43-dev)

The small object retains FU's **16×24** frame and four named states; the large
retains **40×32** and the same four states. Their original hive bodies, entrances,
and bee emblem remain recognizable. The visible additions are restrained metal
compression bands, copper coils, and small powered indicators. The disabled and
infested frame colors follow their original states. Object preview and the
animator base both point to the matching local frame sheet; FU's bees, loading,
warning and container interface parts remain in use. Inventory icons are local
variants of the FU icons. No new animation script or recurring work was added.

The small sprite preserves four support feet. The large sprite has four distinct
feet, two frontal and two recessed; all terminate at the same frame baseline.
Bottom edges run horizontally, with no visible top or underside planes. These
are project art constraints, not universal requirements of FU's original art.

Source: FU Apiary and Large Apiary PNGs and frame definitions from revision
`17868d86c9bb7bc00f92038fb78b48cebd1b41b8`, as pinned in
[SPRITE_SOURCES](SPRITE_SOURCES.md). Adaptation uses direct integer-pixel edits
on those native canvases. The concept illustration is not a production asset.
Static inspection checks frame dimensions, state names, preview paths, alpha,
and foot alignment; rendering beside FU machines still requires an in-game check.

### Large Apiary concept based on the current mod asset

For further visual revisions, use the current `large-object.png` as the base,
not a newly interpreted large hive. The [native concept sheet](reference/overload-large-native-concept.png)
preserves the four 40×32 frames; the [comparison preview](reference/overload-large-current-vs-concept.png)
shows current art above and proposed art below at 8× nearest-neighbor.
Only the lower left side and right feet change: the four-dot panel sits on the
left side face, the front keeps its existing bee emblem and has no four-dot
panel, and both right feet move two pixels inward. All four feet still end on
row 31. The concept alters 58 pixels per frame. These files are review material
under `docs/reference/`; the game object still uses its existing PNG until the
concept is adopted.
