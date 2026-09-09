#!/usr/bin/env python3
"""Synthetic encoder tests, never substituted for Java execution evidence."""

from collections import Counter
from functools import lru_cache
from pathlib import Path
import re
import unittest

import fifth_law_record_replays as r
from run_submission_container_closure import Blocked


def sources():
    return [dict(zip(r.SOURCE_FIELDS, [name, *r.SOURCES[name]])) for name in sorted(r.SOURCES)]


def vocabulary(spec):
    p, op, t, mutation = spec
    c = r.coordinates(p, op, t)
    types = {}
    def collect(typ):
        n = r.exact_type(typ); types[n[1][0]] = n
        for child in typ[2]: collect(child)
    collect(c["resultType"]); collect(c["elementType"])
    one_key = r.stable("schema/one", [], [c["element"]]); one_id = r.schema_id(one_key)
    sk = r.schema_key(c["carrier"], c["arity"], c["element"]); sid = r.schema_id(sk)
    one = r.node("schema", [one_id, "ONE", r.runtime_type(c["elementType"]), "FINITE:1", "RIGID"])
    container = r.node("schema", [sid, c["carrier"], "", c["arity"],
                       "COMMUTATIVE_IDEMPOTENT_SET" if c["carrier"] == "SET" else "COMMUTATIVE_BAG"], [r.node("schema-ref", [one_id])])
    schemas = {one_id: one, sid: container}
    operators = [r.node("operator", ["operator/" + r.sha("test-" + op), c["runtime"], "ALLOY/" + op, c["flat"]],
                        [r.node("schema-ref", [sid])])]
    for name in ("law-wire-a", "law-wire-b"):
        operators.append(r.node("operator", ["operator/" + r.sha(name), r.runtime_type(c["elementType"]), name, "none"]))
    if mutation.startswith("registry-"):
        a = mutation[9:]; new_sid = r.candidate(spec)[0][1][8]
        fields, children = list(container[1]), container[2]; fields[0] = new_sid
        if a == "carrier": fields[1], fields[4] = "BAG", "COMMUTATIVE_BAG"
        if a == "policy": fields[3] = "AT_LEAST:0"
        if a == "element":
            child = r.schema_id(r.stable("schema/one", [], [r.type_key(r.graph_type("int"))]))
            schemas[child] = r.node("schema", [child, "ONE", "Int", "FINITE:1", "RIGID"])
            children = [r.node("schema-ref", [child])]
        if a in ("element", "result"): collect(r.graph_type("int"))
        schemas[new_sid] = r.node("schema", fields, children)
        extra_id = "operator/" + r.content_id(r.node("operator-id", ["law-counterfeit/" + a]))
        operators.append(r.node("operator", [extra_id, "Int" if a == "result" else "Bool",
                                 "ALLOY/IFF" if a == "operator" else "ALLOY/AND", "0/0"], [r.node("schema-ref", [new_sid])]))
    sections = [r.node("schemas", [], sorted(schemas.values(), key=lambda n: n[1][0])),
                r.node("operators", [], sorted(operators, key=lambda n: n[1][0])),
                r.node("exact-types", [], sorted(types.values(), key=lambda n: n[1][0]))]
    return r.b64(r.tree_key(r.node("law-vocabulary", [], sections)))


@lru_cache(maxsize=1)
def fixture_rows():
    result = []
    for i, spec in enumerate(r.census()):
        p, op, t, mutation = spec; c = r.coordinates(p, op, t)
        original = r.pack_table([("law-certificate", fields, 0) for fields in r.expected_records(p, op, t)])
        outcome, detail = r.expected_outcome(spec)
        result.append(dict(zip(r.FIELDS, [str(i), f"{p}:{op}:{t}", str(p), op, t, mutation,
            *map(r.b64, [c["profile"], c["result"], c["element"], r.schema_key(c["carrier"], c["arity"], c["element"])]),
            original, original, r.pack_table(r.candidate(spec)), vocabulary(spec), "true", outcome, r.b64(detail)])))
    return result


def observations():
    return [dict(row) for row in fixture_rows()]


