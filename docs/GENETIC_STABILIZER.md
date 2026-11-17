# Genetic Stabilizer — 0.2.87-dev

Treats one FU or hybrid bee with a valid genome per 10-second cycle. Success
halves the raw mutation gene, rounded to the nearest representable integer
(half rounds upward), while retaining the remaining genes and item parameters.
Each cycle has an independent 40% chance to consume the bee without output.
The item has Legendary rarity. This balance and metadata change adds no recurring
scripting work.
An occupied output prevents processing. Replacing the specimen, unloading the
machine or blocking the output resets the unfinished cycle. It requires no
power. The Bee Station recipe uses five AI Chips, ten Durasteel Bars, ten Cell
Matter, five Isogen Bars, five Lunari Crystals (`solaricrystal`) and five
Unknown Genes; Unethical Genetics unlocks it.
This recipe-only adjustment adds no recurring scripting work.

The world appearance references FU's Advanced Xenolab, using the original
48×45 frame and light layer with a yellow replacement palette. The standard
48×45 silhouette and position remain unchanged. The inventory icon currently
uses the original FU icon. Appearance, placement and interaction in the game
remain to be checked, including both illumination and orientation.

The existing container helpers protect a failed insertion by restoring the
original specimen or placing it in persisted recovery escrow. The script runs
every 30 ticks, checks at most two slots while idle and does no world search or
UI polling; progress advances with dt only while loaded and unblocked. No CPU
or scripting queue measurements have been made in the engine. For measurement,
compare many loaded idle, processing and blocked machines, with UI closed and
open, and verify the unloaded/reloaded cycle and automation transfers.

During a valid, unblocked cycle the animator draws a blue fullbright layer
derived from the gray areas of FU's Xenolab sprite, alongside the three-frame
animated light from the same source. The original body and light remain
separate layers. It returns to idle on completion, invalid input, blocked
output or recovery. Only transitions call the animator; the existing 30-tick
update selects the state and the renderer loops the frames without another
timer or world query. Color, alignment and transitions need an in-game check.
