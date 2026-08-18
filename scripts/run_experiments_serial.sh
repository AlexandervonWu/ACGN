#!/usr/bin/env bash
set -euo pipefail

# Full structural reproduction, deliberately serialized:
#   CanonicalBatchTest -> Alloy4FunAugmenter -> Ablation -> Capability
#
# Environment overrides:
#   DATASET, DISTANCE_OUTPUT, AUGMENTED_OUTPUT, ABLATION_OUTPUT,
#   CAPABILITY_OUTPUT, THREADS, MAX_HEAP, CAPABILITY_TARGET, SEED.
# Set REWARD_POOL to a positive integer to enable Rewarder for the first two
# stages; the default is the faster reward-free run.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$(mktemp -d /tmp/acgn-serial-experiments.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT

DATASET="${DATASET:-$ROOT/classified-data}"
DISTANCE_OUTPUT="${DISTANCE_OUTPUT:-$ROOT/distance_results}"
AUGMENTED_OUTPUT="${AUGMENTED_OUTPUT:-$ROOT/alloy4fun-augmented}"
ABLATION_OUTPUT="${ABLATION_OUTPUT:-$ROOT/egraph_ablation}"
CAPABILITY_OUTPUT="${CAPABILITY_OUTPUT:-$ROOT/capability_benchmark}"
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

stage() {
  printf '\n[%s] %s\n' "$(date --iso-8601=seconds)" "$1"
}

stage "Compiling experiment classes"
mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
javac --release 17 -cp "$ROOT/lib/*" -d "$BUILD_DIR" "${sources[@]}"
classpath="$BUILD_DIR:$ROOT/lib/*"

stage "1/4 CanonicalBatchTest"
java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.CanonicalBatchTest \
  "$DATASET" "$DISTANCE_OUTPUT" \
  --threads "$THREADS" "${reward_args[@]}"

stage "2/4 Alloy4FunAugmenter"
java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.Alloy4FunAugmenter \
  "$DATASET" "$AUGMENTED_OUTPUT" \
  --threads "$THREADS" "${reward_args[@]}"

stage "3/4 Seven-arm ablation"
"$ROOT/scripts/run_egraph_ablation.sh" \
  --input "$DATASET" \
  --output "$ABLATION_OUTPUT" \
  --threads "$THREADS" \
  --max-heap "$MAX_HEAP" \
  --seed "$SEED"

stage "4/4 Capability study"
"$ROOT/scripts/run_capability_benchmark.sh" \
  --dataset "$DATASET" \
  --output "$CAPABILITY_OUTPUT" \
  --natural "$ABLATION_OUTPUT" \
  --target "$CAPABILITY_TARGET" \
  --threads "$THREADS" \
  --max-heap "$MAX_HEAP" \
  --seed "$SEED"

stage "All four experiment stages completed"
