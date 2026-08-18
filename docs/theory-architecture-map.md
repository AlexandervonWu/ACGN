# Theory-to-Artifact Architecture Map

This document began as the Phase A architecture audit for commit
`a9261da4c096f6ba5fcb1a34bcac93cb1b1df23d`. The current normative source is
`E_Graphs_Draft_LNCS-3.pdf` with SHA-256
`6b128156008abe8065fe2cf3871950ff0206a47dcc263e3486e475053e4a0d33`;
the LNCS-3 re-audit used HEAD `f0e326ab41fbdda9e21b36cb11aecc1863d9712d`
in a dirty worktree.
It describes the Fast Rewrite IR as found and records the certificate-integrated
theory path from its isolated phase gates through the Phase I integration boundary. Names under
**Required exact boundary** that are not listed in the current theory package
remain proposed later-phase classes.

## Current Execution Paths

### Integrated canonical Alloy pipeline

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
  -> Canonical.Prepared
       -> Fast Rewrite IR Canonical / CanonicalDistance reference diagnostics
       -> TheoryAlloyAdapter
            typed signatures, slots, binders, and certified containers
            TypedSlottedPortEGraph.insertNode
            fixed-batch rebuild + strict checkInvariants
            current coherent finite-unfolding observation
          -> CanonicalAlloyPipeline
               CanonicalObservation equality/digest/serialization
               RepairProjection with certified phase descriptors
               established CanonicalDistance geometry on the quotient
               CanonicalRepresentativeTreeDistance diagnostic only
  -> batch, augmentation, ablation, and capability clients
```

The mutable `EGraphNode` graph is now an explicit preprocessing IR, not the
formal state. `TheoryAlloyAdapter` is the one-way boundary into the exact
`G=(U,M,H)` implementation. It never exposes a raw exact mutation path, and
direct `Canonical` execution remains available as the Fast Rewrite metric
differential. Relevant entry points are `IRAgent`, `NormalForm`, `Canonical.prepare`,
`TheoryAlloyAdapter`, and `CanonicalAlloyPipeline`.

### Retained comparison engines

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

### Certificate-Integrated IR path

Phases B-H add the carrier, explicit-port algebra, Definition 5 state,
structural leader-kernel extraction, quotient-first canonicalization, a closed
typed certificate/rebuild algebra, and bounded finite-unfolding conformance
without changing Fast Rewrite IR behavior. Phase I connects that exact path to the
Alloy and experiment layers as an additional, explicitly identified engine.
LNCS-3 extended the Phase C and E contracts; revised Phase C, Phase DA, Phase
E, Phase F certificate admission, and Phase G fixed-batch rebuilding are implemented. The draft's
witness-dependent whole-node replay remains separated from the structural
canonicalization result rather than being fabricated from graph state alone:

```text
GraphType
  -> TypedSlot + SlotAlphabet
  -> TypedSlotContext + CanonicalSlotAlphabet
  -> TypedEmbedding
       -> TypedRenaming -> TypedPermutation
  -> TypedEClassInterface
  -> TypedInvocation
  -> BinderCoordinateDescriptor -> BinderBlockDescriptor
       -> BinderAutomorphismGroup [certificate-bearing generators]
  -> [implemented] PortSchema = One | K^epsilon | Bind | BindBlock
       K in {Seq, Bag, Set}, epsilon in {+, 0}
  -> OperatorDeclaration -> InstantiatedOperator
  -> [implemented] PortValue = One | K^epsilon | Bind | BindBlock
       structural action + support + deterministic key
  -> FlatApplication -> TypedENode.flatConstruct
  -> CanonicalShape -> ShapeWitness
  -> TypedEClassRecord = (tau, S, B, G)
  -> ParentStep -> ParentPath -> TypedRenamedUnionFind
  -> TypedSlottedPortEGraph = (U, M, H, status)
  -> [implemented Phase DA] LeaderKernelExtractor
       LeaderKernelResult(K, iota, xi)
       LeaderKernelTrace + LeaderPortTrace
       ContainerNormalizationTrace
       ExactContextRestrictor
  -> LeaderNormalizer [compatibility projection]
  -> TypedAlphaEquivalence
  -> TypedRenamingEnumerator
  -> [implemented Phase E]
       ExhaustiveGraphCanonicalizer || ProductionGraphCanonicalizer
       local Q_G before Seq/Bag/Set reconstruction
  -> CanonicalizationResult(kernel, shape, sigma, iota, omega, xi)
  -> [implemented Phase F]
       TypedCertificateEndpoint -> sealed TypedEqualityCertificate
       input/rewrite, forward congruence, parent edge, symmetry,
       binder automorphism, interface restriction, and container laws
       CertificateVerifier + certificate-preserving find
       unionCertified + addSymmetryCertified
  -> [implemented Phase G]
       ParentRecordKey reverse uses + deduplicated dirty queue
       exact shape equations (EC)
       RebuildCongruenceCertificate + EffectiveShapeCollisionCertificate
       restrictInterfaceCertified + historical invocation transport
       fixed-batch rebuild to exact quiescent H
  -> [implemented after repaired PF3]
       CoherentWitnessFamily(EC, PC, SC)
       ContainerNormalizationCertificate + StructuralAlphaCertificate
       KernelReplayCertificate(xi,w) = d_n^w
       CertifiedCanonicalizationResult(K,p,sigma,iota,omega,xi,d)
       graph-owned certified insertNode + retained collision provenance
  -> [implemented Phase H]
       FiniteUnfoldingTree + FiniteUnfoldingIndexTrace
       FiniteUnfoldingCommonWeakening
       explicit local iota/mbar commuting squares and scoped freshness
       FiniteUnfoldingEqualityWitness(find, certified leader pi)
       BoundedFiniteUnfoldingOracle + independent observations
  -> [implemented Phase I]
       TheoryAlloyAdapter
       CanonicalAlloyPipeline
       CertifiedSemanticArtifact -> CanonicalObservation
       CertifiedSemanticArtifact + repaired NormalForm -> RepairProjection
       RepairView -> QuotientRepairDistance (Fast Rewrite metric semantics)
       CanonicalBatchTest + Alloy4FunAugmenter
       typed-slotted-port-egraph ablation/capability arm
       manifest-v3 compatibility and output-hash gate
