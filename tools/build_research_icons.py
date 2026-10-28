"""Build the three 16 px FU Agriculture research icons."""
from io import BytesIO
from pathlib import Path
import sys
from PIL import Image, ImageDraw
out=Path(__file__).resolve().parent.parent/'FUBeesGenetics/zb/researchTree/fubeesgenetics'

def icon(name, paint):
    im=Image.new('RGBA',(16,16),(0,0,0,0));paint(ImageDraw.Draw(im))
    data=BytesIO();im.save(data,format='PNG');target=out/name
    if '--check' in sys.argv:
        assert target.read_bytes()==data.getvalue(), target
    else:
        target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data.getvalue())

GOLD='#f4bb42'; PALE='#ffe398'; DARK='#3b2b29'; CYAN='#5bd3e5'; GREEN='#79d66a'; RED='#ed756e'

def industrial(d):
    # Bee above a sorting fork with two distinct exits.
    d.polygon([(3,2),(5,1),(7,3),(6,5),(3,5),(2,4)],fill=PALE)
    d.polygon([(9,3),(11,1),(13,2),(14,4),(12,5),(9,5)],fill=PALE)
    d.polygon([(5,4),(10,4),(11,6),(10,8),(5,8),(4,6)],fill=GOLD,outline=DARK)
    d.line((7,4,7,8),fill=DARK,width=1)
    d.line((9,4,9,8),fill=DARK,width=1)
    d.point((5,5),fill='#20252b')
    d.line((7,9,7,10),fill=CYAN,width=1)
    d.line((3,10,12,10),fill=CYAN,width=1)
    d.line((3,10,3,12),fill=CYAN,width=1)
    d.line((12,10,12,12),fill=CYAN,width=1)
    d.rectangle((1,12,5,14),fill='#304733')
    d.rectangle((2,12,4,13),fill=GREEN)
    d.rectangle((10,12,14,14),fill='#614635')
    d.rectangle((11,12,13,13),fill=GOLD)

def abusive(d):
    # Large honeycomb and a harsh bolt driven into it.
    d.polygon([(1,5),(4,3),(7,5),(7,10),(4,12),(1,10)],fill='#6b412a',outline='#e1a54c')
    d.polygon([(2,6),(4,5),(6,6),(6,9),(4,10),(2,9)],fill='#e9ad50')
    d.rectangle((3,6,4,7),fill='#4c3328')
    d.point((4,8),fill='#4c3328')
    d.polygon([(11,1),(7,8),(10,8),(8,15),(15,6),(12,6),(14,1)],fill='#8a3242')
    d.polygon([(11,2),(9,7),(11,7),(9,13),(13,6),(11,6),(12,2)],fill='#ffd65f')
    d.line((11,2,9,7,11,7),fill='#fff1a0',width=1)

def unethical(d):
    # Two mismatched DNA strands, linked and marked with a warning.
    left=[(3,1),(5,3),(7,5),(7,7),(5,9),(3,11),(3,14)]
    right=[(9,1),(7,3),(5,5),(5,7),(7,9),(9,11),(9,14)]
    d.line(left,fill='#58d2dc',width=2,joint='curve')
    d.line(right,fill='#e37ac8',width=2,joint='curve')
    for y,x1,x2 in [(2,4,8),(5,5,7),(8,5,7),(11,4,8),(14,3,9)]:
        d.line((x1,y,x2,y),fill='#e9d7bb',width=1)
    d.polygon([(12,8),(15,14),(9,14)],fill='#542b33',outline='#f3b052')
    d.line((12,10,12,12),fill='#fff1b0',width=1)
    d.point((12,13),fill='#fff1b0')

for name,fn in [('industrial_beekeeping.png',industrial),('abusive_apiaries.png',abusive),('unethical_genetics.png',unethical)]:icon(name,fn)
