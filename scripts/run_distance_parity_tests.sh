#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/acgn-distance-parity.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT
lean docs/distance-parity-20261107/IncidentLaws.lean
lean docs/distance-parity-20261107/UnionMinimum.lean
lean docs/distance-parity-20261107/SingletonComposition.lean
lean docs/distance-parity-20261107/FlatExposure.lean
lean docs/distance-parity-20261107/AugmentedPrelude.lean
lean docs/distance-parity-20261107/MatrixReplay.lean
lean docs/distance-parity-20261107/DeclarationReplay.lean
lean docs/distance-parity-20261107/TemporalReplay.lean
lean docs/distance-parity-20261107/LocalDomainOperand.lean
lean docs/distance-parity-20261107/IncidentReplay.lean
lean docs/distance-parity-20261107/DiagnosticScanMode.lean
lean docs/distance-parity-20261107/GuardedJoinRotation.lean
lean docs/distance-parity-20261107/ShorterReplayBoundary.lean
lean docs/distance-parity-20261107/ClosedTemporalPhase.lean
lean docs/distance-parity-20261107/FastProductGeometry.lean
for contract in DependentChainSequence DependentJoinGuard PhaseA2DependentChains GuardedJoinChain; do
    LEAN_PATH="$BUILD_DIR" lean -o "$BUILD_DIR/$contract.olean" \
        "docs/section3-repair-audit/formal/$contract.lean"
done
LEAN_PATH="$BUILD_DIR" lean docs/distance-parity-20261107/FastChainGeometry.lean
mapfile -t sources < <(rg --files src -g '*.java' | sort)
javac -J-Xmx512m --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$BUILD_DIR" "${sources[@]}"
for test in BatchParityGateTest AugmentedPreludeTest theory.FlatOperandExposureTest theory.GuardedJoinRotationTest PartialJoinCompositionTest metric.RepairProjectionPermutationTest metric.MatrixReplayTest metric.TemporalReplayTest metric.PhaseReplayTest NativePhaseReplayTest LocalDomainSingletonTest FastChainGeometryTest P06ShorterReplayTest ProductShorterReplayTest FastProductGeometryTest core.ClosedTemporalPhaseTest DistanceReplayDiagnosticsTest FirstIncidentReplayTest CertifiedSingletonCompositionTest FastResultTypeCostTest FastRewriteParityTest EGraphSaturationTest metric.QuotientRepairDistanceTest CanonicalAlloyPipelineTest; do
    java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
        -cp "$BUILD_DIR:$ROOT/lib/*" "is.fivefivefive.CanDis.$test"
done
python3 -B scripts/test_batch_parity_stop.py --classpath "$BUILD_DIR:$ROOT/lib/*" \
    --output "$BUILD_DIR/parity-stop-cli"
python3 -B scripts/test_diagnostic_parity_scan.py --classpath "$BUILD_DIR:$ROOT/lib/*" \
    --output "$BUILD_DIR/diagnostic-stop-cli"
python3 -B scripts/test_distance_replay_diagnostics.py --classpath "$BUILD_DIR:$ROOT/lib/*" \
    --output "$BUILD_DIR/replay-cli"
python3 -B -m unittest discover -s scripts -p test_classify_distance_mismatches.py
python3 -B -m unittest discover -s scripts -p test_v3_release_gates.py
