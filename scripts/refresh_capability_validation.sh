#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT="${1:?Usage: refresh_capability_validation.sh OUTPUT [BENCHMARK_ROOT] [PER_SUBTYPE]}"
BENCHMARK="${2:-$ROOT/capability_benchmark}"
PER_SUBTYPE="${3:-1}"
HEAP="${ACGN_VALIDATION_HEAP:-1g}"
LEAN="${LEAN_BIN:-lean}"
OUTPUT="$(realpath -m "$OUTPUT")"
BENCHMARK="$(realpath "$BENCHMARK")"
[[ "$PER_SUBTYPE" =~ ^[1-9][0-9]*$ ]] || { printf 'PER_SUBTYPE must be positive\n' >&2; exit 2; }
case "$OUTPUT/" in "$ROOT"/*) printf 'Output must be outside the worktree\n' >&2; exit 2 ;; esac
if [[ -e "$OUTPUT" ]] && [[ -n "$(find "$OUTPUT" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  printf 'Output must be new or empty: %s\n' "$OUTPUT" >&2
  exit 2
fi
[[ -z "$(git -C "$ROOT" status --porcelain --untracked-files=all)" ]] \
  || { printf 'Validation publication requires a clean worktree\n' >&2; exit 1; }
cd "$ROOT"
mkdir -p "$OUTPUT/build/classes" "$OUTPUT/inputs" "$OUTPUT/capability_validation" "$OUTPUT/proofs"
JAR="$OUTPUT/build/acgn-experiments.jar"
MANIFEST="$OUTPUT/run-manifest.json"
PLAN="$OUTPUT/planned-commands.txt"
cp "$BENCHMARK/metadata.csv" "$BENCHMARK/metadata.json" "$OUTPUT/inputs/"
cp "$ROOT/lean-toolchain" "$OUTPUT/inputs/"
cp "$ROOT/docs/temporal-capability-solver/TemporalCommandGuard.lean" "$OUTPUT/inputs/"
cp "$ROOT/docs/section3-repair-audit/formal/Phase5SourceRules.lean" "$OUTPUT/inputs/"
cp "$ROOT/scripts/refresh_capability_validation.sh" "$ROOT/scripts/publication_manifest.py" "$OUTPUT/inputs/"
config="$(python3 -c 'import json,sys; m=json.load(open(sys.argv[1], encoding="utf-8")); print(m["rngSeed"], m["targetPerFamily"])' "$OUTPUT/inputs/metadata.json")"
read -r seed target <<< "$config"

mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
compile=(javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$OUTPUT/build/classes" "${sources[@]}")
package=(jar --create --file "$JAR" -C "$OUTPUT/build/classes" .)
guard=("$LEAN" -o "$OUTPUT/proofs/TemporalCommandGuard.olean" "$OUTPUT/inputs/TemporalCommandGuard.lean")
duals=("$LEAN" -o "$OUTPUT/proofs/Phase5SourceRules.olean" "$OUTPUT/inputs/Phase5SourceRules.lean")
regression=(java -ea -Xmx"$HEAP" -XX:+ExitOnOutOfMemoryError -cp "$JAR:$ROOT/lib/*" is.fivefivefive.CanDis.CapabilitySoundnessCheckTest)
sample=(java -ea -Xmx"$HEAP" -XX:+ExitOnOutOfMemoryError -cp "$JAR:$ROOT/lib/*" is.fivefivefive.CanDis.CapabilitySoundnessCheck --root "$BENCHMARK" --output "$OUTPUT/capability_validation" --per-subtype "$PER_SUBTYPE")
for command in compile package guard duals regression sample; do
  declare -n planned="$command"
  printf '%q ' "${planned[@]}"
  printf '\n'
done > "$PLAN"
"${compile[@]}" > "$OUTPUT/build/compile.log" 2>&1
"${package[@]}" > "$OUTPUT/build/package.log" 2>&1
rm -rf "$OUTPUT/build/classes"
python3 -B "$ROOT/scripts/publication_manifest.py" create \
  --repo "$ROOT" --dataset "$BENCHMARK/models" --jar "$JAR" --commands "$PLAN" \
  --manifest "$MANIFEST" --workers 1 --heap "$HEAP" --seed "$seed" --capability-target "$target"
"$LEAN" --version > "$OUTPUT/proofs/lean-version.log" 2>&1
"${guard[@]}" > "$OUTPUT/proofs/guard.log" 2>&1
"${duals[@]}" > "$OUTPUT/proofs/duals.log" 2>&1
"${regression[@]}" > "$OUTPUT/capability_validation/regression.log" 2>&1
"${sample[@]}" > "$OUTPUT/capability_validation/solver.log" 2>&1
cmp "$BENCHMARK/metadata.csv" "$OUTPUT/inputs/metadata.csv"
cmp "$BENCHMARK/metadata.json" "$OUTPUT/inputs/metadata.json"
python3 - "$OUTPUT/inputs/metadata.csv" "$OUTPUT/capability_validation/soundness.json" "$PER_SUBTYPE" <<'PY'
import collections
import csv
import json
import sys

with open(sys.argv[1], encoding="utf-8", newline="") as stream:
    rows = list(csv.DictReader(stream))
counts, selected = collections.Counter(), []
for row in rows:
    key = row["family"], row["subtype"]
    if counts[key] < int(sys.argv[3]):
        selected.append((row["relativePath"], *key))
        counts[key] += 1
with open(sys.argv[2], encoding="utf-8") as stream:
    report = json.load(stream)
checks = report["checks"]
actual = [(row["relativePath"], row["family"], row["subtype"]) for row in checks]
if not selected or actual != selected:
    raise SystemExit("Validation output does not match the frozen sample selection")
if any(row["inconclusive"] or row["solverReportedCounterexample"] or row["error"] for row in checks):
    raise SystemExit("Validation contains a failed or inconclusive check")
print(f"Validated frozen sample: {len(checks)} checks")
PY
python3 -B "$ROOT/scripts/publication_manifest.py" record-stage --manifest "$MANIFEST" \
  --name capability-validation --root "$OUTPUT/capability_validation" --command "$(printf '%q ' "${sample[@]}")"
python3 -B "$ROOT/scripts/publication_manifest.py" bind-report --manifest "$MANIFEST" \
  --report "$OUTPUT/capability_validation/SOUNDNESS.md" \
  --source "$OUTPUT/capability_validation/soundness.json" --source "$OUTPUT/inputs/metadata.csv"
python3 -B "$ROOT/scripts/publication_manifest.py" finalize --manifest "$MANIFEST"
printf 'Validation-only publication completed: %s\n' "$MANIFEST"
