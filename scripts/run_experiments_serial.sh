#!/usr/bin/env bash
set -euo pipefail

# Full structural reproduction, deliberately serialized:
#   CanonicalBatchTest -> Alloy4FunAugmenter -> Ablation -> Capability
#
# Environment overrides:
#   DATASET, DISTANCE_OUTPUT, AUGMENTED_OUTPUT, ABLATION_OUTPUT,
#   CAPABILITY_OUTPUT, SERIAL_SUMMARY, THREADS, MAX_HEAP,
#   CAPABILITY_TARGET, SEED, LIMIT.
# Set REWARD_POOL to a positive integer to enable Rewarder for the first two
# stages; the default is the faster reward-free run.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR=""

DATASET="${DATASET:-$ROOT/classified-data}"
DISTANCE_OUTPUT="${DISTANCE_OUTPUT:-$ROOT/distance_results}"
AUGMENTED_OUTPUT="${AUGMENTED_OUTPUT:-$ROOT/alloy4fun-augmented}"
ABLATION_OUTPUT="${ABLATION_OUTPUT:-$ROOT/egraph_ablation}"
CAPABILITY_OUTPUT="${CAPABILITY_OUTPUT:-$ROOT/capability_benchmark}"
SERIAL_SUMMARY="${SERIAL_SUMMARY:-$ROOT/experiment_results_summary.md}"
MAX_HEAP="${MAX_HEAP:-4g}"
CAPABILITY_TARGET="${CAPABILITY_TARGET:-500}"
SEED="${SEED:-55520260811}"

logical_cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')"
THREADS="${THREADS:-$logical_cores}"
if (( THREADS > 32 )); then
  THREADS=32
fi

reward_args=(--skip-rewards)
if [[ -n "${REWARD_POOL:-}" ]]; then
  if (( REWARD_POOL <= 0 )); then
    printf 'REWARD_POOL must be a positive integer\n' >&2
    exit 2
  fi
  reward_args=(--reward-pool "$REWARD_POOL")
fi

limit_args=()
if [[ -n "${LIMIT:-}" ]]; then
  if ! [[ "$LIMIT" =~ ^[1-9][0-9]*$ ]]; then
    printf 'LIMIT must be a positive integer\n' >&2
    exit 2
  fi
  limit_args=(--limit "$LIMIT")
fi

stage() {
  printf '\n[%s] %s\n' "$(date --iso-8601=seconds)" "$1"
}

fail() {
  printf 'Serial experiment validation failed: %s\n' "$1" >&2
  exit 1
}

require_file() {
  [[ -s "$1" ]] || fail "missing or empty artifact: $1"
}

require_text() {
  local path="$1"
  local expected="$2"
  require_file "$path"
  grep -Fq -- "$expected" "$path" \
    || fail "$path does not contain required marker: $expected"
}

validate_canonical_batch() {
  local json="$DISTANCE_OUTPUT/distances.json"
  local markdown="$DISTANCE_OUTPUT/summary.md"
  require_text "$json" '"certificateIntegratedEngine"'
  require_text "$json" '"fastRewriteEngine"'
  require_text "$json" '"implementationFieldMapping"'
  require_text "$json" '"averageCertificateIntegratedCanonicalDistance"'
  require_text "$json" '"averageFastRewriteCanonicalDistance"'
  require_text "$markdown" 'Certificate-Integrated IR'
  require_text "$markdown" 'Fast Rewrite IR'
}

validate_augmenter() {
  local json="$AUGMENTED_OUTPUT/index.json"
  local markdown="$AUGMENTED_OUTPUT/summary.md"
  require_text "$json" '"certificateIntegratedEngine"'
  require_text "$json" '"fastRewriteEngine"'
  require_text "$json" '"implementationFieldMapping"'
  require_text "$json" '"averageNearestCertificateIntegratedDistance"'
  require_text "$json" '"averageNearestFastRewriteDistance"'
  require_text "$markdown" 'Avg nearest Certificate-Integrated IR'
  require_text "$markdown" 'Avg nearest Fast Rewrite IR'
  require_file "$AUGMENTED_OUTPUT/correct_ast_diff_canonical_equiv.json"
  require_file "$AUGMENTED_OUTPUT/correct_ast_diff_fast_rewrite_equiv.json"
}

validate_ablation() {
  local markdown="$ABLATION_OUTPUT/summary.md"
  require_text "$markdown" 'Fast Rewrite IR'
  require_text "$markdown" 'Certificate-Integrated IR'
  require_file "$ABLATION_OUTPUT/canonical/pairs.csv"
  require_file "$ABLATION_OUTPUT/canonical/summary.json"
  require_file "$ABLATION_OUTPUT/typed-slotted-port-egraph/pairs.csv"
  require_file "$ABLATION_OUTPUT/typed-slotted-port-egraph/summary.json"
  require_file "$ABLATION_OUTPUT/comparison.json"
  require_file "$ABLATION_OUTPUT/run-manifest.json"
}

