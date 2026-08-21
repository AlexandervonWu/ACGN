# Phase 6 Audit: Determinism, Streaming, and Binder Occurrences

> Historical review verdicts and check counts below are retained as repair
> provenance only. They are not current evidence or ballots under the
> closed-world gate in `adversarial-review-protocol.md`.

## Status

PRELIMINARY MAXIMUM-ADVERSARIAL REVIEW: **FAIL**. ROOT IDENTITY AND THE
TERM-ONLY WITNESS OMISSION ARE REPAIRED, BUT PRODUCER/VERIFIER ORDER
REFINEMENT, PAIR OBSERVATION OWNERSHIP, LOCAL ORBIT MATERIALIZATION, COMPLETE
FORMAL REFINEMENT, AND A STABLE FIVE-REVIEW BALLOT REMAIN BLOCKED.

## Implemented Obligations

- `LeastOption<T>` is the explicit minimum-selection state. No canonicalizer
  uses `null` to mean “no candidate,” so Boolean bottom is a valid minimum.
- Production free-slot enumeration and the writer's outer Cartesian traversal
  are callback based. Current local binder-group objects still retain eagerly
  materialized finite closures, so the artifact does not yet satisfy the
  unqualified no-orbit-materialization requirement.
- Production and exhaustive Java canonicalizers order candidates by
  `(shape, renaming witness)`. The current schema v7 retains and independently checks
  the selected witness as well as the selected term. Whether the verifier's
  reconstructed term order is exactly the producer's canonical-shape order is
  a separate unresolved refinement obligation.
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
| P6-B10 | `BinderAutomorphismGroup` and `TypedSymmetryGroup` eagerly retain finite closure lists, including all `5,040` members of `S7`. | **Unrepaired blocker:** implement genuinely streamed local group traversal with an exact completeness argument. | Retained-object and bounded group probes remain required. |
| P6-F11 | The rooted binder-key repair initially retained the schema-v5 label, silently reinterpreting bytes whose binder identity had been rootless. | Separate rooted identity in v6; the current provenance-extended contract advances to v7 and rejects all earlier bytes before decoding. | An otherwise valid v7 fixture relabeled v5 or v6 rejects with `UNSUPPORTED_FORMAT_VERSION`; `Phase4CollisionBuckets.lean` admits only version 7. |
| P6-B12 | Java minimizes canonical `CanonicalShape` values in `Can(Delta)`, while `CanonicalProfileVerifier` currently minimizes normalized acted terms in the effective-support context. No proof establishes that these orders coincide. | **Unrepaired blocker:** make the wire carry the exact kernel-to-canonical construction and have replay reconstruct Java's precise shape key and witness order, or supply a proved injective order-preserving refinement. | A bounded differential over nontrivial free renamings and local quotients is still required. |
| P6-B13 | PAIR currently takes the structural key of the orbit proof's re-instantiated right endpoint. The canonical-record path does not yet demonstrate that this is the independently replayed least canonical shape used by Java. | **Unrepaired blocker:** bind the canonical record and PAIR endpoint to the exact verified shape observation while retaining the source-to-kernel derivation separately. | Cross-bundle alpha-renaming, equal-kernel/different-shape, and equal-shape/different-kernel attacks remain required. |

## Regression Evidence

- Focused post-P6-F08/P6-F09/P6-F11 evidence on the current moving worktree:
  `TheoryCertificatesTest=320`, `VerifierTest=97`,
  `CertificateBundleWriterTest=95` in each deterministic run,
  `ProducerBundleInspectionTest=68`,
  `ProducerSemanticEvidenceMutationTest=60`, and
  `TrustedTheoryPinsTest=31`. The bounded export census remains exactly
  `VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`.
- `bind-block-dual-a.acgncert` deliberately uses equal local paths under two
  distinct roots and returns `VERIFIED/NONE` under FULL verification.
- `formal/Phase6OrbitCanonicalization.lean` preserves the rootless-key
  counterexample, proves injectivity of the abstract rooted repair, and records
  the still-open shape-only witness counterexample.
- These are focused checks, not a complete gate or a phase ballot. Earlier
  green counts do not close the newly identified blockers.

No protected empirical result directory, paper source, or reproducibility
terminal program was modified.

## Review Gate

No ballot may begin until P6-B10, P6-B12, P6-B13, and every mapped claim are repaired
on one immutable snapshot. Five fresh reviewers must each compare production streaming results with the
exhaustive reference on small graphs, inspect all remaining minimum sentinels
and orbit materialization, replay nested same-descriptor occurrences, mutate
occurrence paths/contexts/actions, and independently derive every counter from
its represented unit. Each receives the fraud-assumption instruction in
`adversarial-review-protocol.md`; one weakness fails the entire phase.
