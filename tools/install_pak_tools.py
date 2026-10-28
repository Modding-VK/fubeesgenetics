#!/usr/bin/env python3
"""Install the pinned OpenStarbound Linux PAK tools into the ignored cache."""

import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "tools/pak_toolchain.json"
CACHE = ROOT / ".cache/pak-tools"
TOOL_NAMES = ("asset_packer", "asset_unpacker")


def digest(path):
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def main():
    manifest = json.loads(MANIFEST.read_text())
    expected = {name: manifest["linux_x86_64_tools"][name]["sha256"] for name in TOOL_NAMES}
    if all((CACHE / name).is_file() and digest(CACHE / name) == sha
           for name, sha in expected.items()):
        print("Pinned OpenStarbound PAK tools already installed")
        return

    CACHE.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="fubees-pak-tools-") as temporary:
        archive = Path(temporary) / "client.tar.lz"
        subprocess.run([
            "curl", "--fail", "--location", "--retry", "3", "--retry-delay", "2",
            "--output", str(archive), manifest["url"]
        ], check=True)
        if digest(archive) != manifest["archive_sha256"]:
            raise ValueError("OpenStarbound archive SHA-256 mismatch")

        found = set()
        with subprocess.Popen(["lzip", "-dc", str(archive)], stdout=subprocess.PIPE) as process:
            with tarfile.open(fileobj=process.stdout, mode="r|") as contents:
                for member in contents:
                    name = Path(member.name).name
                    if name not in expected or not member.isfile():
                        continue
                    if name in found:
                        raise ValueError(f"Duplicate tool in OpenStarbound archive: {name}")
                    source = contents.extractfile(member)
                    if source is None:
                        raise ValueError(f"Cannot read OpenStarbound tool: {name}")
                    with source, (Path(temporary) / name).open("wb") as destination:
                        shutil.copyfileobj(source, destination)
                    found.add(name)
            if process.wait() != 0:
                raise ValueError("Could not decompress OpenStarbound archive")

        if found != set(TOOL_NAMES):
            raise ValueError(f"Missing OpenStarbound tools: {set(TOOL_NAMES) - found}")
        for name, sha in expected.items():
            source = Path(temporary) / name
            if digest(source) != sha:
                raise ValueError(f"OpenStarbound {name} SHA-256 mismatch")
            target = CACHE / name
            shutil.copyfile(source, target)
            target.chmod(0o755)
            print(f"Installed {name}: SHA-256 {sha}")


if __name__ == "__main__":
    main()
