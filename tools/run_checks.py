#!/usr/bin/env python3
"""Check the recovered MVP against pinned FU sources using Python's standard library."""
import argparse
import copy
import ctypes
import ctypes.util
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = json.loads((ROOT / "tools/upstream.json").read_text())


def asset_json(text):
    # Preserve strings (including URLs) while removing comments/trailing commas.
    tokens = re.compile(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*[\s\S]*?\*/')
    text = tokens.sub(lambda m: m[0] if m[0].startswith('"') else '', text)
    trailing = re.compile(r'"(?:\\.|[^"\\])*"|,\s*([}\]])')
    text = trailing.sub(lambda m: m[1] if m[1] else m[0], text)
    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError(f'Duplicate JSON key: {key}')
            result[key] = value
        return result
    return json.loads(text, object_pairs_hook=unique)


def lua(value):
    if value is None:
        return "nil"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, list):
        return "{" + ",".join(lua(v) for v in value) + "}"
    return "{" + ",".join("[" + lua(k) + "]=" + lua(v) for k, v in value.items()) + "}"


def run_lua(script):
    executable = shutil.which("lua5.4") or shutil.which("lua")
    if executable:
        subprocess.run([executable, str(script)], check=True, cwd=ROOT)
        return
    library = ctypes.util.find_library("lua5.4")
    if not library:
        raise RuntimeError("Install Lua 5.4 or its shared library to run the checks.")
    lib = ctypes.CDLL(library)
    lib.luaL_newstate.restype = ctypes.c_void_p
    lib.luaL_openlibs.argtypes = [ctypes.c_void_p]
    lib.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
    lib.luaL_loadfilex.restype = ctypes.c_int
    lib.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int,
                              ctypes.c_int, ctypes.c_ssize_t, ctypes.c_void_p]
    lib.lua_pcallk.restype = ctypes.c_int
    lib.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
    lib.lua_tolstring.restype = ctypes.c_char_p
    lib.lua_close.argtypes = [ctypes.c_void_p]
    state = lib.luaL_newstate()
    if not state:
        raise RuntimeError("Could not allocate Lua state.")
    try:
        lib.luaL_openlibs(state)
        status = lib.luaL_loadfilex(state, os.fsencode(script), None)
        if not status:
            status = lib.lua_pcallk(state, 0, -1, 0, 0, None)
        if status:
            raise RuntimeError(lib.lua_tolstring(state, -1, None).decode())
    finally:
        lib.lua_close(state)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--fetch", action="store_true", help="Download pinned FU test sources")
    parser.add_argument("--fu-root", type=Path, default=ROOT / ".cache/fu")
    parser.add_argument("--ic-root", type=Path, help="Unpacked original IC 2.11 for optional integration checks")
    args = parser.parse_args()
    fu_root = args.fu_root.resolve()
    for path, expected in MANIFEST["files"].items():
        target = fu_root / path
        if args.fetch:
            url = ("https://raw.githubusercontent.com/" + MANIFEST["repository"]
                   + "/" + MANIFEST["commit"] + "/" + path)
            with urllib.request.urlopen(url, timeout=30) as response:
                payload = response.read()
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(payload)
        if not target.is_file():
            raise RuntimeError(f"Missing {target}; use --fetch or --fu-root.")
        payload = target.read_bytes()
        actual = hashlib.sha1(b"blob " + str(len(payload)).encode() + b"\0" + payload).hexdigest()
        if actual != expected:
            raise RuntimeError(f"Upstream blob mismatch: {path} ({actual} != {expected})")
    from check_container_ui import load_references
    native_root = load_references(ROOT, args.fetch)
    metadata = asset_json((ROOT / "FUBeesGenetics/_metadata").read_text())
    dependency = asset_json((fu_root / ".metadata").read_text())["name"]
    assert metadata["name"] == "FUBeesGenetics"
    assert metadata["requires"] == [dependency] == ["FrackinUniverse"]
    bee_data = asset_json((fu_root / "bees/beeData.config").read_text())
    tags = {}
    for path in MANIFEST["files"]:
        if path.endswith(".item"):
            item = asset_json((fu_root / path).read_text())
            tags[item["itemName"]] = {tag: True for tag in item["itemTags"]}
    # Non-Honey identities use synthetic caste tags; Honey retains real pinned tags.
    for family in bee_data["stats"]:
        tags.setdefault("bee_" + family + "_queen", {"bee": True, "queen": True})
        tags.setdefault("bee_" + family + "_youngQueen", {"bee": True, "youngQueen": True})
    # Test caste eligibility independently from text in the item name.
    tags["bee_honey_unusual"] = {"bee": True, "youngQueen": True}
    tags["bee_unknown_queen"] = {"bee": True, "queen": True}
    tags["brokenname"] = {"bee": True, "queen": True}
    tags["bee_honey_fakequeen"] = {"bee": True}
    fixture = {"nativeRoot": str(native_root), "nativeContainerUi": json.loads((native_root / "interface/chests/chest16.config").read_text()), "exchangeConfig": json.loads((ROOT / "FUBeesGenetics/objects/bees/fubeesgenetics/beeexchange/beeexchange.object").read_text()), "beeData": bee_data, "tags": tags, "fuRoot": str(fu_root), "repoRoot": str(ROOT),
               "tradeRecipes": {"/"+p: asset_json((fu_root/p).read_text()) for p in MANIFEST["files"] if p.startswith("recipes/bees/beerefuge/")},
               "uiConfig": json.loads((ROOT / "FUBeesGenetics/interface/fubeesgenetics/geneticqueenfilter/fubeesgenetics_geneticqueenfilter.config").read_text())}
    with tempfile.TemporaryDirectory(prefix="fubeesgenetics-checks-") as directory:
        script = Path(directory) / "run.lua"
        compilation = "".join("assert(loadfile(" + lua(str(path)) + "))\n"
                              for path in sorted((ROOT / "FUBeesGenetics").rglob("*.lua")))
        script.write_text(compilation + "fixture = " + lua(fixture) + "\n"
                          + "dofile(" + lua(str(ROOT / "tests/adapter_test.lua")) + ")\n")
        run_lua(script)
        for name in ["machine_test.lua", "interface_test.lua", "exchange_test.lua"]:
            script.write_text(compilation + "fixture = " + lua(fixture) + "\n"
                              + "dofile(" + lua(str(ROOT / "tests" / name)) + ")\n")
            run_lua(script)
    if args.ic_root:
        from check_storage_compat import run_storage_checks
        run_storage_checks(ROOT, args.ic_root, fixture, native_root)
    from generate_hybrids import generate
    hybrid_catalog = asset_json((ROOT / 'docs/HYBRID_SPECIES_CATALOG.json').read_text())
    assert hybrid_catalog == generate(fu_root), 'Hybrid runtime catalog is stale'
    hybrid_plants = asset_json((ROOT / 'FUBeesGenetics/bees/hybridPlants.config').read_text())
    expected_plants = asset_json((ROOT / 'tools/hybrid_plants.json').read_text())
    assert hybrid_plants == {family: {'id': plant['id'], 'likeness': plant['likeness']}
                             for family, plant in expected_plants.items()}
    from build_hybrid_sprites import generate_sprites
    generate_sprites(fu_root, check=True)
    hybrid_data = copy.deepcopy(bee_data)
    for op in asset_json((ROOT / 'FUBeesGenetics/bees/beeData.config.patch').read_text()):
        section, name = op['path'].strip('/').split('/')
        hybrid_data[section][name] = op['value']
    fixture.update(hybridBeeData=hybrid_data, hybridCatalog=hybrid_catalog, hybridPlants=hybrid_plants,
                   hybridizerConfig=asset_json((ROOT / 'FUBeesGenetics/objects/bees/fubeesgenetics/hybridizer/hybridizer.object').read_text()),
                   overloadConfig=asset_json((ROOT / 'FUBeesGenetics/objects/bees/fubeesgenetics/overloadapiary/overloadapiary.object').read_text()),
                   hybridItems={d['itemName']: d for p in (ROOT / 'FUBeesGenetics/bees/bees').glob('hybrid*.item')
                                for d in [asset_json(p.read_text())]})
    with tempfile.TemporaryDirectory(prefix='hybrid-checks-') as directory:
        script = Path(directory) / 'run.lua'
        script.write_text('fixture = ' + lua(fixture) + '\n' +
                          'dofile(' + lua(str(ROOT / 'tests/hybrid_test.lua')) + ')\n')
        run_lua(script)
    from check_assets import check_assets
    check_assets(ROOT, fu_root, native_root)
    print("Lua syntax, metadata and upstream blob integrity: PASS", flush=True)


if __name__ == "__main__":
    main()
