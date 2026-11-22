#!/usr/bin/env python3
"""Compile an explicit Lean declaration/axiom inventory for governed catalogs."""

from __future__ import annotations

import argparse
import csv
import json
import re
import subprocess
import sys
from collections import Counter, OrderedDict
from pathlib import Path


NAMESPACE = re.compile(r"^\s*namespace\s+([A-Za-z0-9_'.]+)\s*$", re.MULTILINE)
DECLARATION = re.compile(r"^[A-Za-z0-9_'.]+$")


FORMAL = Path("docs/section3-repair-audit/formal")
SIXTH = Path("docs/obligation-repair/sixth-five/qualification.json")
AUDIT_MARKER = "Begin generated Section 3 supplemental axiom inventory"


def supplemental_declarations(root: Path) -> dict[str, list[str]]:
    # Use the existing CI and sixth-batch theorem inventories. Two ordinary
    # bounded CI modules previously registered only the source to compile.
    sys.dont_write_bytecode = True
    from run_java_lean_refinement import REFINEMENT_THEOREMS
    from run_submission_container_closure import THEOREMS, scan_proof, unique_object
    from check_rewrite_dispatch_parity import strip_lean_comments

    retained = str(FORMAL / "RetainedArtifactReads.lean")
    phases = json.loads((root / SIXTH).read_bytes(), object_pairs_hook=unique_object)["phases"]
    matches = [p for p in phases if p["parent"] == "P3-13"]
    if len(matches) != 1 or matches[0]["proof"] != retained:
        raise SystemExit("missing or inconsistent P3-13 retained-read proof registration")
    retained_names = matches[0]["theorems"]
    prefix = "ACGN.SixthFive.RetainedArtifactReads."
    if not all(name.startswith(prefix) for name in retained_names):
        raise SystemExit("invalid P3-13 retained-read theorem namespace")
    modules = {
        "ContainerReplay": THEOREMS,
        "SmartConstructionRefinement": REFINEMENT_THEOREMS,
        "RetainedArtifactReads": [name.removeprefix(prefix) for name in retained_names],
        "PositiveVerificationMemo": [
            "empty_sound", "successful_insert", "check_eq_verification", "discard_sound",
        ],
        "UnusedGroupedBindings": [
            "all_drop_unused", "some_drop_unused", "no_drop_unused", "all_drop_first",
            "some_drop_first", "d8_reference", "old_gate_rejects", "reduced_gate_accepts",
            "all_vacuous", "some_vacuous", "one_product", "lone_product",
            "exists_assignments", "one_assignments", "lone_assignments",
            "one_fibers", "lone_fibers", "empty_all_counterexample",
            "empty_some_counterexample", "disjoint_counterexample", "all_after_tautology",
            "some_after_tautology", "unused_subset_some", "unused_subset_all",
            "original_declarations_distinct", "overwritten_declaration_inventory",
            "shadowed_first_slot",
        ],
    }
    registered = {}
    for module, expected in modules.items():
        relative = str(FORMAL / (module + ".lean"))
        path = root / relative
        if not path.is_file() or path.is_symlink():
            raise SystemExit(f"missing supplemental proof: {relative}")
        observed = scan_proof(path)
        clean = strip_lean_comments(path.read_text(encoding="utf-8"))
        declarations = re.findall(r"\b(?:theorem|lemma)\s+[A-Za-z_][\w'.]*", clean)
        if (not expected or len(expected) != len(set(expected))
                or Counter(observed) != Counter(expected) or len(declarations) != len(expected)):
            raise SystemExit(f"supplemental theorem census differs: {relative}")
        registered[relative] = sorted(expected)
    return registered


def audit_supplemental_output(output: Path, stem: str, log: str, names: list[str]) -> None:
    from run_submission_container_closure import audit_assumptions

    # The authored module can already print some of its declarations. Audit the
    # subsequently generated commands independently, exactly once per theorem.
    parts = log.split(AUDIT_MARKER + "\n")
    if len(parts) != 2:
        raise SystemExit(f"missing generated axiom inventory marker: {stem}")
    axioms = output / (stem + "-supplemental-axioms.log")
    axioms.write_text(parts[1], encoding="utf-8")
    audit_assumptions(axioms, len(names))
    observed = re.findall(r"'([^']+)' (?:does not depend on any axioms|depends on axioms:)", parts[1])
    if Counter(observed) != Counter(names):
        raise SystemExit(f"supplemental axiom requests differ from observations: {stem}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, type=Path)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--output", type=Path)
    action.add_argument("--list-formal-files", action="store_true",
                        help="print the complete governed file inventory")
    parser.add_argument("--lean", type=Path)
    parser.add_argument(
        "--rewrite-only",
        action="store_true",
        help="audit only declarations referenced by the rewrite-rule catalog",
    )
    args = parser.parse_args()

    root = args.root.resolve()
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

    supplemental = {} if args.rewrite_only else supplemental_declarations(root)
    for formal_file, declarations in supplemental.items():
        for name in declarations:
            add_declaration(formal_file, name, "supplemental theorem registry")

    if args.list_formal_files:
        for formal_file in sorted(by_file):
            print(formal_file)
        return 0
    if not args.lean:
        parser.error("--output requires --lean")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
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
            qualified_names: list[str] = []
            if relative in supplemental:
                commands.append(f'#eval IO.println "{AUDIT_MARKER}"')
            for declaration in declarations:
                qualified = declaration if "." in declaration or not namespace else (
                    namespace + "." + declaration
                )
                inventory.write(f"{relative}\t{declaration}\t{qualified}\n")
                qualified_names.append(qualified)
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
            if relative in supplemental:
                audit_supplemental_output(output, f"{index:02d}-{source_path.stem}",
                                          completed.stdout, qualified_names)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
