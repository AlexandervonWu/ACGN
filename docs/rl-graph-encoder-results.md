# RL Graph Encoder Results

Date: 2026-10-03. This is a bounded functional comparison, not a corpus
generalization result or an encoder-selection study.

## Implementation

The existing gated MPNN is joined by edge-aware GCN, multi-head GAT, and
edge-aware GIN. All consume the same typed source/canonical repair projection,
preserve message occurrences, and use the existing actor/critic, action menu,
reward bank, and executable Lean rollout gate. MPNN remains the default.

[The design and proof ledger](rl-repair/GRAPH-ENCODERS.md) specifies the exact
variants, self-loop rules, numerical boundaries, and comparison protocol. The
work followed proof first, documentation second, then implementation and tests.
PyTorch/CUDA are external TCB. Full application-to-Lean refinement remains open;
none of these embeddings authorizes semantic equality or e-class merging.

## Verification

The [machine verification report](rl-graph-encoder-verification.json) records
**8/8 frozen finite claims passed in two clean builds**, against input root
`c1fb17fa790cc0fc21227e338366e0c329f4a32c1e3af02d1cfcc713940b67a1`.
The checks took about 223 seconds on the local RTX 5080 host.

- 21 new Lean graph-contract theorems; 83 total across the four RL proof files.
- A 400-row Lean/Python graph-schedule matrix, alongside the existing 128-row
  controller and 155-row feedback/reward matrices.
- 26 Python/CUDA/gate tests per build, including independent dense GCN/GAT/GIN
  outputs and gradients, attention normalization, isolated nodes, graph
  relabeling, checkpoints, action masks, and typed comparison settings.
- Existing Java checks: 64 environment, 38 feedback, 2,041 pipeline, 2,266
  quotient distance, and 44 source-command/profile assertions per build.
- 38 actual policy updates per build across all four encoders. Proof objects,
  deterministic episode records, and learned tensors agree between builds.

Raw evidence: `/tmp/acgn-rl-graph-check-02`. The earlier comparison metadata
failure is retained at `/tmp/acgn-rl-encoder-comparison-01` and explained in the
design ledger. Reports from earlier input roots are historical, not reused as
verification evidence for this revision.

## Matched Pilot

[Machine results](rl-graph-encoder-comparison.json) and the
[generated detailed summary](rl-graph-encoder-comparison.md) retain all seeds,
counts, returns, steps, edits, parameters, timing, and memory observations.
Raw traces and checkpoints are in `/tmp/acgn-rl-encoder-comparison-02`.

The pilot used two training tasks, two held-out tasks, seeds 42/43/44, ten
episodes per training task, three per held-out task, horizon four, width 64,
depth two, four GAT heads, and pool capacity 100. All 12 runs completed with
240 training updates and zero aborts. Random episode records matched across
encoder families at each seed.

Held-out bounded repairs:

- MPNN: 3/18; per-seed rates 0%, 50%, 0%.
- GCN: 6/18; per-seed rates 0%, 100%, 0%.
- GAT: 3/18; per-seed rates 0%, 50%, 0%.
- GIN: 6/18; per-seed rates 50%, 50%, 0%.
- Matched random baseline: 5/18; counted once, not pooled as independent data
  four times merely because each encoder reran it.

GCN/GIN have higher aggregate success in this pilot, but the small sample and
large seed variation do not establish superiority. Evaluation uses evolving
counterexample banks, so repeated episodes are not independent samples. No
hyperparameter or default-policy selection was made from these held-out results.

The comparison took about 173 seconds overall. Per-family wall times summed
over three seeds were approximately 38 seconds. Timed model forward/update work
was approximately 1.7-2.0 seconds per family; most wall time was outside that
timed model work, including Java/Lean execution, solver interaction and I/O.
This is not an equal-parameter or isolated GPU-throughput benchmark.

## Reproduce

```bash
./scripts/run_rl_learning_tests.sh /tmp/acgn-rl-graph-check-next

./scripts/run_rl_encoder_comparison.sh \
  --manifest docs/rl-repair/fixtures/encoder_comparison.json \
  --output /tmp/acgn-rl-encoder-comparison-next \
  --encoders mpnn gcn gat gin --seeds 42 43 44 \
  --episodes 10 --eval-episodes 3 --horizon 4 \
  --hidden 64 --layers 2 --heads 4 --capacity 100 --device cuda
```

Use fresh output directories. The comparison launcher runs children serially;
it rejects incompatible inputs/settings and leaves failed runs in the report.
Only the new RL extension and its documentation changed. Tracked canonical
semantics, published experimental trees, and full-corpus runners have no diff.
