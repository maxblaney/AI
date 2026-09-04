#!/usr/bin/env python3
"""Slice a headshot sprite sheet into the individual portraits the game
loads from `assets/fighters/`.

The first two sheets were cut by hand, twice, with the numbers worked out
each time. This exists so the third one is a command:

    python3 tool/slice_headshots.py assets/fighters/source/headshots_v3_sheet.png

By default it reports what it found without writing anything. Add
`--write` once the report looks right.

Naming follows what the picker expects: `<set>_NN.png`, where the part
before the underscore is the group heading shown in the game
(`HeadshotCatalog`). Numbering continues from whatever is already in the
output directory, so re-running never clobbers earlier art.
"""

from __future__ import annotations

import argparse
import os
import re
import sys

try:
    from PIL import Image
except ImportError:  # pragma: no cover - the message is the point
    sys.exit("Pillow is required: pip install pillow")


# Skin brightness cut-offs used to bucket a portrait into a tone set.
#
# Calibrated against the art already in `assets/fighters/`, whose buckets
# were checked by eye: on the cheek sample below, deep sits around 19-37,
# medium 36-59 and tan 59-81. These are only a starting suggestion — the
# --set flag overrides them, and art that isn't a skin tone at all (a
# mask, a helmet) should always be named by hand.
TONE_CUTOFFS = ((45, "deep"), (72, "medium"), (255, "tan"))


def cell_is_empty(cell: Image.Image, alpha_floor: int = 8) -> bool:
    """True when a cell holds no artwork — a blank slot on the sheet."""
    if cell.mode != "RGBA":
        cell = cell.convert("RGBA")
    alpha = cell.getchannel("A")
    return alpha.getextrema()[1] < alpha_floor


def _patch_brightness(cell: Image.Image, y0: float, y1: float,
                      x0: float, x1: float) -> float:
    """Mean luminance of one fractional rectangle of the tile, ignoring
    anything transparent."""
    rgba = cell.convert("RGBA")
    w, h = rgba.size
    pixels = rgba.load()
    total, count = 0.0, 0
    for y in range(int(h * y0), int(h * y1)):
        for x in range(int(w * x0), int(w * x1)):
            r, g, b, a = pixels[x, y]
            if a < 128:
                continue
            total += 0.299 * r + 0.587 * g + 0.114 * b
            count += 1
    return total / count if count else 0.0


def skin_brightness(cell: Image.Image) -> float:
    """How light this fighter's skin is, read off both upper cheeks.

    Not the middle of the face, which is what this sampled first: the
    centre strip is where a beard, a moustache and a shadowed mouth live,
    and on a bearded tan fighter they dragged the reading down far enough
    to sort him in with the darkest art on the sheet. The cheeks are skin
    on essentially every portrait, so they measure skin.
    """
    left = _patch_brightness(cell, 0.38, 0.52, 0.22, 0.38)
    right = _patch_brightness(cell, 0.38, 0.52, 0.62, 0.78)
    samples = [value for value in (left, right) if value > 0]
    return sum(samples) / len(samples) if samples else 0.0


def tone_for(brightness: float) -> str:
    for ceiling, name in TONE_CUTOFFS:
        if brightness <= ceiling:
            return name
    return TONE_CUTOFFS[-1][1]


def next_index(out_dir: str, prefix: str) -> int:
    """One past the highest `<prefix>_NN.png` already in [out_dir], so a
    second run of the same set appends instead of overwriting."""
    pattern = re.compile(rf"^{re.escape(prefix)}_(\d+)\.png$")
    highest = 0
    if os.path.isdir(out_dir):
        for name in os.listdir(out_dir):
            match = pattern.match(name)
            if match:
                highest = max(highest, int(match.group(1)))
    return highest + 1


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("sheet", help="the sprite sheet to cut up")
    parser.add_argument("--cell", type=int, default=32,
                        help="cell size in pixels (default 32)")
    parser.add_argument("--out", default="assets/fighters",
                        help="where the portraits go (default assets/fighters)")
    parser.add_argument("--set", dest="set_name",
                        help="name every portrait into this one set, instead "
                             "of bucketing them by sampled skin brightness")
    parser.add_argument("--write", action="store_true",
                        help="actually write the files (default is a report)")
    args = parser.parse_args()

    sheet = Image.open(args.sheet).convert("RGBA")
    width, height = sheet.size
    if width % args.cell or height % args.cell:
        print(f"warning: {width}x{height} is not a whole number of "
              f"{args.cell}px cells — the last row/column will be clipped",
              file=sys.stderr)

    columns, rows = width // args.cell, height // args.cell
    print(f"{args.sheet}: {width}x{height} -> {columns}x{rows} cells "
          f"of {args.cell}px")

    counters: dict[str, int] = {}
    written = 0
    for row in range(rows):
        for column in range(columns):
            box = (column * args.cell, row * args.cell,
                   (column + 1) * args.cell, (row + 1) * args.cell)
            cell = sheet.crop(box)
            if cell_is_empty(cell):
                print(f"  r{row}c{column}: empty, skipped")
                continue

            brightness = skin_brightness(cell)
            prefix = args.set_name or tone_for(brightness)
            if prefix not in counters:
                counters[prefix] = next_index(args.out, prefix)
            index = counters[prefix]
            counters[prefix] += 1

            name = f"{prefix}_{index:02d}.png"
            print(f"  r{row}c{column}: brightness {brightness:5.1f} -> {name}")
            if args.write:
                os.makedirs(args.out, exist_ok=True)
                cell.save(os.path.join(args.out, name))
                written += 1

    if args.write:
        print(f"wrote {written} portraits to {args.out}/")
    else:
        print("nothing written — re-run with --write once this looks right")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
