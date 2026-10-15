#!/usr/bin/env python3
"""Build standard Starbound PAK with native tools, verify it, and create delivery ZIPs."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]
STAMP = (2026, 10, 14, 0, 0, 0)


def report(path, detail):
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    print(f'{path.name}: {detail}; SHA256 {digest}')


def build_zip(output, entries):
    with zipfile.ZipFile(output, 'w', zipfile.ZIP_DEFLATED) as archive:
        for name, path in sorted(entries):
            info = zipfile.ZipInfo(name, STAMP)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, path.read_bytes())
    with zipfile.ZipFile(output) as archive:
        assert archive.testzip() is None
    report(output, f'{len(entries)} files')


def native_tool(value, name):
    if value:
        found = shutil.which(value)
        candidate = Path(found or value).expanduser().resolve()
        if not candidate.is_file():
            raise ValueError(f'Tool not found: {value}')
        return candidate
    found = shutil.which(name) or shutil.which(name + '.exe')
    if found:
        return Path(found).resolve()
    cached = ROOT / '.cache/pak-tools' / name
    if cached.is_file():
        return cached
    raise ValueError(f'Provide --{name.replace("_", "-")} with the native Starbound/OpenStarbound tool path.')


def verify_unpacked(source, restored):
    expected = {p.relative_to(source).as_posix(): p for p in source.rglob('*') if p.is_file()}
    actual = {p.relative_to(restored).as_posix(): p for p in restored.rglob('*') if p.is_file()}
    if expected.keys() != actual.keys():
        raise ValueError(f'PAK file list mismatch: missing={expected.keys()-actual.keys()}, extra={actual.keys()-expected.keys()}')
    for name, original in expected.items():
        # Native unpacker writes metadata from the PAK index; JSON formatting can change.
        if name == '_metadata':
            identical = json.loads(original.read_text()) == json.loads(actual[name].read_text())
        else:
            identical = original.read_bytes() == actual[name].read_bytes()
        if not identical:
            raise ValueError(f'PAK round-trip mismatch: {name}')
    return len(expected)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output-dir', type=Path, default=ROOT.parent)
    parser.add_argument('--asset-packer', help='Native asset_packer executable, including .exe on Windows')
    parser.add_argument('--asset-unpacker', help='Native asset_unpacker executable for round-trip verification')
    args = parser.parse_args()
    try:
        packer = native_tool(args.asset_packer, 'asset_packer')
        unpacker_value = args.asset_unpacker
        if not unpacker_value and args.asset_packer:
            sibling = packer.with_name('asset_unpacker' + packer.suffix)
            if sibling.is_file():
                unpacker_value = str(sibling)
        unpacker = native_tool(unpacker_value, 'asset_unpacker')
    except ValueError as error:
        parser.error(str(error))
    output = args.output_dir.resolve()
    output.mkdir(parents=True, exist_ok=True)
    mod = ROOT / 'FUBeesGenetics'
    with tempfile.TemporaryDirectory(prefix='fubees-pak-', dir=output) as temporary:
        staging = Path(temporary)
        pak = staging / 'fubeesgenetics-mvp.pak'
        subprocess.run([str(packer), str(mod), str(pak)], check=True)
        with pak.open('rb') as stream:
            if stream.read(8) != b'SBAsset6':
                raise ValueError('Native tool did not produce a Starbound SBAsset6 archive.')
        restored = staging / 'unpacked'
        subprocess.run([str(unpacker), str(pak), str(restored)], check=True)
        count = verify_unpacked(mod, restored)
        shutil.copyfile(pak, output / pak.name)
        report(output / pak.name, f'{count} files verified by native unpacker')
    workshop = output / 'fubeesgenetics-workshop'
    workshop.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(output / 'fubeesgenetics-mvp.pak', workshop / 'contents.pak')
    build_zip(output / 'fubeesgenetics-workshop-content.zip', [('contents.pak', workshop / 'contents.pak')])
    paths = [p for p in ROOT.rglob('*') if p.is_file()
             and not {'.git', '.cache', '__pycache__'}.intersection(p.relative_to(ROOT).parts)
             and p.suffix not in {'.pyc', '.zip', '.bundle', '.pak'} and p.name != '.gitkeep']
    build_zip(output / 'fubeesgenetics-mvp-mod.zip',
              [(p.relative_to(ROOT).as_posix(), p) for p in paths if p.is_relative_to(mod)])
    build_zip(output / 'fubeesgenetics-mvp-source.zip',
              [(p.relative_to(ROOT).as_posix(), p) for p in paths])


if __name__ == '__main__':
    main()
