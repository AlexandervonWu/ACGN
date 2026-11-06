#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ $# != 8 ]]; then
  echo "Usage: $0 INPUT TARGET COMMAND_INDEX FORBIDDEN_NAME_OR_DASH BEAM_OR_RANDOM SEED ATTEMPTS NEW_OUTPUT_JSON" >&2
  exit 2
fi
SECONDS_LIMIT=${REPAIR_TIMEOUT_SECONDS:-120}
if [[ ! "$SECONDS_LIMIT" =~ ^[1-9][0-9]*$ ]]; then
  echo "REPAIR_TIMEOUT_SECONDS must be a positive integer" >&2
  exit 2
fi
WORK=$(mktemp -d "${TMPDIR:-/tmp}/acgn-repair-explorer.XXXXXXXX")
trap 'rm -rf -- "$WORK"' EXIT
lean -o "$WORK/RepairKernel.olean" "$ROOT/docs/rl-repair/formal/RepairKernel.lean"
mkdir "$WORK/classes"
find "$ROOT/src" -name '*.java' -print0 |
  xargs -0 javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$WORK/classes"
timeout --kill-after=5s "${SECONDS_LIMIT}s" java -ea -Xmx2g \
  -cp "$WORK/classes:$ROOT/lib/*" is.fivefivefive.ACGN.repair.RepairExplorer "$@"
