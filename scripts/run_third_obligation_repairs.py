#!/usr/bin/env python3
"""Third-five profile of the unchanged v2.13 two-build closure engine.

An enumerated set of package literals, the Lean scope-inventory grammar, and
PARENTS are adapted in a private module. No imported next-five module, source
file or report is modified. Use an unused evidence directory outside --root.
"""

from __future__ import annotations

import ast
from collections import Counter
import hashlib
from pathlib import Path
import re
import sys
from types import ModuleType

sys.dont_write_bytecode = True
from run_submission_container_closure import Blocked
from third_obligation_replays import AREAS

PACKAGE = Path("docs/obligation-repair/third-five")
CONFIG = PACKAGE / "closure-config.json"
PLUGIN = "scripts/third_obligation_replays.py"
BASE_SHA256 = "d3006d1b0e093cd7fc5e9c277c19a36e0828329dc6c4f3cacff7201ef8c48f55"
PARENT_HASHES = {
    "P1-06": "30fb21fcb2a524cc57aa6a240c4380ce349da552b012527be9e41ff988e810f9",
    "P1-09": "88fab51f179dd66df7b0703a9e3d93dac32ffde6432e699709e6ce3ab9bb02d3",
    "P1-16": "2ff9bdd7b3b7112086c0a821d74da9c49a16620a39e6ab62f8b348e4a8d6e052",
    "P2-19": "19ae22028dc1c50a3f7b92d54a236e8696c1b389ef204e6c5ae764cdab60a354",
    "A2-04": "e5ed1e70cefbc417e2046ae878201b4c371f9e2223ed11f91e371d4658541e3d",
}
PARENTS = frozenset(PARENT_HASHES)
PROOF_DEPENDENCIES = ("DependentChainSequence.lean", "DependentJoinGuard.lean", "PhaseA2DependentChains.lean")
GENERATED_AUDITS = {"PhaseA2DependentChains.lean": "ACGN.Section3.PhaseA2"}
AREA_TESTS = tuple("scripts/test_" + area["plugin"] for area in AREAS)
NOTES = ("call-notes.md", "join-notes.md", "registry-notes.md", "harness-notes.md")
REQUIRED_INPUTS = frozenset({
    "scripts/run_third_obligation_repairs.py", "scripts/test_third_obligation_repairs.py", PLUGIN,
    *(str(PACKAGE / name) for name in NOTES), *AREA_TESTS,
    *("scripts/" + area["plugin"] for area in AREAS),
})
PASS_CONDITION = {
    "type": "all",
    "checks": ["original-parent-hash", "frozen-inputs-and-verifiers", "audited-lean-proofs",
               "all-configured-java-tests", "strict-area-censuses", "kernel-checked-replays",
               "negative-and-source-controls-exit-1", "two-fresh-builds",
               "deterministic-artifacts-and-provenance", "bound-machine-evidence"],
}
BLOCK_CONDITIONS = [
    "CLAIM_MUTATION", "INPUT_MUTATION", "UNDECLARED_DEPENDENCY", "VERIFIER_FAILURE",
    "VERIFIER_NOT_RUN", "STALE_OR_UNBOUND_EVIDENCE", "UNMAPPED_IMPLEMENTATION_OBJECT",
    "AMBIGUOUS_CORRESPONDENCE", "MISSING_WITNESS", "WITNESS_INVALID", "CLEAN_BUILD_FAILURE",
    "NONDETERMINISM", "ORPHAN_CLAIM", "SCOPE_LEAK",
]


