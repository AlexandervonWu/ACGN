# Independent CALL Review: P1-08 / P1-05

**Result: PASS (bounded semantic/correspondence review).** No concrete scoped
blocker found: neither a supported-source counterexample nor false acceptance
of the claimed new source-control mapping was demonstrated. This is not a
registered closure result, a parent-obligation discharge, or universal Java
correctness. Review performed offline on 2026-09-07, within the ten-minute bound.

Only this repository file was edited. Compilation, observations, generated
Lean checks, and isolated source mutations were confined to
`/tmp/acgn-review-call-heVyoD`. Existing worktree changes were preserved.
The boundary in [call-notes.md](call-notes.md) was read before testing.

## Evidence

One independent clean full-source compilation used `javac --release 17
-encoding UTF-8`, fresh classes, and copied local jars. Runtime: OpenJDK
17.0.20; proof checker: explicitly selected Lean 4.33.0, commit
`d8b18978322de05a8f3dba51ef03cf5461676c17`. No downloads were used.

| Check | Observed result |
| --- | --- |
| `OrderedCallValidation.lean` | Exit 0; 17 theorem inventories; axiom union only `propext`, `Classical.choice`, `Quot.sound` |
| `OrderedCallValidationRegressionTest` | Exit 0; 7 arities, 56 occurrences, 637 rejections, 70 order controls, 5355 checks |
| `ZeroArgumentCallRegressionTest` | Exit 0; 13 occurrences, 1160 checks |
| `CallExtractionRegressionTest` | Exit 0; 161 checks |
| `CallValidationExtractor` | Exit 0; exactly the three declared control rows |
| Actual TSV through `call_program` and Lean | Exit 0; 56 observation theorems plus 3 source-control equalities |
| Focused temporary harness | All 36 checks PASS, including expected rejections |

Raw per-check logs, generated Lean inputs, hashes, and exit codes are retained
in `/tmp/acgn-review-call-heVyoD/review-evidence.json` and adjacent files;
`check_review.py` records the commands and mutations. Expected Lean failures
were checked for a false proposition, not merely a nonzero exit. Each mutated
Java source compiled successfully before extractor rejection, whose diagnostic
was `Unmodeled control`. These are local review artifacts, not registered
closure evidence. The final checks were rerun after concurrent plugin updates.

## Correspondence Findings

- **PROVED:** `validate_iff` (proof line 96) derives complete indexed encoding
  from executable acceptance; it does not assume acceptance or distinct
  payloads. `selectCall` (line 168) reads only the exact visit and rejects past
  the maximum. `checkObservation` (line 204) compares actual edges and all three
  payload observations under the explicit Java index envelope.
- **TESTED:** the Java observer captures actual `super.visit` returns and
  checks parser identity, complete declaration metadata, role positions, owner,
  visit, order, and multiplicity. It traverses `getCertificationMatrixEGraph()`
  (test line 277), not the optimized matrix. Certified literals are decoded
  from stored invocation/e-class shapes (line 233). Public
  `CallOccurrenceCertificate.create` controls (line 245) retain the actual
  certified endpoint and reject wrong/swapped same-type `OnePort` arguments.
- **CHECKED:** extractor lines 171 and 183 enforce declaring owners, parameter
  types/modifiers, the complete CALL dispatch prefix, and both validator bodies;
  resolved nominal/callee owners are checked at line 85. Isolated removal of
  the early return or owner guard, reversal of the comparator, and skipping the
  last argument in either validator all compiled and were rejected. No source
  translation of sorting, allocation, getters, or transitive helpers is implied.
- **KEY INJECTIVITY:** `call_program` enumerates the union of source and target
  `(callee, kind, arity)` tuples. Capture tokens come from the source tuple;
  callee edges come from the independently exported target tuple, read by Java
  reflection at test line 393. Fresh wrong target identity, target kind, and
  target arity each make Lean reject. Source-only renaming at the first and last
  rows also rejects; jointly renaming each matching pair passes. This checks
  equality-token behavior without inventing declaration/certificate authority.
- **NEGATIVES:** the five CALL mutations in `negatives()` were reproduced
  through the actual `call_program`: foreign target, foreign owner, missing END,
  extra certified payload, and distinct certified swap all reject. Additional
  visit/position corruption and parser/IR/MASG swaps reject; MASG-token
  disagreement and missing occurrence census reject in the encoder. A changed
  extracted loop bound fails Lean; an equal-duplicate swap remains accepted.
  The full multi-obligation `negatives()`/closure runner was not executed.

## Limits

The actual source fixtures contain nonnegative numeric literals at arities
`{0,1,2,3,5,8,16}`, with separate predicate/function bodies. They do not establish
universal parser behavior, all supported arities, nested/nonliteral payload
semantics, or optimizer occurrence survival. The general Lean result concerns
role-ordered natural-number buckets. Heap identity, sorting/permutation,
dynamic dispatch, Java collections, and parser-to-model interpretation remain
tested/trusted boundaries. `arity + 3 <= 2147483647` is an arithmetic envelope,
not a production overflow guard or feasible-allocation theorem.

Independent target authority/source spelling are not exported to Lean. Java
checks actual `matchesTarget` and complete downstream metadata; the replay
does not reauthenticate authority, certificate paths/operators, or the
observation hash's preimage. Owner numbers are recorded equality tokens, not
a proof of general object identity. Actual empty numeric-list TSV cells decode
to `[]`; the wire cells do not contain the literal text `[]`.

The public certificate-construction checks are not standalone verifier replay
or full bundle verification. Null edge/target objects, negative machine values,
resource failures, concurrent mutation, arbitrary hostile internals, and new
authority mechanisms were not added to the threat model. Lean/JDK/local parser
jars, observers/encoders, reflection, adapters, SHA-256, OS and hardware remain
trusted as declared. Two-clean-build determinism and release provenance remain
the main runner's responsibility; repeated local checks are not a second clean
build or global closure.

## Reviewed Input Hashes

SHA-256 of the tested copies, matched against the worktree at review completion:

```text
e246329b9d7e0b763528b1e1a8158ab73b244855f9980d5945a014fdda04bba5  OrderedCallValidation.lean
dfee3577eda3f43e943b2df965430302fd73c8394957846dbd945c654dbbf976  OrderedCallValidationRegressionTest.java
2cb915f89869a14f8cc10ffe87c6317ae81fc38c181a955bdd90a72c92d327b8  CallValidationExtractor.java
77a1b5384a9dbb99479a7fec2754f209ba1e02cb87311d22b0d20b8dc053aac2  scripts/next_obligation_replays.py
```
