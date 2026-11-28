"""Reproduce complete native edit programs for known divergences on a specific candidate binary."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE / "original-audit"))
from native_commitment import SerializedNumber, canonical, check_programs


def sha(data):
    return hashlib.sha256(data).hexdigest()


def verify(value, reason):
    if not value:
        raise ValueError(reason)


def capture(workspace, engine, expected_sha, paths, output):
    original = workspace / "frozen"
    verify(sha(engine.read_bytes()) == expected_sha, "Candidate JAR changed")
    classpath = f"{engine}:{original}/lib/*"
    with tempfile.TemporaryDirectory() as temp:
        subprocess.run(["javac", "--release", "17", "-cp", classpath, "-d", temp,
                        HERE / "original-audit/EmitNativePrograms.java"], check=True)
        for input_file in paths:
            archive = json.loads(gzip.decompress(input_file.read_bytes()), parse_float=SerializedNumber)
            row = archive["identity"]
            before = archive["nativeComparatorEvidence"]
            check_programs(before, row)
            verify(before["status"] == row["status"] == "MISMATCH", "Original example did not diverge")
            selectors = [row["left"], row["leftPredicate"], archive["leftSha256"],
                         row["right"], row["rightPredicate"], archive["rightSha256"]]
            raw = subprocess.check_output(["java", "-Xmx600m", "-XX:+UseSerialGC", "-XX:ActiveProcessorCount=1",
                    "-cp", f"{temp}:{classpath}", "is.fivefivefive.CanDis.EmitNativePrograms",
                    original / "classified-data", *selectors])
            after = json.loads(raw, parse_float=SerializedNumber)
            verify(after["status"] == "MATCHED" and after["reason"] == "CHECKED_NATIVE_ACTIONS_EQUAL" and
                   all(after[f] is True for f in ["sourceCertificatesChecked", "endpointCorrespondenceChecked",
                                                   "fixedChoiceReplaysChecked"]), "Repaired verifier did not accept")
            verify(all(prog["diagnostic"][arm]["distance"] == row["expected"]
                       for prog in (before, after) for arm in ("fast", "certified")), "Incorrect native costs")
            def sequence(prog, arm):
                if row["sequenceKind"] == "TEMPORAL_BLOCK_EFFECTS":
                    return [[b["component"], b["effect"]] for b in prog[arm + "Blocks"]]
                return prog[arm + "Actions"]
            of, oc = (sequence(before, arm) for arm in ("fast", "certified"))
            nf, nc = (sequence(after, arm) for arm in ("fast", "certified"))
            verify(canonical(nf) == canonical(nc), "Repaired native programs differ")
            tag = input_file.name.split("-")[:3]
            prefix = "-".join(tag)
            native = output / (prefix + "-after.json.gz")
            with native.open("xb") as stream:
                stream.write(gzip.compress(raw, mtime=0))
            report = dict(left=selectors[:3], right=selectors[3:], cost=row["expected"], kind=row["sequenceKind"],
                          originalIncident=input_file.name, originalIncidentSha256=sha(input_file.read_bytes()),
                          candidateJarSha256=expected_sha, afterEvidence=native.name, afterEvidenceSha256=sha(native.read_bytes()),
                          oldFastSequenceSha256=sha(canonical(of).encode()), oldCertifiedSequenceSha256=sha(canonical(oc).encode()),
                          newSequenceSha256=sha(canonical(nf).encode()), certifiedProgramPreserved=canonical(oc) == canonical(nc),
                          originalFirstDifference=row["firstDifference"], fastFirst=row["fastFirst"], certifiedFirst=row["certifiedFirst"],
                          oldCounts=[len(of), len(oc)], newCount=len(nf))
            summary = output / (prefix + "-example.json")
            with summary.open("x") as stream:
                json.dump(report, stream, indent=2, sort_keys=True)
                stream.write("\n")
            print(summary.name, report["cost"], report["newSequenceSha256"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workspace", type=Path)
    parser.add_argument("candidate_jar", type=Path)
    parser.add_argument("expected_jar_sha256")
    parser.add_argument("output", type=Path)
    parser.add_argument("incident", type=Path, nargs="+")
    opt = parser.parse_args()
    opt.output.mkdir()
    capture(opt.workspace, opt.candidate_jar, opt.expected_jar_sha256, opt.incident, opt.output)
