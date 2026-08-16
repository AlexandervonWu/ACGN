# Theory-to-Artifact Architecture Map

This document began as the Phase A architecture audit for commit
`a9261da4c096f6ba5fcb1a34bcac93cb1b1df23d`. The current normative source is
`E_Graphs_Draft_LNCS-1.pdf` with SHA-256
`6e44bae88fcd82fd9cd26db54d52025affb9f7d21d5cc3a2165211ab52a9d42f`.
It describes the legacy code as found and records the isolated exact path as
phase gates are implemented. Names under **Required exact boundary** that are
not listed in the Phase B-E exact package remain proposed later-phase classes.

## Current Execution Paths

### Canonical Alloy pipeline

```text
Alloy parser / MASGVisitor
  -> IRAgent.buildEGraph
  -> EGraphNode / EClass / EClassRef
  -> NormalForm.normalize, once per temporal phase
       lexical alpha-renaming
       let beta reduction
       implication / iff / ITE elimination
       NNF and temporal duals
       safe phase-local prenexing
       primitive-domain guard insertion
       A / AC / ACI normalization
       bounded local saturation
  -> Canonical / CanonicalDistance
  -> batch, augmentation, and backtranslation clients
```

This path contains the mature Alloy normalization behavior, but its graph
objects are untyped at the slot interface and do not realize the formal
`G=(U,M,H)` state. Relevant entry points are `IRAgent.java:79-166`,
`NormalForm.java:247-299`, `EGraphNode.java:181-310`, and
`Canonical.java:14-60`.

### Legacy ablation paths

```text
Alloy AST
  -> AlloyAstTermAdapter
  -> AlloyTerm
  -> RawEGraph / RawDeBruijnEGraph
     JavaEgglog / JavaEgglogDeBruijn
     SlottedEGraph
  -> AblationEngine.Result / EGraphStats
  -> EGraphAblationSuite and report generation
```

These are intentionally retained experimental engines. `SlottedEGraph` has
approximate union-find, slot maps, shapes, hash-consing, and permutation
groups, but paper section 5.2 explicitly records that they are not the typed,
certificate-checked construction.

### Theory-faithful carrier, port, state, and canonicalization path

Phases B-E add an isolated carrier, explicit-port algebra, Definition 5 state,
and graph-relative canonicalization without changing either execution path above:

```text
GraphType
  -> TypedSlot + SlotAlphabet
  -> TypedSlotContext + CanonicalSlotAlphabet
  -> TypedEmbedding
       -> TypedRenaming -> TypedPermutation
  -> TypedEClassInterface
  -> TypedInvocation
  -> PortSchema = One | Seq | Bag | Set | Bind
  -> OperatorDeclaration -> InstantiatedOperator
  -> PortValue = One | Seq | Bag | Set | Bind
       structural action + support + deterministic key
  -> FlatApplication -> TypedENode.flatConstruct
  -> CanonicalShape -> ShapeWitness
  -> TypedEClassRecord = (tau, S, B, G)
  -> ParentStep -> ParentPath -> TypedRenamedUnionFind
  -> TypedSlottedPortEGraph = (U, M, H, status)
  -> LeaderNormalizer
  -> TypedAlphaEquivalence
  -> TypedRenamingEnumerator
  -> ExhaustiveGraphCanonicalizer || ProductionGraphCanonicalizer
  -> CanonicalizationResult(shape, witness) [provisional support-preserving result]
  -> required: EffectiveCanonicalizationResult(kernel, shape, sigma, iota, omega, d)
```

The hierarchies are immutable and sealed. `NodeSealer` is the narrow callback
through which a graph turns a visible different-headed nested node into an
opaque invocation; Phase C validates its observable type, context, and support
contract. Phase D now supplies graph-owned state and provenance-preserving
leader lookup. Source/rewrite insertion remains a later controlled transition.

No legacy runner, dataset program, command-line entry point, reproducibility
script, experiment manifest, or existing terminal package depends on this path
yet. That boundary is intentional: Phase I remains the only integration point,
so the current measurement layer stays runnable while the exact engine is built
underneath it.

## Formal State Mapping

