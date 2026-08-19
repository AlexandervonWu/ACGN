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
pins="$repo_root/certificate-verifier/trusted/theory-pins.tsv"

pin_digest() {
  local pin_id="$1"
  local digest
  digest="$(awk -F '\t' -v pin_id="$pin_id" \
    'NR > 1 && $1 == pin_id { print $8 }' "$pins")"
  if [[ ! "$digest" =~ ^[0-9a-f]{64}$ ]]; then
    printf 'missing or malformed static theory pin %s in %s\n' \
      "$pin_id" "$pins" >&2
    exit 1
  fi
  printf '%s' "$digest"
}

empty_theory_digest="$(pin_digest fixture-empty-theory-v1)"
parent_theory_digest="$(pin_digest fixture-parent-path-theory-v1)"

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
  "$repo_root" "$producer_jar" "$verifier_jar" \
  "$empty_theory_digest" "$parent_theory_digest"

java -ea -cp "$verifier_classes:$verifier_tests" \
  org.acgn.cert.TrustedTheoryPinsTest \
  "$pins" \
  "$run_a/nullary-a.acgncert" \
  "$run_a/slot-only-a.acgncert" \
  "$run_a/parent-path-a.acgncert"

for name in "${expected[@]}"; do
  selected_digest="$empty_theory_digest"
  if [[ "$name" == parent-path-* ]]; then
    selected_digest="$parent_theory_digest"
  fi
  artifact_digest="$(
    java -cp "$verifier_jar" org.acgn.cert.ManifestInspector "$run_a/$name"
  )"
  if [[ "$artifact_digest" != "$selected_digest" ]]; then
    printf 'bundle %s has theory %s but static pin selects %s\n' \
      "$name" "$artifact_digest" "$selected_digest" >&2
    exit 1
  fi
  java -jar "$verifier_jar" \
    --profile full \
    --theory-digest "$selected_digest" \
    "$run_a/$name" >/dev/null
done

java -jar "$verifier_jar" \
  --profile pair \
  --theory-digest "$empty_theory_digest" \
  "$run_a/pair-equivalent-left.acgncert" \
  "$run_b/pair-equivalent-right.acgncert" >/dev/null

set +e
java -jar "$verifier_jar" \
  --profile pair \
  --theory-digest "$empty_theory_digest" \
  "$run_a/pair-equivalent-left.acgncert" \
  "$run_b/pair-non-equivalent.acgncert" >/dev/null
non_equivalent_status=$?
set -e
if [[ "$non_equivalent_status" -ne 3 ]]; then
  printf 'non-equivalent PAIR returned %s instead of UNCHECKABLE (3)\n' \
    "$non_equivalent_status" >&2
  exit 1
fi

set +e
wrong_pin_output="$(java -jar "$verifier_jar" \
  --profile full \
  --theory-digest "$parent_theory_digest" \
  "$run_a/nullary-a.acgncert")"
wrong_pin_status=$?
set -e
if [[ "$wrong_pin_status" -ne 2 \
    || "$wrong_pin_output" != *'"outcome":"REJECTED"'* \
    || "$wrong_pin_output" != *'"code":"UNTRUSTED_THEORY"'* ]]; then
  printf 'wrong static pin did not yield REJECTED / UNTRUSTED_THEORY: %s\n' \
    "$wrong_pin_output" >&2
  exit 1
fi

java -ea "${provenance_options[@]}" -cp "$producer_cp" \
  is.fivefivefive.CanDis.CertificateVerifierExportSmoke \
  "$smoke" "$empty_theory_digest"

mapfile -t smoke_files < <(
  find "$smoke" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' | sort
)
expected_smoke=(
  coverage-census.tsv
  nullary.acgncert
  parsed-pair-left.acgncert
  parsed-pair-left.als
  parsed-pair-right.acgncert
  parsed-pair-right.als
)
if [[ "${smoke_files[*]}" != "${expected_smoke[*]}" ]]; then
  printf 'unexpected export-smoke files: %s\n' "${smoke_files[*]}" >&2
  exit 1
fi

awk -F '\t' '
  NR == 1 {
    if ($1 != "predicate" || $3 != "status" || $4 != "code") exit 10
    next
  }
  $1 == "nullary" && $3 == "VERIFIED" && $4 == "NONE" { nullary++ }
  $1 == "slotBearing" && $3 == "UNCHECKABLE" \
      && $4 == "EXPORT_UNSUPPORTED" { slot++ }
  $1 == "deliberatelyUnsupported" && $3 == "UNCHECKABLE" \
      && $4 == "EXPORT_UNSUPPORTED" { unsupported++ }
  $3 == "REJECTED" { rejected++ }
  END {
    if (NR != 4 || nullary != 1 || slot != 1 || unsupported != 1 \
        || rejected != 0) exit 11
  }
' "$smoke/coverage-census.tsv"

java -ea -cp "$verifier_classes:$verifier_tests" \
  org.acgn.cert.ParsedSourcePairInspectionTest \
  "$smoke/parsed-pair-left.acgncert" \
  "$smoke/parsed-pair-right.acgncert" \
  "$smoke/parsed-pair-left.als" \
  "$smoke/parsed-pair-right.als" \
  "$empty_theory_digest"

printf 'certificate producer/verifier harness passed; work=%s empty=%s parent=%s\n' \
  "$work" "$empty_theory_digest" "$parent_theory_digest"
