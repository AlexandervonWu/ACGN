#!/usr/bin/env python3
"""Finite regression controls for the certified Java-to-Lean observation boundary."""

import copy
import json
from pathlib import Path
import sys
import unittest

sys.dont_write_bytecode = True
from run_java_lean_refinement import (
    Blocked, CONFIG, check_rows, expected_sources, leaves, render_observations,
    render_program, unique_object,
)


def source_json(source):
    return {"leaf": source[1]} if source[0] == "leaf" else {
        "children": [source_json(child) for child in source[1]]}


class RefinementBoundaryTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = json.loads((Path(__file__).resolve().parents[1] / CONFIG).read_text())
        cls.payload = {"schemaVersion": 1, "alphabetSize": 3, "maxLength": 4, "rows": []}
        # Encoder/census fixtures only. Runtime correspondence uses the Java probe.
        for head in cls.config["bounds"]["heads"]:
            for profile in cls.config["bounds"]["profiles"]:
                for shape, source in sorted(expected_sources()):
                    word = leaves(source)
                    output = sorted(set(word))
                    cls.payload["rows"].append({
                        "id": len(cls.payload["rows"]), "head": head, "profile": profile,
                        "shape": shape, "source": source_json(source),
                        "certificateSource": source_json(source) if word else None,
                        "outcome": "REJECTED_EMPTY" if not word else "SINGLETON" if len(output) == 1 else "NODE",
                        "output": output, "traceInput": word, "traceOutput": output,
                        "fibers": [[i for i, value in enumerate(word) if value == x] for x in output],
                        "hasUnit": False, "certificatePresent": bool(word), "tracePresent": bool(word),
                        "certificateVerified": True, "sourceBound": True, "targetBound": True,
                    })
        cls.program = {
            "condition": {"kind": "and", "left": {"kind": "isSet"}, "right": {
                "kind": "eq", "left": {"kind": "size"}, "right": {"kind": "nat", "value": 1}}},
            "rejectionGuard": {"kind": "not", "condition": {"kind": "isOne"}},
            "whenTrue": "SINGLETON", "whenFalse": "NODE",
        }

    def changed(self):
        return copy.deepcopy(self.payload)

    def rejected(self, payload):
        with self.assertRaises(Blocked):
            check_rows(payload, self.config)

    def test_exact_source_census(self):
        self.assertEqual(len(expected_sources()), 589)
        self.assertEqual(len(check_rows(self.payload, self.config)), 2356)

    def test_missing_input(self):
        payload = self.changed()
        payload["rows"].pop()
        self.rejected(payload)

    def test_duplicate_input(self):
        payload = self.changed()
        payload["rows"][1] = dict(payload["rows"][0], id=1)
        self.rejected(payload)

    def test_changed_bound(self):
        self.rejected(dict(self.payload, maxLength=3))

    def test_source_certificate_disagreement(self):
        payload = self.changed()
        payload["rows"][0]["certificateSource"] = {"children": [{"leaf": 2}]}
        self.rejected(payload)

    def test_target_certificate_disagreement(self):
        payload = self.changed()
        payload["rows"][0]["traceOutput"] = [2]
        self.rejected(payload)

    def test_unverified_certificate(self):
        payload = self.changed()
        payload["rows"][0]["certificateVerified"] = False
        self.rejected(payload)

    def test_wrong_trace_origin(self):
        payload = self.changed()
        payload["rows"][0]["traceInput"] = [2]
        self.rejected(payload)

    def test_invalid_fiber(self):
        payload = self.changed()
        payload["rows"][0]["fibers"] = [[99]]
        self.rejected(payload)

    def test_no_unit_boundary(self):
        payload = self.changed()
        payload["rows"][0]["hasUnit"] = True
        self.rejected(payload)

    def test_boolean_not_atom_id(self):
        payload = self.changed()
        payload["rows"][0]["source"] = {"children": [{"leaf": True}]}
        self.rejected(payload)

    def test_boolean_not_certificate_atom_id(self):
        payload = self.changed()
        row = next(row for row in payload["rows"] if row["output"] == [1])
        row["traceOutput"] = [True]
        self.rejected(payload)

    def test_float_not_certificate_atom_id(self):
        payload = self.changed()
        row = next(row for row in payload["rows"] if row["output"] == [1])
        row["traceOutput"] = [1.0]
        self.rejected(payload)

    def test_boolean_not_schema_version(self):
        self.rejected(dict(self.payload, schemaVersion=True))

    def test_boolean_not_row_id(self):
        payload = self.changed()
        payload["rows"][0]["id"] = False
        self.rejected(payload)

    def test_empty_row_null_output(self):
        payload = self.changed()
        row = next(row for row in payload["rows"] if row["outcome"] == "REJECTED_EMPTY")
        row["output"] = None
        self.rejected(payload)

    def test_empty_row_cannot_carry_certificate(self):
        payload = self.changed()
        row = next(row for row in payload["rows"] if row["outcome"] == "REJECTED_EMPTY")
        row["certificatePresent"] = True
        self.rejected(payload)

    def test_program_encodes_actual_threshold(self):
        program = copy.deepcopy(self.program)
        program["condition"]["right"]["right"]["value"] = 2
        self.assertIn("(.literal 2)", render_program(program))
        self.assertNotIn("(.literal 1)", render_program(program))

    def test_program_encodes_actual_short_circuit(self):
        program = copy.deepcopy(self.program)
        program["condition"]["kind"] = "or"
        self.assertIn("(.or .isSet", render_program(program))

    def test_unmodeled_expression_rejects(self):
        program = copy.deepcopy(self.program)
        program["condition"] = {"kind": "methodCall"}
        with self.assertRaises(Blocked):
            render_program(program)

    def test_duplicate_json_key(self):
        with self.assertRaises(Blocked):
            json.loads('{"source": 1, "source": 2}', object_pairs_hook=unique_object)

    def test_encoding_preserves_observed_data(self):
        row = copy.deepcopy(self.payload["rows"][0])
        row.update(source={"children": [{"leaf": 2}, {"leaf": 0}, {"leaf": 2}]},
                   traceInput=[2, 0, 2], output=[2, 0], fibers=[[0, 2], [1]], outcome="NODE")
        emitted, count = render_observations([row])
        self.assertIn("input := [2, 0, 2], output := [2, 0], fibers := [[0, 2], [1]]", emitted)
        self.assertIn("source := (.flat [2, 0, 2])", emitted)
        self.assertIn("_java_target", emitted)
        self.assertEqual(count, 12)
        self.assertNotIn("native_decide", emitted)


if __name__ == "__main__":
    unittest.main()
