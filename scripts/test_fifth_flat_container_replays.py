"""Standalone records plugin tests. Synthetic fixtures are never Java evidence.

python -B scripts/test_fifth_flat_container_replays.py
python -B scripts/test_fifth_flat_container_replays.py --live-root /tmp/records-check
The optional live run uses two fresh snapshots, public Java observations, Lean
positive/negative checks, and all source controls. It is not the shared closure.
"""
from __future__ import annotations

import argparse
import copy
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import unittest

import fifth_flat_container_replays as r
from run_next_obligation_repairs import check_proof_log, proof_inventory, replay_specs, negative_specs, mutation_spec
from run_submission_container_closure import Blocked
from run_fifth_obligation_repairs import check_rejection

ROOT = Path(__file__).resolve().parents[1]
PROOF = "docs/section3-repair-audit/formal/FlatContainerRecords.lean"
OWNED = (PROOF, "docs/obligation-repair/fifth-five/flat-container-notes.md",
         "src/is/fivefivefive/CanDis/theory/FlatContainerRecordsRegressionTest.java",
         "scripts/java/FlatContainerRecordsExtractor.java", "scripts/fifth_flat_container_replays.py",
         "scripts/test_fifth_flat_container_replays.py")
REJECTION_HELPERS = ("scripts/run_fifth_obligation_repairs.py", "scripts/fifth_obligation_replays.py")


def sources():
    return [dict(object=n, owner=("org.acgn.cert." if n == "SemanticEvidenceVerifier" else
        "is.fivefivefive.CanDis.theory.") + n, shapeSha256=p.split()[0], bindingsSha256=p.split()[1])
        for n, p in r.SOURCE_PINS.items()]


def synthetic_binding(name):
    keys = [r.stable("atom", ["0"]), r.stable("atom", ["1"])]
    meta = [] if name.startswith("trace-") else ["certificate", "0"*64, "operator", "0/0"] + (
        ["NODE"] if name.startswith("flat-") else []) + ["target", "left", "right", "owner"]
    return r.wire("bindings", ["operator", "context", "schema", r.stable("operator"),
            r.stable("context"), r.stable("schema"), *meta], [r.wire("ids", ["0", "1"]), r.wire("keys", keys)])


