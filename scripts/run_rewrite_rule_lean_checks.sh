#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALOG="$ROOT/docs/section3-repair-audit/rewrite-rule-traceability.tsv"
EXPECTED_TOOLCHAIN="leanprover/lean4:v4.33.0"

if ! command -v rg >/dev/null 2>&1; then
  printf 'ripgrep is required for fail-closed proof-escape scanning\n' >&2
  exit 1
fi

if [[ ! -f "$ROOT/lean-toolchain" ]]; then
  printf 'missing Lean toolchain pin: %s\n' "$ROOT/lean-toolchain" >&2
  exit 1
fi
actual_toolchain="$(tr -d '\r\n' <"$ROOT/lean-toolchain")"
if [[ "$actual_toolchain" != "$EXPECTED_TOOLCHAIN" ]]; then
  printf 'unexpected Lean toolchain: expected=%s actual=%s\n' \
    "$EXPECTED_TOOLCHAIN" "$actual_toolchain" >&2
  exit 1
fi

lean_bin="${LEAN_BIN:-}"
if [[ -z "$lean_bin" ]]; then
  lean_bin="$(command -v lean || true)"
fi
if [[ -z "$lean_bin" || ! -x "$lean_bin" ]]; then
  printf 'Lean executable is unavailable\n' >&2
  exit 1
fi
lean_version="$("$lean_bin" --version | head -n 1)"
if [[ "$lean_version" != "Lean (version 4.33.0,"* ]]; then
  printf 'unexpected Lean executable: %s\n' "$lean_version" >&2
  exit 1
fi

if [[ ! -f "$CATALOG" ]]; then
  printf 'missing rewrite-rule catalog: %s\n' "$CATALOG" >&2
  exit 1
fi
header="$(head -n 1 "$CATALOG")"
expected_header=$'rule_id\tscope\trule\tbaseline_name\tlean_refs\tjava_refs\ttest_refs\tstatus\tnotes'
if [[ "$header" != "$expected_header" ]]; then
  printf 'unexpected rewrite-rule catalog header\n' >&2
  exit 1
fi

python3 "$ROOT/scripts/check_rewrite_dispatch_parity.py" --root "$ROOT"

work="$(mktemp -d /tmp/acgn-rewrite-rule-lean.XXXXXX)"
cleanup() {
  if [[ "$work" == /tmp/acgn-rewrite-rule-lean.* && -d "$work" ]]; then
    rm -rf -- "$work"
  fi
}
trap cleanup EXIT

mapped_file="$work/mapped-lean-files.txt"
if ! awk -F '\t' '
  NR > 1 && $0 !~ /^#/ && $0 !~ /^[[:space:]]*$/ {
    if (NF != 9 || $5 == "") {
      printf "malformed rewrite catalog row %d\n", NR > "/dev/stderr"
      exit 1
    }
    count = split($5, references, ";")
    for (i = 1; i <= count; i++) {
      separator = index(references[i], "#")
      if (separator <= 1 || separator == length(references[i])) {
        printf "malformed Lean reference on catalog row %d\n", NR > "/dev/stderr"
        exit 1
      }
      if (index(substr(references[i], separator + 1), "#") != 0) {
        printf "multiple fragment separators on catalog row %d\n", NR > "/dev/stderr"
        exit 1
      }
      print substr(references[i], 1, separator - 1)
    }
  }
' "$CATALOG" | sort -u >"$mapped_file"; then
  printf 'failed to parse rewrite-rule Lean source inventory\n' >&2
  exit 1
fi
mapfile -t mapped_lean_files <"$mapped_file"
if [[ "${#mapped_lean_files[@]}" -eq 0 ]]; then
  printf 'rewrite-rule catalog names no Lean sources\n' >&2
  exit 1
fi

formal_root="$(realpath -e "$ROOT/docs/section3-repair-audit/formal")"
forbidden_lean='\b(sorry|sorryAx|admit|axiom|unsafe|native_decide|extern|partial|implemented_by)\b|\bLean\.ofReduceBool\b'
for relative_lean_file in "${mapped_lean_files[@]}"; do
  if [[ "$relative_lean_file" != docs/section3-repair-audit/formal/*.lean ]]; then
    printf 'rewrite Lean source is outside the governed directory: %s\n' \
      "$relative_lean_file" >&2
    exit 1
  fi
  if [[ ! -f "$ROOT/$relative_lean_file" ]]; then
    printf 'missing rewrite Lean source: %s\n' "$relative_lean_file" >&2
    exit 1
  fi
  resolved="$(realpath -e "$ROOT/$relative_lean_file")"
  if [[ "$resolved" != "$formal_root/"* ]]; then
    printf 'rewrite Lean source escapes governed directory: %s\n' \
      "$relative_lean_file" >&2
    exit 1
  fi
  scan_status=0
  rg -n "$forbidden_lean" "$resolved" || scan_status=$?
  case "$scan_status" in
    0)
      printf 'rewrite Lean source contains a forbidden proof escape: %s\n' \
        "$relative_lean_file" >&2
      exit 1
      ;;
    1)
      ;;
    *)
      printf 'proof-escape scan failed for: %s\n' "$relative_lean_file" >&2
      exit 1
      ;;
  esac
  printf 'Compiling %s\n' "$relative_lean_file"
  "$lean_bin" "$resolved"
done

python3 "$ROOT/scripts/audit_lean_assumptions.py" \
  --root "$ROOT" \
  --output "$work/assumptions" \
  --lean "$lean_bin" \
  --rewrite-only

scan_status=0
rg -n '\b(sorryAx|Lean\.ofReduceBool)\b' \
  "$work/assumptions" --glob '*.log' || scan_status=$?
case "$scan_status" in
  0)
    printf 'Lean assumption inventory contains a forbidden proof axiom\n' >&2
    exit 1
    ;;
  1)
    ;;
  *)
    printf 'Lean assumption-log scan failed\n' >&2
    exit 1
    ;;
esac

printf 'Rewrite Lean checks passed: toolchain=%s files=%d\n' \
  "$EXPECTED_TOOLCHAIN" "${#mapped_lean_files[@]}"
