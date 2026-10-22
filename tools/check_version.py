#!/usr/bin/env python3
"""Validate development/release identifiers without creating tags or promoting code."""
import argparse
import json
from pathlib import Path
import re
from run_checks import asset_json

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--development', action='store_true')
    mode.add_argument('--release', action='store_true')
    parser.add_argument('--tag', help='Expected production tag, for example v0.2.0')
    args = parser.parse_args()
    version = asset_json((ROOT / 'FUBeesGenetics/_metadata').read_text())['version']
    stable = r'(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)'
    expected = stable + (r'-dev' if args.development else '')
    if not re.fullmatch(expected, version):
        parser.error(f'Invalid {"development" if args.development else "release"} version: {version}')
    if args.tag is not None and (not args.release or args.tag != 'v' + version):
        parser.error('A production tag must match the stable metadata version exactly.')
    print(f'Version valid: {version}' + (f'; tag {args.tag}' if args.tag else ''))


if __name__ == '__main__':
    main()