class RecordsPluginTests(unittest.TestCase):
    def test_predeclared_unique_census(self):
        keys = r.expected_keys()
        self.assertEqual(len(keys), 311)
        self.assertEqual(len(set(keys)), 311)
        self.assertEqual(sum(k[1] == "original" for k in keys), 25)
        self.assertEqual(len(r.fixtures()), 25)

    def test_all_frozen_sites_are_exact_and_nonvacuous(self):
        for name, carrier, request in r.fixtures():
            record, _, _ = r.reconstruct(synthetic_binding(name), name, carrier, request)
            for path, ns, nc in r.sites(name):
                node = record
                for part in path.split(".") if path else ():
                    node = node[2][int(part)]
                self.assertEqual((len(node[1]), len(node[2])), (ns, nc))
                for label in r.labels(ns, nc):
                    self.assertNotEqual(r.mutate(record, (path or "root")+":"+label), record)

    def test_independent_order_multiplicity_and_fibers(self):
        xs = [1, 0, 1, 0]
        self.assertEqual(r.normal(0, xs), (xs, [[0], [1], [2], [3]]))
        self.assertEqual(r.normal(1, xs), ([0, 0, 1, 1], [[1], [3], [0], [2]]))
        self.assertEqual(r.normal(2, xs), ([0, 1], [[1, 3], [0, 2]]))
        self.assertEqual(r.normal(2, [0, 0]), ([0], [[0, 1]]))
        for c in range(3):
            self.assertEqual(r.normal(c, []), ([], []))

    def test_recursive_source_association_and_preorder(self):
        b = synthetic_binding("flat-set-0")
        left, _, _ = r.reconstruct(b, "flat-set-0", 2, r.TREES[0])
        right, _, _ = r.reconstruct(b, "flat-set-0", 2, r.TREES[1])
        self.assertNotEqual(left[2][0], right[2][0])
        self.assertEqual(left[2][2], right[2][2])
        self.assertEqual([n[1][0] for n in left[2][1][2]], ["0", "0/0"])
        self.assertNotEqual(left[2][1][2][0][1][4], left[2][1][2][1][1][4])

    def test_missing_extra_duplicate_and_changed_source_pins(self):
        r.source_census(sources())
        for i in range(len(sources())):
            bad = sources(); bad.pop(i)
            with self.assertRaises(Blocked): r.source_census(bad)
            bad = sources(); bad[i]["bindingsSha256"] = "0"*64
            with self.assertRaises(Blocked): r.source_census(bad)
        for bad in (sources()+sources()[:1], sources()[1:]+sources()[1:2]):
            with self.assertRaises(Blocked): r.source_census(bad)

    def test_dictionary_is_lossless_and_fail_closed(self):
        dictionary = ["x"*64, "y"*64]
        self.assertEqual(r.expand(["input", [0, "0"], []], dictionary), r.wire("input", ["x"*64, "0"]))
        for scalar in (-1, 2, True, 1.0, None, "x"*64):
            with self.assertRaises(Blocked): r.expand(["input", [scalar], []], dictionary)
        for value in ("null", "{}", "[ 1]", "[01]"):
            with self.assertRaises(Blocked): r.check_wire(r.parse(value))
        with self.assertRaises(Blocked): r.Lean().atom("ref-0")
        lean = r.Lean()
        self.assertEqual(lean.atom("x"*64), lean.atom("x"*64))
        self.assertNotEqual(lean.atom("x"*64), lean.atom("y"*64))

    def test_structural_preimage_encoding_not_hash_injectivity(self):
        self.assertEqual(r.stable("tag", ["x"]), "3:tag[1:1:x]{0:}")
        self.assertNotEqual(r.stable("tag", ["a", "bc"]), r.stable("tag", ["ab", "c"]))
        with self.assertRaises(Blocked): r.stable("\u03bb")

    def test_source_controls_have_unique_exact_supported_sites(self):
        controls = r.source_mutations()
        self.assertEqual(len(controls), 8)
        self.assertEqual(len({c[0] for c in controls}), 8)
        for record in controls:
            _, path, old, new, _ = mutation_spec(record, {"FlatContainerRecordsExtractor"})
            self.assertEqual((ROOT/path).read_text().count(old), 1, path)
            self.assertNotEqual(old, new)

    def test_registered_rejection_diagnostic(self):
        label = "build1-reject-records-acceptance"
        genuine = "Reject.lean:1:1: error: Tactic `decide` proved that the proposition\n  False\nis false\n"
        check_rejection(label, genuine)
        for suffix in ("Reject.lean:2:1: error: unknown identifier\n",
                       "'failed' depends on axioms: [propext,\n sorryAx]\n"):
            with self.assertRaises(Blocked):
                check_rejection(label, genuine + suffix)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def live(output):
    output = output.resolve()
    if output.exists() or not output.is_relative_to(Path("/tmp")):
        raise ValueError("live output must be a NEW directory under /tmp")
    output.mkdir(parents=True)
    tracked = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode().split("\0")
    paths = sorted(set(p for p in tracked if p and (p.startswith(("src/", "certificate-verifier/src/", "lib/", "scripts/"))
                   or p == "lean-toolchain")) | set(OWNED) | set(REJECTION_HELPERS))
    files = [{"path": p, "sha256": digest(ROOT/p)} for p in paths]
    manifest = json.dumps({"files": files}, sort_keys=True, separators=(",", ":"))
    root_hash = hashlib.sha256(manifest.encode()).hexdigest()
    (output/"manifest.json").write_text(manifest)
    report = {"kind": "standalone-area-tests-not-shared-closure", "inputRootHash": root_hash,
              "builds": [], "commands": [], "trusted": ["Lean 4.33.0 kernel and standard axioms", "JDK17/JVM/javac",
              "Python and bridge encoder", "JSON library", "OS/filesystem/hardware", "SHA256 collision resistance"],
              "excluded": ["universal JVM/byte-parser refinement", "publication authority", "parent ledger discharge"]}
    env = dict(os.environ, ELAN_TOOLCHAIN=(ROOT/"lean-toolchain").read_text().strip(), PYTHONDONTWRITEBYTECODE="1")
    for key in ("JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS", "_JAVA_OPTIONS", "CLASSPATH", "LEAN_PATH"):
        env.pop(key, None)

    def run(label, args, cwd, reject=False, extra=None):
        start = time.monotonic()
        result = subprocess.run(list(map(str, args)), cwd=cwd, env={**env, **(extra or {})},
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=180)
        log = output/(label+".log"); log.write_bytes(result.stdout)
        report["commands"].append({"label": label, "exitCode": result.returncode,
                                   "seconds": round(time.monotonic()-start, 3), "log": log.name})
        if (result.returncode == 0) == reject:
            raise AssertionError(f"unexpected exit {result.returncode}: {log}")
        return log

    try:
        run("java-version", ["java", "-version"], ROOT)
        run("javac-version", ["javac", "-version"], ROOT)
        run("lean-version", ["lean", "--version"], ROOT)
        for build_name in ("A", "B"):
            build = output/build_name; build.mkdir()
            snapshot = build/"snapshot"
            # Reuse existing Git objects only for test-only provenance inspection;
            # no commit is made and all compiler inputs are copied from the manifest.
            run(build_name+"-fixture-git", ["git", "clone", "--quiet", "--shared", "--no-checkout", ROOT, snapshot], ROOT)
            for f in files:
                dest = snapshot/f["path"]; dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(ROOT/f["path"], dest)
                if digest(dest) != f["sha256"]: raise AssertionError("INPUT_MUTATION: "+f["path"])
            classes = build/"classes"; classes.mkdir()
            formal = build/"formal"; formal.mkdir()
            java_sources = sorted(p for d in ("src", "certificate-verifier/src") for p in (snapshot/d).rglob("*.java"))
            run(build_name+"-javac", ["javac", "-J-Xmx1g", "--release", "17", "-proc:none", "-encoding", "UTF-8",
                "-cp", str(snapshot/"lib/*"), "-d", classes, *java_sources], snapshot)
            run(build_name+"-extractor-compile", ["javac", "--release", "17", "-d", classes,
                snapshot/"scripts/java/FlatContainerRecordsExtractor.java"], snapshot)
            cp = str(classes)+os.pathsep+str(snapshot/"lib/*")
            run(build_name+"-extract", ["java", "-Xmx1g", "-cp", classes, "FlatContainerRecordsExtractor", snapshot,
                build/"flat-container-records-source.tsv"], snapshot)
            run(build_name+"-java", ["java", "-ea", "-Xmx1g", "-cp", cp,
                "is.fivefivefive.CanDis.theory.FlatContainerRecordsRegressionTest", build/"flat-container-records.tsv"], snapshot)
            run(build_name+"-unit", [sys.executable, "-B", snapshot/"scripts/test_fifth_flat_container_replays.py"], snapshot)
            spec = importlib.util.spec_from_file_location("records_"+build_name, snapshot/"scripts/fifth_flat_container_replays.py")
            plugin = importlib.util.module_from_spec(spec); spec.loader.exec_module(plugin)
            shutil.copyfile(snapshot/PROOF, formal/"FlatContainerRecords.lean")
            generated = replay_specs(plugin.generate(build, formal), ["FlatContainerRecordsReplay.lean"])
            for name, text, count in generated: (formal/name).write_text(text)
            inventories = {}
            for name in ("FlatContainerRecords.lean", "FlatContainerRecordsReplay.lean"):
                inventory = proof_inventory(formal/name); inventories[name] = inventory
                log = run(build_name+"-"+Path(name).stem, ["lean", "-o", Path(name).with_suffix(".olean"), name],
                          formal, extra={"LEAN_PATH": str(formal)})
                check_proof_log(log, inventory)
            controls = negative_specs(plugin.negatives(build, formal), ["FlatContainerRecords.lean", "FlatContainerRecordsReplay.lean"])
            for i, (label, name, text) in enumerate(controls):
                folder = build/("negative-"+str(i)); folder.mkdir(); (folder/name).write_text(text)
                log = run(build_name+"-"+label, ["lean", name], folder, reject=True, extra={"LEAN_PATH": str(formal)})
                check_rejection(build_name+"-reject-records-"+label, log.read_text())
            for i, (label, path, old, new, extractor) in enumerate(plugin.source_mutations()):
                target = snapshot/path; original = target.read_bytes()
                if original.decode().count(old) != 1: raise AssertionError("ambiguous source mutation")
                stale = build/("source-mutation-"+str(i)+".tsv"); stale.write_text("stale\n")
                try:
                    target.write_text(original.decode().replace(old, new))
                    log = run(build_name+"-"+label, ["java", "-Xmx1g", "-cp", classes, extractor, snapshot, stale], snapshot, reject=True)
                    check_rejection(build_name+"-source-reject-records-"+label, log.read_text())
                    if "UNMODELED_SOURCE:" not in log.read_text() or "JAVAC_RESOLUTION_FAILURE" in log.read_text() or stale.exists():
                        raise AssertionError("not a fail-closed resolved source rejection: "+str(log))
                finally:
                    target.write_bytes(original)
            for f in files:
                if digest(snapshot/f["path"]) != f["sha256"]: raise AssertionError("snapshot INPUT_MUTATION")
            deterministic = ["flat-container-records.tsv", "flat-container-records-source.tsv",
                             "formal/FlatContainerRecordsReplay.lean", "formal/FlatContainerRecords.olean",
                             "formal/FlatContainerRecordsReplay.olean"]
            report["builds"].append({"id": build_name, "observations": len(plugin.expected_keys()),
                "theorems": {name: len(names) for name, names in inventories.items()}, "proofInventory": inventories,
                "leanNegatives": len(controls), "sourceControls": len(plugin.source_mutations()),
                "sha256": {p: digest(build/p) for p in deterministic}})
        if report["builds"][0]["sha256"] != report["builds"][1]["sha256"]:
            raise AssertionError("NONDETERMINISM")
        if report["builds"][0]["proofInventory"] != report["builds"][1]["proofInventory"]:
            raise AssertionError("proof inventory NONDETERMINISM")
        for f in files:
            if digest(ROOT/f["path"]) != f["sha256"]: raise AssertionError("workspace INPUT_MUTATION")
        report["testStatus"] = "PASS"
        report["determinism"] = "PASS"
    except Exception as error:
        report["testStatus"] = "FAIL"
        report["error"] = type(error).__name__+": "+str(error)
        raise
    finally:
        (output/"area-test-report.json").write_text(json.dumps(report, indent=2, sort_keys=True)+"\n")
    print("Two clean records builds passed: " + str(output/"area-test-report.json"))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--live-root", type=Path)
    args = parser.parse_args()
    result = unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(RecordsPluginTests))
    if not result.wasSuccessful(): raise SystemExit(1)
    if args.live_root: live(args.live_root)
