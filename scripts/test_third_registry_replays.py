#!/usr/bin/env python3
"""Encoder contract tests; synthetic rows here are never certificate evidence."""
import base64
import unittest

import third_registry_replays as r
from run_submission_container_closure import Blocked


class RegistryReplayEncodingTest(unittest.TestCase):
    def test_census_is_explicit(self):
        self.assertEqual(len(r.expected_keys()), 9516)

    def test_canonical_naturals_only(self):
        for text in ("00", "-1", "+1", " 1", "1.0", "9"):
            with self.assertRaises(Blocked):
                r.integer(text, 8)
        self.assertEqual(r.integer("8", 8), 8)

    def test_exact_booleans(self):
        for text in ("TRUE", "1", "", "false "):
            with self.assertRaises(Blocked):
                r.boolean(text)

    def test_profile_strings_are_lossless(self):
        import json
        for value in ("same-profile", "quote\"slash\\", "line\nnext\tcell", "\u03b1"):
            encoded = base64.b64encode(value.encode()).decode()
            self.assertEqual(json.loads(r.decoded(encoded)), value)

    def test_noncanonical_base64_rejected(self):
        for value in ("###", "YQ", "YQ===", "YQ==\n", "/w=="):
            with self.assertRaises(Blocked):
                r.decoded(value)

    def test_full_request_not_profile_name_inference(self):
        b64 = lambda x: base64.b64encode(x.encode()).decode()
        row = dict(op="0", pair="0", carrier="2", arity="0", law="0", profile="custom",
                   identity="true", bitwidth="4", modular="false", temporal=b64("alloy-temporal"),
                   rewrite=b64("repaired-normal-form-v2"), signature=b64("alloy-signature-v2"), path="0")
        request = r.request(row)
        self.assertIn('.custom', request)
        self.assertIn('"ALLOY/AND"', request)
        self.assertIn('"repaired-normal-form-v2"', request)
        row["profile"] = "compatibility"
        self.assertNotEqual(request, r.request(row))

    def test_nested_schema_is_not_one(self):
        row = dict(op="0", pair="7", carrier="2", arity="0", law="0", profile="custom",
                   identity="true", bitwidth="4", modular="false", temporal="", rewrite="", signature="", path="0")
        self.assertIn("Schema.mk .set none", r.request(row))

    def test_incomplete_source_and_request_census_rejected(self):
        with self.assertRaises(Blocked):
            r.program([], [])
        fake = [dict(object=name, owner="is.fivefivefive.CanDis.theory." + name,
                     shapeSha256="0" * 64, bindingsSha256="0" * 64) for name in r.OBJECTS]
        with self.assertRaises(Blocked):
            r.program([], fake)

    def test_each_source_mutation_is_unique(self):
        mutations = r.source_mutations()
        self.assertEqual(len(mutations), 4)
        self.assertEqual(len({m[0] for m in mutations}), len(mutations))
        self.assertTrue(all(m[-1] == "RegistryAdmissionExtractor" and m[2] != m[3] for m in mutations))


if __name__ == "__main__":
    unittest.main()
