"""Fault injections for pair retention that per-release counts alone cannot detect."""
import unittest
from collections import defaultdict

from verify_historical_pair_coverage import audit, check_rankings, context, pair, read_decisions


def edge(a, b):
    return ("q", "inv", f"{a}.als", a, f"{b}.als", b)


def history(structural=(), scoped=(), negatives=()):
    return defaultdict(set, poolStructural=set(structural), poolFixedCommand=set(scoped),
                       satControls=set(negatives))


class HistoricalPairTests(unittest.TestCase):
    def test_direct_loss_cannot_be_offset_by_a_gain_or_a_scoped_path(self):
        ab, ac, bc = edge("a", "b"), edge("a", "c"), edge("b", "c")
        earlier = history([ab, ac])
        candidate = history([ab, bc], [ac])
        report = audit(candidate, [("release", earlier)])
        self.assertEqual(report["status"], "FAIL")
        self.assertEqual(report["metrics"]["poolStructural"]["lost"], [ac])
        self.assertEqual(report["metrics"]["poolFixedComponents"]["lost"], [])

    def test_non_nearest_score_is_checked_by_reference_identity(self):
        a = dict(referenceSource="a.als", referenceName="a", distance=1)
        b = dict(referenceSource="b.als", referenceName="b", distance=85)
        row = dict(relativePath="query.als", legacyCanonicalRanking=[a, b], canonicalRanking=[b, a])
        self.assertEqual(check_rankings([row], {"query.als"}), 2)
        row["canonicalRanking"] = [a, dict(b, distance=87)]
        with self.assertRaisesRegex(ValueError, "query.als.*b.als.*Fast 85.*87"):
            check_rankings([row], {"query.als"})

    def test_reordering_references_preserves_source_identity(self):
        group = ("q", "inv1")
        before = pair(group, ("a.als", "inv1_correct_5"), ("b.als", "inv1_oracle"))
        after = pair(group, ("b.als", "inv1_oracle"), ("a.als", "inv1_correct_19"))
        self.assertEqual(before, after)
        self.assertNotEqual(after, pair(group, ("b.als", "inv1_correct_0"), ("a.als", "inv1_correct_19")))

    def test_transitive_sat_conflict(self):
        ab, ac, bc = edge("a", "b"), edge("a", "c"), edge("b", "c")
        candidate = history([ab], [bc])
        report = audit(candidate, [("release", history([ab], negatives=[ac]))])
        self.assertEqual(report["connectedSatControls"], [ac])
        self.assertEqual(report["status"], "FAIL")

    def test_gains_in_a_later_release_become_obligations(self):
        ab, ac = edge("a", "b"), edge("a", "c")
        first, second = history([ab]), history([ab, ac])
        self.assertEqual(audit(second, [("first", first)])["status"], "PASS")
        report = audit(first, [("first", first), ("second", second)])
        self.assertEqual(report["metrics"]["poolStructural"]["lost"], [ac])

    def test_scoped_coverage_requires_the_same_command_and_effective_bounds(self):
        decision = dict(basis="FIXED_COMMAND_RULE", native="UNSAT", rules=["fiber"], check="correct",
                        ordinal=0, comparisonDistance=0, equivalent=True, carrierBounds={"A": 3},
                        bitwidth=4, traceMin=-1, traceMax=-1)
        row = dict(path="one.als", left="p", right="q", distance=2, status="CORRECT", decisions=[decision])
        original = read_decisions([row], True)
        decision["carrierBounds"]["A"] = 2
        candidate = read_decisions([row], True)
        report = audit(candidate, [("original", original)])
        self.assertEqual(len(report["metrics"]["pairedFixedCommand"]["lost"]), 1)
        self.assertNotIn(context(decision), report["metrics"]["pairedFixedCommand"]["lost"][0])
        decision["native"] = "SAT"
        with self.assertRaises(ValueError):
            read_decisions([row], True)


if __name__ == "__main__":
    unittest.main()
