# Bounded GNN Gradient Study

The renewed request authorizes a bounded architecture comparison after the
previous eight-task gate failed. It does not erase that failure, authorize
large-model escalation, or change `feedback-intent-path-v1` information access.

## Proof First

`formal/FeedbackGNN.lean` has eleven algebraic/dataflow boundary lemmas:
permutation preserves sum aggregation; a table channel excludes other kinds and
retains its members; bilinear scores respond to context and candidate changes;
private arguments cannot affect a policy whose argument is exclusively public;
paired schedules have fixed length; gradients never authorize repair success.

These integer models specify boundaries, not a verified implementation of
floating-point autodiff. Correspondence tests check graph/address transport,
private-oracle independence, table-channel isolation, query sensitivity,
finite-difference gradients, and finite nonzero encoder/pointer gradients.
PyTorch/CUDA, optimizer arithmetic, Java, Alloy and the OS remain TCB. Learning,
generalization and numerical stability are empirical claims, not Lean theorems.

## Architectures

Use the unchanged typed incidence graph, exact int32 bit features and semantic
pointer choices. Compare the previous relational mean GNN/scorer (`original`)
with GCN (symmetric degree normalization), GraphSAGE (mean), GIN (sum with learned
self coefficient), and multihead edge-aware GAT. New variants share residual
normalized updates, table-wise mean readout, public state/source/draft/history
anchors, and a normalized bilinear conditional action scorer. `mlp` uses the
same new readout/decoder but no messages. This is an architectural comparison,
not an isolation of every individual decoder/readout change.

Table pooling assigns one channel per static table kind, so adding rows of a
different kind does not directly dilute another channel. Message passing can
still legitimately change connected nodes. Node addresses are only pointers,
never learned categorical features. Edge roles retain direction/position.
Last-history selection uses the public chronological history coordinate, not
the physical tensor row order. No oracle labels, hidden task intent, filenames,
question IDs or future counterexamples enter the policy.

## Frozen Protocol

- First eight training tasks in the existing task-file order; no filtering by
  ease or teacher success. A missing teacher blocks the study.
- Seeds 17, 29, 43. Reset model and optimizer for every arm/seed.
- Width 128, three message/update layers; report actual parameter counts.
- AdamW, learning rate 0.001, weight decay 0.001, gradient clipping at norm 1.
- 1,000 updates, eight semantic decisions per update. Uniform task, then uniform
  decision, with an identical precomputed sampling schedule across arms per seed.
- Execute free-running Java/Alloy rollouts at updates 250 and 1,000. No early
  stopping or best-checkpoint substitution for the primary final comparison.
- Two explicit feedback queries, 256 decisions, 30-second worker-response and
  120-second episode deadlines. Existing commit checks and two-direction final
  semantic validation remain authoritative. Matched uniform/no-op controls.
- Record all eight failures as well as successes. Select by final validated
  repairs across seeds, smaller model breaking ties. This is training-set
  learnability, not held-out evidence or stable superiority on the corpus.

Record full-teacher loss, head accuracy and joint-decision accuracy at start/end;
pre-clipping gradient norm, module gradient norms, clipping frequency and actual
parameter update norm; runtime, peak allocated/reserved CUDA memory, inputs,
preflight and output hashes. A nonzero gradient or low teacher-forced loss alone
does not pass the eight-repair gate. Larger consumers remain unrun if it fails.
