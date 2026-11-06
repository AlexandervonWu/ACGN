import os
from pathlib import Path
import subprocess
import unittest
import torch

from acgn_repair.capacity import capacity_statistics, cuda_memory_snapshot, expected_parameters
from acgn_repair.encoders import ENCODERS
from acgn_repair.experiment import ROOT
from acgn_repair.model import StructuredPolicy
from acgn_repair.tune_depth import load_plan


class CapacityTests(unittest.TestCase):
    def test_lean_matches_actual_module_parameter_counts(self):
        lean = subprocess.check_output(["lean", "--run", str(ROOT / "docs/rl-repair/formal/PolicyCapacity.lean")],
                                       text=True, timeout=30)
        rows = []
        for family in ENCODERS:
            for width in (8, 32, 64, 96, 256, 512, 1024, 2048, 4096, 8192, 16384):
                for depth in (1, 2, 4, 6, 8):
                    with torch.device("meta"):
                        model = StructuredPolicy(width, depth, family, 8)
                    stats = capacity_statistics(model)
                    self.assertEqual(stats["parameterCount"], expected_parameters(family, width, depth))
                    rows.append(f"CAPACITY,{family},{width},{depth},{stats['parameterCount']},"
                                f"{stats['parameterBytes']},{stats['nominalParameterGradientAdamBytes']}")
        self.assertEqual(len(rows), 275)
        self.assertEqual(lean, "\n".join(rows) + "\n")

    def test_capacity_rejects_drift_and_non_fp32(self):
        model = StructuredPolicy(8, 1)
        self.assertEqual(capacity_statistics(model)["parameterBytes"], expected_parameters("mpnn", 8, 1) * 4)
        with self.assertRaisesRegex(ValueError, "FP32"):
            capacity_statistics(model.double())
        model.float()
        model.extra = torch.nn.Parameter(torch.ones(1))
        with self.assertRaisesRegex(ValueError, "layout"):
            capacity_statistics(model)
        for values in (("unknown", 64, 4), ("gcn", 0, 4), ("gcn", 64, -1), ("gcn", True, 4)):
            with self.assertRaises(ValueError):
                expected_parameters(*values)

    def test_cuda_allocated_reserved_and_cpu_not_available(self):
        self.assertIsNone(cuda_memory_snapshot("cpu"))
        device = os.environ.get("ACGN_RL_DEVICE", "cuda")
        if device != "cuda" or not torch.cuda.is_available():
            raise RuntimeError("CUDA memory check cannot silently fall back")
        allocation = torch.ones(1024 * 1024, device=device)
        snapshot = cuda_memory_snapshot(device)
        self.assertGreaterEqual(snapshot["allocatedBytes"], allocation.numel() * allocation.element_size())
        self.assertGreaterEqual(snapshot["reservedBytes"], snapshot["allocatedBytes"])
        self.assertGreaterEqual(snapshot["peakAllocatedBytes"], snapshot["allocatedBytes"])
        self.assertGreaterEqual(snapshot["peakReservedBytes"], snapshot["reservedBytes"])
        self.assertGreaterEqual(snapshot["deviceTotalBytes"], snapshot["deviceFreeBytes"])

    def test_large_plan_is_admitted_and_has_real_capacity_increase(self):
        plan = load_plan(ROOT / "docs/rl-repair/large-tuning-grid.json")
        self.assertEqual([c["hidden"] for c in plan], [64, 256, 512, 1024])
        for family in ENCODERS:
            counts = [expected_parameters(family, c["hidden"], c["layers"]) for c in plan]
            self.assertEqual(counts, sorted(counts))
            self.assertGreater(counts[-1], counts[0] * 50)


if __name__ == "__main__":
    unittest.main()
