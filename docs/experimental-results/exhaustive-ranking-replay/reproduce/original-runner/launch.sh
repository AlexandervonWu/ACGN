#!/usr/bin/env bash
set -euo pipefail
root=$(realpath "$(dirname "$0")/..")
unit="acgn-all-ranking-${root##*-}"
cd "$root"
if [[ -e producer-complete.json ]]; then echo "Producer records complete"; exit 0; fi
if systemctl --user is-active --quiet "$unit.service"; then echo "Already active: $unit"; exit 0; fi
if systemctl --user show "$unit.service" --property=LoadState --value | grep -qx loaded; then
    systemctl --user start "$unit.service"
else
    systemd-run --user --unit "$unit" --service-type=exec -p Restart=on-failure -p RestartSec=15         -p OOMPolicy=continue -p MemoryHigh=17G -p MemoryMax=20G -p TasksMax=1600 -p Nice=8         -p KillMode=control-group -p TimeoutStopSec=25 -p WorkingDirectory="$root"         --setenv=PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 -B "$root/runner/supervise.py"
fi
systemctl --user show "$unit.service" --property=InvocationID,ExecMainStartTimestamp,ActiveState