def check_rejection(label, content):
    """A failed control must reach its registered semantic/structural check."""
    if re.search(r"Could not find or load main class|ClassNotFoundException|unknown module prefix|"
                 r"object file .* does not exist|no such file or directory|\bPANIC\b|"
                 r"OutOfMemoryError|StackOverflowError|Segmentation fault", content, re.I):
        raise OSError("Control infrastructure failure: " + label)
    source = re.search(r"(?:^|-)source-reject-(call|join|registry)-", label)
    if source:
        messages = {
            "call": ("UNMODELED_SOURCE:",),
            "registry": ("Unregistered registry source shape/binding:",),
            "join": ("Wrong interior guard", "Unmodeled guard structure/effect",
                     "Unmodeled JOIN structure/resolution:", "Foreign signature/modifiers:"),
        }
        first = content.splitlines()[0] if content else ""
        prefix = 'Exception in thread "main" java.lang.IllegalArgumentException: '
        valid = any(first.startswith(prefix + message) for message in messages[source[1]])
        valid = valid and all(re.fullmatch(
            r"[A-Za-z_][\w.-]* observed [0-9a-f]{64} [0-9a-f]{64}|\tat [^\n]+|", line)
            for line in content.splitlines()[1:])
    else:
        valid = bool(re.search(r"(?:^|-)reject-(call|join|registry)-", label))
        in_proposition, errors = False, 0
        for line in content.splitlines():
            if in_proposition:
                if line == "is false":
                    in_proposition = False
                elif not line.startswith((" ", "\t")):
                    valid = False
            elif re.fullmatch(r"[^\n]+\.lean:\d+:\d+: error: Tactic `decide` proved that the proposition", line):
                in_proposition = True
                errors += 1
            elif line and not re.fullmatch(r"'[^']+' (?:does not depend on any axioms|depends on axioms: \[[^\n]*\])", line):
                valid = False
        valid = valid and errors > 0 and not in_proposition
    if not valid:
        raise Blocked("VERIFIER_FAILURE: unrelated rejection diagnostic: " + label)


def check_java_version(label, content):
    patterns = {"java-version": r'(?:openjdk|java) version "17(?:[.\-+\"]|$)',
                "javac-version": r'javac 17(?:[.\-+\s]|$)'}
    if label in patterns and not re.match(patterns[label], content):
        raise Blocked("UNDECLARED_DEPENDENCY: JDK 17 required: " + label)

# Values are (replacement, required AST occurrence count), not textual rewrites.
LITERALS = {
    "docs/obligation-repair/next-five": (str(PACKAGE), 1),
    "scripts/next_obligation_replays.py": (PLUGIN, 1),
    "scripts/test_next_obligation_repairs.py": ("scripts/test_third_obligation_repairs.py", 2),
    "[next-five] ": ("[third-five] ", 1),
    "_next_obligation_replays_": ("_third_obligation_replays_", 1),
    "next-five-v2.13-": ("third-five-v1-", 1),
    # These occur only in the two package-input globs. Notes are explicit inputs.
    "*.json": ("closure-config.json", 1),
    "*.tsv": ("closure-config.json", 1),
    r"\s*(namespace|section)(?:\s+([\w'.]+))?\s*":
        (r"\s*(namespace|section|mutual)(?:\s+([\w'.]+))?\s*", 1),
}


def adapted_tree(source, filename):
    tree = ast.parse(source, filename=filename)
    counts = Counter()
    for node in ast.walk(tree):
        if isinstance(node, ast.Constant) and isinstance(node.value, str) and node.value in LITERALS:
            old = node.value
            node.value = LITERALS[old][0]
            counts[old] += 1
    if counts != Counter({old: count for old, (_, count) in LITERALS.items()}):
        raise Blocked("UNDECLARED_DEPENDENCY: v2.13 literal adaptation sites changed")
    return tree


def area_test_paths(root):
    for relative in AREA_TESTS:
        if not (root / relative).is_file():
            raise Blocked("MISSING_INPUT: unavailable area encoder suite: " + relative)
    return sorted(path for path in (root / "scripts").glob("test_third_*.py")
                  if path.name != "test_third_obligation_repairs.py")


