# Phase 1 Audit: CALL Extraction and Identity

> Historical review verdicts and check counts below are retained as repair
> provenance only. They are not current evidence or ballots under the
> closed-world gate in `adversarial-review-protocol.md`.

## Current Review Status

IMPLEMENTED; PRIOR SINGLE-REVIEW EVIDENCE RETAINED; REOPENED UNDER THE CURRENT
FIVE-REVIEW ZERO-TRUST GATE. See `adversarial-review-protocol.md`.

## Scope

- Repair branch: `section3-conformance-v2`
- Frozen base: `8ec25613e81d7b3767947db31c60cc4bbed4074d`
- Formal source: `ARTIFACT_REPAIR_PROMPT.md`, Phase 1
- Empirical result directories: unchanged

This phase replaces opcode-only CALL handling with an occurrence-owned call
operator. Each occurrence records its formula/expression kind, source spelling,
qualified semantic identity, independently declared arity, arity authority, and
fresh occurrence identifier.

## Implemented Obligations

| Obligation | Implementation | Regression evidence |
| --- | --- | --- |
| Stable call visit | `MASGVisitor.visitCall` captures `callTov` immediately and uses `visitAndConnectAt` for every edge | nested and mixed call cases |
| Exact visit shape | `validateCompletedCallVisit` requires callee, contiguous ordered arguments, and one final END owned by the same source occurrence | missing END, END-as-argument, foreign-source edge |
| No occurrence reuse | `IRAgent` tracks consumed `CallSymbol` occurrence identifiers | reused nested occurrence rejection |
| Declared local arity | callable declarations are indexed before body traversal | corrupted local argument list rejection |
| Declared imported arity | `AlloyLibraryCallableLedger` fixes accepted imported signatures independently of call children | corrupted `ord/first` arity and unpinned-member rejection |
| Qualified identity | local module identity and opened-module instantiation identity are retained | local and `util/ordering<A>` assertions |
| Ordered IR arguments | IR CALL children contain only source-order arguments; callee and END remain validated metadata | `h[a,b]` versus `h[b,a]` |
| Downstream identity | kind, qualified callee, arity, and arity authority participate in structural and certified keys | kind- and authority-distinction checks |
| CALL is positional | CALL is excluded from flexible-arity classification and unary-wrapper elimination | nested call preservation |
| Generator support | `Generator` emits exact source-order call syntax and validates the visit contract | nested and swapped-argument regeneration |

## Independent Adversarial Reviews

### Review 1: FAIL

The reviewer found seven gaps: code generation dropped the call operator; the IR
did not validate exact END/ownership; call targets could be inferred from
traversal state; arity was observed rather than declared; qualification was
lost; boundary tests were incomplete; and `EdgeCounter` still searched for the
generic opcode. The phase was reopened. All seven findings were repaired.

### Review 2: FAIL

The reviewer found that a missing visit could fail open, unresolved imports
still trusted observed arity, imported identities could be prefixed by the
client module, generator validation was incomplete, tests omitted those cases,
and corpus aggregation fragmented occurrences. The phase was reopened. Visit
reuse now fails closed, open declarations determine imported identity,
generation is strict, occurrence-free aggregation is explicit, and adversarial
tests cover each case.

### Review 3: FAIL

The reviewer found that arbitrary qualified names could be accepted, adapter
and metric projections inferred missing arity from child count, internal keys
omitted formula/expression kind, imported arity authority disappeared after
MASG lowering, and tests omitted those trust-boundary cases. The phase was
reopened. Opened aliases are now required, inference fallbacks were removed,
kind and authority reach structural/certificate identities, and negative tests
were added.

### Review 4: FAIL

The reviewer found two remaining implementation faults: imported declarations
were still instantiated with the observed argument count, and internal keys did
not include arity authority. The test suite also lacked direct corrupt-import
and authority-distinction cases. The phase was reopened. Imported arity now
comes from `AlloyLibraryCallableLedger`; structural, normal-form, and repair
keys include authority; both negative tests were added.

### Review 5: FAIL

The reviewer found that conflicting `open` aliases could overwrite one another,
the fast repair-distance path did not enforce the complete CALL metadata
contract, and source argument order was not asserted at both parser and
serialized-certificate boundaries. The reviewer also requested a regression
for the required corpus instrumentation. The phase was reopened. Imported
aliases now reject differing module instantiations, the fast path checks kind,
authority, fixed arity, and child count, `h[a,b]` and `h[b,a]` are distinguished
through serialization, and parser/IR call counters are regression-tested.

### Review 6: FAIL

A fresh reviewer found five surviving alternate paths: certified and repair
projections still accepted display-name identity and unchecked kind/authority;
the production repair payload omitted authority; anonymous modules used the
non-global `this` qualifier; duplicate local descriptors with one identity
could retain the first declaration; and `Generator` still had a generic
syntactic CALL branch. The phase was reopened. Both projections now enforce
the same complete fixed-arity metadata contract, the repair payload includes
authority, anonymous source units use deterministic SHA-256 qualification,
local descriptor conflicts reject, and generic CALL serialization rejects.

### Review 7: FAIL

The reviewer found that nonempty but unqualified identities were still accepted,
backtranslation did not validate CALL metadata, internal e-graph and normal-form
keys retained a source-name fallback, and the fast metric omitted the exact
`maxArity == declaredArity` check. The phase was reopened. A single
`CallMetadata` validator now governs canonicalization, backtranslation,
certification, repair projection, and fast comparison. `CallSymbol` itself also
rejects unqualified semantic identities.

### Review 8: FAIL

The reviewer found that unmatched normal-form insertion/deletion costs could
measure a malformed CALL without reaching node comparison. The phase was
reopened. `CanonicalDistance.prepare` now validates every reachable CALL once
before any metric decomposition, including null-side and unmatched-form paths.

