# Phase 6 Audit: Determinism, Streaming, and Binder Occurrences

> Historical review verdicts and check counts below are retained as repair
> provenance only. They are not current evidence or ballots under the
> closed-world gate in `adversarial-review-protocol.md`.

## Status

THE TWO COMPLETED REPLACEMENT REVIEWS BOTH RETURNED **FAIL** ON THEIR FROZEN
SNAPSHOTS. THE FIRST REFUTED THE BROAD NON-RETENTION WORDING; THE SECOND FOUND
THREE SURVIVING MUTANTS. THOSE EXACT TEST GAPS ARE REPAIRED ON THE CURRENT
MOVING BYTES. COMPLETE PRODUCER/VERIFIER REFINEMENT, GENERAL PAIR OBSERVATION
OWNERSHIP, JAVA-TO-LEAN REFINEMENT, AND AN IMMUTABLE INDEPENDENT BALLOT REMAIN
OPEN.

## Implemented Obligations

- `LeastOption<T>` is the explicit minimum-selection state. No canonicalizer
  uses `null` to mean “no candidate,” so Boolean bottom is a valid minimum.
- Production free-slot enumeration, local symmetry traversal, and candidate
  minimum selection are callback based. Local finite groups use a deterministic
  stabilizer chain and production retains no complete list of candidate terms.
  Certificate proof ledgers, standalone verifier group/completeness ledgers,
  and `ExhaustiveGraphCanonicalizer` reference orbits are deliberately outside
  that narrowly stated candidate-retention property.
- Production and exhaustive Java canonicalizers order candidates by
  `(shape, renaming witness)`. Schema v10 retains and independently checks the
  selected witness as well as the selected term. The rigid slot-only
  nonidentity path reconstructs the producer's exact canonical-shape key;
  equality of every producer and verifier execution set over leader, binder,
  and container actions remains a separate refinement obligation.
- Every `BindBlockPort` retains a descriptor-to-fresh-occurrence bijection.
  Nested uses of one descriptor allocate disjoint occurrence contexts, carry
  occurrence-relative paths, and replay caller identity plus the conjugated
  bound-coordinate action.
- Every binder-occurrence certificate now commits to its enclosing typed root;
  construction checks that its path resolves to the claimed source block, and
  the external verifier independently derives the same rooted key.
- `CanonicalizationMetrics` reports input and kernel serialized sizes, find
  occurrences, parent steps, container normalizations, complete global
  free-renaming candidates, and local quotient work items.
- `CertificateWriteMetrics` preserves those two candidate units separately,
  adds the exact recursively serialized binder-orbit candidate count, and
  reports exact emitted certificate bytes.

## Fault And Contradiction Log

