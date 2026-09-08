"""Encoder adversaries. Synthetic rows here are tests, never Java observations."""

import copy
from pathlib import Path
import tempfile
import unittest

import fourth_chain_replays as r


THEORY_TEXT = "\n".join((
    "FAMILY:finite-union-of-correlated-ordered-products;normalized=subtype-antichain",
    "DAG:edges=specific-to-general;synthetic-union-and-common-ancestor-nodes-are-not-nominal-authority",
    "UNION:retain-correlation;deduplicate;absorb-only-authenticated-componentwise-subtypes",
    "INTERSECTION:pairwise-product-meet;omit-only-authenticated-disjoint-PrimSig-branches",
    "SET-DERIVATION:source UNION and INTERSECTION DAGs are recursively derived before parser-result equality",
    "JOIN:ordered;complete-alternative-pair-matrix;overlap=exact-or-one-endpoint-on-parser-derived-PrimSig-parent-path;result=init(left)++tail(right)",
    "ARROW:ordered;complete-cartesian-product;result=columns(left)++columns(right)",
    "SUBTYPE:path starts at exact AlloySig carrier, including parser-provided univ;edges are direct PrimSig parents;witness ends at opposite boundary",
    "SUBTYPE-HIERARCHY:single-parent;acyclic;univ-terminal;independent-verification-requires-external-source-hierarchy-authority",
    "DISJOINT:two distinct authenticated PrimSig branches with first common ancestor;univ-commonality-never-implies-overlap",
    "AUTHORITY:one-complete-nominal-path-per-top;one-live-parser-module-per-chain",
    "JOIN-FLAT-GUARD:every interior source operand has retained relation arity at least two, including typed-empty families",
    "LEAF:exact correlated relation family, Int/AlloyCarrier primitive singleton, or parser-authenticated same-arity subfamily;typed empty requires its live parser occurrence;no-name-based-parameter-authority",
    "UNIV:explicit parser-provided AlloySig:univ is an exact carrier;absent-or-unresolved-types-never-invent-univ",
    "EMPTY:positive-arity typed empty family has zero alternatives;all-disjoint JOIN retains complete evidence and ordered Seq",
    "CONTAINER:ordered-duplicate-preserving-Seq",
    "laws=guarded-associativity-only;no-commutativity;no-idempotency;no-unit"))


def sources():
    return [dict(zip(r.SOURCE_FIELDS, [name, ("org.acgn.cert." if name == "SemanticEvidenceVerifier" else "is.fivefivefive.CanDis.theory.") + name, *pin.split()]))
            for name, pin in r.PINS.items()]


def synthetic_rows():
    result = []
    for (surface, fixture, coordinate), model in r.expected_census().items():
        if surface == "leaf-grid":
            stored, view = model
            i, j = map(int, fixture.split(":"))
            p = "PRIMITIVE_SET_SINGLETON" if (i,j) in {(0,0),(1,1),(2,2),(11,1)} else "EXACT_RELATION" if (i,j) in {(3,1),(4,4),(5,5),(6,6)} else "REJECTED"
            w, v, status = r.stable(stored), r.stable(r.BOOL if view is None else r.relation(view)), "PRODUCER"
        elif surface == "control":
            p, w, v, status = "CHANGED", "ENCODED", "REJECTED", "THEORY_MISMATCH"
        elif surface == "leaf":
            proof = model["leaves"][int(coordinate)][2][1]
            p = w = r.stable(proof); v, status = proof[1][0], "VERIFIED"
        elif surface == "ledger":
            p, w = r.stable(model["required"]), r.stable(model["published"])
            v, status = "VERIFIED", "NONE"
        elif coordinate == "theory":
            p, w, v, status = THEORY_TEXT, r.VERSION, r.DIGEST, "SHA256"
        else:
            p = r.stable(model[coordinate])
            w = r.hashlib.sha256(p.encode()).hexdigest() if coordinate == "profile" else p
            v, status = "VERIFIED", "NONE"
        result.append(dict(zip(r.FIELDS, [surface, fixture, coordinate, r.b64(p), r.b64(w), r.b64(v), status])))
    return result


class ChainReplayTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.observed = synthetic_rows()
        cls.extracted = sources()

    def test_fixed_census_and_audits(self):
        source, count = r.program(self.observed, self.extracted)
        self.assertEqual(count, 8754)
        self.assertEqual(source.count("theorem "), count)
        self.assertEqual(source.count("#print axioms "), count)
        self.assertIn("reconstruct combine", source)
        self.assertNotIn("native_decide", source)
        self.assertNotIn("sorry", source)

    def test_key_roundtrip(self):
        for kind in ("JOIN", "ARROW"):
            for fixture in r.FIXTURES:
                model = r.fixture_keys(kind, fixture, 1, 1)
                for name in ("index", "source", "certificate"):
                    self.assertEqual(r.parse_key(r.stable(model[name])), model[name])

    def test_key_grammar_fail_closed(self):
        good = r.stable(r.key("x", ["y"], [r.key("z")]))
        for bad in ("", good + "!", "0:" + good, good.replace("1:x", "01:x"), good[:-1], good.replace("1:y", "2:y"), "1:x[99999999999:]{}", "1:x[0:]{0:}garbage"):
            with self.subTest(value=bad), self.assertRaises(r.Blocked): r.parse_key(bad)

    def test_base64_fail_closed(self):
        for value in ("?", "eA", "eA==\n", "eA===", "7aCA", "w6k="):
            with self.subTest(value=value), self.assertRaises(r.Blocked): r.decoded(value)

    def test_missing_duplicate_foreign_census(self):
        for replacement in (self.observed[:-1], self.observed + [self.observed[0]], [self.observed[0]] * len(self.observed)):
            with self.assertRaises(r.Blocked): r.program(replacement, self.extracted)
        changed = copy.deepcopy(self.observed); changed[0]["fixture"] = "absent"
        with self.assertRaises(r.Blocked): r.program(changed, self.extracted)

    def test_missing_source_and_foreign_owner(self):
        with self.assertRaises(r.Blocked): r.program(self.observed, self.extracted[:-1])
        changed = copy.deepcopy(self.extracted); changed[0]["owner"] += "Other"
        with self.assertRaises(r.Blocked): r.program(self.observed, changed)

    def test_wellformed_source_drift_reaches_false_proposition(self):
        changed = copy.deepcopy(self.extracted); changed[0]["shapeSha256"] = "0" * 64
        source, _ = r.program(self.observed, changed)
        self.assertIn('"' + "0" * 64 + '" = "' + r.PINS[changed[0]["object"]].split()[0] + '"', source)

    def test_observations_not_replaced_by_oracle(self):
        changed = copy.deepcopy(self.observed)
        control = next(row for row in changed if row["surface"] == "control")
        control["verifier"] = r.b64("VERIFIED")
        source, _ = r.program(changed, self.extracted)
        self.assertIn('"VERIFIED" = "REJECTED"', source)

    def test_unrelated_rejections_not_accepted(self):
        for failure in ("INTERNAL_ERROR", "RESOURCE_LIMIT", "NONE", "", "UNTRUSTED_THEORY"):
            changed = copy.deepcopy(self.observed)
            next(row for row in changed if row["surface"] == "control")["status"] = failure
            with self.assertRaises(r.Blocked): r.program(changed, self.extracted)

    def test_changed_stored_view_cannot_relabel_fixture(self):
        for field in ("writer", "verifier"):
            changed = copy.deepcopy(self.observed); changed[0][field] = r.b64(r.stable(r.BOOL))
            with self.assertRaises(r.Blocked): r.program(changed, self.extracted)

    def test_leaf_storage_is_checked_by_executable_contract(self):
        changed = copy.deepcopy(self.observed)
        leaf = next(row for row in changed if row["surface"] == "leaf")
        proof = r.parse_key(r.decoded(leaf["writer"]))
        leaf["writer"] = r.b64(r.stable(r.key(proof[0], proof[1], [r.BOOL, proof[2][1]])))
        source, count = r.program(changed, self.extracted)
        self.assertEqual(count, 8754)
        self.assertEqual(source.count(" /\\ checkLeaf "), 144)

    def test_profiles_associations_and_repeats_are_distinct(self):
        left = r.fixture_keys("JOIN", "exact", 0, 0)
        right = r.fixture_keys("JOIN", "exact", 0, 1)
        modular = r.fixture_keys("JOIN", "exact", 1, 0)
        self.assertEqual(left["index"], right["index"])
        self.assertNotEqual(left["source"], right["source"])
        self.assertNotEqual(left["certificate"], modular["certificate"])
        repeated = r.fixture_keys("JOIN", "repeat", 0, 0)
        self.assertEqual(repeated["leaves"][0], repeated["leaves"][2])
        self.assertEqual(len(repeated["index"][2][0][2]), 3)

    def test_registry_includes_intermediate_beyond_source_association(self):
        model = r.fixture_keys("JOIN", "primitive", 0, 1)
        intermediate = r.relation(r.family(1, [["B"]]))
        self.assertIn(intermediate, model["required"][2])
        self.assertIn(intermediate, model["published"][2])
        self.assertNotIn(intermediate, r.required_types(model["source"]))
        self.assertIn(("control", "JOIN:primitive:0:1", "ledger/intermediate"), r.expected_census())

    def test_case_product_registry_survives_normalization(self):
        product = r.product_key("dependent-type-case-result-v1", ["B", "C"])
        self.assertIn(r.relation(r.family(2, [["B", "C"]])), r.required_types(product))

    def test_missing_published_type_reaches_executable_contract(self):
        changed = copy.deepcopy(self.observed)
        ledger = next(row for row in changed if row["surface"] == "ledger" and row["fixture"] == "JOIN:primitive:0:1")
        published = r.parse_key(r.decoded(ledger["writer"]))
        intermediate = r.relation(r.family(1, [["B"]]))
        ledger["writer"] = r.b64(r.stable(r.key(published[0], children=[t for t in published[2] if t != intermediate])))
        source, count = r.program(changed, self.extracted)
        self.assertEqual(count, 8754)
        self.assertEqual(source.count(" /\\ publishes "), 48)

    def test_every_key_coordinate_is_enumerated(self):
        k = r.key("a", ["s"], [r.key("b"), r.key("c")])
        self.assertEqual(set(r.key_coordinates(k, "k")), {"k/tag", "k/s0", "k/drop0", "k/c0/tag", "k/drop1", "k/c1/tag", "k/swap0"})

    def test_source_mutations_have_unique_compiling_anchors(self):
        root = Path(__file__).resolve().parents[1]
        mutations = r.source_mutations()
        self.assertEqual(len(mutations), 20)
        self.assertEqual(len({m[0] for m in mutations}), 20)
        for label, path, old, new, extractor in mutations:
            self.assertEqual((root / path).read_text().count(old), 1, label)
            self.assertNotEqual(old, new)
            self.assertEqual(extractor, "DependentChainWitnessesExtractor")

    def test_tsv_schema(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "trace.tsv"
            for data in ("", "surface\tfixture\n", "\t".join(r.FIELDS) + "\nshort\n", "\t".join(r.FIELDS) + "\r\n"):
                path.write_text(data)
                with self.assertRaises(r.Blocked): r.rows(path, r.FIELDS)


if __name__ == "__main__":
    unittest.main()
