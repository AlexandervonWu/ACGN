#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/acgn-distance-parity.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT
lean docs/distance-parity-20261107/IncidentLaws.lean
lean docs/distance-parity-20261107/UnionMinimum.lean
mapfile -t sources < <(rg --files src -g '*.java' | sort)
javac -J-Xmx512m --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$BUILD_DIR" "${sources[@]}"
for test in FastResultTypeCostTest FastRewriteParityTest EGraphSaturationTest metric.QuotientRepairDistanceTest CanonicalAlloyPipelineTest; do
    java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
        -cp "$BUILD_DIR:$ROOT/lib/*" "is.fivefivefive.CanDis.$test"
done
