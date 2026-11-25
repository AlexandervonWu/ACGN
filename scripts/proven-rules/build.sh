#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
[[ $# == 1 ]] || { echo "usage: build.sh NEW_CLASS_DIRECTORY" >&2; exit 2; }
classes=$(realpath -m -- "$1")
mkdir -- "$classes"
printf '%s  %s\n' 8a8746b89d95f28762903c9acbd2bee8aca5014fe49a522b7184ba32ffcc5b58 lib/alloy.jar | sha256sum --quiet -c -
javac --release 17 -g -proc:none -encoding UTF-8 -sourcepath '' -cp 'lib/*' -d "$classes" scripts/proven-rules/parser/CompUtil.java
javac --release 17 -proc:none -encoding UTF-8 -sourcepath '' -cp "$classes:lib/*" -d "$classes" \
    src/is/fivefivefive/CanDis/ProvenRewriteRule.java scripts/proven-rules/java/*.java
