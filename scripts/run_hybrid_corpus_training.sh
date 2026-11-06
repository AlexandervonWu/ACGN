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
lean -o "$OUT/HybridRepair.olean" docs/canonical-edit-learning/formal/HybridRepair.lean
lean -o "$OUT/CorpusTraining.olean" docs/canonical-edit-learning/formal/CorpusTraining.lean
find src -name '*.java' -print0 | xargs -0 javac --release 17 -encoding UTF-8 -cp 'lib/*' -d "$OUT/classes"
ACGN_RL_CLASSES="$OUT/classes" "$PYTHON" -m unittest discover -s experiments/hybrid_edit -p 'test_*.py' -v
"$PYTHON" -m experiments.hybrid_edit.corpus --classes "$OUT/classes" --output "$OUT/data" \
  --max-attempts "$ATTEMPTS" --workers 16 --per-question 160
"$PYTHON" -m experiments.hybrid_edit.retry_corpus --classes "$OUT/classes" --data "$OUT/data"
"$PYTHON" -m experiments.hybrid_edit.train_corpus --data "$OUT/data" --output "$OUT/model" \
  --epochs "$EPOCHS" --effective-batch 128 --microbatch 8 --lr 0.00003 \
  --development-test-groups classroom_fol:inv8 trash_fol:inv10
"$PYTHON" -m experiments.hybrid_edit.report_corpus --data "$OUT/data" --run "$OUT/model"
