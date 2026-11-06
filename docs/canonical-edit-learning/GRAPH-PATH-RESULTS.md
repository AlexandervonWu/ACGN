# Complete Graph Repair Programs: First Run

## Answer To The Menu Hypothesis

The previous one-step menu imposed a genuine ceiling: even perfect selection
could repair only 2/192 held-out predicates. The new implementation removes
that ceiling for its admitted examples. Every one of 3,184 teacher programs
replays to the complete paired-oracle graph, without a fixed semantic edit menu.

That change alone did not produce useful learned repairs in this bounded run.
The 503,576,064-parameter model, trained from scratch for eight epochs, produced
**0/652 exact held-out target graphs** and **0/64 on a fixed training sample**.
This is not only an unseen-question failure. It is also not evidence that all
learning signal disappeared: token loss decreased, but complete programs failed.

## Run And Coverage

- 4,096 source attempts across 16 problem sets; no Java export failures.
- 3,184 admitted graph pairs: 2,088 training, 444 validation, 652 test.
- Question groups: 100 training, 29 validation, 25 test.
- Exclusions: 726 duplicate pairs, 127 token-bound pairs, 59 cross-split duplicate inputs.
- All 3,184 teacher replays and input-prefix round trips pass; no cross-split input overlap remains.
- Vocabulary 128; source-only DAG/schema/symbol table; complete COPY/BUILD/EOS programs.
- Effective batch 128, microbatch 8, 136 optimizer updates, peak Adafactor rate 0.0001.
- BF16 compute with FP32 master parameters on the RTX 5080; no INT4 storage claim.
- Training took 51.11 minutes; training plus validation/test generation took 98.12 minutes.
- Maximum allocated/reserved device memory: 10.761/13.762 GiB, excluding the desktop.

## What Failed

Validation token loss fell from 3.139028 after epoch 1 to 1.983006 after epoch 8;
the selected checkpoint was epoch 8. Test token loss was 1.848454 nats.
Nevertheless, 376/652 test outputs were only syntactically replayable: **none
had the required ROOT shape**. Another 235 failed the codec and 41 exhausted
their generation budget. The 235 codec failures were 105 invalid source
references, 79 noncanonical numeric encodings and 51 excessive program depths.

A concrete validation witness starts correctly with `BUILD, LIST`, then emits
label length 7 where the target ROOT label has length 1. In another witness,
the completed label is `[4, 1, 0, 0, 0, 0, 0]`, not `["ROOT"]`. This is a
structural-generation error before any Alloy semantic or certificate check.

Ordinary and cached full-model CPU logits agree on the wrong prefix choices;
the maximum difference over the four checked positions is below 0.000006.
This bounded check supports that the witnessed error belongs to the learned
model, not the cache implementation. The 64-case training diagnostic likewise
has 30 syntactic replays but zero ROOT-shaped outputs or exact target graphs.

The evidence is consistent with underlearned record structure and autoregressive
error propagation. Long serialization/type metadata can dominate token loss;
that explanation is an inference, not an isolated causal result. Only 136
updates were performed. This run does not establish convergence, a capacity
limit, or which representation/optimizer change would solve the problem.

## Boundaries And Checks

These are graph-reconstruction counts, **not solver-verified Alloy repair rates**.
Exact graph identity is stricter than semantic equivalence; syntactic replay is
weaker than a well-typed canonical graph. Generated metadata has no certificate
authority. Source realization and the existing two-direction Alloy gate remain
open. The old and new studies differ in corpus and success criterion, so their
rates are not a head-to-head behavioral comparison.

Eight standalone Lean model theorems compile without `sorry`, `axiom` or
`unsafe`. The 22 new tests and all 36 prior learning tests pass, including live
Java checks. Theorems precede implementation and establish abstract construction
contracts, not a complete Java/Python refinement. All Java sources compile.
Canonicalization, certificate admission, and protected empirical trees are unchanged.
The 376 recorded source/library hashes still match, and all 16,634 files in the
run's `SHA256SUMS` pass verification. The worktree remains explicitly dirty;
these checks are experimental provenance, not a publication release claim.

Before training, an input gap was fixed: original declaration names needed by
opaque target metadata are now available through a source-only module symbol
table. Initial exports were re-encoded, not reselected by repair success. The
old codec snapshot and both preparation ledgers are retained.

## Reproduce And Inspect

```bash
bash scripts/run_graph_path_training.sh /home/augustus/acgn-graph-next 4096 8
```

- [Generated measurements](results/graph_path_504m_20261003/RESULTS.md)
- [Protocol and proof boundary](GRAPH-PATH-STUDY.md)
- [Implementation](../../experiments/graph_repair/README.md)
- Full run: `/home/augustus/acgn-graph-path-20261003`.
- Checkpoint: `model/best.pt` within that run.
- Checkpoint SHA-256: `e55c72b2be7211867cc40c53efd77bc612ef4184558c365c5e9cc40bacb474f1`.

The next representation question is how much fixed graph/typing serialization
can be produced deterministically while the model learns the actual edit
choices and operands. That does not require restoring a one-step action menu.
