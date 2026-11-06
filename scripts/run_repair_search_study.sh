#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
OUT=${1:?Pass a new absolute output directory}
PYTHON=${ACGN_RL_PYTHON:-"$HOME/.venvs/acgn-rl-cu132-py312/bin/python"}
TRAIN_PYTHON=/home/augustus/AIx/.venv-finetune/bin/python
[[ "$OUT" = /* && ! -e "$OUT" ]] || { printf '%s\n' 'Use a new absolute output directory' >&2; exit 2; }
mkdir -p "$OUT/classes"
cd "$ROOT"
export PYTHONDONTWRITEBYTECODE=1 PYTHONPATH="$ROOT/rl" OMP_NUM_THREADS=1
lean -o "$OUT/SearchLearning.olean" docs/repair-search/formal/SearchLearning.lean
find src -name '*.java' -print0 | xargs -0 javac --release 17 -encoding UTF-8 -cp 'lib/*' -d "$OUT/classes"
ACGN_RL_CLASSES="$OUT/classes" "$PYTHON" -m unittest discover -s rl/tests -p test_search_study.py -v
"$PYTHON" -m acgn_repair.search_study --method policy --classes "$OUT/classes" --output "$OUT/policy"
"$PYTHON" -m acgn_repair.search_study --method tar --classes "$OUT/classes" --output "$OUT/tar"
"$PYTHON" -m acgn_repair.language_study --mode prepare --classes "$OUT/classes" --output "$OUT/data"
"$PYTHON" -m acgn_repair.language_study --mode evaluate --classes "$OUT/classes" --output "$OUT/base"
for mode in sft ce; do
  "$TRAIN_PYTHON" scripts/train_repair_lora.py --dataset "$OUT/data/$mode.jsonl" --output "$OUT/$mode-adapter"
  TAG="acgn-repair-$(basename "$OUT")-$mode:pilot"
  "$PYTHON" -m acgn_repair.language_study --mode export --output "$OUT/$mode-adapter" --model "$TAG"
  "$PYTHON" -m acgn_repair.language_study --mode evaluate --classes "$OUT/classes" --output "$OUT/$mode" --model "$TAG"
done
"$PYTHON" -m acgn_repair.report_search "$OUT"
