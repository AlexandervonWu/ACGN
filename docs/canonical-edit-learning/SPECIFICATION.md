# Hybrid Edit Transformer: Specification And Research Plan

Status: specification-first, from-scratch model prototype. This is not a trained
4B repair model or a claim of corpus-level improvement. The user selected
from-scratch training; no pretrained/frozen random backbone is substituted.
The approximate 4B target is subordinate to the 16-GB RTX 5080 and available
host RAM. Lean model contracts were compiled before this document and code.

## Objective

Learn to rank **executable, typed repair actions**, combining:

1. The actual typed e-class/e-node incidence structure, not just one unfolded
   representative or an aggregate graph vector.
2. The finite families of edits already charged by the canonical repair metric.
3. Concrete positive/negative Alloy instances and how proposed actions change
   candidate behavior on those instances.

The learner changes a faulty predicate toward a correct one. Such edits are
usually NOT equalities. It may not insert them as zero-cost e-graph equations,
mint certificates, modify the bootstrap rewrite theory, or change distance units.

The prior failure evidence is in [the ledger](../repair-search/FAILURE-MODES.md).
The design tests three explanations separately: inadequate action coverage,
insufficient structural/behavioral input, and poor learned action ranking.

## Preserve The Metric

Let `C_P(s)` be the current certified repair projection of source `s` in fixed
profile `P`. Let `D` be `QuotientRepairDistance.evaluate`, preserving the
`CanonicalDistance` edit semantics, not representative-tree distance.

`D = D_temporal + D_quantifier + D_matrix`.

Keep the implementation's minimum quantifier alignments, coherent owner-scoped
alpha alignments, maximum-compatible binding matching and minimum-cost unordered
operand assignments. Matrix minimization is conditional on the admitted minimum
quantifier alignments; do not replace it with a different global objective.
Certificate-derived alternatives, temporal imports and exchange orbits remain
legality data, not additional editable labels. Pure display renaming is free.

Current facts that constrain the implementation:

- `core/CanonicalDistance.java:eGraphEdits` sorts unordered children and performs
  a sequence traceback, whereas its scalar distance uses assignment. Its temporal
  explanation also differs from the ordered tree-distance implementation. These
  human-readable strings are not established optimal, executable demonstrations.
- `metric/QuotientRepairDistance.java` returns component costs and statistics, not
  a public structured source-replay witness. Extracting such a witness is work.
- `RepairAction.Kind` currently exposes operator replacement, NOT wrap/unwrap,
  quantifier modification and STOP. It is smaller than the metric dictionary.
- `RepairObservation` expands a repair projection and hashes/clips some features
  downstream. It is not the full typed incidence graph required here.
- Producer-observation consistency is not independent certificate replay.

Do not patch the metric to make these bridges easier, train on explanatory text
as if it were a proof, or assume that a scalar distance is already the shortest
executable source-edit path length.

## Finite Edit Dictionary

The nine semantic charge families are:

- `TEMPORAL_INSERT`, `TEMPORAL_DELETE`, `TEMPORAL_UPDATE`.
- `BINDING_INSERT`, `BINDING_DELETE`, `BINDING_UPDATE`.
- `MATRIX_INSERT`, `MATRIX_DELETE`, `MATRIX_UPDATE`.

Payloads are typed arguments, not new operation names. A binding update changes
the existing `(quantifier, type, cardinality, disjointness-class)` repair tuple
for one unit, even if several fields change. Type and scope changes must still
produce a legal reparsed candidate; provenance is regenerated, not edited.
Matrix updates distinguish operator, bound-use and semantic payload changes
according to the existing node cost. They do not charge alpha renaming twice.
Subtree insertion/deletion expands to its existing charges, not a one-cost macro.
Temporal node deletion/promotion must follow the actual temporal TED witness,
not assume that temporal deletion always removes an entire subtree.

Each ground action contains: family, profile/theory generation, source revision,
phase path, owner-context/coordinate where relevant, source occurrence, expected
payload, typed replacement arguments, and a charge plan. Source macros may bundle
dependent changes atomically, but retain every underlying charge. STOP/ABSTAIN
are controller outcomes, not semantic edit families. A separate validation request
can ask the solver to check a candidate; it is never an unearned success label.

The finite vocabulary does not imply finitely many possible operands. IDs,
integers, tuple entries, types and user symbols use a finite byte/numeric grammar.
The initial executable slice uses existing source actions with verified family
mappings. Missing insert/delete/phase operations are reported as unsupported,
not silently counted as covered by the existing five action kinds.

