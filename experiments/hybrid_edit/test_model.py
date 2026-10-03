import dataclasses
import io
import unittest

import torch

from experiments.hybrid_edit.model import (
    Config, HybridEditTransformer, candidates, fake_quant_weight, optimal_set_loss,
    pack_nibbles, quantize_groups, unpack_nibbles,
)


def tiny_config(bits=16):
    return Config(vocab=64, width=64, layers=2, heads=4, kv_heads=2,
                  head_dim=16, ff=128, weight_bits=bits, group_size=16, max_tokens=32)


class ModelTests(unittest.TestCase):
    def setUp(self):
        torch.manual_seed(19)
        torch.set_num_threads(2)

    def fixture(self):
        tokens = torch.randint(0, 64, (2, 12))
        pointers = torch.tensor([[3, 6, 9], [3, 6, 9]])
        legal = torch.tensor([[True, True, False], [True, True, True]])
        return tokens, pointers, legal

    def test_config_rejects_incoherence(self):
        for args in ({"heads": 5}, {"weight_bits": 3}, {"group_size": 0},
                     {"ff": 130}, {"max_tokens": 0}, {"kv_heads": 3}):
            with self.subTest(args=args), self.assertRaises(ValueError):
                dataclasses.replace(tiny_config(), **args)

    def test_candidate_counts_without_allocating_billions(self):
        expected = {16: 1642208256, 24: 2447563776, 32: 3252919296,
                    40: 4058274816, 48: 4863630336}
        self.assertEqual(len(candidates()), 8)
        for name, config in candidates().items():
            with self.subTest(candidate=name), torch.device("meta"):
                model = HybridEditTransformer(config)
                self.assertEqual(sum(p.numel() for p in model.parameters()), config.parameters())
                self.assertEqual(config.parameters(), expected[config.layers])
                self.assertTrue(all(p.requires_grad for p in model.parameters()))
        sizes = [Config(weight_bits=b).packed_weight_bytes() for b in (4, 8, 16)]
        self.assertEqual(sizes, sorted(sizes))

    def test_all_256_nibble_pairs_and_odd_padding(self):
        low = torch.arange(16, dtype=torch.uint8).repeat_interleave(16)
        high = torch.arange(16, dtype=torch.uint8).repeat(16)
        codes = torch.stack((low, high), -1).flatten()
        packed = pack_nibbles(codes)
        self.assertEqual(torch.unique(packed).numel(), 256)
        self.assertTrue(torch.equal(unpack_nibbles(packed, codes.numel()), codes))
        for length in (0, 1, 3, 127):
            codes = torch.randint(0, 16, (length,), dtype=torch.uint8)
            self.assertTrue(torch.equal(unpack_nibbles(pack_nibbles(codes), length), codes))
        with self.assertRaises(ValueError):
            pack_nibbles(torch.tensor([16], dtype=torch.uint8))
        with self.assertRaises(ValueError):
            unpack_nibbles(torch.tensor([255], dtype=torch.uint8), 1)

    def test_int4_weight_storage_and_zero_groups(self):
        weights = torch.randn(4, 32)
        weights[0].zero_()
        codes, scale = quantize_groups(weights, 4, 16)
        packed = pack_nibbles((codes.flatten() + 8).to(torch.uint8))
        recovered = unpack_nibbles(packed, codes.numel()).to(torch.int8) - 8
        self.assertTrue(torch.equal(recovered.reshape_as(codes), codes))
        decoded = (recovered.reshape_as(codes).float() * scale).reshape_as(weights)
        self.assertTrue(torch.isfinite(decoded).all())
        self.assertTrue(torch.equal(decoded[0], weights[0]))
        self.assertTrue(torch.allclose(fake_quant_weight(weights, 4, 16), decoded, atol=1e-7))

    def test_fake_quant_uses_identity_surrogate_gradients(self):
        for bits in (4, 8):
            weights = torch.randn(4, 32, requires_grad=True)
            fake_quant_weight(weights, bits, 16).sum().backward()
            self.assertTrue(torch.equal(weights.grad, torch.ones_like(weights)))

    def test_mask_and_shape(self):
        model = HybridEditTransformer(tiny_config())
        tokens, pointers, legal = self.fixture()
        outputs = model(tokens, pointers, legal)
        self.assertEqual(outputs["family_logits"].shape, (2, 9))
        self.assertEqual(outputs["witness_logits"].shape, (2, 2))
        self.assertEqual(outputs["value"].shape, (2,))
        self.assertEqual(outputs["action_logits"].softmax(-1)[0, 2].item(), 0)
        with self.assertRaises(ValueError):
            model(tokens, pointers, torch.zeros_like(legal))
        with self.assertRaises(ValueError):
            model(tokens, pointers + 12, legal)
        with self.assertRaises(ValueError):
            model.encode(torch.zeros((1, 33), dtype=torch.long))

    def test_set_loss_includes_all_optimal_actions(self):
        logits = torch.tensor([[1., 2., -torch.inf]], requires_grad=True)
        self.assertEqual(optimal_set_loss(logits, torch.tensor([[True, True, False]])).item(), 0)
        expected = -logits.softmax(-1)[0, 1].log()
        self.assertTrue(torch.allclose(expected, optimal_set_loss(logits, torch.tensor([[False, True, False]]))))
        for bad in ([[False, False, False]], [[False, False, True]]):
            with self.assertRaises(ValueError):
                optimal_set_loss(logits, torch.tensor(bad))

    def test_every_parameter_has_finite_nonzero_gradient(self):
        for bits in (4, 8, 16):
            with self.subTest(bits=bits):
                model = HybridEditTransformer(tiny_config(bits), checkpoint_blocks=True)
                out = model(*self.fixture())
                targets = torch.tensor([[False, True, False], [False, True, True]])
                loss = (optimal_set_loss(out["action_logits"], targets)
                        + torch.nn.functional.cross_entropy(out["family_logits"], torch.tensor([1, 2]))
                        + torch.nn.functional.cross_entropy(out["witness_logits"], torch.tensor([0, 1]))
                        + (out["value"] - 1).square().mean())
                loss.backward()
                for name, param in model.named_parameters():
                    self.assertIsNotNone(param.grad, name)
                    self.assertTrue(torch.isfinite(param.grad).all(), name)
                    self.assertGreater(param.grad.abs().sum().item(), 0, name)

    def test_checkpoint_backward_agrees(self):
        model = HybridEditTransformer(tiny_config(4), checkpoint_blocks=False)
        copy = HybridEditTransformer(tiny_config(4), checkpoint_blocks=True)
        copy.load_state_dict(model.state_dict())
        inputs = self.fixture()
        for network in (model, copy):
            out = network(*inputs)
            out["action_logits"][inputs[2]].sum().backward()
        for a, b in zip(model.parameters(), copy.parameters()):
            if a.grad is not None:
                self.assertTrue(torch.allclose(a.grad, b.grad, atol=1e-6, rtol=1e-5))

    def test_save_reload_and_tied_embedding(self):
        model = HybridEditTransformer(tiny_config(4))
        inputs = self.fixture()
        before = model(*inputs)["action_logits"]
        buffer = io.BytesIO()
        torch.save(model.state_dict(), buffer)
        buffer.seek(0)
        copy = HybridEditTransformer(tiny_config(4))
        copy.load_state_dict(torch.load(buffer, weights_only=True))
        self.assertTrue(torch.equal(before, copy(*inputs)["action_logits"]))
        self.assertEqual(model.token_logits(model.encode(inputs[0])).shape, (2, 12, 64))


if __name__ == "__main__":
    unittest.main()
