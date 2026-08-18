#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SOURCE="$ROOT/src/is/fivefivefive/CanDis/core"
OUTPUT=${1:-"$ROOT/build/candis-core"}
CLASSES="$OUTPUT/classes"
JAR="$OUTPUT/candis-core.jar"

rm -rf "$CLASSES"
mkdir -p "$CLASSES"
find "$SOURCE" -name '*.java' -print0 | xargs -0 javac -d "$CLASSES"
jar --create --file "$JAR" -C "$CLASSES" .

printf 'Wrote %s\n' "$JAR"
