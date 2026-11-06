import copy
import unittest
from unittest.mock import patch

import torch

from experiments.hybrid_edit.batching import BatchPlan, accumulate_gradients, evaluate_batch, update_batch
from experiments.hybrid_edit.batch_probe import synthetic_batch
from experiments.hybrid_edit.model import Config, HybridEditTransformer


class BatchingTests(unittest.TestCase):
    def setUp(self):
        torch.manual_seed(19)
        torch.set_num_threads(2)
        self.config = Config(vocab=128, width=32, layers=2, heads=4, kv_heads=2,
                             head_dim=8, ff=64, group_size=8, max_tokens=16)
        self.batch, self.metadata = synthetic_batch(7, 12, 23, "cpu")

    def test_plan_covers_requested_and_uneven_batches(self):
        for total, micro, passes in ((128, 8, 16), (96, 8, 12), (64, 4, 16), (7, 3, 3)):
            plan = BatchPlan(total, micro)
            self.assertEqual(len(plan.slices()), passes)
            self.assertEqual(sum(plan.chunk_sizes()), total)
            self.assertEqual([i for s in plan.slices() for i in range(s.start, s.stop)], list(range(total)))
        for total, micro in ((0, 1), (4, 0), (4, 5), (True, 1)):
            with self.assertRaises(ValueError):
                BatchPlan(total, micro)

    def test_full_and_uneven_accumulated_gradients_match(self):
        full = HybridEditTransformer(self.config, checkpoint_blocks=True)
        accumulated = copy.deepcopy(full)
        a = accumulate_gradients(full, self.batch, BatchPlan(7, 7))
        b = accumulate_gradients(accumulated, self.batch, BatchPlan(7, 3))
        self.assertAlmostEqual(a, b, places=5)
        for (name, x), y in zip(full.named_parameters(), accumulated.parameters()):
            self.assertTrue(torch.allclose(x.grad, y.grad, atol=2e-6, rtol=2e-5), name)

    def test_accumulated_adafactor_step_matches_full_batch(self):
        full = HybridEditTransformer(self.config)
        accumulated = copy.deepcopy(full)
        optimizer_a = torch.optim.Adafactor(full.parameters(), lr=0.001, foreach=False)
        optimizer_b = torch.optim.Adafactor(accumulated.parameters(), lr=0.001, foreach=False)
        update_batch(full, optimizer_a, self.batch, BatchPlan(7, 7))
        with patch.object(optimizer_b, "step", wraps=optimizer_b.step) as step:
            update_batch(accumulated, optimizer_b, self.batch, BatchPlan(7, 3))
            self.assertEqual(step.call_count, 1)
        for (name, x), y in zip(full.named_parameters(), accumulated.parameters()):
            self.assertTrue(torch.allclose(x, y, atol=2e-6, rtol=2e-5), name)
        self.assertTrue(all(state["step"].item() == 1 for state in optimizer_b.state.values()))

    def test_failure_clears_partial_gradients_without_optimizer_step(self):
        model = HybridEditTransformer(self.config)
        optimizer = torch.optim.Adafactor(model.parameters(), foreach=False)
        before = copy.deepcopy(model.state_dict())
        batch = dict(self.batch, value=self.batch["value"].clone())
        batch["value"][4] = float("nan")
        with patch.object(optimizer, "step", wraps=optimizer.step) as step:
            with self.assertRaises(ValueError):
                update_batch(model, optimizer, batch, BatchPlan(7, 3))
            self.assertEqual(step.call_count, 0)
        self.assertTrue(all(p.grad is None for p in model.parameters()))
        self.assertTrue(all(torch.equal(before[k], v) for k, v in model.state_dict().items()))

    def test_fixture_identity_and_evaluation_mode_restoration(self):
        repeat, metadata = synthetic_batch(7, 12, 23, "cpu")
        self.assertEqual(metadata, self.metadata)
        self.assertEqual(metadata["unique_token_packets"], 7)
        self.assertTrue(torch.equal(repeat["tokens"], self.batch["tokens"]))
        model = HybridEditTransformer(self.config)
        evaluate_batch(model, self.batch, BatchPlan(7, 3))
        self.assertTrue(model.training)
        self.assertTrue(all(p.grad is None for p in model.parameters()))

    def test_size_mismatch_is_not_implicitly_truncated(self):
        model = HybridEditTransformer(self.config)
        with self.assertRaises(ValueError):
            accumulate_gradients(model, self.batch, BatchPlan(6, 3))


if __name__ == "__main__":
    unittest.main()
