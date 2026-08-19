#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR=""

DATASET="$ROOT/classified-data"
OUTPUT="$ROOT/capability_benchmark"
NATURAL="$ROOT/egraph_ablation"
TARGET=500
SEED=55520260811
THREADS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
MAX_HEAP=3g
SOUNDNESS_PER_SUBTYPE=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dataset) DATASET="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --natural) NATURAL="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --seed) SEED="$2"; shift 2 ;;
    --threads) THREADS="$2"; shift 2 ;;
    --max-heap) MAX_HEAP="$2"; shift 2 ;;
    --soundness-per-subtype) SOUNDNESS_PER_SUBTYPE="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

mkdir -p "$OUTPUT"
if [[ -n "${ACGN_EXPERIMENT_JAR:-}" ]]; then
  [[ -f "$ACGN_EXPERIMENT_JAR" ]] \
    || { printf 'ACGN_EXPERIMENT_JAR is missing: %s\n' "$ACGN_EXPERIMENT_JAR" >&2; exit 2; }
  classpath="$ACGN_EXPERIMENT_JAR:$ROOT/lib/*"
else
  BUILD_DIR="$(mktemp -d /tmp/acgn-capability-benchmark.XXXXXX)"
  trap 'rm -rf "$BUILD_DIR"' EXIT
  mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
  javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" \
    -d "$BUILD_DIR" "${sources[@]}"
  classpath="$BUILD_DIR:$ROOT/lib/*"
fi

cd "$ROOT"
java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.CapabilityBenchmark \
  --generate --dataset "$DATASET" --output "$OUTPUT" --target "$TARGET" --seed "$SEED"

java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.CapabilitySoundnessCheck \
  --root "$OUTPUT" --per-subtype "$SOUNDNESS_PER_SUBTYPE"

java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.EGraphAblationSuite \
  --input "$OUTPUT/models" --output "$OUTPUT/arms" --threads "$THREADS" \
  --max-heap "$MAX_HEAP" --seed "$SEED"

java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.CapabilityBenchmark \
  --report --dataset "$DATASET" --output "$OUTPUT" --natural "$NATURAL" \
  --target "$TARGET" --seed "$SEED"
