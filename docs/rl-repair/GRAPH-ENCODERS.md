# Graph Encoder Comparison for RL-2/3

## Shared Boundary

This extension compares four encoders over the same read-only structured
observation. It does not change the action menu, instance bank, Alloy queries,
reward equation, certificate authority, or proof-gated optimizer path. The
observation is a source-occurrence graph joined through a root to the certified
repair projection, with binding, phase, operand, and alternative edges. It is
an abstraction of the e-graph, not an export of every internal e-class.

Source nodes remain necessary because actions identify editable source
occurrences. No unproved inverse of normalization is introduced. All encoders
receive the same types, roles, edge labels, ordered positions, node features,
and action references. Oracle text and equality authority are not learned
inputs. Each edge occurrence remains present, including repeated Bag operands;
this is not a claim that a neural embedding can always distinguish multiplicity.

## Encoders

The CLI names are `mpnn`, `gcn`, `gat`, and `gin`. These are explicitly edge-aware
variants, not exact replicas of external implementations or their published
benchmark results. All use learned categorical/position embeddings and the same
actor, critic, and global mean readout. No external theory downloads are required.

- **MPNN:** the existing gated message-passing baseline. For every directed
  occurrence, compute `tanh(W[h_source; edge])`, sum at its destination, and
  apply a GRU update followed by LayerNorm. Reverse occurrences are explicit.
- **GCN:** add one self-loop per node, then use symmetric degree normalization
  `1 / sqrt(degree(source) * degree(target))`. Messages are
  `W_node h_source + W_edge edge`; normalized sums pass through ReLU and
  LayerNorm. Degrees count edge occurrences, not distinct neighbors.
- **GAT:** add one self-loop per node. Per-head logits combine projected source,
  destination, and edge features with learned attention vectors and LeakyReLU.
  A numerically stabilized softmax runs separately for each destination and
  head, never across the whole graph. Weighted source-plus-edge messages are
  summed, heads concatenated, and ELU/LayerNorm applied. Hidden width must be
  divisible by the positive head count. There is no dropout in this comparison.
- **GIN:** an edge-aware GIN/GINE-style layer. Sum `ReLU(h_source + W_edge edge)`
  over original/reverse occurrences, add `(1 + epsilon) * h_target`, then apply
  a two-layer MLP and LayerNorm. Epsilon is learned. No extra self-loop is added:
  the center term is already explicit.

GCN/GAT process isolated nodes through their self-loop. GIN uses its center
term. MPNN preserves its existing behavior on an entirely edgeless graph.
Edge positions and forward/reverse kinds remain distinct. Position clipping
and feature hashing are approximations, never semantic identities.

Sparse processing uses space proportional to edge occurrences times hidden
width, not a dense node-by-node attention matrix. Inputs exceeding 65,536 source
edge occurrences are rejected. Dense formulas are used only as small independent
test references. Matching width and depth does not match parameter count; both
parameter counts and measured costs must be reported.

## Proof Ledger

`formal/GraphEncoders.lean` was compiled before implementation. It proves:

- GE-01: bounded endpoints, preserved edge attributes under reversal, exact
  bidirectional/self-loop counts, and retention of duplicate occurrences.
- GE-02: each self-loop-augmented neighborhood is nonempty, so every GCN
  degree product is strictly positive.
- GE-03: edge-order invariance of integer sum aggregation and degree counts;
  injective node relabeling preserves incoming occurrences and their attributes.
  This is an exact combinatorial model, not floating-point associativity.
- GE-04: nonnegative attention numerators with a positive witness have a
  positive denominator and total numerator equal to that denominator. This
  specifies normalization; it does not prove CUDA exponentials. Zero numerators
  are allowed, including finite-precision underflow. Stable softmax supplies a
  maximal-score occurrence with exponent one in the numerical implementation.
- GE-05: valid GAT head dimensions reconstruct hidden width; equal architecture
  contracts retain the encoder family. Checkpoints also bind head count and
  the graph-contract hash. Older architecture formats are rejected explicitly.

