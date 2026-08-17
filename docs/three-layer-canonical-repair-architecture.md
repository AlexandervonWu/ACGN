# Three-Layer Canonical Repair Architecture

## Architectural Rule

CanDis now keeps three questions in three dependency-separated layers:

```text
CertifiedSemanticArtifact
  -> CanonicalObservation
  -> equality / digest / serialization

CertifiedSemanticArtifact
  -> RepairProjection
  -> QuotientRepairDistance
```

The metric package does not depend on the canonical package. Canonical
representatives are deterministic equality observations, but they are not
assumed to be isometric representatives of rewrite-equivalence classes.

## Located Conflation

Before this refactor, `CanonicalAlloyPipeline.distance` first constructed the
faithful graph and canonical finite-term key, then ran ordered tree edit
distance on an independently canonicalized representative. This conflated:

1. proof-bearing graph structure;
2. deterministic equality serialization; and
3. source-level repair geometry.

Independent lexicographic alpha choices and independently sorted ACI children
are valid for equality but discontinuous as a metric. A one-edit binder example
measured 9 representative-tree edits, and a one-edit ACI example measured 22.

## Layer 1: Certified Semantic Representation

Primary classes:

- `theory/TypedSlottedPortEGraph`
- `theory/CertifiedSemanticArtifact`
- `theory/FiniteUnfoldingTree`
- `theory/BinderBlockDescriptor`
- `theory/CoherentWitnessFamily`
- certificate, rebuilding, typed-port, and typed-slot classes
- `adapter/TheoryAlloyAdapter`

`CertifiedSemanticArtifact` is an immutable read boundary containing the root
invocation, quiescent e-class snapshot, coherent witness family, complete
stored finite unfoldings, and the signature-certified source container-law
registry. It retains typed ports, exact support, scope and exchange classes,
sequence/bag/set/one distinctions, witnesses, and certificates. It is
intentionally verbose and is not assigned edit costs. Phase and local binder
descriptors remain available at the adapter boundary so projection can require
the exact scope certificate that admitted an alignment.

## Layer 2: Canonical Equality

Primary classes:

- `canonical/CanonicalObservation`
- `canonical/CanonicalRepresentativeTreeDistance`

`CanonicalObservation` owns the normalized finite-term key, deterministic
serialization, equality, and SHA-256 digest. The contract remains that
recognized equivalent inputs receive equal observations.

`CanonicalRepresentativeTreeDistance` preserves the former finite-term TED
under an explicit diagnostic name. It is a baseline only. No isometry theorem
is claimed for it, and the primary metric does not call it.

## Layer 3: Established Repair Metric On The Quotient

Primary classes:

- `metric/RepairView`
- `metric/RepairProjection`
- `metric/QuotientRepairDistance`

`CanonicalDistance` is the metric specification, not a heuristic baseline.
`RepairProjection` snapshots the same repaired `NormalForm` decomposition and
attaches the binder descriptors and container laws certified during faithful
adaptation. `QuotientRepairDistance` ports the legacy edit algebra instead of
inventing a new one. It never calls `CanonicalDistance` and it never edits a
canonical representative tree.

The governing relationship is:

```text
faithful representation certifies the quotient and admissible symmetries
+ established CanonicalDistance defines geometry and edit units on that quotient
```

### Projection Classification

| Faithful component | Role in repair metric | Treatment |
| --- | --- | --- |
| Source semantic operator | `SEMANTIC_EDITABLE` | One operator edit unit |
| Temporal operator | `SEMANTIC_EDITABLE` | Separate ordered temporal tree |
| Binder declaration tuple | `SEMANTIC_EDITABLE` | One insertion, deletion, or tuple modification |
| Bound/free variable occurrence | `SEMANTIC_EDITABLE` | Compared under active certified alignment |
| Seq/Bag/Set/One kind | `ALIGNMENT_ONLY` | Selects DP, multiplicity matching, assignment, or direct comparison |
| Binder automorphism action | `ALIGNMENT_ONLY` | Certifies within-block permutations used by pairwise alpha alignment |
| Scope/exchange/dependency data | `ALIGNMENT_ONLY` | Guards legal alignment and is not charged as an extra repair node |
| Port schema and relational coercion wrapper | `SCHEMA_ONLY` | Wrapper costs zero; semantic child retained |
| Witness, certificate, e-class ID, rebuilding trace | `PROOF_ONLY` | Absent from `RepairView` |
| Ambient-support bookkeeping | `PROOF_ONLY` | Not an editable wrapper; typed occurrences remain available when semantic |

