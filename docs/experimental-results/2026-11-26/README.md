# Recovery of the original slotted zero pairs

On all **61,598** AST-distinct student/oracle comparisons, the original slotted
e-graph found **2,228** correct zero-distance pairs. Fast Rewrite and
Certificate-Integrated each retained every one and recognized **2,271
additional correct pairs**, for **4,499** each. Neither path merged any of the
42,386 incorrect pairs. Their numerical distances agreed on all 61,598 files.
The cohort includes 19,212 correct pairs. The 4,482 AST-identical files in the
66,080-file corpus were outside this comparison.

The pre-repair Fast and original slotted replays each reproduced every
distance in the published v3.1 matrix. The repair retained all 4,413 earlier
canonical zeros and gained 86. The gains comprised 42 socialMedia/inv8 pairs,
39 trainStationNew/inv8 pairs, two coursesNew/inv11 pairs, two cv_v1/inv1
pairs and one cv_v2/inv1 pair. On every gain, the original Alloy
`check correct` selected the recorded predicates and yielded UNSAT at its
recorded bounds. Of the 2,129 numerical distances that changed, 1,266
decreased and 863 increased. Across the entire corpus, the repaired numerical
distance was smaller than the slotted distance on 36,832 pairs, equal on 10,447
and larger on 14,319. The strict inclusion check compares the zero-distance sets.

## The ten pairs

The November 16 transition report and the November 21 distance matrix identify
the same ten lost pairs. [November 16 transition rows](../2026-11-16/natural-ablation/equivalence_disagreements.csv).

Each file compares student predicate `inv8` with the same oracle, `inv8c`, in
`trainStationNew/correct`. A representative pair differs only in how it groups the two declarations.

```alloy
all e: Entry | all x: Exit | x in e.*succs
all e: Entry, x: Exit | x in e.*succs
```

The nested spelling reduced the inner membership to `Exit in e.*succs`.
The grouped spelling kept both quantified variables. This gave both canonical
paths distance 5 on each pair and the original slotted e-graph distance 0.
The repaired Fast and Certificate-Integrated paths both give 0 in both directions.

- [4mNN3z28SdwhfHtn2_inv8.als](../../../classified-data/trainStationNew/correct/4mNN3z28SdwhfHtn2_inv8.als)
- [7yf6otwpXhRdBn4Da_inv8.als](../../../classified-data/trainStationNew/correct/7yf6otwpXhRdBn4Da_inv8.als)
- [8YFbrPvDWYWciWG29_inv8.als](../../../classified-data/trainStationNew/correct/8YFbrPvDWYWciWG29_inv8.als)
- [AEnqk4jM6mRwkWYQd_inv8.als](../../../classified-data/trainStationNew/correct/AEnqk4jM6mRwkWYQd_inv8.als)
- [JfuyLyzR2QpPBuv7j_inv8.als](../../../classified-data/trainStationNew/correct/JfuyLyzR2QpPBuv7j_inv8.als)
- [ZJR9GqfpqjJoThccT_inv8.als](../../../classified-data/trainStationNew/correct/ZJR9GqfpqjJoThccT_inv8.als)
- [aM4CAZYi4mPtGQmbW_inv8.als](../../../classified-data/trainStationNew/correct/aM4CAZYi4mPtGQmbW_inv8.als)
- [vE6z9RXND8gZzbdgS_inv8.als](../../../classified-data/trainStationNew/correct/vE6z9RXND8gZzbdgS_inv8.als)
- [wFJJkTwS2M6tLmHGF_inv8.als](../../../classified-data/trainStationNew/correct/wFJJkTwS2M6tLmHGF_inv8.als)
- [yS9bdPRSYkRtLGBSS_inv8.als](../../../classified-data/trainStationNew/correct/yS9bdPRSYkRtLGBSS_inv8.als)

The shared source rewrite uses the selected variable's binding and keeps the
other declarations and their domains in scope. It also handles a reversed
declaration order and the equivalent form with explicit `Entry` and `Exit`
guards. Disjoint bindings, a following domain that reads the variable, and
multiplicity-qualified membership require separate treatment. The regression
suite includes bounded SAT counterexamples for these boundaries.
[Java regression](../../../src/is/fivefivefive/CanDis/AlloySourceRuleRegressionTest.java) ·
[Lean membership laws](../../section3-repair-audit/formal/Phase5SourceRules.lean).

## Cross-reference check

The relevant trainStationNew/inv8 correct references previously formed two
groups of 12 and 8 distinct ASTs. Both paths now returned zero with matching
native operations in all 380 directions among these 20 references. This
retains all 94 earlier unordered equalities and adds 96 between the two groups.
This check covers those 20 references within the released pool.

## Evidence and replay

The compact delta records each changed file, ordered predicates, original
slotted distance, previous and repaired canonical distances and source SHA-256.
Each newly zero row also records its bounded Alloy result. The receipt records
the bytecode fingerprint, normalizer source hashes, cohort sizes and separate
full-stream digests for both canonical arms.
[Changed distances](changed-distances.tsv.gz) · [Measurement receipt](comparison.json) ·
[Frozen baseline](../2026-11-21-studies/measurements/natural-ablation/pair-distances.csv.gz).

Run the following command from the repository root to verify the saved distances and Alloy source hashes.

```sh
python3 docs/experimental-results/2026-11-26/verify.py
```

The seven-arm runner accepts a fresh output directory.

```sh
./scripts/run_egraph_ablation.sh --input classified-data --output NEW_OUTPUT --threads 16 --max-heap 8g
```

The full report checks the two canonical zero sets against the original and
live slotted results by source path and ordered predicate names. A smaller
subset can contain only ties. Its report still fails on any observed slotted
pair lost by either canonical path. The bounded CI
suite replays all 2,228 original slotted zeros and a strict gain. In that
witness the slotted distance is 8 and both canonical distances are 0.
[CI regression](../../../scripts/test_natural_slotted_retention.py) ·
[Strict-gain witness](../../../classified-data/classroom_fol/correct/22c33R4ECiCdiSyMg_inv1.als).

The complete local bounded CI suite passed, including the source-rule regressions
and distance artifact regeneration.
