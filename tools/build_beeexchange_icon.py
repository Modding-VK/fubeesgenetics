#!/usr/bin/env python3
"""Keep the native item icon, recoloring its plate to the approved furniture gold."""
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
source=Image.open(ROOT/'.cache/ui-reference/starbound/assets/packed/objects/generic/cropshipper/cropshippericon.png').convert('RGBA')
icon=source.copy()
for y in range(16):
 for x in range(16):
  if source.getpixel((x,y))==(109,37,26,255):icon.putpixel((x,y),(244,187,66,255))
assert icon.size==(16,16)
icon.save(ROOT/'FUBeesGenetics/objects/bees/fubeesgenetics/beeexchange/beeexchangeicon.png')
bg=Image.new('RGBA',(16,16),'#344451');bg.alpha_composite(icon)
bg.resize((256,256),Image.Resampling.NEAREST).save(ROOT/'artwork/implemented/beeexchange-0.2.9-icon.png')
