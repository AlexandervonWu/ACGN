#!/usr/bin/env bash
set -uo pipefail

export LC_ALL=C
export TZ=UTC

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="${1:-}"
JAVA_HEAP="${SECTION3_JAVA_HEAP:-1g}"
JAVA_TIMEOUT="${SECTION3_JAVA_TIMEOUT_SECONDS:-300}"
LEAN_TIMEOUT="${SECTION3_LEAN_TIMEOUT_SECONDS:-120}"
LEAN_BIN="${LEAN_BIN:-$HOME/.elan/bin/lean}"

if [[ -z "$OUTPUT" ]]; then
  printf 'usage: %s OUTPUT_DIRECTORY\n' "$0" >&2
  exit 64
fi
if [[ -e "$OUTPUT" ]] && [[ -n "$(find "$OUTPUT" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
  printf 'refusing to reuse nonempty evidence directory: %s\n' "$OUTPUT" >&2
  exit 64
fi
if [[ ! -x "$LEAN_BIN" ]]; then
  printf 'Lean executable is unavailable: %s\n' "$LEAN_BIN" >&2
  exit 3
fi

mkdir -p "$OUTPUT/logs" "$OUTPUT/classes" "$OUTPUT/verifier-classes" \
  "$OUTPUT/verifier-test-classes" "$OUTPUT/certificate-fixtures" \
  "$OUTPUT/certificate-fixtures-replay" \
  "$OUTPUT/phase6-semantic-order" "$OUTPUT/eighth-witness-classes" "$OUTPUT/eighth-witnesses"
OUTPUT="$(cd "$OUTPUT" && pwd)"
cd "$ROOT" || exit 3

failures=0
steps=0

run_step() {
  local label="$1"
  local seconds="$2"
  shift 2
  steps=$((steps + 1))
  printf '[section3-assurance] %s\n' "$label" >&2
  if timeout --signal=TERM --kill-after=10 "$seconds" "$@" \
      >"$OUTPUT/logs/$label.log" 2>&1; then
    printf '%s\tPASS\n' "$label" >>"$OUTPUT/step-results.tsv"
  else
    local status=$?
    printf '%s\tFAIL\texit=%s\n' "$label" "$status" \
      >>"$OUTPUT/step-results.tsv"
    failures=$((failures + 1))
  fi
}

printf 'step\tresult\tdetail\n' >"$OUTPUT/step-results.tsv"

{
  printf 'runSchema\tsection3-bounded-assurance-v1\n'
  printf 'gitHead\t%s\n' "$(git -C "$ROOT" rev-parse HEAD)"
  printf 'dirtyTree\t%s\n' "$(if [[ -n "$(git -C "$ROOT" status --porcelain --untracked-files=normal)" ]]; then printf true; else printf false; fi)"
  printf 'javaHeap\t%s\n' "$JAVA_HEAP"
  printf 'javaTimeoutSeconds\t%s\n' "$JAVA_TIMEOUT"
  printf 'leanTimeoutSeconds\t%s\n' "$LEAN_TIMEOUT"
  printf 'host\t%s\n' "$(hostname)"
  printf 'logicalCpus\t%s\n' "$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf unknown)"
  printf 'kernel\t%s\n' "$(uname -srm)"
  printf 'java\t%s\n' "$(java -version 2>&1 | head -n 1)"
  printf 'javac\t%s\n' "$(javac -version 2>&1)"
  printf 'lean\t%s\n' "$($LEAN_BIN --version | head -n 1)"
} >"$OUTPUT/run-context.tsv"

input_roots=(
  .github/workflows/bounded-ci.yml
  certificate-verifier
  docs/obligation-repair/eighth-five
  docs/obligation-repair/ninth-five
  docs/obligation-repair/tenth-five
  docs/obligation-repair/eleventh-five
  docs/obligation-repair/sixth-five/qualification.json
  docs/obligation-repair/sixth-five/DecodedEvidenceCoverage.lean
  docs/obligation-repair/sixth-five/java/RawCallSourceAuthority.java
  docs/obligation-repair/seventh-five/java/P613SourcePair.java
  docs/obligation-repair/seventh-five/java/RawArrowOccurrenceAuthority.java
  docs/obligation-repair/seventh-five/java/RawArrowSourcePin.java
  docs/section3-assurance-claims.md
  docs/section3-repair-audit
  lean-toolchain
  lib
  scripts
  src
)

write_input_manifest() {
  local destination="$1"
  printf 'sha256\tmode\ttype\tpath\n' >"$destination"
  for input_root in "${input_roots[@]}"; do
    local absolute="$ROOT/$input_root"
    if [[ -f "$absolute" ]]; then
      printf '%s\t%s\tfile\t%s\n' \
        "$(sha256sum "$absolute" | cut -d' ' -f1)" \
        "$(stat -c '%a' "$absolute")" "$input_root" >>"$destination"
    elif [[ -d "$absolute" ]]; then
      while IFS= read -r -d '' path; do
        local relative="${path#"$ROOT/"}"
        if [[ -L "$path" ]]; then
          printf '%s\t%s\tsymlink\t%s\n' \
            "$(printf '%s' "$(readlink "$path")" | sha256sum | cut -d' ' -f1)" \
            "$(stat -c '%a' "$path")" "$relative" >>"$destination"
        else
          printf '%s\t%s\tfile\t%s\n' \
            "$(sha256sum "$path" | cut -d' ' -f1)" \
            "$(stat -c '%a' "$path")" "$relative" >>"$destination"
        fi
      done < <(find "$absolute" \( -type f -o -type l \) -print0 | sort -z)
    else
      printf 'missing assurance input: %s\n' "$input_root" >&2
      return 1
    fi
  done
  local governing_prompt="${SECTION3_GOVERNING_PROMPT:-/home/augustus/文档/ARTIFACT_REPAIR_PROMPT.md}"
  if [[ ! -f "$governing_prompt" ]]; then
    printf 'missing governing prompt: %s\n' "$governing_prompt" >&2
    return 1
  fi
  printf '%s\t%s\texternal-file\t%s\n' \
    "$(sha256sum "$governing_prompt" | cut -d' ' -f1)" \
    "$(stat -c '%a' "$governing_prompt")" "$governing_prompt" \
    >>"$destination"
}

if ! write_input_manifest "$OUTPUT/input-manifest.tsv"; then
  failures=$((failures + 1))
fi

mapfile -t producer_sources < <(find "$ROOT/src" -type f -name '*.java' | sort)
mapfile -t verifier_sources < <(
  find "$ROOT/certificate-verifier/src" -type f -name '*.java' | sort
)
mapfile -t verifier_test_sources < <(
  find "$ROOT/certificate-verifier/test" -type f -name '*.java' | sort
)

run_step compile-producer "$JAVA_TIMEOUT" \
  javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" \
  -d "$OUTPUT/classes" "${producer_sources[@]}"
run_step compile-verifier "$JAVA_TIMEOUT" \
  javac --release 17 -encoding UTF-8 \
  -d "$OUTPUT/verifier-classes" "${verifier_sources[@]}"
run_step compile-verifier-tests "$JAVA_TIMEOUT" \
  javac --release 17 -encoding UTF-8 -cp "$OUTPUT/verifier-classes" \
  -d "$OUTPUT/verifier-test-classes" "${verifier_test_sources[@]}"
run_step package-producer "$JAVA_TIMEOUT" \
  jar --create --file "$OUTPUT/acgn-producer.jar" -C "$OUTPUT/classes" .
run_step package-verifier "$JAVA_TIMEOUT" \
  "$ROOT/scripts/package_certificate_verifier_classes.sh" \
  "$OUTPUT/verifier-classes" "$OUTPUT/acgn-certificate-verifier.jar"

run_step rewrite-rule-traceability "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" -cp "$OUTPUT/classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.RewriteRuleTraceability "$ROOT"

run_step traceability-catalog-fresh "$JAVA_TIMEOUT" \
  bash -c '
    set -euo pipefail
    java -cp "$1:$2/lib/*" is.fivefivefive.CanDis.Section3AssuranceTraceability \
      "$2" --markdown-output="$3"
    cmp "$2/docs/section3-assurance-claims.md" "$3"
  ' assurance-catalog "$OUTPUT/classes" "$ROOT" \
    "$OUTPUT/generated-section3-assurance-claims.md"

java_tests=(
  is.fivefivefive.CanDis.AssuranceTestExecutionCoverageTest
  is.fivefivefive.CanDis.RequiredPolicyCoverageTest
  is.fivefivefive.CanDis.Section3AssuranceTraceabilityTest
  is.fivefivefive.CanDis.RewriteRuleTraceabilityTest
  is.fivefivefive.CanDis.SemanticProfileSourceCommandTest
  is.fivefivefive.CanDis.CallExtractionRegressionTest
  is.fivefivefive.CanDis.MASGVisitorTypeRegressionTest
  is.fivefivefive.CanDis.DependentDeclarationExtractionRegressionTest
  is.fivefivefive.CanDis.AlloySourceRuleRegressionTest
  is.fivefivefive.CanDis.CanonicalAlloyPipelineTest
  is.fivefivefive.CanDis.EGraphSaturationTest
  is.fivefivefive.CanDis.FullCorpusNonTemporalP0RegressionTest
  is.fivefivefive.CanDis.VisualizationAnalysisServiceTest
  is.fivefivefive.CanDis.TheoryLawPolicyRegressionTest
  is.fivefivefive.CanDis.ablation.EGraphAblationTest
  is.fivefivefive.CanDis.augmentation.EquivalenceAugmenterTest
  is.fivefivefive.CanDis.metric.QuotientRepairDistanceTest
  is.fivefivefive.CanDis.theory.TheoryPortsTest
  is.fivefivefive.CanDis.theory.TheoryStateTest
  is.fivefivefive.CanDis.theory.TheoryCanonicalizationTest
  is.fivefivefive.CanDis.theory.TheoryLeaderKernelTest
  is.fivefivefive.CanDis.theory.TheoryCertificatesTest
  is.fivefivefive.CanDis.theory.TheoryCoherentInsertionTest
  is.fivefivefive.CanDis.theory.TheoryRebuildTest
  is.fivefivefive.CanDis.theory.Phase4ProducerTransitionEvidenceTest
  is.fivefivefive.CanDis.theory.TheoryFiniteUnfoldingTest
  is.fivefivefive.CanDis.theory.TheoryDeterminismTest
  is.fivefivefive.CanDis.theory.TheoryDependentChainTest
)
for test_class in "${java_tests[@]}"; do
  short="${test_class##*.}"
  run_step "java-$short" "$JAVA_TIMEOUT" \
    java -ea -Xmx"$JAVA_HEAP" -cp "$OUTPUT/classes:$ROOT/lib/*" "$test_class"
done

verifier_tests=(org.acgn.cert.VerifierTest)
for test_class in "${verifier_tests[@]}"; do
  short="${test_class##*.}"
  run_step "verifier-$short" "$JAVA_TIMEOUT" \
    java -ea -Xmx"$JAVA_HEAP" \
    -cp "$OUTPUT/verifier-classes:$OUTPUT/verifier-test-classes" "$test_class"
done

provenance_options=(
  "-Dacgn.repo.root=$ROOT"
  "-Dacgn.provenance.testOverride=true"
  "-Dacgn.provenance.producerJar=$OUTPUT/acgn-producer.jar"
  "-Dacgn.provenance.verifierJar=$OUTPUT/acgn-certificate-verifier.jar"
  "-Dacgn.provenance.createdAt=1970-01-01T00:00:00Z"
)
run_step producer-certificate-fixtures "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" "${provenance_options[@]}" \
  -cp "$OUTPUT/classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.theory.CertificateBundleWriterTest \
  "$OUTPUT/certificate-fixtures"
run_step producer-certificate-fixtures-replay "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" "${provenance_options[@]}" \
  -cp "$OUTPUT/classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.theory.CertificateBundleWriterTest \
  "$OUTPUT/certificate-fixtures-replay"
run_step producer-certificate-fixtures-deterministic "$JAVA_TIMEOUT" \
  bash -c '
    set -euo pipefail
    first="$1"
    second="$2"
    mapfile -t first_names < <(find "$first" -mindepth 1 -maxdepth 1 -type f -printf "%f\n" | sort)
    mapfile -t second_names < <(find "$second" -mindepth 1 -maxdepth 1 -type f -printf "%f\n" | sort)
    [[ "${first_names[*]}" == "${second_names[*]}" ]]
    for name in "${first_names[@]}"; do
      cmp "$first/$name" "$second/$name"
    done
  ' certificate-determinism "$OUTPUT/certificate-fixtures" \
    "$OUTPUT/certificate-fixtures-replay"
eighth_package="$ROOT/docs/obligation-repair/eighth-five"
eighth_output="$OUTPUT/eighth-witnesses"
eighth_classes="$OUTPUT/eighth-witness-classes"
eighth_dependencies="$OUTPUT/classes:$ROOT/lib/*:$OUTPUT/verifier-classes:$OUTPUT/verifier-test-classes"
mapfile -t eighth_sources < <(find "$eighth_package/java" -type f -name '*.java' | sort)
run_step compile-eighth-witnesses "$JAVA_TIMEOUT" \
  javac --release 17 -encoding UTF-8 -cp "$eighth_dependencies" -d "$eighth_classes" \
  "$ROOT/docs/obligation-repair/sixth-five/java/RawCallSourceAuthority.java" \
  "$ROOT/docs/obligation-repair/seventh-five/java/P613SourcePair.java" "${eighth_sources[@]}"

eighth_java=(java -ea -Xmx"$JAVA_HEAP" "${provenance_options[@]}" -cp "$eighth_classes:$eighth_dependencies")
fresh_verifier="$OUTPUT/acgn-certificate-verifier.jar"
fixtures="$OUTPUT/certificate-fixtures"
run_step java-P611SchemaAdmissionTest "$JAVA_TIMEOUT" \
  "${eighth_java[@]}" org.acgn.cert.P611SchemaAdmissionTest \
  "$ROOT" "$fixtures" "$fresh_verifier" "$eighth_output/schema.tsv"
run_step java-P115ImportedCallAdmissionTest "$JAVA_TIMEOUT" \
  "${eighth_java[@]}" is.fivefivefive.CanDis.P115ImportedCallAdmissionTest
run_step java-P411ShapeIdentityTest "$JAVA_TIMEOUT" \
  "${eighth_java[@]}" org.acgn.cert.P411ShapeIdentityTest "$eighth_output/shape-identities.tsv" "$fresh_verifier"
run_step java-P609RootedBinderTest "$JAVA_TIMEOUT" \
  "${eighth_java[@]}" org.acgn.cert.P609RootedBinderTest "$ROOT" \
  "$fixtures/schema-v8-coverage/bind-block-dual-a.acgncert" \
  "$fixtures/schema-v8-coverage/bind-block-nested-same-descriptor-a.acgncert" "$eighth_output/p609.tsv"
run_step java-A223ArrowFamiliesTest "$JAVA_TIMEOUT" \
  env ACGN_EIGHTH_LEAN="$LEAN_BIN" ACGN_EIGHTH_PROOF="$ROOT/docs/section3-repair-audit/formal/A223ArrowFamilies.lean" \
  "${eighth_java[@]}" is.fivefivefive.CanDis.theory.A223ArrowFamiliesTest "$eighth_output/arrow-families.tsv"

ninth_package="$ROOT/docs/obligation-repair/ninth-five"
ninth_classes="$OUTPUT/ninth-witness-classes"
mkdir -p "$ninth_classes"
mapfile -t ninth_sources < <(find "$ninth_package/java" -type f -name '*.java' | sort)
run_step compile-ninth-witnesses "$JAVA_TIMEOUT" \
  javac --release 17 -encoding UTF-8 -cp "$eighth_dependencies" -d "$ninth_classes" \
  "$ROOT/docs/obligation-repair/seventh-five/java/RawArrowOccurrenceAuthority.java" \
  "$ROOT/docs/obligation-repair/seventh-five/java/RawArrowSourcePin.java" "${ninth_sources[@]}"

run_ninth_witness() {
  local parent="$1" main="$2"
  run_step "java-${main##*.}" "$JAVA_TIMEOUT" \
    python3 -B "$ROOT/scripts/audit_lean_assumptions.py" ninth-phase "$parent" "$main" \
    "$ROOT" "$OUTPUT" "$LEAN_BIN" "$ninth_classes:$eighth_dependencies" "$JAVA_HEAP" "${provenance_options[@]}"
}
run_ninth_witness A2-21 is.fivefivefive.CanDis.theory.A221NormalizationTest
run_ninth_witness A2-22 is.fivefivefive.CanDis.theory.A222IntersectionTest
run_ninth_witness A2-24 org.acgn.cert.A224Qualification
run_ninth_witness A2-25 org.acgn.cert.A225WireCommitmentTest
run_ninth_witness P5-06 is.fivefivefive.CanDis.P506SourceBindingTest

tenth_package="$ROOT/docs/obligation-repair/tenth-five"
tenth_classes="$OUTPUT/tenth-witness-classes"
mkdir -p "$tenth_classes"
mapfile -t tenth_sources < <(find "$tenth_package/java" -type f -name '*.java' | sort)
run_step compile-tenth-witnesses "$JAVA_TIMEOUT" \
  javac --release 17 -encoding UTF-8 -cp "$eighth_dependencies" -d "$tenth_classes" "${tenth_sources[@]}"

run_tenth_witness() {
  local parent="$1" main="$2"
  run_step "java-$parent-${main##*.}" "$JAVA_TIMEOUT" \
    python3 -B "$ROOT/scripts/audit_lean_assumptions.py" tenth-phase "$parent" "$main" \
    "$ROOT" "$OUTPUT" "$LEAN_BIN" "$tenth_classes:$eighth_dependencies" "$JAVA_HEAP" "${provenance_options[@]}"
}
run_tenth_witness P5-05 is.fivefivefive.CanDis.MembershipDualTest
run_tenth_witness P5-07 is.fivefivefive.CanDis.MembershipDualTest
run_tenth_witness P5-11 is.fivefivefive.CanDis.core.egraph.P511LexicalTransportTest
run_tenth_witness A2-26 is.fivefivefive.CanDis.A226Qualification
run_tenth_witness P4-08 is.fivefivefive.CanDis.theory.P408OwnerRestorationTest

eleventh_package="$ROOT/docs/obligation-repair/eleventh-five"
eleventh_classes="$OUTPUT/eleventh-witness-classes"
mkdir -p "$eleventh_classes"
mapfile -t eleventh_sources < <(find "$eleventh_package/java" -type f -name '*.java' | sort)
run_step compile-eleventh-witnesses "$JAVA_TIMEOUT" \
  javac --release 17 -encoding UTF-8 -cp "$eighth_dependencies" -d "$eleventh_classes" "${eleventh_sources[@]}"

run_eleventh_witness() {
  local parent="$1" main="$2"
  run_step "java-$parent-${main##*.}" "$JAVA_TIMEOUT" \
    python3 -B "$ROOT/scripts/audit_lean_assumptions.py" eleventh-phase "$parent" "$main" \
    "$ROOT" "$OUTPUT" "$LEAN_BIN" "$eleventh_classes:$eighth_dependencies" "$JAVA_HEAP" "${provenance_options[@]}"
}
run_eleventh_witness P5-08 is.fivefivefive.CanDis.P508EmptyBindingTest
run_eleventh_witness A2-16 is.fivefivefive.CanDis.A216Qualification
run_eleventh_witness P4-07 is.fivefivefive.CanDis.theory.P407QualifiedUsesTest
run_eleventh_witness P4-04 is.fivefivefive.CanDis.theory.P404ParentAssignmentTest
run_eleventh_witness P4-06 is.fivefivefive.CanDis.theory.P406AbsorbedRecordsTest

run_step producer-Phase6SemanticOrderProducerRegressionTest "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" "${provenance_options[@]}" \
  -cp "$OUTPUT/classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.theory.Phase6SemanticOrderProducerRegressionTest \
  "$OUTPUT/phase6-semantic-order"
run_step verifier-ProducerSemanticEvidenceMutationTest "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" \
  -cp "$OUTPUT/verifier-classes:$OUTPUT/verifier-test-classes" \
  org.acgn.cert.ProducerSemanticEvidenceMutationTest \
  "$OUTPUT/certificate-fixtures/schema-v8-coverage/flat-and-a.acgncert" \
  "$OUTPUT/certificate-fixtures/schema-v8-coverage/flat-and-alt-a.acgncert" \
  "$OUTPUT/certificate-fixtures/schema-v8-coverage/container-equals-a.acgncert" \
  "$OUTPUT/certificate-fixtures/schema-v8-coverage/bind-block-symmetric-a.acgncert" \
  "$OUTPUT/certificate-fixtures/schema-v8-coverage/bind-block-dual-a.acgncert" \
  "$OUTPUT/certificate-fixtures/schema-v8-coverage/bind-block-nested-same-descriptor-a.acgncert" \
  "$OUTPUT/certificate-fixtures/schema-v8-coverage/relation-columns-a.acgncert" \
  "$OUTPUT/certificate-fixtures/schema-v8-coverage/call-occurrence-a.acgncert" \
  "$OUTPUT/certificate-fixtures/schema-v8-coverage/repeated-same-type-slot-a.acgncert" \
  "$OUTPUT/certificate-fixtures/parent-path-a.acgncert"
run_step verifier-Phase6SemanticOrderVerifierRegressionTest "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" \
  -cp "$OUTPUT/verifier-classes:$OUTPUT/verifier-test-classes" \
  org.acgn.cert.Phase6SemanticOrderVerifierRegressionTest \
  "$OUTPUT/phase6-semantic-order/canonical.acgncert" \
  "$OUTPUT/phase6-semantic-order/reversed.acgncert" \
  "$OUTPUT/phase6-semantic-order/polymorphic.acgncert" \
  "$OUTPUT/phase6-semantic-order/monomorphic.acgncert" \
  "$OUTPUT/phase6-semantic-order"

empty_theory_digest=9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c
parent_theory_digest=0901e1ee21d8f82c128ebc93f0e5f1e0b421f7a6833ec16cf5473df3b222b147
run_step verifier-ProducerBundleInspectionTest "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" \
  -cp "$OUTPUT/verifier-classes:$OUTPUT/verifier-test-classes" \
  org.acgn.cert.ProducerBundleInspectionTest \
  "$OUTPUT/certificate-fixtures/nullary-a.acgncert" \
  "$OUTPUT/certificate-fixtures-replay/nullary-a.acgncert" \
  "$OUTPUT/certificate-fixtures/slot-only-a.acgncert" \
  "$OUTPUT/certificate-fixtures-replay/slot-only-a.acgncert" \
  "$OUTPUT/certificate-fixtures/parent-path-a.acgncert" \
  "$OUTPUT/certificate-fixtures-replay/parent-path-a.acgncert" \
  "$OUTPUT/certificate-fixtures/pair-equivalent-left.acgncert" \
  "$OUTPUT/certificate-fixtures-replay/pair-equivalent-right.acgncert" \
  "$OUTPUT/certificate-fixtures-replay/pair-non-equivalent.acgncert" \
  "$ROOT" "$OUTPUT/acgn-producer.jar" \
  "$OUTPUT/acgn-certificate-verifier.jar" \
  "$empty_theory_digest" "$parent_theory_digest"
run_step verifier-TrustedTheoryPinsTest "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" \
  -cp "$OUTPUT/verifier-classes:$OUTPUT/verifier-test-classes" \
  org.acgn.cert.TrustedTheoryPinsTest \
  "$ROOT/certificate-verifier/trusted/theory-pins.tsv" \
  "$OUTPUT/certificate-fixtures/nullary-a.acgncert" \
  "$OUTPUT/certificate-fixtures/slot-only-a.acgncert" \
  "$OUTPUT/certificate-fixtures/parent-path-a.acgncert"

run_step publication-manifest-contracts "$JAVA_TIMEOUT" \
  "$ROOT/scripts/run_publication_manifest_tests.sh"
run_step imported-publication-snapshot "$JAVA_TIMEOUT" \
  "$ROOT/scripts/verify_imported_publication_snapshot.sh"

run_step lean-governed-inventory "$LEAN_TIMEOUT" \
  python3 -B "$ROOT/scripts/audit_lean_assumptions.py" --root "$ROOT" --list-formal-files
cp "$OUTPUT/logs/lean-governed-inventory.log" "$OUTPUT/mapped-lean-files.txt"
mapfile -t mapped_lean_files <"$OUTPUT/mapped-lean-files.txt"
find "$ROOT/docs/section3-repair-audit/formal" -maxdepth 1 \
  \( -type f -o -type l \) -name '*.lean' -printf 'docs/section3-repair-audit/formal/%f\n' \
  | sort >"$OUTPUT/discovered-lean-files.txt"
run_step lean-mapping-exact "$LEAN_TIMEOUT" \
  cmp "$OUTPUT/discovered-lean-files.txt" "$OUTPUT/mapped-lean-files.txt"
# Compile local imports into a fresh directory. No ambient project .oleans
# participate in either the mapped proof checks or the generated axiom audits.
lean_imports="$OUTPUT/lean-imports"
mkdir -p "$lean_imports"
import_sources=(
  docs/obligation-repair/sixth-five/DecodedEvidenceCoverage.lean
  docs/section3-repair-audit/formal/DependentChainSequence.lean
  docs/section3-repair-audit/formal/DependentJoinGuard.lean
  docs/section3-repair-audit/formal/PhaseA2DependentChains.lean
  docs/section3-repair-audit/formal/ContainerReplay.lean
  docs/section3-repair-audit/formal/Phase2VariadicLaws.lean
)
for relative in "${import_sources[@]}"; do
  module="$(basename "$relative" .lean)"
  run_step "lean-import-$module" "$LEAN_TIMEOUT" \
    env LEAN_PATH="$lean_imports" bash -c 'cd "$1" && exec "$2" -o "$3/$4.olean" "$4.lean"' \
    assurance-import "$ROOT/$(dirname "$relative")" "$LEAN_BIN" "$lean_imports" "$module"
done
for relative_lean_file in "${mapped_lean_files[@]}"; do
  if [[ "$relative_lean_file" != docs/section3-repair-audit/formal/*.lean ]]; then
    printf 'mapped Lean file is outside the governed directory: %s\n' \
      "$relative_lean_file" >&2
    failures=$((failures + 1))
    continue
  fi
  lean_file="$ROOT/$relative_lean_file"
  name="$(basename "$lean_file" .lean)"
  imports="$lean_imports"
  for phase_cache in "$OUTPUT/ninth-witnesses" "$OUTPUT/tenth-witnesses" "$OUTPUT/eleventh-witnesses"; do
    if [[ -f "$phase_cache/$name.imports" ]]; then
      if [[ "$imports" != "$lean_imports" ]]; then
        printf 'ambiguous phase import cache for %s\n' "$name" >&2
        failures=$((failures + 1))
        continue 2
      fi
      read -r cache <"$phase_cache/$name.imports"
      imports="$phase_cache/$cache"
    fi
  done
  run_step "lean-$name" "$LEAN_TIMEOUT" env LEAN_PATH="$imports" "$LEAN_BIN" "$lean_file"
done

run_step lean-ConcreteRepairMetric-vectors "$LEAN_TIMEOUT" \
  "$LEAN_BIN" --run \
  "$ROOT/docs/section3-repair-audit/formal/ConcreteRepairMetric.lean" \
  "$OUTPUT/concrete-repair-metric.tsv"
run_step java-ConcreteRepairMetricRefinementTest "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" -cp "$OUTPUT/classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.metric.ConcreteRepairMetricRefinementTest \
  "$OUTPUT/concrete-repair-metric.tsv"

run_step lean-forbidden-token-scan "$LEAN_TIMEOUT" \
  bash -c 'rg -n "\b(sorry|admit|axiom|unsafe)\b" "$1" --glob "*.lean"
    status=$?
    case "$status" in 0) exit 1 ;; 1) exit 0 ;; *) exit "$status" ;; esac' \
  assurance-scan "$ROOT/docs/section3-repair-audit/formal"
run_step lean-explicit-assumption-inventory "$LEAN_TIMEOUT" \
  env LEAN_PATH="$lean_imports" python3 -B "$ROOT/scripts/audit_lean_assumptions.py" \
  --root "$ROOT" --output "$OUTPUT/lean-assumptions" --lean "$LEAN_BIN" --phase-caches "$OUTPUT/ninth-witnesses" --phase-caches "$OUTPUT/tenth-witnesses" --phase-caches "$OUTPUT/eleventh-witnesses"

run_step traceability-tests "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" -cp "$OUTPUT/classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.Section3AssuranceTraceabilityTest

java -cp "$OUTPUT/classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.Section3AssuranceTraceability "$ROOT" \
  >"$OUTPUT/traceability-report.txt" 2>&1
trace_failures="$(awk -F= '$1 == "failures" { print $2; exit }' \
  "$OUTPUT/traceability-report.txt")"
if [[ ! "$trace_failures" =~ ^[0-9]+$ ]]; then
  trace_failures=-1
  failures=$((failures + 1))
fi

if ! write_input_manifest "$OUTPUT/input-manifest-final.tsv"; then
  failures=$((failures + 1))
else
  run_step input-manifest-stability "$JAVA_TIMEOUT" \
    cmp "$OUTPUT/input-manifest.tsv" "$OUTPUT/input-manifest-final.tsv"
fi

find "$OUTPUT/classes" -type f -name '*.class' -print0 | sort -z \
  | xargs -0 sha256sum >"$OUTPUT/producer-class-hashes.txt"
find "$OUTPUT/verifier-classes" -type f -name '*.class' -print0 | sort -z \
  | xargs -0 sha256sum >"$OUTPUT/verifier-class-hashes.txt"

if (( failures > 0 )); then
  outcome=FAIL
  exit_status=1
elif (( trace_failures > 0 )); then
  outcome=INCOMPLETE
  exit_status=3
else
  outcome=PASS
  exit_status=0
fi

{
  printf '# Section 3 Bounded Assurance Run\n\n'
  printf -- '- Outcome: `%s`\n' "$outcome"
  printf -- '- Executed steps: %s\n' "$steps"
  printf -- '- Failed executable steps: %s\n' "$failures"
  printf -- '- Open traceability diagnostics: %s\n' "$trace_failures"
  printf -- '- Input manifest SHA-256: `%s`\n' \
    "$(sha256sum "$OUTPUT/input-manifest.tsv" | cut -d' ' -f1)"
  printf '\n`INCOMPLETE` is not a passing assurance result. It means all executable\n'
  printf 'steps completed but one or more claim obligations remain open.\n'
} >"$OUTPUT/summary.md"

printf 'sha256\tpath\n' >"$OUTPUT/output-manifest.tsv"
while IFS= read -r -d '' path; do
  relative="${path#"$OUTPUT/"}"
  if [[ "$relative" != "output-manifest.tsv" ]]; then
    printf '%s\t%s\n' "$(sha256sum "$path" | cut -d' ' -f1)" "$relative"
  fi
done < <(find "$OUTPUT" -type f -print0 | sort -z) \
  >>"$OUTPUT/output-manifest.tsv"

printf '[section3-assurance] outcome=%s evidence=%s\n' "$outcome" "$OUTPUT" >&2
exit "$exit_status"
