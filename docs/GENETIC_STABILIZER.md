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
Unknown Genes; Genetic Stabilization unlocks it.
This recipe-only adjustment adds no recurring scripting work.

The stabilizer interface reuses the 120×101 FU Bee Examiner window and the
mod's native slot frames. Its two slots, title, icon and risk/cycle text fit in
the compact window. These are static layout changes with no additional UI
script or polling. Positioning and text readability still require in-game
verification.
The slots, their frames and their labels are positioned three pixels lower;
the help text and window size are unchanged.

The world appearance references FU's Advanced Xenolab, using the original
48×45 frame and animated layer, using the earlier yellow body palette. The
same palette is applied to the placement preview and all idle/working frames;
only the marked displays are fullbright. This uses static image
directives and adds no recurring scripting work. The standard
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

During a valid, unblocked cycle the animator draws blue fullbright overlays
only inside the five marked displays, excluding their surrounding borders,
cropped from FU's three-frame Xenolab animation. The remaining body and
animation are not fullbright.
It returns to idle on completion, invalid input, blocked
output or recovery. Only transitions call the animator; the existing 30-tick
update selects the state and the renderer loops the frames without another
timer or world query. Color, alignment and transitions need an in-game check.
The screenshot shows the mirrored orientation; the display crops are defined
in source-frame coordinates and flip together with the machine's animator.
