import itertools
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import torch
from acgn_repair import experiment
from acgn_repair.capacity import (GIB, ResourceLimitError, apply_cuda_budget,
                                  expected_parameters, fits_budget, training_estimate)
from acgn_repair.tune_depth import (RESOURCE_PROOF, lean_smallest_best, load_plan,
                                    smallest_best)


class ResourceTests(unittest.TestCase):
    def test_lean_resource_and_size_tie_matrix(self):
        lean = subprocess.check_output(["lean", "--run", str(RESOURCE_PROOF)], text=True, timeout=30)
        rows = [f"RESOURCE,{p},{r},{b},{str(fits_budget(p, r, b)).lower()}"
                for p, r, b in itertools.product((0, 1, 10, 100), (0, 32), (0, 16, 24, 32, 240, 2432))]
        rows += [f"SELECT,{a},{pa},{b},{pb},{smallest_best([a, b], [pa, pb])}"
                 for a, b, pa, pb in itertools.product(range(3), range(3), (10, 20, 30), (10, 20, 30))]
        self.assertEqual(len(rows), 129)
        self.assertEqual(lean, "\n".join(rows) + "\n")
        self.assertEqual(lean_smallest_best([2, 4, 4, 3], [1, 40, 20, 10]), 2)
        self.assertEqual(lean_smallest_best([4, 4, 4], [20, 20, 20]), 0)

    def test_budget_inputs_and_wide_plan(self):
        for values in ((-1, 0, 1), (1, -1, 1), (1, 0, -1), (True, 0, 1), (1, 0, 1.5)):
            with self.assertRaises(ValueError):
                fits_budget(*values)
        for scores, parameters in (([1], []), ([1], [-1]), ([1], [True]), ([], [])):
            with self.assertRaises(ValueError):
                smallest_best(scores, parameters)
        plan = load_plan(experiment.ROOT / "docs/rl-repair/wide-tuning-grid.json")
        self.assertEqual([c["hidden"] for c in plan], [64, 1024, 2048, 4096])
        for family in ("mpnn", "gcn", "gat", "gin"):
            for c in plan:
                self.assertTrue(fits_budget(expected_parameters(family, c["hidden"], c["layers"]), GIB, 10 * GIB))
            for width in (8192, 16384):
                self.assertFalse(fits_budget(expected_parameters(family, width, 2), GIB, 10 * GIB))
        self.assertEqual(training_estimate(10, 0), 240)

    def test_cuda_budget_enforcement_arguments_and_headroom(self):
        snapshot = {"deviceFreeBytes": 14 * GIB, "deviceTotalBytes": 16 * GIB}
        with patch("acgn_repair.capacity.cuda_memory_snapshot", return_value=snapshot), \
             patch("torch.cuda.current_device", return_value=0), \
             patch("torch.cuda.set_per_process_memory_fraction") as limit:
            result = apply_cuda_budget("cuda", "gcn", 4096, 2, 10 * GIB)
            limit.assert_called_once_with(10 / 16, 0)
            self.assertEqual(result["limitBytes"], 10 * GIB)
            self.assertFalse(result["estimateIsPeakBound"])
            with self.assertRaisesRegex(ResourceLimitError, "estimate"):
                apply_cuda_budget("cuda", "gcn", 8192, 2, 10 * GIB)
            snapshot["deviceFreeBytes"] = 10 * GIB
            with self.assertRaisesRegex(ResourceLimitError, "headroom"):
                apply_cuda_budget("cuda", "gcn", 64, 2, 10 * GIB)
        with self.assertRaisesRegex(ValueError, "CUDA device"):
            apply_cuda_budget("cpu", "gcn", 64, 2, 10 * GIB)

    def test_live_cuda_limit_accepts_indexless_device(self):
        index = torch.cuda.current_device()
        previous = torch.cuda.get_per_process_memory_fraction(index)
        try:
            torch.cuda.empty_cache()
            result = apply_cuda_budget("cuda", "gcn", 64, 2, 10 * GIB)
            self.assertAlmostEqual(torch.cuda.get_per_process_memory_fraction(index),
                                   10 * GIB / result["deviceBeforeLimit"]["deviceTotalBytes"])
            allocation = torch.ones(1024, device="cuda")
            self.assertEqual(float(allocation.sum()), 1024)
        finally:
            torch.cuda.set_per_process_memory_fraction(previous, index)

    def test_resource_failure_exit_is_not_semantic_negative(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "run"
            args = ["experiment", "--manifest", "x", "--classes", "y", "--output", str(output)]

            def fail(_):
                output.mkdir()
                raise torch.cuda.OutOfMemoryError("bounded injected allocator failure")

            with patch("sys.argv", args), patch.object(experiment, "run", side_effect=fail):
                with self.assertRaises(SystemExit) as result:
                    experiment.main()
            self.assertEqual(result.exception.code, 75)
            recorded = json.loads((output / "resource-limit.json").read_text())
            self.assertEqual(recorded["status"], "RESOURCE_LIMIT")
            self.assertFalse(recorded["semanticNegative"])

    def test_forward_oom_stops_after_first_episode_and_closes_worker(self):
        classes = Path(os.environ["ACGN_RL_CLASSES"])
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "run"
            args = experiment.argument_parser().parse_args([
                "--manifest", str(experiment.ROOT / "docs/rl-repair/fixtures/pilot.json"),
                "--classes", str(classes), "--output", str(output), "--episodes", "2"])
            workers = []
            original = experiment.JavaWorker

            def worker(*a, **kw):
                instance = original(*a, **kw)
                workers.append(instance)
                return instance

            with patch.object(experiment, "JavaWorker", side_effect=worker), \
                 patch.object(experiment.StructuredPolicy, "forward",
                              side_effect=torch.cuda.OutOfMemoryError("bounded injected forward failure")):
                with self.assertRaises(ResourceLimitError):
                    experiment.run(args)
            episodes = json.loads((output / "episodes.json").read_text())
            self.assertEqual(len(episodes), 1)
            self.assertEqual(episodes[0]["status"], "ABORTED")
            self.assertNotIn("update", episodes[0])
            self.assertEqual(len(workers), 1)
            self.assertIsNotNone(workers[0].process.poll())
            self.assertFalse((output / "summary.json").exists())


if __name__ == "__main__":
    unittest.main()
