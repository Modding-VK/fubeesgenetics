# Overload Apiary — 0.2.20-dev

The Overload Apiary is a powered variant of the Frackin Universe Apiary. It
keeps FU's native container, genetics, frames, biome and flower rules, and uses
the FU power network for a continuous draw of **12 W**.

## Behavior

- Resource production is multiplied by **1.2**.
- Drone breeding is multiplied by **1.2**.
- The queen loses lifespan at **1 / 0.7** the normal rate, resulting in 70% of
  her normal working life.
- The apiary pauses its bee simulation when its connected network cannot supply
  its power draw. Output and queen aging resume when power is available.
- It never releases random capturable bee entities, whether the queen is native
  or hybrid. Drones and queen larvae remain inventory items.
- Crafting is unlocked by obtaining the Bee Station. Recipe: one Normal Apiary,
  two AI Chips, and eight Titanium Bars.

The current object reuses FU's native Apiary art and interface. The item ID is
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
