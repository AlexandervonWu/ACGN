#!/usr/bin/env python3
"""A diagnostic inventory must not silently drop or reinterpret failures."""

import sys
import unittest

sys.dont_write_bytecode = True
from report_obligation_repairs import parse_report


class ReportingTest(unittest.TestCase):
    def test_complete_report(self):
        counts, failures = parse_report(
            "Section 3 assurance traceability\nrequirements=2\nmatrixRows=2\n"
            "ready=1\nfailures=1\nFAIL\tA-01 MISSING_LOW_LEVEL_REGISTRY\n")
        self.assertEqual(counts["failures"], 1)
        self.assertEqual(failures, ["A-01 MISSING_LOW_LEVEL_REGISTRY"])

    def test_zero_failures(self):
        self.assertEqual(parse_report("requirements=1\nmatrixRows=1\nready=1\nfailures=0\n")[1], [])

    def test_missing_count(self):
        with self.assertRaises(ValueError):
            parse_report("requirements=1\nready=1\nfailures=0\n")

    def test_duplicate_count(self):
        with self.assertRaises(ValueError):
            parse_report("requirements=1\nrequirements=1\nmatrixRows=1\nready=1\nfailures=0\n")

    def test_hidden_failure(self):
        with self.assertRaises(ValueError):
            parse_report("requirements=1\nmatrixRows=1\nready=1\nfailures=0\nFAIL\tA-01 incomplete\n")

    def test_missing_failure(self):
        with self.assertRaises(ValueError):
            parse_report("requirements=1\nmatrixRows=1\nready=0\nfailures=1\n")

    def test_duplicate_failure(self):
        with self.assertRaises(ValueError):
            parse_report("requirements=1\nmatrixRows=1\nready=0\nfailures=2\n"
                         "FAIL\tA-01 incomplete\nFAIL\tA-01 incomplete\n")

    def test_invalid_count(self):
        with self.assertRaises(ValueError):
            parse_report("requirements=1\nmatrixRows=1\nready=2\nfailures=0\n")


if __name__ == "__main__":
    unittest.main()
