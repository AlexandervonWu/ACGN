#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
BUILD_DIR="$(mktemp -d /tmp/acgn-fast-parity.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT
lean -o "$BUILD_DIR/PhaseA2DependentChains.olean" docs/section3-repair-audit/formal/PhaseA2DependentChains.lean
LEAN_PATH="$BUILD_DIR${LEAN_PATH:+:$LEAN_PATH}" lean docs/fast-rewrite-parity/Model.lean
mapfile -t sources < <(rg --files src -g '*.java' | sort)
javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$BUILD_DIR" "${sources[@]}"
for test in FastRewriteParityTest EGraphSaturationTest theory.TheoryDependentChainTest CanonicalAlloyPipelineTest; do
    java -Xmx2g -cp "$BUILD_DIR:$ROOT/lib/*" "is.fivefivefive.CanDis.$test"
done
