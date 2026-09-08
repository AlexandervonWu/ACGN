"""Bounded checks for the v2.15 profile adapter and frozen dispatcher.

Synthetic observations test orchestration only; actual repair evidence comes
from the registered Java traces and Lean replays in two fresh builds.
"""

import copy
import hashlib
import json
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import run_next_obligation_repairs as previous
import run_fourth_obligation_repairs as profile
import fourth_obligation_replays as replay

ROOT = Path(__file__).resolve().parents[1]


def config():
    return json.loads((ROOT / profile.CONFIG).read_text(encoding="utf-8"))


def theorem(namespace):
    return f"namespace {namespace}\ntheorem valid : True := by trivial\n#print axioms valid\nend {namespace}\n"


def plugin(area):
    return SimpleNamespace(
        generate=lambda build, formal: [(area["replay"], theorem("Fixture." + area["id"]), 1)],
        negatives=lambda build, formal: [("wrong", "Reject.lean", "example : False := by decide\n")],
        source_mutations=lambda: [("guard", "src/Example.java", "original", "mutated", area["extractor"])],
    )


class ProfileTests(unittest.TestCase):
    def test_private_engine_defaults_and_globals_do_not_change_previous_package(self):
        before = dict(previous.__dict__)
        first, second = profile.load_runner(), profile.load_runner()
        self.assertIsNot(first, second)
        self.assertIs(first.execute.__globals__, first.__dict__)
        self.assertIs(previous.execute.__globals__, previous.__dict__)
        self.assertEqual(first.CONFIG, profile.CONFIG)
        self.assertEqual(first.execute.__defaults__, (profile.CONFIG,))
        self.assertEqual(first.inputs.__defaults__, (profile.CONFIG,))
        self.assertEqual(first.PARENTS, profile.PARENTS)
        self.assertEqual(first.PLUGIN, profile.PLUGIN)
        self.assertEqual(set(previous.__dict__), set(before))
        for key, value in before.items():
            self.assertIs(previous.__dict__[key], value, key)

    def test_parent_hashes_match_unchanged_claims(self):
        rows = profile.load_runner().check_matrix(ROOT, config())
        self.assertEqual({p: row["claim_sha256"] for p, row in rows.items()}, profile.PARENT_HASHES)

    def test_required_work_is_exact_and_shared_traces_are_deduplicated(self):
        plan = profile.load_runner().validate_config(config())
        self.assertEqual(plan["proofs"], list(profile.PROOF_DEPENDENCIES) + [a["proof"] for a in replay.AREAS])
        self.assertEqual(set(plan["replays"]), {a["replay"] for a in replay.AREAS})
        for area in replay.AREAS:
            self.assertEqual(sum(t["class"] == area["test"] for t in plan["tests"]), 1)

    def test_predicates_and_authoritative_mappings_cannot_be_weakened(self):
        edits = [lambda c: c.update(requiredCleanBuilds=1), lambda c: c.update(networkDuringVerification=True),
                 lambda c: c.update(profile="other"), lambda c: c.update(replayPlugin=previous.PLUGIN),
                 lambda c: c.update(inputs=[]), lambda c: c.update(trusted=[]),
                 lambda c: c.update(proofDependencies=["Unknown.lean"]),
                 lambda c: c["statusPolicy"].update(manualOverrideAllowed=True),
                 lambda c: c["statusPolicy"].update(warningIsBlocking=False),
                 lambda c: c["phases"][0].update(claimSha256="a" * 64),
                 lambda c: c["phases"][0].update(id="new-id"),
                 lambda c: c["phases"][0].update(passCondition={}),
                 lambda c: c["phases"][0].update(blockConditions=[]),
                 lambda c: c["phases"][0].update(proof="Other.lean"),
                 lambda c: c["phases"][0].update(replays=["Other.lean"]),
                 lambda c: c["phases"][0].update(tests=["example.Test"]),
                 lambda c: c["extractors"].pop(),
                 lambda c: c["extractors"][0].update(source="scripts/java/Other.java")]
        for edit in edits:
            value = config()
            edit(value)
            with self.subTest(edit=edit), self.assertRaises(previous.Blocked):
                profile.load_runner().validate_config(value)

    def test_engine_and_counted_sites_are_hash_pinned(self):
        with patch.object(profile, "BASE_SHA256", "0" * 64), self.assertRaises(previous.Blocked):
            profile.load_runner()
        source = (ROOT / "scripts/run_next_obligation_repairs.py").read_text()
        for altered in (source.replace('"next-five-v2.13-"', '"other-"'),
                        source + '\nextra = "next-five-v2.13-"\n'):
            with self.assertRaises(previous.Blocked):
                profile.adapted_tree(altered, "candidate.py")

    def test_java_and_javac_versions_are_both_checked(self):
        profile.check_java_version("java-version", 'openjdk version "17.0.19" 2026\n')
        profile.check_java_version("javac-version", "javac 17.0.19\n")
        for label, text in (("java-version", 'openjdk version "21.0.1"'),
                            ("java-version", 'unrelated "17.0.1"'),
                            ("javac-version", "javac 170"), ("javac-version", "javac 21.0.1")):
            with self.assertRaises(previous.Blocked):
                profile.check_java_version(label, text)

    def test_rejection_must_reach_false_proposition(self):
        good = 'Reject.lean:3:20: error: Tactic `decide` proved that the proposition\n  False\nis false\n'
        for area in replay.AREAS:
            label = "build1-reject-" + area["id"] + "-wrong"
            profile.check_rejection(label, good)
            profile.check_rejection(label, good + good)
            for bad in ("", "error: unexpected token end", good + "Other.lean:1:2: error: unknown identifier x\n",
                        good.replace("is false\n", ""), good + "warning: ignored\n"):
                with self.assertRaises(previous.Blocked):
                    profile.check_rejection(label, bad)
        with self.assertRaises(previous.Blocked):
            profile.check_rejection("build1-reject-foreign-wrong", good)

    def test_source_rejection_cannot_mask_compilation_or_loader_failure(self):
        good = 'Exception in thread "main" java.lang.IllegalArgumentException: UNMODELED_SOURCE:\n'
        profile.check_rejection("build1-source-reject-chain-field", good)
        for bad in ("compile failed", good + "Example.java:1: error: cannot find symbol\n", good + "unexpected output\n"):
            with self.assertRaises(previous.Blocked):
                profile.check_rejection("build1-source-reject-chain-field", bad)
        for bad in (good + "PANIC runtime error", "Error: Could not find or load main class Missing",
                    "error: unknown module prefix 'Missing'", "OutOfMemoryError"):
            with self.assertRaises(OSError):
                profile.check_rejection("build1-source-reject-chain-field", bad)

    def test_mutual_scopes_keep_theorem_inventory_qualified(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "Proof.lean"
            code = theorem("Outer").replace("theorem valid", "mutual\n  def a : Nat := 0\nend\ntheorem valid")
            path.write_text(code)
            self.assertEqual(profile.load_runner().proof_inventory(path), ["Outer.valid"])
            path.write_text(code.replace("#print axioms valid\n", ""))
            with self.assertRaises(previous.Blocked):
                profile.load_runner().proof_inventory(path)

    def test_fresh_build_differences_block(self):
        base = {key: {"value": "fixed"} for key in (
            "inputRootHash", "fixtureGitCommit", "fixtureGitScope", "proofInventory", "provenance",
            "artifacts", "negativeControls", "controlArtifacts", "sourceMutations")}
        first, second = dict(base, number=1, status="PASS"), dict(base, number=2, status="PASS")
        runner = profile.load_runner()
        runner.compare_builds([first, second])
        for field in base:
            other = copy.deepcopy(second)
            other[field] = {"value": "changed"}
            with self.subTest(field=field), self.assertRaises(previous.Blocked):
                runner.compare_builds([first, other])
        with self.assertRaises(previous.Blocked):
            runner.compare_builds([first])


class DispatcherTests(unittest.TestCase):
    def setUp(self):
        self.dispatcher = replay.load_dispatcher()
        self.plugins = {area["id"]: plugin(area) for area in replay.AREAS}
        loader = patch.object(self.dispatcher, "load_area", side_effect=lambda a: self.plugins[a["id"]])
        loader.start()
        self.addCleanup(loader.stop)

    def test_every_family_runs_and_control_labels_are_disjoint(self):
        generated = self.dispatcher.generate(Path("build"), Path("formal"))
        self.assertEqual([r[0] for r in generated], [a["replay"] for a in replay.AREAS])
        self.assertEqual([r[0] for r in self.dispatcher.negatives(Path("build"), Path("formal"))],
                         [a["id"] + "-wrong" for a in replay.AREAS])
        self.assertEqual([r[0] for r in self.dispatcher.source_mutations()],
                         [a["id"] + "-guard" for a in replay.AREAS])

    def test_missing_census_or_controls_cannot_pass(self):
        for area in replay.AREAS:
            for method in ("generate", "negatives", "source_mutations"):
                with patch.object(self.plugins[area["id"]], method, return_value=[]), \
                        self.subTest(area=area["id"], method=method), self.assertRaises(previous.Blocked):
                    getattr(self.dispatcher, method)(Path("build"), Path("formal"))

    def test_error_is_never_replaced_with_a_successful_replay(self):
        for error in (previous.Blocked("missing observation"), TypeError("encoder bug"), SystemExit(0)):
            with patch.object(self.plugins["chain"], "generate", side_effect=error), self.assertRaises(type(error)):
                self.dispatcher.generate(Path("build"), Path("formal"))

    def test_names_counts_and_namespace_ownership_are_exact(self):
        area = replay.AREAS[1]
        for record in [(area["replay"], theorem("Fixture.container"), 1),
                       (area["replay"], theorem("Fixture.chain"), 2),
                       ("Foreign.lean", theorem("Fixture.chain"), 1)]:
            with patch.object(self.plugins["chain"], "generate", return_value=[record]), \
                    self.assertRaises(previous.Blocked):
                self.dispatcher.generate(Path("build"), Path("formal"))

    def test_source_mutation_stays_with_its_registered_extractor(self):
        original = self.plugins["container"].source_mutations()
        for values in (original * 2, [(*original[0][:4], "SemanticProfileWireExtractor")]):
            with patch.object(self.plugins["container"], "source_mutations", return_value=values), \
                    self.assertRaises(previous.Blocked):
                self.dispatcher.source_mutations()

    def test_dispatcher_pin_and_previous_module_are_unchanged(self):
        import third_obligation_replays as old
        before = dict(old.__dict__)
        dispatcher = replay.load_dispatcher()
        self.assertIsNot(dispatcher, old)
        self.assertNotEqual(dispatcher.AREAS, old.AREAS)
        self.assertEqual(hashlib.sha256((ROOT / "scripts/third_obligation_replays.py").read_bytes()).hexdigest(),
                         replay.BASE_SHA256)
        for key, value in before.items():
            self.assertIs(old.__dict__[key], value)
        with patch.object(replay, "BASE_SHA256", "0" * 64), self.assertRaises(previous.Blocked):
            replay.load_dispatcher()

    def test_missing_area_file_is_blocking(self):
        dispatcher = replay.load_dispatcher()
        with tempfile.TemporaryDirectory() as directory:
            dispatcher.__file__ = str(Path(directory) / "fourth_obligation_replays.py")
            for area in replay.AREAS:
                with self.assertRaises(previous.Blocked):
                    dispatcher.load_area(area)


if __name__ == "__main__":
    unittest.main()
