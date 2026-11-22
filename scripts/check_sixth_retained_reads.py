#!/usr/bin/env python3
"""Check the P3-13 frozen read census and run real producer, Layer 3, writer and FULL controls."""
import csv
import difflib
import os
from pathlib import Path
import subprocess
import sys
import tempfile


FIELDS = {
    "root", "classes", "witnesses", "unfoldings", "containerLaws", "flatConstructions",
    "containerConstructions", "dependentChainConstructions", "guardedJoinConstructions",
    "callOccurrenceCertificates", "constructionSources", "binderOccurrenceCertificates",
    "semanticProfile",
}
SECTIONS = [
    ("law-certificates", "verifyLaws", 0),
    ("flat-constructions", "SemanticReplay.verify", 0),
    ("container-constructions", "SemanticReplay.verify", 1),
    ("binder-occurrences", "SemanticReplay.verify", 2),
    ("exact-types", "parseExactTypes", 0),
    ("call-occurrences", "verifyCallOccurrences", 0),
]
CONTROLS = [
    ("producer", "original", "ACCEPTED"),
    ("producer", "omission", "SOURCE_OCCURRENCES_DIFFER"),
    ("producer", "duplicate", "SOURCE_OCCURRENCES_DIFFER"),
    ("producer", "detached-source", "SOURCE_OCCURRENCES_DIFFER"),
    ("layer3", "original", "ACCEPTED"),
    ("layer3", "detached-artifact", "CHAIN_OUTSIDE_ARTIFACT"),
    ("writer", "matched-law-registry", "EXPORTED"),
    ("writer", "omitted-law-registry", "UNCHECKABLE/REGISTRIES_DIFFER"),
    ("standalone-FULL", "original", "VERIFIED/NONE"),
    ("standalone-FULL", "alternate-source", "VERIFIED/NONE"),
    ("standalone-FULL", "omission", "REJECTED/MISSING_EVIDENCE"),
    ("standalone-FULL", "detached-source", "REJECTED/MISSING_EVIDENCE"),
]


def require(condition, message):
    if not condition:
        raise ValueError(message)


def check_reads(expected, actual):
    frozen = expected.read_bytes()
    observed = actual.read_bytes()
    if frozen != observed:
        diff = difflib.unified_diff(frozen.decode().splitlines(), observed.decode().splitlines(),
                                    fromfile="frozen reads", tofile="observed reads", n=1)
        raise ValueError("retained read census differs\n" + "\n".join(diff))
    with actual.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t", quoting=csv.QUOTE_NONE)
        require(reader.fieldnames == ["kind", "owner", "method", "occurrence", "target", "detail"],
                "invalid read census header")
        rows = list(reader)
    keys = {(r["kind"], r["owner"], r["method"], int(r["occurrence"])) for r in rows}
    require(len(keys) == len(rows), "duplicate occurrence in the compiler census")
    for kind in ("FIELD", "GETTER"):
        selected = [r["target"] for r in rows if r["kind"] == kind]
        require(len(selected) == len(FIELDS) and set(selected) == FIELDS,
                "retained field and bound accessor census changed: " + kind)
    writes = {r["target"]: r["detail"] for r in rows if r["kind"] == "WIRE_WRITE"}
    reads = [r for r in rows if r["kind"] == "WIRE_READ"]
    require(len(writes) == len(SECTIONS), "semantic evidence section cardinality changed")
    for index, (tag, method, argument) in enumerate(SECTIONS):
        require(writes[str(index)].startswith(f'node("{tag}", '), "wrong writer at " + tag)
        endpoints = [r["detail"] for r in reads if r["target"] == str(index)]
        require(any(".requireSection(" in e and f'"{tag}"' in e for e in endpoints),
                "missing verifier section check: " + tag)
        require(any("." + method + "(" in e and f" argument {argument} of " in e for e in endpoints),
                "missing independent verification dispatch: " + tag)
    return len(rows)


def main(root, output):
    root = root.resolve(strict=True)
    output = output.resolve()
    output.mkdir()
    package = root / "docs/obligation-repair/sixth-five"
    paths = [Path(os.environ[key]).resolve(strict=True)
             for key in ("ACGN_SIXTH_PRODUCER_CLASSES", "ACGN_SIXTH_VERIFIER_CLASSES")]
    require(all(p.is_dir() for p in paths), "missing compiled class directory")
    reads = output / "retained-reads.tsv"
    subprocess.run(["java", "-Xmx1g", root / "scripts/java/RetainedArtifactReadsExtractor.java",
                    root, reads], cwd=root, check=True)
    count = check_reads(package / "p3-13-reads.tsv", reads)
    controls = output / "retained-controls.tsv"
    classpath = os.pathsep.join(map(str, [*paths, root / "lib/*"]))
    with tempfile.TemporaryDirectory(dir=output) as scratch:
        subprocess.run(["java", "-ea", "-Xmx768m", f"-Dacgn.repo.root={root}",
                        "-Dacgn.provenance.testOverride=true", "-cp", classpath,
                        package / "java/RetainedArtifactOmissionTest.java", scratch, controls],
                       cwd=root, check=True)
    with controls.open(encoding="utf-8", newline="") as stream:
        observations = list(csv.reader(stream, delimiter="\t"))
    require(observations == [["consumer", "case", "outcome"], *map(list, CONTROLS)],
            "retained control result changed")
    print(f"P3-13 retained reads passed: {count} compiler rows, {len(CONTROLS)} controls")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("usage: check_sixth_retained_reads.py ROOT NEW_OUTPUT_DIR")
    main(Path(sys.argv[1]), Path(sys.argv[2]))
