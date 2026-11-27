import json
import tempfile
import unittest
from pathlib import Path

from verify_historical_pair_coverage import ranking_scores, source_endpoint
from verify_historical_rank_traces import inspect_results, jobs_for_run, require_historical_floor, sha


class PaidWitnessGateTest(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.dataset = Path(temp.name)
        for name in ("submission.als", "reference.als"):
            (self.dataset / name).write_text(name)
        self.floor = {"submission": "submission.als", "predicate": "inv1",
                      "sourceSha256": sha(self.dataset / "submission.als"), "reference": "reference.als",
                      "referencePredicate": "inv1", "referenceSha256": sha(self.dataset / "reference.als")}
        rank = [{"referenceSource": "reference.als", "referenceName": "inv1_oracle", "distance": 1},
                {"referenceSource": "reference.als", "referenceName": "inv1_correct_17", "distance": 8}]
        self.row = {"relativePath": "submission.als", "leftPredicate": "inv1", "invariantId": "inv1",
                    "statusFolder": "OVERCONSTRAINED", "legacyCanonicalRanking": rank, "canonicalRanking": rank}

    def jobs(self, floor=None, rows=None):
        return jobs_for_run([self.floor] if floor is None else floor, [self.row] if rows is None else rows,
                            self.dataset, source_endpoint, ranking_scores)

    def test_selects_original_predicate_and_preserves_current_cost(self):
        self.assertEqual(self.jobs(), [{**self.floor, "expected": 8}])
        self.row["canonicalRanking"] = [{**entry, "distance": 4} for entry in self.row["canonicalRanking"]]
        with self.assertRaisesRegex(ValueError, "unequal measured scores"):
            self.jobs()

    def test_missing_repeated_and_changed_sources_fail(self):
        with self.assertRaisesRegex(ValueError, "Missing measured"):
            self.jobs(rows=[])
        with self.assertRaisesRegex(ValueError, "Repeated floor"):
            self.jobs(floor=[self.floor, self.floor])
        with self.assertRaisesRegex(ValueError, "Repeated producer"):
            self.jobs(rows=[self.row, self.row])
        (self.dataset / "reference.als").write_text("changed")
        with self.assertRaisesRegex(ValueError, "Changed source"):
            self.jobs()

    def test_a_previous_release_cannot_drop_a_witness_or_replace_its_bytes(self):
        archive = self.dataset / "old-floor.jsonl"
        archive.write_text(json.dumps(self.floor) + "\n")
        require_historical_floor([self.floor], [archive])
        for candidate in ([], [{**self.floor, "sourceSha256": "changed"}]):
            with self.assertRaisesRegex(ValueError, "Lost archived native witness"):
                require_historical_floor(candidate, [archive])

    def test_requires_two_checked_native_replays_with_measured_cost(self):
        jobs = self.jobs()
        forward = {**jobs[0], "passed": True, "status": "MATCHED", "fastDistance": 8,
                   "certifiedDistance": 8, "sourceCertificatesChecked": True, "fixedChoiceReplaysChecked": True,
                   "endpointCorrespondenceChecked": True, "direction": "forward",
                   "nativeSequencesEqual": True, "reason": "CHECKED_NATIVE_ACTIONS_EQUAL",
                   "sequenceKind": "FLAT_ACTIONS", "fastActionCount": 4, "certifiedActionCount": 4}
        reverse = {**forward, "direction": "reverse"}
        self.assertEqual(inspect_results(jobs, [forward, reverse]), [])
        timed = {**reverse, "sequenceKind": "TEMPORAL_BLOCK_EFFECTS", "orderedBlockEffectsEqual": True,
                 "fastBlockCount": 6, "certifiedBlockCount": 6}
        self.assertEqual(inspect_results(jobs, [forward, timed]), [])
        for change in ({"orderedBlockEffectsEqual": False}, {"certifiedBlockCount": 5}, {"nativeSequencesEqual": False}):
            self.assertEqual(len(inspect_results(jobs, [forward, {**timed, **change}])), 1)
        with self.assertRaisesRegex(ValueError, "Missing native replays"):
            inspect_results(jobs, [forward])
        for mutation in ({"firstDifference": 1}, {"status": "UNKNOWN"}, {"status": "MISMATCH"}, {"reason": "unknown"},
                         {"nativeSequencesEqual": False}, {"sequenceKind": "UNKNOWN"}, {"certifiedActionCount": 3}, {"endpointCorrespondenceChecked": False},
                         {"certifiedDistance": 7}, {"expected": 7}, {"passed": False}):
            with self.subTest(mutation=mutation):
                self.assertEqual(len(inspect_results(jobs, [forward, {**reverse, **mutation}])), 1)


if __name__ == "__main__":
    unittest.main()
