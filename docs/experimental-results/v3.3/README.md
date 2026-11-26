# CanDis v3.3 full-corpus results

Both Fast Rewrite and Certificate-Integrated recognized **4,499
correct structural zero-distance pairs**. Each retained all **2,228**
original slotted e-graph zeros and added **2,271** correct
pairs. The paths agreed on every measured distance and on the native-operation
diagnostic for all 61,598 AST-distinct pairs. Neither path
returned zero for any of the 42,386 labeled incorrect pairs.
There were 4,482 additional AST-identical rows among the
66,080 original files.

The shared universal-membership rewrite restored the ten
`trainStationNew/inv8` pairs previously lost to the original slotted e-graph.
It recognizes ordinary subset tests consistently across grouped and nested
universals. Both paths retained the earlier 4,413 v3.1 structural zeros.
[Exact source pairs and rewrite details](../2026-11-26/README.md).

## Rules checked under the Alloy command

The default batch rerun found a selected fixed check on
61,598 AST-distinct pairs and verified a rule match
on 347. Of those, **259**
had positive structural distance. The five source readers require the
original selected endpoints, the Alloy command's effective bounds, matching
results for both orientations, and a native UNSAT result for a proposed
match. Structural distances measure rewrite equality. Fixed-command matches
apply at the recorded scope and bitwidth.

The Augmenter covered all 181 invariant pools with **4,496** AST-distinct
references and **132,032** unordered within-pool comparisons. The pools
contained **2,016 structural forms and 1,942 fixed-command components**. The rule matched
1,234 of those pairs. The complete CSV and pair ledger
include the common-context status. Each component count is formed within
one invariant. All 1,234 v3.2 rule
matches were retained and the 105 historical native counterexamples stayed
in separate components. Against the earlier structural pool measurement,
319 cross-file pairs gained a zero and seven lost one. These seven are in
the CV exercises and each had distance 16 in the original slotted engine.
[The seven cross-file pairs](changed-v31-pool-zeros.json) ·
[Original slotted checks](pool-direct-losses-slotted.jsonl).
[Per-invariant counts](correct-pools.csv) · [All invariants](forms-by-invariant.pdf) ·
[Pair decisions](correct-pool-pairs.jsonl.gz).

## Repair distances and controlled studies

The full-reference ranking evaluated 42,386
incorrect submissions against every admissible reference in their
invariant pools, for 1,894,168 structural comparisons.
Another 21 cross-file AST identities were recorded separately. Mean
nearest-reference distance was **11.477**
for the repair projection and **12.267**
for raw AST edit distance.
[Nearest distances](nearest-distances.csv.gz) · [Coverage figure](repair-coverage.pdf).

The bounded semantic checker found no counterexamples among
4,499 distinct natural zero claims at the
original command bounds. All four intentionally inequivalent probes
remained separate in every arm. The capability study regenerated the
5,500 transformations and recorded
29 subtype sample checks. Natural typed-slot measurements
covered the same measured files and recorded 2,228
typed zeros. The paper retains the published synthetic scaling grid
with its original censored timeouts.
[Bounded natural checks](bounded-natural-checks.json.gz) ·
[Capability measurements](capability.json) ·
[Natural slot typing](natural-slot-typing.json).

## Reproduction

The frozen source commit is `d5c0c2a07504d53b13b28c61e9e64768c37eb984`. The supervisor used
OpenJDK 17, 16 workers, an 8 GiB heap, reward pool 100, and seed
`55520260811`. All four experiment stages and the natural slot-typing
comparison completed on that commit. The paired batch used the same
fail-fast `--diagnostic-operations` protocol as v3.1. Native-operation and
bounded source checks do not confer public certification. The public replay
witness remains outside this experiment's authority.

[Headline data](headlines.json) · [All seven arm distances](ablation-distances.csv.gz) ·
[Paired decisions](paired-comparisons.jsonl.gz) ·
[AST-identical paths](ast-identical-paths.txt) ·
[Run receipt](run-receipt.json) · [Paper](paper-v3.3.pdf).

Run `python3 verify.py` in this directory to recompute the published counts.
