import copy
import hashlib
import json
import os
from pathlib import Path
import tempfile
import unittest

import torch

from experiments.hybrid_edit.corpus_codec import compact_uint, decode_compact_uint, encode, T
from experiments.hybrid_edit.model import Config, HybridEditTransformer
from experiments.hybrid_edit.train_corpus import features, summarize, load_records
from experiments.hybrid_edit.corpus import ROOT, JavaWorker


class CorpusTests(unittest.TestCase):
    def test_all_numeric_codes_are_canonical_and_roundtrip(self):
        codes = set()
        for value in range(65536):
            code = compact_uint(value)
            self.assertEqual(decode_compact_uint(code), value)
            self.assertNotIn(code, codes)
            codes.add(code)
        for code in ((14, 64, 64, 64, 64), (14,), (0,), (64, 65)):
            with self.assertRaises(ValueError):
                decode_compact_uint(code)

    def test_padding_does_not_change_nonpad_predictions(self):
        torch.manual_seed(1)
        torch.set_num_threads(2)
        config = Config(width=32, layers=2, heads=4, kv_heads=2, head_dim=8, ff=64, max_tokens=16, group_size=8)
        model = HybridEditTransformer(config).eval()
        tokens = torch.tensor([[1, 7, 32, 13, 14, 15]])
        positions = torch.tensor([[3, 4]])
        legal = torch.ones(1, 2, dtype=torch.bool)
        plain = model(tokens, positions, legal)
        padded = model(torch.nn.functional.pad(tokens, (0, 4)), positions, legal)
        for key in plain:
            self.assertTrue(torch.allclose(plain[key], padded[key], atol=2e-5, rtol=2e-5), key)

    def test_policy_features_ignore_all_teacher_fields(self):
        row = {"tokens": [1, 13, 14, 15], "positions": [2], "actions": [{}],
               "optimal": [True], "outcomes": [{"solved": True}], "teacher": "secret"}
        changed = dict(row, optimal=[False], outcomes=[{"solved": False}], teacher="different")
        a, b = features([row], "cpu"), features([changed], "cpu")
        self.assertEqual(set(a), {"tokens", "positions", "legal"})
        self.assertTrue(all(torch.equal(a[key], b[key]) for key in a))

    def test_exact_random_without_replacement_reference(self):
        row = {"group": "g", "actions": [0]*4,
               "outcomes": [{"solved": i == 3, "score": i} for i in range(4)]}
        result = summarize([row], [[0, 1, 2, 3]])
        self.assertEqual(result["budgets"]["1"]["random_expected_rate"], .25)
        self.assertEqual(result["budgets"]["3"]["random_expected_rate"], .75)
        self.assertEqual(result["budgets"]["3"]["learned_solved"], 0)
        self.assertEqual(result["one_step_upper_bound"], 1)

    def test_loader_rejects_uncertified_success_and_zero_distance_conflicts(self):
        row = {"group": "g", "split": "train", "actions": [{"index": 0}],
               "optimal": [True], "initialDistance": 1,
               "outcomes": [{"index": 0, "valid": True, "distance": 0, "solved": True,
                             "validation": {"extra": "UNSAT", "missing": "UNSAT",
                                            "verdict": "SOLVED_WITHIN_PROFILE"}}]}
        with tempfile.TemporaryDirectory() as temp:
            directory = Path(temp)
            (directory / "records").mkdir()

            def store(value):
                digest = hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()
                (directory / "records/r.json").write_text(json.dumps({"packet": value}))
                (directory / "ledger.json").write_text(json.dumps([
                    {"id": "r", "status": "ACCEPTED", "packetHash": digest}]))

            store(row)
            self.assertEqual(load_records(directory), [row])
            for direction in ("extra", "missing"):
                invalid = copy.deepcopy(row)
                invalid["outcomes"][0]["validation"][direction] = "SAT"
                store(invalid)
                with self.assertRaisesRegex(ValueError, "two-direction"):
                    load_records(directory)
            invalid = copy.deepcopy(row)
            invalid["outcomes"][0]["solved"] = False
            store(invalid)
            with self.assertRaisesRegex(ValueError, "conflicts"):
                load_records(directory)
            store(dict(row, initialDistance=0))
            with self.assertRaisesRegex(ValueError, "Initial semantic"):
                load_records(directory)

    @unittest.skipUnless(os.environ.get("ACGN_RL_CLASSES"), "Requires compiled Java worker")
    def test_live_source_export_solver_labels_and_action_pointers(self):
        classes = Path(os.environ["ACGN_RL_CLASSES"])
        command = ["java", "-Xmx768m", "-cp", str(classes) + ":lib/*",
                   "is.fivefivefive.ACGN.repair.HybridCorpusWorker"]
        with tempfile.TemporaryDirectory() as temp:
            directory = Path(temp)
            source = directory / "fixture.als"
            source.write_text("sig S {}\npred inv { some S }\npred truth { no S }\nrun {} for 3\n")
            with JavaWorker(ROOT, classes, directory / "worker.log", command=command) as worker:
                raw = worker.request("load", path=str(source), target="inv", oracle="truth", command=0)
                packet = encode(raw)
                self.assertNotIn("teacher", raw)
                self.assertEqual(len(packet["actions"]), 3)
                for action, pos in zip(packet["actions"], packet["positions"]):
                    self.assertEqual(packet["tokens"][pos], T["END"])
                    self.assertEqual(packet["tokens"][pos-1], T["OP_" + action["after"]])
                mutated = copy.deepcopy(raw)
                mutated["teacher"] = "not for policy"
                mutated["outcomes"] = [999]
                self.assertEqual(encode(mutated)["tokens"], packet["tokens"])
                result = worker.request("labels", indices=[a["index"] for a in packet["actions"]])
                by_op = {a["after"]: out for a, out in zip(packet["actions"], result["outcomes"])}
                self.assertTrue(by_op["NO"]["solved"])
                self.assertFalse(by_op["ONE"]["solved"])
                self.assertFalse(by_op["LONE"]["solved"])
                self.assertEqual(by_op["NO"]["distance"], 0)
                self.assertEqual(by_op["NO"]["validation"]["extra"], "UNSAT")
                self.assertEqual(by_op["NO"]["validation"]["missing"], "UNSAT")

    @unittest.skipUnless(os.environ.get("ACGN_RL_CLASSES"), "Requires compiled Java worker")
    def test_live_alpha_renaming_preserves_structural_packet(self):
        classes = Path(os.environ["ACGN_RL_CLASSES"])
        command = ["java", "-Xmx768m", "-cp", str(classes) + ":lib/*",
                   "is.fivefivefive.ACGN.repair.HybridCorpusWorker"]
        exports = []
        with tempfile.TemporaryDirectory() as temp:
            directory = Path(temp)
            for variable in ("x", "renamed"):
                source = directory / (variable + ".als")
                source.write_text("sig S { r: set S }\npred inv { all " + variable +
                                  ":S | some " + variable + ".r }\npred truth { all y:S | no y.r }\nrun {} for 3\n")
                with JavaWorker(ROOT, classes, directory / (variable + ".log"), command=command) as worker:
                    exports.append(worker.request("load", path=str(source), target="inv", oracle="truth", command=0))
            # Keep the same labelled worlds: SAT enumeration order is not an alpha claim.
            exports[1]["worlds"] = exports[0]["worlds"]
            a, b = encode(exports[0]), encode(exports[1])
            self.assertEqual(a["tokens"], b["tokens"])
            self.assertEqual(a["positions"], b["positions"])


if __name__ == "__main__":
    unittest.main()
