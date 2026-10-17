#!/usr/bin/env python3
"""Keep the native item icon, using the approved gold plaque and empty glass chamber."""
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
source=Image.open(ROOT/'.cache/ui-reference/starbound/assets/packed/objects/generic/cropshipper/cropshippericon.png').convert('RGBA')
icon=source.copy()
for y in range(16):
 for x in range(16):
  if source.getpixel((x,y))==(109,37,26,255):icon.putpixel((x,y),(244,187,66,255))
# Four-by-three native icon chamber: darker side pane, cyan transparent front,
# bright reflection and a bare one-pixel mount. No wood colors remain here.
for y in range(8,11):
 for x in range(7,11):
  icon.putpixel((x,y),(40,139,172,190) if x==7 else (116,207,239,185))
icon.putpixel((8,8),(207,248,255,225))
icon.putpixel((10,8),(164,238,250,205))
icon.putpixel((9,10),(70,108,130,255))
assert icon.size==(16,16)
icon.save(ROOT/'FUBeesGenetics/objects/bees/fubeesgenetics/beeexchange/beeexchangeicon.png')
bg=Image.new('RGBA',(16,16),'#344451');bg.alpha_composite(icon)
bg.resize((256,256),Image.Resampling.NEAREST).save(ROOT/'artwork/implemented/beeexchange-0.2.10-icon.png')
