# Open Diagnostics Repair, 2026-08-27

## Scope

The starting 191-row traceability matrix reported 212 diagnostics. This pass
did not interpret an open diagnostic as proof that the implementation was
wrong, nor did it blanket-promote rows. Each item was classified as:

1. an invalid or stale bookkeeping state;
2. missing execution or traceability evidence;
3. a finite implementation/formal gap that could be repaired now; or
4. a genuine remaining obligation such as structural coverage, immutable
   review, external authority, closed-world empirical traceability, or an
   unproved whole-implementation refinement.

After the focused repairs, the checker reports 87 ready rows and 132 open
diagnostics. Open rows remain open deliberately.

## Repaired Gaps

| Finding | Repair | Focused evidence |
| --- | --- | --- |
| `DIRECT-BOUNDED` duplicated the defined meaning of `DIRECT`. | Normalize the state vocabulary and retain bounds in notes/formal status. | Matrix status census and traceability schema. |
| Java test references could name non-callable symbols and cited tests were not necessarily executed. | Require callable test declarations and add governed owner/method/script reachability checks. | `Section3AssuranceTraceabilityTest` 35 checks; `AssuranceTestExecutionCoverageTest` 893 checks. |
| Human-readable ledger states diverged from the authoritative matrix and seven rows contained two state cells. | Normalize all 191 state cells to the exact matrix pair and reject future state disagreement or malformed duplicate cells. | Ledger cardinality/shape check plus `Section3AssuranceTraceabilityTest` 35 checks. |
| The Lean pin and declaration assumptions were not governed output. | Hash `lean-toolchain`; run every mapped file; emit `#check` and `#print axioms` for every mapped declaration. | 888 declarations across 24 generated assumption logs. |
| The eighteen required adversarial policies lacked a closed executable census. | Add an exact policy ledger and reject missing, duplicate, uncalled, unregistered, or workflow-invisible entries. | `RequiredPolicyCoverageTest` 128 checks. |
| Phase 4 rebuild lacked an implementation-enforced finite processing rank. | Add a checked fixed-batch processing budget tied to initial dirty records, record count, and the maximum leader-decreasing union epochs. | `TheoryRebuildTest` 522 checks; `Phase4CollisionBuckets.lean`. |
| Semantic-profile traceability described compatibility data as production authority. | Exercise parser-owned source-command propagation and cross-command rejection; label fixed compatibility internal/test-only. | `SemanticProfileSourceCommandTest` 44 checks. |
| G-02 pointed at fixture pins instead of the independent fixed law registries; G-03 lacked complete record mutation evidence. | Map the actual producer/verifier registries, expand the formal index, and mutate all 17 law-record fields independently. | `ProducerSemanticEvidenceMutationTest` 135 checks; `CrossPhaseContract.lean`. |
| CALL creation had no immutable implementation witness for immediate stable capture. | Construct each CALL node inside `CallVisitCapture` before registration and recheck it at completion. | `CallExtractionRegressionTest` 161 checks; `Phase1CallExtraction.lean`. |
| Readable metric operations were not part of the governed run. | Register visualization operation reconstruction and retain aggregate fallback when unit operations cannot exactly account for certified cost. | `VisualizationAnalysisServiceTest` in the governed runner. |

## Deliberately Open

The following are not bookkeeping defects and were not promoted:

- statement/decision coverage and MC/DC or reviewed dispositions (`A-06`);
- one immutable manifest binding complete review evidence (`A-10`, `A-12`);
- open scoped findings and machine-enforced fault closure (`A-11`);
- complete producer/verifier coupling and evidence-family products (`A-07`,
  `G-04`);
- independent production theory pins beyond the existing bounded fixture
  authorities;
- universal parser/JVM/codec/refinement claims where only bounded conformance
  exists;
- closed-world empirical statement-to-manifest and authority-surface censuses
  (`G-13`, `G-16` through `G-18`).

These gaps continue to produce diagnostics. Removing them from the count
without their named evidence would recreate GC-F103's false closure.

## Verification State

The complete bounded governed run at
`/tmp/acgn-section3-diagnostics-20260827` executed 77 steps with zero
executable failures. It compiled every mapped Lean file, inventoried all 888
mapped declarations, replayed producer/verifier and certificate fixtures,
checked trusted pins and the publication snapshot, and regenerated the
traceability catalog. Its input-manifest SHA-256 is
`e5e05dd93ed0c8d6b452ed7a75f350a524c06560b1d07fa45c4dd813878911d4` and
its output-manifest SHA-256 is
`36a41a24bc862a5aa376acd54d0c177e7145c1ead529af1aba2761ac637f4205`.

The result remains `INCOMPLETE`, not `PASS`, because the traceability gate
reports 132 open diagnostics. The run demonstrates that the repaired
implementation and bookkeeping gates execute successfully; it does not erase
the deliberately open obligations above.
