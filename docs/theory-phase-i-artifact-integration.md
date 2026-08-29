# Phase I Artifact Integration

> **Publication superseding note (2026-08-29):** Dirty-worktree and earlier
> run identities below are retained as historical phase provenance. The current
> authoritative empirical snapshot is clean publication run
> `df4d8d4c-6265-4fe7-88d5-3aceee60398b` from source commit `fbd9b149`, verified
> by `scripts/verify_imported_publication_snapshot.sh`.

## Scope

Phase I connects the Alloy experiment layer to the Certificate-Integrated IR
built in Phases B-H. The integration is additive: the Fast Rewrite IR
normalizer and bounded rewrite saturation, together with all comparison
engines, remain available under explicit names. The
primary `canonical` measurements in `CanonicalBatchTest` and
`Alloy4FunAugmenter` now come from `CanonicalAlloyPipeline`; Fast Rewrite
counterparts are emitted under the historical compatibility name
`legacyCanonical*`.

The exact execution path is:

```text
Alloy parser -> MASGVisitor -> IRAgent temporal phases
  -> NormalForm phase-local normalization
  -> TheoryAlloyAdapter
       typed slots and complete binder descriptors
       certified Seq=A, Bag=AC, Set=ACI declarations
       graph-owned insertNode and fixed-batch rebuild
       strict checkInvariants after every transition
  -> current CoherentWitnessFamily
  -> bounded complete finite unfoldings
  -> CertifiedSemanticArtifact
       -> CanonicalObservation equality / digest / serialization
       -> RepairProjection -> QuotientRepairDistance
```

`CanonicalAlloyPipeline` is the experiment-facing facade. Exact equality and
SHA-256 digests use the complete normalized finite-term key. Repair distance is
a separate immutable view of the repaired `NormalForm`. It preserves the
established `CanonicalDistance` decomposition and edit units while obtaining
scope and container admissibility from the certified binder/signature
structure. `CanonicalRepresentativeTreeDistance` retains the former TED only
as a diagnostic baseline; canonical representatives are not assumed to be
isometric.

## Integrated Clients

| Client | Phase I behavior | Compatibility behavior |
| --- | --- | --- |
| `CanonicalBatchTest` | Certified repair distance, size, digest, graph counts, and phase timings are primary | The directly executed reference implementation, its size, and diagnostic edits remain separate JSON/Markdown differential fields |
| `Alloy4FunAugmenter` | Correct-pool equivalence and nearest canonical ranking use the exact prepared form | Fast Rewrite IR ranking and ratios are emitted in the same pass; `--skip-rewards` avoids Rewarder work |
| `EGraphAblationSuite` | Adds `typed-slotted-port-egraph` as a seventh arm | The six historical arms retain their implementations and identifiers |
| `CapabilityBenchmark` | Runs the exact seventh arm through all generated families and composed cases | Historical arm columns remain available for transition analysis |
| `AblationRunManifest` | Schema v3 records and checks the complete Phase I engine configuration | Report-only mode rejects incompatible or modified arm outputs |

The exact arm is selected directly with
`--engine typed-slotted-port-egraph`; aliases `exact`, `theory`, and
`typed-slotted-port` are accepted for interactive use.

## Preserved Invariants

| Boundary | Executable invariant |
| --- | --- |
| Temporal normalization | Every listed phase is reachable exactly once; binary temporal halves are paired; binders never cross a phase boundary |
| Variable identity | Source names are lookup aids only; typed bound coordinates and complete descriptors determine alpha-equivalence |
| Scoped prenex slots | Compatible sibling `ALL`/conjunction and `SOME`/disjunction scopes reuse ordinal lanes, so the prefix contains the maximum simultaneously live arity; nested scopes and quantifier/connective barriers consume distinct lanes |
| Binder permutation | A generator is issued only within one normalized exchange class and for equal type, domain, quantifier, cardinality, and disjointness payloads; `BinderBlockDescriptor.certified` verifies every field |
| Flexible arity | `SEQ`, `BAG`, and `SET` become certified A, AC, and ACI ports respectively; Bag multiplicity and Seq order are preserved |
| Construction | Every exact node is narrowed to exact support and enters through `TypedSlottedPortEGraph.insertNode` |
| Equality provenance | Exact unions, symmetries, restrictions, collisions, and rebuild steps remain certificate-bearing; preprocessing never calls an uncertified exact mutation |
| Administrative state | Reads occur only at quiescence; rebuild has no rewrite-round cap and strict invariants run after every adapter transition |
| Observation | The finite-unfolding family must be current and complete within its explicit bound; no cutoff leaf is invented |
| Equality versus distance | Full finite-term keys define equality; the established repair metric is evaluated directly over certified admissible alignments, and canonical representative TED is diagnostic only |
| Metric zero kernel | Certified canonical equality is exactly the public zero-distance kernel; disagreement in either direction fails closed |
| Dataset selection | Existing early raw-AST identity exclusion and problem/status grouping are unchanged |
| Reproducibility | Combined reporting checks run context and every generated hash before regenerating reports |

## Located Faults And Corrections

