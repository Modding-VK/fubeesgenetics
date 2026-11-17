# Genetic Stabilizer — 0.2.87-dev

Treats one FU or hybrid bee with a valid genome per 10-second cycle. Success
halves the raw mutation gene, rounded to the nearest representable integer
(half rounds upward), while retaining the remaining genes and item parameters.
Each cycle has an independent 30% chance to consume the bee without output.
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
