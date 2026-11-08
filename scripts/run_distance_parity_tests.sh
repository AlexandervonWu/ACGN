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
lean docs/distance-parity-20261107/TemporalOccurrenceAccounting.lean
lean docs/distance-parity-20261107/InjectiveVariableFallback.lean
lean docs/distance-parity-20261107/PaidDeclarationAlignment.lean
lean docs/distance-parity-20261107/MixedPaidDeclarationAlignment.lean
lean docs/distance-parity-20261107/LocalPaidDeclarationAlignment.lean
lean docs/distance-parity-20261107/LonePaidDeclarationAlignment.lean
lean docs/distance-parity-20261107/GroupedPaidDeclarationAlignment.lean
lean docs/distance-parity-20261107/CertifiedDeclarationOrbit.lean
lean docs/distance-parity-20261107/OnePaidDeclarationAlignment.lean
lean docs/distance-parity-20261107/BoundVariableCorrespondence.lean
lean docs/distance-parity-20261107/NestedPaidDeclaration.lean
lean docs/distance-parity-20261107/ScopedPaidAdmission.lean
lean docs/distance-parity-20261107/JointDeclarationMatrixReplay.lean
lean docs/distance-parity-20261107/UnobservedDeclarationCompletion.lean
lean docs/distance-parity-20261107/RetainedScopePaidCompletion.lean
lean docs/distance-parity-20261107/NativeOperationGate.lean
lean docs/distance-parity-20261107/ScopeBlockTieOrder.lean
lean docs/distance-parity-20261107/RetainedExistentialAdmission.lean
lean docs/distance-parity-20261107/RetainedPaidCandidateUnion.lean
lean docs/distance-parity-20261107/GroupedPaidOrbit.lean
lean docs/distance-parity-20261107/SeparatePrefixExchange.lean
lean docs/distance-parity-20261107/MixedRetainedAdmission.lean
lean docs/distance-parity-20261107/CertifiedSetEncounterOrder.lean
lean docs/distance-parity-20261107/GuardedJoinSourceFiber.lean
lean docs/distance-parity-20261107/DisjointPaidDeclarationAlignment.lean
lean docs/distance-parity-20261107/EmptyBindingEvidence.lean
for contract in DependentChainSequence DependentJoinGuard PhaseA2DependentChains GuardedJoinChain; do
    LEAN_PATH="$BUILD_DIR" lean -o "$BUILD_DIR/$contract.olean" \
        "docs/section3-repair-audit/formal/$contract.lean"
done
LEAN_PATH="$BUILD_DIR" lean docs/distance-parity-20261107/FastChainGeometry.lean
mapfile -t sources < <(rg --files src -g '*.java' | sort)
javac -J-Xmx512m --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$BUILD_DIR" "${sources[@]}"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.RetainedPaidCompletionTest
for test in BatchParityGateTest AugmentedPreludeTest theory.FlatOperandExposureTest theory.GuardedJoinRotationTest PartialJoinCompositionTest metric.RepairProjectionPermutationTest metric.MatrixReplayTest metric.TemporalReplayTest metric.PhaseReplayTest NativePhaseReplayTest LocalDomainSingletonTest FastChainGeometryTest P06ShorterReplayTest ProductShorterReplayTest FastProductGeometryTest core.ScopedTemporalShorterReplayTest core.TemporalOccurrenceAccountingTest core.InjectiveVariableFallbackTest core.InjectiveVariableReplayTest PaidDeclarationShorterReplayTest core.FastPaidDeclarationAlignmentTest core.ClosedTemporalPhaseTest DistanceReplayDiagnosticsTest FirstIncidentReplayTest CertifiedSingletonCompositionTest FastResultTypeCostTest FastRewriteParityTest EGraphSaturationTest metric.QuotientRepairDistanceTest CanonicalAlloyPipelineTest; do
    java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
        -cp "$BUILD_DIR:$ROOT/lib/*" "is.fivefivefive.CanDis.$test"
done
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.MixedPaidDeclarationShorterReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.FastLocalPaidScopeTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.LocalPaidDeclarationShorterReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.LonePaidDeclarationAlignmentTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.LonePaidDeclarationShorterReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.GroupedPaidDeclarationAlignmentTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.GroupedPaidDeclarationShorterReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.metric.CertifiedDeclarationOrbitTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.DeclarationOrbitSourceTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.DeclarationOrbitShorterReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.OnePaidDeclarationAlignmentTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.OnePaidDeclarationShorterReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.BoundVariableCostTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.BoundVariableShorterReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.FastNestedPaidScopeTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.NestedPaidDeclarationReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.ScopedPaidAdmissionTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.ScopedPaidAdmissionReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.JointDeclarationTieReplayTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.UnusedDeclarationCompletionTest
python3 -B scripts/test_batch_parity_stop.py --classpath "$BUILD_DIR:$ROOT/lib/*" \
    --output "$BUILD_DIR/parity-stop-cli"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.NativeOperationComparisonTest "$BUILD_DIR/native-operation-comparison"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.NativeOperationGateTest "$BUILD_DIR/native-operation-gate"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.ScopeBlockTieReplayTest "$BUILD_DIR/scope-block-tie"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.core.RetainedExistentialAdmissionTest
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.RetainedExistentialReplayTest "$BUILD_DIR/retained-existential"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.RetainedPaidCandidateReplayTest "$BUILD_DIR/retained-paid-candidate"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.GroupedPaidOrbitReplayTest "$BUILD_DIR/grouped-paid-orbit"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.SeparatePrefixOrbitReplayTest "$BUILD_DIR/separate-prefix-orbit"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.MixedRetainedAdmissionReplayTest "$BUILD_DIR/mixed-retained"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.CertifiedSetEncounterOrderReplayTest "$BUILD_DIR/set-encounter"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.GuardedJoinOccurrenceReplayTest "$BUILD_DIR/join-occurrence"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.DisjointPaidDeclarationReplayTest "$BUILD_DIR/disjoint-paid"
java -Xmx1g -XX:+ExitOnOutOfMemoryError -Djava.io.tmpdir="$BUILD_DIR" \
    -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.EmptyBindingEvidenceReplayTest "$BUILD_DIR/empty-binding"
python3 -B scripts/test_native_operation_scan.py --classpath "$BUILD_DIR:$ROOT/lib/*" \
    --output "$BUILD_DIR/native-operation-cli"
python3 -B scripts/test_diagnostic_parity_scan.py --classpath "$BUILD_DIR:$ROOT/lib/*" \
    --output "$BUILD_DIR/diagnostic-stop-cli"
python3 -B scripts/test_distance_replay_diagnostics.py --classpath "$BUILD_DIR:$ROOT/lib/*" \
    --output "$BUILD_DIR/replay-cli"
python3 -B -m unittest discover -s scripts -p test_classify_distance_mismatches.py
python3 -B -m unittest discover -s scripts -p test_v3_release_gates.py