| ID | Located fault | Repair | Regression |
| --- | --- | --- | --- |
| P6-F01 | Minimum selection used nullable best candidates, conflating unset with a possible bottom-shaped value. | Introduce `LeastOption<T>` and port every production/reference minimum. | Boolean false is selected and verified as an ordinary canonical shape. |
| P6-F02 | Binder certificate export materialized the Cartesian orbit before selecting a minimum. | Enumerate descriptor alternatives depth-first and retain only the least term and raw count. | Streaming producer output equals independent replay and remains byte deterministic. |
| P6-F03 | The wire serialized every orbit member although verification needs only completeness count plus the least representative. | Replace `orbit-members` with one `orbit-minimum`; independently enumerate and compare in `CanonicalProfileVerifier`. | Missing, wrong, or nonminimal representatives reject. |
| P6-F04 | Canonicalization and export exposed no stable work/size counters. | Add immutable canonicalization and write metric records and exact aggregation. | Tests assert deterministic counters and certificate byte count equals the file size. |
| P6-F05 | Standalone binder replay treated a bound-coordinate occurrence permutation as the entire body action, which failed for a nested occurrence with a nonempty caller context. | Extend the action with identity on every caller slot before recursively acting on the body. | The nested same-descriptor producer bundle verifies. |
| P6-F06 | The writer retained only the outer conjugated permutation, omitting recursively extended actions needed to replay an outer permutation through an inner binder. | Traverse nested port syntax and retain each capture-safe extended action embedding. | Independent canonical-orbit replay no longer returns `MISSING_EVIDENCE`. |
| P6-F07 | Independent semantic replay could act only on `One` bodies. | Reconstruct action recursively for `Seq`, `Bag`, `Set`, `Bind`, and `BindBlock` while preserving order/quotient and freshness. | Two swappable occurrences of one nested descriptor retain distinct paths and endpoints. |
| P6-R01 | A preliminary reviewer falsified the claim that `orbitCandidates` had one meaning: production counted global plus local work, the exhaustive implementation counted only global free renamings, and the writer counted a recursive binder orbit. | Remove the ambiguous field. Production and exhaustive canonicalizers now expose identical `globalFreeRenamingCandidates` and `localQuotientWorkItems`; the writer separately exposes `serializedBinderOrbitCandidates`. | Differential tests require full metric equality. Seven same-typed slots report `5,040` global candidates and `35,280` local work items; Boolean bottom reports `1` and `0`; two nested binary binder groups serialize exactly `4` orbit candidates. |
| P6-F08 | Binder-occurrence identity omitted the enclosing root. Distinct roots with equal local block, path, and automorphism produced one key; FULL verification rejected the producer output as `DUPLICATE_ID`. | Include the root structural key, validate root-relative ownership at construction, serialize that root, and derive the rooted key independently in the verifier. | A two-root/same-path fixture FULL-verifies; root and cross-orbit mutations reject. |
| P6-F09 | The wire proved only the selected term although Java's declared order uses `(shape,witness)`. Equal shapes with unequal witnesses were indistinguishable in the evidence. | Schema v6 serializes the orbit base, selected witness, and minimum `(term,witness)` pair; replay checks the selected action and tie-break. | A symmetric Set gives the same normalized term under identity and swap; selecting the larger swap now rejects. Lean proves shape-only noninjectivity and pair injectivity. |
| P6-B10 | `BinderAutomorphismGroup` and `TypedSymmetryGroup` eagerly retained finite closure lists, including all `5,040` members of `S7`. | Replace production local closure lists with deterministic stabilizer-chain traversal. Keep complete materialization only in the explicitly exhaustive bounded differential oracle. | Ninety-six deterministic `S4` subgroup samples equal an independent materialized BFS oracle without duplicates; the `S7` probe emits exactly `5,040` elements while retaining six levels, maximum orbit width seven, and fewer transversals than group elements. A Java heap/refinement proof remains open. |
| P6-F11 | The rooted binder-key repair initially retained the schema-v5 label, silently reinterpreting bytes whose binder identity had been rootless; the first dependent-subtype extension later reused v8 despite adding a new trust-boundary contract. | Separate every incompatible contract revision; the rooted/CALL-provenance/exact-transition/witness-unfold/dependent-subtype contract is admitted only as schema v9. | Otherwise-valid v5, v6, v7, and v8 relabels reject with `UNSUPPORTED_FORMAT_VERSION`; the formal schema model admits only v9. |
| P6-B12 | Earlier replay minimized normalized acted terms without establishing equality with the producer's `CanonicalShape` order. | The rigid nonidentity slice now carries the producer source and selected witness; independent replay reconstructs the exact stable canonical-shape key and the complete `(shape,witness)` order. | Canonical/reversed two-slot producer bundles, witness mutation, and FULL/PAIR replay pass the bounded regression. Complete candidate-set refinement over every leader, binder, and container action remains open. |
| P6-B13 | PAIR previously used the orbit endpoint's structural key without demonstrating ownership by independently replayed least-shape evidence. | Semantic authorization records the independently reconstructed representative key, and PAIR composes source replay with the checked orbit while comparing that key and exact sort across bundles. | The alpha-equivalent canonical/reversed pair verifies; polymorphic/monomorphic declaration mismatch and selected-witness mutation reject. The complete cross-bundle substitution matrix remains open. |
| P6-F14 | The correlated dependent-type DAG and complete JOIN/ARROW alternative-pair matrix were added after schema v9, so retaining the v9 label would silently reinterpret dependent-chain bytes. | Admit the combined rooted/CALL/transition/witness/subtype/correlated-DAG contract only as schema v10 and reject all v5 through v9 roots. | Lean admits the complete feature vector only at v10; the standalone verifier rejects an otherwise valid v9 relabel, and DAG/matrix omission, order, and decision mutations reject. |
| P6-R14 | The replacement review showed that P6-10 falsely swept complete certificate and verifier evidence ledgers into a production no-retention claim. | Restrict P6-10 to complete lists of candidate terms and state every proof/completeness-ledger exclusion in the claim itself. | The traceability hash binds the narrowed sentence; the failed report remains immutable provenance. |
| P6-R15 | Removal of the equal-shape witness tie-break survived permanent tests, and the first-candidate verifier required a temporary six-order `S3` sweep. | Permanently emit all six three-slot source orders and add a direct equal-term identity/swap comparator probe in both directions. | The producer/verifier regression now covers all six bundles and the exact witness-tie branch; fresh mutation review is still required. |
| P6-R16 | The next frozen mutation review found three surviving variants: producer witness-tie removal, standalone verifier first-candidate selection, and production retention of a complete candidate list. | Add a producer comparator probe, route a verifier test hook through the real streaming minimum in both orders, and inspect the exact nonstatic state of `BestCandidate`. | Current focused runs report `TheoryCanonicalizationTest=14,481`, producer semantic order `5`, and verifier semantic order `26`; a new independent review is required because these are moving bytes. |