### Final Review

**PASS.** The final reviewer confirmed that whole-input validation in
`CanonicalDistance.prepare` closes the last unmatched insertion/deletion bypass.
No concrete Phase 1 production bypass remained.

This historical verdict predates the current unanimous five-review rule and
does not close the phase under that rule.

### Current Formal-Coverage Review: FAIL

`P1-F09`: the first Lean visit model counted one callee and checked argument roles, but
it did not represent callee ownership, argument ownership, exact callee
identity, or the position of END in the edge sequence. It could therefore
"prove" validity for a cross-visit child or a nonfinal terminator. The model
now binds all owners to the occurrence and fixes the exact
callee/arguments/END order; independent counterexamples for foreign callee,
foreign argument, wrong callee identity, and early END compile as rejections.
This repair invalidates every earlier Phase 1 ballot. Java refinement to this
stronger model is still an open ledger obligation, so Phase 1 remains blocked.

`P1-F10`: completed-edge validation compared only source spelling even though
the downstream key claimed qualified declaration identity, call kind,
declared arity, and arity authority. Callee targets now retain that complete
metadata and both MASG and IR validation compare it. A same-spelling target
with qualified identity `fraud/f` is rejected for a call of `module/f`. The
focused test and Lean key model pass, but complete parser-to-wire refinement
and a fresh immutable review remain open.

`P1-F11`: a fresh Luna falsifier constructed the valid-UTF-8 callee
`m/f\u0000X`. `CallMetadata.requireText` admitted the embedded control even
though later typed-operator construction and standalone replay rejected it.
CALL source names, qualified callees, and occurrence paths now use the common
well-formed visible-identity rule at `CallSymbol`, normalized metadata,
certificate construction, and verifier replay. Control, format, private-use,
unassigned, and lone-surrogate fragments reject directly. A fresh immutable
review remains required.

`P1-F12`: a fresh Terra falsifier removed all CALL-occurrence rows from an
otherwise valid producer bundle. Each supplied row had been checked, but no
producer or standalone-verifier invariant required the ledger to be complete.
The construction source ledger now records every occurrence certificate,
artifact assembly requires exact occurrence equality, and standalone replay
requires the supplied certificate operator identities to equal the CALL
operator identities present in the kernel model. Producer and verifier
omission mutations reject with `MISSING_EVIDENCE`.
`Phase1CallExtraction.lean` independently defines exact occurrence-ledger and
operator-coverage predicates; its complete-evidence and omitted-evidence
theorems reduce to the corresponding Boolean outcomes. Full parser-to-Java
refinement and a wholly fresh immutable review remain open.

`P1-F13`: both fresh Luna reviewers then showed that operator-set coverage was
not occurrence completeness. In `f[f[a]]`, deleting either row preserved the
single semantic operator identity. Every wire occurrence now creates one
nullary `ACGN/CALL-OCCURRENCE/<base64url-wire-key>` model anchor. Standalone
replay reconstructs the full identity from each row and requires exact
anchor/row set equality, separately from semantic operator coverage. The
anchor is provenance-only, so it neither changes CALL equality nor blocks
hash-consing of repeated semantic terms. The nested same-operator fixture
verifies, deleting either one of its two rows while retaining its anchor
rejects with `MISSING_EVIDENCE`,
and `Phase1CallExtraction.lean` proves distinct anchors and the corresponding
one-omission rejection. Raw source parsing is not claimed by this local
certificate invariant.

`P1-F14`: local preflight invalidated the next snapshot before ballot results
because a cardinality anchor had not yet been prohibited from semantic use.
The verifier now requires each marker to be a unique nullary term with the
same context and sort as its CALL source and exactly one scalar occurrence in
the complete decoded bundle: its own term-table ID. Any reference from a term,
witness, proof, snapshot, canonical record, unfolding, publication, or other
evidence therefore rejects. One iterative bounded scan handles all marker IDs
together. Lean independently pins isolation and context/sort mismatch
rejection. No review vote from the interrupted snapshot is retained.

`P1-F15`: both Round 28 Luna reviewers demonstrated the remaining authority
limit by deleting one nested CALL row together with its marker term/operator.
The surviving bundle is internally consistent because the standalone verifier
does not receive the raw Alloy source or an independently pinned occurrence
commitment. Another bundle-internal digest cannot repair this circularity.
Accordingly, marker checks are stated only as protection against unpaired
tampering. Complete raw-source occurrence coverage is an open theory blocker
requiring source replay or external authority; Phase 1 and the integrated
artifact remain `INCOMPLETE`.

## Verification

`CallExtractionRegressionTest` passes 148 checks in the current focused run,
including an Alloy-backed two-atom witness separating `f[f[a]]` from `f[a]`.
`CertificateBundleWriterTest` passes 109 checks and
`ProducerSemanticEvidenceMutationTest` passes 113 checks, including the
independent CALL-ledger omission paths.

The protected `./scripts/run_bounded_ci_java_tests.sh` is byte-identical to the
repair base and therefore does not claim to register this new focused suite.
The current direct bounded commands compile the complete source tree and run
`CallExtractionRegressionTest`, `CanonicalAlloyPipelineTest`, and the related
focused suites from a fresh `/tmp` class directory. A new nonprotected audit
entry point remains required before CI registration can be claimed.

## Deliberate Limitation

Imported CALL acceptance is conservative. The independently fixed v1 ledger
currently admits the `util/ordering` predicates and functions used by the
publication corpus. An imported member outside that ledger fails closed. A
future extension must pin the additional module's declarations independently;
it must not infer arity from occurrence children.
