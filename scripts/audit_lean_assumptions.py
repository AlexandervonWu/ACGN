#!/usr/bin/env python3
"""Compile an explicit Lean declaration/axiom inventory for governed catalogs."""

from __future__ import annotations

import argparse
import csv
import re
import subprocess
from collections import OrderedDict
from pathlib import Path


NAMESPACE = re.compile(r"^\s*namespace\s+([A-Za-z0-9_'.]+)\s*$", re.MULTILINE)
DECLARATION = re.compile(r"^[A-Za-z0-9_'.]+$")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--lean", required=True, type=Path)
    parser.add_argument(
        "--rewrite-only",
        action="store_true",
        help="audit only declarations referenced by the rewrite-rule catalog",
    )
    args = parser.parse_args()

    root = args.root.resolve()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    matrix = root / "docs/section3-repair-audit/requirements-traceability.tsv"
    rewrite_catalog = (
        root / "docs/section3-repair-audit/rewrite-rule-traceability.tsv"
    )

    by_file: OrderedDict[str, list[str]] = OrderedDict()

    def add_declaration(formal_file: str, declaration: str, source: str) -> None:
        formal_file = formal_file.strip()
        declaration = declaration.strip()
        if not formal_file:
            raise SystemExit(f"missing Lean source path in {source}")
        if not DECLARATION.fullmatch(declaration):
            raise SystemExit(
                f"invalid mapped Lean declaration {declaration!r} "
                f"in {formal_file} ({source})"
            )
        by_file.setdefault(formal_file, [])
        if declaration not in by_file[formal_file]:
            by_file[formal_file].append(declaration)

    if not args.rewrite_only:
        with matrix.open(encoding="utf-8", newline="") as stream:
            for row in csv.DictReader(stream, delimiter="\t"):
                formal_file = row["formal_file"]
                for declaration in row["formal_declarations"].split(";"):
                    add_declaration(
                        formal_file,
                        declaration,
                        f"requirements row {row.get('requirement_id', '<unknown>')}",
                    )

    with rewrite_catalog.open(encoding="utf-8", newline="") as stream:
        for row in csv.DictReader(stream, delimiter="\t"):
            rule_id = row.get("rule_id", "<unknown>")
            references = row.get("lean_refs")
            if references is None:
                raise SystemExit("rewrite catalog is missing the lean_refs column")
            encoded_references = references.split(";")
            if not encoded_references or any(not item.strip() for item in encoded_references):
                raise SystemExit(f"rewrite rule {rule_id} has an empty Lean reference")
            for encoded in encoded_references:
                if encoded.count("#") != 1:
                    raise SystemExit(
                        f"rewrite rule {rule_id} has malformed Lean reference {encoded!r}"
                    )
                formal_file, declaration = encoded.rsplit("#", 1)
                add_declaration(
                    formal_file,
                    declaration,
                    f"rewrite rule {rule_id}",
                )

    summary = output / "assumption-inventory.tsv"
    with summary.open("w", encoding="utf-8", newline="\n") as inventory:
        inventory.write("formal_file\tdeclaration\tqualified_declaration\n")
        for index, (relative, declarations) in enumerate(by_file.items()):
            source_path = (root / relative).resolve()
            if root not in source_path.parents or not source_path.is_file():
                raise SystemExit(f"mapped Lean source escapes or is missing: {relative}")
            source = source_path.read_text(encoding="utf-8")
            namespace_match = NAMESPACE.search(source)
            namespace = namespace_match.group(1) if namespace_match else ""
            commands: list[str] = []
            for declaration in declarations:
                qualified = declaration if "." in declaration or not namespace else (
                    namespace + "." + declaration
                )
                inventory.write(f"{relative}\t{declaration}\t{qualified}\n")
                commands.append(f"#check {qualified}")
                commands.append(f"#print axioms {qualified}")

            audit_source = output / f"{index:02d}-{source_path.name}"
            audit_source.write_text(
                source + "\n\n-- Generated assurance assumption inventory.\n"
                + "\n".join(commands) + "\n",
                encoding="utf-8",
                newline="\n",
            )
            completed = subprocess.run(
                [str(args.lean), str(audit_source)],
                cwd=root,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                check=False,
            )
            (output / f"{index:02d}-{source_path.stem}.log").write_text(
                completed.stdout, encoding="utf-8", newline="\n"
            )
            if completed.returncode != 0:
                raise SystemExit(
                    f"Lean assumption extraction failed for {relative}; "
                    f"see {index:02d}-{source_path.stem}.log"
                )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
