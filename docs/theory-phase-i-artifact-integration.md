# Phase I Artifact Integration

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
| I-F28 | The adapter used `carrierTypeName` as the slot's alpha color. Unsafe strict prenexing legitimately uses nonempty `univ` as an operational quantifier carrier, but this collapsed the original primitive colors; at corpus progress 16,668, `coursesOld/both/qYmq7gitNeA9qJSbg_inv15.als` therefore exposed ten same-colored coordinates and attempted an artificial `10!` orbit | Separate the two fields: `typeName` is the Alloy-annotated least-parent primitive alpha color and repair-tuple type, while `carrierTypeName` records the operational quantifier domain (`univ` only where the prenex equivalence requires it). Descriptor slots use the former and descriptor domain payloads use the latter; syntactic type inference is fallback only |
| I-F29 | Finite-term binder minimization acted on a body whose Bag/Set operands had already been normalized, but did not normalize those containers again after permuting their bound-coordinate markers. Nested and grouped subtype binders could therefore have repair distance zero but different canonical keys | Every binder-automorphism candidate now re-sorts Bag operands and re-sorts plus deduplicates Set operands after the coordinate action. The strict zero kernel remains enabled, and the nested/grouped `Entry`/`Exit` regression has one byte-identical canonical observation |
| I-F30 | The next full run had one remaining zero-kernel failure: `trash_ltl/correct/WCmW6XqHcDpTMcHzX_inv16.als`. Implication elimination plus primitive-domain guarding produced the same `NOT_IN(f, Protected)` operand twice under an ACI `OR`. One copy retained the parser-only source label `BOP_IN`, so frontend saturation failed to deduplicate it; Layer 1 ignored that nonsemantic label and correctly deduplicated the Set, while `RepairProjection` copied both occurrences and charged three matrix edits | Clear parser provenance whenever normalization changes an opcode, so the repaired NormalForm itself restores ACI idempotence; also project certified `SET` containers idempotently as a boundary invariant. This is a metric-port bug fix: Set idempotence was already part of the established quotient semantics. Bag multiplicity and Seq order are unchanged. Both the Fast Rewrite metric and certificate-integrated temporal/quantifier/matrix components are now zero |
| I-F31 | The I-F30 temporal fixture exposed a pre-existing backtranslation contradiction: matrix `REF` leaves such as `temporal[0:1]` were emitted literally as Alloy source and temporal children were appended conjunctively, losing the reference's Boolean position | Render direct temporal children first, bind each unary/binary child to its exact `temporal[index:arity]` key, and substitute each `REF` in place while retaining an explicit fallback only for manually assembled unreferenced children. Unresolved references fail closed. The connective-embedded temporal regression compiles, and bounded equivalence of both predicates in the I-F30 file has zero mismatches and failures |
| I-F32 | Corpus-scale augmentation, ablation, memory, capability, semantic-soundness, and backtranslation runners had inconsistent or absent progress output; several parallel collectors also waited in submission order, so one slow early task made productive runs appear stuck | Add one shared `ExperimentProgress` reporter with bounded checkpoints, throughput, ETA, and 30-second no-completion heartbeats. Parallel collectors consume completion order but restore results by source index, preserving deterministic artifacts. Runners that suppress noisy global output retain the original `stderr` for progress, and the process-isolated suite reports both arm completion and the currently running child log |
| I-F33 | `Alloy4FunAugmenter` retained each proof-heavy `CertifiedSemanticArtifact` after extracting its canonical observation and repair view. At parse completion 19,282 the live 8 GiB heap held 8,044,742 / 8,052,736 KiB, RSS was 8.9 GiB, and G1 workers had consumed most elapsed CPU; the nearby source files were not pathological. It also queued all 66,080 parse futures at once | Keep full `Prepared` values as the replayable default, but add an explicit comparison compaction that retains the certified observation, repair view, and scalar statistics while releasing construction-only graph witnesses. Augmentation caches use only this compact form. Simultaneous certificate-integrated construction is bounded by the configured heap and capped at 16, while parsing and distance work retain requested parallelism. Parsing keeps at most four tasks per worker in flight, and stall heartbeats identify the earliest unresolved source path |
| I-F34 | The strict correct-pool audit found a zero repair distance with unequal certified observations for `classroom_fol/inv11`. A safely relativized `some v: Teacher` retained operational carrier `univ` although an earlier direct `Person` prefix binder already guaranteed the primitive carrier was inhabited; the comparison formula used `Person` directly | After prenexing, propagate only guaranteed prefix-carrier witnesses. A later `univ` carrier may narrow to its primitive type only when a preceding direct binder of that type witnesses nonemptiness. The subtype guard remains in the matrix, so empty-domain semantics and the quantifier repair tuple are preserved |
| I-F35 | The same audit exposed `classroom_fol/inv3`: `p != q` and `q != p` had repair distance zero under a certified binder swap, but the exact signature represented `NOT_EQUALS` with ordered child ports and therefore rejected its intrinsic commutativity | Represent fixed commutative `IFF`, `EQUALS`, and `NOT_EQUALS` operands through a certified ordinary `BagPort`. This certifies operand exchange without incorrectly flattening equality into an associative operator; relational equality operands are coerced before entering the homogeneous Bag |
| I-F36 | The final strict-kernel contradiction was `lts/inv7`. Local comprehension variables had no prenex binding index, so `RepairProjection` retained parser alpha labels such as `_q1` while the exact layer correctly used the local binder descriptor and its permutation group | Carry each local binder's source-name-to-certified-coordinate map out of `TheoryAlloyAdapter`. Project local variables to depth-qualified coordinates and minimize pairwise only over the descriptor's certified automorphism elements. Nested depths prevent capture, readable aliases remain presentation data, and no symmetry is inferred from type or names |
| I-F37 | The I-F36 round-trip fixture exposed a separate backtranslation failure: `COMPREHENSION` was rendered with the default existential keyword, so closure received a Boolean expression such as `^(some s1,s2: State | P)` | Render local comprehensions as Alloy set comprehensions `{s1,s2: State | P}`. The targeted six-file bounded check now compiles and proves all 12 backtranslated predicates with zero mismatches and zero failures |
| I-F38 | Incorrect-predicate ranking exposed a false certified equality in `coursesOld/inv13`: `ordering/first` and `ordering/last` differed by one repair edit, but every non-temporal `REF` leaf had the same exact operator head | Include the normalized source identity in every non-temporal `REF` signature head. Temporal normal-form references are resolved before node construction and remain structural phase invocations. The concrete pair now has unequal observations and exactly one matrix edit |
| I-F39 | `trash_ltl/inv8` exposed the opposite failure. The repaired formula compared `eventually f2 in Trash` with `eventually f1 in Trash`; phase-local minimization chose identity for the implication phase and a swap for its temporal child, although both phases refer to one owning binder. This was a Fast Rewrite admissible-space ambiguity proved too broad by the certificate-integrated owner coordinates | Perform one exact maximum-cardinality alpha minimization over owner-coordinate identities across all aligned temporal phases, then reuse that mapping at every inherited occurrence. A declaration-modification fallback aligns only the same owner coordinate and cannot reuse a certified target, preserving the established one-unit quantifier edit. Consistently permuted temporal formulas remain distance zero; inconsistent targets cost one |
| I-F40 | Adding the exact arm to semantic-soundness probes exposed an invalid local automorphism: every local binder coordinate used exchange class 0, so `{x,y:S | y in x.r}` could be identified with `{x,y:S | x in y.r}` even though comprehension coordinates are ordered result columns | Assign each comprehension coordinate its positional exchange class. Alpha-renaming still acts positionwise, while formula and summation binders retain their certified exchange groups. The repaired 185-check pipeline suite distinguishes the pair, and the refreshed bounded run checks 2,320 current union claims with 0 counterexamples, 0 errors, and all four negative probes rejected by all seven arms |

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

