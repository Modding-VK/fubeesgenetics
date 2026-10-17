#!/usr/bin/env python3
"""Build approved glass machine with native vanilla casing and native display.
Requires Pillow and pinned reference cache from tools/run_checks.py --fetch.
"""
from PIL import Image,ImageDraw
from pathlib import Path
r=Path(__file__).resolve().parents[1];d=r/'FUBeesGenetics/objects/bees/fubeesgenetics/beeexchange';s=Image.open(r/'.cache/ui-reference/starbound/assets/packed/objects/generic/cropshipper/cropshipper.png').convert('RGBA');native=s.crop((128,0,192,80));old=Image.open(r/'artwork/proposals/auto-refugee-work-v1/static.png').convert('RGBA');base=native.copy()
base.paste((0,0,0,0),(0,0,64,28))
# Approved sign and transparent glass/rod are preserved pixel for pixel.
for box in [(16,28,61,47),(17,53,48,68)]:base.paste(old.crop(box),box)
# Vanilla casing has clean panels and both native side LEDs. Keep their original
# geometry and positions; the fullbright layer below owns their state colors.
# Remove the baked-in cyan check; only the animated display owns its lit pixels.
for y in range(72,75):
 for x in range(28,44):
  color=base.getpixel((x,y))
  if color[2]>color[0]+40:base.putpixel((x,y),(48,48,48,255))
base.save(d/'static.png')
# Native fullbright display crop: ready cyan pulse and work upward arrow.
light=Image.open(r/'.cache/ui-reference/starbound/assets/packed/objects/generic/cropshipper/cropshipperfullbright.png').convert('RGBA')
box=(27,70,44,76);sheet=Image.new('RGBA',(64*22,80));names=['ready.1','ready.2']+['work.'+str(i) for i in range(1,21)]
for i,name in enumerate(names):
 idx=2+i if i<2 else (8+min(18,round((i-2)*18/19)))
 frame=Image.new('RGBA',(64,80));frame.paste(light.crop((idx*64+box[0],box[1],idx*64+box[2],box[3])),box)
 # Copy BOTH LEDs, pixel for pixel, from the native light atlas.
 for led_box in [(7,38,11,46),(7,57,11,65)]:
  frame.paste(light.crop((idx*64+led_box[0],led_box[1],idx*64+led_box[2],led_box[3])),led_box)
 sheet.paste(frame,(64*i,0))
sheet.save(d/'display.png')
import json
(d/'display.frames').write_text(json.dumps({'frameGrid':{'size':[64,80],'dimensions':[22,1],'names':[names]}},indent=2)+'\n')
a=json.loads((d/'beeexchange.animation').read_text());a['animatedParts']['stateTypes']['machine']['states']['ready']['frames']=2;a['animatedParts']['stateTypes']['machine']['states']['ready']['cycle']=0.2
for part in ['specimen','teleport']:a['animatedParts']['parts'][part]['partStates']['machine']['ready']['properties']['image']=part+'.png:ready.1'
a['animatedParts']['parts']['display']={'properties':{'centered':False,'zLevel':3,'fullbright':True},'partStates':{'machine':{state:{'properties':{'image':'display.png:'+state+'.<frame>'}} for state in ['ready','work']}}}
(d/'beeexchange.animation').write_text(json.dumps(a,indent=2)+'\n')
# Preview with native glow and unchanged insect/teleport layers.
sp=Image.open(d/'specimen.png').convert('RGBA');fx=Image.open(d/'teleport.png').convert('RGBA');frames=[]
for i in range(22):
 f=base.copy();j=0 if i<2 else i-1
 for layer in [sp,fx]:f.alpha_composite(layer.crop((j*64,0,(j+1)*64,80)))
 f.alpha_composite(sheet.crop((i*64,0,(i+1)*64,80)));bg=Image.new('RGBA',(64,80),'#344451');bg.alpha_composite(f);frames.append(bg.convert('RGB').resize((384,480),Image.Resampling.NEAREST))
out=r/'artwork/implemented';frames[0].save(out/'beeexchange-0.2.6.png');seq=[frames[i%2] for i in range(10)]+frames[2:]+[frames[i%2] for i in range(10)];seq[0].save(out/'beeexchange-0.2.6.gif',save_all=True,append_images=seq[1:],duration=65,loop=0)
