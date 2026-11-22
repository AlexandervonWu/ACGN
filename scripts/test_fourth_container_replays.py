"""Encoder contract tests. Synthetic tables here are not execution evidence."""
import copy
from pathlib import Path
import unittest

import fourth_container_replays as r
from run_submission_container_closure import Blocked


def sources():
    return [dict(object=name, owner=("org.acgn.cert." if name == "SemanticEvidenceVerifier"
                 else "is.fivefivefive.CanDis.theory.") + name,
                 shapeSha256=pin.split()[0], bindingsSha256=pin.split()[1]) for name, pin in r.SOURCE_PINS.items()]


def observations():
    result = []
    for i, ((surface, family, label), value) in enumerate(r.expected_keys().items()):
        row = dict(case=str(i), surface=surface, family=str(family), fixture=label, tree="[]", inputs="[]",
                   outputs="[]", fibers="[]", splices="[]", accepted="false", indexMatches="true", controls="1", stage="")
        if surface in ("flat", "trace", "wireTree"):
            recursive = surface != "trace"
            tree = value if recursive else []
            inputs = r.leaf_order(tree) if recursive else value
            carrier = (1 if family == 2 else 2) if recursive else family
            outputs = r.expected_outputs(carrier, inputs)
            fibers = ([[i] for i in range(len(inputs))] if carrier == 0 else
                      [[i] for i in sorted(range(len(inputs)), key=lambda i: inputs[i])] if carrier == 1 else
                      [[i for i, v in enumerate(inputs) if v == out] for out in outputs])
            splices = r.splice_coordinates(tree) if recursive else []
            controls = 2 + len(inputs) + len(outputs)
            if surface == "flat":
                controls += (18 if family == 2 else 27) + 2 + sum(len(s) + 1 for s in splices)
            row.update(tree=r.encode(tree), inputs=r.encode(inputs), outputs=r.encode(outputs), fibers=r.encode(fibers),
                       splices=r.encode(splices), accepted="true", controls=str(controls),
                       stage="LOCAL_VERIFIED" if surface == "flat" else "STRUCTURAL_ONLY")
            if surface == "wireTree":
                positive = label.endswith(":original")
                row.update(controls="1", accepted=str(positive).lower(), stage="VERIFIED:NONE" if positive else "REJECTED:THEORY_MISMATCH",
                           splices=r.encode(splices if positive else list(reversed(splices))))
        elif surface == "pipeline":
            row.update(accepted="true", stage="ADAPTER_VERIFIED")
        elif surface == "unit":
            row["stage"] = "REGISTRY_REJECTED"
        elif surface == "boundary":
            row["stage"] = "LOCAL_REJECTED"
        else:
            row.update(accepted="true" if label == "original" else "false",
                       stage="VERIFIED:NONE" if label == "original" else "REJECTED:INVALID_RECORD_SHAPE"
                       if label in ("inputCount", "outputCount", "missingSplice") else "REJECTED:THEORY_MISMATCH")
        result.append(row)
    return result


