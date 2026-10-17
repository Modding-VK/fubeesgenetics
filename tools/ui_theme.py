"""Render native pixel UI primitives; no bitmap mockup or FU assets are resampled."""
import json
import math
from pathlib import Path
import struct
import zlib


class Surface:
    def __init__(self, width, height):
        self.width, self.height = width, height
        self.pixels = bytearray(width * height * 4)

    def pixel(self, x, y, color):
        if 0 <= x < self.width and 0 <= y < self.height:
            color = bytes.fromhex(color.lstrip('#'))
            if len(color) == 3:
                color += b'\xff'
            offset = (y * self.width + x) * 4
            self.pixels[offset:offset + 4] = color

    def rect(self, x0, y0, x1, y1, color, cut=0):
        # Inclusive bounds, stepped clipped corners, no anti-aliasing.
        for y in range(y0, y1 + 1):
            inset = max(0, cut - min(y - y0, y1 - y))
            for x in range(x0 + inset, x1 - inset + 1):
                self.pixel(x, y, color)

    def line(self, x0, y0, x1, y1, color):
        distance = max(abs(x1 - x0), abs(y1 - y0))
        if not distance:
            self.pixel(x0, y0, color)
        else:
            for i in range(distance + 1):
                self.pixel(round(x0 + (x1 - x0) * i / distance),
                           round(y0 + (y1 - y0) * i / distance), color)

    def png(self, top=0, height=None):
        height = self.height - top if height is None else height
        stride = self.width * 4
        raw = b''.join(b'\x00' + self.pixels[y * stride:(y + 1) * stride]
                       for y in range(top, top + height))
        def chunk(kind, data):
            return (struct.pack('>I', len(data)) + kind + data
                    + struct.pack('>I', zlib.crc32(kind + data) & 0xffffffff))
        return (b'\x89PNG\r\n\x1a\n'
                + chunk(b'IHDR', struct.pack('>IIBBBBB', self.width, height, 8, 6, 0, 0, 0))
                + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))


