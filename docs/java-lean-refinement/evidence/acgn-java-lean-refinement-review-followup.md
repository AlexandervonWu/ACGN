# Java-Lean Correspondence Delta Review

**PASS for this repair delta.** The original JLR-06 finding is resolved; no scoped regression found. This is not a declaration that the new full closure run is VERIFIED.

Reviewed only the driver, boundary-test, and claim changes against the original build-A snapshot. The package README is unchanged. The three changed files match the new frozen manifest in `/tmp/acgn-java-lean-refinement-20260907-b`.

New input root: `24b86eb7786795db400588794e5c2ab507fe0fbadda526e6ddaf4c9764166d15`.

## Targeted Results

Using the original actual payload `/tmp/acgn-java-lean-refinement-20260907-a/A-probe.log`, independently copy row 2's payload and replace only its certificate-side `traceOutput`. That row is AND/FORBID, flat source `{"children":[{"leaf":1}]}`, returned singleton `[1]`.

| Check | Observed result |
| --- | --- |
| `traceOutput = [true]`, decoded from JSON | `Blocked: invalid returned typed identity` |
| `traceOutput = [1.0]`, decoded from JSON | `Blocked: invalid returned typed identity` |
| Unmodified actual payload | All 2,356 rows accepted, including four empty rejections |
| Rendering accepted original observations | Byte-identical to original build-A `CertifiedReplay.lean`; 7,065 replay/general theorem entries |
| `python3 -B scripts/test_java_lean_refinement.py` | 22 tests passed, exit 0 |

These probes invoked the corrected `check_rows` directly. No Java build or Lean replay was rerun.

## Correction Assessment

`scripts/run_java_lean_refinement.py:146` now strictly validates `output`, `traceInput`, and `traceOutput` as lists of integer atom IDs before endpoint equality and before the empty-row return. Exact `int` checks exclude both Python booleans and floats. Strict metadata/row-ID checks and the explicit empty-output/certificate-presence conditions are consistent with the actual producer payload. Existing source binding, occurrence-fiber, no-UNIT, census, and successful-certificate checks remain present.

The six added regressions cover the requested boolean and float witnesses, boolean schema/row IDs, null empty output, and certificate presence on an empty row. JLR-06 now explicitly covers the registered malformed-data mutations, consistent with its finite negative-control scope. No production or Lean semantics changes were introduced by this delta.

The earlier review remains preserved at `/tmp/acgn-java-lean-refinement-review.md`, SHA-256 `2d26740314e8f0f3517f8304d542c0718b90bd310d4d8ba2fff8d90bdc7fcc3e`. No repository or build-evidence files were changed. No broad search, internet access, or new mutation family was used. This follow-up does not expand the fragment to global P2-16 closure.
