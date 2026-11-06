import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from acgn_repair.experiment import ROOT, load_policy, load_tasks, save_checkpoint, seed_all
from acgn_repair.model import StructuredPolicy, update_policy
from acgn_repair.worker import JavaWorker, WorkerError
from acgn_repair.proof_gate import ProofGate, step_record
import torch


CLASSES = Path(os.environ["ACGN_RL_CLASSES"])
DEVICE = os.environ.get("ACGN_RL_DEVICE", "cuda")


class LearningTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        seed_all(123)
        if DEVICE == "cuda" and not torch.cuda.is_available():
            raise RuntimeError("CUDA tests cannot silently skip")
        cls.work = tempfile.TemporaryDirectory(prefix="acgn-rl-python-test-")
        cls.directory = Path(cls.work.name)
        cls.gate = ProofGate()
        with JavaWorker(ROOT, CLASSES, cls.directory / "worker.log") as worker:
            worker.request("load", path=str(ROOT / "docs/rl-repair/fixtures/basic.als"), target="candidate",
                           oracle="oracle", command=0, horizon=4, capacity=4, seedsPerClass=1)
            initial = worker.request("reset")
            cls.observation = initial["observation"]
            action = next(i for i, a in enumerate(cls.observation["actions"])
                          if a["kind"] == "REPLACE_OPERATOR" and a["operation"] == "no")
            repaired = worker.request("step", token=initial["token"], action=action)
            if repaired["status"] != "SOLVED_WITHIN_PROFILE":
                raise AssertionError(repaired)
            if repaired["newPotential"] != 0 or repaired["validation"]["extra"] != "UNSAT" or repaired["validation"]["missing"] != "UNSAT":
                raise AssertionError("Success lacks terminal reward/two-direction evidence")
            cls.trace = (initial, repaired)
            cls.action = action
            cls.record = step_record(initial, action, repaired)

    @classmethod
    def tearDownClass(cls):
        cls.gate.close()
        cls.work.cleanup()

    def checked(self):
        return self.gate.check([self.record], train=True, uncensored=True, policy_before=0,
                               policy_after=0, profile=self.trace[0]["bank"]["profile"])

    def test_live_worker_success_is_profile_bounded(self):
        initial, repaired = self.trace
        self.assertEqual(repaired["certificateReplay"], "NOT_REQUESTED")
        self.assertEqual(repaired["reward"], 1000 - initial["score"]["potential"])
        self.assertEqual(initial["bank"]["profile"], repaired["bank"]["profile"])

    def test_lean_java_feedback_matrix(self):
        lean = subprocess.check_output(["lean", "--run", str(ROOT / "docs/rl-repair/formal/FeedbackLearning.lean")], cwd=ROOT, text=True)
        java = subprocess.check_output(["java", "-cp", str(CLASSES) + os.pathsep + str(ROOT / "lib/*"),
                                        "is.fivefivefive.ACGN.repair.RepairLearningTest", "--matrix"], cwd=ROOT, text=True)
        self.assertEqual(lean, java)
        self.assertEqual(len(lean.splitlines()), 155)
        for row in lean.splitlines():
            fields = row.split(",")
            if fields[0] == "REWARD":
                base, old, new, result = map(int, fields[1:])
                self.assertEqual(base + new - old, result)

    def test_masks_and_embedding_gradients(self):
        policy = StructuredPolicy(32).to(DEVICE)
        logits, value = policy(self.observation)
        mask = [False] * logits.numel()
        mask[0] = True
        masked, _ = policy(self.observation, mask)
        distribution = torch.distributions.Categorical(logits=masked)
        self.assertEqual(float(distribution.probs[0].detach()), 1.0)
        self.assertTrue(bool((distribution.probs[1:] == 0).all()))
        with self.assertRaises(ValueError):
            policy(self.observation, [False] * logits.numel())
        optimizer = torch.optim.Adam(policy.parameters(), lr=0.001)
        before = policy.symbols.weight.detach().clone()
        distribution = torch.distributions.Categorical(logits=logits)
        chosen = torch.tensor(self.action, device=DEVICE)
        trajectory = [(distribution.log_prob(chosen), value, distribution.entropy(), self.trace[1]["reward"])]
        stats = update_policy(policy, optimizer, trajectory, self.checked())
        self.assertGreater(stats["gradientNorm"], 0)
        self.assertFalse(torch.equal(before, policy.symbols.weight))
        self.assertEqual(policy.symbols.weight.device.type, DEVICE)
        with self.assertRaisesRegex(ValueError, "does not match"):
            update_policy(policy, optimizer, trajectory, self.checked())

    def test_unchecked_or_mismatched_update_preserves_parameters(self):
        policy = StructuredPolicy(32).to(DEVICE)
        optimizer = torch.optim.Adam(policy.parameters())
        logits, value = policy(self.observation)
        distribution = torch.distributions.Categorical(logits=logits)
        trajectory = [(distribution.log_prob(torch.tensor(self.action, device=DEVICE)), value,
                       distribution.entropy(), self.trace[1]["reward"] + 1)]
        before = {k: v.clone() for k, v in policy.state_dict().items()}
        for checked in (None, self.checked()):
            with self.assertRaises(ValueError):
                update_policy(policy, optimizer, trajectory, checked)
        self.assertTrue(all(torch.equal(v, policy.state_dict()[k]) for k, v in before.items()))
        self.assertEqual(policy.generation, 0)

    def test_worker_record_mismatch_is_rejected(self):
        before, after = self.trace
        for field, value in (("previousToken", "other"), ("actionIndex", self.action + 1),
                             ("episode", before["episode"] + 1), ("oldPotential", -1)):
            broken = {**after, field: value}
            with self.subTest(field=field), self.assertRaises(ValueError):
                step_record(before, self.action, broken)

    def test_checkpoint_reproduces_logits(self):
        policy = StructuredPolicy(32, layers=3).to(DEVICE).eval()
        optimizer = torch.optim.Adam(policy.parameters())
        path = self.directory / "checkpoint.pt"
        save_checkpoint(path, policy, optimizer, {"hidden": 32}, 0)
        restored = load_policy(path, DEVICE)
        self.assertEqual(restored.layers, 3)
        with torch.no_grad():
            expected = policy(self.observation)
            actual = restored(self.observation)
        self.assertTrue(torch.equal(expected[0], actual[0]))
        self.assertTrue(torch.equal(expected[1], actual[1]))
        checkpoint = torch.load(path, weights_only=True)
        checkpoint["architecture"]["contractHash"] = "different contract"
        torch.save(checkpoint, path)
        with self.assertRaisesRegex(ValueError, "proof contract"):
            load_policy(path, DEVICE)

    def test_detached_actor_and_critic_gradient_paths(self):
        log_probs = torch.tensor([-0.5, -0.7], device=DEVICE, requires_grad=True)
        values = torch.tensor([0.3, 0.4], device=DEVICE, requires_grad=True)
        targets = values.new_tensor([0.7, -0.2])
        actor = -(log_probs * (targets - values.detach())).mean()
        actor.backward()
        self.assertIsNone(values.grad)
        self.assertTrue(torch.equal(log_probs.grad, -(targets - values.detach()) / 2))
        (values - targets).square().mean().backward()
        self.assertTrue(torch.equal(values.grad, values.detach() - targets))

    def test_structural_positions_and_multiplicity(self):
        policy = StructuredPolicy(32).to(DEVICE).eval()
        with torch.no_grad():
            original = policy(self.observation)[0]
            changed = copy.deepcopy(self.observation)
            edge = next(e for e in changed["edges"] if e[2] == "SOURCE_CHILD")
            edge[3] += 1
            self.assertFalse(torch.allclose(original, policy(changed)[0], atol=1e-7))
            changed = copy.deepcopy(self.observation)
            changed["edges"].append(copy.deepcopy(changed["edges"][0]))
            self.assertFalse(torch.allclose(original, policy(changed)[0], atol=1e-7))

    def test_graph_id_permutation_and_metadata_noninterference(self):
        policy = StructuredPolicy(32).to(DEVICE).eval()
        changed = copy.deepcopy(self.observation)
        count = len(changed["nodes"])
        changed["nodes"].reverse()
        for edge in changed["edges"]:
            edge[0], edge[1] = count - 1 - edge[0], count - 1 - edge[1]
        for action in changed["actions"]:
            action["node"] = count - 1 - action["node"]
        with torch.no_grad():
            baseline = policy(self.observation)[0]
            self.assertTrue(torch.allclose(baseline, policy(changed)[0], atol=1e-5))
            changed = copy.deepcopy(self.observation)
            changed["oracleSource"] = "arbitrary private source that is not a neural feature"
            changed["taskId"] = "do not train on this"
            self.assertTrue(torch.equal(baseline, policy(changed)[0]))

    def test_worker_timeout_reaps_process(self):
        worker = JavaWorker(ROOT, CLASSES, self.directory / "timeout.log", timeout=0.2,
                            command=[sys.executable, "-c", "import time; time.sleep(30)"])
        with self.assertRaisesRegex(WorkerError, "TIMEOUT"):
            worker.request("reset")
        self.assertIsNotNone(worker.process.poll())

    def test_split_leakage_is_rejected(self):
        manifest = json.loads((ROOT / "docs/rl-repair/fixtures/pilot.json").read_text())
        for task in manifest["tasks"]:
            task["path"] = str(ROOT / "docs/rl-repair/fixtures" / task["path"])
        manifest["tasks"][1]["group"] = manifest["tasks"][0]["group"]
        path = self.directory / "leakage.json"
        path.write_text(json.dumps(manifest))
        with self.assertRaisesRegex(ValueError, "leakage"):
            load_tasks(path)
        manifest["tasks"][1]["group"] = "different"
        manifest["tasks"][1]["path"] = manifest["tasks"][0]["path"]
        path.write_text(json.dumps(manifest))
        with self.assertRaisesRegex(ValueError, "leakage"):
            load_tasks(path)


if __name__ == "__main__":
    unittest.main()