| ID | Located fault or contradiction | Correction |
| --- | --- | --- |
| I-F01 | A source node could expose an ambient context larger than its structural support, violating fresh-class interface `Delta_n` | Narrow every source node with `inExactSupportContext()` before certified insertion, then widen only the returned invocation |
| I-F02 | Readable aliases for a shadowing binder could leave an outer binding in the lookup map | Inner aliases now replace lookup entries; identity remains the distinct typed bound coordinate, not the readable name |
| I-F03 | The outer predicate declaration name leaked into the canonical term, making identical bodies under different predicate names unequal | Strip only the outer `PREDICATE`/`CALL` declaration wrapper; nested semantic calls remain explicit |
| I-F04 | Finite-term observation restored source witness order but did not quotient binder-block bodies by certified `Aut(beta)` | Minimize each restored binder-block body over its certified automorphism group before constructing the normalized key |
| I-F05 | Every finite-unfolding candidate eagerly built global index traces and proof-heavy structural keys, making corpus adaptation disproportionately slow | Keep proof accessors exact but materialize traces lazily; enumeration uses a separate lightweight complete-tree key |
| I-F06 | A direct tree metric counted certificate and schema implementation nodes as user-visible repairs; the first semantic-key projection reduced labels but still used canonical-representative TED | Retain that projection only inside the named TED baseline; the primary `RepairProjection` re-expresses the repaired normal-form metric domain and attaches certified legality metadata |
| I-F07 | Recursive distance repeatedly hashed complete structural trees and revisited identical subproblems | Cache structural hashes and subtree sizes, use identity fast paths, and memoize prepared-pair comparisons |
| I-F08 | The experiment harness had no exact arm and manifests could not identify certificate/invariant modes | Add the seventh arm; the current three-layer schema is `candis-ablation-manifest-v3` / `candis-ablation-output-v5` and records the quotient metric plus representative-TED versions |
| I-F09 | Batch and augmentation smoke runs were coupled to Rewarder and its instance pools | Add `--skip-rewards`; structural outputs remain complete and rewarded reruns stay available |
| I-F10 | Fast Rewrite diagnostic edit paths could be mistaken for the certificate-integrated distance | Preserve the historical API names `legacyDiagnostic*` / `legacyCanonical*`, but identify both active engines explicitly in generated metadata and documentation |
| I-F11 | Augmentation ranking and correct-pool worker exceptions were swallowed, allowing partial structural reports to look complete | Structural worker interruption or failure now aborts report publication with the original cause; Rewarder failures remain explicit per-record observations |
| I-F12 | The adapter erased every non-integer primitive carrier to `AlloyRel`, so `canon_G` treated unrelated `User`, `Photo`, and `Ad` slots as one renaming color and explored a factorial global orbit | Preserve normalized primitive carriers as graph slot types; add relational coercions only where a flexible relational container requires homogeneous element ports; bump adapter/signature versions to v2 |
| I-F13 | `CanonicalBatchTest` queued the entire corpus, retained every formula/edit trace until completion, emitted no progress, and retried all failures serially | Use a bounded completion window, parallel per-task retry, deterministic ordered streaming to JSON, and periodic throughput/ETA reporting |
| I-F14 | Flat prenexing summed variables from independent sibling scopes. The blocking `socialMedia/.../3GorLbiT9rBjLk8cf_inv7.als` therefore exposed eight interchangeable `User` coordinates and eagerly constructed an erroneous `S_8` orbit | Allocate typed prenex coordinates by lexical liveness: reusable sibling scopes share ordinal prefixes, while direct nesting advances the prefix. The file now has three `User` coordinates (the maximum of 3, 1, 2, 1, 1) and one `Influencer` coordinate |
| I-F15 | An unrestricted scope quotient would identify the outer and inner universals in `(all x.P) and (some y. all z.R)`, changing quantifier dependency; traversing the declaration type `one S` also looked like a matrix barrier | Close reuse at every incompatible connective or different quantifier, and normalize declaration domains in an isolated scope-neutral allocator view. A mixed `ALL/SOME/ALL` adversary now retains two universal coordinates |
| I-F16 | Coalescing branch-local variables retained only the first source name, so a temporal child from a later branch could lose its inherited-binding lookup | Each `QuantiVar` retains all source aliases; temporal inheritance, exact adaptation, and backtranslation register every alias while keeping one alpha/de Bruijn identity |
| I-F17 | `BinderAutomorphismGroup` repeated full source/codomain/type trees in every closure key and eagerly materialized a proof DAG for every group element | Store closure membership by compact ordinal permutation actions, validate immutable generator certificates once, and reconstruct only the requested closure proof by a deterministic predecessor search |
| I-F18 | Phase I used ordinary TED between independently canonicalized finite-term representatives as though canonicalization were an isometry | Split `CanonicalObservation` from `QuotientRepairDistance`; retain representative TED under an explicit diagnostic name and remove it from the primary metric path |
| I-F19 | Proof/schema wrappers, one-port carriers, binder implementation nodes, and ambient bookkeeping inflated repair sizes and made one source edit cost many tree edits | Keep those structures in Layer 1 but project the original source repair units: phases, quantifier tuples, matrix operators, and operands |
| I-F20 | Independent binder alpha minimization and independently sorted ACI operands produced discontinuous positional alignments | Port the Fast Rewrite pairwise alpha minimization and Hungarian ACI assignment onto certified scope blocks; retain ordered sequence DP and one-unit declaration changes |
| I-F21 | The initial three-layer implementation treated the Fast Rewrite distance as a heuristic baseline and introduced a generic semantic-tree metric whose 100-pair mean was 16.870 instead of the normative 15.000 | Make `CanonicalDistance` the Layer-3 specification and port every recurrence/edit unit explicitly; the final 100-pair differential is 100/100 equal |
| I-F22 | Comparing raw exchange-class integers across two formulas rejected a legal class alignment after an inserted quantifier run (`1` versus `0`) | Enumerate order-preserving pairwise matchings of certified scope blocks; class identifiers remain local to each descriptor |
| I-F23 | Unequal-arity alpha recursion committed the first compatible variable and depended on hash-map tie order | Compute maximum matching cardinality first, then minimize over every maximum partial mapping; apply the same correction to `CanonicalDistance` and the certificate-integrated port |
| I-F24 | The repair projection inferred a full declaration-class permutation from an exchange label and per-coordinate orbit without proving that the certified group generated the complete Fast Rewrite alignment space | Before exposing that space, require certified adjacent transpositions for each equal-payload declaration class; a narrower future group now fails closed rather than admitting uncertified mappings |
| I-F25 | A full 66,080-file batch reported 737 missing-law failures: 732 `GENERICRELDECL` Bags, four empty `AND` Sets, and one normalized-away `OR` Set. `RepairProjection` had reconstructed its law registry only from selected finite unfoldings, so source operators consumed into binder blocks or erased by normalization were absent | Record every flexible source operator's signature-certified A/AC/ACI declaration before construction, carry the immutable registry in `CertifiedSemanticArtifact`, and require that registry during repair projection. Zero-operand operators are certified even when no flat occurrence is emitted |
| I-F26 | The same run reported 47 zero-kernel failures. Independent heterogeneous binders retained source coordinate order, and guarded binders used an order-sensitive syntactic approximation (`Protected` versus `Trash`) instead of Alloy's annotated least-parent primitive type | Canonically order independent phase coordinates within preserved exchange classes, retain an explicit source-index-to-coordinate permutation for readable repair tuples, and obtain each primitive type from Alloy's annotation. Complex guards remain only in the ACI-normalized matrix |
| I-F27 | Once I-F25 was removed, `{x:S, y:S | P}` versus `{x,y:S | P}` exposed a certified-equality/nonzero-distance contradiction. The certificate-integrated local `BinderBlockDescriptor` erases declaration grouping, while Fast Rewrite matrix syntax charged five edits for that presentation difference | Treat this as a demonstrated Fast Rewrite admissible-space ambiguity: merge only adjacent, non-disjoint local declarations with identical projected domains, and only when that exact source binder has a certified local descriptor. Disjointness classes and dependency order remain barriers. This is an intentional semantic correction, not an approximate metric change |
| I-F28 | The adapter used `carrierTypeName` as the slot's alpha color, while an earlier unsafe prenex path could assign synthetic `univ`; at corpus progress 16,668 this collapsed ten primitive colors and attempted an artificial `10!` orbit | Preserve `typeName` and `carrierTypeName` as the Alloy-annotated least-parent primitive type. Complex declaration domains remain explicit matrix guards, and a quantifier stays local whenever moving it would require an unavailable carrier-inhabitation proof. The dead synthetic-`univ` producer path has been removed |
| I-F29 | Finite-term binder minimization acted on a body whose Bag/Set operands had already been normalized, but did not normalize those containers again after permuting their bound-coordinate markers. Nested and grouped subtype binders could therefore have repair distance zero but different canonical keys | Every binder-automorphism candidate now re-sorts Bag operands and re-sorts plus deduplicates Set operands after the coordinate action. The strict zero kernel remains enabled, and the nested/grouped `Entry`/`Exit` regression has one byte-identical canonical observation |
| I-F30 | The next full run had one remaining zero-kernel failure: `trash_ltl/correct/WCmW6XqHcDpTMcHzX_inv16.als`. Implication elimination plus primitive-domain guarding produced the same `NOT_IN(f, Protected)` operand twice under an ACI `OR`. One copy retained the parser-only source label `BOP_IN`, so frontend saturation failed to deduplicate it; Layer 1 ignored that nonsemantic label and correctly deduplicated the Set, while `RepairProjection` copied both occurrences and charged three matrix edits | Clear parser provenance whenever normalization changes an opcode, so the repaired NormalForm itself restores ACI idempotence; also project certified `SET` containers idempotently as a boundary invariant. This is a metric-port bug fix: Set idempotence was already part of the established quotient semantics. Bag multiplicity and Seq order are unchanged. Both the Fast Rewrite metric and certificate-integrated temporal/quantifier/matrix components are now zero |
| I-F31 | The I-F30 temporal fixture exposed a pre-existing backtranslation contradiction: matrix `REF` leaves such as `temporal[0:1]` were emitted literally as Alloy source and temporal children were appended conjunctively, losing the reference's Boolean position | Render direct temporal children first, bind each unary/binary child to its exact `temporal[index:arity]` key, and substitute each `REF` in place while retaining an explicit fallback only for manually assembled unreferenced children. Unresolved references fail closed. The connective-embedded temporal regression compiles, and bounded equivalence of both predicates in the I-F30 file has zero mismatches and failures |
| I-F32 | Corpus-scale augmentation, ablation, memory, capability, semantic-soundness, and backtranslation runners had inconsistent or absent progress output; several parallel collectors also waited in submission order, so one slow early task made productive runs appear stuck | Add one shared `ExperimentProgress` reporter with bounded checkpoints, throughput, ETA, and 30-second no-completion heartbeats. Parallel collectors consume completion order but restore results by source index, preserving deterministic artifacts. Runners that suppress noisy global output retain the original `stderr` for progress, and the process-isolated suite reports both arm completion and the currently running child log |
| I-F33 | `Alloy4FunAugmenter` retained each proof-heavy `CertifiedSemanticArtifact` after extracting its canonical observation and repair view. At parse completion 19,282 the live 8 GiB heap held 8,044,742 / 8,052,736 KiB, RSS was 8.9 GiB, and G1 workers had consumed most elapsed CPU; the nearby source files were not pathological. It also queued all 66,080 parse futures at once | Keep full `Prepared` values as the replayable default, but add an explicit comparison compaction that retains the certified observation, repair view, and scalar statistics while releasing construction-only graph witnesses. Augmentation caches use only this compact form. Simultaneous certificate-integrated construction is bounded by the configured heap and capped at 16, while parsing and distance work retain requested parallelism. Parsing keeps at most four tasks per worker in flight, and stall heartbeats identify the earliest unresolved source path |
| I-F34 | The strict correct-pool audit found a zero repair distance with unequal certified observations for `classroom_fol/inv11`; the then-current synthetic-`univ` operational carrier disagreed with the primitive comparison carrier | The current producer no longer fabricates an operational `univ` carrier. It moves a guarded quantifier only under a connective-specific rule with any required inhabited-carrier witness, keeps the primitive tuple type, and retains the subtype guard in the matrix; otherwise the quantifier remains local |
| I-F35 | The same audit exposed `classroom_fol/inv3`: `p != q` and `q != p` had repair distance zero under a certified binder swap, but the exact signature represented `NOT_EQUALS` with ordered child ports and therefore rejected its intrinsic commutativity | Represent fixed commutative `IFF`, `EQUALS`, and `NOT_EQUALS` operands through a certified ordinary `BagPort`. This certifies operand exchange without incorrectly flattening equality into an associative operator; relational equality operands are coerced before entering the homogeneous Bag |
| I-F36 | The final strict-kernel contradiction was `lts/inv7`. Local comprehension variables had no prenex binding index, so `RepairProjection` retained parser alpha labels such as `_q1` while the exact layer correctly used the local binder descriptor and its permutation group | Carry each local binder's source-name-to-certified-coordinate map out of `TheoryAlloyAdapter`. Project local variables to depth-qualified coordinates and minimize pairwise only over the descriptor's certified automorphism elements. Nested depths prevent capture, readable aliases remain presentation data, and no symmetry is inferred from type or names |
| I-F37 | The I-F36 round-trip fixture exposed a separate backtranslation failure: `COMPREHENSION` was rendered with the default existential keyword, so closure received a Boolean expression such as `^(some s1,s2: State | P)` | Render local comprehensions as Alloy set comprehensions `{s1,s2: State | P}`. The targeted six-file bounded check now compiles and proves all 12 backtranslated predicates with zero mismatches and zero failures |
| I-F38 | Incorrect-predicate ranking exposed a false certified equality in `coursesOld/inv13`: `ordering/first` and `ordering/last` differed by one repair edit, but every non-temporal `REF` leaf had the same exact operator head | Include the normalized source identity in every non-temporal `REF` signature head. Temporal normal-form references are resolved before node construction and remain structural phase invocations. The concrete pair now has unequal observations and exactly one matrix edit |
| I-F39 | `trash_ltl/inv8` exposed the opposite failure. The repaired formula compared `eventually f2 in Trash` with `eventually f1 in Trash`; phase-local minimization chose identity for the implication phase and a swap for its temporal child, although both phases refer to one owning binder. This was a Fast Rewrite admissible-space ambiguity proved too broad by the certificate-integrated owner coordinates | Perform one exact maximum-cardinality alpha minimization over owner-coordinate identities across all aligned temporal phases, then reuse that mapping at every inherited occurrence. A declaration-modification fallback aligns only the same owner coordinate and cannot reuse a certified target, preserving the established one-unit quantifier edit. Consistently permuted temporal formulas remain distance zero; inconsistent targets cost one |
| I-F40 | Adding the exact arm to semantic-soundness probes exposed an invalid local automorphism: every local binder coordinate used exchange class 0, so `{x,y:S | y in x.r}` could be identified with `{x,y:S | x in y.r}` even though comprehension coordinates are ordered result columns | Assign each comprehension coordinate its positional exchange class. Alpha-renaming still acts positionwise, while formula and summation binders retain their certified exchange groups. The repaired 185-check pipeline suite distinguishes the pair, and the refreshed bounded run checks 2,320 current union claims with 0 counterexamples, 0 errors, and all four negative probes rejected by all seven arms |
| I-F41 | The refreshed correct pool exposed 14 strict-kernel contradictions, all on predicates labeled `CORRECT`: stale lexical paths blocked certified prenex alignment for `LONE`, while Boolean neutral-element reduction happened after the certified snapshot. Adversarial rounds then found name-only Boolean literals, missing container/arena/operand/opcode guards, implicit path-erasure authority, incomplete orbit ledgers, descendant-CALL admission bypasses through both Boolean absorption and temporal dualization, omitted alternatives in reachable union components, generic `Bool` metadata acting as operator provenance, caller-supplied raw observation authority, malformed binding indices, and under-scoped formal exchange maps | Compare prenexed bindings through certified owner/exchange/dependency/orbit payloads only when both sides carry explicit prenex path-erasure authority; otherwise retain source-path equality. Require complete owner-scoped orbit partitions and preserve same-orbit relations under zero-cost alpha mappings; scope injective, monotone exchange maps by role and temporal owner; apply Boolean laws before cloning the certificate-facing matrix; require concordant literal/container/formula-opcode/operand type plus arena/profile evidence; traverse every alternative in every reachable union component and every temporal phase before rewriting; distinguish parser-concordant or internally derived operator authority from generic Boolean typing; and accept public kernel checks only for sealed certified projections. Exact witnesses, forged-type/provenance regressions, owner/orbit Lean obligations, a 2,266-check bounded alpha differential, and a fresh 11-file reproduction complete with zero violations; `CORRECT` remains metadata rather than proof authority, unbounded candidate refinement stays open, and a full-corpus rerun remains required |
| I-F42 | The post-lowering arena cleanup treated every registered e-class as reachable. A disconnected registered union component therefore remained strongly referenced even when no retained NormalForm root could reach it. | Compute the retained closure from roots through child edges and only the union components reached by that traversal, then remove every other registered class. The deterministic regression removes exactly two disconnected classes, preserves a reachable union peer, and reports zero removals on a second cleanup; the finite Lean model distinguishes registration from child/union reachability. |
| I-F43 | Live temporal evidence required its source and exact edge occurrence to remain in the Multigraph, but did not require each downlink target to remain a graph vertex. Removing only a child vertex therefore left the occurrence admissible. | Require exact target-vertex membership for every recorded downlink until the owner-bound claim is sealed. Child-only removal now rejects at NormalForm admission and direct adaptation, restoring the child restores admission, and the finite Lean model records child-target liveness independently. |
| I-F44 | A retained root-to-temporal-source edge could keep path continuity valid after the non-temporal captured graph root itself was removed from the vertex set. | Require exact captured-root membership in addition to stable graph-root identity until sealing. A nested temporal fixture rejects root-only removal at both public boundaries and admits again after exact restoration; Lean tracks graph-root liveness independently. |
| I-F45 | Recursive saturation checked arena mutability only for its entry root. A second unfrozen parent could therefore rewrite a shared descendant already frozen through a certified parent, and detection of a later frozen sibling could follow a partial rewrite of an earlier mutable sibling. | Under the arena monitor, preflight mutability over the complete reachable child/union closure before the first rewrite and recheck each recursively visited node. A direct shared-child fixture requires both frozen and mutable descendants to remain unchanged after rejection; Lean models all-reachable admission and no partial result on failed preflight. |
| I-F46 | Temporal-reference completeness compared observed references only with issued authorities. A temporal child attached without any authority made both sets empty and crossed admission/freezing unreferenced. | Partition every temporal child index by exactly one in-bounds, identity-exact, nonoverlapping owner-issued authority range, require a matrix and authority ledger whenever children exist, and retain per-matrix authority coverage. Direct admission/freeze regressions and Lean missing/exact/overlap cases pin the boundary. |
| I-F47 | Nodes synthesized while rewriting an existing graph selected the executing thread's `CURRENT_ARENA`; cross-thread saturation therefore created foreign-arena children. Snapshot construction also transiently consulted that unrelated arena. | Make node arena ownership final. Public graph construction may select the thread-local builder, but derived rewrite and snapshot nodes explicitly inherit the existing source graph arena. Cross-thread IMPLIES saturation now completes, and Lean distinguishes source-arena inheritance from executing-thread selection. |
| I-F48 | Rejected fixed-arity child mutations changed the child list before reporting the arity failure, and invalid CALL metadata could revoke provenance before rejecting. | Precompute compatible child invocations and validate prospective arity and metadata before the commit point. Replacement, append, invocation append, occurrence-id, and declared-arity regressions now require byte-for-byte semantic state preservation on rejection; Lean models the transaction boundary. |
| I-F49 | Retained-arena cleanup interpreted an empty root list as a no-op and left both registered classes and union-find bookkeeping live. | Treat no roots as the empty reachability closure and prune both storage layers under the arena monitor. The two-class union regression removes two classes and is stable on repetition; Lean retains no class whose child/union reachability flags are both false. |
| I-F50 | Pruning erased registered storage but did not retire escaped e-class handles, allowing a later canonical lookup to dereference an erased union leader. | Give every pruned class a permanent retired lifecycle state and reject its reuse at invocation, canonicalization, union, traversal, admission, and mutation boundaries. The stale two-class handle now fails deliberately rather than re-registering or producing null. |
| I-F51 | NormalForm-generated copies selected the executing thread's arena, and temporal dualization changed the temporal operation before matrix construction had succeeded. | Construct every clone and synthetic node in its source arena. Stage temporal child operations and matrices together with both rewritten parent matrices, saturate the staged parent, and commit only after all fallible work succeeds. The parser-backed cross-thread fixture preserves a coherent temporal phase. |
| I-F52 | The central admitted-graph traversal did not consult the retired lifecycle flag and could admit a pruned root using its residual node list. | Require liveness before every admission visit and union-component expansion. The stale handle now rejects at the public admission boundary before any semantic occurrence is consumed. |
| I-F53 | A retired class tombstone still strongly held nodes, child references, shapes, symmetries, and slots. | Clear every semantic/cache payload during retirement, retaining only the class identity and retired flag needed for deterministic rejection. The bounded formal model records zero retained payload without making GC-scheduling claims. |
| I-F54 | Temporal rewrite staging and certification freeze used distinct NormalForm monitors, so a child could freeze after its mutability check but before staged operation/matrix publication. | Share one lifecycle monitor across the complete temporal tree and use it for construction, normalization, rewrite, admission, and recursive freeze. Derived e-node creation checks owner mutability under the arena monitor. A parser-backed two-thread regression admits only the two serialized outcomes, and the Lean model records the same finite outcome set. |
| I-F55 | Reachability cleanup distinguished an empty root list from a nonempty list whose entries were all null, retaining the whole current arena in the latter case. | Apply empty-closure cleanup after filtering null roots as well as before iteration. The direct union-component fixture and finite Lean root model both require zero retained roots. |
| I-F56 | A certified ACI identity could be visible to Layer 1 and the post-snapshot repair projection but unavailable to an earlier enclosing source rule. The valid pair `some (S + S) or not (some S)` and `no none` therefore reached the public kernel with zero repair distance and unequal producer observations; a Boolean ACI singleton over bound slots exposed the same transition mismatch. | Give complement and self-difference a read-only view of the exact typed/profile-indexed ACI quotient before the snapshot. Same-operator flat operands compose slot maps, only Set quotients deduplicate, and a quotient singleton is exposed before duality; distinct operators remain barriers. Parser-backed A/C/I, bound-slot, self-difference, and near-miss regressions pass, while standalone Lean proves the underlying relation ACI and equality-transport obligations. |
| I-F57 | An initial diagnostic inferred arithmetic from exact `INT` result carrier. | Superseded by I-F62 after direct Alloy execution established that parser `PLUS`/`MINUS` retain relational set semantics over `Int`. |
| I-F58 | Rewinding a shared binary-symbol visit after nested same-operator traversal erased the distinction between source occurrences and could publish an empty operator. | Retain each nested occurrence's monotone visit while connecting the parent through its separately saved visit. |
| I-F59 | Dual complement comparison was positional even for certified commutative equality operators. | Compare certified composed child multisets only under the declared C quotient; keep ordered duals ordered. |
| I-F60 | A parser-authenticated nested relational union could not flatten when its inferred intermediate result was a strict subfamily of the outer result carrier. | Admit only same-module, same-arity `PLUS` subfamily widening and represent each leaf-to-outer conversion explicitly. |
| I-F61 | Nested ITE traversal rewound the shared symbol's occurrence counter and could publish a valid source ITE with zero children at the advertised visit. | Preserve monotonically allocated child occurrence visits and connect the ternary parent through its separately saved visit. Parser-backed formula and expression nesting now pass fixed-arity admission. |
| I-F62 | The adapter candidate relabeled valid relational `PLUS`/`MINUS` whenever their exact carrier was `INT`. | Preserve parser operator identity and let the certified container schema distinguish the unary-Int relation Set from integer arithmetic. Direct solver, parser, producer-equality, and repair-kernel checks cover the supported transition. |
| I-F63 | Structurally equal integer literal nodes shared IRAgent's visit count, disconnecting the second literal from its exact parser type. | Use identity-keyed occurrence accounting during MASG-to-IR lowering. Repeated/nested arithmetic, cardinality, subtraction, and negative literals now reach the certificate-integrated representation. |
| I-F64 | Alloy's `Type.is_int()` reported Int participation for `Int + S`, and the adapter-facing exact type erased the heterogeneous signature alternative before certification. | Require the full parser product family to be exactly unary built-in Int before assigning `GraphType.INT`; preserve mixed Int/signature alternatives as a correlated relation family. |
| I-F65 | Literal alternative containment made relational PLUS associativity depend on grouping when a nested exact type used a subtype and the outer result used its parent. | Consume same-module parser ancestry per correlated product column when proving nested-family inclusion; keep reverse, sibling, arity, module, and operator barriers explicit. |
| I-F66 | Set identities involving authenticated `univ` and relational difference were applied only after the certificate-facing source snapshot, allowing producer equality to disagree with the repair quotient. | Close the five exact identities in the guarded pre-snapshot pass and retain the same reductions in saturation. Built-in recognition remains authority-gated, and direct Alloy, parser-backed pipeline, and Lean evidence cover the supported transition. |
| I-F67 | The certificate-facing source pass retained a relational subfamily even when its union contained the actual full parent signature, and its first contextual repair could fail to publish a same-arity child replacement. | Authenticate the full signature leaf by parser identity, exact unary family, and same-module ancestry; eliminate every proved subrelation through the surrounding relational-PLUS association and compare child identities rather than only list lengths when committing the rewrite. Keep merely parent-typed expressions and unrelated families outside the carrier authority. |
| I-F68 | A named subset carrier was indistinguishable from its primitive parent in exact Alloy `Type`, so declaration-chain absorption stopped one level too early. | Preserve runtime parser declaration authority on actual signature leaves and use the same-module signature DAG for named-carrier containment; keep primitive exact-family fallback narrowly scoped. |
| I-F69 | The certified source pass omitted the same-arity law `none in R` and its `not in` dual. | Gate the rule by authenticated empty-set identity and exact relation-arity equality, and mirror it in saturation. |
| I-F70 | Plain relation product/composition did not propagate an authenticated empty operand before certification. | Derive exact-result-arity `none` for relation-valued `ARROW`/`JOIN` annihilation, with direct Alloy, producer, and Lean coverage. |
| I-F71 | Alloy's convenience descendant query over-approximated containment for a subset declaration with multiple union parents. | Use an explicit all-parent declaration-DAG proof; a common ancestor is admissible, but no individual union branch receives carrier authority. |
| I-F72 | The source adapter preserved abstract declaration metadata in the parser but did not consume Alloy's generated cover fact, leaving a semantically equal complete child union outside the quotient. | Derive abstract covers only from live same-module direct `extends` declarations, recurse across abstract child covers, require complete branch coverage and operand containment, and normalize singleton abstract chains to one deterministic highest carrier. |
| I-F73 | The integrated source pass had no authority-bearing representation of Alloy `iden`, so valid JOIN identity pairs remained outside the certified quotient. | Add parser-only identity authority, preserve it through trusted exact cloning, and apply two-sided identity elimination before the certificate snapshot with a mirrored saturation rule. |
| I-F74 | Certified observations retained redundant transpose layers and unreversed ARROW products. | Admit exact-binary transpose involution and binary-product reversal before snapshot creation; preserve order for every unsupported operator shape. |
| I-F75 | Certified observations retained redundant nested CLOSURE/RCLOSURE combinations. | Normalize the four exact-binary closure fixed points before the snapshot and mirror them in saturation, while preserving the semantic distinction between transitive and reflexive-transitive closure. |
| I-F76 | Enum coverage was not an explicit integration obligation. | Add parser, solver, certified-equality, zero-distance, and Lean coverage for a complete enum atom family. |
| I-F77 | Abstract-cover candidate derivation and final operand admission were tested separately but lacked one end-to-end case showing that an unrelated terminal blocks the proposed carrier. | Preserve the existing all-terminal containment gate and pin it with parser-backed positive-distance, direct Alloy SAT, and standalone outside-witness proof evidence. |
| I-F78 | The integrated source pass could reconstruct an abstract unary carrier but could not lift that proof through a Cartesian product, despite preserving the required dependent factor evidence. | Add a one-coordinate full-cover product rewrite with parser-derived Cartesian exact type; retain slot, diagonal-grid, unrelated-alternative, operator, and module barriers. |
| I-F79 | The integrated unary relation pass omitted the identity fixed points for transpose, transitive closure, and reflexive-transitive closure. | Adopt only an authenticated `iden` child with the same exact occurrence type, before the certificate snapshot and in mirrored saturation. |
| I-F80 | The integrated abstract-product rule was binary-only even though certified ARROW observations use ordered variadic dependent chains, and it could not close complete Cartesian grids spanning multiple cover coordinates. | Analyze a plain binary source tree as a factor sequence without changing its committed syntax; perform parser-certified subgroup cover reductions to a fixed point; rebuild binary source nodes with independent exact product proofs. Require complete grids and retain partial/diagonal barriers. |
| I-F81 | Exact `Int` occurrences deliberately used a scalar kind to protect integer operator dispatch, but that representation also prevented valid relational-product proofs and caused a production exception. | Keep scalar dispatch unchanged while binding parser-origin Int to transient module authority; permit only that authority to reinterpret the occurrence as one unary set column inside Cartesian type derivation. |
| I-F82 | The integrated source quotient retained converse outside relational composition even though exact binary semantics require `~(r.s)=(~s).(~r)`. | Reverse the parser-authenticated ordered JOIN sequence and transpose every operand, deriving the exact result profile independently; keep wrong-order and synthetic-evidence cases outside the rule. |
| I-F83 | Domain/range restriction remained structural across sound coordinate homomorphisms, nested restrictions, opposite-side commutation, and complete union grids. The first generalized implementation also assigned inconsistent source identities to generated lattice nodes and failed to converge on a four-cell grid. | Normalize authenticated restriction coordinates before certification, factor only complete covers or one-coordinate differences, preserve correlated exact types and composed slots, and give generated relational operators canonical source identities. Retain diagonal and multi-coordinate barriers. |
| I-F84 | A first JOIN-chain union factorization could expose another sound factorization, but the guarded source pass cloned the certificate matrix before reaching that fixed point and valid middle/initial-coordinate inputs failed certificate transfer. | Recursively close parser-authenticated JOIN union factoring before the certificate snapshot. Preserve the ordered sequence, exact dependent boundaries, and slot maps; retain intersection and synthetic-evidence barriers. |
| I-F85 | Converse remained outside transitive/reflexive closure and domain/range restriction. | Commute converse through either exact closure without changing its kind, and swap authenticated DOMAIN/RANGE while transposing only the relation coordinate. Derive each result profile independently and retain authority and near-miss barriers. |
| I-F86 | Restriction retained a proved full endpoint carrier and failed to propagate an authenticated empty restrictor or relation coordinate. | Eliminate only built-in univ or a closed primitive carrier whose parser-derived restriction profile is exactly the relation profile; derive arity-preserving none from either authenticated empty coordinate. Keep variable and incomplete carriers explicit. |
| I-F87 | Typed empty binary relations remained structural under converse and closure. | Derive empty for TRANSPOSE/CLOSURE and authenticated iden for RCLOSURE, preserving exact result arity/profile and rejecting forged empty spellings. |
| I-F88 | Endpoint and internal restrictions remained structural across relational composition even though their guards constrain the same source, target, or shared existential JOIN coordinate. | Lift first/last endpoint guards outward and transfer an internal range guard to the adjacent domain under exact parser-derived JOIN/restriction types, ordered operands, and composed slot invocations. Keep wrong-side, wrong-guard, and synthetic evidence outside the rule. |
| I-F89 | The first contextual-restriction implementation confused a unary operand's only coordinate with a surviving output endpoint, although JOIN eliminates it as the shared existential boundary. | Gate endpoint lifting on underlying operand arity at least two. Preserve unary/internal guards at the boundary and orient them onto the right operand; prove and test both unary directions and their SAT-inequivalent endpoint-lift controls. |
| I-F90 | Direct unary domain and range restrictions remained separate structural operators even though a unary tuple has only one coordinate. | Under parser-authenticated exact arity one, orient RANGE to DOMAIN. Retain separate roles for higher arity and reject synthetic type-only authorization. |
| I-F91 | Reflexive relation subset/equality atoms and their explicit negations remained structural even when both operands denoted one certified ACI invocation. | Fold the four atoms only with parser-authenticated set-family evidence and equality in the certified operand quotient. Preserve distinct invocations and reject synthetic relation labels. |
| I-F92 | Structural relation containment and the exact subset/lattice adjunctions remained outside the integrated quotient, leaving elementary subset truths and conjunction expansions at positive distance. | Prove containment recursively through authenticated union, intersection, difference, and restriction; expand a union only on the subset's left and an intersection only on its right, with NOT_IN dualization. Preserve the two unsound opposite directions and synthetic evidence as barriers. |

