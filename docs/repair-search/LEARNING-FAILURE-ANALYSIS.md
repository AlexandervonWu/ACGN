# Why The Repair-Learning Experiments Have Not Succeeded

Evidence and literature review: 2026-10-03.

## Conclusion

The completed studies have not established a useful, stable learned repair
advantage. They do **not** establish that GNNs, scratch-trained transformers or
LLM fine-tuning are intrinsically unsuitable for Alloy repair. Different runs
failed at different stages, and several shared limitations concern the learning
problem we constructed rather than the choice of neural architecture.

The strongest explanation supported by this artifact is:

1. The restricted action model often could not express a repair at all.
2. Its distance-based supervision could improve action ranking without solving
   the predicate, and sometimes supplied no preference among actions.
3. Removing the menu exposed a different problem: the scratch model had not
   learned to generate the graph protocol, even on a training sample.
4. Data diversity and optimizer-update budgets were small relative to the
   tasks attempted. More parameters did not provide missing training experience.
5. Some inputs omit intended behavior, while some outputs demand extensive
   bookkeeping. A compact alphabet does not remove either difficulty.
6. The LLM adaptation pilot had a serious output-formation failure and only
   16 or 30 training examples. It is not a strong test of fine-tuning in general.

These conclusions come from existing reports, machine-readable results and
inspection of the learning interfaces. No training, solver experiment or
canonicalization change was made for this review. Literature below supplies
possible mechanisms and experimental designs, not retrospective proof of a
particular cause. This is a targeted review, not a systematic literature survey.

## What Actually Failed

### Graph Policies And Graph Transformers

The larger graph study used 64 training, 16 validation and 24 held-out tasks.
GCN and GAT each obtained 0/48 validation episodes at both completed seeds.
The graph transformer obtained 9/48 and then 0/48; its first fresh test obtained
0/72 versus random's 4/72. The apparent nine successes were three predicates
repeated three times, not nine independent repairs. Seven children completed
before the study was interrupted; there is no completed five-seed comparison.
See the [graph-study conclusion](../rl-graph-learning-conclusion.md).

Earlier fixture studies did have isolated positive results. For example, the
small GAT achieved 12/27 versus random's 8/27, while the validation-selected
larger GAT achieved 6/27. This supports instability and failure to establish
generalization, not the claim that every learned policy always lost.
See the [transformer study](../rl-transformer-results.md).

### From-Scratch 508M Action Ranker

The source-backed run trained 508,313,088 parameters on 1,192 examples for
eight epochs, with 80 optimizer updates. Held-out repair was 0/192 at top 1
and 1/192 with three independent single-edit attempts. Random expectations
were 0.533 and 1.6 repairs, respectively. Exhaustively trying the entire
admitted one-step menu could repair only **2/192**. Three attempts were not
three successive edits. See the [report](../canonical-edit-learning/CORPUS-RESULTS.md)
and [comparison JSON](../canonical-edit-learning/results/corpus_508m_20261003/comparison.json).

Thus there was a measured 1.04% coverage ceiling, before considering the model.
This particular ceiling has not been measured for every earlier GNN menu and
must not be retroactively attributed to all of them.

### From-Scratch Complete Graph-Program Model

The replacement trained 503,576,064 parameters on 2,088 pairs for eight epochs,
with 136 optimizer updates. It could express every admitted teacher target:
all 3,184 exported programs replayed exactly, without the old action menu.
Nevertheless, it generated 0/652 exact held-out graphs and 0/64 exact graphs
on a fixed training sample. None of either sample had the required `ROOT`
label. Of the 652 test outputs, 376 were syntactically replayable, 235 were
invalid and 41 exhausted the token budget.

