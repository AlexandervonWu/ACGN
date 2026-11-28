# Native replay of the ranked Alloy corpus

This evidence directory records the same 1,894,168 student–reference comparisons on the original and repaired engines. Each comparison uses the published student predicate, reference predicate, source hashes and expected distance. Each measured build contains both Fast Rewrite and Certificate-Integrated. The original and repaired builds have distinct JAR hashes. The ranking denominator and its scalar scores come from the original score producer.

## Results

Fast Rewrite and Certificate-Integrated returned **the same ordered native program on all 1,894,168 ranking pairs**. Of these comparisons, 1,867,495 used flat edit actions and 26,673 used temporal blocks. Every original distance was reproduced. The comparison covers 42,386 incorrect submissions and 4,496 eligible reference ASTs across 181 invariant pools. The original ranking ledger separately records 21 cross-file AST identities outside its measured cohort. [Headline data](headlines.json) · [Revised paper](paper-exhaustive-ranking-replay.pdf)

On the previous build, 386 pairs across 13 pools had equal distances and different programs. For example, at distance three Fast kept a `Photo` binder and Certified kept a `User` binder. We replayed each recorded discrepancy across the successive repairs. [All 386 pairs by source, reference and repair](repairs-by-pair.csv) · [Five worked examples with native traces](worked-examples/) · [Forward and reverse results at each stage](stage-attribution/tables/final-timeline.csv)

| First repair that held through the final build | Forward pairs |
| --- | ---: |
| Read counting-binder positions from the original declaration | 136 |
| Visit tied permutations in original declaration order | 47 |
| Preserve the linked temporal declaration when two paid updates tie it | 5 |
| Compare each eligible target binder group before choosing a mapping | 188 |
| Recover the original declaration and tuple slot of each coalesced binder | 10 |

The repaired program agreed with the previous Certified program on 381 of those pairs and with the previous Fast program on the other five. The regression suite protects all 386 pairs and the earlier 83 by source identity. Both orientations passed on all 469 pairs. The Lean kernel checked the finite selection lemmas and representative traces. The exhaustive native result applies to replay from the frozen normalized inputs. A general refinement proof from the Java implementation and a public certificate from original text to edits remain open. [Regression inventory](paid-rank-witnesses-floor.jsonl) · [Lean evidence](receipts/repaired/kernel/)

Both paths retained every original Slotted zero. On the 19,212 correct distinct-AST student–oracle pairs, the count rose from 2,228 to **5,137**. All 42,386 incorrect pairs kept positive distance. Across correct references the count rose from 8,952 to **19,271**. Grouping the 4,496 references by structural zero gives 1,816 forms. A further 1,107 direct links verified under their fixed Alloy commands reduce the count to 1,743 connected components. All 105 solver counterexamples stay disconnected. For example, two classroom predicates have structural distance seven, but their original Alloy command admits no counterexample to equivalence at its bounds. [Historical source and command evidence](retention/) · [Reference-pool comparison](reference-pool-scores/)

The structural checks also cover the seven reference pairs that v3.1 recognized and v3.3 lost. Six are in the first CV model and one is in the second. In the historical recovery table, the seven rows with `v3.1` in `historicalEvidence` identify their original predicates. [Historical reference recoveries](../historical-retention/repaired-reference-pairs.csv)

Figure 3 uses the v3.1 presentation, with the legend at bottom right. It connects the cumulative share at successive integer edit radii. At radius ten, 25,036 incorrect submissions have a reference within reach under the rewrite distance, compared with 23,087 under raw AST edits. [Coverage figure](../historical-retention/repair-coverage.pdf) · [Counts at each radius](../historical-retention/repair-coverage.csv)

The repaired run used 29 workers and completed in 10 hours 30 minutes, including the power outage. The supervisor resumed the 29 interrupted shards, and the independent verifier rechecked all 1,059 completed shards. [Final verdict](receipts/repaired/independent-closure.json) · [Recovery records](receipts/recovery/)

## Why 196 archived temporal hashes changed

The old and repaired builds already agreed internally on these 196 pairs. Yet an ordered block effect includes the integer that the JVM assigned to each local variable occurrence. Preparing another predicate first changes that integer. In fresh processes, both builds emitted identical edits, in identical order, for all 196 pairs. Restoring just the original numbers to the authenticated source occurrences reproduced **all 392 archived hashes**. This preserves the distinction between separate uses of the same binder. A fresh replay of all 26,673 temporal pairs found the same 196 with such numbers. The other 26,477 reproduced their archived hashes directly. [Source-bound replay and original receipts](temporal-program-replay/) · [Complete temporal recount](temporal-program-replay/full-temporal-scope/)

## Verify the release

Use Python 3.10 or later, Git, and a checkout of ACGN containing the released data and measured revisions. From this directory run

```sh
python3 -B verify.py --repo /path/to/ACGN
```

