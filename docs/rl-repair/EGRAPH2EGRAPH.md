# Lean-Gated EGraph2Graph Transformer

## Scope And Sequence

The first model proof, `formal/EGraph2Graph.lean`, and executable structural
gate were compiled before this specification and before Python implementation.
This is a bounded, iterative graph-edit transformer, not unrestricted generation
of arbitrary Alloy programs and not an implementation of complete equality
saturation inside the neural network.

The existing `repair-structured-graphs-v1` observation contains source occurrences,
temporal/phase nodes, canonical matrix occurrences, available certified alternatives,
bindings, and use/dependency/disjointness edges. It is an e-graph-derived **repair
projection**, not every internal e-class and member of the saturation engine.
This first version keeps that public Java observation unchanged. Its limitations,
including feature hashing and clipped numeric/port-position features, remain.

## Primary Research

Sources checked on 2026-10-03. These motivate design choices, not a claim that this
prototype reproduces a paper or achieves state-of-the-art repair performance.

- [GraphGPS, NeurIPS 2022](https://arxiv.org/abs/2205.12454): motivates combining
  edge-aware local processing with a separate global attention path.
- [Graphormer, NeurIPS 2021](https://arxiv.org/abs/2106.05234): motivates preserving
  structural information in graph attention. We use existing typed edge and port
  features, not shortest-path preprocessing or an arbitrary node-order embedding.
- [TokenGT, NeurIPS 2022](https://arxiv.org/abs/2207.02505): motivates treating graph
  structure explicitly as input. We do not reproduce its node-identifier encoding.
- [Perceiver IO, ICLR 2022](https://arxiv.org/abs/2107.14795): motivates a bounded
  latent read/write bottleneck and output queries for structured predictions.
- [Exphormer, ICML 2023](https://proceedings.mlr.press/v202/shirzad23a.html): motivates
  sparse global communication. This version does not implement expander edges.
- [PPGT, TMLR 2026, revision 4](https://arxiv.org/abs/2504.12588v4): highlights the
  importance of graph structure and token magnitude. We retain edge occurrences
  and an unnormalized local sum. We do not implement its L2 attention, AdaRMSNorm,
  or claim that our learned embeddings distinguish every multiset or graph.

## Architecture

Let `G_t` be the checked candidate's repair projection and `M_t` its source edit
menu. The transition is:

```text
G_t + bounded feedback
  -> Lean structural admission
  -> shared node/type/container/port embeddings
  -> local + latent-global Graph Transformer blocks
  -> action-query cross-attention over encoded graph nodes
  -> distribution over existing source edit menu M_t
  -> Java apply / reparse / exact preparation / solver feedback
  -> G_(t+1), or the existing rejected/terminal outcome
```

Each block uses pre-LayerNorm, a bidirectional edge-aware local sum, eight learned
latent queries reading all nodes, node queries reading those latents, and a residual
four-times-width GELU feed-forward network. Attention uses PyTorch multi-head
scaled dot-product attention with dropout zero. The global read/write pair count
is `16*N`, per head per layer. Local processing retains all message occurrences;
it does not deduplicate BAG operands or reorder SEQUENCE ports.

For each action, concatenate its source-occurrence embedding and edit features,
project to an action query, and cross-attend to the graph. The existing actor
scores occurrence, decoded action features and pooled feedback context. The
critic and Lean-checked reward/return/update protocol remain unchanged. Decoder
attention costs `O(A*N)` per head, with `A <= 512` and `N <= 4096`.

There are no oracle body tokens, oracle graph inputs, learned equality merges,
synthetic type certificates, or direct writes into certified graphs. The edit
menu is a proposal space, not a guarantee that every proposed edit will parse
or type-check; Java remains responsible for those checks. The existing supported
source profile is unchanged. Rejected edits and solver uncertainty retain their
existing meanings.

This is "egraph2egraph" through **checked edit transitions**, not a one-shot
decoder of all e-class membership, slots and proofs. A future full-e-graph encoder
would require a separately versioned observation contract and its own evidence.

## Formal And Executable Correspondence

- `admission_valid` and bound lemmas: executable Lean checks the actual node,
  edge, action-pointer, head/depth/width, mask and latent-slot request.
- `relabel_port_attributes`, `relabel_duplicate_ports`, `relabel_pointer`:
  the exact structural model retains labels, positions, multiplicity and pointers.
- `mass_order_invariant`, `moment_order_invariant`, `cross_read_permutation`,
  `query_order_equivariant`, `pointwise_composition`: exact integer weighted-moment
  algebra underlying permutation-invariant reads and equivariant queries.
- `positive_mass`, mask lemmas: normalization support and exclusion contracts.
- `commit_requires_checked_graph` and commit cases: output validity is conditional
  on the checker supplying a valid graph; this does not prove the Java checker.
- `layer_parameter_increment`, `fixed_latents_linear`: exact layout accounting and
  linear latent-global attention pair count. The whole network is not O(N), since
  its local edges, feature width, and action decoder also contribute work.

The runtime structural gate echoes its exact request, whose hash is recorded in
each model-driven transition. A bounded cache may reuse an admission only for
the identical structural request and unchanged proof/code contract. Every
optimizer update still requires the existing executable Lean rollout admission.
The structural receipt certifies the request's shape, not the truth of a source
type, the extraction of features, or a floating-point tensor computation.

The Python parameter contract is
`11*w*w + 4189*w + 2 + layers*(18*w*w + 25*w)` in FP32. It includes the action
cross-attention decoder. Meta-device construction checks this against actual
PyTorch parameters. Checkpoint architecture metadata identifies the graph
transformer and its proof/implementation contract; mismatches fail closed.

## Bounded Verification Plan

Freeze the theorem inventory, 640-row Lean/Python structural-admission matrix,
275-row parameter matrix across all five encoders, CUDA dense-reference attention
values/gradients, relabeling/action-order/mask tests, duplicate/port sensitivity,
gate rejection and cache tests, live graph transition, per-layer update and
checkpoint tests. Run the existing Java/Lean/CUDA regressions and two clean
builds, plus deterministic transformer pilots. Bind receipts and output hashes.

PyTorch/CUDA, numerical kernels, driver, Lean runtime and the declared Alloy/SAT
dependencies remain TCB. Full Java/Python-to-Lean refinement, exact floating-point
permutation invariance, graph-isomorphism completeness, convergence, semantic
equality inferred from embeddings and corpus generalization remain excluded.
Dense-reference and permutation tests are tests, not universal refinement proofs.

## Training Protocol

Verification incident: candidate r1 completed its transformer pilot, but its
receipt counter included task-load records. It stopped with
`TRANSFORMER_ADMISSION_MISSING` at `/tmp/acgn-rl-transformer-check-01`.
Candidate r2 counts only actual model-driven transitions and recomputes each
receipt hash from that transition's observation. A regression includes load
records, random steps, changed port positions and changed receipt hashes. Failed
evidence is retained; r2 must pass fresh clean builds before the tuning run.

Compare `egraph_transformer` against a freshly trained `gat` control, on the same
existing train/validation/test fixture split, with widths/depths 64x2, 128x2,
256x4 and 512x4. Eight heads; learning rate 0.0003; 24 training episodes per task;
three evaluation episodes per task; horizon four; instance capacity 100.
The grid tunes depth as well as width and is not parameter-matched across models.

Validation seeds: 342,343. Final seeds: 401,402,403. Freeze maximum-validation-repair,
minimum-parameter selections before final tests. These are reused fixtures with
fresh seeds, not a new benchmark. The GPU children run serially with the existing
10 GiB allocator cap. No historical results or default model are overwritten.
