"""Encoder unit tests only; synthetic rows are not implementation evidence."""

import copy
import csv
import json
from pathlib import Path
import re
import tempfile
import unittest

from third_call_replays import (
    AUTHORITIES, Blocked, CALL_CENSUS, CALL_FIELDS, CALL_OCCURRENCES,
    CALL_REPLAY, CALL_SOURCE_FIELDS, CALL_SOURCE_OBJECTS, CALL_SOURCE_TRACE,
    CALL_TRACE, Encoder, REPLAY_NAMESPACE, call_program, generate, module,
    natural, negatives, parsed_row, rows, signature, source_mutations, tree,
)


def extracted():
    return [dict(zip(CALL_SOURCE_FIELDS, (key, *value))) for key, value in CALL_SOURCE_OBJECTS.items()]


def sig(n=1, callee="test/f"):
    return [callee, "call/expression", n, "DECLARATION"]


def call(n, args, callee="test/f"):
    return ["call", sig(n, callee), args]


def observed():
    result = []
    for fixture, count in CALL_CENSUS.items():
        arity = int(fixture[6:]) if fixture.startswith("arity-") else 1
        table = [sig(n) for n in sorted({0, 1, 2, 3, 5, 8, 16, arity})]
        for i in range(count):
            syntax = call(arity, [["atom", 1 + k % 3] for k in range(arity)])
            if fixture == "nested":
                if i == 0:
                    syntax = call(2, [["atom", 1], ["atom", 1]])
                elif i == 1:
                    syntax = call(2, [["atom", 1], ["atom", 2]])
                elif i == 2:
                    syntax = call(1, [call(1, [["atom", 1]])])
                elif i == 3:
                    syntax = call(1, [["barrier", "CARDINALITY", [call(1, [["atom", 1]])]]])
            n = syntax[1][2]
            row = dict(zip(CALL_FIELDS, ["call-authority-v1", fixture, str(i), str(i + 10), "1",
                json.dumps(table), json.dumps([n] if n else []), json.dumps(syntax[1]),
                *[json.dumps(syntax)] * 4, "0", "1", "1", "true", "2", "2", "false", "1", str(n),
                "ORDERED_SEQUENCE", f"phase/0/matrix/child/{i}", "0" * 64]))
            result.append(row)
    return result


def write(path, fields, values):
    with path.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fields, delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(values)


