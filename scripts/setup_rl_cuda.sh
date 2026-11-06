#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
VENV=${ACGN_RL_VENV:-"$HOME/.venvs/acgn-rl-cu132-py312"}
PYTHON=${ACGN_RL_BASE_PYTHON:-python3.12}
"$PYTHON" -c 'import sys; assert sys.version_info >= (3, 12), "Python >=3.12 is required"'
if [[ ! -x "$VENV/bin/python" ]]; then
  "$PYTHON" -m venv --without-pip "$VENV"
fi
if ! "$VENV/bin/python" -m pip --version >/dev/null 2>&1; then
  python3 -m pip --python "$VENV/bin/python" install pip
fi
"$VENV/bin/python" -m pip install --upgrade pip
"$VENV/bin/python" -m pip install -r "$ROOT/rl/requirements-cuda.txt"
"$VENV/bin/python" -c 'import torch; assert torch.cuda.is_available(); x=torch.randn(64,64,device="cuda",requires_grad=True); x.square().mean().backward(); torch.cuda.synchronize(); print(torch.__version__, torch.version.cuda, torch.cuda.get_device_name(0), float(x.grad.norm()))'