| Formal component | Current candidate | Current representation | Audit result | Required exact boundary |
| -- | -- | -- | -- | -- |
| Type algebra | `theory.GraphType`; legacy `Metatype`/strings | Exact immutable grammar carrier consumed directly by typed schemas, signatures, and class records; legacy remains separate | Phase B-D carrier exact | Preserve through later certificates and adapters |
| Typed slot | `theory.TypedSlot` | Type, disjoint alphabet, and unbounded ordinal form identity | Phase B exact | Consume only this slot value in the exact engine |
| Typed context | `theory.TypedSlotContext` | Immutable finite sorted subset with per-type operations | Phase B exact | Consume only this context value in ports and graph state |
| Embedding | `theory.TypedEmbedding` | Sealed, total, immutable, type-preserving injection over declared contexts | Phase B exact | Reuse in typed actions and renamed union-find edges |
| Renaming/permutation | `theory.TypedRenaming`, `theory.TypedPermutation` | Sealed onto and same-context refinements | Phase B exact | Reuse in canonicalization and certified symmetry groups |
| Invocation `m*a` | `theory.TypedInvocation` and `TypedEClassInterface` | Class interface plus validated embedding; caller context is codomain; graph registration rejects ID/metadata reuse | Phase B carrier and Phase D ownership exact | Preserve in certified transitions |
| Port grammar | `theory.PortSchema` and `theory.PortValue`; legacy child lists remain separate | Five sealed schema classes and five sealed immutable value classes | Phase C grammar, typing, action, support, and local normalization exact | Reused without conversion in Phase D stored shapes |
| Signature `Sigma(f)` | `theory.OperatorDeclaration` and `InstantiatedOperator`; legacy opcode tables remain separate | Type parameters, recursive schemas, output, law declarations, and flat port are one immutable value | Phase C typed signature exact; semantic law certificates await Phase F | Bind Phase F certificates to these declarations |
| `U` | Exact `TypedRenamedUnionFind`; legacy `RenamedIdUnionFind` remains separate | Total typed parent assignments, identity roots, formal-direction embeddings, and retained primitive paths | Phase D embedding/state component exact; parent certificates await Phase F | Attach `ParentEdgeCertificate` to primitive steps |
| `M(a).tau_a` | `TypedEClassRecord.interfaceValue().outputType()` | Immutable graph-owned output type | Phase D exact | Preserve in all certified mutations |
| `M(a).S_a` | `TypedEClassRecord.interfaceValue().exposedSlots()` | Immutable graph-owned finite typed context | Phase D exact | Change only by certified Phase F restriction |
| `M(a).B_a` | `TypedEClassRecord.storedShapes()` | Immutable ordered `CanonicalShape -> ShapeWitness` dependent map; current Phase E returns the shape and instantiating renaming only on the support-preserving domain | Phase D carrier exact; revised Appendix C result transport remains partial | Populate only after effective-support canonicalization and certified insertion are reconciled |
| `M(a).G_a` | `TypedSymmetryGroup` | Exact finite typed closure on `S_a` | Typed group exact; nontrivial provenance partial | Add and transport Phase F symmetry certificates |
| `H` | `TypedSlottedPortEGraph` hash-cons | Typed canonical shape to leader class ID with a checked iff invariant at quiescence | Phase D exact current-state invariant | Maintain transactionally during Phase G rebuild |
| Dirty state | `GraphStatus` in `TypedSlottedPortEGraph` | Explicit `DIRTY`/`QUIESCENT`; dirty H queries reject | Phase D guard partial because parent-use queue/rebuild is absent | Add deduplicated dirty-parent queue and exact rebuild in Phase G |
| Equality provenance | None | Direct mutation | Absent | Sealed typed certificate hierarchy |
| `canon_G` | `ExhaustiveGraphCanonicalizer` and `ProductionGraphCanonicalizer`; legacy `SlotCanonicalizer` remains separate | Exact kernel orbit on support-preserving states; current result lacks the revised appendix's kernel, ambient embedding, and derivation | Differential tests pass on the guarded domain; PF-TB01-PF-TB03 block totality and stable certificate endpoints | Repair Sections 3.6-3.7/Theorem 1, implement the effective result, then add certified binder/symmetry inputs |
| Indexed alpha relation | `TypedAlphaEquivalence` | Separate structural and graph-relative recursive judgements over nodes and all five ports | Structural relation exact; graph-relative relation partial until group provenance exists | Consume only Phase F certified group state |
| Invariant checker | `TypedSlottedPortEGraph.checkInvariants()`; legacy scenario assertions | Audits all currently representable U/M/H, metadata, child, group, and quiescent hash-cons invariants | Phase D coverage partial pending certificates/rebuild | Extend checker with every Phase F-G transition object |

The corresponding row-level evidence is in
[`theory-artifact-matrix.md`](theory-artifact-matrix.md), especially `STATE-*`,
`UF-*`, `CAN-*`, and `CERT-*`.

## Current Mutation Inventory

