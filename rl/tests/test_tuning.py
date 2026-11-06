import copy
import itertools
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

from acgn_repair.experiment import ROOT, argument_parser, load_tasks
from acgn_repair.tune_depth import (PROOF, lean_select, load_plan, select_index,
                                   validate_seeds, validation_scores)


class TuningTests(unittest.TestCase):
    def test_lean_selection_matrix(self):
        lean = subprocess.check_output(["lean", "--run", str(PROOF)], text=True, timeout=30)
        rows = [f"TUNE,{':'.join(map(str, scores))},{select_index(scores)}"
                for n in (1, 2, 3) for scores in itertools.product(range(4), repeat=n)]
        self.assertEqual(len(rows), 84)
        self.assertEqual(lean, "\n".join(rows) + "\n")
        self.assertEqual(lean_select([0, 12, 12, 1]), 1)

    def test_selection_rejects_invalid_scores(self):
        for scores in ([], [-1, 0], [True, 1], [0.5, 1]):
            with self.assertRaises(ValueError):
                select_index(scores)
        self.assertEqual(select_index([3, 3, 3]), 0)

    def test_three_splits_and_no_cross_split_duplicates(self):
        tasks = load_tasks(ROOT / "docs/rl-repair/fixtures/depth_tuning.json")
        self.assertEqual({t["split"] for t in tasks}, {"train", "validation", "evaluation"})
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "tasks.json"
            for field in ("path", "group"):
                changed = copy.deepcopy(tasks)
                changed[2][field] = changed[0][field]
                path.write_text(json.dumps({"schemaVersion": 1, "tasks": changed}))
                with self.assertRaisesRegex(ValueError, "leakage"):
                    load_tasks(path)

    def test_final_seeds_are_fresh_and_unique(self):
        validate_seeds([42, 43], [101, 102, 103])
        for a, b in (([], [1]), ([1, 1], [2]), ([1], [1]), ([1], [2, 2]), ([-1], [2])):
            with self.assertRaises(ValueError):
                validate_seeds(a, b)

    def test_plan_bounds_and_duplicate_settings(self):
        plan = ROOT / "docs/rl-repair/tuning-grid.json"
        self.assertEqual([c["layers"] for c in load_plan(plan)], [2, 4, 4, 6])
        original = json.loads(plan.read_text())
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "plan.json"
            for field, value in (("layers", 0), ("layers", 9), ("hidden", 31), ("hidden", 16385), ("lr", float("nan")), ("lr", 0)):
                changed = copy.deepcopy(original)
                changed["configurations"][0][field] = value
                path.write_text(json.dumps(changed))
                with self.assertRaises(ValueError):
                    load_plan(path)
            changed = copy.deepcopy(original)
            changed["configurations"][1] = {**changed["configurations"][0], "id": "duplicate-settings"}
            path.write_text(json.dumps(changed))
            with self.assertRaisesRegex(ValueError, "Duplicate"):
                load_plan(path)

    def test_selection_blocks_censoring_and_ignores_test_scores(self):
        candidates = [{"id": "a"}, {"id": "b"}]
        rows = [{"stage": "validation", "encoder": "gcn", "configuration": c["id"], "seed": seed,
                 "status": "COMPLETE", "summary": {"groups": {"learned": {
                     "episodes": 6, "solved": i + 1, "aborted": 0, "initialSolved": 0}}}}
                for i, c in enumerate(candidates) for seed in (42, 43)]
        self.assertEqual(validation_scores(rows, "gcn", candidates, [42, 43], 6), [2, 4])
        test = copy.deepcopy(rows[0])
        test["stage"] = "evaluation"
        test["summary"]["groups"]["learned"]["solved"] = 1000
        self.assertEqual(validation_scores(rows + [test], "gcn", candidates, [42, 43], 6), [2, 4])
        for bad in (rows[:-1], rows + [rows[0]]):
            with self.assertRaises(ValueError):
                validation_scores(bad, "gcn", candidates, [42, 43], 6)
        for field, value in (("episodes", 5), ("aborted", 1), ("initialSolved", 1)):
            bad = copy.deepcopy(rows)
            bad[0]["summary"]["groups"]["learned"][field] = value
            with self.assertRaises(ValueError):
                validation_scores(bad, "gcn", candidates, [42, 43], 6)

    def test_default_split_is_backward_compatible(self):
        parser = argument_parser()
        flags = ["--manifest", "x", "--output", "y", "--classes", "z"]
        self.assertEqual(parser.parse_args(flags).eval_split, "evaluation")
        self.assertEqual(parser.parse_args(flags + ["--eval-split", "validation"]).eval_split, "validation")


if __name__ == "__main__":
    unittest.main()
