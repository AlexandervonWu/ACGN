#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATASET="$ROOT/classified-data"
RUN_ROOT=""
MAX_HEAP="4g"
SEED="55520260811"
CAPABILITY_TARGET="500"
LIMIT="0"
REWARD_POOL="0"
logical_cores="$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf '1')"
THREADS="$logical_cores"
if (( THREADS > 32 )); then THREADS=32; fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dataset) DATASET="$2"; shift 2 ;;
    --run-root) RUN_ROOT="$2"; shift 2 ;;
    --threads) THREADS="$2"; shift 2 ;;
    --max-heap) MAX_HEAP="$2"; shift 2 ;;
    --seed) SEED="$2"; shift 2 ;;
    --capability-target) CAPABILITY_TARGET="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --reward-pool) REWARD_POOL="$2"; shift 2 ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
done

if [[ -z "$RUN_ROOT" ]]; then
  printf 'usage: %s --run-root <new-directory> [options]\n' "$0" >&2
  exit 2
fi
for number in "$THREADS" "$CAPABILITY_TARGET"; do
  [[ "$number" =~ ^[1-9][0-9]*$ ]] || { printf 'positive integer required: %s\n' "$number" >&2; exit 2; }
done
for number in "$LIMIT" "$REWARD_POOL"; do
  [[ "$number" =~ ^[0-9]+$ ]] || { printf 'nonnegative integer required: %s\n' "$number" >&2; exit 2; }
done