The following paths can change a graph-relevant value. None currently carries
the complete typed certificate boundary required by the paper.

| Owner | Mutation path | State affected | Current guard | Formal consequence |
| -- | -- | -- | -- | -- |
| `IRAgent` | `new EGraphNode`, `addChild`, source metadata setters (`IRAgent.java:88-162,283-301`) | Nodes, child invocations, parser metadata | Opcode helpers | Bypasses typed signature and explicit port construction |
| `NormalForm` | Synthetic node construction, `addChild`, `setChildren`, alpha setters (`NormalForm.java:301-1445`) | Matrix syntax and e-class slot cache | Stage-local rewrite conditions | Must eventually feed one typed `flatConstruct` insertion boundary |
| `NormalForm` | `registerQuantifierSymmetries` -> `EClass.addSlotSwap` (`NormalForm.java:399-413`) | E-class symmetry group | Partial descriptor comparisons | Omits certificate and complete binder descriptor |
| `EGraphNode` | Public constructor and child mutators (`EGraphNode.java:181-269`) | Node shape and inferred slots | Null checks only | Generic port/schema bypass |
| `EGraphNode` | `saturate`/`saturateOnce` (`EGraphNode.java:410-645`) | Representative shape, equivalent nodes, child lists | Bounded 32 iterations | Mixes rewriting, normalization, and graph mutation; opens opaque representatives |
| `EGraphNode` | Static `union` (`EGraphNode.java:293-310`) | Union-find; same-leader symmetry | Arena check | Union has no equality certificate; same-leader event infers symmetry |
| `EGraphNode.EClass` | `addEquivalentNode`, snapshots, shape cache (`EGraphNode.java:1093-1118`) | `B_a` approximation | String-key dedup | No typed shape witness or hash-cons invariant |
| `EGraphNode.EClass` | `recomputeSlots` (`EGraphNode.java:1120-1152`) | Exposed interface, group, union-find maps | Syntactic intersection | Uncertified interface restriction |
| `EGraphNode.EClass` | `addSlotSwap` / invocation equivalence (`EGraphNode.java:1083-1086,1163-1168`) | Symmetry group | Untyped bijection checks | Missing witness equation/provenance |
| `RenamedIdUnionFind` | `register`, `updateSlots`, `union`, path compression (`RenamedIdUnionFind.java:20-123`) | Parent forest and correspondences | Untyped map validation | Wrong formal edge direction; partial composition; no path certificate |
| `SlotPermutationGroup` | `setSlots`, `addGenerator`, `addSwap`, `addInvocationEquivalence` (`SlotPermutationGroup.java:23-106`) | Interface-local group | Untyped closure checks | Restriction and symmetry insertion are uncertified |
| `AlloyTerm` | Public `atom`, `variable`, and `node` factories | Legacy term tree | Structural null/copy checks | Generic list can bypass formal port grammar |
| `SlottedEGraph.Core` | `add`/`intern` (`SlottedEGraph.java:101-219`) | Classes, records, parents, hash-cons | Local slot arrays | No typed schema, output, or complete witness |
| `SlottedEGraph.Core` | `findPath` compression (`SlottedEGraph.java:236-252`) | Parent mappings | Array bounds mapped to `-1` | No total typed embedding or certificate composition |
| `SlottedEGraph.Core` | `union` and `recordSymmetry` (`SlottedEGraph.java:255-353`) | Forest, redundant-slot count, group | Rank/count heuristics | Infers symmetry and redundancy from endpoint correspondence |
| `SlottedEGraph.Core` | `rebuild`/`compact` (`SlottedEGraph.java:388-455`) | Records, hash-cons, interfaces, unions | Full scan capped at 16 rounds | No dirty-parent fixed point or certified restriction/congruence |
| `IntEGraph` | `add`, `union`, `rebuild` | Ordinary e-classes and hash-cons | Structural keys | Valid legacy baseline, not renamed typed state |

Read-only operations are also significant: `EClassRef.canonical` and
`equivalentTo` (`EGraphNode.java:994-1021`), `Canonical.compare`, and ablation
measurements can observe state without a formal graph-wide quiescence guard.

## Required Exact Engine Boundary

Later phases extend the distinct Phase B-E path rather than relabeling a legacy
arm. The carrier, port, signature, flat-construction, Definition 5 state, and
canonicalization blocks shown here are implemented:

