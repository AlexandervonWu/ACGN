# P0 Incident: Dependent JOIN Subtype Boundaries

## Trigger

`Alloy4FunAugmenter` aborted while preparing
`classified-data/productionLine_v1/over/wTqZ6ddZzBTkTXmka_inv4.als`.
The source contains `p.position`, where `p : Product` and
`position : Component -> Position` with `Component extends Product`.
Alloy admits the JOIN, but dependent-chain theory v4 required literal boundary
identity and raised `Product != Component`.

## Incorrect First Response

The first incident patch classified every nonidentical boundary as unsupported
and retained fixed-binary JOIN syntax. That was fail-closed, but it violated the
Phase-A2 requirement: a parser-authenticated subtype boundary has enough
evidence to remain a dependent ordered `Seq`. The fallback is retained only for
unresolved or unprovable typing, nullary results, or a JOIN shape that fails
the interior-arity associativity guard. Authenticated disjoint boundaries are
not unresolved: their positive-arity JOIN is a typed empty family.

## P0 Repair

1. `ExactAlloyType.fromParser(Type, CompModule)` records, for every exact
   relation column, the path obtained by repeatedly reading Alloy's
   `PrimSig.parent`, while requiring every object on that path to belong by
   identity to the originating parser module and every source-declared parent
   edge below the built-in `univ` root to carry a parser-assigned declaration
   position.
2. `DependentColumnEvidence` binds the exact column and its acyclic path.
3. `DependentBoundaryCorrespondence` derives exactly one of `EXACT`,
   `LEFT_SUBTYPE_OF_RIGHT`, or `RIGHT_SUBTYPE_OF_LEFT`; subtype rules require
   exact Alloy signature endpoints, including explicit `univ`, and use the shortest path prefix
   ending at the opposite boundary.
4. JOIN result typing still drops the two matched positions. The dependent
   operand carrier remains `Seq`; order and multiplicity are unchanged.
5. Source, application, theory-index, endpoint, and certificate keys bind the
   ancestry and correspondence. Ancestry is proof-only and deliberately does
   not change general `ExactAlloyType` equality or repair ordering.
6. The standalone verifier reconstructs every path and correspondence, rejects
   conflicting direct parents and cycles, recomputes each binary and flat fold,
   and rejects direction or endpoint mutations.
7. Final P0 review found that the first Lean executable wire checker validated
   parent steps without also binding the witness endpoints and rule direction.
   Java was already strict, but that formal mismatch blocked closure. The Lean
   checker now uses a closed `BoundaryRule`, binds both endpoints, validates the
   selected direction, and proves rejection of reversed, truncated, unrelated,
   and sibling witnesses.
8. The first implementation also exposed a public explicit-ancestry factory.
   Although unused by production, it was an unnecessary authority-forging
   surface. It has been removed: nontrivial ancestry is now constructed only by
   `ExactAlloyType.fromParser(Type, CompModule)` while walking module-owned
   `PrimSig.parent` links carrying live parser-assigned declaration positions;
   public ordinary relation constructors produce self-only evidence.
9. The standalone wire does not contain parser declarations or an independently
   pinned signature-hierarchy authority. Schema v9 therefore replays every
   subtype field and fold first, rejects malformed evidence, then classifies a
   structurally valid nonexact subtype bundle as
   `UNCHECKABLE / MISSING_EVIDENCE`. Exact-boundary chains remain eligible for
   verification. Schema v8 bytes are rejected rather than reinterpreted.
10. `ExactAlloyType` now uses Java stream version 3. This deliberately
    invalidates ancestry-free v2 serialized caches. Current v3 round trips
    preserve and revalidate ancestry as data, but the live-parser authority bit
    is transient and is cleared during reconstruction. Both old and current
    cached values must be rebuilt from Alloy source before nonexact ancestry can
    authorize producer construction. No migration fabricates authority.
11. A fresh review then showed that public `PrimSig` constructors could create
    a parent chain accepted by the public type converter. Requiring a declaration
    position alone was also insufficient because a caller could transplant a
    genuine parser `Attr` onto that synthetic object. Nontrivial producer
    ancestry now requires both identity membership in the exact originating
    `CompModule` and parser-assigned positions. `MASGVisitor` receives that
    module explicitly and every old module-free call site was rewired. Public
    synthetic chains, transferred attributes, module-free conversion, and
    deserialized values fail at the dependent type bridge. This check does not
    claim raw-source ownership or expand standalone verifier authority.
12. The first fresh ballot after that repair failed on the formal model itself:
    its fold admitted unary chains and unary interior JOIN operands, did not
    consume parser authority, assumed its result equality, and omitted the
    schema-v9 outcome boundary. The repaired Lean model binds each module
    object identity to its nominal carrier, consumes one positioned flag per
    parent edge, executable-checks producer and structural folds, rejects
    unary, nullary, unpositioned, swapped-identity, transferred, and serialized
    witnesses, and proves that valid nonexact v9 evidence is uncheckable rather
    than verified. That failed review round was stopped and invalidated.
