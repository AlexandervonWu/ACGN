#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
# Check the sealed pair inventory and structural baseline before replaying current code.
python3 docs/experimental-results/2026-11-25/verify.py
javac --release 17 -proc:none -encoding UTF-8 -sourcepath src -cp 'lib/*' -d "$tmp" \
    scripts/proven-rules/tests/DefaultPoolReplay.java
java -ea -Xmx1g -XX:ActiveProcessorCount=2 -Dorg.slf4j.simpleLogger.defaultLogLevel=warn \
    -cp "$tmp:lib/*" is.fivefivefive.CanDis.augmentation.DefaultPoolReplay