```

The hierarchies are immutable and sealed. `NodeSealer` is the narrow callback
through which a graph turns a visible different-headed nested node into an
opaque invocation; Phase C validates its observable type, context, and support
contract. Phase D supplies graph-owned state and provenance-preserving leader
lookup. Phase DA turns that lookup into an exact leader kernel and structural
replay trace. Phase F gives every represented equality-producing transition a
machine-checked proof object and preserves parent proofs through path
compression. Phase G adds certificate-preserving interface restriction and
administrative rebuilding. The repaired PF3 contract additionally supplies
coherent witness capture, endpoint-checked trace replay, and certified source
insertion. Phase H supplies the theorem-shaped bounded validation oracle.
Phase I adapts only completed phase-local normalization results, inserts them
through the certified source boundary, and exposes exact equality/distance to
the four experiment clients. Existing engines and their fields remain present,
so historical and exact measurements are not conflated.

## Maintained Paths And Tradeoff

The Fast Rewrite IR and Certificate-Integrated IR are both maintained parts of
the artifact. The first owns the efficient repaired `NormalForm`, bounded
rewrite saturation, and direct `CanonicalDistance` execution. The second owns
typed slotted-port state, certificate admission, strict congruence and
quiescence checks, canonical observations, and the certified repair
projection. Phase I connects them without replacing either implementation.

The Fast Rewrite IR is appropriate for large-corpus ranking and rapid repeated
experiments. The Certificate-Integrated IR spends substantially more CPU on
proof construction, law validation, renaming orbits, rebuild, invariant
checking, and finite observations. In return it fails closed when semantic
admissibility cannot be certified and provides an auditable boundary against
unsupported scope permutations or rewrite laws. The current 61,598-pair run
measured 18.360 seconds versus 2,265.990 seconds wall time and 2,316 versus
2,317 `CORRECT` zeroes, with no incorrect zeroes in either arm. Those corpus
labels and bounded Alloy checks are evidence, not an unbounded soundness proof.

## Formal State Mapping

| Formal component | Current candidate | Current representation | Audit result | Required exact boundary |
| -- | -- | -- | -- | -- |
| Type algebra | `theory.GraphType`; Fast Rewrite `Metatype`/strings | Exact immutable grammar carrier consumed directly by typed schemas, signatures, and class records; Fast Rewrite IR remains separate | Phase B-D carrier exact | Preserve through later certificates and adapters |
| Typed slot | `theory.TypedSlot` | Type, disjoint alphabet, and unbounded ordinal form identity | Phase B exact | Consume only this slot value in the exact engine |
| Typed context | `theory.TypedSlotContext` | Immutable finite sorted subset with per-type operations | Phase B exact | Consume only this context value in ports and graph state |
| Embedding | `theory.TypedEmbedding` | Sealed, total, immutable, type-preserving injection over declared contexts | Phase B exact | Reuse in typed actions and renamed union-find edges |
| Renaming/permutation | `theory.TypedRenaming`, `theory.TypedPermutation` | Sealed onto and same-context refinements | Phase B exact | Reuse in canonicalization and certified symmetry groups |
| Invocation `m*a` | `theory.TypedInvocation` and `TypedEClassInterface` | Class interface plus validated embedding; caller context is codomain; graph registration rejects ID/metadata reuse | Phase B carrier and Phase D ownership exact | Preserve in certified transitions |
| Port grammar | `theory.PortSchema` and `theory.PortValue`; Fast Rewrite child lists remain separate | Six sealed schema/value variants implement `One`, indexed Seq/Bag/Set, unary `Bind`, and descriptor-indexed `BindBlock`; strict consumption requires certified container laws and binder automorphisms | Phase C carrier and Phase F provenance gate exact | Preserve certificates during source insertion and later integration |
| Signature `Sigma(f)` | `theory.OperatorDeclaration` and `InstantiatedOperator`; Fast Rewrite opcode tables remain separate | Type parameters, recursive schemas, output, law declarations with structured certificates, and flat port form one immutable value | Phase C typed signature and Phase F law provenance exact | Adapter issues only `canonical-alloy-signature-v7` named-reference, container, fixed-commutativity, and binder axioms |
| `U` | Exact `TypedRenamedUnionFind`; Fast Rewrite `RenamedIdUnionFind` remains separate | Total typed parent assignments, identity roots, formal-direction embeddings, retained primitive paths, historical restriction transport, and composed certificates | Phase D/F carrier plus Phase G transport exact | Preserve this boundary in the Alloy adapter |
| `M(a).tau_a` | `TypedEClassRecord.interfaceView().outputType()` | Immutable graph-owned output type | Phase D exact | Preserve in all certified mutations |
| `M(a).S_a` | `TypedEClassRecord.interfaceView().exposedSlots()` | Immutable graph-owned finite typed context replaced only by a prevalidated factorization transaction; fresh insertion exposes exactly `Delta_n` | Phase G restriction and certified source insertion exact | Adapter narrows source nodes to exact support and widens only returned invocations |
| `M(a).B_a` | `TypedEClassRecord.shapeWitnesses()` | Immutable ordered `CanonicalShape -> ShapeWitness` map; every strict entry has an exact EC, including fresh source insertions | Fixed-batch rebuild and source insertion exact | Preserve source provenance when adapting rewrites |
| `M(a).G_a` | `TypedSymmetryGroup` | Exact finite typed closure on `S_a`, with derivations for every element and certified stabilizer transport through union/restriction | Phase F/G exact | Adapter emits only complete-descriptor binder generators with structured origins |
| `H` | `TypedSlottedPortEGraph` hash-cons | Typed canonical shape to leader ID; rebuild removes stale keys, handles certified collisions, and restores the checked iff | Phase G exact for fixed batches | Exact clients observe H only after adapter-enforced quiescence |
| Dirty state | `GraphStatus`, `ParentRecordKey`, reverse parent uses | Explicit status, exact reverse index, deduplicated queue, and private in-flight marker; dirty H/canonicalization queries reject | Phase G exact | Adapter rebuilds before every coherent-family read and rejects non-quiescence |
| Equality provenance | `TypedEqualityCertificate` hierarchy and `CertificateVerifier` | Closed typed derivations including ECs, context restriction, concrete container normalization, structural alpha, kernel replay, witness definition, rebuild congruence, and effective-shape collision | Phase F/G plus repaired PF3 replay exact for represented transitions | Preprocessing cannot bypass certificate-bearing exact admission |
| Coherent witness family | `CoherentWitnessFamily` | Graph-owned immutable EC/PC/SC reconstruction snapshot tied to a semantic revision; path compression preserves it and graph mutation makes it stale | Repaired PF3 coherent-prefix contract exact | Capture only at strict quiescent prefixes |
| Indexed finite unfolding | `FiniteUnfoldingTree`, `FiniteUnfoldingIndexTrace`, `FiniteUnfoldingStepIndex`, `FiniteUnfoldingCommonWeakening` | Complete bounded representation trees retain shape witnesses and ECs; every local `iota`/`mbar` square, fresh redundant image, binder scope, final weakening, and pairwise common-context restriction is checked | Phase H bounded relation exact | Consume only a current coherent quiescent prefix |
| Finite-unfolding conformance | `FiniteUnfoldingEqualityWitness`, `BoundedFiniteUnfoldingOracle`, `FiniteUnfoldingConformanceReport` | Certified find/symmetry reachability plus independent normalized or finite-model observations over every complete bounded representation | Phase H executable oracle exact | Keep as validation evidence, not a proof or runtime equality definition |
| `leaderKernelTrace_G` | `LeaderKernelExtractor`, `LeaderKernelResult`, `LeaderKernelTrace`, `KernelReplayCertificate` | Structural extraction returns `(K,iota,xi)`; separate replay against coherent `w` composes find, container, congruence, and alpha steps to exact `d_n^w` endpoints | Structural and dependent boundaries exact | Do not relabel `xi` itself as a certificate |
| `canon_G` | Both graph canonicalizers plus `CertifiedCanonicalizationResult`; Fast Rewrite `SlotCanonicalizer` remains separate | Structural result remains `(K,p,sigma,iota,omega,xi)`; coherent wrapper adds only endpoint-checked `d_n^w`, and only `p` is hashed | Structural Phase E and repaired PF3 wrapper exact | Preserve the projection distinction in integration |
| Indexed alpha relation | `TypedAlphaEquivalence` | Separate structural and graph-relative recursive judgements over nodes and all six ports; strict graph-relative comparison admits only certified group state | Phase E relation plus Phase F group provenance exact | Preserve this boundary in the Alloy adapter |
| Invariant checker | `TypedSlottedPortEGraph.checkInvariants()`; Fast Rewrite scenario assertions | Recomputes U/M domains, EC/PC/SC proofs, restriction history, exact reverse uses, dirty coverage, node-law provenance, nonleader emptiness, and quiescent H iff B | Phase G exact for represented state | Extend only for later source insertion/unfolding state |

The corresponding row-level evidence is in
[`theory-artifact-matrix.md`](theory-artifact-matrix.md), especially `STATE-*`,
`UF-*`, `CAN-*`, and `CERT-*`.

## Current Mutation Inventory

The following Fast Rewrite IR paths can change the preprocessing IR and remain
deliberately outside the exact package. Phase I does not reinterpret those
objects as formal state: it translates their completed normalization result
through `TheoryAlloyAdapter`. The exact package exposes only fixed-batch
admission, certified union/symmetry/restriction, provenance find,
deterministic rebuilding, certified source insertion, and read-only bounded
unfolding.

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
| `AlloyTerm` | Public `atom`, `variable`, and `node` factories | Retained comparison term tree | Structural null/copy checks | Generic list can bypass formal port grammar |
| `SlottedEGraph.Core` | `add`/`intern` (`SlottedEGraph.java:101-219`) | Classes, records, parents, hash-cons | Local slot arrays | No typed schema, output, or complete witness |
| `SlottedEGraph.Core` | `findPath` compression (`SlottedEGraph.java:236-252`) | Parent mappings | Array bounds mapped to `-1` | No total typed embedding or certificate composition |
| `SlottedEGraph.Core` | `union` and `recordSymmetry` (`SlottedEGraph.java:255-353`) | Forest, redundant-slot count, group | Rank/count heuristics | Infers symmetry and redundancy from endpoint correspondence |
| `SlottedEGraph.Core` | `rebuild`/`compact` (`SlottedEGraph.java:388-455`) | Records, hash-cons, interfaces, unions | Full scan capped at 16 rounds | No dirty-parent fixed point or certified restriction/congruence |
| `IntEGraph` | `add`, `union`, `rebuild` | Ordinary e-classes and hash-cons | Structural keys | Valid retained baseline, not renamed typed state |

Read-only operations are also significant: `EClassRef.canonical` and
`equivalentTo` (`EGraphNode.java:994-1021`), `Canonical.compare`, and ablation
measurements can observe state without a formal graph-wide quiescence guard.

## Required Exact Engine Boundary

Later phases extend the distinct Phase B-G path rather than relabeling the Fast Rewrite IR
arm. The carrier, port, signature, flat-construction, Definition 5 state,
canonicalization, and certificate-admission blocks shown here are implemented:

```text
Alloy typed adapter
  -> Typed source/rewrite syntax
  -> [implemented] GraphType / TypedSlotContext /
       TypedEmbedding / TypedInvocation
  -> [implemented] OperatorDeclaration + certified law declarations
       One / K+/K0 Seq / Bag / Set / Bind / BindBlock ports
       complete binder descriptors + certified descriptor-preserving Aut(beta)
       typed action, support, deterministic structural keys
       visible-only TypedENode.flatConstruct
  -> [implemented] CanonicalShape + ShapeWitness
       TypedEClassRecord + certificate-bearing TypedSymmetryGroup
       TypedRenamedUnionFind + certificate-preserving find
       TypedSlottedPortEGraph(U, M, H, status)
  -> [implemented Phase DA] leaderKernelTrace_G
       exact K_G(n) + iota_n + structural xi_n
  -> [implemented Phase E] leader-first canon_G
       quotient-first exhaustive reference + streaming production
       indexed structural / graph-relative alpha
       effective kernel + least shape + sigma/iota/omega/xi
  -> [implemented Phase F] sealed typed certificate algebra
       certified laws/groups + unionCertified + addSymmetryCertified
  -> [implemented Phase G]
       certified fixed-batch record admission + exact EC map
       reverse parent index + deduplicated dirty records
       atomic restrictInterfaceCertified transport
       generated rebuild/collision certificates + certified union
       uncapped rewrite-disabled rebuild to quiescence
  -> [implemented repaired-PF3 boundary]
       coherent EC/PC/SC w + replay(xi,w) -> exact d_n^w
       complete certified result + graph-owned insertNode
  -> [implemented Phase H]
       indexed complete finite trees + certified reachability
       bounded normalization/finite-model conformance oracle
