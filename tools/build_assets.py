#!/usr/bin/env python3
"""Reproduce recovered native art and corrected GUI without resampling or redrawing."""
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
OBJECT = ROOT/'FUBeesGenetics/objects/bees/fubeesgenetics/geneticqueenfilter'
UI = ROOT/'FUBeesGenetics/interface/fubeesgenetics/geneticqueenfilter'


def main():
    # These are archived MVP pixels, not a recreation of the unavailable approved sprite.
    shutil.copyfile(ROOT/'artwork/machine-recovered.png', OBJECT/'geneticqueenfilter.png')
    shutil.copyfile(ROOT/'artwork/icon-recovered.png', OBJECT/'geneticqueenfiltericon.png')
    layout = json.loads((ROOT/'artwork/interface-layout.json').read_text())
    (UI/'fubeesgenetics_geneticqueenfilter.config').write_text(json.dumps(layout,ensure_ascii=False,indent=2)+'\n')
    print('Restored archived 40x32 sprite, 20x20 icon and corrected UI config; no pixel edits.')


if __name__ == '__main__':
    main()