RUN_ROOT="$(realpath -m "$RUN_ROOT")"
DATASET="$(realpath "$DATASET")"
case "$RUN_ROOT/" in
  "$ROOT"/*)
    printf 'Publication run root must be outside the Git worktree: %s\n' "$RUN_ROOT" >&2
    exit 2
    ;;
esac
if [[ -e "$RUN_ROOT" ]] && [[ -n "$(find "$RUN_ROOT" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  printf 'Publication run root must be new or empty: %s\n' "$RUN_ROOT" >&2
  exit 2
fi
if [[ -n "$(git -C "$ROOT" status --porcelain --untracked-files=all)" ]]; then
  printf 'Publication runs require a clean Git worktree.\n' >&2
  exit 1
fi

mkdir -p "$RUN_ROOT/build/classes"
JAR="$RUN_ROOT/build/acgn-experiments.jar"
MANIFEST="$RUN_ROOT/run-manifest.json"
COMMANDS="$RUN_ROOT/planned-commands.txt"
DISTANCE="$RUN_ROOT/distance_results"
AUGMENTED="$RUN_ROOT/alloy4fun-augmented"
ABLATION="$RUN_ROOT/egraph_ablation"
CAPABILITY="$RUN_ROOT/capability_benchmark"

reward_args=(--skip-rewards)
if (( REWARD_POOL > 0 )); then reward_args=(--reward-pool "$REWARD_POOL"); fi
limit_args=()
if (( LIMIT > 0 )); then limit_args=(--limit "$LIMIT"); fi

cat > "$COMMANDS" <<EOF
CanonicalBatchTest dataset=$DATASET output=$DISTANCE threads=$THREADS heap=$MAX_HEAP rewardPool=$REWARD_POOL limit=$LIMIT
Alloy4FunAugmenter dataset=$DATASET output=$AUGMENTED threads=$THREADS heap=$MAX_HEAP rewardPool=$REWARD_POOL limit=$LIMIT
EGraphAblationSuite dataset=$DATASET output=$ABLATION threads=$THREADS heap=$MAX_HEAP seed=$SEED limit=$LIMIT
EGraphSemanticSoundnessCheck dataset=$DATASET results=$ABLATION threads=$THREADS
CapabilityBenchmark dataset=$DATASET output=$CAPABILITY natural=$ABLATION target=$CAPABILITY_TARGET threads=$THREADS heap=$MAX_HEAP seed=$SEED
EOF

mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" \
  -d "$RUN_ROOT/build/classes" "${sources[@]}"
jar --create --file "$JAR" -C "$RUN_ROOT/build/classes" .
rm -rf "$RUN_ROOT/build/classes"

python3 "$ROOT/scripts/publication_manifest.py" create \
  --repo "$ROOT" --dataset "$DATASET" --jar "$JAR" --commands "$COMMANDS" \
  --manifest "$MANIFEST" --workers "$THREADS" --heap "$MAX_HEAP" \
  --seed "$SEED" --capability-target "$CAPABILITY_TARGET" \
  --limit "$LIMIT" --reward-pool "$REWARD_POOL"

assert_identity() {
  python3 "$ROOT/scripts/publication_manifest.py" verify --manifest "$MANIFEST"
}

record_stage() {
  python3 "$ROOT/scripts/publication_manifest.py" record-stage \
    --manifest "$MANIFEST" --name "$1" --root "$2" --command "$3"
  assert_identity
}

classpath="$JAR:$ROOT/lib/*"
assert_identity
java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.CanonicalBatchTest "$DATASET" "$DISTANCE" \
  --threads "$THREADS" "${reward_args[@]}" "${limit_args[@]}"
record_stage canonical-batch "$DISTANCE" "$(sed -n '1p' "$COMMANDS")"

java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.Alloy4FunAugmenter "$DATASET" "$AUGMENTED" \
  --threads "$THREADS" "${reward_args[@]}" "${limit_args[@]}"
record_stage alloy4fun-augmenter "$AUGMENTED" "$(sed -n '2p' "$COMMANDS")"

ACGN_EXPERIMENT_JAR="$JAR" "$ROOT/scripts/run_egraph_ablation.sh" \
  --input "$DATASET" --output "$ABLATION" --threads "$THREADS" \
  --max-heap "$MAX_HEAP" --seed "$SEED" "${limit_args[@]}"
assert_identity
java -Xmx"$MAX_HEAP" -XX:+ExitOnOutOfMemoryError -cp "$classpath" \
  is.fivefivefive.CanDis.EGraphSemanticSoundnessCheck \
  --input "$DATASET" --results "$ABLATION" --threads "$THREADS"
python3 "$ROOT/scripts/publication_manifest.py" bind-semantic \
  --manifest "$MANIFEST" --results "$ABLATION" \
  --checker-source "$ROOT/src/is/fivefivefive/CanDis/EGraphSemanticSoundnessCheck.java"
record_stage ablation-and-semantic-check "$ABLATION" \
  "$(sed -n '3,4p' "$COMMANDS" | tr '\n' ';')"

ACGN_EXPERIMENT_JAR="$JAR" "$ROOT/scripts/run_capability_benchmark.sh" \
  --dataset "$DATASET" --output "$CAPABILITY" --natural "$ABLATION" \
  --target "$CAPABILITY_TARGET" --threads "$THREADS" \
  --max-heap "$MAX_HEAP" --seed "$SEED"
record_stage capability "$CAPABILITY" "$(sed -n '5p' "$COMMANDS")"

cat > "$RUN_ROOT/summary.md" <<EOF
# Publication Experiment Run

- Run manifest: \`$MANIFEST\`
- Commit: \`$(git -C "$ROOT" rev-parse HEAD)\`
- Dataset: \`$DATASET\`
- Workers: $THREADS
- Heap: \`$MAX_HEAP\`

| Stage | Summary | Machine-readable data |
| --- | --- | --- |
| Canonical batch | \`$DISTANCE/summary.md\` | \`$DISTANCE/distances.json\` |
| Augmentation | \`$AUGMENTED/summary.md\` | \`$AUGMENTED/index.json\` |
| Ablation | \`$ABLATION/summary.md\` | \`$ABLATION/comparison.json\` |
| Semantic checker | \`$ABLATION/semantic_soundness.md\` | \`$ABLATION/semantic_soundness.json\` |
| Capability | \`$CAPABILITY/REPORT.md\` | \`$CAPABILITY/results.json\` |
EOF

bind_report() {
  local report="$1"
  shift
  local arguments=()
  for source in "$@"; do arguments+=(--source "$source"); done
  python3 "$ROOT/scripts/publication_manifest.py" bind-report \
    --manifest "$MANIFEST" --report "$report" "${arguments[@]}"
}
bind_report "$DISTANCE/summary.md" "$DISTANCE/distances.json"
bind_report "$AUGMENTED/summary.md" "$AUGMENTED/index.json"
bind_report "$ABLATION/summary.md" "$ABLATION/comparison.json" "$ABLATION/run-manifest.json"
bind_report "$ABLATION/semantic_soundness.md" "$ABLATION/semantic_soundness.json"
bind_report "$CAPABILITY/REPORT.md" "$CAPABILITY/results.json" "$CAPABILITY/arms/run-manifest.json"
bind_report "$RUN_ROOT/summary.md" "$DISTANCE/summary.md" "$AUGMENTED/summary.md" \
  "$ABLATION/summary.md" "$ABLATION/semantic_soundness.md" "$CAPABILITY/REPORT.md"

python3 "$ROOT/scripts/publication_manifest.py" finalize --manifest "$MANIFEST"
printf 'Publication run completed and verified: %s\n' "$RUN_ROOT"