This is a **graph-generation failure**, not a measured zero behavioral-repair
rate: graph-to-Alloy realization and solver evaluation were not implemented
for generated outputs. Exact graph matching is stricter than semantic repair,
but that distinction does not explain the absence of even the required root.
See the [report](../canonical-edit-learning/GRAPH-PATH-RESULTS.md),
[results JSON](../canonical-edit-learning/results/graph_path_504m_20261003/results.json)
and [training diagnostic](../canonical-edit-learning/results/graph_path_504m_20261003/training-diagnostic.json).

### Local LLM And Fine-Tuning

On eight held-out predicates, the local Q3 base model repaired 1/8, supervised
LoRA repaired 0/8 and counterexample-guided LoRA repaired 0/8. Both adapters
were genuinely trained, saved, reloaded, exported and evaluated. Each trained
2,162,688 parameters, rank 8, on the last four decoder MLP layers. SFT used
16 examples/updates; CE used 30 examples/updates, including 14 feedback examples.

SFT's 32 proposals included 28 JSON-format failures and four semantic
counterexamples. CE's 32 proposals included two format failures and 30 semantic
counterexamples. These are proposals for eight tasks, not 32 independent tasks.
The local `Qwen3.8` alias refers to recorded configuration architecture
`Qwen3_5ForConditionalGeneration`; names alone do not establish model provenance.
See the [completed pilot](RESULTS.md) and [comparison JSON](results/comparison.json).

### Verifier-Guided Search And TAR

The small AlphaProof-inspired learner found one repair in 16 training searches.
Learned PUCT, uniform PUCT and random tree exploration each obtained 0/24 over
the same eight held-out tasks and three search seeds. TAR repaired 4/8, and
every reported TAR repair passed the common validator. TAR had a broader
mutation inventory and a different budget. It shows that some tasks were
repairable by another method, not that search universally beats learning or
that the neural menus contained those solutions. See the [pilot report](RESULTS.md).

## Explanations And Their Evidence

### LF01: Action Coverage Can Dominate Policy Quality

**Established for the one-step ranker.** No policy can select a successful
action that is absent from its menu. Increasing width, depth or training time
cannot raise that run's 2/192 ceiling. Fail-closed source editing and a limited
set of executable edit templates were different design decisions: retaining
semantic validation does not require limiting all repairs to those templates.

The complete graph-program experiment removes this explanation for its
admitted teacher pairs. All teacher programs are representable and replay
correctly. Its zero result therefore cannot be blamed on the old menu, although
the subsequent executable source-repair bridge remains open.

### LF02: The Training Objective Was Not The Final Repair Objective

**Established mismatch; strength of its causal effect is unmeasured.** The
ranker's teacher retained actions minimizing residual canonical distance.
That is a legitimate structural objective, but not the same as producing a
behaviorally correct predicate within the action budget.

The model chose a teacher-optimal action on 140/192 test cases, versus random's
expected 128.819, yet repaired none at top 1. Moreover, 74/192 test cases and
475 training cases tied across every menu action. Such a set-valued target
cannot teach a preference among those actions. The forced model action raised
mean distance from 16.3177 to 16.6250; the menu had no STOP option. A lower loss
or a better choice than random was not necessarily better than doing nothing.
These observations are recorded in the [ranker report](../canonical-edit-learning/CORPUS-RESULTS.md).

This does not invalidate the canonical repair metric or justify changing its
semantics. A metric on the quotient does not promise that every restricted
source-action neighborhood contains a decreasing step, or that every decrease
is a complete behavioral repair.

The graph-program run instead minimized target-token cross entropy and selected
its checkpoint by validation token loss. That was explicitly a surrogate,
not the earlier repair-success selection criterion. Training loss fell from
3.979137 to 1.949738, while complete training-sample generation still scored
zero. Token prediction, graph reconstruction and verified repair must remain
separate reported quantities.

### LF03: Scratch Training Had Not Mastered The Task Before Generalization