## Performance Diagnosis

The August 17 investigation separated parsing, Fast Rewrite normalization, certificate-integrated
construction, finite unfolding, and distance measurement. Exact graph
construction dominated; tree distance itself was below one millisecond in the
pathological cases. Java Flight Recorder attributed the construction cost to
an allocation-heavy orbit search in `ProductionGraphCanonicalizer`, especially
`TypedRenamingEnumerator`, structural-key construction, and repeated immutable
symmetry-proof validation.

The concrete trigger was type erasure at the adapter boundary. A normalized
matrix with five `User`, two `Photo`, and two `Ad` coordinates was exposed as
nine `AlloyRel` coordinates, admitting up to `9!` typed renamings instead of
`5! * 2! * 2!`. Carrier-aware slots preserve exactly the intended typed
alpha-equivalence and remove those cross-carrier candidates. Symmetry and
binder proof checks are now memoized only after successful validation of the
same immutable group/interface pair; mutation boundaries still run their
strict graph invariants.

A second trigger appeared at corpus position 34,901. Five sibling universal
scopes with arities 3, 1, 2, 1, and 1 were flattened to eight `User`
coordinates. Scope-aware allocation now uses three shared `User` lanes; the
directly nested, differently typed `Influencer` remains a fourth coordinate.
The isolated file completes in 3.37 seconds with `-Xmx512m` instead of
exhausting the heap. This optimization is semantic scope coloring, not a cap:
a genuine eight-coordinate declaration still denotes the full `S_8` orbit and
remains intrinsically expensive.

