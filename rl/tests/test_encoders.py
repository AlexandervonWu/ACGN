import copy
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
import torch
from torch.nn import functional as F

from acgn_repair.encoders import ENCODERS, GCNLayer, GATLayer, GINLayer, destination_softmax, message_schedule
from acgn_repair.experiment import ROOT, argument_parser, load_policy, save_checkpoint, seed_all
from acgn_repair.compare_encoders import OPTIONS, require_matched_settings
from acgn_repair.model import StructuredPolicy, update_policy
from acgn_repair.proof_gate import ProofGate, step_record
from acgn_repair.worker import JavaWorker
from acgn_repair.capacity import capacity_statistics


DEVICE = os.environ.get("ACGN_RL_DEVICE", "cuda")
CLASSES = Path(os.environ["ACGN_RL_CLASSES"])


def dense_reference(layer, h, src, dst, edge):
    if isinstance(layer, GCNLayer):
        counts = torch.stack([(dst == i).sum() for i in range(len(h))]).to(h.dtype)
        incidence = F.one_hot(dst, num_classes=len(h)).to(h.dtype).T
        coefficients = incidence / torch.sqrt(counts[src] * counts[dst])[None, :]
        messages = F.linear(h, layer.node.weight)[src] + F.linear(edge, layer.edge.weight)
        return layer.norm(F.relu(coefficients @ messages))
    if isinstance(layer, GATLayer):
        z = F.linear(h, layer.node.weight).reshape(len(h), layer.heads, layer.width)
        e = F.linear(edge, layer.edge.weight).reshape(len(src), layer.heads, layer.width)
        scores = F.leaky_relu((z[src] * layer.source_attention).sum(-1)
                              + (z[dst] * layer.target_attention).sum(-1)
                              + (e * layer.edge_attention).sum(-1), 0.2)
        rows = []
        for i in range(len(h)):
            incoming = dst == i
            weights = torch.softmax(scores[incoming], dim=0)
            rows.append((weights[:, :, None] * (z[src[incoming]] + e[incoming])).sum(0).flatten())
        return layer.norm(F.elu(torch.stack(rows)))
    messages = F.relu(h[src] + F.linear(edge, layer.edge.weight))
    rows = [messages[dst == i].sum(0) for i in range(len(h))]
    return layer.norm(layer.mlp((1 + layer.epsilon) * h + torch.stack(rows)))


class EncoderTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        seed_all(73)
        if DEVICE == "cuda" and not torch.cuda.is_available():
            raise RuntimeError("CUDA checks cannot silently skip")
        cls.work = tempfile.TemporaryDirectory(prefix="acgn-encoder-tests-")
        cls.directory = Path(cls.work.name)
        cls.gate = ProofGate()
        with JavaWorker(ROOT, CLASSES, cls.directory / "worker.log") as worker:
            worker.request("load", path=str(ROOT / "docs/rl-repair/fixtures/basic.als"), target="candidate",
                           oracle="oracle", command=0, horizon=4, capacity=4, seedsPerClass=1)
            cls.before = worker.request("reset")
            cls.observation = cls.before["observation"]
            cls.action = next(i for i, a in enumerate(cls.observation["actions"])
                              if a["kind"] == "REPLACE_OPERATOR" and a["operation"] == "no")
            cls.after = worker.request("step", token=cls.before["token"], action=cls.action)
            cls.checked = cls.gate.check([step_record(cls.before, cls.action, cls.after)], train=True,
                                        uncensored=True, policy_before=0, policy_after=0,
                                        profile=cls.before["bank"]["profile"])

    @classmethod
    def tearDownClass(cls):
        cls.gate.close()
        cls.work.cleanup()

    def test_lean_schedule_matrix(self):
        expected = subprocess.check_output(["lean", "--run", str(ROOT / "docs/rl-repair/formal/GraphEncoders.lean")],
                                           cwd=ROOT, text=True)
        rows = []
        for n in range(1, 5):
            for source in range(n):
                for target in range(n):
                    for duplicate in (False, True):
                        for loops in (False, True):
                            edges = [(source, target, "K", 2)] * (2 if duplicate else 1)
                            messages = message_schedule(n, edges, loops)
                            for v in range(n):
                                incoming = [e for e in messages if e[1] == v]
                                value = sum((s + 1) * 10 + (0 if kind == "SELF" else 3 if kind.startswith("reverse:") else 2) + pos
                                            for s, _, kind, pos in incoming)
                                rows.append(f"GRAPH,{n},{source},{target},{str(duplicate).lower()},{str(loops).lower()},"
                                            f"{v},{len(incoming)},{value}")
        self.assertEqual(len(rows), 400)
        self.assertEqual(expected, "\n".join(rows) + "\n")

    def test_comparison_settings_are_typed_not_formatted(self):
        args = argument_parser(comparison=True).parse_args([
            "--manifest", "/tmp/tasks.json", "--classes", "/tmp/classes", "--output", "/tmp/comparison"])
        config = {name: str(getattr(args, name)) if isinstance(getattr(args, name), Path)
                  else getattr(args, name) for name in OPTIONS}
        config["timeout"] = 30.0
        require_matched_settings(args, config)
        for name, value in (("timeout", 31.0), ("timeout", "30"), ("capacity", 99), ("lr", 0.004)):
            with self.subTest(field=name, value=value), self.assertRaisesRegex(ValueError, name):
                require_matched_settings(args, {**config, name: value})

    def test_sparse_layers_match_dense_values_and_gradients(self):
        for factory in (lambda: GCNLayer(8), lambda: GATLayer(8, 2), lambda: GINLayer(8)):
            sparse = factory().to(device=DEVICE, dtype=torch.float64)
            dense = copy.deepcopy(sparse)
            loops = not isinstance(sparse, GINLayer)
            messages = message_schedule(4, [(0, 1, "CHILD", 1), (0, 1, "CHILD", 1), (1, 2, "USE", 0)], loops)
            src = torch.tensor([e[0] for e in messages], device=DEVICE)
            dst = torch.tensor([e[1] for e in messages], device=DEVICE)
            h = torch.randn(4, 8, device=DEVICE, dtype=torch.float64, requires_grad=True)
            edge = torch.randn(len(messages), 8, device=DEVICE, dtype=torch.float64, requires_grad=True)
            dh, de = h.detach().clone().requires_grad_(), edge.detach().clone().requires_grad_()
            actual, expected = sparse(h, src, dst, edge), dense_reference(dense, dh, src, dst, de)
            with self.subTest(layer=type(sparse).__name__):
                torch.testing.assert_close(actual, expected, atol=1e-9, rtol=1e-8)
                weights = torch.randn_like(actual)
                ga = torch.autograd.grad((actual * weights).sum(), [h, edge, *sparse.parameters()])
                ge = torch.autograd.grad((expected * weights).sum(), [dh, de, *dense.parameters()])
                for a, e in zip(ga, ge):
                    torch.testing.assert_close(a, e, atol=1e-8, rtol=1e-7)

    def test_attention_normalizes_per_destination_and_head(self):
        scores = torch.tensor([[10000., -10000.], [9999., 10000.], [-10000., 3.], [-9999., 4.]], device=DEVICE)
        dst = torch.tensor([0, 0, 1, 1], device=DEVICE)
        alpha = destination_softmax(scores, dst, 2)
        self.assertTrue(bool(torch.isfinite(alpha).all()))
        torch.testing.assert_close(torch.zeros(2, 2, device=DEVICE).index_add(0, dst, alpha),
                                   torch.ones(2, 2, device=DEVICE))
        for i in range(2):
            torch.testing.assert_close(alpha[dst == i], scores[dst == i].softmax(dim=0))

    def test_all_encoders_proof_gated_update_and_checkpoint(self):
        for family in ENCODERS:
            with self.subTest(encoder=family):
                policy = StructuredPolicy(32, 2, family, 4).to(DEVICE)
                optimizer = torch.optim.Adam(policy.parameters(), lr=0.001)
                logits, value = policy(self.observation)
                distribution = torch.distributions.Categorical(logits=logits)
                trajectory = [(distribution.log_prob(torch.tensor(self.action, device=DEVICE)), value,
                               distribution.entropy(), self.after["reward"])]
                before = policy.symbols.weight.detach().clone()
                stats = update_policy(policy, optimizer, trajectory, self.checked)
                self.assertGreater(stats["gradientNorm"], 0)
                self.assertFalse(torch.equal(before, policy.symbols.weight))
                path = self.directory / (family + ".pt")
                save_checkpoint(path, policy, optimizer, {}, 1)
                restored = load_policy(path, DEVICE)
                self.assertEqual(restored.architecture(), policy.architecture())
                with torch.no_grad():
                    for a, b in zip(policy(self.observation), restored(self.observation)):
                        self.assertTrue(torch.equal(a, b))
                checkpoint = torch.load(path, weights_only=True)
                checkpoint["architecture"]["graphContractHash"] = "stale"
                torch.save(checkpoint, path)
                with self.assertRaisesRegex(ValueError, "graph encoder contract"):
                    load_policy(path, DEVICE)

    def test_all_encoders_relabeling_edge_order_and_masks(self):
        changed = copy.deepcopy(self.observation)
        count = len(changed["nodes"])
        changed["nodes"].reverse()
        changed["edges"].reverse()
        for edge in changed["edges"]:
            edge[0], edge[1] = count - 1 - edge[0], count - 1 - edge[1]
        for action in changed["actions"]:
            action["node"] = count - 1 - action["node"]
        for family in ENCODERS:
            with self.subTest(encoder=family), torch.no_grad():
                policy = StructuredPolicy(32, 2, family, 4).to(DEVICE).eval()
                logits, value = policy(self.observation)
                other, other_value = policy(changed)
                torch.testing.assert_close(logits, other, atol=1e-5, rtol=1e-5)
                torch.testing.assert_close(value, other_value, atol=1e-5, rtol=1e-5)
                allowed = [i == self.action for i in range(len(logits))]
                masked, _ = policy(self.observation, allowed)
                probabilities = masked.softmax(0)
                self.assertEqual(float(probabilities[self.action]), 1.)
                self.assertEqual(int((probabilities != 0).sum()), 1)
                with self.assertRaises(ValueError):
                    policy(self.observation, [False] * len(logits))

    def test_deep_layers_receive_gradients_and_reload(self):
        for family in ENCODERS:
            for depth in (4, 6):
                with self.subTest(encoder=family, depth=depth):
                    seed_all(73)
                    policy = StructuredPolicy(64, depth, family, 4).to(DEVICE)
                    optimizer = torch.optim.Adam(policy.parameters(), lr=0.001)
                    before = {k: v.detach().clone() for k, v in policy.named_parameters()}
                    logits, value = policy(self.observation)
                    dist = torch.distributions.Categorical(logits=logits)
                    update_policy(policy, optimizer, [(dist.log_prob(torch.tensor(self.action, device=DEVICE)),
                                  value, dist.entropy(), self.after["reward"])], self.checked)
                    for layer in range(depth):
                        key = f"encoder.{'messages' if family == 'mpnn' else 'layers'}.{layer}."
                        parameters = [(k, p) for k, p in policy.named_parameters() if k.startswith(key)]
                        self.assertTrue(parameters)
                        self.assertTrue(all(p.grad is not None and bool(torch.isfinite(p.grad).all()) for _, p in parameters))
                        self.assertTrue(any(bool((p.grad != 0).any()) for _, p in parameters))
                        self.assertTrue(any(not torch.equal(before[k], p) for k, p in parameters))
                    path = self.directory / f"deep-{family}-{depth}.pt"
                    save_checkpoint(path, policy, optimizer, {}, 1)
                    restored = load_policy(path, DEVICE)
                    with torch.no_grad():
                        for a, b in zip(policy(self.observation), restored(self.observation)):
                            self.assertTrue(torch.equal(a, b))

    def test_large_policies_update_every_layer_and_reload(self):
        for family in ENCODERS:
            with self.subTest(encoder=family):
                seed_all(173)
                policy = StructuredPolicy(1024, 6, family, 8).to(DEVICE)
                optimizer = torch.optim.Adam(policy.parameters(), lr=0.0001)
                self.assertGreater(capacity_statistics(policy)["parameterCount"], 20_000_000)
                logits, value = policy(self.observation)
                distribution = torch.distributions.Categorical(logits=logits)
                result = update_policy(policy, optimizer, [(distribution.log_prob(torch.tensor(self.action, device=DEVICE)),
                                       value, distribution.entropy(), self.after["reward"])], self.checked)
                self.assertGreater(result["gradientNorm"], 0)
                for layer in range(6):
                    key = f"encoder.{'messages' if family == 'mpnn' else 'layers'}.{layer}."
                    parameters = [p for k, p in policy.named_parameters() if k.startswith(key)]
                    self.assertTrue(parameters)
                    self.assertTrue(all(p.grad is not None and bool(torch.isfinite(p.grad).all()) for p in parameters))
                    self.assertTrue(any(bool((p.grad != 0).any()) for p in parameters))
                path = self.directory / f"large-{family}.pt"
                save_checkpoint(path, policy, optimizer, {}, 1)
                restored = load_policy(path, DEVICE)
                self.assertEqual(policy.architecture(), restored.architecture())
                with torch.no_grad():
                    for actual, expected in zip(policy(self.observation), restored(self.observation)):
                        self.assertTrue(torch.equal(actual, expected))
                del restored, policy, optimizer, logits, value, distribution

    def test_isolated_nodes_and_graph_limits(self):
        observation = copy.deepcopy(self.observation)
        observation["edges"] = []
        for family in ENCODERS:
            with self.subTest(encoder=family):
                policy = StructuredPolicy(32, 2, family, 4).to(DEVICE)
                logits, value = policy(observation)
                self.assertTrue(bool(torch.isfinite(logits).all() & torch.isfinite(value)))
        for edges in ([(0, 1, "X", -1)], [(0, 5, "X", 0)], [(0, 1, "X", 0)] * 65537):
            with self.assertRaises(ValueError):
                message_schedule(2, edges)
        with self.assertRaises(ValueError):
            StructuredPolicy(30, encoder="gat", heads=4)

    def test_live_comparison_fixtures_are_editable(self):
        for filename, operation in (("train_connectives.als", "AND"), ("eval_relational.als", "INTERSECT"),
                                    ("val_overlap.als", "SOME"), ("val_implication.als", "AND"),
                                    ("test_nested_boolean.als", "AND"), ("test_bound_overlap.als", "SOME"),
                                    ("test_nested_relation.als", "INTERSECT")):
            with self.subTest(fixture=filename), JavaWorker(ROOT, CLASSES, self.directory / (filename + ".log")) as worker:
                worker.request("load", path=str(ROOT / "docs/rl-repair/fixtures" / filename), target="candidate",
                               oracle="oracle", command=0, horizon=4, capacity=4, seedsPerClass=1)
                state = worker.request("reset")
                self.assertFalse(state["terminal"])
                candidates = [i for i, a in enumerate(state["observation"]["actions"])
                              if a["kind"] == "REPLACE_OPERATOR" and a["operation"].upper() == operation]
                self.assertTrue(candidates, state["observation"]["actions"])
                reply = worker.request("step", token=state["token"], action=candidates[0])
                self.assertEqual(reply["status"], "SOLVED_WITHIN_PROFILE")


if __name__ == "__main__":
    unittest.main()
