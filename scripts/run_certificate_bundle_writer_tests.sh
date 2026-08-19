#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="${1:-/tmp/acgn-certificate-bundle-writer}"
producer_classes="$work/producer-classes"
fixtures="$work/fixtures"

rm -rf "$work"
mkdir -p "$producer_classes" "$fixtures"

"$repo_root/scripts/run_certificate_verifier_tests.sh"

mapfile -t producer_sources < <(find "$repo_root/src" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -cp "$repo_root/lib/*" \
  -d "$producer_classes" "${producer_sources[@]}"

java -ea -cp "$producer_classes:$repo_root/lib/*" \
  is.fivefivefive.CanDis.theory.CertificateBundleWriterTest "$fixtures"

verifier_jar="$repo_root/certificate-verifier/build/acgn-certificate-verifier.jar"
verifier_tests="$repo_root/certificate-verifier/build/test-classes"
java -ea -cp "$verifier_jar:$verifier_tests" \
  org.acgn.cert.ProducerBundleInspectionTest \
  "$fixtures/nullary-a.acgncert" \
  "$fixtures/nullary-b.acgncert" \
  "$fixtures/slot-only-a.acgncert" \
  "$fixtures/slot-only-b.acgncert" \
  "$fixtures/parent-path-a.acgncert" \
  "$fixtures/parent-path-b.acgncert"

for artifact in nullary-a slot-only-a parent-path-a; do
  bundle="$fixtures/$artifact.acgncert"
  theory_digest="$(java -cp "$verifier_jar" \
    org.acgn.cert.ManifestInspector "$bundle")"
  java -jar "$verifier_jar" \
    --profile full \
    --theory-digest "$theory_digest" \
    "$bundle"
done

nullary_digest="$(java -cp "$verifier_jar" \
  org.acgn.cert.ManifestInspector "$fixtures/nullary-a.acgncert")"
java -jar "$verifier_jar" \
  --profile pair \
  --theory-digest "$nullary_digest" \
  "$fixtures/nullary-a.acgncert" \
  "$fixtures/nullary-b.acgncert"

printf 'certificate writer bridge verified; fixtures=%s\n' "$fixtures"
