# ACGN / CanDis

ACGN is a research codebase for Alloy program representation, generation, and
repair analysis. Its current evaluation stack, **CanDis**, converts Alloy
predicates into temporal prenex normal forms backed by slotted, variadic
e-graphs. It now separates certified semantic legality, deterministic canonical
equality, and the established repair metric on the certified quotient instead
of treating tree edit
distance between canonical representatives as the repair metric.

The repository contains:

- the original **Alloy Code Generation Network (ACGN)** graph, code-generation,
  learning, reward, and instance-pool implementation;
- **CanDis**, including the canonicalization pipeline, distance metric,
  backtranslation, and reusable JDK-only core;
- six retained raw, De Bruijn, egglog-like, slotted, and bounded-canonical
  ablations plus the exact typed-slotted-port arm;
- the 66,080-file classified Alloy corpus and an augmented nearest-repair
  dataset;
- generated tables, plots, manifests, bounded semantic checks, and memory
  attribution reports.

CanDis is a structural equivalence and repair-distance system, not a complete
Alloy theorem prover. A canonical distance of zero means equality under the
implemented rewrite theory. Bounded Alloy checks and dataset labels provide
separate semantic evidence.

## Headline Results

The checked-in experimental snapshot was regenerated on August 17, 2026. It
contains all seven ablation arms over the same 61,598 nontrivial corpus pairs,
a 5,500-pair capability matrix, the paired student-oracle evaluation, and the
augmented nearest-correct evaluation. Per-problem and per-status tables are in
[`distance_results/summary.md`](distance_results/summary.md),
[`alloy4fun-augmented/summary.md`](alloy4fun-augmented/summary.md), and
[`egraph_ablation/summary.md`](egraph_ablation/summary.md).

The current three-layer implementation treats `CanonicalDistance` as the
repair-metric specification, retains canonical-representative TED as an
explicit baseline, and makes `certified-legacy-repair-distance-v5` primary.
Layer 1 certifies legal scopes and symmetries; Layer 3 preserves the legacy
temporal/quantifier/matrix decomposition, unit edits, alpha minimization, and
unordered assignment. One binder-owner mapping is reused by every inherited
temporal phase; this is the certified correction to the legacy phase-local
alignment space. The full exact ablation arm completed all 61,598 eligible
pairs with zero failures and zero incorrect zero-distance merges. It retained
all 2,316 legacy-canonical zeroes and certified one additional `CORRECT` pair.

The result directories are internally hash-checked, but their manifests record
a dirty source tree. Their source and output hashes therefore identify the
reported artifacts; a clean, tagged rerun remains necessary for camera-ready
provenance.

### Corpus and paired-oracle distance

Every model contains a student predicate and its oracle predicate. Exact
student/oracle raw-AST matches are removed before distance evaluation and before
truth-pool construction.

| Measure | Result |
| --- | ---: |
| Source Alloy files | 66,080 |
| Raw-AST-identical pairs excluded early | 4,482 |
| Eligible and successfully evaluated pairs | 61,598 |
| Evaluation failures | 0 |
| Eligible `CORRECT` pairs | 19,212 |
| Eligible incorrect pairs | 42,386 |
| Mean predicate-body Levenshtein distance | 39.261064 |
| Mean raw-AST Zhang-Shasha distance | 22.841358 |
| Mean certified repair / direct reference distance | 14.014010 / 14.029027 |
| Mean canonical-representative TED baseline | 37.119306 |
| Mean normalized Levenshtein / AST / certified repair distance | 0.547644 / 0.811451 / 0.716590 |
| Mean raw-AST / repair-observation size | 26.787315 / 18.117812 |
| Compression from the ratio of those means | 32.364% |
| AST-different `CORRECT` pairs at certified distance zero | 2,317 |
| Incorrect zero-distance merges | 0 |
| Certified repair distance range | 0 to 139 |

This paired snapshot uses `canonical-alloy-pipeline-v9-three-layer` and
`certified-legacy-repair-distance-v4`. Normalization divides by the larger
corresponding representation of the student-oracle pair. The directly executed
legacy metric remains a differential oracle, and representative TED is a
separate baseline rather than the repair metric.

### Augmented correct pools and nearest repairs

The augmented dataset groups predicates by problem class and invariant ID. Each
truth pool includes the oracle on a co-equal basis with all `CORRECT` student
solutions, then removes raw-AST duplicates. For every incorrect predicate, each
metric is minimized independently over all truths in its group.

