"""Compare the retained historical node census with the bounded pilot alphabet."""

import argparse
import csv
import hashlib
import io
import json
from pathlib import Path
import subprocess

from experiments.hybrid_edit.scope import ASSIGNED, PROFILE, REFERENCE_BANKS, TOKENS, VOCAB_SIZE


def historical_census(raw):
    rows = []
    for row in csv.reader(io.StringIO(raw.decode("utf-8"))):
        if len(row) != 2 or not row[0].isdigit() or not row[1]:
            raise ValueError("Expected historical id,symbol rows")
        rows.append({"id": int(row[0]), "symbol": row[1]})
    if len({r["id"] for r in rows}) != len(rows) or len({r["symbol"] for r in rows}) != len(rows):
        raise ValueError("Historical census contains ambiguous IDs or symbols")
    symbols = {r["symbol"] for r in rows}
    generic_banks = {"Dummy for sig": "signature", "Dummy for var": "slot", "Dummy for field": "relation"}
    if not generic_banks.keys() <= symbols:
        raise ValueError("Expected generic signature, variable and field entries")
    requested_constants = {"none", "univ", "iden", "true", "false", *(str(i) for i in range(5))}
    missing = sorted(requested_constants - symbols)
    collapsed = len(symbols | requested_constants)
    return {"historical_rows": rows, "historical_unique_symbols": len(symbols),
            "historical_csv_sha256": hashlib.sha256(raw).hexdigest(),
            "requested_missing_constants": missing,
            "historical_plus_requested_constants_collapsed": collapsed,
            "historical_semantic_only_expanded": collapsed + sum(
                REFERENCE_BANKS[bank][1] - 1 for bank in generic_banks.values()),
            "warning": "Historical observed symbols, not a complete Alloy inventory or transport alphabet"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--revision", default="edbae587^")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    commit = subprocess.check_output(["git", "rev-parse", "--verify", args.revision + "^{commit}"]).decode().strip()
    raw = subprocess.check_output(["git", "show", commit + ":node_id.csv"])
    report = historical_census(raw)
    report.update(source_commit=commit, source_path="node_id.csv", pilot_profile=PROFILE,
                  pilot_vocab_size=VOCAB_SIZE, pilot_assigned=len(ASSIGNED),
                  pilot_reserved=sorted(set(range(VOCAB_SIZE)) - ASSIGNED),
                  pilot_collapsed_to_existing_operator_tags=len(ASSIGNED) - sum(size for _, size in REFERENCE_BANKS.values()),
                  pilot_named_tokens=dict(sorted(TOKENS.items(), key=lambda item: item[1])),
                  numeric_digit_tokens=list(range(64, 80)),
                  correspondence="pilot alphabet is a scoped subset plus record tags, not a raw AST ID remap",
                  input_hashes={str(path): hashlib.sha256(path.read_bytes()).hexdigest()
                                for path in (Path(__file__).relative_to(Path.cwd()),
                                             Path("experiments/hybrid_edit/scope.py"),
                                             Path("docs/canonical-edit-learning/formal/HybridRepair.lean"))})
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({key: value for key, value in report.items()
                      if key not in {"historical_rows", "pilot_named_tokens", "input_hashes"}}, indent=2))


if __name__ == "__main__":
    main()
