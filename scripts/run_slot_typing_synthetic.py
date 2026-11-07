#!/usr/bin/env python3
"""Uncapped synthetic representation trials, isolated by a <=300s process deadline."""
import argparse
from collections import Counter
from concurrent.futures import FIRST_COMPLETED, ThreadPoolExecutor, wait
import csv
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import random
import shutil
import signal
import statistics
import subprocess
import threading
import time
import uuid

ROOT = Path(__file__).resolve().parents[1]
ARMS = ("untyped", "typed")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path, value):
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    temporary.replace(path)


def run_process(command, log, timeout, stop):
    """No Java thread cancellation: a late or interrupted child is killed and reaped."""
    started = time.monotonic()
    process = None
    status = None
    with log.open("wb") as stream:
        try:
            if stop.is_set():
                return "NOT_RUN", None, 0.0
            process = subprocess.Popen(command, stdout=stream, stderr=subprocess.STDOUT,
                                       start_new_session=True)
            while True:
                remaining = timeout - (time.monotonic() - started)
                if stop.is_set():
                    status = "INTERRUPTED"
                    break
                if remaining <= 0:
                    status = "TIMEOUT"
                    break
                try:
                    process.wait(timeout=min(remaining, 0.2))
                    break
                except subprocess.TimeoutExpired:
                    pass
        finally:
            if process is not None and (status is not None or process.poll() is None):
                try:
                    os.killpg(process.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                process.wait()
    elapsed = time.monotonic() - started
    if status is None and stop.is_set():
        status = "INTERRUPTED"
    if status is None and elapsed >= timeout:
        status = "TIMEOUT"
    return status, process.returncode, elapsed


def run_trial(trial, output, java, classpath, heap, timeout, stop):
    row = dict(trial)
    directory = output / "trials" / trial["id"]
    directory.mkdir(parents=True)
    result_file = directory / "result.json"
    command = [java, "-Xms256m", "-Xmx" + heap, "-Xss16m", "-XX:+UseG1GC",
               "-XX:ActiveProcessorCount=1", "-XX:+ExitOnOutOfMemoryError", "-cp", classpath,
               "is.fivefivefive.CanDis.SlotTypingSyntheticWorker",
               trial["source"], trial["predicate"], trial["arm"], str(result_file)]
    try:
        status, code, elapsed = run_process(command, directory / "process.log", timeout, stop)
        row.update(status=status, exitCode=code, runtimeSeconds=elapsed)
        if status is not None:
            phases = [line.removeprefix("SLOT_PHASE ") for line in (directory / "process.log")
                      .read_text(encoding="utf-8", errors="replace").splitlines()
                      if line.startswith("SLOT_PHASE ")]
            row["lastPhase"] = phases[-1] if phases else "startup"
            return row
        payload = json.loads(result_file.read_text(encoding="utf-8"))
        if (payload["schema"] != "slot-synthetic-v1" or payload["source"] != trial["source"]
                or payload["predicate"] != trial["predicate"] or payload["arm"] != trial["arm"]):
            raise ValueError("Worker identity mismatch")
        status = payload["status"]
        if status not in {"SUCCESS", "OOM", "STACK_OVERFLOW", "ERROR"}:
            raise ValueError("Unknown worker status")
        if status == "SUCCESS":
            if code != 0:
                raise ValueError("Nonzero exit with a success payload")
            representation = (directory / payload["representationFile"]).resolve()
            if representation.parent != directory.resolve() or sha(representation) != payload["representationSha256"]:
                raise ValueError("Representation artifact/hash mismatch")
            for field in ("parseNanos", "adaptNanos", "representationNanos", "engineNanos", "totalNanos"):
                if type(payload[field]) is not int or payload[field] < 0:
                    raise ValueError("Invalid runtime: " + field)
            row.update({field: payload[field] for field in (
                "parseNanos", "adaptNanos", "representationNanos", "engineNanos", "totalNanos",
                "representationSha256", "eclasses", "enodes", "rewriteApplications",
                "iterations", "rebuilds", "slotMappings")})
        row["status"] = status
        if "error" in payload:
            row["error"] = payload["error"]
    except Exception as error:
        row["status"] = "ERROR"
        row["error"] = type(error).__name__ + ": " + str(error)
        log = directory / "process.log"
        if log.exists() and b"OutOfMemoryError" in log.read_bytes():
            row["status"] = "OOM"
    return row


def successful_times(rows, field, scale=1.0):
    values = sorted(row[field] / scale for row in rows if row["status"] == "SUCCESS")
    return {"median": statistics.median(values) if values else None,
            "p95": values[math.ceil(0.95 * len(values)) - 1] if values else None}


def summarize(rows):
    result = {}
    for arm in ARMS:
        selected = [row for row in rows if row["arm"] == arm]
        statuses = Counter(row["status"] for row in selected)
        count = len(selected)
        success = statuses["SUCCESS"]
        result[arm] = {"predicates": count, "successes": success,
                       "failures": sum(n for s, n in statuses.items()
                                       if s not in {"SUCCESS", "NOT_RUN", "INTERRUPTED"}),
                       "notCompleted": statuses["NOT_RUN"] + statuses["INTERRUPTED"],
                       "successRate": success / count if count else None,
                       "statuses": dict(sorted(statuses.items())),
                       "runtimeSecondsSuccessful": successful_times(selected, "runtimeSeconds"),
                       "engineSecondsSuccessful": successful_times(selected, "engineNanos", 1e9)}
    return result


def report(output, rows, manifest, completed):
    expected = {row["id"] for row in manifest["trials"]}
    if len(expected) != len(rows) or {row["id"] for row in rows} != expected:
        raise ValueError("Missing/duplicate scheduled observations")
    summary = {"schema": "slot-synthetic-v1", "runId": manifest["runId"],
               "complete": completed, "timeoutSeconds": manifest["timeoutSeconds"],
               "all": summarize(rows), "byFamily": {}, "byBindingCount": {}}
    for field, target in (("family", "byFamily"), ("bindings", "byBindingCount")):
        for value in sorted({row[field] for row in rows}):
            summary[target][str(value)] = summarize([row for row in rows if row[field] == value])
    # Outcome-matched timings expose survivorship bias in independent success-only medians.
    successful_ids = [{row["predicateKey"] for row in rows
                       if row["arm"] == arm and row["status"] == "SUCCESS"} for arm in ARMS]
    shared = successful_ids[0] & successful_ids[1]
    summary["matchedSuccessful"] = summarize([row for row in rows if row["predicateKey"] in shared])
    write_json(output / "summary.json", summary)
    fields = ["id", "path", "predicate", "arm", "family", "bindings", "types", "status",
              "runtimeSeconds", "parseNanos", "adaptNanos", "representationNanos", "engineNanos",
              "eclasses", "enodes", "error"]
    with (output / "predicates.csv").open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fields, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)
    def fmt(value):
        return "unavailable" if value is None else f"{value:.6f}"
    def table(stats):
        lines = ["| Pipeline | Predicates | Successes | Success rate | Median runtime (s) | P95 runtime (s) | Median engine (s) | P95 engine (s) |",
                 "| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |"]
        for arm in ARMS:
            s = stats[arm]
            rate = "unavailable" if s["successRate"] is None else f'{100 * s["successRate"]:.2f}%'
            wall, engine = s["runtimeSecondsSuccessful"], s["engineSecondsSuccessful"]
            lines.append(f'| {arm} | {s["predicates"]} | {s["successes"]} | {rate} | '
                         f'{fmt(wall["median"])} | {fmt(wall["p95"])} | '
                         f'{fmt(engine["median"])} | {fmt(engine["p95"])} |')
        return lines
    lines = ["# Synthetic Typed/Untyped Representation Runtime", "",
             f'- Run: `{manifest["runId"]}`', f'- Complete schedule: `{completed}`',
             f'- Deadline: {manifest["timeoutSeconds"]} seconds per predicate per arm.',
             f'- Child heap: {manifest["heap"]}; concurrent isolated JVMs: {manifest["workers"]}.',
             "- Permutation, symmetry, alpha-pass, rewrite-pass, term-size and rebuild caps: disabled in this synthetic path.",
             "- Success means completed representation construction, not semantic equivalence or repair correctness.",
             "- Runtime includes JVM startup, parsing, construction and output; engine excludes parsing/startup but includes adaptation.",
             "- Median/P95 use successes only; P95 is nearest rank. Failures and unfinished trials remain in the rate denominator.",
             "- These independent-success statistics may have survivorship bias; compare the matched subset too.",
             "", "## All Selected Predicates", "", *table(summary["all"]), "",
             "## Failure Statuses", ""]
    for arm in ARMS:
        lines.append(f'- {arm}: `{json.dumps(summary["all"][arm]["statuses"], sort_keys=True)}`')
    lines += ["", "## Matched Successful Predicates", "", *table(summary["matchedSuccessful"])]
    for title, key in (("By Family", "byFamily"), ("By Binding Count", "byBindingCount")):
        lines += ["", "## " + title]
        for group, stats in summary[key].items():
            lines += ["", "### " + group, "", *table(stats)]
    (output / "summary.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def command_text(command):
    return subprocess.check_output(command, cwd=ROOT, stderr=subprocess.STDOUT, text=True).strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", type=Path, default=ROOT / "synthetic-data/slot-binding-stress")
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--workers", type=int, default=1)
    parser.add_argument("--heap", default="4g")
    parser.add_argument("--timeout-seconds", type=float, default=300,
                        help="At most 300; smaller values are for explicitly labeled smoke checks")
    parser.add_argument("--limit-pairs", type=int, default=0)
    parser.add_argument("--seed", type=int, default=20261106)
    parser.add_argument("--min-available-gib", type=float, default=0,
                        help="Linux host available-memory reserve; zero disables this optional guard")
    parser.add_argument("--min-free-disk-gib", type=float, default=0)
    args = parser.parse_args()
    if os.name != "posix":
        parser.error("This supervisor requires POSIX process groups (Linux/macOS)")
    if args.workers < 1 or args.limit_pairs < 0 or not 0 < args.timeout_seconds <= 300:
        parser.error("workers >=1, limit-pairs >=0, and 0 < timeout-seconds <=300 required")
    if args.min_available_gib < 0 or args.min_free_disk_gib < 0:
        parser.error("Resource reserves cannot be negative")
    import re
    if not re.fullmatch(r"[1-9][0-9]*[gGmM]", args.heap):
        parser.error("heap must be a positive JVM size, e.g. 4g")
    dataset = args.dataset.resolve()
    output = args.output.resolve()
    if output.is_relative_to(dataset):
        parser.error("Output must be outside the source dataset")
    output.mkdir(parents=True, exist_ok=False)
    def resource_check():
        if shutil.disk_usage(output).free < args.min_free_disk_gib * 2**30:
            return "Disk reserve breached"
        if args.min_available_gib:
            memory = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
            if int(memory["MemAvailable"].split()[0]) * 1024 < args.min_available_gib * 2**30:
                return "Host available-memory reserve breached"
        return None
    if resource_check():
        raise RuntimeError(resource_check())
    data = json.loads((dataset / "manifest.json").read_text(encoding="utf-8"))
    pairs = list(data["pairs"])
    random.Random(args.seed).shuffle(pairs)
    pairs = pairs[:args.limit_pairs] if args.limit_pairs else pairs
    if not pairs:
        parser.error("No input pairs")
    trials = []
    for index, pair in enumerate(pairs):
        source = (dataset / pair["path"]).resolve()
        if not source.is_relative_to(dataset / "models"):
            raise ValueError("Synthetic source must be under models/")
        contents = source.read_bytes()
        if hashlib.sha256(contents).hexdigest() != pair["sha256"]:
            raise ValueError("Dataset hash mismatch: " + str(source))
        frozen = output / "inputs" / pair["path"]
        frozen.parent.mkdir(parents=True, exist_ok=True)
        frozen.write_bytes(contents)
        for role in ("predicate", "reference"):
            name = pair[role]
            key = pair["path"] + "#" + name
            for arm in (ARMS if index % 2 == 0 else tuple(reversed(ARMS))):
                trials.append({"id": f"{len(trials):05d}-{arm}", "arm": arm, "source": str(frozen),
                               "path": pair["path"], "predicate": name, "predicateKey": key,
                               "family": pair["family"], "bindings": pair["outerBindingsPerPredicate"],
                               "types": pair["outerTypeCount"], "sourceSha256": pair["sha256"]})
    if len({(t["predicateKey"], t["arm"]) for t in trials}) != len(trials):
        raise ValueError("Duplicate synthetic predicate/arm in manifest")
    library = output / "lib"
    library.mkdir()
    for jar in sorted((ROOT / "lib").glob("*.jar")):
        shutil.copy2(jar, library / jar.name)
    classes = output / "classes"
    classes.mkdir()
    sources = sorted((ROOT / "src").rglob("*.java"))
    java = shutil.which("java")
    if java is None:
        raise RuntimeError("java is unavailable")
    manifest = {"schema": "slot-synthetic-v1", "runId": str(uuid.uuid4()),
                "started": datetime.now(timezone.utc).isoformat(), "gitSha": command_text(["git", "rev-parse", "HEAD"]),
                "dirtyTree": bool(command_text(["git", "status", "--porcelain"])),
                "datasetManifestSha256": sha(dataset / "manifest.json"), "seed": args.seed,
                "timeoutSeconds": args.timeout_seconds, "workers": args.workers, "heap": args.heap,
                "minAvailableGiB": args.min_available_gib, "minFreeDiskGiB": args.min_free_disk_gib,
                "host": platform.node(), "platform": platform.platform(), "logicalProcessors": os.cpu_count(),
                "java": command_text([java, "-version"]), "javac": command_text(["javac", "-version"]),
                "limits": "synthetic-uncapped-v1", "trials": trials,
                "sourceHashes": {str(p.relative_to(ROOT)): sha(p) for p in sources},
                "supervisorSha256": sha(Path(__file__)),
                "libraryHashes": {p.name: sha(p) for p in sorted(library.glob("*.jar"))}}
    write_json(output / "manifest.json", manifest)
    with (output / "compile.log").open("w") as log:
        subprocess.run(["javac", "--release", "17", "-encoding", "UTF-8", "-cp", str(library / "*"),
                        "-d", str(classes), *map(str, sources)], check=True, stdout=log, stderr=subprocess.STDOUT)
    classpath = str(classes) + os.pathsep + str(library / "*")
    # The corpus validator rejects AST-identical pairs and invalid source/type/hash records.
    with (output / "validation.log").open("w") as log:
        subprocess.run([java, "-Xmx2g", "-Xss16m", "-Dacgn.validateAdapter=true", "-cp", classpath,
                        "is.fivefivefive.CanDis.SlotBindingDatasetValidator", str(dataset),
                        str(output / "validation.json")], check=True, stdout=log, stderr=subprocess.STDOUT, timeout=300)
    manifest["classHashes"] = {str(p.relative_to(classes)): sha(p) for p in sorted(classes.rglob("*.class"))}
    write_json(output / "manifest.json", manifest)
    stop = threading.Event()
    def interrupt_run(signum, frame):
        raise KeyboardInterrupt
    previous_term_handler = signal.signal(signal.SIGTERM, interrupt_run)
    rows = {}
    iterator = iter(trials)
    pool = ThreadPoolExecutor(max_workers=args.workers)
    active = {}
    interrupted = False
    with (output / "trials.jsonl").open("w", encoding="utf-8") as stream:
        def submit():
            trial = next(iterator, None)
            if trial is not None:
                future = pool.submit(run_trial, trial, output, java, classpath,
                                     args.heap, args.timeout_seconds, stop)
                active[future] = trial
        def record(row):
            rows[row["id"]] = row
            stream.write(json.dumps(row, sort_keys=True) + "\n")
            stream.flush()
            print(f'{len(rows)}/{len(trials)} {row["arm"]} {row["predicate"]}: {row["status"]}', flush=True)
        try:
            for _ in range(args.workers):
                submit()
            while active:
                reason = resource_check()
                if reason:
                    manifest["interruptionReason"] = reason
                    print(reason, flush=True)
                    raise KeyboardInterrupt
                done, _ = wait(active, timeout=30, return_when=FIRST_COMPLETED)
                if not done:
                    print(f'{len(rows)}/{len(trials)} complete; {len(active)} predicates in flight', flush=True)
                for future in done:
                    active.pop(future)
                    record(future.result())
                    submit()
        except KeyboardInterrupt:
            interrupted = True
        finally:
            stop.set()
            pool.shutdown(wait=True)
            signal.signal(signal.SIGTERM, previous_term_handler)
            for future, trial in active.items():
                record(future.result())
            for trial in trials:
                if trial["id"] not in rows:
                    record(dict(trial, status="NOT_RUN", runtimeSeconds=None))
    ordered = [rows[t["id"]] for t in trials]
    manifest["finished"] = datetime.now(timezone.utc).isoformat()
    manifest["complete"] = not interrupted and all(r["status"] not in {"NOT_RUN", "INTERRUPTED"} for r in ordered)
    write_json(output / "manifest.json", manifest)
    report(output, ordered, manifest, manifest["complete"])
    hashes = [f"{sha(p)}  {p.relative_to(output)}" for p in sorted(output.rglob("*")) if p.is_file()]
    (output / "SHA256SUMS").write_text("\n".join(hashes) + "\n", encoding="utf-8")
    print("Report: " + str(output / "summary.md"))
    return 0 if manifest["complete"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