A third trigger appeared in ordered progress near 16,668. The former
relativization path assigned synthetic `univ` to a guarded declaration and the
adapter reused that field as the alpha color, collapsing ten primitive colors
into one artificial `S_10` orbit. That carrier assignment is not sound without
an independently checked inhabitation premise and has been removed. Using the
Alloy-annotated primitive type as the slot color reduces the isolated predicate
to Course x2, Person x2, Grade x4, and Project x1, whose largest admissible
orbit is 96 rather than `10!`. The formerly blocking file now completes in
5.55 seconds. A 171-file window centered on the frontier completes 171/171 in
15.50 seconds with no failures.

Measured without Rewarder on the same machine and `-Xmx4g`:

| Workload | Before | After | Result |
| --- | ---: | ---: | --- |
| Pathological nine-binding predicate, exact preparation | 30.819 s | 2.993 s | 10.3x faster |
| Stratified corpus sample, 1,002 files / 926 eligible, 32 workers | 55.16 s | 32.73 s | 40.7% lower wall time |
| Same updated sample, 16 workers | - | 32.53 s | 2.72 GiB peak RSS and less CPU contention |
| Former 16,668 stall window, 171 files / 16 workers | did not pass the blocking item | 15.50 s | 171 successes, 0 failures; 3.19 GiB peak RSS |

