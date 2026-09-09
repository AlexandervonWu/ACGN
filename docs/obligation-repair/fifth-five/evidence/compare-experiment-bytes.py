"""Compare the preserved v2.16 experiment JAR with a fresh closure build.

This is byte-identity evidence, not a theorem about arbitrary JVM loading.
The accompanying source review determines whether new entry points are used
by the experimental workflow.
"""
import argparse
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile

parser = argparse.ArgumentParser()
parser.add_argument("jar", type=Path)
parser.add_argument("classes", type=Path)
args = parser.parse_args()
same, changed, missing = [], [], []
with ZipFile(args.jar) as archive:
    entries = sorted(n for n in archive.namelist() if n.endswith(".class"))
    if not entries or len(entries) != len(set(entries)):
        raise SystemExit("Missing or duplicate archived class entries")
    for name in entries:
        candidate = args.classes / name
        if not candidate.is_file():
            missing.append(name)
        elif archive.read(name) != candidate.read_bytes():
            changed.append(name)
        else:
            same.append(name)
print(json.dumps({
    "baselineJar": str(args.jar),
    "baselineJarSha256": hashlib.sha256(args.jar.read_bytes()).hexdigest(),
    "freshClasses": str(args.classes),
    "identicalExistingClasses": len(same),
    "changedExistingClasses": changed,
    "missingExistingClasses": missing,
    "allExistingClassesByteIdentical": not changed and not missing,
}, indent=2))
raise SystemExit(bool(changed or missing))
