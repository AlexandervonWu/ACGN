# Phase I Artifact Integration

## Scope

Phase I connects the Alloy experiment layer to the exact implementation built
in Phases B-H. The integration is additive: the bounded legacy canonicalizer
and all earlier ablation engines remain available under explicit names. The
primary `canonical` measurements in `CanonicalBatchTest` and
`Alloy4FunAugmenter` now come from `CanonicalAlloyPipeline`; their legacy
counterparts are emitted as `legacyCanonical*` diagnostics.

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
  -> normalized finite-term key modulo certified laws
  -> CanonicalAlloyPipeline equality and semantic edit projection
```

`CanonicalAlloyPipeline` is the experiment-facing facade. Exact equality and
SHA-256 digests use the complete normalized finite-term key. Edit distance uses
an injective semantic projection that keeps operator, type, binder, container,
and certificate/schema information in node labels while counting only semantic
term nodes as edit units. Thus distance zero is still exactly full-key equality;
proof metadata is not accidentally priced as a repair operation.

## Integrated Clients

| Client | Phase I behavior | Compatibility behavior |
| --- | --- | --- |
| `CanonicalBatchTest` | Exact distance, size, digest, graph counts, and phase timings are primary | Legacy distance, size, and diagnostic edits remain separate JSON/Markdown fields |
| `Alloy4FunAugmenter` | Correct-pool equivalence and nearest canonical ranking use the exact prepared form | Legacy canonical ranking and ratios are emitted in the same pass; `--skip-rewards` avoids Rewarder work |
| `EGraphAblationSuite` | Adds `typed-slotted-port-egraph` as a seventh arm | The six historical arms retain their implementations and identifiers |
| `CapabilityBenchmark` | Runs the exact seventh arm through all generated families and composed cases | Historical arm columns remain available for transition analysis |
| `AblationRunManifest` | Schema v2 records and checks the complete Phase I engine configuration | Report-only mode rejects incompatible or modified arm outputs |

The exact arm is selected directly with
`--engine typed-slotted-port-egraph`; aliases `exact`, `theory`, and
`typed-slotted-port` are accepted for interactive use.

## Preserved Invariants

| Boundary | Executable invariant |
| --- | --- |
| Temporal normalization | Every listed phase is reachable exactly once; binary temporal halves are paired; binders never cross a phase boundary |
| Variable identity | Source names are lookup aids only; typed bound coordinates and complete descriptors determine alpha-equivalence |
| Binder permutation | A generator is issued only for adjacent coordinates with equal type, domain, quantifier, cardinality, and disjointness class; `BinderBlockDescriptor.certified` verifies it |
| Flexible arity | `SEQ`, `BAG`, and `SET` become certified A, AC, and ACI ports respectively; Bag multiplicity and Seq order are preserved |
| Construction | Every exact node is narrowed to exact support and enters through `TypedSlottedPortEGraph.insertNode` |
| Equality provenance | Exact unions, symmetries, restrictions, collisions, and rebuild steps remain certificate-bearing; preprocessing never calls an uncertified exact mutation |
| Administrative state | Reads occur only at quiescence; rebuild has no rewrite-round cap and strict invariants run after every adapter transition |
| Observation | The finite-unfolding family must be current and complete within its explicit bound; no cutoff leaf is invented |
| Equality versus distance | Full finite-term keys define equality; the distance projection is injective in all elided schema/proof subtrees |
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
| I-F06 | A direct tree metric counted certificate and schema implementation nodes as user-visible repairs | Add the injective semantic measurement projection while retaining the full key for equality and digesting |
| I-F07 | Recursive distance repeatedly hashed complete structural trees and revisited identical subproblems | Cache structural hashes and subtree sizes, use identity fast paths, and memoize prepared-pair comparisons |
| I-F08 | The experiment harness had no exact arm and manifests could not identify certificate/invariant modes | Add the seventh arm and manifest schema `candis-ablation-manifest-v2` / output schema `candis-ablation-output-v4` |
| I-F09 | Batch and augmentation smoke runs were coupled to Rewarder and its instance pools | Add `--skip-rewards`; structural outputs remain complete and rewarded reruns stay available |
| I-F10 | Legacy diagnostic edit paths could be mistaken for the new exact distance | Rename them to `legacyDiagnostic*` / `legacyCanonical*` and identify both engines in generated metadata |
| I-F11 | Augmentation ranking and correct-pool worker exceptions were swallowed, allowing partial structural reports to look complete | Structural worker interruption or failure now aborts report publication with the original cause; Rewarder failures remain explicit per-record observations |

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

The Phase I build and focused checks completed on 2026-08-16:

- all sources compile against `lib/*`;
- `CanonicalAlloyPipelineTest`: 38 checks covering typed adaptation,
  same-descriptor permutation, shadow-safe alpha-equivalence, ACI, descriptor
  discrimination, temporal separation, negative discrimination, statistics,
  digest shape, and determinism;
- Phases B-H: 18,520 deterministic checks unchanged;
- `EGraphAblationTest`: passed;
- 100-file batch smoke: 100 successes and 0 failures;
- 100-file augmentation smoke: 100 ranked predicates, 99 unique prepared
  representations, and 0 failures with rewards disabled;
- two-file seven-arm ablation and hash-checked report-only regeneration:
  passed;
- target-one capability smoke: the exact arm recovered all 11/11 generated
  families and all 8/8 composed cases with 0 errors and 0 false negatives;
- bounded capability soundness sample: 11 checks and 0 failures.

These are integration checks, not replacement full-corpus measurements. The
historical six-arm result directories remain historical until a new seven-arm
archival run is completed from a clean commit.

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
  --threads 32 --skip-rewards

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
