# Graph-To-Complete-Program Training Result

This is a bounded supervised graph-reconstruction result, not an Alloy solver repair rate.

## Protocol

- Train / validation / test: 2088 / 444 / 652 pairs.
- Parameters: 503,576,064; vocabulary 128; full training from scratch.
- Epochs: 8; effective batch 128; microbatch 8.
- Question-disjoint splits; exact input overlaps removed from later splits; no one-step menu.
- Module schema, source-only symbol table and faulty DAG are the key; a complete COPY/BUILD program is the value.
- FP32 master weights, BF16 computation, Adafactor, peak learning rate 0.0001.
- Checkpoint criterion: minimum validation target-token cross entropy; earliest wins ties; selected epoch 8.

## Measured Results

- Held-out exact target graphs: 0/652 (0.00%).
- Held-out exact token programs: 0/652.
- Held-out syntactically replayable programs: 376/652.
- Held-out ROOT-shaped outputs: 0/652 (not a type check).
- Unchanged-graph baseline exact matches: 0/652.
- Validation exact target graphs: 0/444.
- Post-selection training sample exact graphs: 0/64 (not held-out evidence).
- Test target-token cross entropy: 1.848454 nats.
- First / last epoch training token loss: 3.979137 / 1.949738.
- Stop counts: {"EOS": 376, "INVALID": 235, "TOKEN_LIMIT": 41}.
- Replay categories: {"Need": 41, "VALID": 376, "ValueError": 235}.
- Training: 51.11 minutes; training plus evaluation: 98.12 minutes.
- Peak device memory: 10.761 GiB allocated / 13.762 GiB reserved.

## Interpretation

The old menu permitted a successful one-step repair for only 2/192 of its test cases. This experiment removes that representational ceiling: every admitted teacher program replays to the full target. The corpus, splits and success criterion differ, so the new rate is not a head-to-head behavioral improvement claim.

Exact graph match is stricter than semantic equivalence and may reject another valid repair. Replay validity is weaker than type correctness. Generated metadata is never accepted as certificate authority. Source realization, reparsing and the existing two-direction solver gate remain required before behavioral repair can be reported.

A single eight-epoch seed does not establish convergence, stable superiority over random walks, or a model-scaling result. Intended behavior may also be ambiguous from a faulty graph and declaration schema without a natural-language specification.

## Evidence

- Eight model-level Lean theorems precede the implementation; they are not a whole-program refinement proof.
- Codec replay, source-only inputs, alpha renaming, temporal targets, loss masking, gradient accumulation, cached decoding and synthetic complete-program learning have bounded regression tests.
- Run: `/home/augustus/acgn-graph-path-20261003`.
- Checkpoint SHA-256: `e55c72b2be7211867cc40c53efd77bc612ef4184558c365c5e9cc40bacb474f1`.
- Small summaries and per-question results are alongside this report; full predictions, packets and raw exports remain in the run directory.
