#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work="${1:-/tmp/acgn-certificate-verifier-smoke}"

"$ROOT/scripts/run_certificate_bundle_writer_tests.sh" "$work"
printf 'Representative export census: %s\n' "$work/export-smoke/coverage-census.tsv"
