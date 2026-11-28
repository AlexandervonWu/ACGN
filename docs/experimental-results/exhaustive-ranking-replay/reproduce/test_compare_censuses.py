"""Small synthetic fixtures for the before/after report and historical floor."""
import gzip
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import compare_censuses as comparison

class ComparisonTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.source = {"submission":"project/both/source.als", "predicate":"inv1",
                       "reference":"project/correct/ref.als", "referencePredicate":"inv1",
                       "sourceSha256":"7"*64, "referenceSha256":"8"*64}
        self.row = {"left":self.source["submission"], "right":self.source["reference"], "leftPredicate":"inv1",
                    "rightPredicate":"inv1", "checked":False,"status":"MISMATCH", "reason":"CHECKED_NATIVE_ACTIONS_DIFFER",
                    "expected":3,"firstDifference":1,"sequenceKind":"FLAT_ACTIONS","fastActionCount":10,"certifiedActionCount":10,
                    "fastSequenceSha256":"1"*64,"certifiedSequenceSha256":"2"*64,"incidentSha256":"3"*64,"incidentPath":"incidents/example.json.gz"}
        self.original = self.archive("old",[[1,"!",self.row["incidentSha256"]],[2,"T",2,"9"*64]],True)
        self.new = self.archive("new",[[1,"F",10,"2"*64],[2,"T",2,"9"*64]],False)
        self.floor = self.root / "floor.jsonl"
        self.floor.write_text(comparison.text_row({**self.source,"submission":"old/source.als"}))
        self.out = self.root / "out"
        self.out.mkdir()

    def archive(self,name,entries,failed):
        path = self.root / name
        path.mkdir()
        chunk = path / "native-ranking-000.jsonl.gz"
        with gzip.open(chunk,"wt") as stream:
            stream.write(comparison.text_row([self.source["submission"],entries]))
        incidents = path / "nonmatching.jsonl.gz"
        with gzip.open(incidents, "wt") as stream:
            if failed:
                stream.write(comparison.text_row(dict(observation=self.row,referenceId=1,
                                 leftSha256=self.source["sourceSha256"],rightSha256=self.source["referenceSha256"])))
        summary = dict(complete=True, inputManifestSha256=comparison.COHORT_SHA, rows=2, nonconforming=int(failed),
                       producerIdentitySha256=("0" if failed else "1")*64, measuredJarSha256=("a" if failed else "b")*64,
                       nonmatchingSha256=comparison.sha(incidents), status="BLOCKED" if failed else "VERIFIED",
                       chunks=[{"path":chunk.name,"sha256":comparison.sha(chunk)}])
        (path / "summary.json").write_text(comparison.text_row(summary))
        return path

    @patch.object(comparison,"REQUIRED",2)
    def test_one_genuine_identity_change_with_single_affected_arm(self):
        report=comparison.rebuild(self.original,self.new,self.floor,self.out)
        self.assertEqual(report["originalFastVersusRepairedProgram"],{"changed":1,"same":1})
        self.assertEqual(report["originalCertifiedVersusRepairedProgram"],{"same":2})
        self.assertEqual(report["newFloor"],2)
        self.assertIn(self.source,list(map(json.loads,(self.out/"paid-rank-witnesses-floor.jsonl").read_text().splitlines())))

    @patch.object(comparison,"REQUIRED",2)
    def test_refuses_shifted_endpoint(self):
        other=self.archive("shifted",[[2,"F",10,"2"*64],[1,"T",2,"9"*64]],False)
        with self.assertRaisesRegex(ValueError,"different endpoints"):
            comparison.rebuild(self.original,other,self.floor,self.out)

    @patch.object(comparison,"REQUIRED",2)
    def test_refuses_replaced_historical_source(self):
        self.floor.write_text(comparison.text_row({**self.source,"sourceSha256":"a"*64}))
        with self.assertRaisesRegex(ValueError,"Source hash drift"):
            comparison.rebuild(self.original,self.new,self.floor,self.out)

    @patch.object(comparison,"REQUIRED",2)
    def test_refuses_changed_chunk(self):
        with (self.new/"native-ranking-000.jsonl.gz").open("ab") as stream:
            stream.write(b"changed")
        with self.assertRaisesRegex(ValueError,"Changed archive"):
            comparison.rebuild(self.original,self.new,self.floor,self.out)

if __name__ == "__main__":
    unittest.main()