def theme_assets(root):
    spec = json.loads((Path(root) / 'artwork/ui-theme.json').read_text())
    p = spec['palette']
    w, h = spec['size']
    frame = Surface(w, h)
    for inset, cut, color in [(0, 8, p['edge']), (1, 7, p['metalLight']),
                              (2, 6, p['metal']), (4, 5, p['metalShade']),
                              (5, 5, p['edge']), (6, 5, p['blueLine']),
                              (7, 5, p['panel'])]:
        frame.rect(inset, inset, w-1-inset, h-1-inset, color, cut)
    for y in range(9, h-9, 2):
        frame.line(9, y, w-10, y, p['scanline'])
    # Brushed metal top and bottom rails with warm safety accents.
    frame.line(12, 2, w-13, 2, p['metalLight'])
    frame.line(14, h-3, w-15, h-3, p['metalLight'])
    for y in [80, 174, 266]:
        for x in [1, w-5]:
            frame.rect(x, y, x+3, y+15, p['amberShade'])
            frame.rect(x, y, x+2, y+2, p['amber'])
    frame.rect(w-62, 1, w-12, 4, p['amberShade'])
    frame.line(w-60, 1, w-12, 1, p['amber'])
    frame.line(w-126, h-5, w-122, h-9, p['amber'])
    frame.line(w-122, h-5, w-118, h-9, p['amber'])
    for y in [18, 153, h-21]:
        for x in [2, w-4]:
            frame.rect(x, y, x+1, y+2, p['edge'])
            frame.pixel(x, y, p['metalLight'])
    # Fine circuits stay entirely in the margin, outside text and hit regions.
    for x, direction in [(10, 1), (w-11, -1)]:
        for y in [62, 106, 150, 194, 238]:
            frame.line(x, y, x, y+18, p['circuit'])
            frame.line(x, y+18, x+3*direction, y+21, p['circuit'])
            frame.line(x+3*direction, y+21, x+3*direction, y+27, p['circuit'])
    # One header, one table, no decorative controls or text in the background.
    frame.line(10, 33, w-11, 33, p['blueLine'])
    frame.line(10, 34, w-11, 34, p['circuit'])
    frame.rect(14, 77, w-15, 105, p['blueLine'])
    frame.rect(15, 78, w-16, 104, p['header'])
    for y in range(79, 105, 2):
        frame.line(16, y, w-17, y, p['scanline'])
    for y in spec['rowRules']:
        frame.line(18, y, w-19, y, p['circuit'])
    frame.line(18, 301, w-19, 301, p['circuit'])
    result = {'header.png': frame.png(0, 34), 'body.png': frame.png(34, 286),
              'footer.png': frame.png(320, 12)}

    # Explicit pixel arrows avoid reliance on Unicode glyphs in game fonts.
    for name, down in [('arrowup', False), ('arrowdown', True)]:
        arrow = Surface(7, 7)
        for y in range(7):
            for x in range(7):
                if (y <= 3 and abs(x-3) <= y) or (y >= 3 and 2 <= x <= 4):
                    arrow.pixel(x, 6-y if down else y, p['cyan'])
        result[name+'.png'] = arrow.png()

    for name, fill in [('reset', p['button']), ('resethover', p['buttonHover']),
                       ('resetpress', p['buttonPressed'])]:
        button = Surface(100, 20)
        button.rect(0, 0, 99, 19, p['edge'], 3)
        button.rect(1, 1, 98, 18, p['metalLight'], 2)
        button.rect(2, 2, 97, 17, p['metalShade'], 1)
        button.rect(3, 3, 96, 16, fill, 1)
        button.line(5, 3, 94, 3, p['metal'])
        result[name+'.png'] = button.png()

    for name, selected, hover in [('radio', False, False), ('radiohover', False, True),
                                   ('radiochecked', True, False), ('radiocheckedhover', True, True)]:
        radio = Surface(18, 18)
        radio.rect(3, 3, 14, 14, p['edge'], 3)
        radio.rect(4, 3, 13, 14, p['metalLight'] if hover else p['metal'], 2)
        radio.rect(5, 4, 12, 13, p['metalShade'], 2)
        radio.rect(5, 5, 12, 12, p['panel'], 2)
        if selected:
            radio.rect(6, 6, 11, 11, p['cyan'], 1)
            radio.line(7, 6, 10, 6, p['cyanLight'])
        elif hover:
            radio.rect(6, 6, 11, 11, p['circuit'], 1)
        result[name+'.png'] = radio.png()

    for name, accent in [('approvedslot', p['approved']), ('inputslot', p['cyan']),
                          ('rejectedslot', p['rejected'])]:
        slot = Surface(24, 24)
        slot.rect(0, 0, 23, 23, p['edge'], 3)
        slot.rect(1, 1, 22, 22, p['metalLight'], 2)
        slot.rect(2, 2, 21, 21, p['metalShade'], 1)
        slot.rect(3, 3, 20, 20, p['panel'])
        for y in range(4, 21, 2):
            slot.line(4, y, 19, y, p['scanline'])
        slot.rect(7, 21, 16, 22, accent)
        result[name+'.png'] = slot.png()

    for name, hover in [('close', False), ('closehover', True)]:
        close = Surface(12, 12)
        close.rect(0, 0, 11, 11, p['blueLine'], 1)
        close.rect(1, 1, 10, 10, p['header'], 1)
        color = p['amber'] if hover else p['text']
        for dx in [0, 1]:
            close.line(3+dx, 3, 7+dx, 7, color)
            close.line(3+dx, 7, 7+dx, 3, color)
        result[name+'.png'] = close.png()

    dna = Surface(20, 20)
    dna.rect(0, 0, 19, 19, p['amberShade'], 1)
    dna.rect(1, 1, 18, 18, p['amber'], 1)
    dna.rect(2, 2, 17, 17, p['header'])
    for y in range(4, 16):
        offset = round(4 * math.cos((y-4) * math.pi / 6))
        x1, x2 = 9+offset, 10-offset
        if y % 3 == 1:
            dna.line(min(x1, x2), y, max(x1, x2), y, p['metalShade'])
        dna.pixel(x1, y, p['cyan'])
        dna.pixel(x2, y, p['amber'])
    result['dna.png'] = dna.png()
    return result


def build(root, destination):
    destination = Path(destination)
    destination.mkdir(parents=True, exist_ok=True)
    for name, payload in theme_assets(root).items():
        (destination / name).write_bytes(payload)
