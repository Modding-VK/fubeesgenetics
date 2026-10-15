#!/usr/bin/env python3
"""Draw the Bee Exchange sprite and compact native container pane."""
from pathlib import Path
from ui_theme import Surface
ROOT = Path(__file__).resolve().parents[1]
OBJECT = ROOT/'FUBeesGenetics/objects/bees/fubeesgenetics/beeexchange'
UI = ROOT/'FUBeesGenetics/interface/fubeesgenetics/beeexchange'


def build():
    sprite = Surface(48,40)
    sprite.rect(0,0,47,39,'18232d',3)
    sprite.rect(1,1,46,38,'627b89',3)
    sprite.rect(3,3,44,36,'263d50',2)
    sprite.rect(6,5,41,32,'102330',2)
    sprite.rect(8,7,39,30,'32627b',2)
    sprite.rect(10,9,37,28,'153342',2)
    # Receiving cage and outbound teleporter, separated by a gold chevron.
    sprite.rect(12,12,20,25,'c5d0b0',1)
    for x in [14,17,20]: sprite.rect(x,12,x,25,'5b7466')
    for y in [14,18,22]: sprite.rect(13,y,19,y,'d7af49')
    for y in range(15,23):
        x=24+min(y-15,22-y)
        sprite.pixel(x,y,'f1cc63');sprite.pixel(x+1,y,'f1cc63')
    sprite.rect(33,13,35,24,'74c7c0')
    sprite.rect(4,34,43,35,'d6ac4e')
    sprite.rect(4,4,43,5,'627b89')
    for x in [5,40]:
        sprite.rect(x,7,x+2,9,'b8c6cc');sprite.rect(x,29,x+2,31,'b8c6cc')
    (OBJECT/'beeexchange.png').write_bytes(sprite.png())
    icon=Surface(20,20)
    icon.rect(0,0,19,19,'18232d',2);icon.rect(1,1,18,18,'627b89',2)
    icon.rect(3,3,16,16,'153342',1);icon.rect(4,4,15,5,'d6ac4e')
    for x in [5,8]:icon.rect(x,7,x,13,'d7af49')
    for y in range(7,14):icon.pixel(11+min(y-7,13-y),y,'74c7c0')
    (OBJECT/'beeexchangeicon.png').write_bytes(icon.png())
    pane=Surface(260,180)
    pane.rect(0,0,259,179,'131c25',5);pane.rect(1,1,258,178,'718594',4)
    pane.rect(3,3,256,176,'283e50',3);pane.rect(5,5,254,174,'172936',2)
    pane.rect(7,29,252,30,'c5a64f');pane.rect(7,144,252,145,'466b82')
    # Plain native grid; its backing and icons share the engine's 19px geometry.
    for name,top,height in [('header',0,30),('body',30,138),('footer',168,12)]:
        (UI/(name+'.png')).write_bytes(pane.png(top,height))
    print('Built Bee Exchange 48x40 sprite, 20x20 icon and 260x180 pane.')


if __name__ == '__main__':
    build()
