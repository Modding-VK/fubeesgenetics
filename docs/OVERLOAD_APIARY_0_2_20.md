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
`/scripts/fupower.lua` at the object's update interval (10 ticks since
0.2.48-dev).

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

### Belt power indicators (0.2.47-dev)

The normal `default` frame now uses a muted Durasteel-blue pixel on the belt;
the existing `powered` frame retains the cyan pixel. The small apiary has one
belt indicator at (4, 10). The large apiary has two front-belt indicators at
(11, 17) and (33, 17), using the existing symmetric positions. The disabled
and infested frames keep their existing colors. All frames retain their native
size and alignment, and the inventory icons are unchanged.

The reference is FU's Hydroponics Tray at commit
`17868d86c9bb7bc00f92038fb78b48cebd1b41b8`: its `powlight` part has
separate `off` and `on` frames, with neutral pixels in `off` and cyan pixels in
`on`. Our existing `powered` base state serves that same visual purpose with
no extra layer or script. In 0.2.47-dev power was checked every 5 ticks;
the animator changes only on a power transition. This asset edit adds
no script callback, timer, cache, or recurring rendering part. Visual behavior
under an actual FU power network remains to be checked in game.

### Half-frequency script updates (0.2.48-dev)

Both Overload Apiary objects now use `scriptDelta: 10` instead of 5, reducing
scheduled `update(dt)` calls from about 12 to 6 per second at 60 game ticks/s.
The existing FU `power.update(dt)` and `power.consume(12 * dt)` use the actual
elapsed time: each call requests twice the energy at the nominal cadence, so
the requested draw remains 12 W per second. The LED can respond up to one
10-tick interval after a power change instead of one 5-tick interval.

FU's `update2` also subtracts `dt` from its bee timer and accumulates
`beeTickDelta`, so the configured `beeUpdateInterval` remains one second. The
per-bee production multiplier (1.2), drone-breeding multiplier (1.2), and
queen-aging factor (1 / 0.7) therefore stay unchanged: doubling them would
change output and lifespan because bee ticks were not halved. FU's 1-second
container refresh and power-network pulse remain time-based. The upstream
stagger increment derived from `scriptDelta` increases from 0.05 to 0.10
seconds, keeping nearby hives' work offset rather than synchronized.

This halves callback frequency, not total script CPU: FU still executes its
bee production and local hive query about once per second. No additional
polling, network request, cache, or rendering layer was introduced. A loaded
world with many powered/unpowered hives and shared generators still needs an
in-game comparison of script time, production, power draw, and queen lifespan;
there is no server-thread measurement from this static change.

### Small apiary belt correction (0.2.49-dev)

The small Overload Apiary's 16×24 world frames now follow the large variant's
front/side belt construction. In each of the five states, the two belt rows
have a darker left-side segment (x=0–6), a vertical corner at x=7, and a
front segment starting at x=8. The lower edge stays horizontal and the four
support feet are untouched. The single indicator formerly on the side at
(4, 10) was replaced by two front indicators at (9, 10) and (14, 10),
symmetrically inset from the front edges. Their colors retain the established
state meanings: neutral for `default` and `disabled`, muted red for infestation,
and cyan for `powered`.

The 24×18 inventory icon's belt now extends one pixel beyond each side of its
body, with a front/side corner and two front indicators. This replaces its
oversized belt, which extended farther than the body on both sides. Edits were
made on copies of the mod's existing PNGs at native resolution; the large
apiary PNGs, canvas sizes, frame names, animation, script, power draw, and
production rules are unchanged. Static pixel inspection shows edits confined
to the belt and icon belt; perspective and appearance in game remain to be
reviewed by the maintainer.

### Inventory icon alignment (0.2.50-dev)

Both inventory icons now present the same side/front orientation as their
corresponding world sprites: the darker side is on the left, the brighter front
on the right. Their belts end at the body edges instead of projecting beyond
them. The belt's dark side segment meets the front at a vertical corner, and
the two cyan accent pixels are symmetric on the front. The small icon remains
24×18 and the large icon remains 24×20. The icon sheets were corrected at native
resolution using the mod's existing art; world sprites, item IDs, scripts, and
animation states were not changed. The static inventory icon is decorative and
does not represent the current live power state.

The Overload Apiaries currently change only their sprite LEDs when energized;
they do not emit light into the world. FU's Hydroponics Tray at pinned revision
`17868d86c9bb7bc00f92038fb78b48cebd1b41b8` likewise has a `powlight`
on/off sprite without world-light settings. FU's separate Heatlamp Tray uses
`emitsLightWhenPowered`, `lightColor`, and `object.setLightColor` to illuminate
its surroundings. No light API call or recurring script work was added here.

### Scanner text cleanup (0.2.51-dev)

The large apiary's eight species-specific and generic scan descriptions now
explain its powered output and queen wear without mentioning inventory slots,
frames, or compartment counts. The small apiary's scan descriptions already
avoided these details. Container capacity and slot configuration remain
unchanged; this text-only change adds no recurring scripting work.

### Large apiary interface title (0.2.52-dev)

The large apiary `shortdescription`, used as the displayed object title, is
abbreviated to `Ov. L. Apiary` to fit its interface header. Scanner descriptions
and the crafting recipe are unchanged.
