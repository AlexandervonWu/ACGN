# Phase G Certified Rebuilding

> **Publication superseding note (2026-08-29):** Dirty-worktree and earlier
> run identities below are retained as historical phase provenance. The current
> authoritative empirical snapshot is clean publication run
> `df4d8d4c-6265-4fe7-88d5-3aceee60398b` from source commit `fbd9b149`, verified
> by `scripts/verify_imported_publication_snapshot.sh`.

> Historical gate report. Its PF3-TB01/PF3-TB02 and missing-source-insertion
> sections describe the state before repaired `appendixC_v5.tex`. They are
> superseded, not erased, by
> [`theory-pre-phase-h-unblocked.md`](theory-pre-phase-h-unblocked.md).

## Audit Identity

Phase G was implemented on 2026-08-16 against:

- mission specification
  `/home/augustus/.codex/attachments/700dd038-fc5b-455b-9e11-c2aaa9aea2eb/pasted-text.txt`,
  SHA-256 `53f7fec4db8ff7aefb0192120739a2c1fc47e2d71153571be6c8e5b56ba33fbd`;
- normative draft `E_Graphs_Draft_LNCS-3.pdf`, SHA-256
  `6b128156008abe8065fe2cf3871950ff0206a47dcc263e3486e475053e4a0d33`;
- repository HEAD `f0e326ab41fbdda9e21b36cb11aecc1863d9712d` in a dirty worktree.

The content diff, not HEAD alone, identifies this implementation. Changes are
confined to `is.fivefivefive.CanDis.theory`, its tests, and `/docs`. No dataset,
experiment runner, manifest, reproducibility script, or terminal package was
changed or rewired.

## Implemented

`TypedSlottedPortEGraph` now owns the complete fixed-batch rebuild state:

- `ParentRecordKey` identifies one immutable owner/shape record;
- an exact reverse `e-class -> parent records` index tracks opaque uses;
- a deterministic `TreeSet` deduplicates dirty records;
- every strict stored shape has one oriented exact shape equation (EC);
- interface-restriction history justifies stale invocation metadata;
- a private in-flight marker keeps the currently processed record logically
  dirty during nested invariant checks;
- `RebuildReport` separates finite administrative work from rewrite work.

`admitFixedBatchRecordCertified` admits an already-flat, bottom-up finite
record only after checking current leader children, certified node laws,
certified class symmetries, canonical witnesses, and exactly one EC per shape.
Its name is intentionally not `insertNode`: it does not claim to construct the
draft's unresolved witness-dependent source certificate `d_n^w`.

`unionCertified` now absorbs all child shapes before installing the parent
edge. Shape witnesses are deterministically relabeled so the parent interface
is literal in the transported ambient context. ECs are transported through the
parent certificate. Nonleaders retain no strict shapes. Certified child
symmetries that stabilize the parent image induce checked parent symmetries;
no symmetry or restriction is inferred from type equality or a proper image.

`restrictInterfaceCertified` is the sole interface mutation. It atomically:

1. verifies the proper-subcontext factorization;
2. transports all shape witnesses and ECs;
3. rebuilds every affected union-find path as a direct certified parent edge;
4. restricts the class group to its certified setwise stabilizer;
5. records a composable metadata history for stored invocations;
6. dirties every indexed parent.

`TypedFindResult` consequently distinguishes the original invocation from its
current-interface normalized form and composes the restriction proof before
the ordinary parent-path proof.

`rebuild` is a first-class, rewrite-disabled fixed point. For each dirty record
it canonicalizes the instantiated stored shape through the current graph,
removes the stale key, creates a `RebuildCongruenceCertificate`, narrows the
equation to exact effective support, reinserts the key, and handles any
collision through `EffectiveShapeCollisionCertificate` and
`ParentEdgeCertificate`. A collision is prevalidated before stale state is
mutated. Recursive unions enqueue newly affected parents. There is no round
cap; successful return requires an empty dirty set and exact quiescent `H`.

The implementation is transactionally ordered: the polled record is marked
in-flight and therefore logically stale while canonicalization and all
replacement evidence are prevalidated. Physical deletion happens immediately
before reinsertion. No H-dependent public query can observe that interval, and
a failed contraction leaves the original key, witness, equation, and queue
entry intact.

If leaderization contracts support below the owner's current interface,
`rebuild` throws `InterfaceRestrictionRequiredException` before mutation and
requeues the record. The caller must supply an independent restriction
certificate and retry. A proper parent embedding is never cast to a renaming
or treated as proof of redundancy.

## Formal Obligations Discharged

Phase G directly realizes these fixed-batch obligations:

- Section 3.7's reverse parent tracking, stale-key removal, child `find`,
  embedding composition, quotient-first `canon_G`, flexible-port
  normalization, reinsertion, certified collision, recursive dirtiness, and
  quiescence;
- Proposition 3's finite administrative fixed point under a fixed finite
  stored-node batch, finite groups, and no rule insertion;
- Theorem 1 obligation 6 for separately certified interface restriction;
- Theorem 1 obligation 8 for rebuild collision only after retained child/EC
  derivations exist;
- the quiescent invariant `H(p)=a` iff `a` is a leader and `p` is in `B_a`;
- Seq order/multiplicity, Bag permutation quotient with multiplicity, and Set
  permutation/idempotence;
- opaque-child rebuilding: a hidden same-headed representative is never
  unfolded by administrative rebuild.

The runtime checker now recomputes and verifies U/M domains, nonleader shape
emptiness, all EC/PC/SC derivations, restriction chains, the complete reverse
parent index, dirty coverage for every stale invocation, certified node laws,
and exact H at quiescence.