validate_capability() {
  local report="$CAPABILITY_OUTPUT/REPORT.md"
  local arms="$CAPABILITY_OUTPUT/arms/summary.md"
  require_text "$report" '| canonical |'
  require_text "$report" '| typed-slotted-port-egraph |'
  require_text "$arms" 'Fast Rewrite IR'
  require_text "$arms" 'Certificate-Integrated IR'
  require_file "$CAPABILITY_OUTPUT/arms/canonical/pairs.csv"
  require_file "$CAPABILITY_OUTPUT/arms/typed-slotted-port-egraph/pairs.csv"
  require_file "$CAPABILITY_OUTPUT/results.json"
}

write_serial_summary() {
  mkdir -p "$(dirname "$SERIAL_SUMMARY")"
  {
    printf '# Serial Experiment Run Summary\n\n'
    printf -- '- Completed at: `%s`\n' "$(date --iso-8601=seconds)"
    printf -- '- Dataset: `%s`\n' "$DATASET"
    printf -- '- Workers: %s\n' "$THREADS"
    printf -- '- JVM heap cap: `%s`\n' "$MAX_HEAP"
    if [[ ${#limit_args[@]} -gt 0 ]]; then
      printf -- '- Predicate-pair/file limit: %s\n' "$LIMIT"
    else
      printf -- '- Predicate-pair/file limit: full corpus\n'
    fi
    printf '\n## Implementations\n\n'
    printf -- '- Fast Rewrite IR: `Canonical` / `CanonicalDistance`; ablation arm `canonical`.\n'
    printf -- '- Certificate-Integrated IR: `CanonicalAlloyPipeline`; ablation arm `typed-slotted-port-egraph`.\n'
    printf -- '- Result: both implementations were present in every applicable machine-readable artifact and Markdown summary.\n'
    printf '\n## Detailed Results\n\n'
    printf '| Experiment | Detailed summary | Machine-readable data |\n'
    printf '| --- | --- | --- |\n'
    printf '| CanonicalBatchTest | `%s` | `%s` |\n' \
      "$DISTANCE_OUTPUT/summary.md" "$DISTANCE_OUTPUT/distances.json"
    printf '| Alloy4FunAugmenter | `%s` | `%s` |\n' \
      "$AUGMENTED_OUTPUT/summary.md" "$AUGMENTED_OUTPUT/index.json"
    printf '| Seven-arm ablation | `%s` | `%s` |\n' \
      "$ABLATION_OUTPUT/summary.md" "$ABLATION_OUTPUT/comparison.json"
    printf '| Capability study | `%s` | `%s` |\n' \
      "$CAPABILITY_OUTPUT/REPORT.md" "$CAPABILITY_OUTPUT/results.json"
    printf '\nThe detailed summaries retain each implementation independently; this index does not merge their measurements.\n'
  } > "$SERIAL_SUMMARY"
}

if [[ -n "${ACGN_EXPERIMENT_JAR:-}" ]]; then
  [[ -f "$ACGN_EXPERIMENT_JAR" ]] \
    || fail "ACGN_EXPERIMENT_JAR is missing: $ACGN_EXPERIMENT_JAR"
  stage "Using frozen experiment JAR $ACGN_EXPERIMENT_JAR"
  classpath="$ACGN_EXPERIMENT_JAR:$ROOT/lib/*"
else
  BUILD_DIR="$(mktemp -d /tmp/acgn-serial-experiments.XXXXXX)"
  trap 'rm -rf "$BUILD_DIR"' EXIT
  stage "Compiling experiment classes"
  mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
  javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" \
    -d "$BUILD_DIR" "${sources[@]}"
  classpath="$BUILD_DIR:$ROOT/lib/*"
fi

stage "1/4 CanonicalBatchTest"
java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.CanonicalBatchTest \
  "$DATASET" "$DISTANCE_OUTPUT" \
  --threads "$THREADS" "${reward_args[@]}" "${limit_args[@]}"
validate_canonical_batch

stage "2/4 Alloy4FunAugmenter"
java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.Alloy4FunAugmenter \
  "$DATASET" "$AUGMENTED_OUTPUT" \
  --threads "$THREADS" "${reward_args[@]}" "${limit_args[@]}"
validate_augmenter

stage "3/4 Seven-arm ablation"
"$ROOT/scripts/run_egraph_ablation.sh" \
  --input "$DATASET" \
  --output "$ABLATION_OUTPUT" \
  --threads "$THREADS" \
  --max-heap "$MAX_HEAP" \
  --seed "$SEED" \
  "${limit_args[@]}"
validate_ablation

stage "4/4 Capability study"
"$ROOT/scripts/run_capability_benchmark.sh" \
  --dataset "$DATASET" \
  --output "$CAPABILITY_OUTPUT" \
  --natural "$ABLATION_OUTPUT" \
  --target "$CAPABILITY_TARGET" \
  --threads "$THREADS" \
  --max-heap "$MAX_HEAP" \
  --seed "$SEED"
validate_capability

write_serial_summary
stage "All four experiment stages completed; wrote $SERIAL_SUMMARY"