def load_runner():
    """Create a fresh namespace; function defaults are compiled for this profile."""
    path = Path(__file__).with_name("run_next_obligation_repairs.py")
    source = path.read_bytes()
    if hashlib.sha256(source).hexdigest() != BASE_SHA256:
        raise Blocked("UNDECLARED_DEPENDENCY: unsupported v2.13 engine hash")
    module = ModuleType("_third_five_engine")
    module.__file__ = str(path)
    tree = adapted_tree(source.decode("utf-8"), str(path))
    exec(compile(tree, str(path), "exec"), module.__dict__)
    module.PARENTS = PARENTS
    module.__doc__ = __doc__
    base_validate, base_inputs, base_inventory = module.validate_config, module.inputs, module.proof_inventory
    base_commands = module.Commands

    class Commands(base_commands):
        def run(self, label, argv, cwd, extra=None, reject=False):
            log = super().run(label, argv, cwd, extra, reject)
            try:
                if reject:
                    check_rejection(label, log.read_text(encoding="utf-8"))
                if label in ("java-version", "javac-version"):
                    check_java_version(label, log.read_text(encoding="utf-8"))
            except (Blocked, OSError) as error:
                self.report["commands"][-1]["status"] = (
                    "BLOCKED" if isinstance(error, Blocked) else "INFRASTRUCTURE_FAILURE")
                raise
            if label == "plugin-tests":
                for path in area_test_paths(cwd):
                    super().run("area-tests-" + path.stem, [sys.executable, path], cwd)
            return log

    def validate_config(config):
        plan = base_validate(config)
        require = module.require
        require(config.get("replayPlugin") == PLUGIN, "third-five aggregator is required")
        require(config.get("profile") == "third-five-v1", "unknown third-five profile")
        require(REQUIRED_INPUTS <= set(config.get("inputs", [])), "missing third-five frozen dependency")
        require(config.get("proofDependencies") == list(PROOF_DEPENDENCIES)
                and config.get("generatedDependencyAudits") == GENERATED_AUDITS,
                "third-five Lean dependencies/audits changed", "UNDECLARED_DEPENDENCY")
        for phase in config["phases"]:
            parent = phase["parent"]
            area = next(area for area in AREAS if parent in area["parents"])
            require(phase["id"] == "TF-" + parent and phase["claimSha256"] == PARENT_HASHES[parent],
                    "third-five original parent identity changed", "CLAIM_MUTATION")
            require(phase.get("passCondition") == PASS_CONDITION
                    and phase.get("blockConditions") == BLOCK_CONDITIONS,
                    "third-five predicates must be frozen before execution", "CLAIM_MUTATION")
            require(phase["proof"] == area["proof"] and phase["replays"] == [area["replay"]],
                    "third-five area mapping changed", "UNMAPPED_IMPLEMENTATION_OBJECT")
            tests = [module.test_spec(test) for test in phase["tests"]]
            require({"class": area["test"], "args": [], "output": area["trace"]} in tests,
                    "missing area trace test", "MISSING_WITNESS")
        require({item["class"] for item in config["extractors"]} == {area["extractor"] for area in AREAS},
                "third-five extractor census changed", "UNMAPPED_IMPLEMENTATION_OBJECT")
        for area in AREAS:
            extractor = next(item for item in config["extractors"] if item["class"] == area["extractor"])
            require(extractor["source"] == "scripts/java/" + area["extractor"] + ".java"
                    and extractor["output"] == area["sourceTrace"], "third-five extractor mapping changed")
        return dict(plan, proofs=[*PROOF_DEPENDENCIES, *plan["proofs"]])

    def inputs(root, config, config_path=CONFIG):
        manifest = base_inputs(root, config, config_path)
        for name in PROOF_DEPENDENCIES:
            relative = str(module.FORMAL / name)
            module.require(relative in manifest, "missing proof dependency: " + name, "MISSING_INPUT")
        return dict(sorted(manifest.items()))

    def proof_inventory(path):
        if path.name in GENERATED_AUDITS:
            source = path.parent.parent / "source" / module.FORMAL / path.name
            original = source.read_text(encoding="utf-8")
            module.scan_proof(source)
            private = re.findall(r"(?m)^\s*private\s+(?:theorem|lemma)\s+([A-Za-z_][\w'.]*)",
                                 module.strip_lean_comments(original))
            # The compiled source retains privacy. Only the inventory view
            # exposes these declarations to the inherited completeness scanner.
            visible = re.sub(r"(?m)^(\s*)private(?=\s+(?:theorem|lemma)\s)", r"\1", original)
            class InventoryView:
                name = path.name

                def read_text(self, encoding="utf-8"):
                    return visible

            names = module.scan_proof(InventoryView())
            audited = original + "\n" + "".join(
                "#print axioms " + GENERATED_AUDITS[path.name] + "." + name + "\n" for name in names)
            current = path.read_text(encoding="utf-8")
            module.require(current in (original, audited), "dependency audit input changed", "INPUT_MUTATION")
            if current == original:
                path.write_text(audited, encoding="utf-8")
            visible = re.sub(r"(?m)^(\s*)private(?=\s+(?:theorem|lemma)\s)", r"\1", audited)
            qualified = {GENERATED_AUDITS[path.name] + "." + name for name in private}
            # Lean's actual axiom output must match these private declaration IDs.
            return [f"_private.{path.stem}.0.{name}" if name in qualified else name
                    for name in base_inventory(InventoryView())]
        return base_inventory(path)

    module.validate_config = validate_config
    module.inputs = inputs
    module.proof_inventory = proof_inventory
    module.Commands = Commands
    return module


def execute(root, output, config_path=CONFIG):
    return load_runner().execute(root, output, config_path)


if __name__ == "__main__":
    sys.exit(load_runner().main())
