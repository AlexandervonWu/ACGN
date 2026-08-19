#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
RESULTS=${1:-"$ROOT/distance_results"}
OUTPUT=${2:-"${TMPDIR:-/tmp}/acgn-distance-paper-artifacts"}
export MPLCONFIGDIR=${MPLCONFIGDIR:-/tmp/candis-matplotlib}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-/tmp/candis-xdg-cache}
mkdir -p "$MPLCONFIGDIR"
mkdir -p "$XDG_CACHE_HOME"

results_real="$(realpath -m "$RESULTS")"
output_real="$(realpath -m "$OUTPUT")"
for protected in \
  "$ROOT/distance_results" \
  "$ROOT/alloy4fun-augmented" \
  "$ROOT/egraph_ablation" \
  "$ROOT/capability_benchmark"; do
  protected_real="$(realpath -m "$protected")"
  if [[ "$output_real" == "$protected_real" \
      || "$output_real" == "$protected_real"/* ]]; then
    printf 'derived output must be outside manifest-bound result trees: %s\n' \
      "$output_real" >&2
    exit 1
  fi
done
mkdir -p "$output_real"

if [[ ! -f "$results_real/summary.md" ]]; then
  printf 'distance summary is missing: %s\n' "$results_real/summary.md" >&2
  exit 1
fi

python3 "$ROOT/scripts/generate_distance_paper_tables.py" \
  "$results_real/summary.md" "$output_real/paper_tables.md"

if [[ -f "$results_real/visualize_rewards.py" \
    && -f "$results_real/distances.json" ]]; then
  python3 "$results_real/visualize_rewards.py" \
    "$results_real/distances.json" "$output_real"
else
  printf 'Reward plots skipped: this snapshot has no reward plotting inputs.\n'
fi

printf 'Derived distance artifacts written outside the frozen snapshot: %s\n' \
  "$output_real"
