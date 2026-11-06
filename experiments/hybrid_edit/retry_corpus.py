"""Retry only infrastructure/worker failures once, retaining the initial ledger."""
import argparse
import collections
import json
from pathlib import Path
import shutil
import time

from .corpus import ROOT, digest, process, write


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=Path, required=True)
    parser.add_argument("--classes", type=Path, required=True)
    args = parser.parse_args()
    ledger_path = args.data / "ledger.json"
    ledger = json.loads(ledger_path.read_text())
    selection = json.loads((args.data / "selection.json").read_text())
    if len(ledger) != selection["attempts"] or not (args.data / "summary.json").exists():
        raise ValueError("Collection must finish before retry")
    directory = args.data / "retry-1"
    directory.mkdir()
    for name in ("sources", "logs", "records"):
        (directory / name).mkdir()
    shutil.copy2(ledger_path, directory / "initial-ledger.json")
    started = time.monotonic()
    changes = []
    for index, before in enumerate(ledger):
        if before["status"] != "FAILED":
            continue
        source = ROOT / before["source"]
        if digest(source) != before["sourceHash"]:
            raise ValueError("Source changed before retry")
        after = process(source, directory, args.classes)
        changes.append({"before": before, "after": after})
        ledger[index] = dict(after, initialFailure=before["reason"])
        if after["status"] == "ACCEPTED":
            shutil.copy2(directory / "records" / (after["id"] + ".json"),
                         args.data / "records" / (after["id"] + ".json"))
    seen = set()
    for row in ledger:
        if row["status"] == "ACCEPTED":
            metadata = row["metadata"]
            identity = row["group"], metadata["studentAstHash"], metadata["oracleAstHash"]
            if identity in seen:
                row.update(status="EXCLUDED", reason="DUPLICATE_AST_PAIR")
            seen.add(identity)
    write(directory / "receipt.json", {"changes": changes, "seconds": time.monotonic()-started,
          "initialLedgerHash": digest(directory / "initial-ledger.json"),
          "collectorHash": digest(Path(__file__).with_name("corpus.py")),
          "retryHash": digest(__file__)})
    write(ledger_path, ledger)
    summary = json.loads((args.data / "summary.json").read_text())
    summary.update(accepted=collections.Counter(r["split"] for r in ledger if r["status"] == "ACCEPTED"),
                   exclusions=collections.Counter(r.get("reason", "").split(":")[0]
                       for r in ledger if r["status"] != "ACCEPTED"),
                   retried=len(changes), retrySeconds=time.monotonic()-started)
    write(args.data / "summary.json", summary)
    print(json.dumps(summary), flush=True)


if __name__ == "__main__":
    main()
