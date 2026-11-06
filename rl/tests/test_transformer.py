import copy
import itertools
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import torch
from torch.nn import functional as F
from acgn_repair.experiment import ROOT, load_policy, save_checkpoint, seed_all
from acgn_repair.model import StructuredPolicy, update_policy
from acgn_repair.proof_gate import FORMAL, ProofGate, step_record
from acgn_repair.transformer import (GraphTransformerLayer, GraphEditDecoder, graph_request,
                                     request_valid, verify_graph_trace)
from acgn_repair.worker import JavaWorker


DEVICE = os.environ.get("ACGN_RL_DEVICE", "cuda")
CLASSES = Path(os.environ["ACGN_RL_CLASSES"])


def dense_attention(module, query, key, value):
    w = module.embed_dim
    weights, biases = module.in_proj_weight.split(w), module.in_proj_bias.split(w)
    q, k, v = [F.linear(x, a, b).reshape(len(x), module.num_heads, w // module.num_heads).transpose(0, 1)
               for x, a, b in zip((query, key, value), weights, biases)]
    scores = q @ k.transpose(-1, -2) / (w // module.num_heads) ** 0.5
    result = (scores.softmax(-1) @ v).transpose(0, 1).reshape(len(query), w)
    return F.linear(result, module.out_proj.weight, module.out_proj.bias)


def fixture():
    return {"schema": "repair-structured-graphs-v1", "nodes": [
        {"categories": [op, "SET", "SEQUENCE"], "numeric": [0.1 * i, 0, i % 2]}
        for i, op in enumerate(("SOURCE:A", "CANONICAL:JOIN", "BINDING:ALL", "CANONICAL:A"))],
        "edges": [[0, 1, "SOURCE_CHILD", 1], [1, 2, "USE", 0], [1, 3, "MATRIX_CHILD", 2]],
        "actions": [{"node": i, "kind": "REPLACE_OPERATOR", "operation": op, "numeric": [0, 0.1]}
                    for i, op in ((0, "some"), (1, "no"), (0, "one"))], "numeric": [0] * 8}


class TransformerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        seed_all(411)
        if DEVICE != "cuda" or not torch.cuda.is_available():
            raise RuntimeError("Transformer CUDA tests cannot silently fall back")
        cls.gate = ProofGate()
        cls.model = StructuredPolicy(32, 2, "egraph_transformer", 4).to(DEVICE)
        cls.gate.check_graph(fixture(), cls.model.architecture())

    @classmethod
    def tearDownClass(cls):
        cls.gate.close()
        del cls.model

    def test_lean_structural_admission_matrix(self):
        output = subprocess.check_output(["lean", "--run", str(FORMAL / "EGraph2GraphMatrix.lean")],
                                         env=self.gate.env, text=True, timeout=30)
        rows = []
        for n, w, h in itertools.product(range(5), (0, 8, 10, 64), (0, 2, 3, 4)):
            for source, action, mask in itertools.product((0, n), (0, n), (False, True)):
                r = {"nodes": n, "width": w, "heads": h, "layers": 2, "slots": 8,
                     "edges": [{"source": source, "target": 0, "kind": "USE", "position": 2}],
                     "actions": [action], "allowed": [mask]}
                rows.append(f"TRANSFORMER,{n},{w},{h},{source},{action},{str(mask).lower()},"
                            f"{str(request_valid(r)).lower()}")
        self.assertEqual(len(rows), 640)
        self.assertEqual(output, "\n".join(rows) + "\n")

    def test_dense_reference_values_and_gradients(self):
        for decoder in (False, True):
            layer = (GraphEditDecoder(8, 2) if decoder else GraphTransformerLayer(8, 2)).to(DEVICE).double()
            reference = copy.deepcopy(layer)
            h = torch.randn(4, 8, device=DEVICE, dtype=torch.float64, requires_grad=True)
            x = torch.randn(3, 8, device=DEVICE, dtype=torch.float64, requires_grad=True)
            rh, rx = h.detach().clone().requires_grad_(), x.detach().clone().requires_grad_()
            src = torch.tensor([0, 0, 1], device=DEVICE)
            dst = torch.tensor([1, 1, 2], device=DEVICE)
            if decoder:
                actual = layer(h, src, x)
                queries = reference.query(torch.cat((rh[src], rx), -1))
                expected = reference.norm(rx + dense_attention(reference.attention, queries, rh, rh))
            else:
                actual = layer(h, src, dst, x)
                z = reference.pre(rh)
                values = F.gelu(reference.local_node(z)[src] + reference.local_edge(rx))
                local = torch.stack([values[dst == i].sum(0) for i in range(len(z))])
                latents = reference.latents + dense_attention(reference.read, reference.latents, z, z)
                mixed = rh + local + dense_attention(reference.write, z, latents, latents)
                expected = mixed + reference.ff(reference.ff_norm(mixed))
            torch.testing.assert_close(actual, expected, atol=1e-9, rtol=1e-8)
            coefficients = torch.randn_like(actual)
            ga = torch.autograd.grad((actual * coefficients).sum(), [h, x, *layer.parameters()])
            ge = torch.autograd.grad((expected * coefficients).sum(), [rh, rx, *reference.parameters()])
            for a, b in zip(ga, ge):
                torch.testing.assert_close(a, b, atol=1e-8, rtol=1e-7)

    def test_node_edge_and_action_reindexing(self):
        original = fixture()
        other = copy.deepcopy(original)
        other["nodes"].reverse()
        other["edges"].reverse()
        for e in other["edges"]:
            e[0], e[1] = 3 - e[0], 3 - e[1]
        for a in other["actions"]:
            a["node"] = 3 - a["node"]
        other["actions"].reverse()
        with torch.no_grad():
            actual, value = self.model(original)
            changed, changed_value = self.model(other)
        torch.testing.assert_close(actual, changed.flip(0), atol=1e-5, rtol=1e-5)
        torch.testing.assert_close(value, changed_value, atol=1e-5, rtol=1e-5)

    def test_duplicate_and_port_features_are_not_discarded(self):
        original = fixture()
        with torch.no_grad():
            logits = self.model(original)[0]
            for change in ("duplicate", "port"):
                other = copy.deepcopy(original)
                if change == "duplicate":
                    other["edges"].append(copy.deepcopy(other["edges"][0]))
                else:
                    other["edges"][0][3] = 3
                self.assertFalse(torch.allclose(logits, self.model(other)[0], atol=1e-6, rtol=1e-6))

    def test_gate_cache_rejections_and_exact_echo(self):
        with ProofGate() as gate:
            obs, arch = fixture(), self.model.architecture()
            first = gate.check_graph(obs, arch)
            self.assertEqual(gate.check_graph(obs, arch), first)
            self.assertEqual((gate.graph_checks, gate.graph_executions), (2, 1))
            for field, value in (("nodes", 0), ("actions", [99]), ("allowed", [False] * 3),
                                 ("heads", 0), ("width", 31), ("slots", 7), ("layers", 9)):
                request = graph_request(obs, arch)
                request[field] = value
                self.assertFalse(request_valid(request))
                with self.assertRaisesRegex(ValueError, "Lean application gate rejected"):
                    gate._run(["lean", "--run", str(FORMAL / "EGraph2GraphRunner.lean")], json.dumps(request) + "\n")
            altered = copy.deepcopy(obs)
            altered["actions"][0]["node"] = -1
            with self.assertRaises(ValueError):
                gate.check_graph(altered, arch)
            with self.assertRaises(ValueError):
                gate.check_graph(obs, arch, [False] * 3)
            with patch("acgn_repair.proof_gate.transformer_contract_hash", return_value="changed"):
                with self.assertRaisesRegex(ValueError, "contract"):
                    gate.check_graph(obs, arch)
            obs["edges"][0][3] = 4
            with patch.object(gate, "_run", return_value=json.dumps({"accepted": True, "request": {}})):
                with self.assertRaisesRegex(ValueError, "bound"):
                    gate.check_graph(obs, arch)

    def test_checkpoint_binds_transformer_contract(self):
        with tempfile.TemporaryDirectory() as directory:
            model = StructuredPolicy(32, 2, "egraph_transformer", 4).to(DEVICE)
            optimizer = torch.optim.Adam(model.parameters())
            path = Path(directory) / "model.pt"
            save_checkpoint(path, model, optimizer, {}, 0)
            loaded = load_policy(path, DEVICE)
            with torch.no_grad():
                for a, b in zip(model(fixture()), loaded(fixture())):
                    self.assertTrue(torch.equal(a, b))
            checkpoint = torch.load(path, weights_only=True)
            checkpoint["architecture"]["transformerContractHash"] = "stale"
            torch.save(checkpoint, path)
            with self.assertRaisesRegex(ValueError, "architecture"):
                load_policy(path, DEVICE)

    def test_trace_receipts_ignore_loads_but_bind_actual_transitions(self):
        obs, arch = fixture(), self.model.architecture()
        receipt = self.gate.check_graph(obs, arch)
        trace = [{"mode": "train", "load": {}},
                 {"mode": "train", "step": 0, "observation": obs, "graphAdmission": receipt},
                 {"mode": "random", "step": 0, "graphAdmission": None}]
        self.assertEqual(verify_graph_trace(trace, arch), 1)
        for change in ("observation", "receipt"):
            altered = copy.deepcopy(trace)
            if change == "observation":
                altered[1]["observation"]["edges"][0][3] += 1
            else:
                altered[1]["graphAdmission"]["requestHash"] = "0" * 64
            with self.assertRaisesRegex(ValueError, "receipt"):
                verify_graph_trace(altered, arch)

    def test_source_edit_rebuild_and_both_lean_gates(self):
        with tempfile.TemporaryDirectory() as directory, ProofGate() as gate, \
             JavaWorker(ROOT, CLASSES, Path(directory) / "worker.log") as worker:
            worker.request("load", path=str(ROOT / "docs/rl-repair/fixtures/basic.als"), target="candidate",
                           oracle="oracle", command=0, horizon=4, capacity=4, seedsPerClass=1)
            before = worker.request("reset")
            model = StructuredPolicy(32, 2, "egraph_transformer", 4).to(DEVICE)
            obs = before["observation"]
            action = next(i for i, a in enumerate(obs["actions"]) if a["operation"] == "no")
            receipt = gate.check_graph(obs, model.architecture())
            self.assertEqual(len(receipt["requestHash"]), 64)
            logits, value = model(obs)
            dist = torch.distributions.Categorical(logits=logits)
            after = worker.request("step", token=before["token"], action=action)
            self.assertEqual(after["status"], "SOLVED_WITHIN_PROFILE")
            self.assertNotEqual(before["canonicalDigest"], after["canonicalDigest"])
            self.assertEqual(after["validation"]["extra"], "UNSAT")
            self.assertEqual(after["validation"]["missing"], "UNSAT")
            checked = gate.check([step_record(before, action, after)], train=True, uncensored=True,
                                 policy_before=0, policy_after=0, profile=before["bank"]["profile"])
            optimizer = torch.optim.Adam(model.parameters(), lr=0.0003)
            result = update_policy(model, optimizer, [(dist.log_prob(torch.tensor(action, device=DEVICE)),
                                   value, dist.entropy(), after["reward"])], checked)
            self.assertGreater(result["gradientNorm"], 0)
            self.assertTrue(any(bool((p.grad != 0).any()) for p in model.decoder.parameters()))


if __name__ == "__main__":
    unittest.main()
