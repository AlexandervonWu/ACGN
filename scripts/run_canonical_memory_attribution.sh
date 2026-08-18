#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$(mktemp -d /tmp/acgn-canonical-memory.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT

INPUT="$ROOT/classified-data"
OUTPUT="$ROOT/canonical_memory"
PRODUCTION="$ROOT/egraph_ablation/canonical"
LIMIT=2000
SEED=55520260811
MAX_HEAP=3g
WORKERS="1,8,32"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) INPUT="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --production) PRODUCTION="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --seed) SEED="$2"; shift 2 ;;
    --max-heap) MAX_HEAP="$2"; shift 2 ;;
    --workers) WORKERS="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

mkdir -p "$OUTPUT"
javac -cp "$ROOT/lib/*" -d "$BUILD_DIR" $(find "$ROOT/src" -name '*.java')

IFS=',' read -ra WORKER_LIST <<< "$WORKERS"
for worker in "${WORKER_LIST[@]}"; do
  worker="${worker//[[:space:]]/}"
  RUN_DIR="$OUTPUT/workers-$worker"
  mkdir -p "$RUN_DIR"
  /usr/bin/time -v -o "$RUN_DIR/process.time" \
    java -Xms32m -Xmx"$MAX_HEAP" -cp "$BUILD_DIR:$ROOT/lib/*" \
      is.fivefivefive.CanDis.CanonicalMemoryAttribution \
      --run --input "$INPUT" --output "$RUN_DIR" --workers "$worker" \
      --limit "$LIMIT" --seed "$SEED" --post-run-gc \
      > "$RUN_DIR/run.log" 2>&1
done

java -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.CanonicalMemoryAttribution \
  --report --input "$INPUT" --output "$OUTPUT" --production "$PRODUCTION" \
  --limit "$LIMIT" --seed "$SEED" --report-workers "$WORKERS"
