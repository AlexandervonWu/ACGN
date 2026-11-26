#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
bash scripts/proven-rules/build.sh "$tmp/classes"
javac --release 17 -proc:none -encoding UTF-8 -sourcepath '' -cp "$tmp/classes:lib/*" -d "$tmp/classes" scripts/proven-rules/tests/*.java
for test in ClassifierControls FiberWitnessControls SplitClassifierControls ClassifiedSetControls ReleaseRulesTest DefaultScopeTest; do
    java -ea -Xmx512m -Dorg.slf4j.simpleLogger.defaultLogLevel=warn -cp "$tmp/classes:lib/*" \
        "is.fivefivefive.CanDis.augmentation.$test" "$tmp/fixture.als"
done
export LEAN_PATH="$tmp" LC_ALL=C
modules=(Phase5SourceRules AdaptiveVisibleDiagonal AdaptiveRelationalImage AdaptivePhaseAlgebra AdaptiveUniquePreimage AdaptiveOwnerFiber AdaptiveCardinality AdaptiveCountingFiber AdaptiveDifferenceCount AdaptiveEndpointBounds AdaptiveRoleSupport AdaptiveHomogeneousRows AdaptiveMixedRowCounting AdaptiveFutureFrames AdaptiveFramedRowCounts AdaptiveClassifier AdaptiveFiberWitness AdaptiveClassifierArms AdaptiveClassifierProjection AdaptiveRoleCounting AdaptiveMixedReadLaws)
for mod in "${modules[@]}"; do
    lean -DwarningAsError=true -o "$tmp/$mod.olean" "docs/section3-repair-audit/formal/$mod.lean"
done
python3 scripts/proven-rules/audit_lean.py "${modules[@]}"
