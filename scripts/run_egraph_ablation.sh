#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR=""
if [[ -n "${ACGN_EXPERIMENT_JAR:-}" ]]; then
  [[ -f "$ACGN_EXPERIMENT_JAR" ]] \
    || { printf 'ACGN_EXPERIMENT_JAR is missing: %s\n' "$ACGN_EXPERIMENT_JAR" >&2; exit 2; }
  classpath="$ACGN_EXPERIMENT_JAR:$ROOT/lib/*"
else
  BUILD_DIR="$(mktemp -d /tmp/acgn-egraph-ablation.XXXXXX)"
  trap 'rm -rf "$BUILD_DIR"' EXIT
  mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
  javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" \
    -d "$BUILD_DIR" "${sources[@]}"
  classpath="$BUILD_DIR:$ROOT/lib/*"
fi
cd "$ROOT"
java -cp "$classpath" is.fivefivefive.CanDis.EGraphAblationSuite "$@"
