"""Executable representation and learning-boundary tests, with actual Java views."""
import unittest
from copy import deepcopy
import torch
from .test_replay import ReplayTest
from .tables import encode
from .policy import GraphPolicy, choose, bits


class LearningTest(unittest.TestCase):
    setUp = ReplayTest.setUp
    load = ReplayTest.load
    source = staticmethod(ReplayTest.source)
    action = staticmethod(ReplayTest.action)
    path = ReplayTest.path

    def test_exact_int32_roundtrip(self):
        x = torch.tensor([[0, -1, 2**31-1, -(2**31), 16777217]], dtype=torch.int64)
        b = bits(x).reshape(1, 5, 32).long()
        unsigned = (b << torch.arange(32)).sum(-1)
        restored = torch.where(unsigned >= 2**31, unsigned - 2**32, unsigned)
        self.assertTrue(torch.equal(restored, x))

    def test_private_changes_same_tensors_and_prediction(self):
        _, left, catalog = self.load(self.source())
        _, right, _ = self.load(self.source('some S'))
        a, b = encode(left, catalog['operators']), encode(right, catalog['operators'])
        for field in ('kinds', 'values', 'edges', 'roles'):
            self.assertTrue(torch.equal(getattr(a, field), getattr(b, field)))
        torch.manual_seed(7); model = GraphPolicy(32, 2).eval()
        with torch.no_grad():
            self.assertEqual(choose(model, a, left, 0)[0], choose(model, b, right, 0)[0])
        poisoned = deepcopy(left); poisoned['oracle'] = 'secret'
        with self.assertRaises(ValueError): encode(poisoned, catalog['operators'])

    def test_graph_address_transport(self):
        _, obs, catalog = self.load(self.source())
        graph = encode(obs, catalog['operators'])
        torch.manual_seed(21); order = torch.randperm(len(graph.kinds))
        transported = graph.permute(order)
        roundtrip = transported.permute(torch.argsort(order))
        for field in ('kinds', 'values', 'edges', 'roles'):
            self.assertTrue(torch.equal(getattr(graph, field), getattr(roundtrip, field)))
        model = GraphPolicy(32, 2).eval()
        with torch.no_grad():
            a, q = model.encode(graph); b, r = model.encode(transported)
            torch.testing.assert_close(a, b[order], atol=2e-6, rtol=2e-6)
            torch.testing.assert_close(q, r, atol=2e-6, rtol=2e-6)

    def test_source_alpha_names_not_tensor_identity(self):
        source = 'sig S {} pred candidate { all x: S | some x } pred oracle { no S } run {} for 3'
        _, left, cat = self.load(source)
        _, right, _ = self.load(source.replace('all x: S | some x', 'all aVeryLongName: S | some aVeryLongName'))
        self.assertEqual(left, right)
        graph = encode(left, cat['operators'])
        self.assertGreater(len(graph.edges[0]), 0)

    def test_canonical_aci_and_temporal_import(self):
        _, obs, cat = self.load('sig S {} var sig T in S {} pred candidate { all x:S | once x in T implies always x in T } pred oracle { no S } run {} for 3')
        current = obs['current']
        self.assertGreater(len(current['canonicalPhasePorts']), 1)
        self.assertTrue(any(row[1] == 2 for row in current['canonicalBindings']))
        encode(obs, cat['operators'])
        _, obs, cat = self.load('sig S,T,U {} pred candidate { some S and (some T and some U) } pred oracle { no S } run {} for 3')
        current = obs['current']; op = cat['canonicalOperators'].index('AND')
        node = next(i for i, row in enumerate(current['canonicalNodes']) if row[0] == op)
        self.assertEqual(current['canonicalNodes'][node][2], 3)
        self.assertEqual(len([p for p in current['canonicalPorts'] if p[0] == node]), 3)

    def test_teacher_features_exclude_label_and_future(self):
        from .replay import replay
        worker, obs, cat = self.load(self.source())
        data = replay(worker, obs, self.path(obs, cat))
        torch.manual_seed(3); model = GraphPolicy(32, 2)
        for item in data['decisions']:
            key = item['observation']
            graph = encode(key, cat['operators'])
            queries = sum(row[1] in (11, 12) for row in key['history'])
            _, loss, _ = choose(model, graph, key, queries, item['action'])
            self.assertTrue(torch.isfinite(loss))
        self.assertFalse(data['decisions'][0]['observation']['feedback']['worlds'])

    def test_query_budget_mask(self):
        from .policy import options
        _, obs, _ = self.load(self.source())
        candidates = options(obs, 'control', {}, queries=2)
        self.assertFalse(any(c.fields['control'] in (11, 12) for c in candidates))


if __name__ == '__main__':
    torch.set_num_threads(2)
    unittest.main()
