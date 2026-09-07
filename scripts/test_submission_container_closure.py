#!/usr/bin/env python3
"""Regression controls for the finite runtime-to-Lean replay boundary."""

import copy
import itertools
import json
from pathlib import Path
import tempfile
import unittest
import sys

sys.dont_write_bytecode = True
from run_submission_container_closure import (
    Blocked, CONFIG, audit_assumptions, check_census, render_replay, unique_object,
)


class ContainerClosureTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = json.loads((Path(__file__).resolve().parents[1] / CONFIG).read_text())
        cls.payload = {"schemaVersion": 1, "alphabetSize": 3, "maxLength": 4, "rows": []}
        # This is a census/encoding fixture, not evidence about Java normalization.
        for carrier in ("BOOL", "REL"):
            for kind in ("SEQ", "BAG", "SET"):
                for length in range(5):
                    for word in itertools.product(range(3), repeat=length):
                        cls.payload["rows"].append({
                            "rowId": len(cls.payload["rows"]), "carrier": carrier, "kind": kind,
                            "input": list(word), "output": list(word),
                            "fibers": [[i] for i in range(length)],
                            "atoms": [{"id": i, "portEncoding": f"{carrier}/port/{i}",
                                       "slotEncoding": f"{carrier}/slot/{i}"} for i in range(3)],
                        })

    def test_complete_census(self):
        self.assertEqual(len(check_census(self.payload, self.config)), 726)

    def test_missing_row(self):
        changed = copy.deepcopy(self.payload)
        changed["rows"].pop()
        with self.assertRaises(Blocked):
            check_census(changed, self.config)

    def test_duplicate_input(self):
        changed = copy.deepcopy(self.payload)
        changed["rows"][2] = dict(changed["rows"][1], rowId=2)
        with self.assertRaises(Blocked):
            check_census(changed, self.config)

    def test_changed_bounds(self):
        changed = dict(self.payload, maxLength=3)
        with self.assertRaises(Blocked):
            check_census(changed, self.config)

    def test_wrong_kind(self):
        changed = copy.deepcopy(self.payload)
        changed["rows"][0]["kind"] = "FIXED"
        with self.assertRaises(Blocked):
            check_census(changed, self.config)

    def test_boolean_is_not_slot_integer(self):
        changed = copy.deepcopy(self.payload)
        changed["rows"][1]["input"] = [True]
        with self.assertRaises(Blocked):
            check_census(changed, self.config)

    def test_invalid_output_slot(self):
        changed = copy.deepcopy(self.payload)
        changed["rows"][1]["output"] = [3]
        with self.assertRaises(Blocked):
            check_census(changed, self.config)

    def test_fiber_bounds(self):
        changed = copy.deepcopy(self.payload)
        changed["rows"][1]["fibers"] = [[1]]
        with self.assertRaises(Blocked):
            check_census(changed, self.config)

    def test_noninjective_port_encoding(self):
        changed = copy.deepcopy(self.payload)
        changed["rows"][0]["atoms"][1]["portEncoding"] = changed["rows"][0]["atoms"][0]["portEncoding"]
        with self.assertRaises(Blocked):
            check_census(changed, self.config)

    def test_duplicate_json_key(self):
        with self.assertRaises(Blocked):
            json.loads('{"input": [0], "input": [1]}', object_pairs_hook=unique_object)

    def test_encoder_preserves_observed_order_and_fibers(self):
        row = {"kind": "BAG", "input": [2, 0, 2], "output": [0, 2, 2], "fibers": [[1], [0], [2]]}
        emitted = render_replay([row])
        self.assertIn("input := [2, 0, 2], output := [0, 2, 2], fibers := [[1], [0], [2]]", emitted)
        self.assertIn("theorem observed_0000", emitted)
        self.assertNotIn("native_decide", emitted)

    def test_assumption_inventory(self):
        with tempfile.TemporaryDirectory() as work:
            log = Path(work) / "axioms.log"
            log.write_text("'a' does not depend on any axioms\n'b' depends on axioms: [propext, Quot.sound]\n")
            audit_assumptions(log, 2)
            with self.assertRaises(Blocked):
                audit_assumptions(log, 3)
            log.write_text("'a' depends on axioms: [sorryAx]\n")
            with self.assertRaises(Blocked):
                audit_assumptions(log, 1)


if __name__ == "__main__":
    unittest.main()