class LawRecordReplayTest(unittest.TestCase):
    def test_census(self):
        specs = r.census()
        self.assertEqual(len(specs), 152)
        self.assertEqual(len(set(specs)), 152)
        base = [s for s in specs if s[-1] == "base"]
        self.assertEqual(len(base), 48)
        self.assertEqual(set(s[1] for s in base), set(r.OPS))
        self.assertEqual(sum(len(r.laws(p, op)) for p, op, t, m in base), 94)
        self.assertEqual(Counter(s[-1].split("-")[0] for s in specs),
                         dict(base=48, field=51, omit=20, duplicate=6, order=5, tag=3, child=3, recompute=11, registry=5))

    def test_every_field_and_shape(self):
        original = r.candidate((0, "AND", "bool", "base"))
        for i in range(17):
            changed = r.candidate((0, "AND", "bool", f"field-{i}"))
            self.assertNotEqual(original, changed)
            row = next(row for row in changed if row not in original)
            original_row = next(row for row in original if row not in changed)
            self.assertEqual([j for j in range(17) if row[1][j] != original_row[1][j]], [i])
            self.assertEqual(len(r.candidate((0, "AND", "bool", f"omit-field-{i}"))[0][1]), 16)

    def test_recomputed_is_structurally_valid_and_unregistered(self):
        original = r.expected_records(0, "AND", "bool")
        for attack in r.RECOMPUTED:
            changed = next(n[1] for n in r.candidate((0, "AND", "bool", "recompute-" + attack)) if n[1] not in original)
            for i in (0, 9, 10, 11, 12): r.parse_key(changed[i])
            self.assertEqual(changed[15].split(":")[-1], r.sha(changed[10]))
            if attack != "endpoints": self.assertNotIn(changed[0], [v[0] for v in original])

    def test_registry_checks_are_matrix_failures(self):
        for attack in r.REGISTRY_ATTACKS:
            spec = (0, "AND", "bool", "registry-" + attack)
            r.vocabulary_checks(spec, vocabulary(spec))
            outcome, detail = r.expected_outcome(spec)
            self.assertEqual(outcome, "REJECTED:THEORY_MISMATCH")
            self.assertTrue("fixed Alloy law matrix" in detail or "wrong exact result/element types" in detail)

    def test_wire_hash_preimage(self):
        self.assertEqual(r.wire_bytes(r.node("x", ["a"])).hex(), "000000017800000001000000016100000000")
        self.assertNotEqual(r.content_id(r.node("x", ["a", "bc"])), r.content_id(r.node("x", ["ab", "c"])))
        self.assertNotEqual(r.schema_id(r.schema_key("SET", "AT_LEAST:1", "Bool")),
                            r.schema_id(r.schema_key("BAG", "AT_LEAST:1", "Bool")))

    def test_utf16_order_not_scalar_order(self):
        self.assertLess(r.java_order("\U00010000"), r.java_order("\ue000"))
        self.assertGreater("\U00010000", "\ue000")
        self.assertLess(r.java_order("prefix"), r.java_order("prefix-more"))

    def test_noncanonical_encoding(self):
        for bad in ("YR==", "YQ", "YQ===", "/w==", "7aCA", "A" * 131073):
            with self.subTest(value=bad[:10]), self.assertRaises(Blocked): r.decoded(bad)
        for bad in ("a", "YQ==:2:YQ==", "YQ==:01:YQ==", "YQ==:0:YQ==:"):
            with self.assertRaises(Blocked): r.unpack_table(bad)

    def test_roundtrip_observation_framing(self):
        for spec in r.census(): self.assertEqual(r.unpack_table(r.pack_table(r.candidate(spec))), r.candidate(spec))

    def test_program_inventory_and_dictionary(self):
        code, count = r.program(observations(), sources())
        names = re.findall(r"^theorem (\w+)", code, re.M)
        self.assertEqual(count, 246)
        self.assertEqual(len(names), count)
        self.assertEqual(names, re.findall(r"^#print axioms (\w+)", code, re.M))
        self.assertNotRegex(code, r"\b(sorry|axiom|unsafe|native_decide)\b")
        self.assertIn("matrixAllowed", code)
        self.assertIn("expectedRecord", code)
        self.assertLess(len(code), 3_000_000)

    def test_general_inventory(self):
        path = Path(__file__).resolve().parents[1] / "docs/section3-repair-audit/formal/LawRecordWire.lean"
        code = path.read_text()
        names = re.findall(r"^theorem (\w+)", code, re.M)
        self.assertGreaterEqual(len(names), 25)
        self.assertEqual(names, re.findall(r"^#print axioms (\w+)", code, re.M))
        self.assertNotRegex(code, r"\b(sorry|axiom|unsafe|native_decide)\b")
        self.assertIn("javaLess a.index b.index", code)

    def test_missing_duplicate_reordered_cases(self):
        full = observations()
        for changed in ([], full[:-1], full + full[-1:], [full[1], full[0], *full[2:]], [full[0], full[0], *full[2:]]):
            with self.assertRaises(Blocked): r.program(changed, sources())

    def test_strict_sources(self):
        full = sources()
        for changed in ([], full[:-1], full + full[-1:], list(reversed(full))):
            with self.assertRaises(Blocked): r.program(observations(), changed)
        for field in r.SOURCE_FIELDS:
            changed = sources(); changed[0][field] = "wrong"
            with self.assertRaises(Blocked): r.program(observations(), changed)

    def test_all_columns_registered(self):
        for field in r.FIELDS:
            changed = observations(); del changed[0][field]
            with self.assertRaises(Blocked): r.program(changed, sources())
        changed = observations(); changed[0]["extra"] = "x"
        with self.assertRaises(Blocked): r.program(changed, sources())

    def test_frozen_case_and_coordinate_fields(self):
        for field in r.FIELDS[:10] + ["candidate"]:
            changed = observations(); changed[0][field] = "wrong"
            with self.subTest(field=field), self.assertRaises(Blocked): r.program(changed, sources())

    def test_output_values_enter_proofs(self):
        for field in ("producer", "writer"):
            changed = observations(); t = r.unpack_table(changed[0][field]); tag, f, n = t[0]; f = list(f); f[16] = "99"
            t[0] = tag, tuple(f), n; changed[0][field] = r.pack_table(t)
            code, _ = r.program(changed, sources(), only=0)
            self.assertIn("ofCodepoints [57, 57]", code)
        changed = observations(); changed[0]["outerFresh"] = "false"
        self.assertIn("false = true", r.program(changed, sources(), only=0)[0])
        changed = observations(); changed[0]["detail"] = r.b64("wrong")
        self.assertIn("ofCodepoints [119, 114, 111, 110, 103]", r.program(changed, sources(), only=0)[0])

    def test_vocabulary_is_independently_checked(self):
        for index in range(3):
            spec = r.census()[0]
            tree = r.parse_key(r.decoded(vocabulary(spec)))
            sections = list(tree[2]); section = sections[index]; nodes = list(section[2]); n = nodes[0]
            fields = list(n[1]); fields[-1] = "wrong"
            nodes[0] = r.node(n[0], fields, n[2]); sections[index] = r.node(section[0], [], nodes)
            with self.assertRaises(Blocked):
                r.vocabulary_checks(spec, r.b64(r.tree_key(r.node(tree[0], [], sections))))

    def test_no_unknown_verifier_stage(self):
        changed = observations(); changed[0]["outcome"] = "REJECTED:INTERNAL_ERROR"
        with self.assertRaises(Blocked): r.program(changed, sources())

    def test_source_mutations_exact_unique(self):
        controls = r.source_mutations(); root = Path(__file__).resolve().parents[1]
        self.assertEqual(len(controls), 18)
        self.assertEqual(len({c[0] for c in controls}), 18)
        for label, path, old, new, extractor in controls:
            self.assertEqual(extractor, "LawRecordWireExtractor")
            self.assertNotEqual(old, new)
            self.assertEqual((root / path).read_text().count(old), 1, label)


if __name__ == "__main__":
    unittest.main()
