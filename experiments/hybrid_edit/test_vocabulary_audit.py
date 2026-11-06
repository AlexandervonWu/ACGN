import unittest

from experiments.hybrid_edit.audit_vocabulary import historical_census


class CensusTests(unittest.TestCase):
    def test_counts_use_distinct_symbols_and_only_known_banks(self):
        report = historical_census(b"0,Dummy for sig\n1,Dummy for var\n2,Dummy for field\n3,iden\n")
        self.assertEqual(report["historical_unique_symbols"], 4)
        self.assertEqual(len(report["requested_missing_constants"]), 9)
        self.assertEqual(report["historical_plus_requested_constants_collapsed"], 13)
        self.assertEqual(report["historical_semantic_only_expanded"], 34)

    def test_invalid_or_ambiguous_inventory_fails(self):
        for raw in (b"0,x\n0,y\n", b"0,x\n1,x\n", b"not-an-id,x\n", b"0,AND\n"):
            with self.assertRaises(ValueError):
                historical_census(raw)


if __name__ == "__main__":
    unittest.main()
