#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
DATA="${1:-synthetic-data/slot-binding-stress}"
OUT="${2:-/tmp/acgn-slot-binding-validation}"
ALLOY62="${ALLOY62_JAR:-$HOME/.m2/repository/org/alloytools/org.alloytools.alloy.dist/6.2.0/org.alloytools.alloy.dist-6.2.0.jar}"
[[ -f "$ALLOY62" ]] || { echo 'Set ALLOY62_JAR to the Alloy 6.2.0 distribution JAR' >&2; exit 2; }
mkdir -p "$OUT"
python3 scripts/generate_slot_binding_stress.py --output "$DATA" --check
lean docs/slot-typing-ablation/StressSchemas.lean > "$OUT/lean.log"
BUILD="$(mktemp -d /tmp/acgn-binding-validator.XXXXXX)"
trap 'rm -rf "$BUILD"' EXIT
javac --release 17 -encoding UTF-8 -cp "$ROOT/lib/*" -sourcepath "$ROOT/src" -d "$BUILD" \
  src/is/fivefivefive/CanDis/SlotBindingDatasetValidator.java
sha256sum "$ALLOY62" "$ROOT/lib/alloy.jar" > "$OUT/parser-hashes.txt"
java -Xmx2g -Xss16m -cp "$ALLOY62:$BUILD:$ROOT/lib/*" \
  is.fivefivefive.CanDis.SlotBindingDatasetValidator "$DATA" "$OUT/alloy-6.2.json"
java -Xmx2g -Xss16m -Dacgn.validateAdapter=true -cp "$BUILD:$ROOT/lib/*" \
  is.fivefivefive.CanDis.SlotBindingDatasetValidator "$DATA" "$OUT/bundled-parser.json"
mapfile -t families < <(python3 -c 'import json,sys; print("\n".join(x["family"] for x in json.load(open(sys.argv[1]))["reducedProbes"]))' "$DATA/manifest.json")
for family in "${families[@]}"; do
  timeout 60s java -Xmx2g -Xss16m -cp "$ALLOY62:$BUILD:$ROOT/lib/*" \
    is.fivefivefive.CanDis.SlotBindingDatasetValidator "$DATA" "$OUT/probes/$family.json" "$family" \
    > "$OUT/$family.log" 2>&1
done
echo "Validation complete; reports in $OUT. No rewriting benchmark was run."
