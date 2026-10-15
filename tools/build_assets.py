#!/usr/bin/env python3
"""Preserve recovered machine pixels and build the approved native HUD theme."""
import json
from pathlib import Path
import shutil
from ui_theme import build

ROOT = Path(__file__).resolve().parents[1]
OBJECT = ROOT/'FUBeesGenetics/objects/bees/fubeesgenetics/geneticqueenfilter'
UI = ROOT/'FUBeesGenetics/interface/fubeesgenetics/geneticqueenfilter'


def main():
    # These are archived MVP pixels, not a recreation of the unavailable approved sprite.
    shutil.copyfile(ROOT/'artwork/machine-recovered.png', OBJECT/'geneticqueenfilter.png')
    shutil.copyfile(ROOT/'artwork/icon-recovered.png', OBJECT/'geneticqueenfiltericon.png')
    layout = json.loads((ROOT/'artwork/interface-layout.json').read_text())
    build(ROOT, UI)
    (UI/'fubeesgenetics_geneticqueenfilter.config').write_text(json.dumps(layout,ensure_ascii=False,indent=2)+'\n')
    print('Preserved machine/icon; built native 388x332 HUD, controls and UI config.')


if __name__ == '__main__':
    main()