A third trigger appeared in ordered progress near 16,668. Relativizing a
guarded declaration legitimately selected nonempty `univ` as its operational
quantifier carrier, but the adapter incorrectly reused that field as the alpha
color and collapsed ten primitive colors into one artificial `S_10` orbit.
Using the Alloy-annotated primitive type as the independent slot color reduces the isolated predicate
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

The completed seven-arm natural-corpus run makes the remaining exact-engine
cost concrete. At 32 workers and `-Xmx3g`, the Fast Rewrite IR arm finished
61,598 eligible pairs in 18.470 seconds with 13.255 engine CPU seconds; the
exact arm required 2,303.890 seconds and 47,451.149 engine CPU seconds. Exact
per-pair latency was 555.391 ms at p50 and 4,394.306 ms at p95. Maximum RSS was
similar, 3,529.023 MiB for Fast Rewrite and 3,603.680 MiB for certificate-integrated execution, and the exact
observation was not larger: 29.830 average units versus 29.843. This confirms
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

## Validation

The Phase I build and focused checks were refreshed on 2026-08-17:

- all sources compile against `lib/*`;
- `CanonicalAlloyPipelineTest`: 185 checks covering mixed-carrier typed adaptation,
  same-descriptor permutation, shadow-safe alpha-equivalence, ACI, descriptor
  discrimination, scoped maximum arity, nested-scope separation,
  `ALL/SOME/ALL` barriers, temporal alias inheritance, temporal separation,
  negative discrimination, heterogeneous binder-order equality, guarded-domain
  ACI, post-permutation Bag/Set normalization, nested-versus-grouped subtype
  binders, certified local-declaration regrouping, statistics, digest shape,
  and determinism;
- `QuotientRepairDistanceTest`: 13 focused checks covering Seq order, Set/Bag
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

The generated seven-arm directories are now full-corpus measurements, not
smokes. Their manifests record source SHA
`cc53042333fa3a1c820eb5715aa3b124e03d0ff1` with a dirty tree, so the manifest
source/output hashes are authoritative. A clean, tagged archival rerun remains
a release-provenance task.

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
