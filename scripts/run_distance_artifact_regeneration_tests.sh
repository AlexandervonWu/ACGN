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

python3 - "$work/paper_metrics.json" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
metrics = payload["metrics"]
expected = {
    "Average Certificate-Integrated IR repair distance": "14.042096",
    "Average Fast Rewrite IR distance": "14.029027",
    "Average canonical representative TED baseline": "37.119533",
}
for key, value in expected.items():
    actual = metrics.get(key)
    if actual != value:
        raise SystemExit(f"{key}: expected {value}, got {actual}")
correlations = payload["rewardCorrelations"]
if correlations["available"]:
    raise SystemExit("reward-disabled snapshot exposed measured correlations")
if correlations["rewardsEnabled"] or correlations["rewardedFiles"] != 0:
    raise SystemExit("reward-disabled snapshot metadata was parsed incorrectly")
if correlations["sampleSize"] != 0 or correlations["values"]:
    raise SystemExit("zero-sample snapshot retained correlation values")
if any(key.startswith("Pearson correlation,") for key in metrics):
    raise SystemExit("reward-disabled metrics retained false measured correlations")
PY

if ! grep -Fq \
  'Reward correlations are unavailable because rewards were disabled and the Pearson correlation sample size is zero files.' \
  "$work/paper_tables.md"; then
  printf 'reward-disabled Markdown does not explain correlation availability\n' >&2
  exit 1
fi

synthetic="$work/synthetic-rewarded"
mkdir -p "$synthetic"
python3 "$ROOT/scripts/generate_distance_paper_tables.py" \
  "$ROOT/scripts/testdata/rewarded-summary-v11.md" \
  "$synthetic/paper_tables.md"
python3 - "$synthetic/paper_metrics.json" <<'PY'
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
