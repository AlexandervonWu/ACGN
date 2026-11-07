import copy
import unittest
from verify_v3_release_gates import near_fourteen, pair_keys, synthetic_checks


class ReleaseGatesTest(unittest.TestCase):
    def test_mean_boundaries(self):
        for n in (13, 14, 15):
            self.assertTrue(near_fourteen(n))
        for n in (12.99, 15.01, float("nan"), float("inf")):
            self.assertFalse(near_fourteen(n))

    def pair(self, name):
        return dict(rawAstDistance=1, canonicalDistance=0, questionSet="q", invariantId="p",
                    left=dict(kind="oracle", source="a.als", name="a"),
                    right=dict(kind="correct-student", source=name + ".als", name=name))

    def test_same_count_is_not_same_subset(self):
        a = pair_keys(dict(pairCount=1, pairs=[self.pair("b")]), "canonicalDistance")
        b = pair_keys(dict(pairCount=1, pairs=[self.pair("c")]), "canonicalDistance")
        self.assertEqual(len(a), len(b))
        self.assertNotEqual(a, b)

    def test_pair_direction_is_irrelevant(self):
        row = self.pair("b")
        a = pair_keys(dict(pairCount=1, pairs=[row]), "canonicalDistance")
        row["left"], row["right"] = row["right"], row["left"]
        self.assertEqual(a, pair_keys(dict(pairCount=1, pairs=[row]), "canonicalDistance"))

    def test_invalid_zero_records_fail(self):
        row = self.pair("b")
        for data in (dict(pairCount=2, pairs=[row]), dict(pairCount=2, pairs=[row, row])):
            with self.assertRaises(ValueError):
                pair_keys(data, "canonicalDistance")
        row["rawAstDistance"] = 0
        with self.assertRaises(ValueError):
            pair_keys(dict(pairCount=1, pairs=[row]), "canonicalDistance")

    def grid(self):
        rows = [dict(id=f"{n}-{m}-{i}-{arm}", predicateKey=f"{n}-{m}-{i}", sourceSha256="fixture",
                     bindings=n, types=m, arm=arm, status="SUCCESS")
                for n in range(2, 11) for m in range(1, n+1)
                for i in range(10) for arm in ("typed", "untyped")]
        manifest = dict(complete=True, workers=8, heap="768m", timeoutSeconds=60, trials=copy.deepcopy(rows))
        return manifest, rows

    def test_timeout_is_censored_not_missing(self):
        m, rows = self.grid()
        self.assertTrue(synthetic_checks(m, rows))
        rows[0]["status"] = "TIMEOUT"
        self.assertTrue(synthetic_checks(m, rows))
        for status in ("OOM", "ERROR", "INTERRUPTED", "NOT_RUN"):
            rows[0]["status"] = status
            self.assertFalse(synthetic_checks(m, rows))

    def test_grid_coverage_and_identity(self):
        m, rows = self.grid()
        self.assertFalse(synthetic_checks(m, rows[:-1]))
        self.assertFalse(synthetic_checks(m, rows[:-1] + [rows[0]]))
        rows[0]["types"] = 2
        self.assertFalse(synthetic_checks(m, rows))
        m, rows = self.grid()
        m["timeoutSeconds"] = 300
        self.assertFalse(synthetic_checks(m, rows))


if __name__ == "__main__":
    unittest.main()
