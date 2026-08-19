#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$(mktemp -d /tmp/acgn-bounded-java-tests.XXXXXX)"
trap 'rm -rf "$work"' EXIT
classes="$work/classes"
mkdir -p "$classes"

mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" \
  -d "$classes" "${sources[@]}"

tests=(
  is.fivefivefive.CanDis.CanonicalAlloyPipelineTest
  is.fivefivefive.CanDis.CanonicalBacktranslatorTest
  is.fivefivefive.CanDis.EGraphSaturationTest
  is.fivefivefive.CanDis.MASGVisitorTypeRegressionTest
  is.fivefivefive.CanDis.VisualizationAnalysisServiceTest
  is.fivefivefive.CanDis.VisualizationProcessRunnerTest
  is.fivefivefive.CanDis.ablation.EGraphAblationTest
  is.fivefivefive.CanDis.metric.QuotientRepairDistanceTest
  is.fivefivefive.CanDis.theory.TheoryFoundationsTest
  is.fivefivefive.CanDis.theory.TheoryPortsTest
  is.fivefivefive.CanDis.theory.TheoryStateTest
  is.fivefivefive.CanDis.theory.TheoryCanonicalizationTest
  is.fivefivefive.CanDis.theory.TheoryLeaderKernelTest
  is.fivefivefive.CanDis.theory.TheoryCertificatesTest
  is.fivefivefive.CanDis.theory.TheoryCoherentInsertionTest
  is.fivefivefive.CanDis.theory.TheoryRebuildTest
  is.fivefivefive.CanDis.theory.TheoryFiniteUnfoldingTest
  is.fivefivefive.CanDis.theory.TheoryDeterminismTest
  is.fivefivefive.CanDis.theory.CertificateProvenanceTest
)

for test_class in "${tests[@]}"; do
  printf 'Running %s\n' "$test_class"
  java -ea -Xmx1g -cp "$classes:$ROOT/lib/*" "$test_class"
done

"$ROOT/scripts/run_distance_artifact_regeneration_tests.sh" \
  "$work/distance-paper-artifacts"