| Measure | Result |
| --- | ---: |
| Invariant question groups | 181 |
| Correct truth predicates, including 181 oracles | 19,393 |
| AST-distinct truths | 4,496 |
| Unique canonical truth forms | 2,318 |
| AST-different, canonically equivalent truth pairs | 10,257 |
| Incorrect predicates ranked | 42,386 |
| Groups using oracle plus correct students / oracle only | 176 / 5 |
| Mean nearest Levenshtein distance | 28.054924 |
| Mean nearest raw-AST distance | 15.987944 |
| Mean nearest certified canonical distance | 10.865050 |
| Mean relative Levenshtein / AST / canonical distance | 0.415603 / 0.608420 / 0.602071 |

Repair-radius coverage shows how many incorrect predicates have at least one
correct reference within the given edit budget:

| Radius | Raw AST | Canonical |
| ---: | ---: | ---: |
| 1 | 3,479 (8.2%) | 2,346 (5.5%) |
| 2 | 4,962 (11.7%) | 5,446 (12.8%) |
| 5 | 10,106 (23.8%) | 13,976 (33.0%) |
| 10 | 18,242 (43.0%) | 26,274 (62.0%) |

At radii expressed as a fraction of each incorrect predicate's representation
size, the coverage is:

| Relative radius | Levenshtein | Raw AST | Canonical |
| ---: | ---: | ---: | ---: |
| 5% | 1,085 (2.6%) | 2,049 (4.8%) | 318 (0.8%) |
| 10% | 2,939 (6.9%) | 4,110 (9.7%) | 1,568 (3.7%) |
| 20% | 8,169 (19.3%) | 7,476 (17.6%) | 5,862 (13.8%) |
| 50% | 30,080 (71.0%) | 18,668 (44.0%) | 18,263 (43.1%) |

This augmented snapshot uses `canonical-alloy-pipeline-v10-three-layer` and
`certified-legacy-repair-distance-v5`. Its pool-100 Rewarder pass completed all
42,386 incorrect predicates without a reward failure.

### Seven-arm e-graph ablation

All seven arms processed the same 61,598 eligible pairs with 32 workers in
fresh JVMs. The first five use the same `canonical-equivalences-v2` rule program.
`java-egglog` is a Java replica of the execution model used in this study, not
a full textual-language-compatible port of external egglog.

| Arm | `CORRECT` zeroes | Coverage | Mean distance | Wall s | Engine CPU s | Max RSS MiB | Avg units |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Raw fixed-arity e-graph | 823 | 4.284% | 18.390 | 18.260 | 4.517 | 933.320 | 58.184 |
| Raw e-graph + De Bruijn | 2,163 | 11.259% | 17.923 | 16.580 | 5.289 | 864.070 | 57.865 |
| Java egglog-like variadic | 823 | 4.284% | 17.996 | 16.400 | 4.094 | 874.352 | 56.740 |
| Java egglog-like + De Bruijn | 2,163 | 11.259% | 17.530 | 16.630 | 4.997 | 915.074 | 56.410 |
| Slotted e-graph | 2,162 | 11.253% | 17.694 | 17.390 | 14.642 | 936.621 | 52.952 |
| Legacy canonical | 2,316 | 12.055% | 14.029 | 18.470 | 13.255 | 3,529.023 | 29.843 |
| Typed slotted-port exact | 2,317 | 12.060% | 14.042 | 2,303.890 | 47,451.149 | 3,603.680 | 29.830 |

Key transitions in the observed zero-distance sets are:

- De Bruijn variables add 1,340 pairs to both the raw and variadic arms, with
  no losses.
- Variadic egglog-like storage alone adds no zeroes over fixed arity on this
  natural corpus.
- Slotted storage retains 2,160 egglog-plus-De-Bruijn zeroes, adds 2, and loses
  3. Those three are documented false negatives, not semantic counterexamples.
- Legacy canonicalization adds 154 zeroes over slotted storage and loses none
  of the slotted zeroes.
- The exact typed slotted-port pipeline retains all 2,316 legacy zeroes and
  adds one `CORRECT` zero. Neither canonical arm produces an incorrect zero.

The full transition data and pair identities are in
[`equivalence_disagreements.csv`](egraph_ablation/equivalence_disagreements.csv).