Thirty-two workers remain supported and remain the CLI default. With a 4 GiB
heap, 16 workers were faster on the allocation-heavy exact arm and avoided the
4.06 GiB process RSS observed at 32 workers. Rewarder invokes SAT solving and
is a separate potentially dominant phase; use `--skip-rewards` for structural
reproduction, then run rewarded measurements deliberately.

The completed clean seven-arm natural-corpus run makes the remaining exact-engine
cost concrete. At 16 workers and `-Xmx8g`, the Fast Rewrite IR arm finished
61,598 eligible pairs in 23.860 seconds with 73.605 engine CPU seconds; the
exact arm required 2,775.650 seconds and 42,224.753 engine CPU seconds. Exact
per-pair latency was 324.876 ms at p50 and 2,414.924 ms at p95. Maximum RSS was
1,840.508 MiB for Fast Rewrite and 8,912.141 MiB for certificate-integrated execution, while the exact
observation remained slightly smaller: 29.541 average units versus 30.001. This confirms
that certificate-bearing state transitions, orbit minimization, strict
invariant checking, rebuild, and finite unfolding dominate; output size and the
Layer-3 repair recurrence do not explain the wall-time gap.

### Maintained implementation tradeoff

The Fast Rewrite IR is not a discarded predecessor. It remains the efficient
direct implementation of normalization and repair geometry used for
large-corpus ranking, rapid iteration, and differential validation. The
Certificate-Integrated IR is the stronger semantic-assurance path: it requires
typed law provenance, certified binder actions, coherent congruence state, and
strict invariant success before equality is observable. Unsupported or stale
evidence therefore fails closed instead of being treated as an admissible
rewrite.