## Structured Input And Canonicalization

### Graph Stream

Export from `CertifiedSemanticArtifact.classes()` and typed port records:
e-class IDs, member e-nodes, operator identity, exact type/context, invocation
maps, root and child ports, source occurrence links, binding owners/imports,
disjointness partitions and dependency relations. Preserve sharing and cycles
with references. Also retain the source occurrence graph for realizing edits.

SEQUENCE records preserve position. BAG records retain multiplicity. SET records
deduplicate only using existing certified identity/laws. Integer PLUS is not
relational union. JOIN/ARROW carry their actual dependent-chain evidence and
ordered ports; never invent associativity or cross a CALL/phase barrier.

The canonicalization specification is a lexicographic minimum of a complete
typed incidence encoding over admissible administrative renamings: allocation
IDs are renameable; binders only use certified exchanges; source declarations,
port positions, types and semantic profile are fixed anchors. All cross-stream
references must be transported by the same renaming. Do not call sorting raw
allocation IDs canonicalization. A practical exporter may reuse existing checked
canonical witnesses, but `canon_G` is not assumed to label a whole arbitrary
incidence graph automatically. Unresolved symmetry or exceeded enumeration
budget yields `ENCODING_UNRESOLVED`, not a guessed canonical representative.

This guarantees nothing beyond the admitted renaming relation: alpha-admissible
and representation-isomorphic graphs should encode alike; arbitrary semantically
equivalent formulas need not have identical whole saturation graphs.

### Counterexample Stream

Use structured `A4Solution` tuples, not parsed pretty-print strings. A record
contains profile/bank version, context validity, expected Boolean result,
signature memberships, ordered relation tuples and concrete integer values.
Atoms are local to one world. Canonicalize a finite world under type-preserving
atom bijections while fixing relation identities, integers, tuple positions and
labels. Sort the resulting world records; transport every atom reference and
every evaluation annotation. Arbitrary enumeration IDs must not become features.
Retain the inverse map solely for readable explanations.

Optional checked annotations expose evaluation of selected source subexpressions
under explicit binder environments, and each candidate action's true/false
behavior on the same bank. Do not evaluate an open subterm without an environment.
Evaluation data comes from the candidate interpreter; the hidden oracle supplies
labels only, never its syntax. A learned witness-agreement head is auxiliary,
not a replacement for interpretation or solver validation.

### Action Stream

Canonicalize ground action descriptors together with their source/graph pointers.
Keep all equally optimal actions; arbitrary sorting or original variable names
must not create conflicting supervision. For symmetric actions, transport their
probabilities and targets equivariantly or sum target probability over the orbit.
Do not identify actions that lead to different source occurrences without a
checked action-realization correspondence.

The wire vocabulary has 4,096 IDs: structural tags, versioned operator/edit tags,
bytes, numeric delimiters and reserved tokens. Minimal length-delimited integers
and byte strings retain exact payloads. No hash bucket or clipped count is an
equality key. Require `decode(encode(x)) = x` for normalized records. The full
source exporter/atom canonicalizer is a separate obligation from this codec.

## Dataset And Labels

For each training faulty predicate `s`, form a nonempty pool `T_s` of oracle and
AST-distinct correct-student bodies, co-equally. Matching a question ID is not
enough: instantiate each body in the same source context and validate it against
the oracle/profile before admitting it as a target. Reuse prepared targets and
cache by source, profile, theory/metric versions and actual pool hash.

Define `r(s) = min_{t in T_s} D(C_P(s), C_P(t))`.

For each executable action `a`, independently prepare `s_a` and compute the
offline label `delta(s,a) = r(s) - r(s_a)`. Predict this from public observations;
do not provide the correct body, exact target distance, target pool identities or
ground-truth script to the deployed policy. Target-dependent labels are training
supervision, not inference features. Semantic failures still yield behavioral
counterexamples; they do not prove that a multi-edit continuation is hopeless.

The first teacher uses the set `A*(s) = argmin_a r(s_a)` within the admitted menu.
This is an exact residual-distance ranking, NOT a claim of shortest repair paths.
If no action decreases the residual, record `NO_STRICT_IMPROVEMENT`, retain the
state, and use bounded search/trajectories rather than teaching an unvalidated
STOP. A distance resource-limit exception is a censored label, not zero or an
infinite negative. Allow temporary increases: no Bellman or triangle property
relating this metric to executable source actions has been established.

