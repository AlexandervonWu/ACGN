#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR=""
if [[ -n "${ACGN_EXPERIMENT_JAR:-}" ]]; then
  [[ -f "$ACGN_EXPERIMENT_JAR" ]] \
    || { printf 'ACGN_EXPERIMENT_JAR is missing: %s\n' "$ACGN_EXPERIMENT_JAR" >&2; exit 2; }
  classpath="$ACGN_EXPERIMENT_JAR:$ROOT/lib/*"
else
  BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/acgn-egraph-ablation.XXXXXX")"
  trap 'rm -rf "$BUILD_DIR"' EXIT
  ablation_src="$ROOT/src/is/fivefivefive/CanDis"
  # EqualityCertificates.java also declares the package-private DerivedEqualityCertificate.
  javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -sourcepath "$ROOT/src" -d "$BUILD_DIR" \
    "$ablation_src/EGraphAblationSuite.java" "$ablation_src/EGraphAblationStudy.java" \
    "$ablation_src/theory/EqualityCertificates.java"
  classpath="$BUILD_DIR:$ROOT/lib/*"
fi
cd "$ROOT"
java -cp "$classpath" is.fivefivefive.CanDis.EGraphAblationSuite "$@"
