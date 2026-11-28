#!/usr/bin/env bash
set -euo pipefail
root=$(realpath "$(dirname "$0")/..")
uuid=$(python3 -B -c 'import json,sys; print(json.load(open(sys.argv[1]))["candidateRunId"])' "$root/runner-identity.json")
unit="acgn-ranking-candidate-$uuid.service"
file="$root/$unit"
if [[ ! -f $file ]]; then
    cat > "$file" <<EOF
[Unit]
Description=ACGN paid ranking candidate replay $uuid
ConditionPathExists=!$root/producer-complete.json
[Service]
Type=exec
WorkingDirectory=$root
ExecStart=/usr/bin/python3 -B "$root/runner/supervise.py"
Restart=on-failure
RestartSec=15
TimeoutStopSec=25
KillMode=control-group
OOMPolicy=continue
MemoryHigh=17G
MemoryMax=20G
TasksMax=1600
Nice=8
[Install]
WantedBy=default.target
EOF
fi
systemctl --user link "$file"
systemctl --user daemon-reload
systemctl --user enable --now "$unit"
systemctl --user show "$unit" --property=ActiveState,SubState,InvocationID
