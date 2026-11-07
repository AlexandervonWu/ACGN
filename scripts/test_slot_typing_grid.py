import json
import math
import unittest
from collections import Counter
import generate_slot_typing_grid as grid
import plot_slot_typing_grid as plot


class GridTests(unittest.TestCase):
    def test_all_cells_balanced_reproducible_and_bounded(self):
        files = grid.contents()
        self.assertEqual(files, grid.contents())
        manifest = json.loads(files["manifest.json"])
        self.assertEqual(manifest["targetPairs"], 270)
        cells = Counter()
        for row in manifest["pairs"]:
            n, m = row["outerBindingsPerPredicate"], row["outerTypeCount"]
            counts = list(row["outerTypeHistogram"].values())
            self.assertEqual(sum(counts), n)
            self.assertEqual(len(counts), m)
            self.assertGreaterEqual(min(counts), 1)
            self.assertLessEqual(max(counts)-min(counts), 1)
            self.assertEqual(row["totalBindingsPerPredicate"], n)
            self.assertEqual(grid.digest(files[row["path"]]), row["sha256"])
            cells[n,m] += 1
        self.assertEqual(cells, Counter({(n,m):5 for n in range(2,11) for m in range(1,n+1)}))
        self.assertNotEqual(files, grid.contents(seed=20261108))

    def test_invalid_bounds_rejected(self):
        for n,m in ((1,1),(11,1),(4,0),(4,5)):
            with self.assertRaises(ValueError):
                grid.balanced_types(n,m,grid.rng_for(1))

    def test_log_speedup_and_censoring(self):
        rows = [dict(bindings=2,types=1,predicateKey="p",arm=a,status="SUCCESS",
                     engineNanos=int(t*1e9),runtimeSeconds=t)
                for a,t in (("typed",1),("untyped",10))]
        cell = plot.cells_from_rows(rows)[0]
        self.assertEqual(cell["matchedLog10EngineSpeedup"],1)
        rows[1]["status"] = "TIMEOUT"
        cell = plot.cells_from_rows(rows)[0]
        self.assertFalse(cell["completeMatchedCell"])
        self.assertIsNone(cell["matchedLog10EngineSpeedup"])
        self.assertEqual(cell["untypedSuccessRate"],0)

    def test_duplicate_or_missing_arm_rejected(self):
        r = dict(bindings=2,types=1,predicateKey="p",arm="typed",status="TIMEOUT")
        for rows in ([r], [r,r]):
            with self.assertRaises(ValueError):
                plot.cells_from_rows(rows)

    def test_arithmetic_envelope(self):
        _,_,row = grid.build(10,5,0,20261107,0)
        self.assertAlmostEqual(10**row["log10TypePartitionedPermutationEnvelope"], 2**5)
        self.assertAlmostEqual(10**row["log10UntypedPermutationEnvelope"], math.factorial(10))


if __name__ == "__main__":
    unittest.main()