13. The replacement ballot found that the first executable authority snapshot
    still allowed duplicate object IDs and accepted position flags supplied by
    the witness. It also omitted the fixed theory digest from the exact-chain
    outcome and assumed whole-record equality during replay. The snapshot now
    owns a unique identity-to-label ledger and concrete positioned parent-edge
    ledger; path admission replays both. Chain evidence checks pin the exact v5
    version and digest, use slice-local outcome names, and compare every wire
    commitment field explicitly. This remains a bounded finite model, not a
    proof of the Alloy parser, JVM object identity, SHA-256, or full wire parser.
    The second ballot was stopped and invalidated.
14. A token-conserving formal preflight then found that a module parent ledger
    could remain functional yet cyclic, and a variadic JOIN could consume a
    different valid module snapshot at each boundary. Snapshot validation now
    checks every object path for cycles, and the producer fold requires one
    common authority snapshot across the complete chain. The two-node cycle
    and a mixed-module three-operand JOIN are permanent rejecting witnesses.
15. The ensuing five-reviewer ballot exposed a legal built-in exception:
    `seq/Int` is Alloy's own child of `Int`, but its parent edge does not carry
    a user-source filename. Producer admission now recognizes only the exact
    object-identity pair `Sig.SEQIDX -> Sig.SIGINT` as built-in authority.
    User-declared non-`univ` edges still require a known parser position, and a
    same-label synthetic object receives no authority.
16. The same ballot found that module ownership was reduced to a Boolean after
    extraction. Two separately parsed modules with identical labels could
    therefore be mixed, and JOIN could consume the sole column carrying an
    earlier module's evidence. `ExactAlloyType` now retains the originating
    `CompModule` as a transient proof-only identity. Every present capability
    across all original variadic leaves must agree before folding, and each
    nonexact boundary requires authority on both endpoints. The capability is
    absent from value equality, hashing, stable keys, serialization, wire
    evidence, and metric ordering.
17. Lean's former `live : Bool` was caller-settable and could be restored by a
    record update after serialization. It is replaced by a proposition indexed
    by the exact immutable module snapshot. Serialized evidence has a distinct
    snapshot-only type and cannot inhabit producer authority. The formal model
    also distinguishes source-position provenance from the closed sequence-index
    and universe-root built-in provenance rules. This models the bounded authority transition; it
    does not claim to prove JVM access control.
18. A later blanket exclusion incorrectly treated explicit parser-provided
    `univ` as if it were a missing-type fallback. Dependent theory v8 removes
    that exclusion: `univ/univ` is exact, a concrete/`univ` boundary consumes
    the authenticated concrete-to-root path, and ARROW retains `univ` as an
    ordinary ordered column. Missing or unresolved type information still
    cannot invent `univ`. Parser-level regressions cover both associations of
    `(x.trans).univ` and `(univ.trans).x`; only the unary-interior JOIN
    counterexample blocks reassociation on associativity grounds.
19. A later review found that the complete all-disjoint matrix was still
    discarded after successful boundary replay. Dependent theory v9 represents
    that result as `AlloyEmptyRelation$arity=n`, preserves the complete
    disjoint matrix and ordered source `Seq`, and rejects only a computed
    nullary result. The standalone verifier independently checks the empty
    carrier, positive arity, absent common ancestor, structural key, and every
    disjoint case.
20. Fresh replay review then found two empty-family boundary gaps. The
    verifier's variadic JOIN guard still decoded interior operands as nonempty
    product lists, and the producer adapter returned an empty parser result
    before recursively checking source UNION/INTERSECTION operands. The guard
    now compares positive relation arity directly, while the adapter derives
    set-operator DAGs before accepting their result. Exact empty-interior wire
    replay and parser-backed empty set-operation fixtures cover both paths.

For the triggering source, the evidence is:

```text
left boundary:  AlloySig:Product
right boundary: AlloySig:Component
rule:           RIGHT_SUBTYPE_OF_LEFT
witness:        AlloySig:Component -> AlloySig:Product
result:         Rel(AlloySig:Position)
carrier:        dependent Seq[Product, Component->Position]
```

`AlloySig:univ` may occur above a carrier in parser provenance or as an explicit
JOIN endpoint. It is never substituted for a missing type.

## Implemented Dependent Type DAG Extension

Dependent theory v10 retains the single-parent `PrimSig` stack extracted from one
live parser module as nominal authority and layers a finite correlated-product
DAG over it for Alloy unions and intersections.

Draw edges from a more specific type toward a more general type, with concrete
declared signatures at the top and `univ` as the terminal sink. For declared
types `T1,...,Tn`, an intersection node has edges to every `Ti`, while every
`Ti` has an edge to a union node. The union node then has edges to each minimal
common supertype independently established by the authenticated source graph:

