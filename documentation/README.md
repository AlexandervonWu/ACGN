# CanDis

CanDis constructs a temporal, prenex, typed slotted-port representation of Alloy
predicates and evaluates the established repair metric on its certified
semantic quotient. Canonical equality, deterministic representatives, and
repair distance are separate layers. The repository also contains dataset
runners, backtranslation, semantic checks, and a seven-arm ablation comparing
fixed-arity, De Bruijn, egglog-like, slotted, legacy-canonical, and exact
representations.

## Contents

- [Concepts](#concepts)
- [Current experimental snapshot](#current-experimental-snapshot)
- [Architecture](#architecture)
- [Canonicalization pipeline](#canonicalization-pipeline)
- [Canonical representation](#canonical-representation)
- [Rewrite theory](#rewrite-theory)
- [Canonical distance](#canonical-distance)
- [Java APIs](#java-apis)
- [Building and testing](#building-and-testing)
- [Dataset runners](#dataset-runners)
- [Ablation study](#ablation-study)
- [Targeted capability benchmark](#targeted-capability-benchmark)
- [Canonical memory attribution](#canonical-memory-attribution)
- [Generated outputs](#generated-outputs)
- [Interpretation and limits](#interpretation-and-limits)

## Concepts

CanDis compares an Alloy predicate with another predicate, normally a student
answer and an oracle answer for the same invariant question. The source path
passes through three representation levels:

1. **Raw AST:** parser nodes with source-level operators and identifiers.
2. **MASG/IR:** an augmented multigraph converted into temporal normal forms.
3. **Certified canonical form:** typed slotted-port semantic state, a
   deterministic equality observation, and a repair view preserving source edit
   units.

The full distance is structural. It is designed to assign zero cost to the
implemented equivalence theory, including alpha-equivalence, declaration
permutations, ACI operators, De Morgan rewrites, connective elimination, and
selected quantifier rewrites.

`distance == 0` means equality under that implemented theory. It is not a
complete theorem prover for arbitrary Alloy semantics.

## Current Experimental Snapshot

The August 17, 2026 snapshot uses 66,080 source files. Every runner excludes
4,482 student-oracle pairs with identical parser ASTs before pool construction,
leaving 61,598 eligible pairs: 19,212 `CORRECT` and 42,386 incorrect.

| Evaluation | Headline result |
| --- | --- |
| Paired student-oracle (`pipeline-v9`, metric v4) | 61,598 successes, 0 failures; mean certified repair distance 14.014010; 2,317 `CORRECT` zeroes; 0 incorrect zeroes |
| Nearest correct pool (`pipeline-v10`, metric v5) | 42,386 incorrect predicates ranked, 0 failures; mean nearest certified distance 10.865050 |
| Truth-pool diversity | 19,393 oracle-plus-student truths, 4,496 AST-distinct truths, 2,318 canonical components, 10,257 AST-different zero-distance truth pairs |
| Seven-arm natural corpus | exact arm retained 2,316 legacy-canonical zeroes and added 1; both canonical arms had 0 incorrect zeroes |
| Generated capability matrix | slotted, legacy-canonical, and exact arms recovered 5,500/5,500 pairs; all 11 expected capability boundaries matched |

The exact arm averaged 29.830 representation units, 20.935 reachable e-classes,
and 18.059 reachable e-nodes, but required 2,303.890 seconds wall time versus
18.470 seconds for the legacy canonical arm. Maximum RSS was 3,603.680 versus
3,529.023 MiB. Its cost is dominated by certificate-bearing construction,
renaming-orbit search, strict invariant checks, rebuild, and finite unfolding,
not by larger output terms or the final repair-distance recurrence.

The ablation and capability manifests record a dirty source tree at Git SHA
`cc53042333fa3a1c820eb5715aa3b124e03d0ff1`. Their source, dataset, and output
hashes are the exact provenance for these results; a clean tagged rerun remains
a release task.

## Architecture

### Dependency boundary

The reusable implementation is JDK-only:

```text
is.fivefivefive.CanDis.core
  CanonicalDistance          temporal + binding + matrix distance
  NormalForm                 one prenex matrix for one temporal phase
  QuantiVar                  canonical quantified binding tuple
  EGraphNode                 production slotted e-node/e-class representation
  RenamedIdUnionFind         renamed-ID congruence structure
  SlotPermutationGroup      finite binding permutation groups

is.fivefivefive.CanDis.core.egraph
  AlloyTerm                  immutable parser-independent term
  RawEGraph                  fixed-arity baseline
  RawDeBruijnEGraph          fixed-arity baseline with nameless binders
  JavaEgglog                 variadic egglog-like baseline
  JavaEgglogDeBruijn         variadic baseline with nameless binders
  SlottedEGraph              renamed-slot baseline
  DeBruijnVariables          scoped nearest-binder encoding
  AlloyRewriteSystem         shared ablation rewrite program
```

The core JAR depends only on `java.base`. Alloy and parser integration remains
outside the core:

```text
is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter
  parser AST -> AlloyTerm

is.fivefivefive.CanDis.ir.IRAgent
  MASG -> NormalForm + EGraphNode

is.fivefivefive.CanDis.Canonical
  compatibility facade for Multigraph callers
```

The main source locations are:

- [`core`](../src/is/fivefivefive/CanDis/core/)
- [`core.egraph`](../src/is/fivefivefive/CanDis/core/egraph/)
- [`IRAgent`](../src/is/fivefivefive/CanDis/ir/IRAgent.java)
- [`Canonical` facade](../src/is/fivefivefive/CanDis/Canonical.java)
- [`CanonicalBacktranslator`](../src/is/fivefivefive/CanDis/CanonicalBacktranslator.java)

The complete ordered rule inventory and its side conditions are collected in
[`REWRITE_SYSTEM.md`](REWRITE_SYSTEM.md).

## Canonicalization Pipeline

CanDis applies the following sequence independently within each temporal phase:

1. **Parse and graph construction.** `MASGVisitor` converts the Alloy model into
   one `Multigraph` per predicate or callable.
2. **IR skeleton.** `IRAgent` converts the selected graph into e-nodes and splits
   temporal operands into child `NormalForm` objects.
3. **Structural cleanup.** Internal `<END>` nodes and unary `NOOP` wrappers are
   removed from normal-form matrices.
4. **Alpha normalization.** Bound identifiers receive scope-aware canonical slot
   names. Original source names remain attached for readable edit paths.
5. **Let beta reduction.** `let` expressions are substituted with
   capture-avoidance.
6. **Branch-connective elimination.** Implication, IFF, and formula ITE are
   rewritten before prenexing.
7. **NNF conversion.** Negations are pushed through boolean, atomic, temporal,
   and quantified formulas using their dual operators.
8. **Per-phase prenexing.** Prenexable formula quantifiers are pulled to the
   front of the current temporal phase. Quantifiers never cross a temporal
   boundary.
9. **Binding normalization.** Each binding retains a primitive carrier type,
   quantifier, cardinality, and disjointness class. A complex domain is moved
   into the matrix as an `in` constraint. A domain equal to its primitive
   carrier does not produce a redundant membership constraint.
10. **Second NNF pass.** Constraints introduced by prenexing are normalized with
    the matrix.
11. **Variadic normalization.** Associative children are flattened; AC/ACI
    operands are sorted; SET operators remove duplicates while BAG operators
    preserve multiplicity.
12. **E-saturation.** Local equivalence rules, e-class unions, slot redundancy,
    and permutation groups are applied to a fixed point.
13. **Preparation.** `CanonicalDistance.prepare` records temporal structure,
    canonical size, and reusable e-class metadata for repeated comparisons.

Binary temporal operators retain left/right phase identifiers internally, such
as `UNTILL` and `UNTILR`. The temporal distance reconstructs the natural
operator (`UNTIL`, `RELEASES`, `SINCE`, or `TRIGGERED`) before comparison.

## Canonical Representation

### Temporal normal forms

Every temporal phase has:

```text
NormalForm := TemporalOp x BindingList x MatrixEGraph x TemporalChildren
```

No formula quantifier is moved between temporal phases. Ancestor bindings may
remain visible to descendants, but ownership stays with the phase where the
binding was introduced.

### Quantified variables

Each `QuantiVar` records:

```text
(slot, originalName, quantifier, cardinality, carrierType,
 disjointnessClass, bindingPath)
```

The relevant quantifiers are `ALL`, `SOME`, `NO`, `ONE`, `LONE`, `NOTONE`,
`NOTLONE`, `SUM`, and `COMPREHENSION`. Cardinalities are `SET`, `SOME`, `ONE`,
`LONE`, and `EXACTLY`.

Disjointness is represented by an integer class, not one global boolean. Thus
two declarations such as `all disj x1,x2:S` and `some disj x3,x4:S` remain two
independent disjointness groups.

Bindings with the same symmetric quantifier signature form finite permutation
groups. For example, after alpha normalization:

```alloy
all x, y: S | f[x, y]
all x, y: S | f[y, x]
```

compare at distance zero when the declaration permits the slot permutation.

### Flexible arity

CanDis uses three flexible-arity semantics:

| Operators | Status | Representation |
| --- | --- | --- |
| `and`, `or`, relational `+`, relational `&` | ACI | `SET` |
| arithmetic `+`, arithmetic `*` | AC | `BAG` |
| relational join `.`, relational arrow `->` | A | `SEQUENCE` |

- **SET** means associative, commutative, and idempotent. Children are flattened,
  sorted, and deduplicated.
- **BAG** means associative and commutative. Children are flattened and sorted,
  but duplicate e-class invocations are retained.
- **SEQUENCE** means associative and order-sensitive. Children are flattened in
  source order.

Calls, declaration lists, comprehensions, and other structural variadic nodes
remain variadic but do not automatically acquire A, AC, or ACI semantics.

### Canonical size

The canonical representation size is:

```text
#normal forms
+ sum(matrix e-graph size for each normal form)
+ sum(quantified bindings for each normal form)
```

Dataset summaries compare this size with raw AST size and lexical body length.

## Rewrite Theory

The ablation baselines share the terminating rule set
`canonical-equivalences-v2`. The production canonicalizer applies the same main
equivalences while additionally performing temporal partitioning, strict
per-phase normalization, primitive binding extraction, and slot symmetries.

### Connectives and NNF

```text
A implies B             -> not A or B
A iff B                 -> (not A or B) and (not B or A)
if A then B else C      -> (A and B) or (not A and C)
not not A               -> A
not (A and B)           -> not A or not B
not (A or B)            -> not A and not B
not true / not false    -> false / true
```

Atomic comparison and membership operators are rewritten to their negation
duals: `=`/`!=`, `in`/`not in`, `>`/`<=`, `>=`/`<`.

### Temporal negation

```text
not always A            -> eventually not A
not eventually A        -> always not A
not historically A      -> once not A
not once A              -> historically not A
not (A until B)         -> (not A) releases (not B)
not (A releases B)      -> (not A) until (not B)
not (A since B)         -> (not A) triggered (not B)
not (A triggered B)     -> (not A) since (not B)
```

### Quantifier negation and empty domains

```text
not (all x:S | P)       -> some x:S | not P
not (some x:S | P)      -> all x:S | not P
not (no x:S | P)        -> some x:S | P
not (one x:S | P)       -> notone x:S | P
not (lone x:S | P)      -> notlone x:S | P
no x:S | P              -> all x:S | not P
```

The inverse negations of `NOTONE` and `NOTLONE` produce `ONE` and `LONE`.
Over `none`, `ALL`, `NO`, `LONE`, and `NOTONE` are true; `SOME`, `ONE`, and
`NOTLONE` are false.

The shared ablation rules also fold domain-independent constant bodies:
`all x:S | true`, `no/lone/notone x:S | false` become true, while
`some/one/notlone x:S | false` become false. Results that depend on whether `S`
is empty remain quantified.

Safe prenex rules require that the moved binding is not free in the other
operand:

```text
(some x:S | P) and Q    -> some x:S | P and Q
(all x:S | P) or Q      -> all x:S | P or Q
```

### Identities and annihilators

```text
A and A                 -> A
A or A                  -> A
R + R                   -> R
R & R                   -> R
A and true              -> A
A or false              -> A
A and false             -> false
A or true               -> true
A and not A             -> false
A or not A              -> true
x in none               -> false
x in univ               -> true
R + none                -> R
R & none                -> none
```

`let` beta reduction is capture-avoiding. Operator aliases and source-specific
AST opcodes are canonicalized before these rules are compared.

## Canonical Distance

`CanonicalDistance` is the repair-metric specification. The three-layer
pipeline preserves this edit algebra while replacing uncertified scope
assumptions with faithful binder and operator certificates. Canonical
representative TED is reported separately and is not this metric.

For prepared forms `L` and `R`:

```text
D(L, R) = D_temporal + D_bindings + D_matrix
```

### Temporal component

`D_temporal` is an ordered rooted-tree edit distance over temporal phases.
Insertion and deletion cost the size of the affected temporal subtree; changing
one temporal operator costs one.

### Binding component

`D_bindings` aligns each phase's canonical binding list using dynamic
programming:

- insert binding: `1`
- delete binding: `1`
- modify quantifier, primitive type, cardinality, or disjointness class: `1`
- alpha-renaming alone: `0`

Symmetric `ALL` and `SOME` groups are canonically ordered by their binding tuple.

### Matrix component

`D_matrix` computes a minimum unit-cost rooted edit distance over saturated
matrix representatives. Pairwise alpha alignment enumerates every
maximum-cardinality partial variable mapping admitted by an order-preserving
matching of certified scope blocks. Ordered children use sequence DP;
commutative, Bag, and Set children use minimum-cost assignment. A node
replacement costs one; subtree insertion and deletion cost their canonical
node counts.

The mapping is chosen once per binder owner across the complete aligned phase
family. Temporal descendants reuse that choice for inherited coordinates, so a
parent implication and its `eventually` child cannot silently choose different
alpha permutations. A changed declaration may retain the same owner-coordinate
alignment, ensuring that one quantifier-tuple modification still costs one.

Prenex bindings and local expression binders use different certified coordinate
maps. Local comprehensions and sums are compared over their own descriptor
automorphism groups, with depth-qualified coordinates preventing accidental
capture. Fixed commutative operators such as equality and inequality expose a
two-operand Bag port; this permits exchange without claiming associativity.
Named non-temporal references also remain semantic atoms: for example,
`ordering/first` and `ordering/last` have distinct exact signatures.

`Canonical.edits` emits a readable edit path. It uses temporal labels such as
`left branch of UNTIL` and source variable names where available, while the
distance calculation continues to use alpha-canonical slots.

## Java APIs

### Multigraph compatibility facade

Use the facade when the caller already has MASG `Multigraph` objects:

```java
import is.fivefivefive.CanDis.Canonical;

Canonical.Prepared left = Canonical.prepare(leftGraph);
Canonical.Prepared right = Canonical.prepare(rightGraph);

int distance = Canonical.distance(left, right);
int size = Canonical.canonicalFormSize(left);
List<String> edits = Canonical.edits(left, right);
List<String> formulas = Canonical.irTemporalFol(left);
```

Preparation is reusable and should be cached when one predicate is compared
against many references.

### Parser-independent canonical API

Use the core API with normalized `NormalForm` lists:

```java
import is.fivefivefive.CanDis.core.CanonicalDistance;

CanonicalDistance.Prepared left = CanonicalDistance.prepare(leftNormalForms);
CanonicalDistance.Prepared right = CanonicalDistance.prepare(rightNormalForms);
int distance = CanonicalDistance.distance(left, right);
```

### Parser-independent e-graph baselines

```java
import is.fivefivefive.CanDis.core.egraph.AlloyTerm;
import is.fivefivefive.CanDis.core.egraph.AblationEngine;
import is.fivefivefive.CanDis.core.egraph.SlottedEGraph;

AlloyTerm a = AlloyTerm.atom("VAR", "a");
AlloyTerm b = AlloyTerm.atom("VAR", "b");
AlloyTerm formula = AlloyTerm.node("BF/AND", a, b);
AlloyTerm permuted = AlloyTerm.node("BF/AND", b, a);

AblationEngine.Result result = new SlottedEGraph().compare(formula, permuted);
```

For parser AST nodes, use `AlloyAstTermAdapter.fromPredicate` rather than adding
parser dependencies to `AlloyTerm`.

### Backtranslation

`CanonicalBacktranslator` emits Alloy predicate text from one normal form or a
temporal normal-form list. Local relational comprehensions are emitted as
`{decls | formula}`, including when nested below closure. Regression tests
compile the emitted predicate with the Alloy parser. Backtranslation is
intended for validation and inspection; the original source formatting is not
preserved.

## Building And Testing

The repository currently uses direct `javac` commands and the JARs in `lib/`.
Java 17 is the tested runtime.

### Full project

```bash
BUILD=/tmp/acgn-build
rm -rf "$BUILD"
mkdir -p "$BUILD"
javac -cp 'lib/*' -d "$BUILD" $(find src -name '*.java')
```

### Standalone core JAR

```bash
./scripts/build_candis_core.sh
jdeps -summary build/candis-core/candis-core.jar
```

The expected dependency summary is:

```text
candis-core.jar -> java.base
```

An alternate output directory can be passed as the first argument:

```bash
./scripts/build_candis_core.sh /tmp/candis-core
```

### Fast regressions

After compiling the full project into `$BUILD`:

```bash
java -cp "$BUILD:lib/*" is.fivefivefive.CanDis.ablation.EGraphAblationTest
java -cp "$BUILD:lib/*" is.fivefivefive.CanDis.EGraphSaturationTest
java -cp "$BUILD:lib/*" is.fivefivefive.CanDis.CanonicalBacktranslatorTest
java -cp "$BUILD:lib/*" is.fivefivefive.CanDis.MASGVisitorTypeRegressionTest
```

The first two tests can also be compiled and run against only the standalone
core JAR.

## Dataset Runners

### Canonical batch comparison

`CanonicalBatchTest` compares each selected student predicate with its paired
oracle, computes lexical, raw-AST, and canonical distances, optionally evaluates
rewards, and writes JSON plus Markdown statistics.

The unqualified canonical fields use the Phase I `CanonicalAlloyPipeline`
backed by the exact `TypedSlottedPortEGraph` and the certified port of the
established metric. Direct legacy-execution values remain in explicit
`legacyCanonical*` fields as differential evidence; readable edit paths remain
`legacyDiagnostic*`.

```bash
java -cp "$BUILD:lib/*" is.fivefivefive.CanDis.CanonicalBatchTest \
  classified-data distance_results \
  --threads 32 --skip-rewards
```

Options:

| Option | Meaning |
| --- | --- |
| first positional path | input dataset, default `classified-data` |
| second positional path | output directory, default `distance_results` |
| `--threads N` | file workers, default `32` |
| `--reward-pool N` | reward instance-pool size, default `10` |
| `--skip-rewards` | produce structural results without running Rewarder |
| `--limit N` | process only the first `N` files |
| `--verbose` | print individual failures and progress |

### Alloy4Fun augmentation

`Alloy4FunAugmenter` groups attempts by problem class and invariant identifier,
places the oracle and AST-distinct correct student answers into one co-equal
reference pool, ranks every incorrect answer against every correct reference,
and writes an augmented research dataset.

Canonical pool equivalence and nearest-reference ranking use the exact Phase I
pipeline. The legacy canonical ranking is retained in one shared comparison
pass for compatibility.

Before constructing any question group or truth pool, it removes files whose
student predicate and paired oracle predicate have identical raw ASTs. On the
current full corpus this partitions 66,080 source files into 4,482 excluded
trivial pairs and 61,598 files considered by every downstream pool, ranking,
and statistic. Excluded paths are retained in
`ast_identical_predicate_pairs.csv` for auditing.

```bash
java -cp "$BUILD:lib/*" is.fivefivefive.CanDis.Alloy4FunAugmenter \
  classified-data alloy4fun-augmented \
  --threads 32 --reward-pool 100
```

Additional options are `--skip-rewards`, `--audit-only`, `--limit N`, and
`--verbose`.

The augmenter stores compact certified comparison values after construction:
canonical equality and repair distance retain the same observation and repair
view, while construction-only graph witnesses are released. Faithful graph
construction is memory-bounded independently of parser and distance workers.
The progress line reports both values; for example, `--threads 32` under
`-Xmx2g` currently selects four canonical builders. The builder count is capped
at 16 and reduced further when the configured maximum heap is smaller.

Strict-kernel failures report the incorrect source, truth reference, both
canonical digests, and temporal/quantifier/matrix components. The current
pool-100 rewarded full-corpus run completes all 61,598 eligible models and
42,386 incorrect rankings with no parse, strict-kernel, or reward failure.

The runners skip raw-AST-identical predicate pairs where configured. Dataset
labels are read from the problem-class and correctness directories. Correctness
labels include `CORRECT`, `OVERCONSTRAINED`, `UNDERCONSTRAINED`, and `BOTH`, with
case-normalization handled by dataset conventions.

All corpus-scale runners emit bounded progress checkpoints with completed and
total work, throughput, and ETA. If no task completes for 30 seconds, they emit
a heartbeat with the number of tasks still in flight. This applies to batch and
augmentation stages, individual ablation arms and their process-isolated suite,
memory attribution, capability generation/reporting and bounded soundness,
semantic-soundness claims, and backtranslation equivalence checks. Parallel
collectors report completion order while retaining source order in generated
artifacts.

## Ablation Study

The ablation suite compares seven process-isolated arms:

1. `raw-egraph`: fixed-arity e-graph plus the shared rewrite program.
2. `raw-egraph-debruijn`: the fixed-arity arm with bound variables stored as
   nearest-binder De Bruijn indices.
3. `java-egglog`: variadic egglog-like saturation and rebuilding.
4. `java-egglog-debruijn`: the variadic arm with De Bruijn variable storage.
5. `slotted-egraph`: renamed slots, slot redundancy, and permutation groups.
6. `canonical`: temporal partitioning, per-phase prenexing, binding tuples, and
   bounded rewrite saturation around the reference metric implementation.
7. `typed-slotted-port-egraph`: complete `CanonicalAlloyPipeline` adaptation,
   certified exact graph insertion/rebuild, and finite-term observation.

The two De Bruijn arms retain named terms as capture-safe rewrite witnesses and
freshly encode each retained witness before hash-consing, e-class comparison,
and edit-distance measurement. This keeps the rewrite rules identical while
ensuring that prenex movement cannot capture a stale relative index.

Run the full corpus with:

```bash
./scripts/run_egraph_ablation.sh \
  --input classified-data \
  --output egraph_ablation \
  --max-heap 3g
```

All arms receive the same worker count. The effective policy is:

```text
min(requested threads, logical processors, 32)
```

Every arm writes a manifest containing the run ID, Git/source state, dataset
fingerprint, rule/schema versions, JVM and heap, worker count, host/CPU details,
start time, exact-engine/invariant/certificate/canonicalizer/bound settings,
and output hashes. The suite rejects a combined report unless all seven
manifests describe the same run context and every retained arm output still
matches its recorded hash. Useful options are `--limit N`, `--threads N`,
`--verbose`, and `--report-only`. `--report-only` verifies those manifests and
regenerates all combined reports, including the canonical-only/slotted report,
without rerunning the engines.

### Ablation interpretation

The report includes:

- process wall time, process CPU, worker engine CPU, peak heap, and maximum RSS
- equivalent-pair coverage by dataset label
- minimum edit distances for all seven representations
- pair-level transitions isolating De Bruijn encoding, variadic representation,
  slots, and full canonicalization
- semantically labeled equivalent discoveries per wall second, CPU second, and
  GiB of maximum RSS

A "found semantic equivalent" in the efficiency table is a zero-distance pair
whose dataset label is `CORRECT`. It uses the dataset's existing SAT-validated
label and does not rerun the SAT solver during the ablation.

The current full-corpus result is:

| Arm | `CORRECT` zeroes | Mean distance | Wall s | Engine CPU s | Max RSS MiB |
| --- | ---: | ---: | ---: | ---: | ---: |
| `raw-egraph` | 823 | 18.390 | 18.260 | 4.517 | 933.320 |
| `raw-egraph-debruijn` | 2,163 | 17.923 | 16.580 | 5.289 | 864.070 |
| `java-egglog` | 823 | 17.996 | 16.400 | 4.094 | 874.352 |
| `java-egglog-debruijn` | 2,163 | 17.530 | 16.630 | 4.997 | 915.074 |
| `slotted-egraph` | 2,162 | 17.694 | 17.390 | 14.642 | 936.621 |
| `canonical` | 2,316 | 14.029 | 18.470 | 13.255 | 3,529.023 |
| `typed-slotted-port-egraph` | 2,317 | 14.042 | 2,303.890 | 47,451.149 | 3,603.680 |

All arms completed all 61,598 eligible pairs with zero failures and zero
incorrect zero-distance merges. Pair-level transitions show `+1/-0` from
legacy canonical to exact. The exact arm's p50 and p95 engine latencies were
555.391 and 4,394.306 ms. Consult the generated report for per-pair transitions,
representation counts, and process metadata rather than copying this summary
into a paper table by hand.

## Targeted Capability Benchmark

`CapabilityBenchmark` is a deterministic companion experiment for all seven
arms. It embeds small equivalence-by-construction
formula pairs into real zero-parameter predicates selected from Alloy4Fun
`CORRECT` files. Families isolate alpha-renaming, ACI, same-block binder
permutations, scope-safe prenexing, logical/negation normalization, temporal
normalization, and compositions of those transformations.

```bash
./scripts/run_capability_benchmark.sh \
  --dataset classified-data \
  --output capability_benchmark \
  --target 500 --seed 55520260811 \
  --threads 32 --max-heap 3g
```

Generation compiles every model, rejects parser-AST-identical pairs, deduplicates
formula pairs, and records rejection reasons. The generated assertion documents
the intended equivalence; the benchmark ground truth comes from the recorded
sound rewrite and its side condition, not from the source file's dataset label.
The report preserves every expected-boundary miss in
`unexpected_failures.csv`, plus pair-level distances, family recovery, arm
transitions, CPU/wall costs, representation proxies, and natural-corpus context.
The launcher also executes one deterministic scope-4 SAT check per transformation
subtype by default (`--soundness-per-subtype N`) and labels that evidence as a
bounded sanity check rather than proof.

In the current 5,500-pair run, raw and Java egglog each recovered 47.00%; their
De Bruijn variants recovered 65.96%; and slotted, legacy-canonical, and exact
each recovered 100.00%. Every expected first-capable boundary matched. The 29
bounded checks had zero conclusive non-temporal failures; six temporal checks
remain explicitly inconclusive because no temporal backend was available.

Principal outputs are `metadata.{json,csv}`, `skips.csv`, `results.{json,csv}`,
`pair_results.csv`, `transitions.csv`, `unexpected_failures.csv`, `REPORT.md`,
`soundness.{json,csv}`, `SOUNDNESS.md`, and the normal seven-arm directories under
`arms/`.

## Canonical Memory Attribution

`CanonicalMemoryAttribution` adds opt-in, no-op-by-default observations at the
temporal skeleton, normalization, preparation, and comparison boundaries. It
also counts canonical edit-distance DP arrays. Ordinary canonicalization does
not invoke explicit GC. The launcher runs an identical deterministic subset at
multiple worker counts in fresh JVMs and performs a clearly separated post-run
diagnostic GC only after timed work and artifact serialization.

```bash
./scripts/run_canonical_memory_attribution.sh \
  --input classified-data \
  --output canonical_memory \
  --limit 2000 --seed 55520260811 \
  --workers 1,8,32 --max-heap 3g
```

Each worker directory contains `pairs.csv`, `phase_events.csv`,
`heap_samples.csv`, `phase_summary.csv`, `metrics.json`, `process.time`, and
`run.log`. The combined `REPORT.md`, `results.json`, and `phase_summary.csv`
compare wall/CPU/RSS/heap scaling and verify that all worker counts produced the
same pair results. Process heap is global; concurrent phase samples are
attribution evidence and structural counts are implementation proxies, not a
substitute for an object-layout profiler.

## Generated Outputs

### `distance_results/`

- `distances.json`: pair-level distances, sizes, formulas, edits, and reward data
- `summary.md`: aggregate raw/relative distances, compression, repair radii, and
  correlations
- CSV/SVG artifacts: plotting inputs and generated visualizations
- `paper_tables.md` and `paper_metrics.json`: reproducible paper-table extracts
  pinned to the source summary hash

Regenerate all plotting data, PNG/SVG figures, and paper-table extracts with:

```bash
./scripts/regenerate_distance_artifacts.sh distance_results
```

### `alloy4fun-augmented/`

- `index.json`: question groups, reference pools, incorrect attempts, and full
  rankings under Levenshtein, raw AST, and canonical distance
- `correct/<problem>/<invariant>.als`: AST-distinct correct pools including the
  oracle
- `summary.md`: corpus, reference diversity, minimum-distance, repair-radius,
  reward, and compression statistics
- `correct_ast_diff_canonical_equiv.json`: AST-different correct references that
  share a canonical form
- CSV/SVG artifacts: reward and repair-coverage analyses

### `egraph_ablation/`

- `summary.md`: human-readable ablation comparison
- `comparison.json`: machine-readable run and transition metrics
- `minimum_distances.csv`: per-pair distance under every arm
- `equivalence_disagreements.csv`: zero-equivalence differences among arms
- `canonical_only_vs_slotted.md`: canonical-only equivalences generated from
  the same verified arm outputs
- `run-manifest.json`: combined context and hashes of every generated output
- `<arm>/pairs.csv`: pair-level results for one arm
- `<arm>/metrics.properties`: compact run metrics and worker count
- `<arm>/summary.json`: grouped run details
- `<arm>/manifest.json`: arm context plus output hashes

### `capability_benchmark/`

- `REPORT.md`: family-by-arm recovery, capability boundaries, transitions, and costs
- `metadata.{json,csv}`: seeds, source hashes, formulas, transformations, side conditions, and AST sizes
- `pair_results.csv`: every generated pair's distance and zero status under all seven arms
- `unexpected_failures.csv`: expected-boundary misses retained for inspection
- `soundness.{json,csv}` and `SOUNDNESS.md`: bounded subtype checks, including inconclusive temporal evidence
- `arms/`: ordinary process-isolated seven-arm output for the generated corpus

### `canonical_memory/`

- `REPORT.md` and `results.json`: worker-scaling and retention diagnosis
- `phase_summary.csv`: combined begin/end phase timing and heap-delta proxies
- `workers-{1,8,32}/`: identical deterministic selections with pair results, raw phase/heap samples, JVM metrics, and GNU time/RSS output

## Interpretation And Limits

- CanDis canonicalization is a terminating, implementation-defined equivalence
  theory, not complete Alloy semantic equivalence.
- A zero distance outside `CORRECT` is treated as a potential soundness defect and
  should be investigated with `EGraphSemanticSoundnessCheck`.
- A positive distance for a `CORRECT` pair indicates incomplete normalization,
  not semantic inequivalence.
- Quantifiers are prenexed only where movement is scope-safe and only within one
  temporal phase.
- Alpha-equivalence uses canonical slots internally; readable edit paths use
  retained source names when possible.
- BAG multiplicity is semantically significant. Duplicate removal is limited to
  operators explicitly classified as ACI/SET or to proven tautological rules.
- Both canonical arms peak near 3.5 GiB RSS versus roughly 0.9 GiB for the first
  five baselines. The exact arm's principal penalty is CPU and latency, not
  additional output units: certificates, orbit witnesses, immutable mutation
  records, strict invariant checks, and finite unfoldings are construction
  state rather than repair-observation nodes.
- Batch reward values depend on the sampled Alloy instance pool and are not
  semantic proofs.

For implementation-level invariants, the fastest executable references are
`EGraphSaturationTest` and `EGraphAblationTest`. For end-to-end translation,
`CanonicalBacktranslatorTest` and `MASGVisitorTypeRegressionTest` cover the
adapter boundary.
