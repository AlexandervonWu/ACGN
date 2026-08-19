#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
count="${1:-100}"
work="${2:-/tmp/acgn-certificate-verifier-smoke}"
producer_classes="$work/producer-classes"
run_a="$work/run-a"
run_b="$work/run-b"

rm -rf "$work"
mkdir -p "$producer_classes" "$run_a" "$run_b"

"$repo_root/scripts/run_certificate_verifier_tests.sh"

mapfile -t producer_sources < <(find "$repo_root/src" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -cp "$repo_root/lib/*" \
  -d "$producer_classes" "${producer_sources[@]}"

java -cp "$producer_classes:$repo_root/lib/*" \
  is.fivefivefive.CanDis.CertificateVerifierExportSmoke "$run_a" "$count"
java -cp "$producer_classes:$repo_root/lib/*" \
  is.fivefivefive.CanDis.CertificateVerifierExportSmoke "$run_b" "$count"

jar_file="$repo_root/certificate-verifier/build/acgn-certificate-verifier.jar"
first="$run_a/preparation-000.acgncert"
theory_digest="$(java -cp "$jar_file" org.acgn.cert.ManifestInspector "$first")"

for ((index = 0; index < count; index++)); do
  name="$(printf 'preparation-%03d.acgncert' "$index")"
  cmp "$run_a/$name" "$run_b/$name"
  java -jar "$jar_file" \
    --profile full \
    --theory-digest "$theory_digest" \
    "$run_a/$name" >/dev/null
done

java -jar "$jar_file" \
  --profile pair \
  --theory-digest "$theory_digest" \
  "$run_a/preparation-000.acgncert" \
  "$run_b/preparation-000.acgncert"

printf 'verified %s deterministic exact preparations; theory=%s\n' \
  "$count" "$theory_digest"