### Targeted capability benchmark

The generated benchmark contains 5,500 parser-AST-different pairs whose
equivalence follows by construction from the implemented rules, with 500 pairs
in each of 11 transformation families.

| Arm | All 5,500 | Eight composed families |
| --- | ---: | ---: |
| Raw fixed-arity e-graph | 2,585 (47.00%) | 2,023 / 4,000 (50.58%) |
| Raw e-graph + De Bruijn | 3,628 (65.96%) | 2,566 / 4,000 (64.15%) |
| Java egglog-like variadic | 2,585 (47.00%) | 2,023 / 4,000 (50.58%) |
| Java egglog-like + De Bruijn | 3,628 (65.96%) | 2,566 / 4,000 (64.15%) |
| Slotted e-graph | 5,500 (100.00%) | 4,000 / 4,000 (100.00%) |
| Legacy canonical | 5,500 (100.00%) | 4,000 / 4,000 (100.00%) |
| Typed slotted-port exact | 5,500 (100.00%) | 4,000 / 4,000 (100.00%) |

De Bruijn encoding gives complete alpha-equivalence recovery, but the raw and
egglog-like representations do not implement general declaration-block
permutations. The raw and egglog-like arms recover 1 of 500 binder-permutation
cases incidentally, and their De Bruijn variants recover 22 of 500. Slotted and
canonical representations recover all 500 alpha-equivalence and all 500
binder-permutation cases. The exact arm agrees with both of them on every
generated pair, and all 11 expected first-capable boundaries match the observed
matrix. The complete family matrix is in
[`capability_benchmark/REPORT.md`](capability_benchmark/REPORT.md).

**AC/logical v2 correction.** Fixed-arity re-binarization could expose a
complement as normalized atomic duals such as `some S` and `no S`, while the v1
matcher recognized only an explicit `A` / `not A` pair. Rule set
`canonical-equivalences-v2` recognizes those duals and folds only
domain-independent constant quantified bodies. Raw and raw-plus-De-Bruijn
coverage for the composed AC-plus-logical-normalization family increased from
479/500 to 500/500; all seven arms now recover all 500 cases. The natural-corpus
zero sets did not change, no incorrect zeroes were introduced, and
[`unexpected_failures.csv`](capability_benchmark/unexpected_failures.csv) is
empty.

### Bounded semantic evidence

The most recent bounded semantic checker predates the exact-arm rerun. It
checked the then-current union of 2,238 natural-corpus equivalence claims using
each model's own Alloy `check correct` command:

| Arm | Claims checked | Bounded counterexamples | Errors |
| --- | ---: | ---: | ---: |
| Raw / raw + De Bruijn | 823 / 2,163 | 0 / 0 | 0 / 0 |
| Egglog-like / egglog-like + De Bruijn | 823 / 2,163 | 0 / 0 | 0 / 0 |
| Slotted / canonical | 2,162 / 2,235 | 0 / 0 | 0 / 0 |

Four targeted negative probes for capture, comprehension-column permutation,
signature shadowing, and temporal implication all had Alloy counterexamples and
were rejected by every arm. This is bounded evidence, not an unbounded proof.
The current seven-arm corpus run supplies a separate label-agreement check: all
2,317 exact zeroes are in `CORRECT`, and none of 42,386 incorrect pairs is zero.
That is not a replacement for rerunning the bounded checker on the 79 newly
observed claims. The current targeted capability soundness sample had zero
conclusive non-temporal failures across 29 subtype checks; six temporal checks
were inconclusive because the installed solver lacked a temporal backend. One
of those inconclusive raw solver runs reported a counterexample under Alloy's
warned static temporal reduction, so it is recorded but not counted as
conclusive evidence. See
[`semantic_soundness.md`](egraph_ablation/semantic_soundness.md) and
[`capability_benchmark/SOUNDNESS.md`](capability_benchmark/SOUNDNESS.md).

### Reward observations

Rewarder results depend on finite sampled instance pools and should not be read
as semantic equivalence proofs.

| Protocol | Pool | Predicates | Mean candidate reward | Headline Pearson result |
| --- | ---: | ---: | ---: | ---: |
| Paired student vs oracle | 10 | 61,598 | 0.567082 | certified distance vs reward: -0.040249 |
| Incorrect vs nearest-correct pool | 100 | 42,386 | 0.352766 | certified distance vs `1 - reward`: 0.056805 |