The measured cost is substantial: approximately 125x wall time in the cited
run, despite similar representation sizes and maximum RSS. The artifact keeps
both paths so experiments can choose throughput or auditable semantic
admission without changing the underlying repair metric. Zero incorrect merges
and bounded solver checks support the implementation, but do not establish
unbounded Alloy equivalence.

## Manifest Contract

Every ablation arm manifest now records the run ID, Git SHA and dirty flag,
Java source hash, dataset root/hash/count/bytes, JVM/vendor/heap, workers,
logical processors, host/CPU/OS, seed, start/completion times, rule names and
rule-set version, schema versions, engine identifier, exact-engine flag,
invariant mode, canonicalizer version, certificate mode/verifier, adapter,
pipeline, finite-unfolding and measurement-projection versions, bounded rewrite
settings, and SHA-256 hashes of generated outputs.

`--report-only` requires compatible run contexts and verifies per-arm hashes
before producing combined files. It does not silently combine an old six-arm
run with the new exact arm.

## Historical Validation Chronology

The individual bullets in this section retain the developmental measurements
that led to the current implementation. The superseding clean publication
measurement is stated at the end of the chronology.

The Phase I build and focused checks were refreshed on 2026-08-26:

- all sources compile against `lib/*`;
- `CanonicalAlloyPipelineTest`: 1,428 checks covering mixed-carrier typed adaptation,
  same-descriptor permutation, shadow-safe alpha-equivalence, ACI, descriptor
  discrimination, scoped maximum arity, nested-scope separation,
  `ALL/SOME/ALL` barriers, temporal alias inheritance, temporal separation,
  negative discrimination, heterogeneous binder-order equality, guarded-domain
  ACI, post-permutation Bag/Set normalization, nested-versus-grouped subtype
  binders, certified local-declaration regrouping, statistics, digest shape,
  guarded relational factoring, exact relation-valued binder arity, full-carrier
  subtype absorption, union cardinality, left- and right-nested difference
  normalization, intersection/difference extraction, one-coordinate Cartesian
  product difference factoring, its multi-coordinate barrier, coordinatewise
  product intersection, dependent-chain ACI transfer through JOIN and ARROW
  with union/intersection order and duplicate coverage, converse-JOIN reversal,
  domain/range restriction coordinate algebra and its diagonal/multi-difference
  barriers, and determinism;
