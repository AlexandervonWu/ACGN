# Phase H Finite-Unfolding Conformance

> Historical gate note: this file records the state at the close of Phase H,
> before experiment integration. Phase I has since closed the eight integration
> rows listed below. Current status is in `theory-artifact-matrix.md` and
> `theory-phase-i-artifact-integration.md`.

## Scope And Sources

Phase H was implemented on 2026-08-16 against the controlling mission
specification in
`/home/augustus/.codex/attachments/700dd038-fc5b-455b-9e11-c2aaa9aea2eb/pasted-text.txt`
and the repaired Figure 4 contract in `appendixC_v5.tex`. The implementation
is confined to `is.fivefivefive.CanDis.theory`, its deterministic tests, and
`docs`. It does not modify or import the Alloy adapters, datasets, experiment
runners, manifests, reproducibility scripts, or terminal package.

The oracle is executable conformance evidence for Theorem 1. It is not used as
a replacement for the equational proof.

## Executable Relation

`BoundedFiniteUnfoldingOracle` opens only on a current
`CoherentWitnessFamily` from a strict quiescent graph. For a root invocation it:

1. chooses each stored canonical shape and its exact `ShapeWitness`;
2. retains the oriented EC attached to that owner/shape record;
3. recursively replaces every invocation occurrence with a complete child
   tree;
4. drops a candidate at the depth frontier instead of inventing a cutoff term;
5. bounds the unique complete-tree set and every child cross product; and
6. rejects a stale family or dirty graph before reading publishable state.

Every `FiniteUnfoldingStepIndex` materializes the indexed relation with
`iota : Gamma -> Omega` and `mbar : T -> Omega`, then checks

```text
mbar o inclusion(S,T) = iota o m.
```

Coordinates in `T - S` receive deterministic fresh same-typed slots outside
the weakening image. `FiniteUnfoldingIndexTrace` threads those free coordinates
through the whole tree. Under `Bind` and `BindBlock`, bound coordinates remain
in the local scoped codomain and do not escape into the root's final free
context.

For every pair of distinct final contexts,
`FiniteUnfoldingCommonWeakening` constructs their union context and checks that
both embeddings restrict to the same map on the original `Gamma`, covering the
theorem's final common-weakening clause.

`FiniteUnfoldingEqualityWitness` separately discharges the theorem's graph
premise. It retains both certificate-preserving `find` results, selects a
certified leader permutation `pi` satisfying `m_i = m_j o pi`, reconstructs its
SC derivation, and composes a certificate between the original invocations.

## Observation Boundary

Each tree has a deterministic finite-term key modulo typed alpha-equivalence
and the declared `Seq=A`, `Bag=AC`, and `Set=ACI` laws. The key intentionally
does not orient arbitrary input equations. `FiniteUnfoldingConformanceReport`
therefore consumes an independent `FiniteUnfoldingObserver`, which may be a
normalizer or a bounded finite-model evaluator, and requires one observation
across every represented tree on both graph-equal sides.

This separation caught an intended contrast in the tests: a productive
`alias(false)` cycle has several structural finite terms, while the independent
Boolean model evaluates all of them to `false`.

## Located Faults And Corrections

| ID | Located fault or contradiction | Correction |
| --- | --- | --- |
| H-F01 | The first tree implementation retained shape witnesses and ECs but omitted the explicit indexed `iota`/`mbar` commuting square | Added `FiniteUnfoldingStepIndex` and whole-tree `FiniteUnfoldingIndexTrace` with checked fresh coordinates and final weakening |
| H-F02 | A first symmetry test captured a coherent family immediately after adding a generator, while the graph was correctly `DIRTY` | Rebuilt before witness capture; the oracle continues to reject dirty state |
| H-F03 | Comparing only graph or certificate keys would make conformance circular | Added an external observer boundary and retained normalized terms only as diagnostics/default structural observations |
| H-F04 | Naive global fresh-slot threading would leak binder coordinates into the outer context | Materialization tracks current free context separately from each lexical bound context and widens them independently |
| H-F05 | Emitting depth-cut leaves would not witness the paper's finite `Rep_G` relation | Depth exhaustion now yields no candidate; only complete finite trees are returned |
| H-F06 | The architecture map still said source insertion was closed after the repaired-PF3 implementation had added `insertNode` | Updated the map and package description to distinguish implemented source insertion from still-open Alloy adapter wiring |
| H-F07 | The first reachability check used compressing `find`, so a rejected unequal nonleader pair could change administrative state | Added a noncompressing provenance lookup for Phase H and a full-state before/after regression |
| H-F08 | A post-Phase-I integration case exposed that applying `Aut(beta)` after initial Bag/Set normalization could invalidate operand order and Set uniqueness in the transformed finite-term key | Re-normalize every affected Bag and Set after each binder-coordinate action; a nested-versus-grouped subtype-binder integration regression now checks the complete observation |

## Validation Matrix

`TheoryFiniteUnfoldingTest` performs 424 deterministic checks with seed
`55520260823`. It covers:

- productive acyclic and cyclic finite unfoldings;
- exact leader reachability and a nonidentity certified Bag symmetry;
- fresh redundant-coordinate restoration under two finite-model valuations;
- scoped binder-child materialization;
- 48 generated small well-typed graphs containing constants, aliases,
  negation, and AC conjunction; and
- malformed bounds, unknown roots, unequal leaders, stale families, dirty
  states, malformed ECs, malformed child trees, and enumeration overflow.

`TheoryDeterminismTest` adds 47 checks with seed `55520260824`. Complete graph
and canonical-shape SHA-256 digests agree over 12 repeated runs, reversed
admissible fixed-batch and Bag order, one versus available logical-core workers,
and two fresh JVM processes.

All eight prior Phase B-G suites pass unchanged. The isolated cumulative total
is 18,520 checks.

## Matrix Result At The Phase H Boundary

At the close of Phase H, the 125-row matrix was:

| Status | Rows |
| --- | ---: |
| `EXACT` | 117 |
| `PARTIAL` | 5 |
| `ABSENT` | 2 |
| `CONTRADICTED` | 1 |

The eight then-non-`EXACT` rows were all Phase I integration work:

- `BIND-03`: Alloy binder consumers do not yet issue typed law certificates;
- `MUT-02`: Fast Rewrite parser/rewrite construction does not yet use `insertNode`;
- `INT-02` and `INT-03`: typed Alloy adapter and reproducibility arm/manifest;
- `RW-02`, `RW-05`, `RW-06`, and `RW-07`: existing normalization results and
  rewrite evidence are not yet translated through the exact typed boundary.

Those rows were deliberately not relabeled in the Phase H gate. They are now
closed by the adapter and reproducibility rewiring documented in the Phase I
report.

## Gate Decision

At the Phase H boundary, Gate H passed for bounded generated finite unfoldings
of the isolated strict engine. Valid graph-equal invocations agreed under
independent finite-model observations, and every injected represented malformed
trace was rejected before it could alter graph state. The reproducibility layer
was intentionally still open at that point; Phase I subsequently integrated it.