For the paired run, oracle self-reward averaged 1.000000. On the 42,386
non-`CORRECT` pairs, Levenshtein, raw AST, and certified repair correlations
with candidate reward were -0.089408, -0.073326, and -0.040249. In the
augmented nearest-correct run, their correlations with raw reward error were
0.141856, 0.123954, and 0.056805. All are weak in these sampled configurations.

### Runtime and memory interpretation

The legacy canonical arm completed the 61,598-pair corpus in 18.470 seconds on
a 32-logical-core Ryzen 9 9950X3D host with Java 17 and a 3 GiB heap cap. Its
representation averaged 29.843 units, 25.022 reachable e-classes, and 25.173
reachable e-nodes, with 3,529.023 MiB maximum RSS.

The exact typed slotted-port arm completed the same pairs in 2,303.890 seconds
(26.743 pairs/s). It used 47,451.149 engine CPU seconds, with per-pair engine
latency p50 555.391 ms and p95 4,394.306 ms. Its normalized observations were
slightly smaller at 29.830 units, 20.935 reachable e-classes, and 18.059
reachable e-nodes, while maximum RSS was similar at 3,603.680 MiB. The roughly
125x wall-time increase is therefore not representation growth: it comes from
certificate validation, exact renaming-orbit enumeration, immutable graph
transactions, strict invariant checks, rebuild-to-quiescence, and complete
finite unfolding. The established repair metric itself is not the dominant
cost.

A deterministic 2,000-file attribution run explains the apparent mismatch:

| Workers | Successful | Wall s | Throughput pairs/s | Peak heap MiB | Post-GC MiB | Max RSS MiB |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 1,887 | 3.533 | 534.132 | 299.643 | 82.768 | 606.547 |
| 8 | 1,887 | 1.040 | 1,813.632 | 553.391 | 82.742 | 1,122.309 |
| 32 | 1,887 | 1.045 | 1,805.584 | 544.259 | 82.739 | 1,083.539 |

Peak heap grew 1.816x from 1 to 32 workers, while post-GC heap remained about
82.7 MiB and outputs were identical. The measured peak is dominated by
overlapping parser, MASG, and normalization working sets. Raw-AST construction
alone took 2.965 seconds in the one-worker phase trace; the largest tracked
edit-distance scratch buffer was 1.305 KiB. See
[`canonical_memory/REPORT.md`](canonical_memory/REPORT.md).

## Canonicalization and Distance

The production path is ordered because connective elimination and negation
polarity determine which quantifiers can be moved safely:

1. Parse Alloy and build the MASG intermediate representation.
2. Split temporal operators into a temporal tree of phase-local normal forms.
3. Remove internal `NOOP` and `<END>` scaffolding from matrices.
4. Alpha-normalize bindings while retaining source names for readable edits.
5. Beta-reduce `let` expressions with capture avoidance.
6. Eliminate implication, IFF, and formula ITE before prenexing.
7. Push explicit and implicit negations to NNF, including quantifier and
   temporal duals.
8. Prenex only within the current temporal phase; quantifiers never cross a
   temporal boundary.
9. Store each binding as a primitive carrier, quantifier/cardinality,
   disjointness class, and canonical slot. Move only non-primitive domain
   constraints into the matrix.
10. Reuse typed slot ordinals across compatible sibling universal-conjunction
    or existential-disjunction scopes, using the maximum live arity; nested
    binders and quantifier/connective barriers retain distinct coordinates.
11. Normalize introduced constraints, flatten variadic operators, and saturate
    local equivalences to a fixed point.

Variadic children use three laws: `SEQ` for associativity, `BAG` for
associativity plus commutativity while retaining multiplicity, and `SET` for
associativity, commutativity, and idempotence. Binder permutation groups apply
only within one complete, certified exchange class; continuous compatible
nested declarations may share a class, while a scope barrier cannot.
Named non-temporal references retain their symbol identity, so built-ins such
as `ordering/first` and `ordering/last` cannot collapse.

The Phase I primary exact path next converts every normalized phase through
`TheoryAlloyAdapter`, which creates typed ports and complete binder blocks,
issues structured certificates for Seq=A, Bag=AC, and Set=ACI, inserts every
node through `TypedSlottedPortEGraph.insertNode`, rebuilds to strict quiescence,
and observes a current complete finite-unfolding family. The resulting
`CertifiedSemanticArtifact` is the proof-bearing semantic layer. Full
normalized keys enter `CanonicalObservation` and define equality, digests, and
reproducible serialization.

