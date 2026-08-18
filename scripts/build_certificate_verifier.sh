#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
module="$repo_root/certificate-verifier"
build="$module/build"
classes="$build/classes"
jar_file="$build/acgn-certificate-verifier.jar"

rm -rf "$build"
mkdir -p "$classes"

mapfile -t sources < <(find "$module/src" -name '*.java' -type f | sort)
javac --release 17 -Xlint:all -Werror -d "$classes" "${sources[@]}"
jar --create --file "$jar_file" --main-class org.acgn.cert.Main -C "$classes" .

if rg -n '^import is\.fivefivefive\.CanDis\.(theory|adapter|canonical|metric)|CanonicalAlloyPipeline|CanonicalDistance' \
    "$module/src"; then
  echo "forbidden producer dependency found in certificate verifier" >&2
  exit 1
fi

dependency_summary="$(jdeps -summary "$jar_file")"
printf '%s\n' "$dependency_summary"
if [[ "$dependency_summary" != "acgn-certificate-verifier.jar -> java.base" ]]; then
  echo "standalone verifier has a dependency outside java.base" >&2
  exit 1
fi

printf 'built %s\n' "$jar_file"
