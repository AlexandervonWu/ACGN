"""Recount every registered stage, regenerate the 386-pair history and bind optional final forward programs."""

import argparse
import concurrent.futures
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import zipfile


def sha(path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for b in iter(lambda: f.read(1024 * 1024), b""):
            h.update(b)
    return h.hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def need(ok, message):
    if not ok:
        raise ValueError(message)


def unpack(root, target, packs):
    for name, h in packs.items():
        p = root / name
        need(sha(p) == h, "Changed stage archive " + name)
        with zipfile.ZipFile(p) as z:
            for info in z.infolist():
                rel = Path(info.filename)
                out = target / rel
                need(
                    not rel.is_absolute()
                    and ".." not in rel.parts
                    and rel.as_posix() == info.filename
                    and not out.exists(),
                    "Duplicate or invalid path",
                )
                out.parent.mkdir(parents=True, exist_ok=True)
                with z.open(info) as f, out.open("xb") as dest:
                    shutil.copyfileobj(f, dest)
    for p in target.rglob("part-*"):
        if p.is_dir() and p.name[5:].isdigit():
            (p / "incidents").mkdir(exist_ok=True)


def run(args, expected=0):
    out = subprocess.run([sys.executable, "-B", *map(str, args)], capture_output=True, text=True)
    need(out.returncode == expected, out.stdout + "\n" + out.stderr)


def read_native(p):
    with gzip.open(p, "rt") as f:
        for s in f:
            yield json.loads(s)


def bind_forward(archive, expected, required_summary):
    need(sha(archive / "summary.json") == required_summary, "Unregistered full-census summary")
    s = read(archive / "summary.json")
    need(
        s["complete"] is True
        and s["rows"] == 1_894_168
        and s["shardsChecked"] == s["required"] == 1059,
        "Full census is incomplete",
    )
    seen = set()
    wanted = {key[0] for key in expected}
    for chunk in s["chunks"]:
        p = archive / chunk["path"]
        need(sha(p) == chunk["sha256"], "Changed compact program chunk")
        for left, cells in read_native(p):
            if left not in wanted:
                continue
            for cell in cells:
                k = left, cell[0]
                if k in expected:
                    need(
                        k not in seen and cell[1:] == expected[k],
                        "Full-run forward program differs at " + str(k),
                    )
                    seen.add(k)
    need(seen == set(expected), "Some closed targets lack a full-run forward program")
    return len(seen)


def verify(root, full=None):
    m = read(root / "manifest.json")
    need(sha(root / "verify.py") == m["readerSha256"], "Unregistered stage reader")
    for name, h in m["tables"].items():
        need(sha(root / name) == h, "Changed stage table " + name)
    with tempfile.TemporaryDirectory() as temp:
        w = Path(temp)
        stage = w / "closed-stage-attribution"
        unpack(root, w, m["archives"])
        names = m["stages"]
        need(
            names
            == ["original-replay", "candidate-01", "candidate-02", "candidate-03", "candidate-04"],
            "Unexpected stage sequence",
        )

        def redo(name):
            d = stage / name
            snap = d / "snapshot.json"
            b = w / "builds" / name
            t = d / "native"
            out = w / (name + ".json")
            run(
                [
                    w / "regression-audit/verify_checkpoint.py",
                    "audit",
                    "--workspace",
                    w,
                    "--jar",
                    b / "a.jar",
                    "--build-receipt",
                    b / "build-receipt.json",
                    "--target",
                    t,
                    "--snapshot",
                    snap,
                    "--snapshot-sha256",
                    sha(snap),
                    "--output",
                    out,
                ],
                2,
            )
            need(
                out.read_bytes() == (d / "independent-recount.json").read_bytes(),
                "Independent historical stage recount differs " + name,
            )

        with concurrent.futures.ThreadPoolExecutor(2) as executor:
            list(executor.map(redo, names[1:]))
        new = stage / "reproduced"
        run([stage / "compare_stages.py", "--output", new, "--stages", *names[1:]])
        for p in new.iterdir():
            need(
                p.read_bytes() == (root / "tables" / p.name).read_bytes(),
                "Computed stage attribution differs " + p.name,
            )
        final = m["final"]
        if final is not None:
            v = w / "regression-audit/verify_checkpoint.py"
            d = w / "final"
            selected = d / "snapshot.json"
            out = d / "repeat.json"
            run(
                [
                    v,
                    "audit",
                    "--workspace",
                    w,
                    "--jar",
                    d / "a.jar",
                    "--build-receipt",
                    d / "build-receipt.json",
                    "--target",
                    d / "native",
                    "--snapshot",
                    selected,
                    "--snapshot-sha256",
                    sha(selected),
                    "--output",
                    out,
                ]
            )
            need(
                out.read_bytes() == (d / "independent-recount.json").read_bytes(),
                "Final exact-JAR recount differs",
            )
            gate = read(out)
            marker = read(d / "launch-marker.json")
            approval = read(d / "approval.json")
            registration = read(d / "registration.json")
            need(
                gate["recountStatus"] == gate["nativeCheckpointStatus"] == "VERIFIED"
                and gate["originalIncidents"] == 386
                and gate["historyFloorRows"] == 83
                and gate["originalPairs"] == 469
                and gate["directions"] == gate["verifiedDirections"] == 938,
                "Final directional scope incomplete",
            )
            need(
                final["directions"] == final["forwardAndReverseMatched"] == 938
                and final["original"] == 386
                and final["historical"] == 83,
                "Incomplete final manifest",
            )
            need(
                final["jarSha256"]
                == sha(d / "a.jar")
                == marker["jarSha256"]
                == gate["candidateJarSha256"]
                == registration["jarSha256"]
                == approval["jarSha256"]
                and final["commit"]
                == gate["candidateCommit"]
                == marker["commit"]
                == registration["commit"]
                == approval["commit"],
                "Wrong final source or JAR",
            )
            need(
                final["uuid"] == marker["uuid"] == marker["candidateRunId"]
                and final["identitySha256"] == marker["identitySha256"]
                and final["preflightRecountSha256"] == sha(out) == marker["preflightAuditSha256"]
                and final["markerSha256"] == sha(d / "launch-marker.json"),
                "Wrong final run marker",
            )
            need(
                approval["freezeSha256"]
                == marker["rootFreezeSha256"]
                == sha(d / "registration.json")
                and sha(d / "approval.json") == marker["rootFreezeAuthoritySha256"]
                and sha(w / "final-handoff/required-paid-ranking-witnesses.jsonl")
                == marker["expandedFloorSha256"],
                "Historical scope authority differs",
            )
            sys.path.insert(0, str(root))
            from final_rows import derive, table, history

            observed = derive(
                d / "native/native-observations.jsonl",
                w / "cohort/reference-catalog.tsv",
                root / "tables/complete-pair-observations.jsonl.gz",
                w / "final-handoff/required-paid-ranking-witnesses.jsonl",
            )
            need(
                table(observed) == (root / "tables/final-directions.csv").read_bytes(),
                "Final paid-floor table differs",
            )
            timeline, signals = history(
                observed, root / "tables/complete-pair-observations.jsonl.gz"
            )
            need(
                table(timeline) == (root / "tables/final-timeline.csv").read_bytes()
                and signals == read(root / "tables/final-transitions.json"),
                "Computed repair timeline differs",
            )
            if full is not None:
                summary = read(full / "summary.json")
                need(
                    summary["measuredJarSha256"] == final["jarSha256"]
                    and summary["candidateRunId"] == final["uuid"]
                    and summary["producerIdentitySha256"] == final["identitySha256"]
                    and summary["measuredCommit"] == final["commit"]
                    and summary["complete"]
                    and summary["status"] == "VERIFIED",
                    "Wrong repaired full-census registration",
                )
                values = {
                    (r["submission"], r["referenceId"]): [r["mode"], r["steps"], r["programSha256"]]
                    for r in observed
                    if r["direction"] == "forward"
                }
                need(
                    len(values) == 469
                    and bind_forward(full, values, final["fullSummarySha256"]) == 469,
                    "Incomplete final forward binding",
                )
        else:
            need(full is None, "No verified final checkpoint has been installed")
    return {
        "originalPairs": 386,
        "directionsPerStage": 772,
        "historicalEngines": len(names),
        "unresolvedAt04": 10,
        "final": m["final"],
    }


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("stage", type=Path, nargs="?", default=Path(__file__).resolve().parent)
    p.add_argument("--full-archive", type=Path)
    a = p.parse_args()
    print(json.dumps(verify(a.stage.resolve(), a.full_archive), sort_keys=True))
