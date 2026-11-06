#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
OUT=${1:?Supply a fresh absolute output directory}
ATTEMPTS=${2:-4096}
EPOCHS=${3:-8}
PYTHON=${ACGN_RL_PYTHON:-"$HOME/.venvs/acgn-rl-cu130/bin/python"}
[[ "$OUT" = /* && ! -e "$OUT" ]] || { printf '%s\n' 'Use a fresh absolute output directory' >&2; exit 2; }
mkdir -p "$OUT/classes"
cd "$ROOT"
export PYTHONDONTWRITEBYTECODE=1 OMP_NUM_THREADS=1
lean -o "$OUT/GraphRepair.olean" docs/canonical-edit-learning/formal/GraphRepair.lean
find src -name '*.java' -print0 | xargs -0 javac --release 17 -encoding UTF-8 -cp 'lib/*' -d "$OUT/classes"
ACGN_RL_CLASSES="$OUT/classes" "$PYTHON" -m unittest experiments.graph_repair.test_graph -v
"$PYTHON" -m experiments.graph_repair.collect --output "$OUT/exports" \
  --classpath "$OUT/classes:lib/*" --attempts "$ATTEMPTS" --workers 12 --per-question 200
"$PYTHON" -m experiments.graph_repair.repack --source "$OUT/exports" --output "$OUT/data"
"$PYTHON" -m experiments.graph_repair.audit --data "$OUT/data" --output "$OUT/data-audit.json"
"$PYTHON" -m experiments.graph_repair.train --data "$OUT/data" --output "$OUT/model" \
  --epochs "$EPOCHS" --effective-batch 128 --microbatch 8 --decode-batch 8 --lr 0.0001
"$PYTHON" -m experiments.graph_repair.diagnose --run "$OUT/model" --data "$OUT/data"
"$PYTHON" -m experiments.graph_repair.report --run "$OUT/model" --data "$OUT/data" --output "$OUT/report"
