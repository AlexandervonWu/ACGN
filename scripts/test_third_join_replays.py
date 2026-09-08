"""Fail-closed encoder checks; synthetic rows here are not execution evidence."""

import copy
import json
from pathlib import Path
import tempfile
import unittest

import third_join_replays as replay
from run_submission_container_closure import Blocked


def sample_tables():
    observed = []
    for (surface, fixture, tree), (arities, relations) in replay.census().items():
        accepted = len(arities) >= 2 and all(a >= 2 for a in arities[1:-1])
        observed.append(dict(zip(replay.FIELDS, [surface, fixture, ",".join(map(str, arities)), tree,
            "-" if relations is None else json.dumps(relations, separators=(",", ":")),
            "[]" if relations is not None else "-", "-" if surface == "parser" else str(accepted).lower(),
            "-" if surface == "parser" else str(accepted).lower(),
            "-" if surface == "guard" else "false" if surface == "counter" else "true"])))
    extracted = [dict(zip(replay.SOURCE_FIELDS, [name, *values, "2", "1", "1", "last", "first"]))
                 for name, values in replay.SOURCES.items()]
    return observed, extracted


class JoinReplaysTest(unittest.TestCase):
    def setUp(self):
        self.observed, self.extracted = sample_tables()

    def test_census_and_namespace(self):
        source, count = replay.program(self.observed, self.extracted)
        self.assertEqual(count, 1025)
        self.assertEqual(source.count("theorem "), count)
        self.assertEqual(source.count("#print axioms "), count)
        self.assertTrue(source.endswith("end ACGN.ThirdFive.JoinReplay\n"))
        self.assertIn("sameRelation (finiteEval", source)
        counts = {s: sum(r["surface"] == s for r in self.observed) for s in ("guard", "finite", "counter", "parser")}
        self.assertEqual(counts, dict(guard=469, finite=458, counter=2, parser=92))

    def test_missing_duplicate_unknown(self):
        for change in (self.observed[:-1], [self.observed[0]] + self.observed[:-1],
                       [dict(self.observed[0], fixture="foreign")] + self.observed[1:]):
            with self.assertRaises(Blocked):
                replay.program(change, self.extracted)

    def test_source_census_binding_and_modifiers(self):
        for field in ("owner", "method", "modifiers", "shapeSha256", "bindingsSha256"):
            changed = copy.deepcopy(self.extracted)
            changed[0][field] = "foreign"
            with self.assertRaises(Blocked):
                replay.program(self.observed, changed)
        with self.assertRaises(Blocked):
            replay.program(self.observed, self.extracted[:-1])

    def test_fixture_inputs_are_frozen(self):
        i = next(i for i, row in enumerate(self.observed) if row["surface"] == "finite")
        for field, value in (("arities", "1,2"), ("relations", "[]"), ("tree", "(1,0)"),
                             ("producer", "True"), ("output", "[[true]]"), ("output", "[[0], [1]]"),
                             ("output", "[[1],[0]]"), ("output", "[[0],[0]]")):
            changed = copy.deepcopy(self.observed)
            changed[i][field] = value
            with self.assertRaises(Blocked, msg=field + value):
                replay.program(changed, self.extracted)

    def test_output_is_observed_not_replaced_by_oracle(self):
        i = next(i for i, row in enumerate(self.observed) if row["surface"] == "finite")
        changed = copy.deepcopy(self.observed)
        changed[i]["output"] = "[[1,1]]"
        changed[i]["verifier"] = "false"
        source, _ = replay.program(changed, self.extracted)
        self.assertIn(f"sameRelation (finiteEval relations{i} tree{i}) [[1, 1]] = true", source)
        self.assertIn("guard .JOIN [2, 2] = false", source)

    def test_tree_parser_is_total_on_frozen_shapes(self):
        for n in range(2, 6):
            for tree in replay.associations(list(range(n))):
                self.assertIn(".app .join", replay.tree_term(tree))
        for bad in ("", "5", "(0)", "(0,)", "(0,1", "(0,1))", "(0,1);", "(0 1)"):
            with self.assertRaises(Blocked):
                replay.tree_term(bad)

    def test_negatives_are_closed_modules(self):
        i = next(i for i, row in enumerate(self.observed) if row["surface"] == "finite")
        self.observed[i]["output"] = "[[0,0]]"
        with tempfile.TemporaryDirectory() as tmp:
            build = Path(tmp)
            for name, fields, table in (("guarded-join-chains.tsv", replay.FIELDS, self.observed),
                                        ("guarded-join-source.tsv", replay.SOURCE_FIELDS, self.extracted)):
                (build / name).write_text("\t".join(fields) + "\n" + "\n".join(
                    "\t".join(row[f] for f in fields) for row in table) + "\n", encoding="utf-8")
            negatives = replay.negatives(build, build)
            self.assertEqual(len(negatives), 12)
            self.assertEqual(len({label for label, _, _ in negatives}), 12)
            for _, _, source in negatives:
                self.assertEqual(source.count("namespace ACGN.ThirdFive.JoinReplay"), 1)
                self.assertTrue(source.endswith("end ACGN.ThirdFive.JoinReplay\n"))
                self.assertIn(" := by decide", source)

    def test_source_mutations_have_unique_real_anchors(self):
        root = Path(__file__).resolve().parents[1]
        mutations = replay.source_mutations()
        self.assertEqual(len(mutations), 12)
        for _, path, old, new, extractor in mutations:
            self.assertEqual((root / path).read_text(encoding="utf-8").count(old), 1, path + ":" + old)
            self.assertNotEqual(old, new)
            self.assertEqual(extractor, "GuardedJoinChainExtractor")


if __name__ == "__main__":
    unittest.main()
