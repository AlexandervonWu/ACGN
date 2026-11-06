#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
lean docs/slot-typing-ablation/Model.lean
BUILD_DIR="$(mktemp -d /tmp/acgn-slot-tests.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT
mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$BUILD_DIR" "${sources[@]}"
java -Xmx2g -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.ablation.SlotTypingAblationTest
java -Xmx2g -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.ablation.EGraphAblationTest
