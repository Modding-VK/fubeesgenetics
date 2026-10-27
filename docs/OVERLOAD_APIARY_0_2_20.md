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

The small sprite preserves four support feet. In 0.2.44-dev the large sprite
returns to FU's original **solid, floor-flush base**, without distinct feet.
Bottom edges run horizontally, with no visible top or underside planes.

Source: FU Apiary and Large Apiary PNGs and frame definitions from revision
`17868d86c9bb7bc00f92038fb78b48cebd1b41b8`, as pinned in
[SPRITE_SOURCES](SPRITE_SOURCES.md). Adaptation uses direct integer-pixel edits
on those native canvases. Static inspection checks frame dimensions, state
names, preview paths and alpha; rendering beside FU machines still requires an
in-game check.

### Large Apiary correction based on the current mod asset (0.2.44-dev)

The [historical native sheet](reference/overload-large-native-concept.png) records
the 0.2.44-dev art before the Durasteel recolor. The [comparison preview](reference/overload-large-current-vs-concept.png)
shows the previous art above and that correction below, at 8× nearest-neighbor.
Each frame remains 40×32. The right/front illuminated vertical strip is gone;
the left/side strip remains. The solid lower three rows come directly from the
corresponding FU frame, eliminating the four feet. The central metal band now
has a darker side segment and a distinct front segment that meet at a vertical
corner. The icon's band follows the same division. The bee emblem and FU
animation states remain intact. No new script or recurring work was added.

### Durasteel color across all states (0.2.45-dev)

Both Overload Apiary sheets now use the blue-violet Durasteel Bar palette as
their base material in **all four states**: `default`, `disabled`, `infested`
and `infested2`. The two infested states retain small muted red accents so the
infection remains legible. The small canvas remains 16×24 per frame and the
large canvas 40×32. The large sheet also includes the corrected front-band
indicator symmetry and its right edge aligned to the body. Both inventory
icons follow the Durasteel palette. No scripts, animation state names or
mechanics changed; normal idle appearance already uses `default` in FU and
therefore now shows Durasteel too. The archive images above document the older
art and are not the current game textures.

### Separate powered state (0.2.46-dev)

Both objects now use a local copy of FU's apiary animation with one additional
`base` state named `powered`. Their sprite sheets have a fifth frame with that
name; it is pixel-identical to `default` for now. The original four frames,
their names, canvas sizes, bees, loading and warning parts remain intact.

The existing 12 W `power.consume` result determines both the production bonus
and the visual state. On a change from unpowered to powered, the script selects
`powered`; when energy is insufficient, it selects `default`. With no power,
normal FU production still continues without the 20% bonus. The script adds
only a boolean comparison on its existing update and sends an animator change
**only on power transitions**. There is no new polling, timer, cache or
recurring message. In-game verification is still needed to confirm the
transition and appearance under a connected FU power network.
