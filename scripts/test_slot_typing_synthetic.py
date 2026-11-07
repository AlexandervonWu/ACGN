import hashlib
import json
from pathlib import Path
import sys
import subprocess
import tempfile
import threading
import time
import unittest
from unittest.mock import patch

import run_slot_typing_synthetic as runner


def row(index, arm, status="SUCCESS", elapsed=1):
    return {"id": f"{index}-{arm}", "arm": arm, "predicateKey": str(index),
            "family": "test", "bindings": 8, "types": 2, "status": status,
            "runtimeSeconds": elapsed, "engineNanos": int(elapsed * 1e9)}


class StatisticsTests(unittest.TestCase):
    def test_success_only_statistics_keep_failure_denominator(self):
        rows = [row(0, "typed", elapsed=2), row(1, "typed", elapsed=4),
                row(2, "typed", "TIMEOUT", 300), row(3, "typed", "OOM", 10)]
        stats = runner.summarize(rows)["typed"]
        self.assertEqual(stats["successRate"], 0.5)
        self.assertEqual(stats["failures"], 2)
        self.assertEqual(stats["runtimeSecondsSuccessful"], {"median": 3, "p95": 4})

    def test_empty_successes_are_unavailable(self):
        stats = runner.summarize([row(0, "typed", "TIMEOUT", 300)])["typed"]
        self.assertEqual(stats["successRate"], 0)
        self.assertEqual(stats["runtimeSecondsSuccessful"], {"median": None, "p95": None})

    def test_p95_is_nearest_rank(self):
        rows = [row(i, "typed", elapsed=i) for i in range(1, 21)]
        self.assertEqual(runner.successful_times(rows, "runtimeSeconds"), {"median": 10.5, "p95": 19})

    def test_unfinished_inputs_stay_in_denominator(self):
        stats = runner.summarize([row(0, "typed"), row(1, "typed", "NOT_RUN")])["typed"]
        self.assertEqual(stats["successRate"], 0.5)
        self.assertEqual(stats["notCompleted"], 1)

    def test_matched_subset_and_markdown(self):
        rows = [row(0, "typed"), row(0, "untyped", elapsed=2),
                row(1, "typed", "TIMEOUT", 300), row(1, "untyped", elapsed=3)]
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            manifest = {"trials": rows, "runId": "test", "timeoutSeconds": 300, "workers": 1, "heap": "4g"}
            runner.report(output, rows, manifest, True)
            summary = json.loads((output / "summary.json").read_text())
            self.assertEqual(summary["matchedSuccessful"]["typed"]["predicates"], 1)
            self.assertEqual(summary["all"]["typed"]["successRate"], 0.5)
            self.assertIn("P95 runtime", (output / "summary.md").read_text())
            with self.assertRaises(ValueError):
                runner.report(output, rows[:-1], manifest, False)


class DeadlineTests(unittest.TestCase):
    def test_cli_rejects_deadlines_above_five_minutes(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "must-not-exist"
            result = subprocess.run([sys.executable, str(Path(runner.__file__)), "--output", str(output),
                                     "--timeout-seconds", "301"], capture_output=True)
            self.assertEqual(result.returncode, 2)
            self.assertFalse(output.exists())

    def test_live_cancellation_stops_child(self):
        stop = threading.Event()
        timer = threading.Timer(0.2, stop.set)
        with tempfile.TemporaryDirectory() as directory:
            timer.start()
            try:
                status, code, elapsed = runner.run_process(
                    [sys.executable, "-c", "import time; time.sleep(30)"], Path(directory) / "log", 300, stop)
            finally:
                timer.cancel()
            self.assertEqual(status, "INTERRUPTED")
            self.assertNotEqual(code, 0)
            self.assertLess(elapsed, 5)

    def test_timeout_kills_process_group(self):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            marker = directory / "orphan"
            descendant = "import pathlib,time; time.sleep(0.8); pathlib.Path(" + repr(str(marker)) + ").touch()"
            parent = "import subprocess,sys,time; subprocess.Popen([sys.executable,'-c'," + repr(descendant) + "]); time.sleep(30)"
            status, code, elapsed = runner.run_process(
                [sys.executable, "-c", parent], directory / "log", 0.3, threading.Event())
            self.assertEqual(status, "TIMEOUT")
            self.assertNotEqual(code, 0)
            self.assertLess(elapsed, 5)
            time.sleep(1)
            self.assertFalse(marker.exists(), "descendant survived the deadline")

    def test_cancel_before_start(self):
        stop = threading.Event()
        stop.set()
        with tempfile.TemporaryDirectory() as directory:
            status, code, elapsed = runner.run_process(
                ["nonexistent-never-launched"], Path(directory) / "log", 300, stop)
            self.assertEqual((status, code, elapsed), ("NOT_RUN", None, 0))

    def test_nonzero_exit_not_timeout(self):
        with tempfile.TemporaryDirectory() as directory:
            status, code, _ = runner.run_process(
                [sys.executable, "-c", "raise SystemExit(3)"], Path(directory) / "log", 5, threading.Event())
            self.assertIsNone(status)
            self.assertEqual(code, 3)

    def test_late_success_payload_is_not_accepted(self):
        with tempfile.TemporaryDirectory() as directory:
            trial = {"id": "late", "predicate": "p", "arm": "typed", "source": "/input.als"}
            def late(command, log, timeout, stop):
                log.write_text("SLOT_PHASE representation\n")
                return "TIMEOUT", 0, 300.01
            with patch.object(runner, "run_process", side_effect=late):
                result = runner.run_trial(trial, Path(directory), "java", "classes", "4g", 300, threading.Event())
            self.assertEqual(result["status"], "TIMEOUT")
            self.assertEqual(result["lastPhase"], "representation")

    def test_success_requires_matching_artifact(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory)
            trial = {"id": "ok", "predicate": "p", "arm": "typed", "source": "/input.als"}
            def fake(command, log, timeout, stop):
                destination = Path(command[-1])
                text = b"representation"
                (destination.parent / "repr.txt").write_bytes(text)
                payload = dict(trial, schema="slot-synthetic-v1", status="SUCCESS",
                               representationFile="repr.txt", representationSha256=hashlib.sha256(text).hexdigest())
                for field in ("parseNanos", "adaptNanos", "representationNanos", "engineNanos", "totalNanos",
                              "eclasses", "enodes", "rewriteApplications", "iterations", "rebuilds", "slotMappings"):
                    payload[field] = 1
                destination.write_text(json.dumps(payload))
                return None, 0, 0.1
            with patch.object(runner, "run_process", side_effect=fake):
                result = runner.run_trial(trial, output, "java", "classes", "4g", 300, threading.Event())
            self.assertEqual(result["status"], "SUCCESS")
            trial["id"] = "bad"
            with patch.object(runner, "run_process", side_effect=fake), patch.object(runner, "sha", return_value="wrong"):
                result = runner.run_trial(trial, output, "java", "classes", "4g", 300, threading.Event())
            self.assertEqual(result["status"], "ERROR")


if __name__ == "__main__":
    unittest.main()
