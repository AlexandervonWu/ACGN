import unittest
import csv
from pathlib import Path
import tempfile
from classify_distance_mismatches import classify, classify_all, inventory


def row(path, fast, certified, temporal=(0, 0), quantifier=(0, 0)):
    return dict(relativePath=path, legacyCanonicalDistance=fast, distance=certified,
                legacyTemporalDistance=temporal[0], quotientTemporalDistance=temporal[1],
                legacyQuantifierDistance=quantifier[0], quotientQuantifierDistance=quantifier[1],
                legacyMatrixDistance=fast-temporal[0]-quantifier[0],
                quotientMatrixDistance=certified-temporal[1]-quantifier[1])


class ClassificationTest(unittest.TestCase):
    def read_inventory(self, values):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "mismatches.csv"
            with path.open("w", newline="") as stream:
                writer = csv.DictWriter(stream, list(values[0]))
                writer.writeheader()
                writer.writerows(values)
            return inventory(path)

    def test_inventory_rejects_bad_census_rows(self):
        valid = row("p/a", 6, 4)
        self.assertEqual(6, self.read_inventory([valid])["p/a"]["legacyCanonicalDistance"])
        with self.assertRaises(ValueError):
            self.read_inventory([valid, valid])
        with self.assertRaises(ValueError):
            self.read_inventory([row("p/a", 4, 4)])
        broken = dict(valid, quotientMatrixDistance=9)
        with self.assertRaises(ValueError):
            self.read_inventory([broken])
        with self.assertRaises(ValueError):
            self.read_inventory([row("p/a", -1, 4)])

    def test_component_overlap_is_explicit(self):
        result = classify(row("p/a", 6, 4, (2, 1)), None)
        self.assertEqual("temporal+matrix", result["componentClass"])
        self.assertEqual("introduced", result["change"])
        self.assertEqual("UNCLASSIFIED", result["confirmedWitnessCause"])

    def test_absolute_gap_not_signed_mean(self):
        result = classify(row("p/a", 8, 5), row("p/a", 1, 5))
        self.assertEqual("improved", result["change"])
        self.assertTrue(result["signFlipped"])

    def test_population_accounting_and_representatives(self):
        old = {"p/a": row("p/a", 4, 5), "p/b": row("p/b", 4, 5)}
        new = {"p/b": row("p/b", 2, 5), "q/c": row("q/c", 7, 5)}
        classified, summary, representatives = classify_all(new, old)
        self.assertEqual(1, summary["resolved"])
        self.assertEqual(1, summary["introduced"])
        self.assertEqual(2, sum(c["count"] for c in summary["classes"]))
        self.assertEqual({"p/b", "q/c"}, {r["relativePath"] for r in representatives})
        self.assertEqual("worsened", classified[0]["change"])


if __name__ == "__main__":
    unittest.main()