Where structured minimum-cost trace extraction is implemented, admit a trace
only after checking alignment witnesses, sum of component charges, equality to
the unchanged scalar metric, source replay, type/profile preservation and final
semantic validation. Some decomposed metric plans may not have a well-typed
intermediate source realization. Such cases are `UNREALIZABLE_TRACE`; keep the
scalar metric, and use atomic multi-charge plans or distance-labelled candidates.

Split by question group before deriving targets, mutations, counterexamples,
macros or templates. Deduplicate AST-identical pairs as required by the existing
experiment invariant. Report same-question reference-assisted repair as a
different setting from held-out-question generalization. No held-out truth pool
may enter retrieval, training, selection or model context. Counterexample-guided
dataset aggregation may update weights only from training questions.

## Learning Possibilities

1. **Candidate ranker first.** A linear/small model ranks the exact same typed
   menu using local structural features and per-action witness disagreements.
   This isolates data and menu quality before scale is credited with a benefit.
2. **Hybrid transformer.** Jointly contextualize the three canonical streams;
   select ground action IDs rather than generate Alloy. This is the primary
   from-scratch model requested here.
3. **Typed edit-program retrieval.** Retrieve training-only abstract edit motifs
   with scoped holes, then instantiate by type/scope checks. Every macro has
   source replay and full charge accounting; a retrieved equality is not a rule.
4. **Search distillation / counterexample aggregation.** Collect checked repair
   trajectories on training questions, supervise tied next actions, and train
   against hard semantic counterexamples. Follow with bounded policy-guided
   search. Do not resume pure sparse-reward exploration as the only teacher.

## From-Scratch Transformer

Reference backbone: decoder-only GQA, RMSNorm, rotary positions, SwiGLU, no
biases, 4,096-token tied input/output vocabulary. Width 3,072; 24 query heads,
8 KV heads of dimension 128; feed-forward width 8,192; 32/36/40 layers.
Forty layers have 4,039,363,584 backbone parameters and 4,058,274,816 including
two pointer projections, nine-family head, two-label witness head and value head.
The 32/36-layer configurations are about 3.25/3.66B. All parameters start random
and are trainable; no frozen-random prefix is called from-scratch full training.

### Precision/Capacity Study

The user also permits INT4 and requests a precision/capacity tradeoff. Start with
the same width/head/FF configuration and vary depth and weight precision:

- BF16: 16, 24 and 32 layers (1.642, 2.448 and 3.253B parameters).
- W8A16: 32 and 40 layers (3.253 and 4.058B).
- W4A16: 32, 40 and 48 layers (3.253, 4.058 and 4.864B).

The shared 32-layer configurations isolate precision; the 40-layer W8/W4 pair
adds a second matched-size comparison. Other pairs measure the requested
smaller/high-bit versus larger/low-bit tradeoff. These are candidates, not a
claim that all fit or that low precision improves repair. Approximately 4B is
an exploration target, not a requirement to allocate the largest possible model.

W4/W8 mean groupwise symmetric **weight** quantization in backbone linear
projections, with group size 128. Activations, embedding, RMSNorm and task heads
remain higher precision. Attention reductions follow the selected kernel's
declared accumulation behavior. Record scales, padding and non-quantized weights
in storage accounting. Neither label means every tensor is 4/8-bit.

The first implementation is quantization-aware training (QAT): quantized and
dequantized forward weights, and a documented identity straight-through
surrogate derivative for trainable master weights. This is a surrogate optimizer,
not the true derivative of rounding. Its dense fake-quant tensors do NOT save
training VRAM. INT4 packing is a separate round-trip storage test, not a native
INT4 matrix-multiply or backward kernel. No frozen quantized random backbone or
adapter-only training is substituted for the requested from-scratch training.

A genuinely low-memory training backend needs CPU/block-streamed masters,
bounded gradient staging and factored/streamed optimizer state, or a separately
validated trainable packed implementation. Compare its update to the reference
on small tensors before large fit tests. Never mutate weights during the same
backward pass while checkpointed layers may still recompute against them.
Packing saved checkpoints alone does not qualify as low-memory training.

Select by held-out repair success, with smaller parameter count breaking ties
as requested. Also report VRAM, RAM, wall time, examples/tokens and inference
latency. Compare both equal-token budgets and fixed-wall-time budgets; a slow
offloaded model must not receive unlimited extra compute. Freeze selection on
validation and evaluate the selected configuration once on the held-out split.