```text
                     Meet(T1,...,Tn)
                       /    |    \
                     T1     ...   Tn
                       \    |    /
                     Union(T1,...,Tn)
                              |
                    minimal common supertypes
                              |
                            univ
```

The union node retains its alternatives; it is not replaced by a common
ancestor. In particular, two divergent concrete branches whose only common
ancestor is `univ` are disjoint; this does not deny an explicit `univ` endpoint
its exact or subtype correspondence. Relation alternatives also remain correlated:
`(A -> B) + (C -> D)` is a sum of two products, never the widened product
`(A + C) -> (B + D)`. The v10 chain certificate consumes the DAG only after it
records every retained alternative and every omitted branch in a complete
row-major matrix. Synthetic meet, union, and common-ancestor nodes remain
observations and never become nominal parent-path authority.

## Formal Correspondence

`formal/PhaseA2DependentChains.lean` defines a direct-parent relation,
reflexive-transitive nominal subtype, hierarchy soundness, and boundary
correspondence. It proves:

- subtype paths preserve carrier membership;
- a certified boundary supplies an inclusion witness and therefore a shared
  boundary domain;
- `Component <: Product` follows from the concrete parent edge;
- the concrete wire is valid and corresponds to that subtype proof;
- `[Product] . [Component, Position]` has exact result `[Position]` under the
  explicit correspondence;
- invalid sibling, reversed-direction, missing-endpoint, and unrelated paths
  receive no such static typing result;
- unary JOIN/ARROW chains, unary JOIN interiors, and nullary JOIN results reject;
- parser object identities must correspond to the nominal path, and missing
  positions, transferred identities, and serialized authority reject;
- user-declared parent edges and the closed `seq/Int -> Int` built-in edge have
  separate provenance rules, and same-label synthetic built-ins reject;
- the computed producer fold, structural wire fold, and schema-v10 outcome are
  executable definitions rather than assumed result equalities;
- schemas v8 and v9 plus malformed v10 reject, exact v10 chain evidence may be accepted by
  this slice and remain eligible for the whole verifier, and structurally valid
  nonexact v10 evidence is `UNCHECKABLE / MISSING_EVIDENCE`, never `VERIFIED`;
- exact chain-slice acceptance requires the pinned v10 theory version and digest
  and does not itself claim whole-bundle `VERIFIED`;
- module object IDs are unique, and source positions belong to concrete
  child/parent declarations in the module snapshot rather than to the path
  witness;
- the complete module-owned functional parent ledger is acyclic, and every
  boundary in one variadic JOIN consumes the same module snapshot.
- live producer authority is indexed by its immutable snapshot rather than a
  caller-settable Boolean; serialization yields snapshot data only.

This is a bounded formal model of the implemented rule. The remaining trust
boundary includes parser-to-`PrimSig.parent` extraction and binding the parsed
declaration to the claimed source occurrence. The standalone verifier does not
reparse Alloy source and therefore does not certify a nonexact subtype path
without a future external hierarchy authority.

## Verification Record

- `TheoryDependentChainTest`: 149 checks, including legal sequence ancestry,
  identical foreign-module rejection, and authority-consumption resistance.
- `CanonicalAlloyPipelineTest`: 514 checks, including live module ownership,
  synthetic-constructor and transferred-attribute rejection, module-free
  conversion rejection, and non-authoritative serialization regressions.
- `CertificateBundleWriterTest`: 109 checks in each deterministic export run.
- `ProducerSemanticEvidenceMutationTest`: 113 checks, including subtype rule,
  witness-endpoint, and typed-empty DAG mutations.
- The current bounded run at `/tmp/acgn-section3-release-candidate-v10-r26` executes 58
  steps with zero executable failures. Its input-manifest SHA-256 is
  `4d4e2d54c78a2f2af0a1f0a16710a0a8bc7422b41c1905e30887213ee78f6156`.
  It remains `INCOMPLETE` because 182 repository-wide traceability diagnostics
  remain open; no phase-wide assurance result is inferred.
- Standalone certificate census remains `VERIFIED=1`, `UNCHECKABLE=2`,
  `REJECTED=0`; trusted fixture digests are unchanged.
- A structurally valid subtype fixture is `UNCHECKABLE / MISSING_EVIDENCE`;
  direction, endpoint, parent-ledger, cycle, and schema mutations reject.
- The exact triggering file completes `Alloy4FunAugmenter --skip-rewards`
  through report publication with one incorrect predicate and one ranking
  comparison.
- A balanced smoke of 129 production-line files across two problem sets and
  all four status directories completes: 5 AST-identical pairs excluded, 124
  models considered, 97 incorrect predicates, and 303 logical comparisons.
  This does not substitute for a fresh full-corpus experimental run.