Repair distance is a separate consumer, but it is not a newly invented
projection metric. `CanonicalDistance` specifies its geometry. `RepairProjection` erases proof,
schema, rebuilding, ambient-support, and port-wrapper plumbing while retaining
semantic operators, declaration tuples, temporal structure, container kinds,
and certified binder actions. `QuotientRepairDistance` preserves the same
temporal/quantifier/matrix edit algebra, using ordered DP for
sequences, multiplicity-aware assignment for bags, minimum assignment for
sets, direct comparison for `one`, and pairwise binder-orbit minimization.
Canonical-representative TED remains available only as
`CanonicalRepresentativeTreeDistance`; no isometry theorem is claimed for it.

The `CanonicalDistance` specification is the sum of:

1. Zhang-Shasha edit distance over the temporal tree;
2. unit-cost additions, deletions, or modifications of phase-local binding
   tuples, minimized over valid binding permutations;
3. e-graph matrix edit distance under semantically equivalent slot bindings.

`CanonicalBatchTest` reports the faithful port, the directly executed metric
specification, and representative TED separately. Its unqualified
canonical distance is the established repair metric evaluated with certified
scope legality; the directly executed legacy implementation and
canonical-representative TED fields are explicit differential diagnostics.

The architectural contracts, exact/bounded guarantees, projection
classification, and controlled comparison are in
[`docs/three-layer-canonical-repair-architecture.md`](docs/three-layer-canonical-repair-architecture.md).

The complete ordered rules, side conditions, opcode inventory, and fixed-point
policy are in [`documentation/REWRITE_SYSTEM.md`](documentation/REWRITE_SYSTEM.md).
The longer architecture and API guide is
[`documentation/README.md`](documentation/README.md).

## ACGN Subsystem

CanDis builds on the original Alloy Code Generation Network infrastructure:

- `ACGN.visitor.MASGVisitor` lowers Alloy parser nodes into the augmented
  multigraph representation in `ACGN.asg`.
- `ACGN.alloy` defines symbols for signatures, fields, declarations, variables,
  references, constants, and graph scaffolding.
- `ACGN.codegen.Generator`, `ACGN.learn.CodeGenAgent`, and `ACGN.learn.Trainer`
  contain the experimental graph-guided generation and learning path.
- `ACGN.learn.Rewarder` compares candidates over sampled Alloy instances;
  `ACGN.util.InstancePool` manages the reusable LFU-backed instance pools used
  by the reward evaluations above.
- `AlloyDataProcessor` contains classification, filtering, graph-output, and
  corpus-counting utilities.

CanDis reuses the MASG front end and Rewarder while keeping canonical-distance
logic in its own packages. Historical ACGN test mains remain useful experiment
harnesses, but `RLAgentFrame` is explicitly marked deprecated and
non-functional in source.

## Repository Layout

```text
src/is/fivefivefive/ACGN/                 original ACGN graph, generator, learner, rewarder
src/is/fivefivefive/CanDis/               runners, compatibility facade, checks, reports
src/is/fivefivefive/CanDis/core/          parser-independent canonical-distance core
src/is/fivefivefive/CanDis/core/egraph/   six retained ablation representation engines
src/is/fivefivefive/CanDis/theory/        exact typed slotted-port e-graph and proofs
src/is/fivefivefive/CanDis/adapter/       Alloy adapters, including exact typed adaptation
src/is/fivefivefive/CanDis/canonical/     canonical equality, hashing, serialization, TED baseline
src/is/fivefivefive/CanDis/metric/        certified port of the established repair metric
src/is/fivefivefive/CanDis/ir/            MASG to canonical IR conversion
src/is/fivefivefive/AlloyDataProcessor/   corpus preprocessing utilities
classified-data/                          source student/oracle dataset
distance_results/                         paired-oracle metrics, JSON, CSV, plots, tables
alloy4fun-augmented/                       correct pools and nearest-repair rankings
egraph_ablation/                           current seven-arm natural-corpus evaluation
capability_benchmark/                      current seven-arm transformation benchmark
canonical_memory/                          worker-scaling and phase attribution
documentation/                             CanDis and rewrite-system references
scripts/                                   build and evaluation launchers
lib/                                       Alloy/parser and utility JARs
```

