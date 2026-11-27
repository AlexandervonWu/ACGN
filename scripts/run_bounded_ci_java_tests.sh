#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/acgn-bounded-java-tests.XXXXXX")"
trap 'rm -rf "$work"' EXIT
classes="$work/classes"
mkdir -p "$classes"

mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" \
  -d "$classes" "${sources[@]}"
mapfile -t verifier_sources < <(find "$ROOT/certificate-verifier/src" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -d "$classes" "${verifier_sources[@]}"

python3 "$ROOT/scripts/proven-rules/tests/default_pipeline.py" "$classes"

printf 'Running %s\n' is.fivefivefive.CanDis.RewriteRuleTraceability
printf '%s\n' \
  'Traceability scope: catalog reference presence only; this gate does not establish Java-Lean refinement or exhaustive executable-branch coverage.'
java -Xmx1g -cp "$classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.RewriteRuleTraceability "$ROOT"
printf 'Running %s\n' is.fivefivefive.CanDis.RewriteRuleTraceabilityTest
java -Xmx1g -cp "$classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.RewriteRuleTraceabilityTest "$ROOT"

python3 "$ROOT/scripts/test_natural_slotted_coverage.py" "$classes"
python3 "$ROOT/scripts/test_natural_slotted_retention.py" "$classes"
python3 -B "$ROOT/scripts/test_historical_pair_coverage.py"
python3 -B "$ROOT/scripts/test_historical_rank_traces.py"

tests=(
  is.fivefivefive.CanDis.CapabilitySourceSchedulingTest
  is.fivefivefive.CanDis.UnusedBindingDescopeTest
  is.fivefivefive.CanDis.UnusedBindingD8Test
  is.fivefivefive.CanDis.core.UnusedBindingEvidenceTest
  is.fivefivefive.CanDis.PerformanceRegressionTest
  is.fivefivefive.CanDis.core.PreparedOrbitCacheTest
  is.fivefivefive.CanDis.PreparedMetadataConcurrencyTest
  is.fivefivefive.CanDis.PrefixBinderPlanTest
  is.fivefivefive.CanDis.core.FastPrefixSourceTest
  is.fivefivefive.CanDis.theory.CertificateVerificationScopeTest
  is.fivefivefive.CanDis.AstWrapperErasureTest
  is.fivefivefive.CanDis.DependencyCompatibilityTest
  is.fivefivefive.ACGN.learn.RewarderConcurrencyTest
  is.fivefivefive.CanDis.Section3AssuranceTraceabilityTest
  is.fivefivefive.CanDis.assurance.ContractDecompositionTest
  is.fivefivefive.CanDis.AssuranceTestExecutionCoverageTest
  is.fivefivefive.CanDis.RequiredPolicyCoverageTest
  is.fivefivefive.CanDis.CallExtractionRegressionTest
  is.fivefivefive.CanDis.ZeroArgumentCallRegressionTest
  is.fivefivefive.CanDis.OrderedCallValidationRegressionTest
  is.fivefivefive.CanDis.CallAuthorityTransitionsRegressionTest
  is.fivefivefive.CanDis.BuiltinIdentityRegressionTest
  is.fivefivefive.CanDis.theory.PolicyRepresentationRegressionTest
  is.fivefivefive.CanDis.theory.DependentJoinGuardRegressionTest
  is.fivefivefive.CanDis.theory.FlatRootPortRegressionTest
  is.fivefivefive.CanDis.theory.FlatTypeSubstitutionRegressionTest
  is.fivefivefive.CanDis.theory.DependentChainSequenceRegressionTest
  is.fivefivefive.CanDis.theory.GuardedJoinChainRegressionTest
  is.fivefivefive.CanDis.theory.RegistryAdmissionRegressionTest
  is.fivefivefive.CanDis.theory.ContainerWitnessTransitionsRegressionTest
  is.fivefivefive.CanDis.theory.DependentChainWitnessesRegressionTest
  is.fivefivefive.CanDis.theory.SemanticProfileWireRegressionTest
  is.fivefivefive.CanDis.theory.LawRecordWireRegressionTest
  is.fivefivefive.CanDis.theory.FlatContainerRecordsRegressionTest
  is.fivefivefive.CanDis.theory.CanonicalWireTablesRegressionTest
  is.fivefivefive.CanDis.theory.SourceOccurrenceBindingsRegressionTest
  is.fivefivefive.CanDis.CanonicalAlloyPipelineTest
  is.fivefivefive.CanDis.CanonicalBacktranslatorTest
  is.fivefivefive.CanDis.EGraphSaturationTest
  is.fivefivefive.CanDis.AlloySourceRuleRegressionTest
  is.fivefivefive.CanDis.DeclarationOrbitWitnessTest
  is.fivefivefive.CanDis.CoalescedDeclarationWitnessTest
  is.fivefivefive.CanDis.TemporalDeclarationWitnessTest
  is.fivefivefive.CanDis.RetainedPaidCandidateReplayTest
  is.fivefivefive.CanDis.GroupedPaidOrbitReplayTest
  is.fivefivefive.CanDis.SeparatePrefixOrbitReplayTest
  is.fivefivefive.CanDis.ScopeBlockTieReplayTest
  is.fivefivefive.CanDis.MASGVisitorTypeRegressionTest
  is.fivefivefive.CanDis.SemanticProfileSourceCommandTest
  is.fivefivefive.CanDis.CapabilitySoundnessCheckTest
  is.fivefivefive.CanDis.TheoryLawPolicyRegressionTest
  is.fivefivefive.CanDis.VisualizationAnalysisServiceTest
  is.fivefivefive.CanDis.VisualizationProcessRunnerTest
  is.fivefivefive.CanDis.ablation.EGraphAblationTest
  is.fivefivefive.CanDis.core.egraph.SlotPermutationSearchTest
  is.fivefivefive.CanDis.core.egraph.SlotBindingBlocksTest
  is.fivefivefive.CanDis.metric.QuotientRepairDistanceTest
  is.fivefivefive.CanDis.theory.TheoryFoundationsTest
  is.fivefivefive.CanDis.theory.TheoryPortsTest
  is.fivefivefive.CanDis.theory.BooleanSmartConstructionTest
  is.fivefivefive.CanDis.theory.TheoryStateTest
  is.fivefivefive.CanDis.theory.TheoryCanonicalizationTest
  is.fivefivefive.CanDis.theory.TheoryLeaderKernelTest
  is.fivefivefive.CanDis.theory.TheoryCertificatesTest
  is.fivefivefive.CanDis.theory.TheoryCoherentInsertionTest
  is.fivefivefive.CanDis.theory.TheoryRebuildTest
  is.fivefivefive.CanDis.theory.Phase4ProducerTransitionEvidenceTest
  is.fivefivefive.CanDis.theory.TheoryFiniteUnfoldingTest
  is.fivefivefive.CanDis.theory.TheoryDeterminismTest
  is.fivefivefive.CanDis.theory.CertificateProvenanceTest
)

"${LEAN_BIN:-lean}" -o "$work/TemporalCommandGuard.olean" \
  "$ROOT/docs/temporal-capability-solver/TemporalCommandGuard.lean"
"${LEAN_BIN:-lean}" "$ROOT/docs/slot-typing-ablation/PartitionedPermutation.lean"
"${LEAN_BIN:-lean}" "$ROOT/docs/slot-typing-ablation/IndependentBindingBlocks.lean"
"${LEAN_BIN:-lean}" "$ROOT/docs/slot-typing-ablation/AstWrapperErasure.lean"
"${LEAN_BIN:-lean}" "$ROOT/docs/section3-repair-audit/formal/PositiveVerificationMemo.lean"
"${LEAN_BIN:-lean}" "$ROOT/docs/distance-parity-20261107/FastPrefixExchange.lean"
"${LEAN_BIN:-lean}" -o "$work/UnusedGroupedBindings.olean" \
  "$ROOT/docs/section3-repair-audit/formal/UnusedGroupedBindings.lean"
python3 -B "$ROOT/scripts/check_historical_cv_proofs.py"
"${LEAN_BIN:-lean}" -o "$work/HistoricalCVPairs.olean" \
  "$ROOT/docs/section3-repair-audit/formal/HistoricalCVPairs.lean"
"${LEAN_BIN:-lean}" -o "$work/SurvivorWitnessOrder.olean" \
  "$ROOT/docs/section3-repair-audit/formal/SurvivorWitnessOrder.lean"
"${LEAN_BIN:-lean}" -o "$work/DeclarationReplay.olean" \
  "$ROOT/docs/distance-parity-20261107/DeclarationReplay.lean"
for module in CrossedDeclarationReplay OriginalOccurrenceOrder TemporalDeclarationTie \
              CoursesPaidData CoursesPaidAlignmentTie CoursesRepairedNative SingleSourceClassMinimum \
              CoalescedDeclarationFrames; do
  LEAN_PATH="$work${LEAN_PATH:+:$LEAN_PATH}" "${LEAN_BIN:-lean}" -o "$work/$module.olean" \
    "$ROOT/docs/section3-repair-audit/formal/$module.lean"
done
"${LEAN_BIN:-lean}" -o "$work/Phase5SourceRules.olean" \
  "$ROOT/docs/section3-repair-audit/formal/Phase5SourceRules.lean"
"${LEAN_BIN:-lean}" -o "$work/TemporalPhaseLocalBinding.olean" \
  "$ROOT/docs/section3-repair-audit/formal/TemporalPhaseLocalBinding.lean"
LEAN_PATH="$work${LEAN_PATH:+:$LEAN_PATH}" "${LEAN_BIN:-lean}" \
  "$ROOT/docs/distance-parity-20261107/CapabilitySourceScheduling.lean"

for test_class in "${tests[@]}"; do
  printf 'Running %s\n' "$test_class"
  java -ea -Xmx1g -Dacgn.test.repoRoot="$ROOT" -cp "$classes:$ROOT/lib/*" "$test_class"
done

"$ROOT/scripts/run_distance_artifact_regeneration_tests.sh" \
  "$work/distance-paper-artifacts"
