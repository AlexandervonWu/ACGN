#!/usr/bin/env python3
"""Compile an explicit Lean declaration/axiom inventory for governed catalogs."""

from __future__ import annotations

import argparse
import csv
import hashlib
import importlib.util
import json
import os
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
    # The 10th primary succeeds the last live reference to this original module.
    # Register the complete immutable historical source and audit every named theorem.
    retired = root / FORMAL / "DependentTypeDagStandalone.lean"
    if hashlib.sha256(retired.read_bytes()).hexdigest() != "43e71745ef0872c31e0473308ba332abca9b2d5d497b31a25cf7bdc0a7c2faa7":
        raise SystemExit("stale DependentTypeDagStandalone supplemental source")
    modules["DependentTypeDagStandalone"] = scan_proof(retired)
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


class AssurancePhase:
    """Run a registered phase with the standard assurance classes and evidence directory."""

    def __init__(self, root: Path, output: Path, heap: str, batch: str):
        self.source = root
        self.path = output
        self.heap = heap
        self.batch = batch
        self.logs = output / "logs"
        self.tmp = output / "tmp"
        for folder in (self.logs, self.tmp):
            folder.mkdir(parents=True, exist_ok=True)
        self.record = {"claims": {}}

    def run(self, name, args, cwd=None, *, expected=0, extra=None):
        if self.batch == "tenth" and extra and "ACGN_NINTH_PROOF" in extra:
            extra = dict(extra, ACGN_TENTH_LEAN=extra["ACGN_NINTH_LEAN"],
                         ACGN_TENTH_PROOF=extra["ACGN_NINTH_PROOF"])
        command = [str(arg) for arg in args]
        if command[0] == "java":
            command[command.index("-Xmx1g")] = "-Xmx" + self.heap
            command.insert(1, "-Djava.io.tmpdir=" + str(self.tmp))
        log = self.logs / (name + ".log")
        with log.open("x", encoding="utf-8") as stream:
            result = subprocess.run(command, cwd=cwd or self.source,
                                    env=dict(os.environ, TMPDIR=str(self.tmp), **(extra or {})),
                                    stdout=stream, stderr=subprocess.STDOUT)
        if result.returncode != expected:
            raise SystemExit(f"{name} exited {result.returncode}, expected {expected}; see {log}")
        return log


def run_registered_phase(batch: str, argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Execute a sealed witness on the assurance build.")
    parser.add_argument("parent")
    parser.add_argument("main_class")
    parser.add_argument("root", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("lean", type=Path)
    parser.add_argument("classpath")
    parser.add_argument("heap")
    parser.add_argument("provenance", nargs=argparse.REMAINDER)
    args = parser.parse_args(argv)
    root, output = args.root.resolve(), args.output.resolve()
    package = Path("docs/obligation-repair") / (batch + "-five")
    spec = importlib.util.spec_from_file_location("section3_" + batch, root / package / ("verify_" + batch + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    base = module.configure(root)
    config, parents = base.read_registration(root)
    phase = next(item for item in config["phases"] if item["parent"] == args.parent)
    if phase["class"] != args.main_class:
        raise SystemExit(f"global witness registration differs for {args.parent}")
    governed = {item["source"] for item in config["leanModules"].values()
                if Path(item["source"]).is_relative_to(package)}
    discovered = {p.relative_to(root).as_posix() for p in (root / package).rglob("*.lean")}
    if discovered != governed:
        raise SystemExit(f"{batch} supplemental Lean inventory differs: {sorted(discovered ^ governed)}")
    with (output / "input-manifest.tsv").open(encoding="utf-8") as stream:
        manifest = {r["path"]: r["sha256"] for r in csv.DictReader(stream, delimiter="\t")
                    if r["type"] == "file"}
    build = AssurancePhase(root, output / (batch + "-witnesses"), args.heap, batch)
    fixtures = output / "certificate-fixtures"
    values = {"source": str(root), "fixtures": str(fixtures), "coverage": str(fixtures / "schema-v8-coverage"),
              "verifierJar": str(output / "acgn-certificate-verifier.jar")}
    claim = base.check_parent(build, phase, manifest, parents[args.parent], args.lean.absolute(),
                              None, args.classpath, values, args.provenance)
    base.write_json(build.path / (args.parent + "-claim.json"), claim)
    # The generic mapped-proof and declaration checks use the same isolated imports.
    # Publish this record only after the full phase passed.
    primary = Path(phase["proof"]).stem
    with (build.path / (primary + ".imports")).open("x", encoding="utf-8") as stream:
        stream.write(args.parent + "-lean-imports\n")
    print(f"{args.parent} {args.main_class}: {len(claim['leanImports'])} audited modules")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, type=Path)
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--output", type=Path)
    action.add_argument("--list-formal-files", action="store_true",
                        help="print the complete governed file inventory")
    parser.add_argument("--lean", type=Path)
    parser.add_argument("--phase-caches", "--ninth-caches", type=Path, action="append", default=[])
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
            env = os.environ.copy()
            indexes = [root_cache / (source_path.stem + ".imports") for root_cache in args.phase_caches]
            records = [idx for idx in indexes if idx.is_file()]
            if len(records) > 1:
                raise SystemExit(f"ambiguous phase import cache for {relative}")
            if records:
                record = records[0]
                cache = record.parent / record.read_text(encoding="utf-8").strip()
                if cache.parent != record.parent or not (cache / (source_path.stem + ".olean")).is_file():
                    raise SystemExit(f"missing or invalid phase import cache for {relative}")
                env["LEAN_PATH"] = str(cache)
            completed = subprocess.run(
                [str(args.lean), str(audit_source)],
                cwd=root, env=env,
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
    if sys.argv[1:2] in (["ninth-phase"], ["tenth-phase"]):
        raise SystemExit(run_registered_phase(sys.argv[1].split("-")[0], sys.argv[2:]))
    raise SystemExit(main())
