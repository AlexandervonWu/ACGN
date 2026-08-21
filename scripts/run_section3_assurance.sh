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
  "$OUTPUT/verifier-test-classes" "$OUTPUT/certificate-fixtures"

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
  certificate-verifier
  docs/section3-assurance-claims.md
  docs/section3-repair-audit
  lib
  scripts/run_section3_assurance.sh
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
  jar --create --file "$OUTPUT/acgn-certificate-verifier.jar" \
  --main-class org.acgn.cert.Main -C "$OUTPUT/verifier-classes" .

run_step traceability-catalog-fresh "$JAVA_TIMEOUT" \
  bash -c '
    set -euo pipefail
    java -cp "$1:$2/lib/*" is.fivefivefive.CanDis.Section3AssuranceTraceability \
      "$2" --markdown-output="$3"
    cmp "$2/docs/section3-assurance-claims.md" "$3"
  ' assurance-catalog "$OUTPUT/classes" "$ROOT" \
    "$OUTPUT/generated-section3-assurance-claims.md"

java_tests=(
  is.fivefivefive.CanDis.Section3AssuranceTraceabilityTest
  is.fivefivefive.CanDis.SemanticProfileSourceCommandTest
  is.fivefivefive.CanDis.CallExtractionRegressionTest
  is.fivefivefive.CanDis.AlloySourceRuleRegressionTest
  is.fivefivefive.CanDis.CanonicalAlloyPipelineTest
  is.fivefivefive.CanDis.EGraphSaturationTest
  is.fivefivefive.CanDis.TheoryLawPolicyRegressionTest
  is.fivefivefive.CanDis.ablation.EGraphAblationTest
  is.fivefivefive.CanDis.metric.QuotientRepairDistanceTest
  is.fivefivefive.CanDis.theory.TheoryPortsTest
  is.fivefivefive.CanDis.theory.TheoryStateTest
  is.fivefivefive.CanDis.theory.TheoryCanonicalizationTest
  is.fivefivefive.CanDis.theory.TheoryLeaderKernelTest
  is.fivefivefive.CanDis.theory.TheoryCertificatesTest
  is.fivefivefive.CanDis.theory.TheoryCoherentInsertionTest
  is.fivefivefive.CanDis.theory.TheoryRebuildTest
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
run_step verifier-ProducerSemanticEvidenceMutationTest "$JAVA_TIMEOUT" \
  java -ea -Xmx"$JAVA_HEAP" \
  -cp "$OUTPUT/verifier-classes:$OUTPUT/verifier-test-classes" \
  org.acgn.cert.ProducerSemanticEvidenceMutationTest \
  "$OUTPUT/certificate-fixtures/flat-and-a.acgncert" \
  "$OUTPUT/certificate-fixtures/flat-and-alt-a.acgncert" \
  "$OUTPUT/certificate-fixtures/container-equals-a.acgncert" \
  "$OUTPUT/certificate-fixtures/bind-block-symmetric-a.acgncert" \
  "$OUTPUT/certificate-fixtures/bind-block-dual-a.acgncert" \
  "$OUTPUT/certificate-fixtures/bind-block-nested-same-descriptor-a.acgncert" \
  "$OUTPUT/certificate-fixtures/relation-columns-a.acgncert" \
  "$OUTPUT/certificate-fixtures/call-occurrence-a.acgncert" \
  "$OUTPUT/certificate-fixtures/repeated-same-type-slot-a.acgncert"

mapfile -t mapped_lean_files < <(
  awk -F '\t' 'NR > 1 && $3 != "" && $3 != "MISSING" { print $3 }' \
    "$ROOT/docs/section3-repair-audit/requirements-traceability.tsv" | sort -u
)
printf '%s\n' "${mapped_lean_files[@]}" >"$OUTPUT/mapped-lean-files.txt"
find "$ROOT/docs/section3-repair-audit/formal" -maxdepth 1 \
  -type f -name '*.lean' -printf 'docs/section3-repair-audit/formal/%f\n' \
  | sort >"$OUTPUT/discovered-lean-files.txt"
run_step lean-mapping-exact "$LEAN_TIMEOUT" \
  cmp "$OUTPUT/discovered-lean-files.txt" "$OUTPUT/mapped-lean-files.txt"
for relative_lean_file in "${mapped_lean_files[@]}"; do
  if [[ "$relative_lean_file" != docs/section3-repair-audit/formal/*.lean ]]; then
    printf 'mapped Lean file is outside the governed directory: %s\n' \
      "$relative_lean_file" >&2
    failures=$((failures + 1))
    continue
  fi
  lean_file="$ROOT/$relative_lean_file"
  name="$(basename "$lean_file" .lean)"
  run_step "lean-$name" "$LEAN_TIMEOUT" "$LEAN_BIN" "$lean_file"
done

run_step lean-forbidden-token-scan "$LEAN_TIMEOUT" \
  bash -c '! rg -n '\''\b(sorry|admit|axiom|unsafe)\b'\'' "$1" --glob '\''*.lean'\''' \
  assurance-scan "$ROOT/docs/section3-repair-audit/formal"

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