```text
Alloy typed adapter
  -> Typed source/rewrite syntax
  -> [implemented] GraphType / TypedSlotContext /
       TypedEmbedding / TypedInvocation
  -> [implemented] OperatorDeclaration + structural law declarations
       One / Seq / Bag / Set / Bind ports
       typed action, support, deterministic structural keys
       visible-only TypedENode.flatConstruct
  -> [implemented] CanonicalShape + ShapeWitness
       TypedEClassRecord + TypedSymmetryGroup
       TypedRenamedUnionFind + provenance-retaining find
       TypedSlottedPortEGraph(U, M, H, status)
  -> [support-preserving implementation, PF-TB01-PF-TB03 guarded] leader-first canon_G
       exhaustive reference + streaming production
       indexed structural / graph-relative alpha
       least CanonicalShape + instantiating TypedRenaming
  -> [Phase F] insertNode
  -> unionCertified / addSymmetryCertified /
     restrictInterfaceCertified
  -> [Phase G] dirty-parent rebuild to quiescence
  -> [Phase H] finite-unfolding conformance
```

Phase D intentionally exposes no public raw link or record-registration API.
Its package-private setup transitions exist only to test the state algebra
before certificates are available. `ParentPath` retains primitive historical
steps across compression, but those steps are not mislabeled as proof objects;
Phase F must attach the required certificates.

The exact graph already exposes the stable identifiers
`typed-slotted-port-egraph` and `canon-g-production-v1`. Its public
`canonicalize` method is an isolated provisional boundary: revised Appendix C
requires a richer effective-support result before Phase F or I may depend on
it. No current experiment or terminal package imports it, so that repair does
not require changing any legacy measurement.

Phase E also exposes a formal conflict instead of weakening a carrier. Revised
Appendix C selects effective support and a separate ambient embedding, but
Sections 3.6-3.7, Corollary 3, and Theorem 1 still use the incompatible
pre-find/full-support contract. Both implementations throw
`CanonicalizationDomainException`; `theory-pre-phase-f-audit.md` records the
three remaining theory blockers and the required proof updates.

The mutation surface should be limited to these graph-owned operations:

| Operation | Accepted evidence | Postcondition |
| -- | -- | -- |
| `insertNode` | Well-typed flat node plus certified source-to-kernel provenance | Fresh class exposes the full support selected by the resolved PF-TB02 contract; shape witness and dirty uses recorded |
| `unionCertified` | Typed input/rewrite or congruence certificate | Distinct leaders joined by a certified parent edge; same leader does not alter symmetry |
| `addSymmetryCertified` | Symmetry certificate with endpoint equation and induced typed permutation | Verified generator added to `G_a` |
| `restrictInterfaceCertified` | Independence/factorization certificate | All shapes, parent embeddings, and certificates transported; parents dirtied |
| `findWithProvenance` | Typed invocation | Leader invocation, composed embedding, and certificate derivation |
| `rebuild` | Dirty graph | Deduplicated parent worklist exhausted and `H` invariant restored |
| `checkInvariants` | Any state, with quiescence-aware checks | Exact diagnostic or success; no mutation except an explicitly selected rebuild |

Internal parent edges, class interfaces, stored shapes, symmetry groups, and
hash-cons ownership must be immutable outside that boundary.

## Dependency Map

| Phase | Depends on | Enables | Matrix families |
| -- | -- | -- | -- |
| B: foundational algebra (complete) | Phase A audit | Typed invocation and support | `TY`, `EMB`, `INV`, `SUP` |
| C: ports and signatures (complete) | Phase B | Flat typed construction and Phase B-C total keys | `PORT`, `SIG`, structural portions of `LAW`, `FLAT`, `ORD` |
| D: state and renamed union-find (complete) | B-C | Direct `G=(U,M,H)` representation and provenance-retaining typed find | `STATE`, `UF`, `HC` |
| E: canonicalization (support-preserving domain implemented; PF-TB01-PF-TB03 open) | B-D | Differential exhaustive/production kernel orbit, exact indexed alpha, and a provisional integration API | `ALPHA`, `GEQ`, `CAN`, `SYM`, `BIND` |
| F: certificates (blocked at entry) | B-E plus resolution of PF-TB01-PF-TB03 | Certified source-to-kernel transport, union, symmetry, and restriction | `CERT`, `UNION`, `REST`, `CONG` |
| G: rebuilding | D-F | Quiescent hash-cons and invariant checking | `REB`, `CHK`, `T1` |
| H: finite unfolding | F-G | Executable theorem conformance | `FIN`, `TEST` |
| I: Alloy/evaluation integration | B-H | Separate theory-faithful experiment arm | `INT`, `RW` |

No later phase can safely compensate for an unresolved foundational embedding
or context invariant: types and map direction must be fixed before graph-state
or certificate work begins.