- `QuotientRepairDistanceTest`: 2,266 focused checks covering Seq order, Set/Bag
  assignment, one-unit declarations, proof presentation, scope barriers,
  unequal-arity exact alpha minimization, temporal decomposition, and the
  fail-closed zero kernel;
- `TheoryCertificatesTest`: 251 checks, including rejection of a same-payload
  swap across exchange classes;
- `EGraphSaturationTest`: passed, including distinct disjointness classes;
- isolated blocking-file backtranslation at Alloy scope 3: 2 predicates,
  0 mismatches, and 0 failures;
- Phases B-H: 18,521 deterministic checks unchanged;
- `EGraphAblationTest`: passed;
- 100-file three-layer batch smoke: 100 successes, 0 failures, 0 incorrect
  zeroes, and 100/100 equality between the Fast Rewrite and certificate-integrated paths;
  temporal, quantifier, and matrix discrepancies were each 0/100;
  mean Fast Rewrite / representative TED / certificate-integrated repair distances were
  15.000 / 35.640 / 15.000;
- exact replay of all 784 files that failed the preceding full-corpus run:
  784 successes, 0 failures, and 0 incorrect canonical zeroes. All 737
  missing-law and all 47 zero-kernel failures were eliminated. Fifty-one
  records differ from Fast Rewrite only through I-F27's certified local-declaration
  regrouping; the formerly contradictory correct pair now has distance zero;
- refreshed replay after I-F28/I-F29: 784/784 successes at 32 workers in
  63.09 seconds, 0 failures, 0 incorrect zeroes, and 4.45 GiB peak process RSS;
- refreshed replay after I-F30: 784/784 successes at 16 workers in 57.53
  seconds, 0 failures, 0 incorrect zeroes, and 5,653,148 KiB peak process RSS;
- ordered 171-file window around the reported 16,668 frontier: 171/171
  successes in 15.50 seconds at 16 workers, 0 failures, and 0 incorrect zeroes;
- isolated replay of the sole subsequent full-run failure
  (`trash_ltl/correct/WCmW6XqHcDpTMcHzX_inv16.als`): one success,
  distance zero, temporal/quantifier/matrix components `(0,0,0)`, and no
  failure with rewards disabled;
- 100-file augmentation smoke: 100 ranked predicates, 99 unique prepared
  representations, and 0 failures with rewards disabled;
- two-file seven-arm ablation and hash-checked report-only regeneration:
  passed;
- target-one capability smoke: the exact arm recovered all 11/11 generated
  families and all 8/8 composed cases with 0 errors and 0 false negatives;
- bounded capability soundness sample: 11 checks and 0 failures.
- progress smoke after I-F32: two-file augmentation, two-file raw-egraph arm,
  and one-file seven-arm isolated suite completed with visible checkpoints;
  deterministic reports were produced and the full source tree compiled.
- I-F33 constrained-heap replay: the four reported files at source positions
  19,282-19,285 completed in 0.49 seconds with 417 MiB peak RSS; a
  root-preserving 5,000-file prefix containing 1,884 `CORRECT` models completed
  in 32.07 seconds under `-Xmx2g`, with 1.17 GiB peak RSS and no failures; a
  mixed 100-file ranking pass completed all 99 distinct candidate tasks with
  the same four-builder heap bound.
- I-F34-I-F36 strict correct-pool audit: all 23,694 correct source files parsed;
  after excluding 4,482 raw-AST-identical student/oracle inputs, all 19,212
  considered inputs and 4,491 distinct references completed with no certified
  zero-kernel contradiction. The three isolated offending invariant groups now
  each have certified equality and repair distance zero.
- I-F37 bounded backtranslation replay: 12 predicates from the six concrete
  kernel-regression files completed with 0 mismatches and 0 failures.
- I-F38-I-F39 targeted ranking replay: `coursesOld`, `trash_ltl`, and
  `trash_rl` completed 16,637 source files, 15,284 eligible models, 7,905
  unique ranking tasks, and 225,884 deduplicated candidate comparisons with no
  strict-kernel failure.
- I-F38-I-F39 full no-reward augmentation: all 66,080 source files parsed;
  4,482 raw-AST-identical files were excluded before pools; all 61,598 eligible
  models, 42,386 incorrect predicates, 30,607 unique ranking tasks, and
  1,424,852 deduplicated candidate comparisons completed with 0 parse failures
  and 0 strict-kernel failures. Ranking took 947.438 seconds at 32 workers.
- refreshed rewarded augmentation (`canonical-alloy-pipeline-v10-three-layer`,
  metric v5): all 61,598 eligible models and 42,386 incorrect rankings
  completed; Rewarder pool size 100 produced 42,386 successes and 0 failures.
  The co-equal truth pools contain 19,393 oracle-plus-student predicates, 4,496
  AST-distinct truths, 2,318 canonical components, and 10,257 AST-different
  canonically equivalent truth pairs. Mean nearest certified repair distance is
  10.865050.
- full seven-arm natural-corpus run: every arm completed all 61,598 eligible
  pairs after excluding 4,482 identical ASTs, with 0 failures and 0 incorrect
  zeroes. Fast Rewrite IR found 2,316 `CORRECT` zeroes; the certificate-integrated arm retained
  all of them and added one. Mean distances were 14.029027 and 14.041998.
  The exact arm recorded 20.935 reachable e-classes and 18.059 reachable
  e-nodes on average.
- refreshed seven-arm bounded soundness run after I-F40: all 2,320 unique
  natural-corpus zero claims completed with 0 counterexamples and 0 solver
  errors. This includes all 82 exact claims absent from the previous report;
  all four targeted inequivalence probes are rejected by every arm.
