#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$(mktemp -d /tmp/acgn-egraph-ablation.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT

javac -cp "$ROOT/lib/*" -d "$BUILD_DIR" $(find "$ROOT/src" -name '*.java')
cd "$ROOT"
java -cp "$BUILD_DIR:$ROOT/lib/*" is.fivefivefive.CanDis.EGraphAblationSuite "$@"
