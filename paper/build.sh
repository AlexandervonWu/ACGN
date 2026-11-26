#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
TECTONIC_BIN=""
if command -v tectonic >/dev/null 2>&1; then
  TECTONIC_BIN="$(command -v tectonic)"
fi

if [ -n "$TECTONIC_BIN" ]; then
  for entry in main_compressed supplement main_compressed full_draft; do
    "$TECTONIC_BIN" -k --keep-logs "$entry.tex"
  done
elif command -v latexmk >/dev/null 2>&1; then
  for entry in main_compressed supplement main_compressed full_draft; do
    latexmk -pdf -bibtex -interaction=nonstopmode -halt-on-error -file-line-error "$entry.tex"
  done
else
  echo "Install Tectonic or TeX Live with latexmk, then rerun this script." >&2
  exit 1
fi
