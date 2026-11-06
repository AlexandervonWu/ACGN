import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

from acgn_repair.corpus_protocol import (task_schedule, check_protocol, stable_counts,
                                         split_for, paired_cluster_interval)
from acgn_repair.experiment import ROOT, argument_parser, sha
from acgn_repair.report_corpus import paired_outcomes


class CorpusTests(unittest.TestCase):
    def test_chunk_coverage_and_determinism(self):
        for tasks in (1, 3, 7):
            for episodes in (1, 5, 9):
                for chunk in (0, 1, 4, 20):
                    plan = task_schedule(tasks, episodes, chunk, 421)
                    jobs = [i * episodes + e for i, nums in plan for e in nums]
                    self.assertEqual(sorted(jobs), list(range(tasks * episodes)))
                    self.assertEqual(plan, task_schedule(tasks, episodes, chunk, 421))
        self.assertEqual(task_schedule(2, 3), [(0, [0, 1, 2]), (1, [0, 1, 2])])
        self.assertNotEqual(task_schedule(7, 9, 4, 421), task_schedule(7, 9, 4, 422))

    def test_lean_schedule_and_count_gate(self):
        rows = [{"learned": 3, "random": 1, "budget": 4, "aborted": 0} for _ in range(5)]
        for chunk in (0, 1, 4):
            result = check_protocol(3, 5, task_schedule(3, 5, chunk, 11), rows)
            self.assertTrue(result["reply"]["stable"])
        for field, value in (("random", 3), ("aborted", 1), ("budget", 2)):
            bad = copy.deepcopy(rows)
            bad[0][field] = value
            self.assertFalse(check_protocol(1, 1, [(0, [0])], bad)["reply"]["stable"])
        self.assertFalse(check_protocol(1, 1, [(0, [0])], rows[:-1])["reply"]["stable"])
        for jobs in ([(0, [0, 0])], [(0, [])], [(1, [0])]):
            with self.assertRaises(ValueError):
                check_protocol(1, 1, jobs)

    def test_stability_rejects_malformed_counts(self):
        for row in ({}, {"learned": True, "random": 0, "budget": 1, "aborted": 0}):
            with self.assertRaises(ValueError):
                stable_counts([row] * 5)

    def test_cluster_resampling_and_pairing(self):
        values = {"a": [1, 1, 0], "b": [1, 0, 1]}
        result = paired_cluster_interval(values)
        self.assertGreater(result["lower"], 0)
        self.assertEqual(result, paired_cluster_interval(values))
        self.assertEqual(paired_cluster_interval({"a": [0], "b": [0]})["lower"], 0)
        with self.assertRaises(ValueError):
            paired_cluster_interval({"a": [2]})

    def test_question_split_and_default_schedule(self):
        keys = [f"problem:inv{i}" for i in range(100)]
        self.assertEqual(set(map(split_for, keys)), {"train", "validation", "evaluation"})
        self.assertEqual(list(map(split_for, keys)), list(map(split_for, keys)))
        parser = argument_parser()
        self.assertEqual(parser.parse_args(["--manifest", "x", "--output", "y", "--classes", "z"]).task_chunk, 0)

    def test_paired_trial_identity(self):
        tasks = [{"id": "a", "group": "q"}]
        rows = [{"mode": m, "task": "a", "group": "q", "episode": 0,
                 "status": "SOLVED_WITHIN_PROFILE" if m == "learned" else "EXHAUSTED", "initialBank": {"hash": "x"}}
                for m in ("learned", "random")]
        counts, paired = paired_outcomes(rows, tasks, 1)
        self.assertEqual(counts, {"learned": 1, "random": 0, "budget": 1, "aborted": 0})
        self.assertEqual(paired, {"q": [1]})
        for bad in (rows[:1], rows + [rows[0]]):
            with self.assertRaises(ValueError):
                paired_outcomes(bad, tasks, 1)
        for field, val in (("status", "ABORTED"), ("group", "other"), ("initialBank", {"hash": "y"})):
            bad = copy.deepcopy(rows)
            bad[0][field] = val
            with self.assertRaises(ValueError):
                paired_outcomes(bad, tasks, 1)

    def test_parser_independent_command_preserves_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "source.als"
            source.write_text("sig S {}\npred inv1 { some S }\npred inv1c { no S }\nrun {} for 3\n")
            original = source.read_bytes()
            output = Path(directory) / "derived.als"
            result = subprocess.check_output(["java", "-cp", os.environ["ACGN_RL_CLASSES"] + ":" + str(ROOT / "lib/*"),
                      "is.fivefivefive.CanDis.RepairCorpusSource", str(source), str(output), "inv1"], text=True)
            metadata = json.loads(result)
            self.assertTrue(output.read_bytes().startswith(original))
            self.assertEqual(source.read_bytes(), original)
            self.assertEqual(metadata["originalHash"], sha(source))
            self.assertEqual(metadata["derivedHash"], sha(output))
            self.assertEqual(metadata["profile"], "appended-independent-run-scope-3")


if __name__ == "__main__":
    unittest.main()
