from dataclasses import replace
import unittest

from experiments.hybrid_edit.scope import (
    ASSIGNED, CONSTANT_TOKENS, Inventory, LIMITS, MAX_ACTIONS, PROFILE, Proposal,
    REFERENCE_BANKS, ScopeExclusion, TOKENS, decode_constant, decode_integer_literal,
    decode_reference, decode_uint, encode_constant, encode_integer_literal,
    encode_reference, encode_uint, scoped_menu, validate_inventory, validate_tokens,
)


def inventory():
    return Inventory(PROFILE, 1, ("BOOLEAN", "RELATIONAL", "ATOM_BINDER"),
                     ("AND", "IN", "VAR", "SIG", "FIELD", "JOIN"), (1, 2),
                     ("ALL",), ("ONE",), (True,), 10, 16, 80, 1, 3, 4, 2, 6, 10,
                     1, 2, (), 4)


class ScopeTests(unittest.TestCase):
    def test_all_numeric_payloads_roundtrip_without_collisions(self):
        encoded = {encode_uint(n) for n in range(65536)}
        self.assertEqual(len(encoded), 65536)
        self.assertEqual(len(ASSIGNED), 97)
        self.assertTrue(all(0 <= t < 128 for t in ASSIGNED))
        for n in range(65536):
            self.assertEqual(decode_uint(encode_uint(n)), n)
        for value in (-1, 65536, True, 1.0):
            with self.assertRaises(ScopeExclusion):
                encode_uint(value)
        for bad in ((64,), (64, 64, 64, 80), (True, 64, 64, 64)):
            with self.assertRaises(ScopeExclusion):
                decode_uint(bad)

    def test_no_unknown_tokens_or_truncation(self):
        packet = (TOKENS["BOS"], TOKENS["GRAPH"], *encode_uint(42), TOKENS["QUERY"])
        validate_tokens(packet)
        for bad in ((1, 127, 15), (1, True, 15), (1, 3, 2), (1, 15) * 1025):
            with self.assertRaises(ScopeExclusion):
                validate_tokens(bad)

    def test_compact_banks_roundtrip_and_never_alias(self):
        seen = set(CONSTANT_TOKENS.values()) | set(range(64, 80)) | set(range(52, 57))
        for kind, (base, size) in REFERENCE_BANKS.items():
            for i in range(size):
                encoded = encode_reference(kind, i)
                self.assertEqual(encoded, (base + i,))
                self.assertEqual(decode_reference(kind, encoded), i)
                self.assertNotIn(encoded[0], seen)
                seen.add(encoded[0])
                validate_tokens((TOKENS["BOS"], *encoded, TOKENS["QUERY"]))
            for bad in (-1, size, True, 1.0):
                with self.assertRaises(ScopeExclusion):
                    encode_reference(kind, bad)
        with self.assertRaises(ScopeExclusion):
            decode_reference("signature", encode_reference("relation", 0))
        with self.assertRaises(ScopeExclusion):
            decode_reference("slot", encode_uint(0))
        self.assertEqual(TOKENS["$sig0"], 80)
        self.assertEqual(TOKENS["$0"], 88)
        self.assertEqual(TOKENS["$rel0"], 96)

    def test_constants_reuse_existing_ids(self):
        expected = {"true": 27, "false": 28, "none": 43, "univ": 44, "iden": 51}
        self.assertEqual(CONSTANT_TOKENS, expected)
        for name, token in expected.items():
            self.assertEqual(encode_constant(name), (token,))
            self.assertEqual(decode_constant((token,)), name)
        with self.assertRaises(ScopeExclusion):
            encode_constant("new-uninterpreted-symbol")

    def test_integer_literals_distinct_and_bitwidth_checked(self):
        for value in range(5):
            encoded = encode_integer_literal(value, bitwidth=4)
            self.assertEqual(encoded, (52 + value,))
            self.assertEqual(decode_integer_literal(encoded, bitwidth=4), value)
            self.assertNotEqual(encoded, encode_uint(value))
            self.assertNotEqual(encoded, encode_reference("slot", value))
        for bad in (-1, 5, True):
            with self.assertRaises(ScopeExclusion):
                encode_integer_literal(bad, bitwidth=4)
        with self.assertRaises(ScopeExclusion):
            encode_integer_literal(4, bitwidth=3)
        with self.assertRaises(ScopeExclusion):
            decode_integer_literal((56,), bitwidth=3)
        self.assertEqual(encode_integer_literal(3, bitwidth=3), (55,))

    def test_v2_inventory_limits_banks_and_literals_not_arithmetic(self):
        valid = replace(inventory(), source_features=("BOOLEAN", "RELATIONAL", "INT_LITERAL"),
                        operators=("EQ", "IDEN", "INT_LITERAL"), integer_literals=(0, 4))
        validate_inventory(valid)
        for changes in ({"profile": "relational-pilot-v1"}, {"globals": 4},
                        {"signatures": 9, "globals": 11}, {"relations": 9, "globals": 10},
                        {"integer_bitwidth": 3}, {"integer_literals": (5,)},
                        {"integer_literals": ()}, {"source_features": ("BOOLEAN", "INT")},
                        {"operators": ("INT_PLUS",)}):
            with self.subTest(changes=changes), self.assertRaises(ScopeExclusion):
                validate_inventory(replace(valid, **changes))

    def test_inventory_excludes_unsupported_semantic_scope(self):
        validate_inventory(inventory())
        for changes in ({"phase_count": 2}, {"profile": "unknown"},
                        {"source_features": ("BOOLEAN", "CALL")},
                        {"source_features": ("BOOLEAN", "INT")},
                        {"operators": ("AND", "IFF")}, {"relation_arities": (3,)},
                        {"quantifiers": ("ONE",)}, {"binder_multiplicities": ("SET",)},
                        {"binder_primitive_domains": (False,)}, {"bindings": 2}):
            with self.subTest(changes=changes), self.assertRaises(ScopeExclusion):
                validate_inventory(replace(inventory(), **changes))

    def test_all_size_limits_are_exclusions_not_clamps(self):
        for field, cap in LIMITS.items():
            with self.subTest(field=field), self.assertRaises(ScopeExclusion):
                validate_inventory(replace(inventory(), **{field: cap + 1}))
        self.assertEqual(inventory().max_world_atoms, 6)

    def test_menu_has_four_templates_and_two_metric_families(self):
        proposals = [Proposal("BOOLEAN_REPLACE", "AND", "OR", 0, True),
                     Proposal("CARDINALITY_REPLACE", "SOME", "LONE", 1, True),
                     Proposal("SET_REPLACE", "UNION", "INTERSECT", 2, True),
                     Proposal("QUANTIFIER_REPLACE", "ALL", "SOME", 3, True),
                     Proposal("BOOLEAN_REPLACE", "AND", "IFF", 0, True),
                     Proposal("SET_REPLACE", "UNION", "DIFFERENCE", 4, False),
                     Proposal("BOOLEAN_REPLACE", "AND", "AND", 0, True),
                     Proposal("WRAP_NOT", "AND", "NOT", 0, True)]
        result = scoped_menu(inventory(), proposals, source_menu_truncated=False)
        self.assertEqual(len(result.actions), 4)
        self.assertEqual(len(result.excluded), 4)
        self.assertEqual({p.family for p in result.actions}, {"MATRIX_UPDATE", "BINDING_UPDATE"})
        self.assertEqual(tuple(proposals[:4]), result.actions)

    def test_menu_limits_empty_duplicate_and_pretruncated(self):
        proposal = Proposal("BOOLEAN_REPLACE", "AND", "OR", 0, True)
        menu = scoped_menu(inventory(), [proposal, proposal], source_menu_truncated=False)
        self.assertEqual(menu.excluded, ((1, "DUPLICATE_ACTION"),))
        many = [replace(proposal, source_occurrence=n) for n in range(MAX_ACTIONS + 1)]
        for entries, truncated in (([], False), ([proposal], True), (many, False)):
            with self.assertRaises(ScopeExclusion):
                scoped_menu(inventory(), entries, source_menu_truncated=truncated)
        self.assertEqual(len(many), MAX_ACTIONS + 1)


if __name__ == "__main__":
    unittest.main()