- full seven-arm capability run: 5,500/5,500 valid generated pairs were
  processed. Raw and egglog recovered 47.00%, their De Bruijn variants 65.96%,
  and slotted, Fast Rewrite IR, and Certificate-Integrated IR each 100.00%. All 11 expected
  capability boundaries matched; `unexpected_failures.csv` is empty. The 29
  bounded subtype checks had 0 conclusive non-temporal failures and 6 temporal
  checks explicitly marked inconclusive.

The bullets above retain the developmental replay chronology. The current
checked-in empirical trees supersede those measurements: clean publication run
`df4d8d4c-6265-4fe7-88d5-3aceee60398b` at source `fbd9b149` completed all
61,598 eligible paired evaluations, all 42,386 incorrect-to-truth rankings,
all seven ablation arms, and all 5,500 capability pairs. It reported zero stage
failures, 4,088 certificate-integrated `CORRECT` paired zeroes, zero paired
incorrect zeroes, and zero certified incorrect-to-truth zeroes. The Fast
Rewrite path reported 4,074 paired `CORRECT` zeroes and zero
incorrect-to-truth zeroes. The bounded natural-corpus checker found no
counterexample in the union of 4,088 claimed equalities. Capability recovery
was 5,500/5,500 for slotted and both canonical arms; the two canonical arms
agreed on all generated pairs.

## Post-Integration Distribution Repair

Pipeline `canonical-alloy-pipeline-v38-phase-local-bindings` includes the guarded semantic
families found by the Round-63 through Round-73 staged reviews. Relational converse now
distributes through exact binary union, intersection, and difference, using a
parser-authenticated correlated-column reversal proof. Ordinary Cartesian
products now factor coordinate unions without requiring an abstract carrier;
subgroup factoring and complete-grid checks still prevent diagonal or partial
grids from inventing missing tuples, and composed bound-slot invocations are
retained throughout that proof. Boolean `AND`/`OR` and relational
`INTERSECT`/`PLUS` additionally normalize the two absorption and two
distributive laws toward a factored representative. Every derived relational
intermediate receives its own parser-authenticated exact union/intersection
type, including an arity-bearing empty overlap. These rules run before the
certified snapshot and are mirrored in saturation. Parser-backed equality/distance
regressions, direct Alloy SAT/UNSAT matrices, authority-loss controls, and
standalone Lean cover the admitted schemas. Full-carrier containment now also
uses declaration-DAG subtype evidence, with `A+B+P=P` and `A&P=A` admitted
only when the named carrier is parser-authenticated. Four set-difference
factorizations, JOIN distribution over union, and `some`/`no` over union are
likewise normalized under exact type guards. Relation-valued binders retain
their complete parser-derived arity in both certified and repair views.
Cartesian product differences additionally factor through exactly one changed
coordinate in an equal-length chain; a two-coordinate change remains explicit.
Intersections of equal-length Cartesian products factor coordinatewise across
every participating product, including n-ary and ternary chains, while
nonproduct residual operands remain outside the factored subgroup. A dependent
JOIN/ARROW certificate retains its exact pre-ACI source commitment and may bind
the frozen repair occurrence only after a separate lineage-, type-, slot-, and
certified-ACI-quotient check.
Converse additionally reverses exact binary JOIN sequences while transposing
every operand. Parser-authenticated domain and range restrictions normalize as
two-coordinate operations: lattice homomorphisms, repeated restrictions,
opposite-side commutation, and complete union grids close, while diagonal grids
and differences changing both coordinates remain explicit.
JOIN distribution over union closes at every coordinate of an ordered
composition chain before certification. Converse also commutes with transitive
and reflexive-transitive closure without changing the closure kind, and swaps
domain with range restriction while retaining the restrictor.
Restrictions additionally consume a proved full endpoint carrier and propagate
an authenticated empty coordinate. Typed empty binary relations remain empty
under converse and transitive closure, while reflexive-transitive closure
becomes authenticated `iden`.
Left-nested difference chains accumulate their removal operands in one
parser-certified union; right-nested difference expands by its separate
pointwise law; and intersections collect kept and removed operands into one
difference. Left and right nesting remain semantically distinct. The
Round-63 through Round-73 snapshots and all earlier ballots on those bytes are
invalidated; a wholly fresh review ladder is required.

The v23 source quotient additionally consumes a parser-certified full carrier
on either side of the relational lattice: `R + C` becomes `C`, and `R & C`
becomes `R`, only when declaration evidence or correlated exact ancestry proves
`R in C`. Composite carriers are closed products or unions of primitive full
signature leaves; a subset signature uses its declaration DAG because Alloy's
static type can erase that boundary. Mutual containment keeps one stable ACI
representative. Parser-backed subtype, subset, field, and product cases close,
while same-typed fields, sibling subsets, and proper sub-products remain
distinct. Round 65 was invalidated by this discovery and contributes no review
credit.

## Quick Reproduction

Compile once:

```bash
BUILD_DIR=/tmp/acgn-phase-i-build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
find src -name '*.java' -print > /tmp/acgn-phase-i-sources.txt
javac -cp 'lib/*' -d "$BUILD_DIR" @/tmp/acgn-phase-i-sources.txt
export ACGN_CLASSPATH="$BUILD_DIR:lib/*"
```

Run the focused boundary test and small corpus smokes:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.CanonicalAlloyPipelineTest
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.metric.QuotientRepairDistanceTest

java -Xmx2g -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.CanonicalBatchTest \
  classified-data /tmp/candis-phase-i-batch \
  --limit 100 --threads 4 --skip-rewards

java -Xmx2g -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.Alloy4FunAugmenter \
  classified-data /tmp/candis-phase-i-augmented \
  --limit 100 --threads 4 --skip-rewards

./scripts/run_egraph_ablation.sh \
  --input classified-data --output /tmp/candis-phase-i-ablation \
  --limit 100 --threads 4 --max-heap 2g --seed 55520260811

./scripts/run_capability_benchmark.sh \
  --dataset classified-data --output /tmp/candis-phase-i-capability \
  --natural /tmp/candis-phase-i-ablation \
  --target 5 --threads 4 --max-heap 2g --seed 55520260811
```

## Full-Corpus Reproduction Points

Run structural experiments first, without Rewarder:

```bash
java -Xmx4g -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.CanonicalBatchTest \
  classified-data distance_results-phase-i \
  --threads 16 --skip-rewards

java -Xmx4g -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.Alloy4FunAugmenter \
  classified-data alloy4fun-augmented-phase-i \
  --threads 32 --skip-rewards

./scripts/run_egraph_ablation.sh \
  --input classified-data --output egraph_ablation-phase-i \
  --threads 32 --max-heap 4g --seed 55520260811

./scripts/run_capability_benchmark.sh \
  --dataset classified-data --output capability_benchmark-phase-i \
  --natural egraph_ablation-phase-i \
  --target 500 --threads 32 --max-heap 4g --seed 55520260811
```

For rewarded reruns, remove `--skip-rewards` and add the desired
`--reward-pool N`. To regenerate only an ablation report, repeat the exact
input/output/thread/limit/heap/seed configuration and add `--report-only`.

## Gate Decision

Gate I passes for the integrated exact engine and its retained compatibility
measurements. The theory-artifact obligation matrix has 125 `EXACT` rows. A
clean, tagged full-corpus rerun remains a release-provenance task, not an
implementation blocker. Phase J must still perform the requested hostile final
audit before making the final artifact claim.