### Actual Algorithms

| Construct | Comparison |
| --- | --- |
| Full metric | `D_temporal + D_quantifiers + D_matrix`, preserving the legacy phase decomposition |
| Binder / alpha | Exact minimum over maximum-cardinality partial variable mappings; certified scope blocks are matched pairwise and in order, then variables permute only inside matched blocks |
| Declaration | One insertion, deletion, or modification of the quantifier/type/cardinality/disjointness tuple |
| Sequence | Ordered dynamic programming |
| Set / ACI | Minimum-cost bipartite assignment; faithful Set already removes duplicates |
| Bag / AC | Multiplicity-preserving minimum-cost bipartite assignment |
| Fixed commutative operator | Minimum-cost child assignment under the Alloy signature law; no associativity is inferred |
| One | Direct ordered child comparison; no proof/schema wrapper is charged |
| Temporal | Ordered rooted-tree DP, kept separate from phase quantifiers and matrices |
| Matrix operator | One legacy opcode/payload update plus ordered DP or unordered assignment over children |
| Proof/schema wrappers | Zero; not emitted as metric terms |
| Finite unfoldings | Equality/certificate observations only; they are not a metric search space |

The pipeline enforces canonical equality as the zero-distance kernel. Either
direction of disagreement fails closed; the implementation does not patch a
projection-only zero into distance one.

### Operation Migration

| `CanonicalDistance` operation | Mathematical edit operation | Minimized alignment/equivalence space | Legacy `NormalForm` information | Faithful certified information |
| --- | --- | --- | --- | --- |
| `treeDistance` | Insert/delete a temporal subtree by its size; relabel one temporal operator for one | Ordered rooted temporal trees | Phase topology and natural binary-temporal labels | Phase reachability and temporal-boundary validation; the same immutable labels enter `RepairView` |
| `canonicalQuantifierOrder` + `bindingListDistance` | Insert, delete, or modify one quantifier/type/cardinality/disjointness tuple for one | Stable permutations inside consecutive `ALL` or `SOME` runs, then sequence DP | `matrixQuantiVars` tuple list | Descriptor payload validates every projected tuple; metric ordering and costs are unchanged |
| `maximumCompatibleMatches` + `bestMappedDistance` | Rename bound occurrences at zero cost under one injective mapping | Every maximum-cardinality pairwise alpha alignment | Parameter/matrix/inherited roles, tuple payloads, indices, and binding paths | Scope owners, exchange blocks, exact domains, dependencies, and the checked full declaration actions in `Aut(beta)` restrict which pairings are admissible |
| `nodeUpdateCost` | Relabel one opcode, referenced symbol, constant, or unmatched variable for one | Active alpha mapping for variable occurrences | Matrix `EGraphNode` opcode, source payload, and readable/alpha name | Law-checked immutable matrix node plus certified binding coordinate; cost remains the legacy unit update |
| `childDistance` | Insert/delete a child subtree by size or recursively edit it | Order-preserving sequence alignments | Ordered child list | Certified `Seq` or fixed ordered operator status |
| `unorderedChildDistance` | Recursively edit matched operands; insert/delete unmatched subtrees | All bipartite matchings, solved by Hungarian minimum-cost assignment | `isOrderInsensitive`, flexible kind, and operand multiplicity | Certified `Bag`/`Set` law or checked fixed commutative signature; Bag occurrences remain distinct and Set idempotence is applied before measurement |
| `matrixDistance` | Sum the minimum matrix repair for each temporal phase | The alpha and child-alignment products above, independently per phase | Phase-local repaired matrix roots and binding tables | Corresponding phase descriptor and certified container laws; quantifiers never cross temporal phases |
| `canonicalFormSize` | Define the normalization denominator | No minimization | `#normal forms + #matrix quantifiers + #matrix nodes` | `RepairView.semanticSize` preserves those source repair units and excludes proof/schema wrappers; certified regrouping of adjacent equivalent local declaration blocks is counted once on the quotient |