**Observed non-mastery; insufficient optimization is a plausible explanation.**
The complete-program model had 2,088 distinct training pairs and only 136
updates. Its failed 64-case training diagnostic means unseen-question transfer
cannot be the sole explanation. The model had not demonstrated memorization
of real training targets under free generation. This is not the usual evidence
for overfitting, where training succeeds and test performance collapses.

The curves were still improving, and no convergence study was performed. Large
effective batches also meant few optimizer steps per epoch. They were chosen
for the hardware experiment, not shown to be optimal for this dataset. Neither
under-capacity nor a particular optimizer defect has been established.

Hoffmann et al. study the joint allocation of parameters and training tokens;
their results motivate considering data and optimization alongside capacity.
They do **not** license applying a universal tokens-per-parameter requirement
to this specialized 128-token supervised task. Repeating examples is also not
equivalent to acquiring new repair concepts.
[Training Compute-Optimal Large Language Models](https://arxiv.org/abs/2203.15556).

The 710M/911M hardware and synthetic probes should not be described as completed
real-corpus repair-training comparisons. Memory fit is a prerequisite, not
evidence that a larger learned model is useful.

### LF04: A Small Alphabet Hid A Large Serialization Problem

**Structural errors are observed; the serialization mechanism is an inference.**
The [data audit](../canonical-edit-learning/results/graph_path_504m_20261003/data-audit.json)
records a mean input of 1,890.83 tokens and target of 389.53 tokens, despite a
mean source DAG of about 30 nodes. These means cover all admitted splits;
they are not training-only token totals. Input includes schema and symbol-table
metadata as well as the predicate. A 128-ID vocabulary can still encode long
strings, reference numbers, arbitrary record trees and many possible programs.

In the [codec](../../experiments/graph_repair/codec.py), unknown strings use
UTF-8 hex escapes, source node IDs are implicit postorder indices, and COPY
references are generated as numbers rather than selected by a node-pointer
head. The model must learn record fields and references as well as semantic
edit decisions. Per-target-token loss gives every such position weight; the
fraction spent on bookkeeping versus repair decisions has not been measured.

The decoder masks generic record syntax, not the complete canonical graph
schema. It can begin a well-formed record that is not a predicate root, or
finish a reference that is then rejected. In one observed prefix it generates
`BUILD, LIST, 7` where the teacher needs `BUILD, LIST, 1, ROOT`. The test failures
include 105 source-reference errors, 79 noncanonical numbers and 51 excessive
program depths. This is not rejection by the equality-certificate checker.

Teacher forcing supplies correct previous tokens during training; generation
uses the model's own previous tokens. Ross et al. analyze this kind of sequential
distribution mismatch. It plausibly amplifies our early structural errors, but
does not explain away the first wrong root-field decision, which already has
a correct prefix. [DAgger paper](https://proceedings.mlr.press/v15/ross11a.html).

Grammar-based program generation and input-pointer architectures offer relevant
alternatives to asking a model to rediscover syntax and address encoding.
They motivate a diagnostic comparison, not a prediction of success on Alloy.
[Yin and Neubig](https://aclanthology.org/P17-1041/),
[Pointer Networks](https://arxiv.org/abs/1506.03134).

### LF05: A Graph Encoder Does Not Automatically Receive The Needed Semantics

**Interface limitations are observed; GNN expressivity failure is unproven.**
The graph policies consumed an e-graph-derived repair projection, not the full
e-class/member/proof structure. The implementation does retain typed categories,
edge roles, operand positions, bindings and phases. It would be inaccurate to
say that it discarded all ordering or alpha-binding information.

However, [the policy](../../rl/acgn_repair/model.py) uses 4,096 hashed categorical
buckets, position clipping at 65, a mean-pooled global context and aggregate
witness feedback. Hashes are features, not semantic identities; aggregation
is not an injective encoding. The graph transformer adds global attention
through eight latent slots but retains the same general observation contract.
These are potential information bottlenecks, not demonstrated collisions
responsible for particular failed repairs.

Xu et al. show limitations of neighborhood-aggregation expressivity, and
Alon and Yahav study long-range message compression. Both are relevant reasons
to measure information loss before adding layers. Neither proves that our
small, edge-aware repair graphs suffered oversquashing or that GAT/GCN could
not represent the required policy. No distinguishing-graph, oversmoothing or
long-range sensitivity study isolated those causes here.
[GNN expressivity](https://arxiv.org/abs/1810.00826),
[GNN bottlenecks](https://arxiv.org/abs/2006.05205).

### LF06: Faulty Structure Does Not Uniquely Specify Intended Behavior

**Missing input modalities are observed; corpus-level ambiguity is not measured.**
The latest graph key contains declaration schema, source graph and symbol table.
It has no natural-language requirement, full module-fact modality or concrete
counterexamples. This differs from the earlier ranker's richer input. Removing
the menu therefore did not hold every other aspect of the experiment constant.
See the [graph-program protocol](../canonical-edit-learning/GRAPH-PATH-STUDY.md)
and [exporter](../../src/is/fivefivefive/CanDis/CanonicalPairExport.java).

For illustration, the same faulty body `some S` could have been an attempt to
say exactly one `S`, or at least two `S`. Types and faulty syntax alone do not
tell us which was intended. An observer would need a requirement, distinguishing
labelled instances, or an explicit learned prior. This is an illustrative
identifiability issue, not a newly found mislabeled corpus pair. The retained
graph audit found zero ambiguous keys under its grouping; it did not establish
that all future task intentions are recoverable from the key.

Question-disjoint splitting tests generalization to new requirements, not merely
repair of new student attempts at familiar questions. That is valuable, but
harder when the model does not receive those requirements. Generic signature
and relation IDs preserve a structural vocabulary; they do not encode a new
question's intended specification. The latest codec also retains original names
in a source symbol table, so it is not an experiment in removing all name cues.

Canonicalization can quotient known equivalent formulations. It cannot infer
which different meaning the student intended. Nor does an equality quotient
automatically preserve every source-edit occurrence or supply an inverse source
map. The source-backed edit and realization interfaces remain essential.

### LF07: Fine-Tuning Was Small And Its Inference Transfer Was Not Isolated

**Tiny adaptation and unusable outputs are observed; root cause remains open.**
Sixteen supervised updates or thirty CE updates over the last four MLP layers
are a narrow adapter feasibility test. They are not broad instruction training,
full-network adaptation or a comparison across adapter placements and budgets.
The suffix-only design was hardware-motivated, not shown optimal for repair.

SFT's incomplete responses and repetitive escaped whitespace require a
format/termination diagnosis before its score can be interpreted as a clean
test of semantic reasoning. CE reached the semantic validator on 30/32
proposals and still failed, so syntax alone is not the whole story. CE also had
more updates than SFT, confounding any attribution to counterexample content.

Training used an NF4 base; exported adapters were evaluated on a Q3 inference
base. Exact adapter reload and finite gradients passed, but these do not
establish functional equivalence across quantization and serving paths.
Template effects, adapter learning and numerical transfer were not separated.
There is no basis to blame a particular runtime or claim that Q3 caused failure.

LoRA and QLoRA show that parameter-efficient and low-bit adaptation can work in
their evaluated settings. They neither guarantee this suffix-only setup nor
prove compatibility of two differently quantized deployment bases.
[LoRA](https://arxiv.org/abs/2106.09685),
[QLoRA](https://arxiv.org/abs/2305.14314).

### LF08: A Verifier Supplies Correctness Feedback, Not Automatically A Curriculum

**Sparse successes and unequal observations are observed.** The small PUCT
learner saw only one successful training search. Most bounded failures reveal
that this search did not find a solution, not that none exists. Aggregate witness
scores provide less localization information than concrete counterexample
tuples, and even tuples do not prescribe which edit will fix the violation.

The Qwen arms received concrete instances but incomplete structural context;
the graph-program model received no counterexamples. These experiments have
not isolated a common counterexample-reasoning component. Passing a finite
bank is not equivalence, and replacing the final solver gate with bank agreement
would inflate apparent success rather than solve this learning problem.

AlphaProof combines pretraining, supervised state/tactic examples, a large
self-generated problem curriculum and verifier-guided search. Our small
512-feature/64-hidden-unit PUCT network and 16 training searches replicate an
inspiration, not that training system. Its negative result is not a refutation
of the AlphaProof approach.
[AlphaProof training and search](https://www.nature.com/articles/s41586-025-09833-y).

TAR instead encodes domain-specific mutations and search/pruning mechanisms.
This is a useful alternative source of candidate trajectories and a baseline,
but its 4/8 result here is not an equal-budget ablation of learning.
[Timely Specification Repair for Alloy 6](https://haslab.github.io/SpecRep/pubs/SEFM22.pdf).

### LF09: Evaluation Limits What We Can Conclude

**Established methodological limitation.** The studies differ in task subsets,
input features, action languages, number of proposals, training budgets and
success criteria. Do not combine their denominators into an overall repair rate
or use them as a controlled architecture ranking.

The graph-program target is the paired oracle graph, not any semantically valid
repair or the nearest member of the augmented correct pool. Alternative correct
graphs could be penalized by exact match; its zero ROOT-shaped outputs show a
more immediate failure in this run. Conversely, the earlier solver-checked
successes are bounded to their declared profiles, not unbounded Alloy validity.

Repeated episodes, multiple proposals for one task and search seeds are not
independent task samples. Validation selection sometimes reversed on test,
and the larger graph study stopped early. Agarwal et al. explain why a small
number of RL runs warrants uncertainty-aware evaluation. Our repair studies
need question-group-aware reporting and independent training seeds, not merely
more repeats of a few fixtures.
[Statistical Precipice](https://arxiv.org/abs/2108.13264).

## Explanations Not Established By These Results

- **"The certificates were too strict."** No false rejection of a valid generated
  repair was demonstrated in these learning runs. The graph-program failure
  occurs before certificate checking. Keep the acceptance boundary unchanged.
- **"All training signal was lost."** Losses decreased, weights changed, and
  the ranker improved some non-repair statistics. The signal was insufficient
  for the requested outcome, not demonstrably absent.
- **"The model needed more VRAM or parameters."** The completed scratch runs
  fit their budgets. More capacity did not repair missing actions or missing
  task information. No optimum model size was established.
- **"The models overfit."** That may describe some small-fixture transfer results,
  but the graph-program model also failed its real training-sample generation
  diagnostic. Do not substitute a generic explanation for this observation.
- **"The implementation is certainly correct."** Teacher replay, small-model
  tests and selected full-model cache/ordinary-forward agreement narrow the
  failure surface. They are not exhaustive implementation proofs. See the
  [cache diagnostic](../canonical-edit-learning/results/graph_path_504m_20261003/full-model-cache-check.json).
- **"Lean proved the learner should work."** Theorems cover stated abstract
  contracts; they do not prove optimization, empirical generalization, numerical
  kernels or whole Java/Python refinement. See the [assurance ledger](CLAIMS.md).

## Small Experiments That Would Discriminate The Causes

These are proposed follow-ups, **not experiments performed for this document**.
Keep the existing negative runs immutable and register a new protocol for each.

1. **Require real-data memorization before scale.** Train on fixed sets of
   1, 8 and 64 unambiguous pairs. Check free-running complete graphs, not only
   teacher-forced loss. Measure root, operator, binding, reference and termination
   errors separately. If this fails, investigate serialization, gradients,
   optimization and decoding before making generalization claims.
2. **Separate protocol generation from repair choice.** Compare the current
   codec with a schema-aware constructor and explicit source-node pointers.
   Generate deterministic bookkeeping outside the model, but preserve all
   admitted teacher targets and the open-ended multi-step edit language.
   A teacher-forced-root diagnostic can locate errors; it is not a repaired model
   or permission to score the old run as successful.
3. **Measure coverage before policy ranking.** Compute bounded oracle-menu
   reachability for the exact action/horizon configuration; report both overall
   success and success conditional on reachable tasks. Preserve unreachable
   cases in the overall denominator. Include no-op, random and search controls.
4. **Condition on the requested behavior.** Compare the same model/data budget
   with requirements, full permitted module context and concrete labelled
   counterexamples. Separate new attempts at familiar questions from genuinely
   held-out questions. Never expose held-out oracle bodies as inference input.
5. **Localize adapter failure.** Decode identical prompts using the trained NF4
   path before export, then the Q3 serving path. Compare templates, termination,
   format validity and candidate semantics. Match SFT/CE update budgets and
   independently vary adapter placement before assigning a causal explanation.
6. **Connect graph output to actual repair.** Build source realization and retain
   type/profile checks, feasible context and two-direction solver validation.
   Report syntax, graph validity, realizability and behavioral success separately.
   Check alternative valid targets without changing canonical metric semantics
   or granting generated metadata certificate authority.
7. **Only then compare learners.** Freeze reachable action space, observations,
   solver/proposal budgets, splits and selection criteria; use multiple training
   seeds and group-aware intervals. More layers, quantization variants or broader
   sweeps are not substitutes for those controls.

The practical priority is therefore **coverage and task specification, then
learnable executable representation, then optimization and architecture**.
The existing e-graph/certificate machinery can remain the semantic checker and
source of structured information without requiring a neural model to generate
proof metadata or treating every missed repair as an architecture failure.

## Evidence Map And Reuse Boundary

- Historical incidents and scope exclusions: [failure ledger](FAILURE-MODES.md).
- Graph features and layer definitions: [encoder contract](../rl-repair/GRAPH-ENCODERS.md)
  and [policy code](../../rl/acgn_repair/model.py).
- Search/LLM outcomes, prompts and training manifests: [pilot results](RESULTS.md)
  and [retained comparison](results/comparison.json).
- Ranker counts, ties and forced-action distances:
  [corpus results](../canonical-edit-learning/CORPUS-RESULTS.md) and
  [diagnostics](../canonical-edit-learning/results/corpus_508m_20261003/diagnostics.json).
- Graph sizes, replay and train/test outcomes:
  [graph results](../canonical-edit-learning/GRAPH-PATH-RESULTS.md),
  [audit](../canonical-edit-learning/results/graph_path_504m_20261003/data-audit.json),
  [loss history](../canonical-edit-learning/results/graph_path_504m_20261003/history.json)
  and [prefix witness](../canonical-edit-learning/results/graph_path_504m_20261003/root-prefix-diagnostic.json).
- Code reviewed for this synthesis: [codec](../../experiments/graph_repair/codec.py),
  [training/decoding](../../experiments/graph_repair/train.py) and
  [Java exporter](../../src/is/fivefivefive/CanDis/CanonicalPairExport.java).

This document summarizes the current author workspace, including development
files that were already untracked when the review began. It is not a claim
that all learning code, checkpoints or `/tmp` evidence is present in a released
artifact. Run manifests and retained reports identify the experiments; the
repository HEAD alone does not identify dirty-worktree training inputs.
No historical measurements, publication results, model weights, semantic
rules or certificate authority were changed by this analysis.

Documentation checks for this review: 15 grouped assertions against the retained
JSON measurements passed; 58 local links across this document and the two
learning READMEs resolved; `git diff --check` passed. The protected
`distance_results`, `alloy4fun-augmented`, `egraph_ablation` and
`capability_benchmark` trees had no tracked diff. These are documentation/data
consistency checks, not new model evaluations or a formal closure claim.
