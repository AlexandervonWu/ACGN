#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="${1:-/tmp/acgn-certificate-bundle-writer}"
producer_classes="$work/producer-classes"
verifier_classes="$work/verifier-classes"
verifier_tests="$work/verifier-test-classes"
producer_jar="$work/acgn-producer.jar"
verifier_jar="$work/acgn-certificate-verifier.jar"
run_a="$work/writer-run-a"
run_b="$work/writer-run-b"
smoke="$work/export-smoke"

rm -rf "$work"
mkdir -p \
  "$producer_classes" "$verifier_classes" "$verifier_tests" \
  "$run_a" "$run_b" "$smoke"

mapfile -t verifier_sources < <(
  find "$repo_root/certificate-verifier/src" -name '*.java' -type f | sort
)
mapfile -t verifier_test_sources < <(
  find "$repo_root/certificate-verifier/test" -name '*.java' -type f | sort
)
mapfile -t producer_sources < <(
  find "$repo_root/src" -name '*.java' -type f | sort
)

javac --release 17 -encoding UTF-8 \
  -d "$verifier_classes" "${verifier_sources[@]}"
javac --release 17 -encoding UTF-8 \
  -cp "$verifier_classes" \
  -d "$verifier_tests" "${verifier_test_sources[@]}"
jar --create --file "$verifier_jar" \
  --main-class org.acgn.cert.Main \
  -C "$verifier_classes" .

javac --release 17 -encoding UTF-8 \
  -cp "$repo_root/lib/*" \
  -d "$producer_classes" "${producer_sources[@]}"
jar --create --file "$producer_jar" -C "$producer_classes" .

java -ea -cp "$verifier_classes:$verifier_tests" org.acgn.cert.VerifierTest
java -ea -cp "$producer_classes:$repo_root/lib/*" \
  is.fivefivefive.CanDis.theory.CertificateProvenanceTest

provenance_options=(
  "-Dacgn.repo.root=$repo_root"
  "-Dacgn.provenance.testOverride=true"
  "-Dacgn.provenance.producerJar=$producer_jar"
  "-Dacgn.provenance.verifierJar=$verifier_jar"
  "-Dacgn.provenance.createdAt=1970-01-01T00:00:00Z"
)
producer_cp="$producer_classes:$repo_root/lib/*"

java -ea "${provenance_options[@]}" -cp "$producer_cp" \
  is.fivefivefive.CanDis.theory.CertificateBundleWriterTest "$run_a"
java -ea "${provenance_options[@]}" -cp "$producer_cp" \
  is.fivefivefive.CanDis.theory.CertificateBundleWriterTest "$run_b"

expected=(
  nullary-a.acgncert
  nullary-b.acgncert
  slot-only-a.acgncert
  slot-only-b.acgncert
  parent-path-a.acgncert
  parent-path-b.acgncert
  pair-equivalent-left.acgncert
  pair-equivalent-right.acgncert
  pair-non-equivalent.acgncert
)

for directory in "$run_a" "$run_b"; do
  mapfile -t actual < <(
    find "$directory" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' | sort
  )
  mapfile -t wanted < <(printf '%s\n' "${expected[@]}" | sort)
  if [[ "${actual[*]}" != "${wanted[*]}" ]]; then
    printf 'unexpected fixture set in %s\nexpected: %s\nactual: %s\n' \
      "$directory" "${wanted[*]}" "${actual[*]}" >&2
    exit 1
  fi
done

for name in "${expected[@]}"; do
  cmp "$run_a/$name" "$run_b/$name"
  test "$(sha256sum "$run_a/$name" | cut -d' ' -f1)" = \
       "$(sha256sum "$run_b/$name" | cut -d' ' -f1)"
done

java -ea -cp "$verifier_classes:$verifier_tests" \
  org.acgn.cert.ProducerBundleInspectionTest \
  "$run_a/nullary-a.acgncert" \
  "$run_b/nullary-a.acgncert" \
  "$run_a/slot-only-a.acgncert" \
  "$run_b/slot-only-a.acgncert" \
  "$run_a/parent-path-a.acgncert" \
  "$run_b/parent-path-a.acgncert" \
  "$run_a/pair-equivalent-left.acgncert" \
  "$run_b/pair-equivalent-right.acgncert" \
  "$run_b/pair-non-equivalent.acgncert" \
  "$repo_root" "$producer_jar" "$verifier_jar"

theory_digest="$(
  java -cp "$verifier_jar" org.acgn.cert.ManifestInspector \
    "$run_a/nullary-a.acgncert"
)"
for name in "${expected[@]}"; do
  artifact_digest="$(
    java -cp "$verifier_jar" org.acgn.cert.ManifestInspector "$run_a/$name"
  )"
  java -jar "$verifier_jar" \
    --profile full \
    --theory-digest "$artifact_digest" \
    "$run_a/$name" >/dev/null
done

java -jar "$verifier_jar" \
  --profile pair \
  --theory-digest "$theory_digest" \
  "$run_a/pair-equivalent-left.acgncert" \
  "$run_b/pair-equivalent-right.acgncert" >/dev/null

set +e
java -jar "$verifier_jar" \
  --profile pair \
  --theory-digest "$theory_digest" \
  "$run_a/pair-equivalent-left.acgncert" \
  "$run_b/pair-non-equivalent.acgncert" >/dev/null
non_equivalent_status=$?
set -e
if [[ "$non_equivalent_status" -ne 3 ]]; then
  printf 'non-equivalent PAIR returned %s instead of UNCHECKABLE (3)\n' \
    "$non_equivalent_status" >&2
  exit 1
fi

java -ea "${provenance_options[@]}" -cp "$producer_cp" \
  is.fivefivefive.CanDis.CertificateVerifierExportSmoke "$smoke"

mapfile -t smoke_files < <(
  find "$smoke" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' | sort
)
expected_smoke=(coverage-census.tsv nullary.acgncert)
if [[ "${smoke_files[*]}" != "${expected_smoke[*]}" ]]; then
  printf 'unexpected export-smoke files: %s\n' "${smoke_files[*]}" >&2
  exit 1
fi

printf 'certificate producer/verifier harness passed; work=%s theory=%s\n' \
  "$work" "$theory_digest"