```

The exact path exposes no public raw link or record-registration API. Phase D's
package-private setup transitions exist only to test the state algebra
independently of later gates; Phase G's public admission method requires a
complete certified fixed-batch record. The public graph defaults to strict
certificate mode; `ParentPath` retains primitive certified steps across
compression and reconstructs their transported transitive proof for the caller
context.

The exact graph exposes stable identifiers `typed-slotted-port-egraph`,
`leader-kernel-trace-v1`, `canon-g-production-v2`, and
`typed-certificate-algebra-v3`; Phase G additionally reports
`typed-fixed-batch-rebuild-v1`, and Phase H reports
`typed-finite-unfolding-oracle-v2`. Its public
`extractLeaderKernel` method is the Phase DA structural boundary; its public
`canonicalize` method is the isolated structural Phase E boundary;
`canonicalizeCertified` is the coherent witness-dependent wrapper; and
`insertNode` is the certified source/rewrite mutation boundary. The read-only
`finiteUnfoldingOracle` requires a current coherent prefix. Phase I imports
these through `TheoryAlloyAdapter` and `CanonicalAlloyPipeline`; no experiment
client receives direct access to graph mutation.

LNCS-3 resolves the former quotient-order defect: Figure 4 now minimizes each
invocation and binder-block orbit before Bag aggregation or Set deduplication.
It simultaneously regresses the provenance boundary by constructing `d_n`
without coherent `w` and returning neither `K_G(n)` nor `xi_n`, contrary to the
main Section 3.6 result and Theorem 1. The implementation follows the coherent
main-text structural result and does not counterfeit a witness-indexed
certificate. The repaired Figure 4 contract in `appendixC_v5.tex` separates
`leaderKernelTrace_G` from `replayKernelCertificate_{G,w}` and returns all
structural fields. The implementation now follows that split. The earlier
LNCS-3 contradiction remains recorded historically in
`theory-pre-phase-f-audit-lncs3.md`.

The mutation surface should be limited to these graph-owned operations:

| Operation | Accepted evidence | Postcondition |
| -- | -- | -- |
| `insertNode` (implemented, adapter-gated) | Well-typed exact-support node plus current `CoherentWitnessFamily` | Replays `xi` to `d_n^w`, exposes `Delta_n`, stores the exact EC and complete source record, returns a certified leader invocation, and routes collisions through both source proofs |
| `admitFixedBatchRecordCertified` (implemented) | Already-flat canonical records plus one exact EC per shape | Bottom-up finite batch is published without claiming source `d_n^w` insertion |
| `unionCertified` (implemented) | `ParentEdgeCertificate` rooted in typed input/rewrite equality or forward congruence | Distinct leaders joined by a certified parent edge; same leader does not alter symmetry |
| `addSymmetryCertified` (implemented) | Symmetry certificate with endpoint equation and induced typed permutation | Verified generator added to `G_a` |
| `verifyInterfaceRestriction` (implemented, read-only) | Independence/factorization certificate | Exact proper subcontext, factorization, and shape-witness transport are accepted without partial mutation |
| `restrictInterfaceCertified` (implemented) | Verified restriction certificate | Shapes/ECs, UF parent proofs, symmetry stabilizer, metadata history, and dirty parents are transported atomically |
| `findWithProvenance` (implemented) | Current or certified historical typed invocation | Normalized invocation, leader invocation, embedding, and replayable restriction/parent certificate path |
| `finiteUnfoldingOracle` (implemented, read-only) | Current `CoherentWitnessFamily` plus positive depth/count bounds | Enumerates complete indexed trees, retains EC/witness traces, and validates only theorem-reachable invocations through an independent observer |
| `rebuild` (implemented) | Dirty fixed-batch graph | Deduplicated worklist exhausted, collisions certified, and exact `H` restored; no rewrite insertion or pass cap |
| `checkInvariants` | Any state, with quiescence-aware checks | Exact diagnostic or success; no mutation except an explicitly selected rebuild |

Internal parent edges, class interfaces, stored shapes, symmetry groups, and
hash-cons ownership must be immutable outside that boundary.

## Dependency Map

| Phase | Depends on | Enables | Matrix families |
| -- | -- | -- | -- |
| B: foundational algebra (complete) | Phase A audit | Typed invocation and support | `TY`, `EMB`, `INV`, `SUP` |
| C: ports and signatures (structural gate complete under LNCS-3) | Phase B | Indexed `K+`/`K0`, first-class `BindBlock`, flat typed construction, and total keys | `PORT`, `SIG`, structural portions of `LAW`, `FLAT`, `ORD`, `BIND` |
| D: state and renamed union-find (complete) | B-C | Direct `G=(U,M,H)` representation and provenance-retaining typed find | `STATE`, `UF`, `HC` |
| E: canonicalization (structural gate complete) | B-D plus revised C | Quotient-first effective-kernel reference/production canonicalization, exact indexed alpha, and trace-bearing result | `ALPHA`, `GEQ`, `CAN`, `SYM`, `BIND` |
| F: certificates (admission gate complete) | Revised C-E | Typed proof algebra, certified law/group admission, union, symmetry, restriction-factorization checking, and proof-preserving find | `CERT`, `UNION`, `REST`, `CONG` |
| G: rebuilding plus repaired-PF3 source boundary | D-F plus repaired Figure 4 | Quiescent certified hash-cons, restriction transport, coherent replay, source insertion, and invariant checking | `REB`, `CHK`, `REST`, `CERT`, `MUT`, `T1` |
| H: finite unfolding | F-G | Executable theorem conformance | `FIN`, `TEST` |
| I: Alloy/evaluation integration | B-H | Separate Certificate-Integrated IR experiment arm | `INT`, `RW` |

No later phase can safely compensate for an unresolved foundational embedding
or context invariant: types and map direction must be fixed before graph-state
or certificate work begins. Phase F implementation evidence and the
source-replay no-go boundary are in
[`theory-phase-f-certificates.md`](theory-phase-f-certificates.md). Phase G
algorithms, corrected faults, and gate evidence are in
[`theory-phase-g-rebuild.md`](theory-phase-g-rebuild.md). The post-repair
replay/insertion work is recorded in
[`theory-pre-phase-h-unblocked.md`](theory-pre-phase-h-unblocked.md).
