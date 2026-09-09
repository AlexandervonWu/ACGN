#!/usr/bin/env python3
"""Synthetic encoder tests only; never substitute these rows for Java output."""

import base64
from collections import Counter
from pathlib import Path
import re
import tempfile
import unittest

import fifth_source_bindings_replays as r
from run_submission_container_closure import Blocked
from run_submission_container_closure import scan_proof


def sources():
    return [dict(zip(r.SOURCE_FIELDS, (name, r.owner(name), *r.PINS[name].split()))) for name in sorted(r.PINS)]


def observations():
    return [dict(zip(r.FIELDS, (fixture, field, base64.b64encode(r.expected_value(spec).encode()).decode())))
            for (fixture, field), spec in r.expected_census().items()]


class SourceBindingsReplayTest(unittest.TestCase):
    def test_independent_census(self):
        rows = observations()
        self.assertEqual(len(rows), 171)
        self.assertEqual(Counter(row["fixture"].split(":")[0] for row in rows),
                         {"JOIN": 60, "ARROW": 60, "ownership": 4, "temporal": 23,
                          "aci": 12, "provenance": 4, "encoding": 8})

    def test_paths_keep_occurrences_and_phases(self):
        entries = r.path_entries([None, ((), ()), ()])
        self.assertEqual(entries, [(0, 1, ()), (1, 1, (0,)), (2, 1, (1,)), (3, 2, ())])
        self.assertEqual(r.path_string(10, (12, 0)), "phase/10/matrix/child/12/child/0")

    def test_encoding_exact_utf16(self):
        for s, length in (("a:{}[];@", 8), ("\u03b1", 1), ("\U0001d400", 2), ("e\u0301", 2)):
            self.assertEqual(r.utf16_length(s), length)
            c = ("leaf", s)
            self.assertEqual(r.encode_content(c), f"4:leaf{length}:{s}")
            self.assertEqual(r.decoded(base64.b64encode(s.encode()).decode()), s)

    def test_delimiter_names_and_association_retained(self):
        self.assertNotEqual(r.encode_content(("leaf", "a:1:b")), r.encode_content(("leaf", "a")))
        for op in ("JOIN", "ARROW"):
            self.assertNotEqual(r.content(op, "left"), r.content(op, "right"))
            self.assertNotEqual(r.encode_content(r.content(op, "left")), r.encode_content(r.content(op, "right")))
            self.assertNotEqual(r.content(op, "left"), r.content(op, "repeat"))

    def test_aci_keeps_certified_not_repaired_content(self):
        census = r.expected_census()
        self.assertNotEqual(census["aci", "0/content"], census["aci", "0/repairContent"])
        self.assertEqual(census["aci", "0/content"], census["aci", "0/certifiedContent"])
        self.assertEqual(census["aci", "0/sourceTransfer"], census["aci", "0/repairTransfer"])
        self.assertNotEqual(census["temporal", "0/certifiedPath"], census["temporal", "1/certifiedPath"])

    def test_bad_base64_unicode_rejected(self):
        for bad in ("YQ", "YQ===", "YR==", "YQ==\n", "/w==", "7aCA", "###", "A" * 200000):
            with self.subTest(bad=bad[:20]), self.assertRaises(Blocked):
                r.decoded(bad)

    def test_no_lean_unicode_json_escapes(self):
        d = r.Dictionary()
        d.text("\U0001d400\0")
        self.assertIn("ofCodepoints [119808, 0]", d.definitions[0])
        self.assertNotIn("\\u", d.definitions[0])

    def test_missing_extra_duplicate_reordered(self):
        full = observations()
        for changed in ([], full[:-1], full + full[-1:], full[::-1], [full[0], full[0], *full[2:]]):
            with self.assertRaises(Blocked):
                r.program(changed, sources())

    def test_every_source_pin_coordinate_frozen(self):
        for field in r.SOURCE_FIELDS:
            changed = sources()
            changed[0][field] = "wrong"
            with self.subTest(field=field), self.assertRaises(Blocked):
                r.program(observations(), changed)
        full = sources()
        for changed in ([], full[:-1], full[::-1], full + full[-1:], [full[0]] * len(full)):
            with self.assertRaises(Blocked):
                r.program(observations(), changed)

    def test_every_schema_coordinate_frozen(self):
        for field in r.FIELDS:
            changed = observations()
            del changed[0][field]
            with self.assertRaises(Blocked):
                r.program(changed, sources())
        for field in ("fixture", "field", "extra"):
            changed = observations()
            changed[0][field] = "wrong"
            with self.assertRaises(Blocked):
                r.program(changed, sources())

    def test_all_actual_values_enter_claims(self):
        baseline = r.program(observations(), sources())[0]
        for i, row in enumerate(observations()):
            changed = observations()
            kind = r.expected_census()[row["fixture"], row["field"]][0]
            wrong = (r.stable(r.key("wrong")) if kind in ("key", "wrapper") else
                     r.encode_content(("leaf", "wrong")) if kind == "content" else
                     "phase/999/matrix" if kind == "paths" else "wrong")
            changed[i]["value"] = base64.b64encode(wrong.encode()).decode()
            self.assertNotEqual(r.program(changed, sources())[0], baseline, (row["fixture"], row["field"]))

    def test_all_generated_theorems_audited_and_compact(self):
        code, count = r.program(observations(), sources())
        names = re.findall(r"^theorem (\w+)", code, re.M)
        self.assertEqual(count, 187)
        self.assertEqual(len(names), count)
        self.assertEqual(names, re.findall(r"^#print axioms (\w+)", code, re.M))
        self.assertLess(len(code), 110000)
        self.assertNotRegex(code, r"\b(sorry|axiom|unsafe|native_decide)\b")

    def test_general_proof_audits(self):
        proof = Path(__file__).resolve().parents[1] / "docs/section3-repair-audit/formal/SourceOccurrenceBindings.lean"
        code = proof.read_text()
        names = re.findall(r"^theorem (\w+)", code, re.M)
        self.assertEqual(len(names), 21)
        self.assertEqual(scan_proof(proof), names)
        self.assertCountEqual(names, re.findall(r"^#print axioms (\w+)", code, re.M))
        self.assertIn("namespace ACGN.FifthFive.Source", code)
        self.assertNotRegex(code, r"\b(sorry|axiom|unsafe|native_decide)\b")

    def test_content_parser_checks_full_grammar(self):
        for (_, field), spec in r.expected_census().items():
            if spec[0] == "content":
                self.assertEqual(r.parse_content(r.expected_value(spec)), spec[1], field)
            elif spec[0] == "wrapper":
                raw = r.expected_value(spec)
                self.assertEqual(r.stable(r.parse_utf16_key(raw)), raw)
        for bad in ("4:leaf01:a", "4:leaf2:a", "4:leaf1:\U0001d400", "4:leaf1:aX", "3:bad", "11:application"):
            with self.subTest(bad=bad), self.assertRaises(Blocked):
                r.parse_content(bad)
        for bad in ("0:[0:]{0:}", "1:a[00:]{0:}", "1:a[0:]{1:0:}", "1:a[0:]{0:}X"):
            with self.subTest(bad=bad), self.assertRaises(Blocked):
                r.parse_utf16_key(bad)

    def test_registered_source_mutations(self):
        root = Path(__file__).resolve().parents[1]
        mutations = r.source_mutations()
        self.assertEqual(len(mutations), 16)
        self.assertEqual(len({m[0] for m in mutations}), 16)
        for name, path, old, new, extractor in mutations:
            self.assertEqual((root / path).read_text().count(old), 1, name)
            self.assertNotEqual(old, new)
            self.assertEqual(extractor, "SourceOccurrenceBindingsExtractor")

    def test_tsv_framing(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "trace.tsv"
            for data in (b"fixture\tfield\tvalue", b"field\tfixture\tvalue\n", b"fixture\tfield\tvalue\r\n",
                         b"fixture\tfield\tvalue\na\tb\tc\td\n", b"fixture\tfield\tvalue\na\tb\n"):
                path.write_bytes(data)
                with self.assertRaises(Blocked):
                    r.rows(path, r.FIELDS)

    def test_dispatcher_apis(self):
        with tempfile.TemporaryDirectory() as tmp:
            build = Path(tmp)
            for name, fields, data in (("source-occurrence-bindings.tsv", r.FIELDS, observations()),
                    ("source-occurrence-bindings-source.tsv", r.SOURCE_FIELDS, sources())):
                (build / name).write_text("\t".join(fields) + "\n" + "".join("\t".join(row[f] for f in fields) + "\n" for row in data))
            replay, code, count = r.generate(build, build)[0]
            self.assertEqual(replay, "SourceOccurrenceBindingsReplay.lean")
            self.assertEqual(count, 187)
            negatives = r.negatives(build, build)
            self.assertEqual(len(negatives), 16)
            self.assertEqual(len({n[0] for n in negatives}), 16)
            for _, name, negative in negatives:
                self.assertEqual(name, "RejectSourceOccurrenceBindings.lean")
                self.assertEqual(len(re.findall(r"^theorem ", negative, re.M)), 1)


if __name__ == "__main__":
    unittest.main()
