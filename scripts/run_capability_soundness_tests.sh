#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="${1:-$(mktemp -d /tmp/acgn-capability-soundness.XXXXXX)}"
mkdir -p "$work/classes"
mapfile -t sources < <(find "$ROOT/src" -name '*.java' -type f | sort)
javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -d "$work/classes" "${sources[@]}"
"${LEAN_BIN:-lean}" -o "$work/TemporalCommandGuard.olean" \
  "$ROOT/docs/temporal-capability-solver/TemporalCommandGuard.lean" > "$work/lean.log" 2>&1
"${LEAN_BIN:-lean}" -o "$work/Phase5SourceRules.olean" \
  "$ROOT/docs/section3-repair-audit/formal/Phase5SourceRules.lean" > "$work/temporal-duals-lean.log" 2>&1
java -ea -Xmx1g -cp "$work/classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.CapabilitySoundnessCheckTest > "$work/regression.log" 2>&1
java -ea -Xmx1g -cp "$work/classes:$ROOT/lib/*" \
  is.fivefivefive.CanDis.CapabilitySoundnessCheck \
  --root "$ROOT/capability_benchmark" --output "$work/sample" --per-subtype 1 \
  > "$work/sample.log" 2>&1
printf 'Capability soundness tests passed; evidence: %s\n' "$work"