## Regression Evidence

- Focused evidence on the current moving worktree includes
  `TheoryCanonicalizationTest=14,481`, `TheoryPortsTest=1,014`,
  `TheoryStateTest=4,214`, `TheoryCertificatesTest=445`,
  `TheoryDeterminismTest=47`, `VerifierTest=179`,
  `CertificateBundleWriterTest=109` in each deterministic run,
  `ProducerBundleInspectionTest=68`,
  `ProducerSemanticEvidenceMutationTest=113`,
  the Phase 6 semantic-order producer/verifier regressions including six
  three-slot order bundles and both equal-shape witness-tie directions, and
  `TrustedTheoryPinsTest=31`. The bounded export census remains exactly
  `VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`.
- `bind-block-dual-a.acgncert` deliberately uses equal local paths under two
  distinct roots and returns `VERIFIED/NONE` under FULL verification.
- `formal/Phase6OrbitCanonicalization.lean` preserves the rootless-key and
  shape-only counterexamples and proves the abstract rooted key, complete
  candidate key, streaming fold, occurrence alignment, schema-v10, counter,
  and PAIR-ownership obligations named in the traceability matrix.
- The original independent mapping failure is retained at
  `/tmp/acgn-phase6-evidence-map-20260821.md`, SHA-256
  `bb593ede990ae71deaa6125a1ade5d26def049e41f4db6598ed319293f2191b6`.
- The fresh replacement failure is retained at
  `/tmp/acgn-phase6-streaming-replacement-review-20260821.md`, SHA-256
  `4a9574907deddff0bb086df63aa8abcae369874de463bd6124fd80944a7f7132`.
- The post-repair mutation failure is retained at
  `/tmp/acgn-phase6-postrepair-review-20260821.md`, SHA-256
  `1d7a29ad873a3e44db2fecb038b83de544adc437709b4f9f2d97dcb0f12d8871`.
  It passed 70,188 executable checks but found the three gaps recorded as
  P6-R16; none of those results is reused as a current ballot.
- These are focused checks, not a complete gate or a phase ballot. Earlier
  green counts do not close the newly identified blockers.

No protected empirical result directory, paper source, or reproducibility
terminal program was modified.

## Review Gate

No ballot may begin until the remaining P6-B12/P6-B13 refinement obligations
and every mapped claim are discharged on one immutable snapshot. Fresh
reviewers must compare production streaming results with the
exhaustive reference on small graphs, inspect all remaining minimum sentinels
and orbit materialization, replay nested same-descriptor occurrences, mutate
occurrence paths/contexts/actions, and independently derive every counter from
its represented unit. Each receives the fraud-assumption instruction in
`adversarial-review-protocol.md`; one weakness fails the entire phase.
