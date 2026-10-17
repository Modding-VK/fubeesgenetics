#!/usr/bin/env python3
"""Build approved glass machine with native vanilla casing and native display.
Requires Pillow and pinned reference cache from tools/run_checks.py --fetch.
"""
from PIL import Image,ImageDraw
from pathlib import Path
r=Path(__file__).resolve().parents[1];d=r/'FUBeesGenetics/objects/bees/fubeesgenetics/beeexchange';s=Image.open(r/'.cache/ui-reference/starbound/assets/packed/objects/generic/cropshipper/cropshipper.png').convert('RGBA');native=s.crop((128,0,192,80));old=Image.open(r/'artwork/proposals/auto-refugee-work-v1/static.png').convert('RGBA');base=native.copy()
base.paste((0,0,0,0),(0,0,64,28))
# One vanilla-shaped plate: keep its original bezel and replace only its print.
base.paste(old.crop((17,53,48,68)),(17,53,48,68))
ImageDraw.Draw(base).rectangle((19,30,58,44),fill='#f4bb42')
base.paste(old.crop((20,31,57,44)),(20,31,57,44))
# Remove the abandoned top rail stub next to the plate and close the two pinholes.
for y in [28]:
 for x in range(10,16):base.putpixel((x,y),(0,0,0,0))
base.putpixel((9,31),native.getpixel((10,31)))
base.putpixel((8,32),native.getpixel((8,33)))
# Rebuild the glass under the old rod, then shorten the rod by two pixels.
for y in range(60,66):
 left,right=base.getpixel((30,y)),base.getpixel((35,y))
 for x in range(31,35):
  t=(x-30)/5
  base.putpixel((x,y),tuple(round(left[c]*(1-t)+right[c]*t) for c in range(4)))
base.paste(old.crop((31,60,35,64)),(31,62,35,66))
# Rebuild moving layers from the approved source, translated down exactly 2px.
for layer_name in ['specimen','teleport']:
 source=Image.open(r/'artwork/proposals/auto-refugee-work-v1'/(layer_name+'.png')).convert('RGBA')
 moved=Image.new('RGBA',source.size);moved.paste(source,(0,2))
 moved.save(d/(layer_name+'.png'))
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
a['animatedParts']['parts']['display']={'properties':{'centered':False,'zLevel':3,'fullbright':True},'partStates':{'machine':{state:{'properties':{'image':'display<facingSuffix>.png:'+state+'.<frame>'}} for state in ['ready','work']}}}
(d/'beeexchange.animation').write_text(json.dumps(a,indent=2)+'\n')
# Preview with native glow and unchanged insect/teleport layers.
sp=Image.open(d/'specimen.png').convert('RGBA');fx=Image.open(d/'teleport.png').convert('RGBA');frames=[]
for i in range(22):
 f=base.copy();j=0 if i<2 else i-1
 for layer in [sp,fx]:f.alpha_composite(layer.crop((j*64,0,(j+1)*64,80)))
 f.alpha_composite(sheet.crop((i*64,0,(i+1)*64,80)));bg=Image.new('RGBA',(64,80),'#344451');bg.alpha_composite(f);frames.append(bg.convert('RGB').resize((384,480),Image.Resampling.NEAREST))
out=r/'artwork/implemented';frames[0].save(out/'beeexchange-0.2.8.png');seq=[frames[i%2] for i in range(10)]+frames[2:]+[frames[i%2] for i in range(10)];seq[0].save(out/'beeexchange-0.2.8.gif',save_all=True,append_images=seq[1:],duration=65,loop=0)

# Engine mirrors objects facing left. Compensate only lettering and display glyphs
# in dedicated runtime textures, while the casing/LEDs/insect mirror normally.
left_base=base.copy()
for word_box in [(31,32,46,37),(25,38,52,43)]:
 left_base.paste(base.crop(word_box).transpose(Image.Transpose.FLIP_LEFT_RIGHT),word_box)
left_base.save(d/'static-left.png')
left_display=sheet.copy()
for i in range(22):
 glyph_box=(i*64+28,71,i*64+44,75)
 left_display.paste((0,0,0,0),(i*64+28,71,i*64+46,75))
 left_display.alpha_composite(sheet.crop(glyph_box).transpose(Image.Transpose.FLIP_LEFT_RIGHT),(i*64+30,71))
for i in range(22):
 # After the engine's whole-frame flip, the display glyph has its original
 # orientation inside the reflected display housing, for every animation frame.
 original_box=(i*64+28,71,i*64+44,75)
 shifted_box=(i*64+30,71,i*64+46,75)
 actual=left_display.crop(shifted_box).transpose(Image.Transpose.FLIP_LEFT_RIGHT)
 expected=sheet.crop(original_box)
 for yy in range(4):
  for xx in range(16):
   a,b=actual.getpixel((xx,yy)),expected.getpixel((xx,yy))
   assert a==b or a[3]==b[3]==0
left_display.save(d/'display-left.png')
(d/'display-left.frames').write_bytes((d/'display.frames').read_bytes())
# Placement uses already oriented, fully lit ready images; it does not run Lua.
right_placement=base.copy();right_placement.alpha_composite(sheet.crop((0,0,64,80)))
left_placement=left_base.copy();left_placement.alpha_composite(left_display.crop((0,0,64,80)))
left_placement=left_placement.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
right_placement.save(d/'placement-right.png');left_placement.save(d/'placement-left.png')
# Exact native renderer compensation: full 64px canvas mirrors around x=32px.
assert left_placement.tobytes()!=right_placement.transpose(Image.Transpose.FLIP_LEFT_RIGHT).tobytes()
for word_box in [(31,32,46,37),(25,38,52,43)]:
 left_box=(64-word_box[2],word_box[1],64-word_box[0],word_box[3])
 assert left_placement.crop(left_box).tobytes()==right_placement.crop(word_box).tobytes()
# Review both directions and all work frames with the same layer order as the engine.
review=[]
for i in range(22):
 pair=Image.new('RGBA',(128,80),'#344451')
 for is_left in [False,True]:
  f=(left_base if is_left else base).copy();j=0 if i<2 else i-1
  for layer in [sp,fx]:f.alpha_composite(layer.crop((j*64,0,(j+1)*64,80)))
  atlas=left_display if is_left else sheet
  f.alpha_composite(atlas.crop((i*64,0,(i+1)*64,80)))
  if is_left:f=f.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
  pair.alpha_composite(f,(0 if is_left else 64,0))
 review.append(pair.convert('RGB').resize((768,480),Image.Resampling.NEAREST))
review[0].save(out/'beeexchange-0.2.8-directions.png')
seq=[review[i%2] for i in range(10)]+review[2:]+[review[i%2] for i in range(10)]
seq[0].save(out/'beeexchange-0.2.8-directions.gif',save_all=True,append_images=seq[1:],duration=65,loop=0)