## Located Faults And Corrections

| ID | Located fault or contradiction | Correction |
| --- | --- | --- |
| G-F01 | Exact state had status but no reverse parent index or dirty record identity | Added exact reverse uses and `ParentRecordKey` queue |
| G-F02 | Strict stored shapes had witnesses but no retained EC | Added one checked EC per strict fixed-batch shape |
| G-F03 | Union could leave shapes owned by a nonleader | Added pre-link shape/witness/EC absorption and literal parent relabeling |
| G-F04 | Phase F restriction verification could not publish an atomic transition | Added graph-owned shape, UF, group, history, and dirty-index transport |
| G-F05 | Restriction made stored invocation metadata stale with no replay path | Added composable restriction history and normalized find certificates |
| G-F06 | The proof algebra could rename into a larger context but could not narrow an equation whose endpoints factor through an inclusion | Added checked `CONTEXT_RESTRICTION` |
| G-F07 | Canonicalization rejected every dirty state, including the one record rebuild must recanonicalize | Added a private nonreentrant rebuild epoch; public dirty canonicalization still rejects |
| G-F08 | Initial queue code removed a record before nested checks, so the checker reported it as forgotten | Added an explicit in-flight dirty record |
| G-F09 | Initial failed contraction consumed the polled dirty record | Requeue the untouched record on every failed rebuild step |
| G-F10 | Initial collision orientation was checked after stale-key mutation | Precompute and verify the collision parent edge before mutation |
| G-F11 | Union/restriction could discard usable certified symmetries | Transport exactly the setwise stabilizer with reconstructed proofs |
| G-F12 | Existing tests did not distinguish rebuilding from opaque representative unfolding | Added a hidden same-headed Set regression |

The retained comparison `SlottedEGraph` still uses capped full scans and uncertified local
maps. That is not a contradiction inside the exact package: paper Section 5.2
and the architecture map classify it as a retained baseline, not Phase G.

## Tests

The isolated package compiles with `javac -Xlint:all`. All phase gates pass:

| Suite | Deterministic checks | Seed |
| --- | ---: | ---: |
| `TheoryFoundationsTest` | 1,053 | 55520260816 |
| `TheoryPortsTest` | 1,006 | 55520260817 |
| `TheoryStateTest` | 4,200 | 55520260818 |
| `TheoryLeaderKernelTest` | 233 | 55520260820 |
| `TheoryCanonicalizationTest` | 11,186 | 55520260819 |
| `TheoryCertificatesTest` | 250 | 55520260821 |
| `TheoryRebuildTest` | 101 | 55520260822 |
| **Total** | **18,029** | |

The Phase G suite covers certified parent collision, recursive fan-in,
quiescent idempotence, exact reverse uses, historical invocation replay,
independent restriction obligations, failed-state preservation, S3-to-S2
stabilizer restriction, nonempty shape absorption, union symmetry transport,
Seq/Bag/Set duplicate behavior, opaque same-head children, forward/reverse
dirty order, 48 generated admission/union/find/rebuild traces, 24 generated
symmetry/restriction traces, and malformed fixed-batch admission. The full
repository compiles, and unchanged `EGraphSaturationTest` and
`EGraphAblationTest` pass.

The matrix now has 125 obligation rows: 105 `EXACT`, 15 `PARTIAL`, 4 `ABSENT`,
and 1 `CONTRADICTED`.

## Remaining Mismatches

- `MUT-01`, `MUT-02`, `T1-01`, and `T1-03` remain non-exact because there is
  no source/rewrite `insertNode` sharing a coherent `d_n^w` construction.
- `CERT-03` and `CERT-05` retain exact fixed-batch EC/PC/SC evidence but lack
  the draft's source-level coherent witness-family parameter.
- `FIN-01` and `FIN-02` remain absent until Phase H.
- `INT-01` through `INT-03` remain open until the exact path is deliberately
  connected to the Alloy and reproducibility layers in Phase I.
- Cross-JVM/worker deterministic replay remains a Phase I manifest concern.
- A child symmetry induces a parent-interface permutation only when it
  stabilizes the parent's embedded image. Non-stabilizing symmetries are not
  invented as parent symmetries or interface restrictions. This is sound, but
  may be incomplete until a separate certified equation or restriction can
  represent that case.

## Theory Blockers

`PF3-TB01` remains: LNCS-3 Figure 4 constructs graph-only `d_n`, while the
main theorem requires witness-dependent `d_n^w`. Phase G does not fabricate
that missing coherent witness. Certified fixed-batch EC admission is a narrower
operation and is labeled as such.

`PF3-TB02` remains editorial: Figure 4 omits complete result components
required by Section 3.6. The artifact continues to retain
`(K,p,sigma,iota,omega,xi)`.

Neither blocker prevents administrative rebuilding of a supplied finite
certified batch. They do prevent claiming complete source insertion or the full
finite-unfolding theorem.

## Gate Decision

**Gate G passes for the fixed finite certified stored-node batch specified by
Section 3.7 and Proposition 3.** Full `checkInvariants()` passes after generated
legal mutation traces, and malformed represented transitions fail before state
publication.

This is not complete-engine acceptance and is not a claim of mechanical formal
verification. The reproducibility layer remains open and unchanged.

## Next Dependency

Phase H may now implement the bounded finite-unfolding conformance oracle over
the certified fixed-batch state. Source-level insertion must remain separate
until PF3-TB01 is repaired or an explicit coherent witness-family API is added.
