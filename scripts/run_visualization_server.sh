#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$(mktemp -d /tmp/acgn-visualization-server.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT

mapfile -d '' SOURCES < <(find "$ROOT/src" -name '*.java' -type f -print0)
javac -encoding UTF-8 --release 17 -cp "$ROOT/lib/*" -d "$BUILD_DIR" "${SOURCES[@]}"

cd "$ROOT"
java --add-modules jdk.httpserver \
  -cp "$BUILD_DIR:$ROOT/lib/*" \
  is.fivefivefive.CanDis.VisualizationServer "$@"