The command checks the entire SHA-256 inventory and recounts both indexed archives. It also rechecks each archived counterexample, the historical bidirectional regression floor, source and command controls, the complete within-reference score comparison, repair-stage results, proof inventory, and CI receipt. The native counterexample count for the original engine is 386. Its archived verifier reports that its ordered-witness equality claim failed. The command below can reproduce this observation separately.

```sh
python3 -B verify.py --repo /path/to/ACGN --original-only
```

## Read an individual comparison

Each source index points to one row of its compressed ranking archive. A flat comparison commits to the ordered Fast/Certified edit actions. A temporal comparison commits to the ordered component and effect of every block. A successful observation requires both source certificates, endpoint correspondence, fixed-choice replay, equal scalar costs, and equal ordered programs. Each divergent original comparison includes its full native diagnostic under `original/incidents/`.

The following commands recover the measured engine bytes from the two committed revisions and replay a real comparison in each. They require JDK 17 and fresh output paths. The recorded compiler version and JAR layout for each build are in `reproduce/jar-assembly/engines.json`.

```sh
repo=/path/to/ACGN
replay_dir=$(mktemp -d)
student='socialMedia/both/26DDAj6ASk6EfaPvY_inv1.als'
reference='socialMedia/correct/2BAGPQKaHm7FbKGip_inv1.als#inv1'
for edition in original repaired; do
    python3 -B reproduce/jar-assembly/reproduce_engine.py "$edition" "$replay_dir/$edition.jar" --repo "$repo"
    python3 -B temporal-program-replay/replay.py "$edition" "$repo" "$student" "$reference" \
        --jar "$replay_dir/$edition.jar" --full-receipt "$replay_dir/$edition-program.json"
done
```

Use an immutable reference ID in place of `path#predicate` for another indexed comparison. Each edition also provides `lookup_native.py` with the same four positional arguments for reading its existing record.

## Reproduce the complete cohort

To reconstruct the frozen source inputs and independently recover the original manifest from Git, run

```sh
python3 -B reproduce/restore_inputs.py "$replay_dir/original-inputs" --repo "$repo" --original-jar "$replay_dir/original.jar"
```

A new repaired run requires a separate output directory. The measured run used 29 workers. Set the worker count according to the available CPUs and RAM. Each process uses one GC thread, a 160 MiB initial heap and a 400 MiB ordinary maximum heap. The runner checkpoints by original shard and row. Allow free disk space for all raw observations in addition to this compact archive.

```sh
commit=$(python3 -c 'import json; print(json.load(open("receipts/repaired/runner-identity.json"))["engine"]["commit"])')
python3 -B reproduce/repaired-runner/prepare.py \
    --baseline-root "$replay_dir/original-inputs" --run-root "$replay_dir/new-repaired" \
    --engine-jar "$replay_dir/repaired.jar" --build-receipt receipts/repaired/build-receipt.json \
    --engine-commit "$commit" --workers 1 --collector parallel-one \
    --initial-heap-mib 160 --max-heap-mib 400 --min-heap-free-ratio 40 --max-heap-free-ratio 70
python3 -B "$replay_dir/new-repaired/runner/supervise.py"
```

Each new execution has its own UUID. The published runner and auditor registrations identify the specific executions covered by this release.

## Files

- `original/` and `repaired/` hold indexed per-comparison native commitments, compact shard bindings, original status and diagnostic details.
- `before-after.json` summarizes both arms’ witness changes across the complete cohort. `repaired-ranking-pairs.csv` identifies the 386 original divergences. `paid-rank-witnesses-floor.jsonl` records all 469 protected comparisons, including 83 from earlier editions.
- `stage-attribution/` traces the original divergences through each repair stage and supplies actual native evidence for both orientations of the final floor. `worked-examples/` contains five source-level examples with complete programs.
- `retention/` records native checks for the 61,598 original paired student–oracle examples and 19,271 structurally equal reference pairs. Its fixed-command records identify the command, bounds, applied rule, and native solver decision for scoped results. The command archive includes 1,234 UNSAT results and 105 SAT controls.
- `reference-pool-scores/` covers all 132,032 within-pool reference pairs, including the 112,761 with positive structural scores.
- `receipts/` records inputs, registered source and JAR identities, cohort completion, independent verification, both clean build inventories, bounded CI and the Lean kernel results. `receipts/repaired/diagnostic-controls/` separately identifies a pre-budget-handling overlay neighbor check and each archived harness outcome on the prior and final builds. `reproduce/` contains verifier and runner sources and JAR assembly metadata.

The supplementary `diagnostic-controls/` archive documents the separately built test-only revision, both repaired standalone harnesses, and class-by-class correspondence with the measured engine.

The reboot recovery receipts in `receipts/recovery/` document the 860 sealed shards, the 29 interrupted shards, and the reconstructed independent checkpoint. The full release verifier matches every preboot seal to the final repaired archive.
