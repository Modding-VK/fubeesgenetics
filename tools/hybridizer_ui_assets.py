"""Build the compact Hybridizer frame from the shared UI palette and artwork."""
import json
import subprocess
from pathlib import Path
from tempfile import TemporaryDirectory

from ui_theme import Surface, hex_badge


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "artwork/ui/hybridizer"
OUTPUT = ROOT / "FUBeesGenetics/interface/fubeesgenetics/hybridizer"
PALETTE = json.loads((ROOT / "artwork/ui-theme.json").read_text())["palette"]
WIDTH, HEIGHT = 270, 165


def frame():
    p = PALETTE
    canvas = Surface(WIDTH, HEIGHT)
    for inset, cut, color in [(0, 8, p["edge"]), (1, 7, p["metalLight"]),
                              (2, 6, p["metal"]), (4, 5, p["metalShade"]),
                              (5, 5, p["edge"]), (6, 5, p["blueLine"]),
                              (7, 5, p["panel"])]:
        canvas.rect(inset, inset, WIDTH - inset - 1, HEIGHT - inset - 1,
                    color, cut)
    for y in range(9, HEIGHT - 9, 2):
        canvas.line(9, y, WIDTH - 10, y, p["scanline"])
    canvas.line(12, 2, WIDTH - 13, 2, p["metalLight"])
    canvas.line(14, HEIGHT - 3, WIDTH - 15, HEIGHT - 3, p["metalLight"])
    canvas.rect(WIDTH - 62, 1, WIDTH - 12, 4, p["amberShade"])
    canvas.line(WIDTH - 60, 1, WIDTH - 12, 1, p["amber"])
    for y in [56, 113]:
        for x in [1, WIDTH - 5]:
            canvas.rect(x, y, x + 3, y + 10, p["amberShade"])
            canvas.rect(x, y, x + 2, y + 2, p["amber"])
    canvas.line(WIDTH - 101, HEIGHT - 2, WIDTH - 97, HEIGHT - 6, p["amber"])
    canvas.line(WIDTH - 97, HEIGHT - 2, WIDTH - 93, HEIGHT - 6, p["amber"])
    for x, direction in [(10, 1), (WIDTH - 11, -1)]:
        for y in [43, 95, 131]:
            canvas.line(x, y, x, y + 12, p["circuit"])
            canvas.line(x, y + 12, x + 3 * direction, y + 15, p["circuit"])
    for y in [33, 94]:
        canvas.line(10, y, WIDTH - 11, y, p["blueLine"])
        canvas.line(10, y + 1, WIDTH - 11, y + 1, p["circuit"])
    return canvas


def build():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    with TemporaryDirectory() as directory:
        temp = Path(directory)
        base = temp / "base.png"
        base.write_bytes(frame().png())
        motif = temp / "motif.png"
        subprocess.run(["magick", str(SOURCE / "honeycomb-source.png"),
                        "-filter", "point", "-resize", "95x73!",
                        "-fill", "#c29a49", "-colorize", "100",
                        "-channel", "A", "-evaluate", "multiply", "0.25",
                        "+channel", str(motif)], check=True)
        composed = temp / "composed.png"
        # Clip the decoration to the panel interior so the metal edge stays on top.
        subprocess.run(["magick", str(base), "(", str(motif),
                        "-crop", "89x67+6+6", "+repage", ")",
                        "-geometry", "+174+90", "-compose", "over", "-composite",
                        str(composed)], check=True)
        for name, y, height in [("header.png", 0, 34),
                                ("body.png", 34, 119),
                                ("footer.png", 153, 12)]:
            subprocess.run(["magick", str(composed), "-crop",
                            f"{WIDTH}x{height}+0+{y}", "+repage",
                            f"PNG32:{OUTPUT / name}"], check=True)
        icon = Surface(20, 20)
        hex_badge(icon, PALETTE)
        for y in range(5, 15):
            t = y - 5
            icon.pixel(7 + ((t + 1) % 5), y, PALETTE["cyan"])
            icon.pixel(12 - ((t + 1) % 5), y, PALETTE["cyanLight"])
        for y in [6, 10, 14]:
            icon.line(8, y, 12, y, PALETTE["cyan"])
        (OUTPUT / "icon.png").write_bytes(icon.png())


if __name__ == "__main__":
    build()
