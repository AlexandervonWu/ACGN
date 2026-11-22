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
    def test_pre_recursive_integer_adapter_pins_are_rejected(self):
        shape = "b583b8d4c87dc505d5391eafeffa3e2927c504dd29836a4a185481eb77f9e7c5"
        bindings = "c7e96284672950a308c81ed1e6741ba5b626e0988cf58aa2dc9854b290500fec"
        for stale in ({"shapeSha256": shape}, {"bindingsSha256": bindings},
                      {"shapeSha256": shape, "bindingsSha256": bindings}):
            changed = sources()
            next(row for row in changed if row["object"] == "TheoryAlloyAdapter").update(stale)
            with self.subTest(fields=tuple(stale)), self.assertRaises(Blocked):
                r.validate_sources(changed)

    def test_pre_publication_bindings_are_not_accepted_as_alternatives(self):
        import fourth_container_replays as containers
        import fifth_flat_container_replays as records
        old = {
            "CertificateVerificationScope": "b756bbdfe372252e690bb2811a56e671e199ae5cda83c1fe4f42f0b12d24822a 986c75b0fef819e817dfb1cf29590e7d2c553fdc0b3f2ad48189403c171b4805",
            "CertificateVerifier": "368b02d882d4bcf7395cfc0dc76ccf1c0140b91bac7881340966e3594d393146 c4917a8b2603d5b8d751c0c881dede3c6de748875d447cf1d22566d15b7cd654",
            "TheoryAlloyAdapter": "34fab8469ffe44905c7aedb253c0bb27b40257987281bfc61536c2550c23d86f 65675f4936fbd2b8f5a2e056c752d728be467f4d574096863252da0939580b25",
            "EGraphNode": "ee8a3ff167b38878bffa8429c7735de618a19f5832d23abaa518d61be39b7b54 ce15aa5eb135475c10b7890732c2a94ff367edfb4a94f2e45305f14d27cb446b",
            "NormalForm": "ea74cf5d68c587d1bfd0848a3b3630400e2062a083d48754696865d2620c8412 7a162a721d2710f615cd1309aae94a245a9e92600ef78e8a4dbc5ea530a7912b",
        }
        for name, pins in old.items():
            changed = sources()
            row = next(s for s in changed if s["object"] == name)
            row["shapeSha256"], row["bindingsSha256"] = pins.split()
            with self.subTest(name=name), self.assertRaises(Blocked):
                r.validate_sources(changed)
        for module in (containers, records):
            for name, pins in old.items():
                if name not in module.SOURCE_PINS:
                    continue
                changed = [dict(object=n, owner=("org.acgn.cert." if n == "SemanticEvidenceVerifier"
                           else "is.fivefivefive.CanDis.theory.") + n,
                           shapeSha256=p.split()[0], bindingsSha256=p.split()[1])
                           for n, p in module.SOURCE_PINS.items()]
                row = next(s for s in changed if s["object"] == name)
                row["shapeSha256"], row["bindingsSha256"] = pins.split()
                with self.subTest(module=module.__name__, name=name), self.assertRaises(Blocked):
                    module.source_census(changed)

    def test_pre_parity_source_pins_are_rejected(self):
        old = {
            "EGraphNode": "a3dcefcf9f13b10cf7883954a822a3d01d2a975d953214550eeb454958296a39 17723240dfec4fb1add3566251897704133d13eb339d0d7b5862cb5fa54aa637",
            "NormalForm": "ab9bfc73fc9e8489d60d8114188ae8fee2b5ef21486eee7767360ab9cb059f79 fc5576cd2d9e19533cbb680801d2972d2348a3c293b1f2495fc539d7e806e5f0",
        }
        for name, pins in old.items():
            changed = sources()
            row = next(s for s in changed if s["object"] == name)
            row["shapeSha256"], row["bindingsSha256"] = pins.split()
            with self.subTest(name=name), self.assertRaises(Blocked):
                r.program(observations(), changed)

    def test_pre_binding_origin_source_pins_are_rejected(self):
        previous = {
            "EGraphNode": ("6069b147c740722ba39abe8611649937c9845caa49e3db62375ec79f38b4de48", "fd1a2f18477610ca7818fa84c60bf0ef1a68c97095a362c9293e34d9841f6e0a"),
            "NormalForm": ("4985ef2fc4bf7c7654aa04ca601a5e1321230fb36e180bd1c174df178007028b", "2a8a9d3f385f374e56dc14768a789232e4ff11fea818ebf353e42017d8cb7e55"),
        }
        for name, (shape, bindings) in previous.items():
            for stale in ({"shapeSha256": shape}, {"bindingsSha256": bindings},
                          {"shapeSha256": shape, "bindingsSha256": bindings}):
                changed = sources()
                row = next(s for s in changed if s["object"] == name)
                row.update(stale)
                with self.subTest(name=name, fields=tuple(stale)), self.assertRaisesRegex(
                        Blocked, "source-bindings: source pin/census"):
                    r.validate_sources(changed)

    def test_pre_source_scheduling_pins_are_rejected(self):
        old = {
            "EGraphNode": "1d2be2e4e27d13be711cf92589564f6d0c6664b326bad2e405bd8250c5c0a561 011ba3078eff66a3e5efd116a1e2cd92dae8e4f4621f87c1802d483af873d4a7",
            "NormalForm": "db00a8a9b8a5bbe7a6b12f455b570774b1b7a6416df1042c8747dc1efeb60ad6 cb766573b1d9443941a6d6d77ed92189c2f90cb416c2d994e36869f04315ec7c",
        }
        for name, pins in old.items():
            shape, bindings = pins.split()
            for stale in ({"shapeSha256": shape}, {"bindingsSha256": bindings},
                          {"shapeSha256": shape, "bindingsSha256": bindings}):
                changed = sources()
                row = next(s for s in changed if s["object"] == name)
                row.update(stale)
                with self.subTest(name=name, fields=tuple(stale)), self.assertRaisesRegex(
                        Blocked, "source-bindings: source pin/census"):
                    r.validate_sources(changed)

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
        self.assertEqual(count, 189)
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
        self.assertEqual(len(mutations), 19)
        self.assertEqual(len({m[0] for m in mutations}), 19)
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
            self.assertEqual(count, 189)
            negatives = r.negatives(build, build)
            self.assertEqual(len(negatives), 16)
            self.assertEqual(len({n[0] for n in negatives}), 16)
            for _, name, negative in negatives:
                self.assertEqual(name, "RejectSourceOccurrenceBindings.lean")
                self.assertEqual(len(re.findall(r"^theorem ", negative, re.M)), 1)


if __name__ == "__main__":
    unittest.main()
