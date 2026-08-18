#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
RESULTS=${1:-"$ROOT/distance_results"}
export MPLCONFIGDIR=${MPLCONFIGDIR:-/tmp/candis-matplotlib}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-/tmp/candis-xdg-cache}
mkdir -p "$MPLCONFIGDIR"
mkdir -p "$XDG_CACHE_HOME"

python3 "$ROOT/distance_results/visualize_rewards.py" \
  "$RESULTS/distances.json" "$RESULTS"
python3 "$ROOT/scripts/generate_distance_paper_tables.py" \
  "$RESULTS/summary.md" "$RESULTS/paper_tables.md"
