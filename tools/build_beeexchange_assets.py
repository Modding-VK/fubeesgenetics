#!/usr/bin/env python3
"""Draw only the native Auto Refugee sign; machine sprite/animations come directly from FU."""
from pathlib import Path
from ui_theme import Surface

ROOT = Path(__file__).resolve().parents[1]
OBJECT = ROOT/'FUBeesGenetics/objects/bees/fubeesgenetics/beeexchange'
FONT = {
    'A':['010','101','111','101','101'], 'U':['101','101','101','101','111'],
    'T':['111','010','010','010','010'], 'O':['111','101','101','101','111'],
    'R':['110','101','110','101','101'], 'E':['111','100','110','100','111'],
    'F':['111','100','110','100','100'], 'G':['111','100','101','101','111']
}


def build():
    sign = Surface(64,80)
    sign.rect(18,30,58,45,'6e451e')
    sign.rect(19,31,57,44,'d99224')
    sign.rect(20,31,56,43,'f4bb42')
    for cx in [22,55]:
        for cy in [33,40]:
            for dx,dy in [(-1,-2),(0,-2),(-2,-1),(1,-1),(-2,0),(1,0),(-1,1),(0,1)]:
                sign.pixel(cx+dx,cy+dy,'de9b24')
    for word,x,y in [('AUTO',31,32),('REFUGEE',25,38)]:
        for letter in word:
            for row,line in enumerate(FONT[letter]):
                for col,pixel in enumerate(line):
                    if pixel=='1':sign.pixel(x+col,y+row,'39240f')
            x+=4
    (OBJECT/'autorefugee-plaque.png').write_bytes(sign.png())
    print('Built transparent 64x80 Auto Refugee sign overlay; original FU sprite/animation retained.')


if __name__ == '__main__':
    build()
