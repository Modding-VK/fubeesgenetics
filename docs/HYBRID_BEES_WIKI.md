# Hybrid Bees Mechanics Wiki

This page explains, in plain language, how bee crossbreeding works in the Genetic Hybridizer.

## 1. What goes into the Hybridizer

The machine accepts:

- a queen bee from one species;
- a drone from another species;
- optionally, a Research Microdisc, Holodisc, or Megadisc.

A successful attempt produces a **hybrid queen larva**, not an adult queen.

Both parent bees are consumed on every attempt. A valid disc is also consumed,
regardless of whether the attempt succeeds or fails.

## 2. Success chance

Without a disc, the base chance is:

- ordinary species: 30%;
- rival species: 10%.

Discs increase this chance:

| Disc | Normal bonus | Bonus against rival species |
| --- | ---: | ---: |
| Research Microdisc | +15 percentage points | +7.5 points |
| Research Holodisc | +25 percentage points | +12.5 points |
| Research Megadisc | +30 percentage points | +15 points |

The chance cannot exceed 100%.

Examples:

- ordinary species + Microdisc: 45%;
- ordinary species + Holodisc: 55%;
- ordinary species + Megadisc: 60%;
- rival species + Microdisc: 17.5%;
- rival species + Holodisc: 22.5%;
- rival species + Megadisc: 25%.

## 3. How traits are inherited

Each trait is calculated separately from the queen's and drone's genes.

The general rule is:

1. the Hybridizer reads the trait value from both parents;
2. it uses the lower parental value as the base;
3. it applies a one-third reduction, keeping approximately two-thirds of the value;
4. it rounds to the nearest genetic unit;
5. if the original base was above zero, the result cannot be lower than 1;
6. if both values were zero, the result remains zero.

The hybrid therefore does not automatically receive the average of both values. The
result is a reduced version of the weaker parental trait.

### Example

If a trait has values 3 and 1:

- lower value: 1;
- two-thirds of 1: 0.67;
- rounding and the positive minimum: 1;
- result: 1.

If the values are 6 and 3:

- lower value: 3;
- two-thirds of 3: 2;
- result: 2.

## 4. Traits with special rules

Some genes do not use the general rule.

### Subspecies

The larva randomly receives one of the two available hybrid subspecies. Both
subspecies have the same appearance, but each prioritizes resources associated
with a different parent.

The visible subspecies field reports:

'Predominant: [subspecies]'

The player can use this field to identify which production lineage was prioritized.

### Work time

Work time has its own rule to preserve valid combinations and avoid incompatible
extreme results.

### Mutation chance

Mutation chance starts from the higher parental value and receives a one-unit
genetic increase, within the gene's internal limit.

## 5. Biomes and intolerances

The intolerances or dislikes from both parents are retained by the hybrid. When both
parents have an explicit value for the same biome, the result is the midpoint
between those values.

The rule can be summarized as:

- both parents' intolerances are preserved;
- conflicting values for the same biome are combined at the midpoint;
- a positive value continues to represent a favorable condition;
- a negative or extreme value continues to represent intolerance or danger,
  according to the scale used by Frackin Universe.

Biome inheritance is independent of the subspecies choice.

## 6. Preferred plants

The hybrid receives one preferred plant from each parent.

When preferences conflict, likeness is combined at the midpoint. The hybrid does
not receive an unlimited preference list: one preference is selected from each
side of the cross.

## 7. Rivalries

A hybrid species is considered rival when the parent combination involves rival
species.

Rivalries also carry into later crosses:

- the hybrid retains rivalry derived from its parents;
- rival species have a lower hybridization chance;
- a rival hybrid can become one of the rival participants in future crosses.

## 8. Production in apiaries

The resource and quantity table belongs to the Frackin Universe apiary. The bee
provides identity, subspecies, and genetics for the apiary to use in its calculations.

Therefore:

- the apiary defines base resources, speed, slots, and processing rules;
- the bee provides the genetic data and lineage consulted by the apiary;
- the predominant subspecies determines which hybrid production line is prioritized;
- the hybrid can produce resources associated with both parent species, with
  reductions according to inheritance and production rules.

## 9. Appearance

Each hybrid species has its own sprite. Its appearance combines colors, patterns,
and visual traits from both parents.

The two subspecies of the same hybrid species share the same appearance. Their
difference lies in genetics, predominant subspecies, and production priority.

## 10. Progress and specimen changes

The Hybridizer accumulates progress only when it has:

- a valid queen;
- a valid drone from a different species;
- an empty larva output slot;
- available power.

If an input is removed, the experiment pauses. Reinserting the exact same bee lets
the experiment continue.

If one of the specimens is replaced:

- existing progress is reduced by 50%;
- the machine shows a rework warning;
- the experiment continues with the new pair.

## 11. Attempt result

When progress reaches 10,000 points, the Hybridizer performs an attempt:

- success: creates a hybrid queen larva;
- failure: consumes both parents and creates no larva;
- disc inserted: consumes the disc with the attempt;
- after the result: the progress cycle resets.

This page describes the trait logic used by hybrid bees and deliberately excludes
the 'miteResistance' gene, which is outside this consolidation.


## 12. Planned hybrid production rule

The hybrid production model combines both parent production profiles
using the predominant parent as the weight.

If parent A produces:

- 5 of resource E;
- 2 of resource F;
- 6 of resource G;
- 1 of resource H;

and parent B produces:

- 3 of resource X;
- 6 of resource Y;
- 10 of resource Z;

then a hybrid with the same production capacity and parent A as predominant uses:

- 2/3 of parent A's production;
- 1/3 of parent B's production.

The hybrid therefore receives the union of both parents' resource profiles. Resources
that only parent A produces are weighted by the 2/3 share. Resources that only
parent B produces are weighted by the 1/3 share. If both parents produce the same
resource, their quantities are combined using those same weights.

The weighted production rule is implemented. The final integer rounding
and the exact apiary integration still need to be implemented and verified.


## 13. Apiary cycle compatibility

Hybrid bees follow the Frackin Universe apiary cycle gate. A queen cannot start
producing drones by itself: valid drones must already be present for the apiary
to advance queen production. The native no-queen timer and drone decay rules are
also preserved, so drones do not remain indefinitely after their queen is removed.


## 14. Hybridizer status outputs

The Hybridizer exposes four binary output nodes for automation:

| Node | Signal condition |
| --- | --- |
| 0 | A valid experiment is actively accumulating progress |
| 1 | A supported research disc is present in the disc slot |
| 2 | The larva result slot is occupied |
| 3 | Valid parents are present, the result slot is free, and the machine can accept progress |

The signals are updated only when their state changes. The existing power input
remains separate from these status outputs.

## 12. Apiary breeding with mixed-species drones

When a hybrid queen breeds inside an FU apiary, the larva genome follows the
same averaging rule as native FU breeding. Every drone in a configured drone
slot contributes its genome, including drones from another species with
different trait values. The queen genome is included in the average, then FU's
mutation chance is applied. Species compatibility remains relevant to hybrid
resource production and rivalries; it does not remove a valid drone genome from
larva inheritance.
