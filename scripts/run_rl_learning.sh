#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
PYTHON=${ACGN_RL_PYTHON:-"$HOME/.venvs/acgn-rl-cu130/bin/python"}
WORK=$(mktemp -d "${TMPDIR:-/tmp}/acgn-rl-learning-build.XXXXXXXX")
trap 'rm -rf -- "$WORK"' EXIT
lean -o "$WORK/RepairKernel.olean" "$ROOT/docs/rl-repair/formal/RepairKernel.lean"
lean -o "$WORK/FeedbackLearning.olean" "$ROOT/docs/rl-repair/formal/FeedbackLearning.lean"
lean -o "$WORK/GraphEncoders.olean" "$ROOT/docs/rl-repair/formal/GraphEncoders.lean"
lean -o "$WORK/TuningProtocol.olean" "$ROOT/docs/rl-repair/formal/TuningProtocol.lean"
lean -o "$WORK/PolicyCapacity.olean" "$ROOT/docs/rl-repair/formal/PolicyCapacity.lean"
lean -o "$WORK/ResourceBudget.olean" "$ROOT/docs/rl-repair/formal/ResourceBudget.lean"
lean -o "$WORK/EGraph2Graph.olean" "$ROOT/docs/rl-repair/formal/EGraph2Graph.lean"
lean -o "$WORK/CorpusProtocol.olean" "$ROOT/docs/rl-repair/formal/CorpusProtocol.lean"
mkdir "$WORK/classes"
find "$ROOT/src" -name '*.java' -print0 |
  xargs -0 javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$WORK/classes"
export PYTHONDONTWRITEBYTECODE=1
export PYTHONPATH="$ROOT/rl${PYTHONPATH:+:$PYTHONPATH}"
MODULE=acgn_repair.experiment
if [[ "${1:-}" == "--compare-encoders" ]]; then
  MODULE=acgn_repair.compare_encoders
  shift
elif [[ "${1:-}" == "--tune-depth" ]]; then
  MODULE=acgn_repair.tune_depth
  shift
fi
"$PYTHON" -m "$MODULE" --classes "$WORK/classes" "$@"