Readable edit paths continue to use source aliases from `QuantiVar`; those
aliases do not participate in alpha identity. The identity used by pairwise
minimization is the certified typed coordinate and its scope block.

At projection time, every equal-payload declaration class used by the legacy
alignment is checked against `Aut(beta)`: certified adjacent transpositions
must generate the full class permutation space. A descriptor with a narrower
group is rejected instead of silently broadening the metric's zero-cost
alignment space. This is the current faithful correspondence for repaired
Alloy declaration blocks.

## Exact And Bounded Guarantees

Exact in the current implementation:

- canonical observation equality and hashing;
- scope/exchange legality supplied by certified binder descriptors;
- sequence, bag, set, and one alignment for a fixed term pair;
- exact pairwise scope-block and variable minimization for the materialized
  repaired normal form;
- one-unit declaration tuple edits;
- proof/schema-wrapper erasure;
- zero-distance kernel equals certified canonical equality.

Explicitly bounded or not yet proved:

- finite unfoldings are those published by the existing bounded complete-tree
  oracle;
- finite unfolding remains bounded for Layer-2 equality observation, but does
  not truncate Layer-3 alpha or operand matching;
- no theorem currently establishes the triangle inequality for the complete
  mixed repair vocabulary;
- the rewrite system remains incomplete for full Alloy semantic equivalence.

## Controlled Smoke Comparison

The first post-refactor no-reward run used the same 100 eligible
`classroom_fol/BOTH` pairs, 32 workers, and repaired `NormalForm` for all three
measurements:

| Metric | Direct reference implementation | Representative TED | Faithful metric port |
| --- | ---: | ---: | ---: |
| Mean distance | 15.000 | 35.640 | 15.000 |
| Observation size | 18.450 | 41.140 | 18.450 |
| Mean normalized distance | 0.791 | 0.852 | 0.791 |
| Incorrect zero merges | 0 | 0 | 0 |
| Mean metric time | not separately instrumented | 0.984 ms | 1.405 ms |

All 100 faithful distances exactly matched `CanonicalDistance`, including
100/100 agreement in each temporal, quantifier, and matrix component. This
smoke established the migration invariant before the full-corpus run.

A separate pool-10 rewarded run on the same 100 incorrect predicates completed
without reward failures. Candidate reward averaged 0.298320 and oracle
self-reward averaged 1.000000. Pearson correlation with candidate reward was
-0.324342 for both the faithful and direct reference implementations and
-0.353022 for representative TED; normalized correlations were -0.203739,
-0.203739, and -0.179873 respectively. These small-sample reward statistics
are diagnostic only.

## Full-Corpus Comparison

The August 17 seven-arm run evaluated all 61,598 nontrivial student-oracle pairs
at 32 workers. The legacy canonical arm and exact metric port produced:

| Measure | Legacy canonical | Faithful exact |
| --- | ---: | ---: |
| Successful pairs / failures | 61,598 / 0 | 61,598 / 0 |
| Mean repair distance | 14.029027 | 14.041998 |
| `CORRECT` zeroes | 2,316 | 2,317 |
| Incorrect zeroes | 0 | 0 |
| Mean representation units | 29.843 | 29.830 |
| Process wall time | 18.470 s | 2,303.890 s |
| Engine CPU time | 13.255 s | 47,451.149 s |
| Maximum RSS | 3,529.023 MiB | 3,603.680 MiB |

The exact zero set contains the complete legacy zero set and one additional
`CORRECT` pair. The small nonzero-distance divergence is retained for
pair-level classification in `minimum_distances.csv`; it is not hidden behind
representative TED. The exact arm's roughly 125x wall-time cost is construction
and certification overhead rather than a larger observation or a replacement
distance geometry.

The current augmented truth-pool run exercises a different minimization
protocol: each of 42,386 incorrect predicates is compared with every
AST-distinct correct truth in its invariant group. It completed without
strict-kernel failures and reports mean nearest certified distance 10.865050.

## Migration Discrepancy Audit

Numerical divergence is never accepted merely because the faithful structure
is more elaborate. The migration exposed and classified the following
discrepancies:

