# Repaired-PF3 Pre-Phase-H Completion

## Scope

This pass was completed on 2026-08-16 against the repaired Figure 4 contract
in `appendixC_v5.tex` (SHA-256
`e3f78ec475d1d6bbf1645e09c57714a7f040bf26dca69b9bacabd7483d577fa2`).
It implements only work before Phase H that PF3-TB01 and PF3-TB02 had blocked.
The legacy normalization/evaluation code, reproducibility programs, experiment
runners, manifests, datasets, and terminal package were not changed.

The repaired contract keeps three operations distinct:

1. `leaderKernelTrace_G(n)` returns structural `(K,iota,xi)`.
2. `replayKernelCertificate_{G,w}` consumes an explicit coherent family and
   returns endpoint-checked `d_n^w`.
3. `canon_G^w` retains `(K,p,sigma,iota,omega,xi,d_n^w)`, while only `p` is a
   hash-cons key.

## Implemented Obligations

| Obligation | Implementation | Enforced invariant |
| --- | --- | --- |
| Coherent `w` | `CoherentWitnessFamily` | Exact EC map, total PC map, and deterministic SC reconstruction are captured only from a strict quiescent graph |
| Snapshot validity | Graph semantic revision | Find/path compression preserves a family; every semantic mutation makes it stale |
| Concrete container replay | `ContainerNormalizationCertificate` | One exact child proof per source occurrence; Seq order, Bag multiplicity, Set fibers, and required certified A/AC/ACI laws are checked |
| Exact kernel replay | `KernelReplayCertificate` | Recomputes the current `xi`, composes find/container/congruence steps, and checks `n -> K.act(iota)` endpoints |
| Binder-safe widening | `StructuralAlphaCertificate` | Exact-context widening may freshen bound coordinates, so the final step is certified typed alpha transport rather than Java equality |
| Complete coherent result | `CertifiedCanonicalizationResult` | Retains structural `(K,p,sigma,iota,omega,xi)` beside, not conflated with, `d_n^w` |
| Fresh witness | `FreshWitnessDefinitionCertificate` | A graph-checked fresh class defines `w_a` at the kernel type and effective interface `Delta_n` |
| Source insertion | `TypedSlottedPortEGraph.insertNode` | Validates children and all evidence before publishing U/M/H; stores the exact EC and complete source provenance |
| Hash collision | Existing effective-shape collision path plus insertion proofs | Collision is prevalidated and its derivation transitively retains both source-to-kernel certificates before union |

`CertificateVerifier` is now version
`typed-certificate-algebra-v3`. New proof categories remain in the sealed
certificate algebra; no structural trace is relabeled as a certificate.

## Located Faults And Corrections

### PH-F01: exact-context widening was assumed to be structural identity

The initial replay implementation asserted
`K.act(iota).equals(ambientLeaderNode)`. This is false under `Bind` and
`BindBlock`: capture-avoiding action may choose a fresh bound coordinate even
when the free-context inclusion is identity. The existing Phase DA test exposed
the fault immediately.

The assertion was removed. Replay now constructs an explicit
`StructuralAlphaCertificate` from the ambient leader syntax to
`K.act(iota)`, and the final `KernelReplayCertificate` still has the exact
dependent endpoint required by the appendix.

### PH-F02: a witness snapshot could otherwise be reused after mutation

An immutable proof map is not enough to establish that it describes the
current graph. The graph now owns a semantic revision. Coherent capture records
that revision, path compression does not alter it, and fixed-batch admission,
union, symmetry, restriction, source insertion, and semantic rebuild changes
invalidate older families. Stale replay fails before mutation.

### PH-F03: collision ECs previously had no source replay provenance

Fixed-batch collision certificates were sound for supplied ECs but could not
justify source insertion. Fresh witness definitions now retain their
`KernelReplayCertificate`; each inserted EC therefore contains its source
replay. `EffectiveShapeCollisionCertificate` composes both ECs, so a
source-source collision contains both `d_n^w` derivations before the parent
edge is admitted.

## Verification

The isolated package compiles with `javac -Xlint:all`. All prior deterministic
gates pass unchanged, and `TheoryCoherentInsertionTest` adds 18 checks for:

- empty and populated EC/PC/SC coherent families;
- fresh insertion and exact `Delta_n` exposure;
- stale-family rejection before mutation;
- equal-key collision with both kernel replays retained;
- graph-induced Set deduplication under certified ACI laws;
- binder-safe exact-context alpha transport;
- exact dependent certificate endpoints; and
- missing-child rejection before U, M, H, or provenance changes.

The cumulative isolated deterministic suite now reports 18,049 checks.

## Matrix Effect

The following formerly blocked rows move to `EXACT`:

- `CERT-03`: coherent EC/PC/SC witness family;
- `CERT-05`: witness-indexed whole-trace replay;
- `MUT-01`: central isolated mutation boundary including `insertNode`;
- `T1-01`: bottom-up certified insertion with effective interface; and
- `T1-03`: source hash collision through certified equal shapes.

The 125-row matrix is now 110 `EXACT`, 10 `PARTIAL`, 4 `ABSENT`, and 1
`CONTRADICTED`.

`MUT-02` intentionally remains `CONTRADICTED`: legacy parser and rewrite paths
have not yet been rewired to this one insertion API. `FIN-01` and `FIN-02`
remain Phase H work. `INT-*`, worker/process replay, and the experimental
workflow remain Phase I work. These are not PF3 regressions and were not
silently claimed as complete.

## Gate Decision

PF3-TB01 and PF3-TB02 no longer block pre-Phase-H implementation in the
isolated theory package. Phase H may now consume coherent insertion histories
and certificates. The reproducibility layer remains open and unchanged for the
later Phase I adapter.