The reusable `CanDis.core` and `CanDis.core.egraph` packages depend only on
`java.base`. Parser and MASG integration remains in the adapter and IR layers.

## Requirements

- A full JDK 17 installation with `java`, `javac`, `jar`, and `jdeps`.
- Bash and standard Linux utilities for the supplied scripts.
- GNU `/usr/bin/time` for process-level ablation timing.
- Python 3 and Matplotlib only when regenerating plots.
- Dependency JARs under repository-root `lib/`; there is no Maven or Gradle
  build file.

Commands below assume a Unix classpath separator and run from the repository
root.

## Build and Test

Compile the complete project:

```bash
BUILD_DIR=/tmp/acgn-build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
find src -name '*.java' -print > /tmp/acgn-sources.txt
javac -cp 'lib/*' -d "$BUILD_DIR" @/tmp/acgn-sources.txt
export ACGN_CLASSPATH="$BUILD_DIR:lib/*"
```

Run the focused regression suite:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.CanonicalAlloyPipelineTest
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.metric.QuotientRepairDistanceTest
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.ablation.EGraphAblationTest
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.EGraphSaturationTest
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.CanonicalBacktranslatorTest
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.MASGVisitorTypeRegressionTest
```

Build the standalone JDK-only core and inspect its dependency boundary:

```bash
./scripts/build_candis_core.sh /tmp/candis-core
jdeps -summary /tmp/candis-core/candis-core.jar
```

The expected dependency summary is `candis-core.jar -> java.base`.

## Main Workflows

Use a fresh output directory for exploratory runs. The named result directories
below are checked-in snapshots and a full rerun overwrites them.

### Paired student-oracle distances

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.CanonicalBatchTest \
  classified-data distance_results \
  --threads 32 --skip-rewards
```

Use `--limit N` for a smoke run. The runner writes `distances.json` and
`summary.md`. Remove `--skip-rewards` and add `--reward-pool 10` for the
rewarded run. Regenerate its plotting
CSV, SVG/PNG figures, and paper tables with:

```bash
./scripts/regenerate_distance_artifacts.sh distance_results
```

### Augmented truth pools and nearest repairs

Start without rewards for the faster structural run:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.Alloy4FunAugmenter \
  classified-data alloy4fun-augmented \
  --threads 32 --skip-rewards
```

Remove `--skip-rewards` and add `--reward-pool 100` for the rewarded run. The
augmenter excludes student/oracle AST-identical files before parsing bodies into
canonical work items, before constructing groups, and before building truth
pools. On this corpus it fails fast unless the full selection invariant is
`66,080 - 4,482 = 61,598`.

Principal outputs are `index.json`, `summary.md`, per-question correct pools,
`correct_ast_diff_canonical_equiv.json`, nearest-repair rankings, AST-identity
audit CSVs, reward CSVs, and coverage/correlation SVGs.

### Seven-arm ablation

```bash
./scripts/run_egraph_ablation.sh \
  --input classified-data \
  --output egraph_ablation \
  --threads 32 --max-heap 3g
```

The suite runs all seven arms sequentially in fresh JVMs. The seventh is
`typed-slotted-port-egraph`, backed by the faithful graph and certified port of
the established metric in `CanonicalAlloyPipeline`; the `canonical` arm
continues to denote the legacy implementation with bounded rewrite saturation,
not an approximate repair metric. Each arm uses
`min(requested workers, logical processors, 32)` threads. A smoke run can add
`--limit 100` and use a `/tmp` output directory.

To regenerate combined reports without rerunning engines:

```bash
./scripts/run_egraph_ablation.sh \
  --input classified-data \
  --output egraph_ablation \
  --report-only
```

Report-only mode verifies per-arm output hashes and rejects incompatible
manifests. It also regenerates `canonical_only_vs_slotted.md`,
`minimum_distances.csv`, and `equivalence_disagreements.csv`.

### Capability and memory studies

```bash
./scripts/run_capability_benchmark.sh \
  --dataset classified-data \
  --output capability_benchmark \
  --natural egraph_ablation \
  --target 500 --seed 55520260811 \
  --threads 32 --max-heap 3g

./scripts/run_canonical_memory_attribution.sh \
  --input classified-data \
  --output canonical_memory \
  --limit 2000 --seed 55520260811