| Discrepancy | Classification | Resolution |
| --- | --- | --- |
| Initial generic semantic-tree port averaged 16.870 where the metric specification averaged 15.000 | Metric-semantics regression | Removed the invented tree geometry and ported every legacy recurrence and edit unit |
| A locally numbered exchange class differed across two otherwise compatible certified artifacts | Implementation bug | Compare pairwise scope-block structure; never compare artifact-local class IDs across inputs |
| Unequal-arity alpha search committed the first compatible variable under a hash-order tie | Implementation bug | Compute maximum compatible cardinality and minimize over every maximum partial mapping in both implementations |
| Container legality was reconstructed only from selected finite unfoldings, omitting source operators consumed or normalized away | Implementation bug | Carry a signature-certified source-operator law registry in the semantic artifact |
| Independent heterogeneous binders retained source coordinate order and guarded slots used an unstable source type approximation | Implementation bug | Canonically order independent coordinates, retain the source-coordinate permutation, and use the primitive certified carrier |
| `{x:S, y:S | P}` and `{x,y:S | P}` received different legacy matrix costs although the certified local binder descriptors are equal | Intentional semantic correction: the legacy admissible transformation space was too narrow | Regroup adjacent non-disjoint, equal-domain declarations only under the exact certified local descriptor; preserve dependency and disjointness barriers |
| The adapter reused the operational `univ` carrier required by unsafe prenexing as the primitive alpha color, creating artificial factorial orbits | Implementation bug | Keep primitive type and operational quantifier carrier as separate certified fields; slots and repair tuples use the primitive color, while descriptor domains retain the operational carrier |
| A binder permutation changed already-normalized ACI operands without re-normalizing the resulting container | Implementation bug | Re-sort Bag operands and re-sort/deduplicate Set operands after every certified coordinate action |
| Parser-only source provenance distinguished two semantic `NOT_IN` operands, and the repair projection retained both under a certified ACI Set | Implementation bug | Clear source provenance on opcode rewrites and deduplicate projected Set operands; preserve Bag multiplicity and Seq order |

The controlled 100-pair differential still has no discrepancy: 100 of 100
faithful distances equal the directly executed metric specification. The
targeted replay of the previous 784 failures contains 51 deliberate
differences, all attributable to the certified local-declaration regrouping;
the other 733 records preserve component parity.

## Regression Evidence

- `QuotientRepairDistanceTest`: 13 checks covering sequence order, set/bag
  assignment, declaration units, scope barriers, unequal-arity exact alpha
  minimization, proof presentation, temporal decomposition, and zero-kernel
  failure.
- `CanonicalAlloyPipelineTest`: 185 checks covering real Alloy alpha and ACI discontinuity,
  certified symmetry invariance, canonical equality, scope legality, and
  negative discrimination, including unequal-arity alpha differential parity,
  heterogeneous binder order, guarded-domain ACI, and the documented local
  declaration-grouping correction, carrier-preserving guarded binders,
  fixed equality/inequality commutativity, named-reference identity, certified
  local-comprehension alpha alignment, one owner mapping across inherited
  temporal phases, and post-permutation ACI normalization.
- 100-file batch smoke: 100 successes, zero failures, zero incorrect zeroes,
  and 100/100 equality with the directly executed metric specification.
- Exact replay of all 784 prior failures: 784 successes, zero failures, zero
  incorrect zeroes, and no unclassified discrepancy.
- Full seven-arm corpus: 61,598 successes per arm, zero failures, zero incorrect
  zeroes, and exact transition `+1/-0` from the legacy canonical zero set.
- Full generated capability matrix: exact, slotted, and legacy canonical each
  recover 5,500/5,500 pairs; all 11 expected capability boundaries match.

## Reproduction

```bash
java -cp "$ACGN_CLASSPATH" \
  is.fivefivefive.CanDis.metric.QuotientRepairDistanceTest

java -Xmx2g -cp "$ACGN_CLASSPATH" \
  is.fivefivefive.CanDis.CanonicalAlloyPipelineTest

java -Xmx2g -cp "$ACGN_CLASSPATH" \
  is.fivefivefive.CanDis.CanonicalBatchTest \
  classified-data /tmp/candis-three-layer \
  --limit 100 --threads 32 --skip-rewards
```

The full run uses the same command without `--limit` and, when rewards are
required, without `--skip-rewards`.
