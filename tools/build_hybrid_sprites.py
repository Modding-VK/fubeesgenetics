#!/usr/bin/env python3
"""Generate one three-caste sprite sheet for every hybrid bee species.

The parents' opaque silhouettes are united, preserving appendages found in
either source. Shared pixels blend parental colors; local edge/detail contrast
shifts the blend toward the parent with the stronger feature. Parent-only
pixels retain their source color with a small tint from the other palette.
"""
import argparse
import hashlib
import io
from pathlib import Path

from PIL import Image, ImageDraw

from run_checks import ROOT, MANIFEST, asset_json

SIZE = (84, 28)
FRAME_WIDTH = 28
OUT = ROOT / 'FUBeesGenetics/bees/bees'
PREVIEW = ROOT / 'artwork/hybrids/preview.png'
PREVIEW_IDS = (
    'hybrid_carpenter_honey', 'hybrid_crystalwing_honey', 'hybrid_cybernetic_stellar',
    'hybrid_assassin_orchid', 'hybrid_aquarum_scoria', 'hybrid_gelidburrower_goldensaint',
    'hybrid_cuckoo_reaper', 'hybrid_exspiravit_rimewing', 'hybrid_artisan_mason',
    'hybrid_harlequin_tunguskudae', 'hybrid_bumblebee_xenodaemonae',
    'hybrid_inventor_shrouded'
)


def source_image(fu_root, family):
    relative = f'bees/bees/{family}.png'
    path = fu_root / relative
    payload = path.read_bytes()
    actual = hashlib.sha1(b'blob ' + str(len(payload)).encode() + b'\0' + payload).hexdigest()
    if actual != MANIFEST['files'][relative]:
        raise ValueError(f'FU parent sprite changed: {relative}')
    image = Image.open(io.BytesIO(payload)).convert('RGBA')
    if image.size != SIZE:
        raise ValueError(f'Unexpected sprite size: {relative} {image.size}')
    return image


def mean_palette(image, frame):
    pixels = image.load()
    colors = [pixels[x, y][:3] for x in range(frame * FRAME_WIDTH, (frame + 1) * FRAME_WIDTH)
              for y in range(SIZE[1]) if pixels[x, y][3] > 0]
    if not colors:
        raise ValueError('Empty source frame')
    return tuple(sum(color[channel] for color in colors) // len(colors) for channel in range(3))


def detail(image, x, y, frame):
    pixels = image.load()
    red, green, blue, alpha = pixels[x, y]
    if alpha == 0:
        return 0
    luminance = (red * 3 + green * 4 + blue) // 8
    difference = 0
    for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
        if frame * FRAME_WIDTH <= nx < (frame + 1) * FRAME_WIDTH and 0 <= ny < SIZE[1]:
            nr, ng, nb, na = pixels[nx, ny]
            if na:
                difference += abs(luminance - (nr * 3 + ng * 4 + nb) // 8)
    return difference


def mix(first, second, first_weight):
    return tuple(round(a * first_weight + b * (1 - first_weight))
                 for a, b in zip(first, second))


def fuse(first, second):
    output = Image.new('RGBA', SIZE)
    a, b, result = first.load(), second.load(), output.load()
    palettes_a = [mean_palette(first, frame) for frame in range(3)]
    palettes_b = [mean_palette(second, frame) for frame in range(3)]
    for y in range(SIZE[1]):
        for x in range(SIZE[0]):
            color_a, color_b = a[x, y], b[x, y]
            alpha_a, alpha_b = color_a[3], color_b[3]
            if not alpha_a and not alpha_b:
                continue
            frame = x // FRAME_WIDTH
            if alpha_a and alpha_b:
                contrast_a, contrast_b = detail(first, x, y, frame), detail(second, x, y, frame)
                # Retain both parent palettes while carrying their small
                # stripes, wing veins, shadows and highlights into the child.
                weight = .5 + .18 * (contrast_a - contrast_b) / (contrast_a + contrast_b + 1)
                rgb = mix(color_a[:3], color_b[:3], weight)
                result[x, y] = (*rgb, max(alpha_a, alpha_b))
            elif alpha_a:
                result[x, y] = (*mix(color_a[:3], palettes_b[frame], .86), alpha_a)
            else:
                result[x, y] = (*mix(color_b[:3], palettes_a[frame], .86), alpha_b)
    return output


def build_preview(sprites):
    preview = Image.new('RGBA', (1080, 600), '#171722')
    draw = ImageDraw.Draw(preview)
    for index, species_id in enumerate(PREVIEW_IDS):
        x, y = (index % 3) * 360, (index // 3) * 150
        draw.rectangle((x + 4, y + 4, x + 355, y + 145), outline='#56526a', width=1)
        sheet = sprites[species_id].resize((336, 112), Image.Resampling.NEAREST)
        preview.alpha_composite(sheet, (x + 12, y + 8))
        label = species_id.removeprefix('hybrid_').replace('_', ' + ').title()
        draw.text((x + 12, y + 124), label, fill='#f0e6c9')
    return preview


def generate_sprites(fu_root, check=False):
    catalog = asset_json((ROOT / 'docs/HYBRID_SPECIES_CATALOG.json').read_text())
    pairs = [(species['id'], *species['parentFamilies']) for species in catalog['hybrids']]
    families = {family for _, a, b in pairs for family in (a, b)}
    originals = {family: source_image(fu_root, family) for family in families}
    expected = set()
    signatures = set()
    preview_sprites = {}
    for species_id, a, b in pairs:
        path = OUT / f'{species_id}.png'
        expected.add(path)
        sprite = fuse(originals[a], originals[b])
        signature = hashlib.sha256(sprite.tobytes()).digest()
        if signature in signatures:
            raise ValueError(f'Duplicate hybrid appearance: {species_id}')
        signatures.add(signature)
        if species_id in PREVIEW_IDS:
            preview_sprites[species_id] = sprite
        if check:
            actual = Image.open(path).convert('RGBA')
            if actual.size != SIZE or actual.tobytes() != sprite.tobytes():
                raise ValueError(f'Stale hybrid sprite: {path}')
        else:
            sprite.save(path, optimize=True)
    extras = set(OUT.glob('hybrid_*_*.png')) - expected
    if extras:
        raise ValueError(f'Unexpected hybrid sprite files: {sorted(extras)[:3]}')
    preview = build_preview(preview_sprites)
    if check:
        actual = Image.open(PREVIEW).convert('RGBA')
        if actual.size != preview.size or actual.tobytes() != preview.tobytes():
            raise ValueError(f'Stale hybrid preview: {PREVIEW}')
    else:
        PREVIEW.parent.mkdir(parents=True, exist_ok=True)
        preview.save(PREVIEW, optimize=True)
    print(f'Hybrid sprites: {len(expected)} unique sheets; ' + ('verified' if check else 'generated'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--fu-root', type=Path, default=ROOT / '.cache/fu')
    parser.add_argument('--check', action='store_true', help='Compare committed sprites pixel by pixel')
    args = parser.parse_args()
    generate_sprites(args.fu_root, args.check)


if __name__ == '__main__':
    main()