```

### Inspect and validate

Inspect all representations for one model:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.EGraphAblationInspector \
  classified-data/<problem>/<status>/<model>.als
```

Rerun bounded checks over every zero-distance claim:

```bash
java -cp "$ACGN_CLASSPATH" is.fivefivefive.CanDis.EGraphSemanticSoundnessCheck \
  --input classified-data --results egraph_ablation --threads 32
```

Smoke-test canonical-form backtranslation against the source predicates:

```bash
java -cp "$ACGN_CLASSPATH" \
  is.fivefivefive.CanDis.CanonicalBacktranslationEquivalenceTest \
  classified-data --limit 100 --scope 3 \
  --output /tmp/acgn-backtranslation/mismatches.json
```

## Dataset Convention

```text
classified-data/
  <problem-class>/
    CORRECT|BOTH|OVERCONSTRAINED|UNDERCONSTRAINED/
      <prefix>_<invariant-id>.als
```

The first path component identifies the question set, the second is the
semantic status, and the filename suffix identifies the attempted invariant.
Each file is expected to contain a student predicate `X` and oracle predicate
`XC` or `Xc`. `OVER` and `UNDER` directory labels are normalized to their full
names. Models are compared or pooled only within the same problem class and
invariant ID.

The current corpus spans 17 problem classes. Do not describe all 66,080 files
as evaluated pairs: 4,482 trivial raw-AST matches are deliberately excluded
from every current distance and ablation run.

## Reproducibility

The checked-in seven-arm natural-corpus snapshot records:

- run ID `cfe55f5d-daf6-4ae1-808e-3eaa863015a8`;
- source SHA `cc53042333fa3a1c820eb5715aa3b124e03d0ff1` with a dirty worktree;
- dataset SHA-256
  `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`;
- Java 17.0.19, 32 workers, a 3 GiB heap cap, rule set
  `canonical-equivalences-v2`, host/CPU metadata, schema versions, timestamps,
  and hashes of every generated arm and combined output.

The checked-in capability snapshot uses run ID
`dfd614b7-661d-4be6-8b46-6459e00809ad`, source SHA
`cc53042333fa3a1c820eb5715aa3b124e03d0ff1`, generated-dataset SHA-256
`e9901ba9e63a8090e0beb9d04d19bd66da3a7f49ca681ef6adf164e8ca6265f0`,
and the same v2 rule set. Its arm manifests and generated-report hashes are
anchored by the capability
[`run-manifest.json`](capability_benchmark/arms/run-manifest.json).

See [`run-manifest.json`](egraph_ablation/run-manifest.json). Because that
snapshot records a dirty worktree, the manifest's source and output hashes are
the authoritative provenance for its numbers; do not silently attribute them
to the repository's current `HEAD`.

## Interpretation and Limits

- Canonical zero is sound only relative to the implemented rewrite system; it
  is not complete for Alloy equivalence.
- Dataset `CORRECT` labels come from SAT-based classification and are not
  produced by the distance engine.
- Semantic validation is bounded by each model's command scope and temporal
  bounds. Absence of a counterexample is evidence, not proof.
- Zhang-Shasha, Levenshtein, canonical, and Rewarder values use different
  representations and should not be compared as if their units were identical.
- Rewarder uses finite instance pools. Pool size and cache state are part of the
  experimental configuration.
- Baseline-arm wall time is parser-heavy; the exact arm is dominated by
  certificate-bearing graph construction and orbit work. Structural byte
  estimates describe graph objects and are not substitutes for measured RSS.
- The ACGN learning/generation code is research infrastructure; some historical
  entry points, including the old RL frame, are retained for experiments rather
  than presented as a production API.

## Further Documentation

- [CanDis architecture, APIs, runners, and generated outputs](documentation/README.md)
- [Ordered rewrite system and side conditions](documentation/REWRITE_SYSTEM.md)
- [Phase I exact-engine integration, invariants, faults, and reproduction](docs/theory-phase-i-artifact-integration.md)
- [Paired-distance paper tables](distance_results/paper_tables.md)
- [Augmented dataset summary](alloy4fun-augmented/summary.md)
- [Current seven-arm ablation report](egraph_ablation/summary.md)
- [Targeted capability benchmark](capability_benchmark/REPORT.md)
- [Canonical memory attribution](canonical_memory/REPORT.md)

## License

This repository is available under the [MIT License](LICENSE).
