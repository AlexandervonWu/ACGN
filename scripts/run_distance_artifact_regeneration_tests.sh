#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -gt 0 ]]; then
  work="$1"
  mkdir -p "$work"
else
  work="$(mktemp -d /tmp/acgn-distance-artifacts.XXXXXX)"
  trap 'rm -rf "$work"' EXIT
fi

before_snapshot_status="$(git -C "$ROOT" status --porcelain=v1 \
  --untracked-files=all -- \
  distance_results alloy4fun-augmented egraph_ablation capability_benchmark)"
"$ROOT/scripts/regenerate_distance_artifacts.sh" \
  "$ROOT/distance_results" "$work"

mapfile -t generated < <(
  find "$work" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' | sort
)
expected=(paper_metrics.json paper_tables.md)
if [[ "${generated[*]}" != "${expected[*]}" ]]; then
  printf 'unexpected derived distance artifacts: %s\n' "${generated[*]}" >&2
  exit 1
fi

python3 - "$work/paper_metrics.json" "$work/paper_tables.md" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
metrics = payload["metrics"]
expected = {
    "Average Certificate-Integrated IR repair distance": "14.021251",
    "Average Fast Rewrite IR distance": "13.938342",
    "Average canonical representative TED baseline": "32.254732",
}
for key, value in expected.items():
    actual = metrics.get(key)
    if actual != value:
        raise SystemExit(f"{key}: expected {value}, got {actual}")
correlations = payload["rewardCorrelations"]
expected_correlations = {
    "Pearson correlation, Certificate-Integrated IR distance vs candidate reward": "-0.063929",
    "Pearson correlation, canonical representative TED vs candidate reward": "-0.059816",
    "Pearson correlation, Fast Rewrite IR distance vs candidate reward": "-0.061337",
    "Pearson correlation, Levenshtein vs candidate reward": "-0.090795",
    "Pearson correlation, raw AST tree distance vs candidate reward": "-0.081877",
    "Pearson correlation, normalized raw AST distance vs candidate reward": "-0.053464",
    "Pearson correlation, normalized Certificate-Integrated IR distance vs candidate reward": "-0.080382",
    "Pearson correlation, normalized canonical representative TED vs candidate reward": "-0.092118",
    "Pearson correlation, normalized Fast Rewrite IR distance vs candidate reward": "-0.062626",
}
if not correlations["available"] or not correlations["rewardsEnabled"]:
    raise SystemExit("rewarded snapshot correlations were marked unavailable")
if correlations["rewardedFiles"] != 61598 or correlations["sampleSize"] != 42386:
    raise SystemExit("rewarded snapshot sample metadata differs")
if correlations["values"] != expected_correlations:
    raise SystemExit("rewarded snapshot correlations differ")
for key, value in expected_correlations.items():
    if metrics.get(key) != value:
        raise SystemExit(f"rewarded snapshot metric {key}: expected {value}")

lines = Path(sys.argv[2]).read_text(encoding="utf-8").splitlines()
targets = {"Avg reward", "Corr(distance,reward)"}
found = set()
data_rows = None
index = 0
while index < len(lines):
    if not lines[index].startswith("|"):
        index += 1
        continue
    block = []
    while index < len(lines) and lines[index].startswith("|"):
        block.append(lines[index])
        index += 1
    headers = [cell.strip() for cell in block[0].strip("|").split("|")]
    columns = [i for i, header in enumerate(headers) if header in targets]
    if not columns:
        continue
    found.update(headers[i] for i in columns)
    data_rows = len(block) - 2
    for row in block[2:]:
        cells = [cell.strip() for cell in row.strip("|").split("|")]
        for column in columns:
            if cells[column] == "N/A":
                raise SystemExit(
                    f"available {headers[column]} cell is unexpectedly N/A")
if found != targets:
    raise SystemExit(f"did not locate unavailable reward columns: {found!r}")
if data_rows != 68:
    raise SystemExit(f"expected 68 unavailable reward rows, got {data_rows}")
PY

if ! grep -Fq \
  '| Pearson correlation, Certificate-Integrated IR distance vs candidate reward | -0.063929 |' \
  "$work/paper_tables.md"; then
  printf 'rewarded Markdown does not expose the bound correlation\n' >&2
  exit 1
fi

synthetic="$work/synthetic-rewarded"
mkdir -p "$synthetic"
python3 "$ROOT/scripts/generate_distance_paper_tables.py" \
  "$ROOT/scripts/testdata/rewarded-summary-v11.md" \
  "$synthetic/paper_tables.md"
python3 - "$synthetic/paper_metrics.json" "$synthetic/paper_tables.md" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
correlations = payload["rewardCorrelations"]
expected = {
    "Pearson correlation, Certificate-Integrated IR distance vs candidate reward": "0.010001",
    "Pearson correlation, canonical representative TED vs candidate reward": "0.020002",
    "Pearson correlation, Fast Rewrite IR distance vs candidate reward": "0.030003",
    "Pearson correlation, Levenshtein vs candidate reward": "0.040004",
    "Pearson correlation, raw AST tree distance vs candidate reward": "0.050005",
    "Pearson correlation, normalized raw AST distance vs candidate reward": "0.060006",
    "Pearson correlation, normalized Certificate-Integrated IR distance vs candidate reward": "0.070007",
    "Pearson correlation, normalized canonical representative TED vs candidate reward": "0.080008",
    "Pearson correlation, normalized Fast Rewrite IR distance vs candidate reward": "0.090009",
}
if not correlations["available"]:
    raise SystemExit("synthetic rewarded correlations were marked unavailable")
if correlations["values"] != expected:
    raise SystemExit(
        f"synthetic rewarded correlations differ: {correlations['values']!r}")
for key, value in expected.items():
    if payload["metrics"].get(key) != value:
        raise SystemExit(f"rewarded metric {key}: expected {value}")

lines = Path(sys.argv[2]).read_text(encoding="utf-8").splitlines()
expected_cells = {
    "Avg reward": "0.812345",
    "Corr(distance,reward)": "-0.456789",
    "Unrelated zero": "0.000000",
}
found = False
for index, line in enumerate(lines):
    if not line.startswith("| Problem class | Status | Avg reward |"):
        continue
    headers = [cell.strip() for cell in line.strip("|").split("|")]
    cells = [
        cell.strip()
        for cell in lines[index + 2].strip("|").split("|")
    ]
    row = dict(zip(headers, cells))
    for key, value in expected_cells.items():
        if row.get(key) != value:
            raise SystemExit(
                f"rewarded table {key}: expected {value}, got {row.get(key)}")
    found = True
    break
if not found:
    raise SystemExit("synthetic rewarded table was not copied")
PY

after_snapshot_status="$(git -C "$ROOT" status --porcelain=v1 \
  --untracked-files=all -- \
  distance_results alloy4fun-augmented egraph_ablation capability_benchmark)"
if [[ "$after_snapshot_status" != "$before_snapshot_status" ]]; then
  printf 'distance regeneration changed a manifest-bound result tree\n' >&2
  diff <(printf '%s\n' "$before_snapshot_status") \
    <(printf '%s\n' "$after_snapshot_status") >&2 || true
  exit 1
fi
printf 'distance artifact regeneration smoke passed; output=%s\n' "$work"
