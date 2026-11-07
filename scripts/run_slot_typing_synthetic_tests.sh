#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
lean docs/slot-typing-ablation/TimedOutcome.lean
python3 -m unittest discover -s scripts -p test_slot_typing_synthetic.py
BUILD="$(mktemp -d "${TMPDIR:-/tmp}/acgn-synthetic-tests.XXXXXX")"
trap 'rm -rf "$BUILD"' EXIT
mapfile -t sources < <(find src -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -cp 'lib/*' -d "$BUILD" "${sources[@]}"
java -ea -Xmx2g -cp "$BUILD:lib/*" is.fivefivefive.CanDis.ablation.SlotTypingSyntheticTest
java -ea -Xmx2g -cp "$BUILD:lib/*" is.fivefivefive.CanDis.ablation.SlotTypingAblationTest
java -ea -Xmx2g -cp "$BUILD:lib/*" is.fivefivefive.CanDis.ablation.EGraphAblationTest
