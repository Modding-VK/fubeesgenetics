#!/usr/bin/env python3
"""Build a plain white Steam Workshop gallery image from hybrid queen sprites."""

import json
import random
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "docs/HYBRID_SPECIES_CATALOG.json"
SPRITES = ROOT / "FUBeesGenetics/bees/bees"
OUTPUT = ROOT / "artwork/workshop/hybrid-queens-gallery-1920x1080.png"
WIDTH, HEIGHT = 1920, 1080
COLUMNS, ROWS = 16, 9
CELL = 112
SCALE = 6


def main():
    catalog = json.loads(CATALOG.read_text())
    species = sorted(entry["id"] for entry in catalog["hybrids"])
    chosen = random.Random(20261022).sample(species, COLUMNS * ROWS)
    canvas = Image.new("RGBA", (WIDTH, HEIGHT), "white")
    left = (WIDTH - COLUMNS * CELL) // 2
    top = (HEIGHT - ROWS * CELL) // 2

    for index, species_id in enumerate(chosen):
        sheet = Image.open(SPRITES / f"{species_id}.png").convert("RGBA")
        if sheet.size != (84, 28):
            raise ValueError(f"Unexpected sprite size for {species_id}: {sheet.size}")
        queen = sheet.crop((28, 0, 56, 28))
        bounds = queen.getbbox()
        if bounds is None:
            raise ValueError(f"Empty queen sprite: {species_id}")
        queen = queen.crop(bounds)
        queen = queen.resize((queen.width * SCALE, queen.height * SCALE), Image.Resampling.NEAREST)
        x = left + (index % COLUMNS) * CELL + (CELL - queen.width) // 2
        y = top + (index // COLUMNS) * CELL + (CELL - queen.height) // 2
        canvas.alpha_composite(queen, (x, y))

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(OUTPUT, optimize=True)
    print(f"{OUTPUT}: {len(chosen)} distinct queens, {WIDTH}x{HEIGHT}")


if __name__ == "__main__":
    main()
