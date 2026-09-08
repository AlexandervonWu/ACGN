#!/usr/bin/env python3
"""Encoder tests. Synthetic fixtures here are not implementation evidence."""

import base64
from collections import Counter
from pathlib import Path
import re
import unittest

import fourth_profile_replays as r
from run_submission_container_closure import Blocked


def b64(value):
    return base64.b64encode(value.encode()).decode()


def sources():
    return [dict(zip(r.SOURCE_FIELDS, (name, *r.SOURCES[name]))) for name in sorted(r.SOURCES)]


def observations():
    result = []
    for i, ((surface, fixture, mutation), (fields, authority, original)) in enumerate(r.census().items()):
        digest = r.sha(r.profile_key(fields if mutation.startswith("rehashed-") or mutation in r.VERSION_CONTROLS else original))
        if mutation == "digest":
            digest = "0" * 64
        outcome, detail = r.expected_outcome(surface, authority, mutation)
        writer = "-" if surface == "serialization" else "|".join(map(b64, original + [
            r.sha(r.profile_key(original)), r.REGISTRY, r.REGISTRY_DIGEST]))
        result.append(dict(zip(r.FIELDS, [str(i), surface, fixture, mutation, authority,
            str(surface != "serialization" and mutation != "publication").lower(), *fields[:2],
            *map(b64, fields[2:]), digest, b64(r.profile_key(fields)), b64(r.profile_key(fields)), writer, outcome, b64(detail)])))
    return result


class ProfileReplayTest(unittest.TestCase):
    def test_census(self):
        self.assertEqual(Counter(key[0] for key in r.census()),
                         {"serialization": 132, "boundary": 132, "clone": 8})
        self.assertEqual(len({tuple(row[0]) for row in r.census().values()}), 190)

    def test_encoding_is_exact_utf16(self):
        for value, size in [("[]{}:", 5), ("\U0001f600", 2), ("\u03b1\u4e2d", 2), ("e\u0301", 2), ("x\0y", 3)]:
            self.assertEqual(r.utf16_length(value), size)
            self.assertEqual(r.stable("t", [value]), f"1:t[1:{size}:{value}]{{0:}}")
            self.assertEqual(r.decoded(b64(value)), value)

    def test_delimiter_boundaries_differ(self):
        self.assertNotEqual(r.profile_key(["4", "FORBID", "a:1", "b", "c"]),
                            r.profile_key(["4", "FORBID", "a", "1:b", "c"]))

    def test_noncanonical_base64_and_unicode(self):
        for value in ("YQ", "YQ===", "YQ==\n", "YR==", "/w==", "7aCA", "###", "A" * 16385):
            with self.subTest(value=value[:20]), self.assertRaises(Blocked):
                r.decoded(value)

    def test_lean_control_text_is_not_json_escape(self):
        self.assertEqual("(ofCodepoints [120, 0, 121])", r.text("x\0y"))
        self.assertIn("10", r.text("line\nnext"))
        self.assertEqual("(ofCodepoints [128512])", r.text("\U0001f600"))
        self.assertNotIn("\\u", r.text("x\0y"))

    def test_all_generated_theorems_audited(self):
        code, count = r.program(observations(), sources())
        self.assertEqual(count, 272)
        self.assertEqual(re.findall(r"^theorem (\w+)", code, re.M),
                         re.findall(r"^#print axioms (\w+)", code, re.M))
        self.assertNotRegex(code, r"\b(sorry|axiom|unsafe|native_decide)\b")

    def test_general_theorems_audited(self):
        code = (Path(__file__).resolve().parents[1] /
                "docs/section3-repair-audit/formal/SemanticProfileWire.lean").read_text()
        names = re.findall(r"^theorem (\w+)", code, re.M)
        self.assertEqual(len(names), 17)
        self.assertEqual(names, re.findall(r"^#print axioms (\w+)", code, re.M))
        self.assertNotRegex(code, r"\b(sorry|axiom|unsafe|native_decide)\b")

    def test_missing_duplicate_reordered_observations(self):
        full = observations()
        for changed in ([], full[:-1], full + full[-1:], [full[1], full[0], *full[2:]],
                        [full[0], full[0], *full[2:]]):
            with self.assertRaises(Blocked):
                r.program(changed, sources())

    def test_complete_source_pin_census(self):
        full = sources()
        for changed in ([], full[:-1], full + full[-1:], list(reversed(full)), [full[0]] * 7):
            with self.assertRaises(Blocked):
                r.program(observations(), changed)
        for field in r.SOURCE_FIELDS:
            changed = sources()
            changed[0][field] = "wrong"
            with self.assertRaises(Blocked):
                r.program(observations(), changed)

    def test_every_input_field_is_frozen(self):
        for field in ("case", "surface", "fixture", "mutation", "authority", "testOnly", "bitwidth", "overflow",
                      "temporal", "rewrite", "signature"):
            changed = observations()
            changed[0][field] = b64("wrong") if field in ("temporal", "rewrite", "signature") else "wrong"
            with self.subTest(field=field), self.assertRaises(Blocked):
                r.program(changed, sources())

    def test_no_extra_or_missing_column(self):
        for field in r.FIELDS:
            changed = observations()
            del changed[0][field]
            with self.assertRaises(Blocked):
                r.program(changed, sources())
        changed = observations()
        changed[0]["unregistered"] = "x"
        with self.assertRaises(Blocked):
            r.program(changed, sources())

    def test_each_output_enters_a_false_proposition(self):
        for field in ("producerKey", "independentKey", "detail"):
            changed = observations()
            changed[0][field] = b64("wrong")
            self.assertIn(r.text("wrong"), r.program(changed, sources())[0])
        changed = observations()
        changed[0]["digest"] = "0" * 64
        self.assertIn(r.text("0" * 64) + " =", r.program(changed, sources())[0])

    def test_no_unknown_rejection_stage(self):
        changed = observations()
        changed[132]["outcome"] = "INTERNAL_ERROR"
        with self.assertRaises(Blocked):
            r.program(changed, sources())

    def test_writer_payload_is_separate_observation(self):
        changed = observations()
        changed[132]["writer"] = "|".join(map(b64, ["wrong"] * 8))
        self.assertIn(r.strings(["wrong"] * 8), r.program(changed, sources())[0])
        changed[132]["writer"] = "|".join(map(b64, ["wrong"] * 7))
        with self.assertRaises(Blocked):
            r.program(changed, sources())

    def test_custom_authority_not_inferred(self):
        expected = r.census()
        for mode in ("FORBID", "MODULAR"):
            self.assertEqual(expected["clone", f"fixed:{mode}", "same-spelling"][1], "custom")
            self.assertEqual(expected["boundary", f"fixed:{mode}", "base"][1], "compatibility")
        self.assertEqual(r.expected_outcome("clone", "custom", "same-spelling")[0], "AUTHORITY_REJECT")

    def test_source_mutations_are_unique_registered_sites(self):
        specs = r.source_mutations()
        self.assertEqual(len(specs), 15)
        self.assertEqual(len({s[0] for s in specs}), 15)
        root = Path(__file__).resolve().parents[1]
        for label, path, old, new, extractor in specs:
            self.assertEqual(extractor, "SemanticProfileWireExtractor")
            self.assertNotEqual(old, new)
            self.assertEqual((root / path).read_text().count(old), 1, label)


if __name__ == "__main__":
    unittest.main()
