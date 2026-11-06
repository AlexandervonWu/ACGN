#!/usr/bin/env python3
"""Fetch pinned stable Java artifacts and remove shadowed bundled dependencies."""
import hashlib
import io
import json
from pathlib import Path
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
MAVEN = "https://repo.maven.apache.org/maven2/"
ARTIFACTS = {
    "alloy.jar": "org/alloytools/org.alloytools.alloy.dist/6.2.0/org.alloytools.alloy.dist-6.2.0.jar",
    "commons-cli-1.11.0.jar": "commons-cli/commons-cli/1.11.0/commons-cli-1.11.0.jar",
    "json-java.jar": "org/json/json/20260814/json-20260814.jar",
    "slf4j-api-2.0.20.jar": "org/slf4j/slf4j-api/2.0.20/slf4j-api-2.0.20.jar",
    "slf4j-simple-2.0.20.jar": "org/slf4j/slf4j-simple/2.0.20/slf4j-simple-2.0.20.jar",
}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def filtered(data, keep):
    output = io.BytesIO()
    with zipfile.ZipFile(io.BytesIO(data)) as source, zipfile.ZipFile(output, "w") as target:
        for entry in source.infolist():
            if keep(entry.filename):
                target.writestr(entry, source.read(entry))
    return output.getvalue()


def main():
    lib = ROOT / "lib"
    records = {}
    pending = {}
    for name, coordinate in ARTIFACTS.items():
        url = MAVEN + coordinate
        raw = urllib.request.urlopen(url, timeout=90).read()
        remote_sha = urllib.request.urlopen(url + ".sha1", timeout=90).read().decode().strip().split()[0]
        if hashlib.sha1(raw).hexdigest() != remote_sha.lower():
            raise RuntimeError("Repository checksum mismatch: " + url)
        data = raw
        if name == "alloy.jar":
            # Exactly one active copy of these independently pinned libraries.
            data = filtered(raw, lambda p: not p.startswith((
                "org/slf4j/", "org/apache/commons/cli/", "org/json/")))
        pending[name] = data
        records[name] = {"url": url, "upstreamSha256": digest(raw), "sha256": digest(data)}
    asg = lib / "AlloyASG-Release.jar"
    thin = filtered(asg.read_bytes(), lambda p: p.startswith((
        "is/fivefivefive/alloyasg/", "com/abdulfatir/")) or p == "META-INF/MANIFEST.MF")
    pending[asg.name] = thin
    records[asg.name] = {"source": "repository-local ASG, dependency-free extraction", "sha256": digest(thin)}
    for name in ("AlloyParser.jar", "AlloyASG.jar"):
        records[name] = {"source": "repository-local adapter", "sha256": digest((lib / name).read_bytes())}
    # Download and validate everything before replacing any active library.
    # Run with builds stopped; replacement is atomic per file, not across the set.
    for name, data in pending.items():
        staging = lib / (name + ".download")
        staging.write_bytes(data)
        staging.replace(lib / name)
    for old in ("commons-cli-1.4.jar", "slf4j-simple-1.7.36.jar"):
        (lib / old).unlink(missing_ok=True)
    (lib / "dependencies.json").write_text(json.dumps(records, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