class ContainerReplayTest(unittest.TestCase):
    def test_pre_recursive_integer_adapter_pins_are_rejected(self):
        shape = "b583b8d4c87dc505d5391eafeffa3e2927c504dd29836a4a185481eb77f9e7c5"
        bindings = "c7e96284672950a308c81ed1e6741ba5b626e0988cf58aa2dc9854b290500fec"
        for stale in ({"shapeSha256": shape}, {"bindingsSha256": bindings},
                      {"shapeSha256": shape, "bindingsSha256": bindings}):
            changed = sources()
            next(row for row in changed if row["object"] == "TheoryAlloyAdapter").update(stale)
            with self.subTest(fields=tuple(stale)), self.assertRaises(r.Blocked):
                r.source_census(changed)

    def test_superseded_verifier_and_writer_pins_are_rejected(self):
        # Retain superseded verifier generations and the pre-registry writer as independent negatives.
        for name, shape, binding in (
                ("SemanticEvidenceVerifier", "bff2c3471c7fc123e9752ce4a70a964811382f52df9d6e5475b6854a10df03bc",
                 "cd2fe91218d45a6eaebc03233f04d8119c8a23064ab520a3f7657e3ee54755cd"),
                ("SemanticEvidenceVerifier", "454ab4a9ae622571b4b1f5fc690cddddc50a811fb24c9806ac472b9a696302d6",
                 "0e1a6587d36c037fe55af80bdff163bd7816d0eec1dfc69c14dbf7aea60bcec8"),
                ("SemanticEvidenceVerifier", "b5112361b564655f391d9f9ce264bed924f79a9b3fcbd8b6f2039cc2ad24aa01",
                 "47dc4427500b1ef24863201ee627c2bb3905ecf4aaa2e15836a82ff0e9b87b3d"),
                ("TheoryAlloyAdapter", "f1fa121d2b059147dc2af5bf7e44531585c147cf827a7aa6138aec658bca9d6c",
                 "d9551bea070c3fd486e496ba2e9daacaae558c862bddbffae0fb9bbd9104bdb5"),
                ("CertificateBundleWriter", "b30d10623694288f274a1fc26b6f92dc6b00ecc6264a58a54e5f01b3a35e7e46",
                 "0807ef1b7acdba3a1c72c6f339a02ede7d8beebc969500c4e66de3c5983b1d21")):
            for stale in ({"shapeSha256": shape}, {"bindingsSha256": binding},
                          {"shapeSha256": shape, "bindingsSha256": binding}):
                changed = sources()
                next(row for row in changed if row["object"] == name).update(stale)
                with self.subTest(owner=name, fields=tuple(stale)), self.assertRaises(r.Blocked):
                    r.source_census(changed)

    def test_exact_independent_census(self):
        keys = r.expected_keys()
        self.assertEqual(len(keys), 1617)
        self.assertEqual({s: sum(k[0] == s for k in keys) for s in ("flat", "trace", "boundary", "unit", "pipeline", "wire", "wireTree")},
                         dict(flat=1413, trace=93, boundary=42, unit=6, pipeline=6, wire=37, wireTree=20))

    def test_valid_synthetic_encoding_inventory(self):
        code, count = r.program(observations(), sources())
        self.assertEqual(count, 102)
        self.assertEqual(code.count("#print axioms "), 102)
        self.assertIn("flatten (OperatorIndex.mk", code)
        self.assertIn("fibers .bag", code)
        self.assertIn("productionUnit", code)
        self.assertIn("producerSplices", code)
        self.assertIn("acceptsSpliceLedger", code)

    def test_omissions_extras_duplicates_even_with_renumbering(self):
        full = observations()
        for changed in (full[:-1], full + [full[0]], [full[0], *full[:-1]], full[1:] + [full[-1]]):
            changed = [dict(row, case=str(i)) for i, row in enumerate(changed)]
            with self.assertRaises(Blocked):
                r.program(changed, sources())

    def test_each_missing_source_and_forged_hash_rejected(self):
        full = sources()
        for i in range(len(full)):
            with self.assertRaises(Blocked):
                r.source_census(full[:i] + full[i + 1:])
            changed = copy.deepcopy(full); changed[i]["shapeSha256"] = "0" * 64
            with self.assertRaises(Blocked):
                r.source_census(changed)
        with self.assertRaises(Blocked):
            r.source_census(full[1:] + [full[1]])

    def test_requests_and_control_counts_are_fixed(self):
        for field, value in (("family", "3"), ("fixture", "absent"), ("tree", "[1]"), ("inputs", "[1]"),
                             ("controls", "0"), ("stage", "ADAPTER_VERIFIED"), ("case", "01")):
            changed = observations(); changed[0][field] = value
            with self.assertRaises(Blocked):
                r.program(changed, sources())

    def test_noncanonical_arrays_booleans_and_integers(self):
        for value in ("[01]", "[ 1]", "[true]", "[-1]", "[3]", "{}", "null", "[1.0]"):
            with self.assertRaises(Blocked):
                r.array(value, maximum=2)
        for value in ("TRUE", "0", "true "):
            with self.assertRaises(Blocked):
                r.boolean(value)
        for value in ("00", "+1", " 1", "1.0", "-1", "1000"):
            with self.assertRaises(Blocked):
                r.integer(value, 100)

    def test_replayed_outputs_are_not_encoder_truth(self):
        for field, value in (("outputs", "[2]"), ("fibers", "[[99]]"), ("splices", "[[99]]"),
                             ("accepted", "false"), ("indexMatches", "false")):
            changed = observations(); changed[0][field] = value
            code, _ = r.program(changed, sources())
            self.assertNotEqual(code, r.program(observations(), sources())[0])

    def test_recursive_order_and_splice_preorder(self):
        tree = [[[0, 1], 2], 0]
        self.assertEqual(r.leaf_order(tree), [0, 1, 2, 0])
        self.assertEqual(r.splice_coordinates(tree), [[0, 2, 2, 0], [0, 0, 2, 2, 0]])

    def test_each_recursive_export_and_reversal_is_required(self):
        full = observations()
        for i, row in enumerate(full):
            if row["surface"] != "wireTree":
                continue
            omitted = [dict(row, case=str(j)) for j, row in enumerate(full[:i] + full[i + 1:])]
            with self.assertRaises(Blocked):
                r.program(omitted, sources())
            ledger = r.array(row["splices"], depth=2)
            self.assertEqual(len(ledger), 2)
            self.assertNotEqual(ledger, list(reversed(ledger)))

    def test_named_reversal_rejects_empty_and_substitute_ledgers(self):
        full = observations()
        for i, row in enumerate(full):
            if row["surface"] != "wireTree" or not row["fixture"].endswith(":reverseSplices"):
                continue
            ledger = r.array(row["splices"], depth=2)
            substitute = copy.deepcopy(ledger)
            substitute[0][-1] = 99
            for candidate in ([], substitute, list(reversed(ledger)), [ledger[0], ledger[0]]):
                with self.subTest(family=row["family"], fixture=row["fixture"], candidate=candidate):
                    changed = [dict(value) for value in full]
                    changed[i]["splices"] = r.encode(candidate)
                    with self.assertRaisesRegex(Blocked, "exact registered reversal"):
                        r.program(changed, sources())
        code, _ = r.program(full, sources())
        self.assertEqual(code.count(")).reverse == "), 10)

    def test_no_static_verifier_dependency_or_private_reflection(self):
        source = (Path(__file__).resolve().parents[1] / "src/is/fivefivefive/CanDis/theory/ContainerWitnessTransitionsRegressionTest.java").read_text()
        self.assertNotIn("import org.acgn.cert", source)
        self.assertNotIn("setAccessible", source)
        self.assertNotIn("getDeclared", source)
        self.assertIn('Class.forName("org.acgn.cert." + name)', source)
        self.assertIn('api("IndependentVerifier").getConstructor()', source)

    def test_source_controls_have_unique_actual_targets(self):
        root = Path(__file__).resolve().parents[1]
        mutations = r.source_mutations()
        self.assertEqual(len(mutations), 10)
        self.assertEqual(len({m[0] for m in mutations}), 10)
        for label, relative, old, new, extractor in mutations:
            self.assertEqual((root / relative).read_text().count(old), 1, label)
            self.assertNotEqual(old, new)
            self.assertEqual(extractor, "ContainerWitnessTransitionsExtractor")


if __name__ == "__main__":
    unittest.main()
