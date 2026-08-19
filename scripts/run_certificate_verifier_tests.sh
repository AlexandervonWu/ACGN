#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
module="$repo_root/certificate-verifier"
build="$module/build"
test_classes="$build/test-classes"

"$repo_root/scripts/build_certificate_verifier.sh"
mkdir -p "$test_classes"

mapfile -t tests < <(find "$module/test" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -Xlint:all -Werror \
  -cp "$build/acgn-certificate-verifier.jar" \
  -d "$test_classes" "${tests[@]}"

java -ea -cp "$build/acgn-certificate-verifier.jar:$test_classes" \
  org.acgn.cert.VerifierTest