class CallEncoderTests(unittest.TestCase):
    def setUp(self):
        self.observed = observed()
        self.extracted = extracted()

    def test_positive_count_and_closed_namespace(self):
        source, count = call_program(self.observed, self.extracted)
        self.assertEqual(count, CALL_OCCURRENCES)
        self.assertEqual(len(re.findall(r"^theorem \w+", source, re.M)), count)
        self.assertEqual(len(re.findall(r"^#print axioms \w+", source, re.M)), count)
        self.assertEqual(source.count("namespace " + REPLAY_NAMESPACE), 1)
        self.assertTrue(source.endswith("end " + REPLAY_NAMESPACE + "\n"))

    def test_deterministic_and_no_input_mutation(self):
        saved = copy.deepcopy(self.observed)
        self.assertEqual(call_program(self.observed, self.extracted), call_program(self.observed, self.extracted))
        self.assertEqual(saved, self.observed)

    def test_natural_syntax(self):
        for value in ("00", "-1", "+1", " 1", "1.0", "1\n", "1e1", "", "9" * 20, 1, True):
            with self.subTest(value=value), self.assertRaises(Blocked):
                natural(value)
        self.assertEqual(natural("2147483647"), 2147483647)

    def test_exact_occurrence_census(self):
        for changed in (self.observed[:-1], self.observed + [self.observed[0]], self.observed[1:] + [self.observed[1]]):
            with self.assertRaises(Blocked):
                call_program(changed, self.extracted)

    def test_unknown_identity_and_duplicate_owner(self):
        for field, value in (("fixture", "unknown"), ("occurrence", "999"), ("owner", self.observed[1]["owner"]),
                             ("ir_policy", "COMMUTATIVE_BAG"), ("schema", "unknown")):
            changed = copy.deepcopy(self.observed)
            changed[0][field] = value
            with self.subTest(field=field), self.assertRaises(Blocked):
                call_program(changed, self.extracted)

    def test_source_census_and_binding(self):
        with self.assertRaises(Blocked):
            call_program(self.observed, self.extracted[:-1])
        for field in CALL_SOURCE_FIELDS:
            changed = copy.deepcopy(self.extracted)
            changed[0][field] = "foreign"
            with self.subTest(field=field), self.assertRaises(Blocked):
                call_program(self.observed, changed)

    def test_bad_tree_grammar(self):
        for syntax in (["atom", True], ["atom", -1], ["atom", 1, 2], ["call", sig(), "bad"],
                       ["set", 0, []], ["call", sig()[:-1], []], ["barrier", "", []], {}):
            with self.subTest(syntax=syntax), self.assertRaises(Blocked):
                tree(syntax)

    def test_tree_depth_bound(self):
        syntax = ["atom", 1]
        for _ in range(130):
            syntax = call(1, [syntax])
        with self.assertRaises(Blocked):
            tree(syntax)

    def test_explicit_authority_not_spelling(self):
        self.assertEqual(signature(sig(0, "util/integer/first"))[3], "DECLARATION")
        for authority in ("declaration", "INFERRED_FROM_NAME", None):
            value = sig()
            value[3] = authority
            with self.assertRaises(Blocked):
                signature(value)

    def test_foreign_target_does_not_inherit_source_token(self):
        row = copy.deepcopy(self.observed[0])
        actual = json.loads(row["cert_tree"])
        actual[1][0] = "wrong/source"
        row["cert_tree"] = json.dumps(actual)
        parsed = parsed_row(row)
        encoder = Encoder([parsed])
        self.assertNotEqual(encoder.callees["wrong/source"], encoder.callees["test/f"])
        source = module([row])
        self.assertIn(f"Signature.mk {encoder.callees['wrong/source']}", source)

    def test_target_arity_and_payload_not_repaired(self):
        row = copy.deepcopy(self.observed[0])
        actual = call(7, [["atom", 99]])
        row["cert_tree"] = json.dumps(actual)
        source = module([row])
        self.assertIn(" 1 7 0)", source)
        self.assertIn("(.scalar 99)", source)
        self.assertIn(" 1 0 0)", source)

    def test_parameter_authority_independent_of_observation(self):
        row = copy.deepcopy(self.observed[0])
        row["declaration_groups"] = "[2,3]"
        source = module([row])
        self.assertIn("declaredArity [2, 3]", source)
        self.assertIn(" 1 0 0)", source)

    def test_counter_targets_not_synthesized(self):
        row = copy.deepcopy(self.observed[0])
        row.update(first_after="7", second_visit="8", second_accept="true")
        source = module([row])
        self.assertIn("= (7, some 1)", source)
        self.assertIn("consume 7 1", source)
        self.assertIn("= (2, some 8)", source)

    def test_authority_table_consistency(self):
        changed = copy.deepcopy(self.observed)
        table = json.loads(changed[0]["signature_table"])
        table[0][0] = "foreign/table"
        changed[0]["signature_table"] = json.dumps(table)
        with self.assertRaises(Blocked):
            call_program(changed, self.extracted)

    def test_malformed_tsv(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "trace.tsv"
            write(path, CALL_FIELDS, self.observed)
            self.assertEqual(rows(path, CALL_FIELDS), self.observed)
            for fields in (CALL_FIELDS[:-1], CALL_FIELDS + ["extra"]):
                write(path, fields, [])
                with self.assertRaises(Blocked):
                    rows(path, CALL_FIELDS)
            bad = dict(self.observed[0], cert_path="bad\npath")
            write(path, CALL_FIELDS, [bad])
            with self.assertRaises(Blocked):
                rows(path, CALL_FIELDS)

    def test_plugin_apis_and_negative_module_closure(self):
        with tempfile.TemporaryDirectory() as directory:
            build = Path(directory)
            write(build / CALL_TRACE, CALL_FIELDS, self.observed)
            write(build / CALL_SOURCE_TRACE, CALL_SOURCE_FIELDS, self.extracted)
            generated = generate(build, build)
            self.assertEqual([(name, count) for name, _, count in generated], [(CALL_REPLAY, CALL_OCCURRENCES)])
            controls = negatives(build, build)
            self.assertEqual(len(controls), 13)
            self.assertEqual(len({label for label, _, _ in controls}), len(controls))
            for label, name, source in controls:
                self.assertTrue(source.endswith("end " + REPLAY_NAMESPACE + "\n"), label)
                self.assertEqual(len(re.findall(r"^theorem \w+", source, re.M)), 1)
                self.assertEqual(name, "RejectCallAuthority.lean")

    def test_source_mutation_contract(self):
        controls = source_mutations()
        self.assertEqual(len(controls), 10)
        self.assertEqual(len({entry[0] for entry in controls}), len(controls))
        root = Path(__file__).resolve().parents[1]
        for label, source, old, new, extractor in controls:
            self.assertEqual((root / source).read_text(encoding="utf-8").count(old), 1, label)
            self.assertNotEqual(old, new)
            self.assertEqual(extractor, "CallAuthorityTransitionsExtractor")


if __name__ == "__main__":
    unittest.main()
