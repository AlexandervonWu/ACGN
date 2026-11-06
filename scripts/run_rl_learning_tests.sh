#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
PYTHON=${ACGN_RL_PYTHON:-"$HOME/.venvs/acgn-rl-cu132-py312/bin/python"}
export PYTHONDONTWRITEBYTECODE=1
export PYTHONPATH="$ROOT/rl${PYTHONPATH:+:$PYTHONPATH}"
exec "$PYTHON" "$ROOT/scripts/verify_rl_learning.py" "$@"
