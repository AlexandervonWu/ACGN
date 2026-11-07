#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
lean docs/slot-typing-ablation/Model.lean
lean docs/slot-typing-ablation/TypedPass.lean
lean docs/slot-typing-ablation/PartitionedPermutation.lean
lean docs/slot-typing-ablation/IndependentBindingBlocks.lean
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/acgn-slot-tests.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT
mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$BUILD_DIR" "${sources[@]}"
java -Xmx2g -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.ablation.SlotTypingAblationTest
java -Xmx2g -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.egraph.SlotPermutationSearchTest
java -Xmx2g -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.egraph.SlotBindingBlocksTest
timeout 120s java -Dorg.slf4j.simpleLogger.defaultLogLevel=warn -Xmx2g -cp "$BUILD_DIR:$ROOT/lib/*" \
  is.fivefivefive.CanDis.core.egraph.SlotRewriteOrderTest "$ROOT"
java -Xmx2g -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.ablation.EGraphAblationTest
