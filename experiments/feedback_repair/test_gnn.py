"""Bounded numerical/contract correspondence checks, not learning proofs."""
import unittest
import torch
from .test_replay import ReplayTest
from .tables import Graph, TABLES, encode
from .policy import Choice, choose
from .gnn_variants import VARIANTS, make_policy, channel_means


def tiny_graph():
    return Graph(torch.tensor([TABLES.index(t) for t in ('state', 'current.nodes', 'current.nodes')]),
                 torch.tensor([[32, 0] + [0]*14, [2, 0] + [0]*14, [3, 1] + [0]*14]),
                 torch.tensor([[0, 1, 1, 2], [1, 0, 2, 1]]), torch.tensor([0, 16, 1, 17]),
                 {('state', 0): 0, ('current.nodes', 0): 1, ('current.nodes', 1): 2})


class GNNTest(unittest.TestCase):
    setUp = ReplayTest.setUp
    load = ReplayTest.load
    source = staticmethod(ReplayTest.source)

    def test_private_oracle_prediction_independence(self):
        _, left, cat = self.load(self.source())
        _, right, _ = self.load(self.source('some S'))
        a, b = encode(left, cat['operators']), encode(right, cat['operators'])
        for variant in VARIANTS:
            with self.subTest(variant=variant), torch.no_grad():
                torch.manual_seed(42); model = make_policy(variant, 16, 2).eval()
                self.assertEqual(choose(model, a, left, 0)[0], choose(model, b, right, 0)[0])

    def test_row_and_edge_order_transport(self):
        graph = tiny_graph(); order = torch.tensor([2, 0, 1]); changed = graph.permute(order)
        changed.edges = changed.edges.flip(1); changed.roles = changed.roles.flip(0)
        choices = [Choice({}, [1, i], [('current.nodes', i)]) for i in range(2)]
        for variant in VARIANTS:
            with self.subTest(variant=variant), torch.no_grad():
                torch.manual_seed(42); model = make_policy(variant, 16, 2).eval()
                h, q = model.encode(graph); j, r = model.encode(changed)
                torch.testing.assert_close(h, j[order], atol=3e-6, rtol=3e-6)
                torch.testing.assert_close(q, r, atol=3e-6, rtol=3e-6)
                a, _ = model.logits(h, q, choices, graph.addresses)
                b, _ = model.logits(j, r, choices, changed.addresses)
                torch.testing.assert_close(a, b, atol=3e-6, rtol=3e-6)

    def test_finite_difference_encoder_gradients(self):
        graph = tiny_graph()
        for variant in VARIANTS[1:]:
            with self.subTest(variant=variant):
                torch.manual_seed(42); model = make_policy(variant, 16, 2).double()
                choices = [Choice({}, [0, i], [('current.nodes', i)]) for i in range(2)]
                def loss():
                    h, q = model.encode(graph)
                    logits, _ = model.logits(h, q, choices, graph.addresses)
                    return torch.nn.functional.cross_entropy(logits[None], torch.tensor([1]))
                value = loss(); value.backward()
                p = model.scalar.weight
                direction = torch.randn_like(p); direction /= direction.norm()
                expected = (p.grad * direction).sum().item()
                original = p.detach().clone(); epsilon = 1e-5
                with torch.no_grad():
                    p.copy_(original + epsilon*direction); plus = loss().item()
                    p.copy_(original - epsilon*direction); minus = loss().item()
                    p.copy_(original)
                self.assertGreater(abs(expected), 1e-8)
                self.assertAlmostEqual(expected, (plus-minus)/(2*epsilon), delta=2e-6)

    def test_nonzero_encoder_pointer_and_query_gradients(self):
        graph = tiny_graph()
        choices = [Choice({}, [0, i], [('current.nodes', i)]) for i in range(2)]
        for variant in VARIANTS[1:]:
            with self.subTest(variant=variant):
                torch.manual_seed(42); model = make_policy(variant, 16, 2)
                h, q = model.encode(graph); logits, _ = model.logits(h, q, choices, graph.addresses)
                torch.nn.functional.cross_entropy(logits[None], torch.tensor([1])).backward()
                for p in (model.scalar.weight, model.pointer.weight, model.context[0].weight,
                          model.query_score[0].weight, model.layers[0].update[0].weight):
                    self.assertIsNotNone(p.grad)
                    self.assertTrue(torch.isfinite(p.grad).all())
                    self.assertGreater(p.grad.norm().item(), 1e-8)

    def test_channel_isolation(self):
        h = torch.tensor([[1., 3.], [3., 5.], [99., 99.]])
        a, present = channel_means(h, torch.tensor([0, 0, 1]))
        b, _ = channel_means(torch.cat((h, torch.ones(25, 2))), torch.tensor([0, 0, 1] + [1]*25))
        torch.testing.assert_close(a[0], torch.tensor([2., 4.]))
        torch.testing.assert_close(a[0], b[0])
        self.assertEqual(int(present.sum()), 2)

    def test_query_changes_candidate_relative_scores(self):
        graph = tiny_graph()
        choices = [Choice({}, [0, i], []) for i in range(3)]
        for variant in VARIANTS[1:]:
            with self.subTest(variant=variant), torch.no_grad():
                torch.manual_seed(42); model = make_policy(variant, 16, 2)
                h, q = model.encode(graph)
                a, _ = model.logits(h, q, choices, graph.addresses)
                b, _ = model.logits(h, -q, choices, graph.addresses)
                self.assertGreater(float(((a-a.mean()) - (b-b.mean())).norm()), 1e-5)

    def test_message_dependence_and_no_message_control(self):
        graph = tiny_graph()
        changed = Graph(graph.kinds, graph.values, graph.edges[:, :0], graph.roles[:0], graph.addresses)
        for variant in VARIANTS[1:]:
            with self.subTest(variant=variant), torch.no_grad():
                torch.manual_seed(42); model = make_policy(variant, 16, 2)
                _, q = model.encode(graph); _, r = model.encode(changed)
                if variant == 'mlp': torch.testing.assert_close(q, r, atol=0, rtol=0)
                else: self.assertGreater(float((q-r).norm()), 1e-5)


if __name__ == '__main__':
    torch.set_num_threads(2)
    unittest.main()
