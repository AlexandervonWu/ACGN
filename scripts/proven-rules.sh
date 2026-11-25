#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
bash "$root/scripts/proven-rules/build.sh" "$tmp/classes"
java -ea -Xmx512m -Dorg.slf4j.simpleLogger.defaultLogLevel=warn -cp "$tmp/classes:$root/lib/*" \
    is.fivefivefive.CanDis.augmentation.ProvenRulesCommand "$@"
