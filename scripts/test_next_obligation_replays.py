import csv
from pathlib import Path
from itertools import product
import tempfile
import unittest

from next_obligation_replays import (
    Blocked, FLAT_FIELDS, flat_program, natural, rows, text, tree_program, associations,
    CALL_ARITIES, CALL_FIELDS, CALL_CONTROLS, call_program, CHAIN_MODELS, chain_program,
)


class ReplayEncodingTest(unittest.TestCase):
    def test_flat_census(self):
        observed = [{"case": str(i), "kind": ["SEQ", "BAG", "SET"][i // 225],
                     "element": "INT", "output": "INT", "expected": "INT"} for i in range(675)]
        source = [{"elementSubstitution": "typeArguments", "resultSubstitution": "typeArguments",
                   "checkedMethods": "10"}]
        program, count = flat_program(observed, source)
        self.assertEqual(count, 677)
        self.assertEqual(program.count("#print axioms"), 677)
        for invalid in (observed[:-1], observed + [observed[0]], [observed[0]] * 675):
            with self.assertRaises(Blocked):
                flat_program(invalid, source)
        for invalid in ([], source * 2, [dict(source[0], checkedMethods="9")]):
            with self.assertRaises(Blocked):
                flat_program(observed, invalid)

    def test_observations_not_replaced_by_expectations(self):
        observed = [{"case": str(i), "kind": ["SEQ", "BAG", "SET"][i // 225],
                     "element": "WRONG", "output": "INT", "expected": "EXPECTED"} for i in range(675)]
        source = [{"elementSubstitution": "x", "resultSubstitution": "y", "checkedMethods": "10"}]
        program, _ = flat_program(observed, source)
        self.assertIn('Observation.mk "WRONG" "INT" "EXPECTED"', program)
        self.assertIn('SubstitutionSites := ⟨"x", "y"⟩', program)

    def test_strict_table(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "observations.tsv"
            def write(fields, values):
                with path.open("w", encoding="utf-8", newline="") as stream:
                    writer = csv.writer(stream, delimiter="\t")
                    writer.writerow(fields)
                    writer.writerows(values)
            valid = ["0", "SEQ", "INT", "INT", "INT"]
            write(FLAT_FIELDS, [valid])
            self.assertEqual(len(rows(path, FLAT_FIELDS)), 1)
            for fields, values in ((FLAT_FIELDS, []), (FLAT_FIELDS[:-1], [valid[:-1]]),
                                   (FLAT_FIELDS, [valid + ["extra"]]), (FLAT_FIELDS, [valid[:-1]]),
                                   (FLAT_FIELDS, [valid[:-1] + ["bad\nvalue"]])):
                write(fields, values)
                with self.assertRaises(Blocked):
                    rows(path, FLAT_FIELDS)

    def test_primitive_encodings(self):
        for value in ("-1", "01", " 1", "1 ", "1.0", "１", "1" * 20):
            with self.assertRaises(Blocked):
                natural(value)
        self.assertEqual(natural("0"), "0")
        self.assertEqual(text('a"b\\c'), '"a\\"b\\\\c"')

    def test_chain_tree_syntax(self):
        term, leaves = tree_program("(0,(1,0))", "join")
        self.assertEqual(leaves, [0, 1, 0])
        self.assertEqual(term, "(.app .join (.leaf 0) (.app .join (.leaf 1) (.leaf 0)))")
        for value in ("", "(0,1", "(0;1)", "(0,1))", "(0,3)", "01", "(0, 1)"):
            with self.assertRaises(Blocked):
                tree_program(value, "join")

    def test_chain_census_and_actual_output(self):
        observed = []
        def add(surface, profile, kind, fixture, tree, word):
            observed.append(dict(surface=surface, profile=profile, kind=kind, fixture=fixture,
                tree=tree, source=",".join(map(str, word)), output=",".join(map(str, word)),
                length=str(len(word)), counts=",".join(str(word.count(i)) for i in range(3)), carrier="SEQ",
                replay="FULL_VERIFIED" if surface == "certificate" else "LOCAL_VERIFIED"))
        for profile, kind in product(("FORBID", "MODULAR"), ("JOIN", "ARROW")):
            for length in (2, 3, 4):
                for ordinal, word in enumerate(product(range(3), repeat=length)):
                    for shape in associations(word):
                        add("typed", profile, kind, f"{length}:{ordinal}", shape, word)
            for fixture in ("Left", "Right", "Swapped"):
                add("pipeline", profile, kind, fixture, "(0,(1,0))", (0, 1, 0))
                add("certificate", profile, kind, fixture, "(0,(1,0))", (0, 1, 0))
            add("barrier", profile, kind, "Barrier", "(0,1)", (0, 1))
        extracted = [dict(object=name, model=model, owner="synthetic-unit-test", method="synthetic",
                          arity="0", shapeSha256="0" * 64, bindingsSha256="1" * 64)
                     for name, model in CHAIN_MODELS.items()]
        code, count = chain_program(observed, extracted)
        self.assertEqual(count, 1900)
        self.assertEqual(code.count("#print axioms"), 1900)
        for invalid in (observed[:-1], observed + [observed[0]], [observed[0]] * 1900):
            with self.assertRaises(Blocked):
                chain_program(invalid, extracted)
        changed = [dict(row) for row in observed]
        changed[0].update(carrier="BAG", output="1")
        code, _ = chain_program(changed, extracted)
        self.assertIn("Target Nat := ⟨.bag, [1]⟩", code)

    def test_call_census_and_injective_target_tokens(self):
        observed = []
        for arity in CALL_ARITIES:
            for index in range(8):
                payload = ",".join(["1"] * arity)
                row = dict.fromkeys(CALL_FIELDS, "unused")
                row.update(schema="ordered-call-v1", fixture=f"arity-{arity}", parser_path=f"path/{index}",
                           occurrence=str(index), owner="7", visit="1", callee="same", kind="call/formula",
                           arity=str(arity), parser_payloads=payload, masg_payloads=payload, ir_payloads=payload,
                           cert_payloads=payload, positions=",".join(map(str, range(1, arity + 3))),
                           edge_owners=",".join(["7"] * (arity + 2)), edge_visits=",".join(["1"] * (arity + 2)),
                           edge_targets="callee," + ((payload + ",") if payload else "") + "end",
                           target_callee="same", target_kind="call/formula", target_arity=str(arity),
                           observation_sha256="0" * 64)
                observed.append(row)
        controls = [dict(control=name, owner=owner, method=method, start=str(bounds[0]),
                         endOffset=str(bounds[1]), step=str(bounds[2]))
                    for name, (owner, method, bounds) in CALL_CONTROLS.items()]
        self.assertEqual(call_program(observed, controls)[1], 59)
        for invalid in (observed[:-1], observed + [observed[0]], [observed[0]] * 56):
            with self.assertRaises(Blocked):
                call_program(invalid, controls)
        changed = [dict(row) for row in observed]
        changed[0]["target_callee"] = "different"
        code, _ = call_program(changed, controls)
        capture = code.split("def call0 :", 1)[1].split("theorem call_replay0", 1)[0]
        self.assertIn("(Capture.mk 7 1 1 0)", capture)
        self.assertIn("(Edge.mk 7 1 1 (.callee 0))", capture)
        changed[0]["edge_targets"] = "callee,1"
        code, _ = call_program(changed, controls)
        self.assertIn("(Edge.mk 7 1 2 (.argument 1))", code)


if __name__ == "__main__":
    unittest.main()
