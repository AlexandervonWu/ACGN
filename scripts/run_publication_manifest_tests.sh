#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="$(mktemp -d /tmp/acgn-publication-manifest-test.XXXXXX)"
trap 'rm -rf "$work"' EXIT
run_root="$work/run"
dataset="$work/dataset"
stage="$run_root/stage"
fixture_repo="$work/repository"
mkdir -p "$run_root/build/empty" "$dataset" "$stage/arm" \
  "$fixture_repo/src" "$fixture_repo/lib"

cp "$ROOT/src/is/fivefivefive/CanDis/EGraphSemanticSoundnessCheck.java" \
  "$fixture_repo/src/EGraphSemanticSoundnessCheck.java"
dependency="$(find "$ROOT/lib" -name '*.jar' -type f | sort | head -n 1)"
cp "$dependency" "$fixture_repo/lib/$(basename "$dependency")"
git -C "$fixture_repo" init -q
git -C "$fixture_repo" config user.name 'ACGN Manifest Test'
git -C "$fixture_repo" config user.email 'manifest-test@example.invalid'
git -C "$fixture_repo" add src lib
git -C "$fixture_repo" commit -q -m fixture

printf 'pred p {}\n' > "$dataset/example.als"
printf 'bounded manifest test\n' > "$run_root/planned-commands.txt"
jar --create --file "$run_root/build/test-experiment.jar" \
  -C "$run_root/build/empty" .
printf 'path,status\nexample.als,CORRECT\n' > "$stage/arm/pairs.csv"
printf '{"violations":0}\n' > "$stage/semantic_soundness.json"
printf 'path,outcome\n' > "$stage/semantic_counterexamples.csv"
printf '# Semantic smoke\n' > "$stage/semantic_soundness.md"
printf '{"value":1}\n' > "$stage/source.json"
printf '# Generated report\n' > "$stage/report.md"

manifest="$run_root/run-manifest.json"
python3 "$ROOT/scripts/publication_manifest.py" create \
  --repo "$fixture_repo" --dataset "$dataset" \
  --jar "$run_root/build/test-experiment.jar" \
  --commands "$run_root/planned-commands.txt" --manifest "$manifest" \
  --workers 1 --heap 256m --seed 1 --capability-target 1
python3 "$ROOT/scripts/publication_manifest.py" bind-semantic \
  --manifest "$manifest" --results "$stage" \
  --checker-source "$ROOT/src/is/fivefivefive/CanDis/EGraphSemanticSoundnessCheck.java"
python3 "$ROOT/scripts/publication_manifest.py" bind-report \
  --manifest "$manifest" --report "$stage/report.md" \
  --source "$stage/source.json"
python3 "$ROOT/scripts/publication_manifest.py" record-stage \
  --manifest "$manifest" --name bounded-test --root "$stage" \
  --command 'bounded manifest test'
python3 "$ROOT/scripts/publication_manifest.py" finalize --manifest "$manifest"

printf '\ndrift\n' >> "$stage/report.md"
if python3 "$ROOT/scripts/publication_manifest.py" verify \
    --manifest "$manifest" --require-complete; then
  printf 'Manifest drift check accepted a changed generated report\n' >&2
  exit 1
fi
printf 'Publication manifest and report-drift tests passed\n'