Input order is GRAPH, COUNTEREXAMPLES, ACTIONS, QUERY. Every action-end position
can attend to graph and witnesses; QUERY attends to all action records. For
candidate `i`, score `z_i = <Wq h_QUERY, Wk h_ACTION_i>/sqrt(d)` with an exact
legal-action mask, followed by softmax over the finite current menu. Family,
witness and value heads are training auxiliaries. A closed, versioned input
grammar and a menu-bound output remove free-form JSON/Alloy generation failures.
Serialization retains graph incidence, but this alone does not guarantee the
neural network learns to use it.

Train in this order: source-graph record prediction/reconstruction on training
data; checked action-set imitation; behavior prediction on interpreted worlds;
then training-only counterexample aggregation and optional search distillation.
The primary imitation objective is `-log sum_{a in A*(s)} pi(a | observation)`.
Add witnessed Boolean cross-entropy and residual/gain regression with separately
reported ablations. An optional token loss may use the tied vocabulary head.
Do not describe residual regression as proof of repairability or reasoning.

Start with short exact packets, microbatch one and activation checkpointing.
Packets beyond the declared token budget are explicitly excluded or handled by
a separately specified lossless chunking design, never silently truncated.
The initial context limit is a capacity parameter, not a promise that all
canonical graphs and witness banks fit 2,048 tokens.

## Hardware Gate

Full conventional Adam storage at a nominal 16 bytes/parameter exceeds 60 GiB
for the reference backbone, before activations. It cannot run resident on this
GPU, and host RAM is not assumed to make it free. BF16 weights alone use about
7.56 GiB for the complete 40-layer model. This is NOT a training peak bound.
Its FP32 master and FP32 gradient copies alone need about 30.24 GiB, already
exceeding this host's presently available RAM. At 48 layers those two copies
need 36.24 GiB. Offload-to-CPU alone therefore does not solve the larger cases.
Full-sized FP32 gradient accumulation must be replaced by bounded staging or
explicit disk spill before such a backend is admitted; optimizer and checkpoint
save/reload peaks must also be measured. Swap is not an assumed memory budget.

The first functional probe uses BF16, activation checkpointing and deferred
CPU gradient storage with a simple SGD update; gradients are computed against
one unchanged weight snapshot and parameters update only after backward ends.
No early in-backward parameter mutation or frozen-layer substitution is allowed.
Production optimizer choice remains an ablation: factored/offloaded optimizers
need their own recurrence, numerical tests and measured RAM/VRAM fit. A plain
SGD smoke step does not demonstrate effective large-model training.

Preflight each size with forward, loss, backward, update, serialization and
reload. Cap allocator use below device capacity, measure whole-process VRAM and
host RSS, reserve host RAM, and shrink layers/context/microbatch only with a new
recorded configuration. Use no GPU memory padding. Choose the largest fitting
configuration only for the size study, not as a presumed performance winner.
No full 4B training begins before real-data labels and coverage gates below pass.
The initial tiny QAT prototype is resident and uses ordinary SGD; the deferred
CPU-gradient probe above is a subsequent backend task, not an implemented claim.

## Finite Acceptance Plan

Stage 0: round-trip graph/world/action codecs; actual source-to-export comparison;
SEQ/BAG/SET, alpha/phase/disjointness, CALL and dependent JOIN regressions.

Stage 1: measure menu coverage using bounded exhaustive search on a frozen small
split. Distinguish complete depth exhaustion, unsupported source operations and
resource-censored enumeration. Reject candidate/trace mismatches before training.

Stage 2: compare small ranker, structural-only, witness-only and full hybrid
inputs using the same menus, examples, updates and budgets. Preserve all negative
outcomes. Loss reduction or synthetic fixture fitting is a functionality check,
not a repair result.

Stage 3: try the fitting precision/capacity variants above from scratch on the admitted dataset.
Freeze train/validation/test groups, source manifests, selection rule and three
training seeds before running. Repair success is primary; smaller wins ties.
Compare matched uniform/random/PUCT controls plus actual TAR as a separately
budgeted external baseline. Report per-question success, candidate/solver/time
budgets, action coverage, exclusions, tokens/updates, memory and all failures.

Final success still requires a satisfiable fixed context and two directional
UNSAT checks under the declared profile. Certificates/replay retain their current
separate authority. A model choice, learned explanation, distance zero or finite
bank pass cannot replace that boundary. No full-application refinement claim is
made by the standalone Lean contracts or a prototype smoke test.
