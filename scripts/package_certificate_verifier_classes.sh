#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

if [[ $# != 2 ]]; then
  printf 'usage: %s CLASSES_DIRECTORY OUTPUT_JAR\n' "$0" >&2
  exit 64
fi
classes="$(realpath -- "$1")"
jar_file="$(realpath -m -- "$2")"
cd "$classes"
mapfile -t members < <(find . -type f -name '*.class' -printf '%P\n' | sort)
[[ -f org/acgn/cert/Main.class ]]
jar --create --file "$jar_file" --date=2000-01-01T00:00:00Z \
  --main-class org.acgn.cert.Main "${members[@]}"
