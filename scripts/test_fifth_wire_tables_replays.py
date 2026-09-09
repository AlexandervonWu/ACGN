#!/usr/bin/env python3
"""Encoder unit tests. Synthetic rows are never Java correspondence evidence."""

import base64
from collections import Counter
from pathlib import Path
import re
import unittest

import fifth_wire_tables_replays as r
from run_submission_container_closure import Blocked


def b64(raw):
    return base64.b64encode(raw).decode("ascii")


def sources():
    return [dict(zip(r.SOURCE_FIELDS, (name, *r.SOURCES[name]))) for name in sorted(r.SOURCES)]


def observations():
    result = []
    for i, ((surface, fixture, mutation), (n, outcome, exact, order)) in enumerate(r.census().items()):
        raw = n if isinstance(n, bytes) else r.encode(n)
        preimage = b64(r.encode(r.content(n))) if surface in ("writer", "content") else "-"
        ident = n.scalars[0] if surface in ("writer", "content") else "-"
        result.append(dict(zip(r.FIELDS, (str(i), surface, fixture, mutation, b64(raw),
            b64(raw) if outcome == "ACCEPT" else "-", preimage, ident, outcome,
            "-" if exact is None else str(exact).lower(), b64(order.encode())))))
    return result


class WireTablesReplayTest(unittest.TestCase):
    def test_census(self):
        self.assertEqual(Counter(k[0] for k in r.census()), {"writer": 2, "table": 44, "content": 7, "grammar": 13})
        self.assertEqual(len(r.census()), 66)
        self.assertEqual(len(r.TABLES), 8)

    def test_byte_grammar(self):
        for value in r.TEXTS:
            node = r.Node("tag", (value,), (r.Node("nested", (value,)),))
            self.assertEqual(r.parse_node(r.encode(node)), node)
        self.assertEqual(r.frame("\U0001f600")[:4], b"\0\0\0\4")
        self.assertNotEqual(r.encode(r.Node("t", ("a", "bc"))), r.encode(r.Node("t", ("ab", "c"))))

    def test_malformed_grammar(self):
        for label, raw, outcome in r.grammar_cases():
            with self.subTest(label=label):
                if outcome == "ACCEPT":
                    self.assertEqual(r.encode(r.parse_node(raw)), raw)
                else:
                    with self.assertRaises((ValueError, UnicodeError)):
                        r.parse_node(raw)

    def test_preimage_excludes_only_id_and_envelope(self):
        a = r.record("term", "alpha")
        b = a._replace(scalars=("changed-id", *a.scalars[1:]))
        self.assertEqual(r.encode(r.content(a)), r.encode(r.content(b)))
        self.assertEqual(r.content(a).tag, "term/content")
        self.assertNotEqual(r.encode(a), r.encode(r.content(a)))
        self.assertNotEqual(r.content(a), r.content(a._replace(children=tuple(reversed(a.children)))))

    def test_recomputed_is_accepted_but_claim_differs(self):
        for label in ("rehashed-scalar", "rehashed-child", "rehashed-child-order"):
            n, outcome, exact = r.table_case("terms", "term", label)
            self.assertEqual(outcome, "ACCEPT")
            self.assertFalse(exact)
            self.assertEqual(n.children[0].scalars[0], r.hashlib.sha256(r.encode(r.content(n.children[0]))).hexdigest())
        self.assertEqual(r.table_case("terms", "term", "rehashed-tag")[1], "UNKNOWN_VARIANT")
        self.assertEqual(r.table_case("witnesses", "witness", "stale-scalar")[1], "ACCEPT")

    def test_named_ids_use_utf16_not_utf8_order(self):
        good, outcome, _ = r.table_case("witnesses", "witness", "named-order")
        ids = [n.scalars[0] for n in good.children]
        self.assertEqual(outcome, "ACCEPT")
        self.assertEqual(ids, sorted(ids, key=lambda s: s.encode("utf-16-be")))
        self.assertNotEqual(ids, sorted(ids, key=lambda s: s.encode("utf-8")))
        self.assertEqual(r.table_case("witnesses", "witness", "named-reverse")[1], "NONCANONICAL_ENCODING")

    def test_strict_base64(self):
        for value in ("YQ", "YQ===", "YQ==\n", "YR==", "###", "A" * 32769):
            with self.subTest(value=value[:20]), self.assertRaises(Blocked): r.decoded(value)

    def test_observation_census_fail_closed(self):
        full = observations()
        for changed in ([], full[:-1], full + full[-1:], list(reversed(full)), [full[0]] * 66):
            with self.assertRaises(Blocked): r.program(changed, sources())

    def test_source_census_fail_closed(self):
        full = sources()
        for changed in ([], full[:-1], full + full[-1:], list(reversed(full)), [full[0]] * 4):
            with self.assertRaises(Blocked): r.program(observations(), changed)
        for field in r.SOURCE_FIELDS:
            changed = sources(); changed[0][field] = "wrong"
            with self.assertRaises(Blocked): r.program(observations(), changed)

    def test_inputs_and_columns_frozen(self):
        for field in ("case", "surface", "fixture", "mutation", "input"):
            changed = observations(); changed[0][field] = "wrong"
            with self.subTest(field=field), self.assertRaises(Blocked): r.program(changed, sources())
        for field in r.FIELDS:
            changed = observations(); del changed[0][field]
            with self.assertRaises(Blocked): r.program(changed, sources())
        changed = observations(); changed[0]["extra"] = "x"
        with self.assertRaises(Blocked): r.program(changed, sources())

    def test_outputs_enter_propositions(self):
        for field in ("output", "preimage", "order"):
            changed = observations(); changed[0][field] = b64(b"wrong")
            code, count = r.program(changed, sources())
            self.assertIn("[119, 114, 111, 110, 103]", code)
            self.assertEqual(count, 66)
        for field, value in (("outcome", "DUPLICATE_ID"), ("exact", "false"), ("id", "0" * 64)):
            changed = observations(); changed[0][field] = value
            self.assertNotEqual(r.program(changed, sources()), r.program(observations(), sources()))

    def test_missing_outputs_cannot_silently_pass(self):
        changed = observations(); changed[0]["output"] = "-"
        self.assertIn("false = true", r.program(changed, sources())[0])
        changed = observations(); changed[0]["outcome"] = "INTERNAL_ERROR"
        with self.assertRaises(Blocked): r.program(changed, sources())

    def test_theorems_are_audited(self):
        code, count = r.program(observations(), sources())
        for source in (code, (Path(__file__).resolve().parents[1] /
                             "docs/section3-repair-audit/formal/CanonicalWireTables.lean").read_text()):
            names = re.findall(r"^theorem (\w+)", source, re.M)
            self.assertEqual(names, re.findall(r"^#print axioms (\w+)", source, re.M))
            self.assertNotRegex(source, r"\b(sorry|axiom|unsafe|native_decide)\b")
        self.assertEqual(len(re.findall(r"^theorem ", code, re.M)), count)
        self.assertLess(len(code), 300000)

    def test_source_controls_are_unique_and_frozen(self):
        root = Path(__file__).resolve().parents[1]
        controls = r.source_mutations()
        self.assertEqual(len(controls), 12)
        self.assertEqual(len({x[0] for x in controls}), 12)
        for label, source, old, new, extractor in controls:
            self.assertEqual((root / source).read_text().count(old), 1, label)
            self.assertNotEqual(old, new)
            self.assertEqual(extractor, "CanonicalWireTablesExtractor")


if __name__ == "__main__":
    unittest.main()