The 400-row Lean/Python schedule matrix covers 1-4 nodes, every single-edge
endpoint pair, duplicates, optional self-loops, incoming degrees and integer
message sums. CUDA tests compare GCN/GAT/GIN with separately written dense
reference calculations and gradients, check per-destination attention mass,
isolated nodes, all four action masks/checkpoints, occurrence permutation within
tolerance, and real proof-gated updates.

These are model proofs plus bounded implementation checks. Full Python/Lean
refinement remains open, as recorded in APPLICATION-ASSURANCE.md. PyTorch/CUDA
remain external TCB; the choice and composition of operations remain application
obligations. Encoder outputs never authorize an e-class merge or a repair claim.

## Comparison Protocol

Use identical tasks, declared train/evaluation splits, seeds, hidden width,
depth, episode counts, solver profile, horizon, learning rate, and pool settings.
Run each encoder/seed in a fresh process, with the same random baseline and an
independent evaluator bank. Bank contents may diverge after different actions;
record initial/final bank evidence rather than claiming identical trajectories.
Report every abort; do not drop failed runs from denominators or select the best
evaluation seed. Do not choose an encoder using held-out outcomes and then call
the same outcomes an unbiased final evaluation.

The comparison writes per-run manifests, traces, checkpoints and summaries plus
combined JSON/Markdown, including success counts, average edits/steps/returns,
solver calls, parameter counts, wall time, timed model forward/update work, and
peak CUDA allocated memory. Timing includes synchronization and is descriptive,
not a claim of production throughput. Model time is separated from solver and
Lean-checker time; the entire experiment is not a GNN microbenchmark.

The bundled comparison is a small functional pilot. A few fixture tasks and
seeds cannot establish generalization or a statistically reliable winner.
The existing corpus repair runners and published empirical trees are untouched.

## Run

For one encoder, use the existing learning launcher with, for example,
`--encoder gat --layers 2 --heads 4 --hidden 64`. MPNN remains the default.
The comparison launcher compiles Java/proofs once and runs fresh child processes
serially. It includes the same random-policy baseline for each seed and checks
that this baseline's episode records agree across encoder arms.

```bash
./scripts/run_rl_encoder_comparison.sh \
  --manifest docs/rl-repair/fixtures/encoder_comparison.json \
  --output /tmp/acgn-rl-encoder-comparison \
  --encoders mpnn gcn gat gin --seeds 42 43 44 \
  --episodes 10 --eval-episodes 3 --horizon 4 \
  --hidden 64 --layers 2 --heads 4 --capacity 100 --device cuda
```

`--episodes` is per training task and seed; `--eval-episodes` is per held-out
task and seed. This fixture manifest has two training and two held-out tasks,
so the command requests 12 runs and 240 training updates. Supply a new output
directory. Use `--encoders`/`--seeds` for comparison, singular `--encoder`/`--seed`
for an individual run. Failed runs remain in `runs.json` and the comparison
exits nonzero; incomplete encoder arms are not selectively averaged.

The expanded `./scripts/run_rl_learning_tests.sh <fresh-directory>` checks the
21 graph-model theorems, 400 schedule rows, numerical/gradient/reference tests,
and all four encoder pilots in two clean builds. The registered scope remains
finite checks, not complete application refinement or a semantic proof of
learned representations.

## Incident Ledger

The first multi-seed wrapper compared configuration values after converting
them to strings. Argparse's default timeout was integer `30`, while the same
explicit child option was parsed as float `30.0`. All 12 underlying training
runs completed without aborts, but the wrapper correctly withheld a complete
comparison when its overly strict metadata check failed. The repair compares
typed JSON-compatible values, serializing only paths, and reports the mismatched
field. A regression checks equal numeric values and rejects genuinely different
timeouts, learning rates, capacities, and numeric strings. The original failed
run is retained at `/tmp/acgn-rl-encoder-comparison-01`; it is not relabeled as
successful. This is a reporting correction, not a change to rewards or encoders.
