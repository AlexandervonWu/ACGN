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
