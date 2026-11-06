# Expanded Feedback GNN Study

The author requested larger models and more data after the eight-task diagnostic.
This is a new, bounded experiment, not a retrospective change to that failed
gate. The inference contract and Java/Alloy success boundary are unchanged.

## Proof And Scope

`formal/FeedbackScaling.lean` compiles before this implementation. Ten model
theorems specify question-level split determinism, exclusion of held-out gradients,
teacher-independent selection, quota bounds, retention of failed attempts in
denominators, validation-only selection, smaller-model tie breaking, and cache
transparency under the invariant that an entry belongs to its exact key. These
are dataflow models plus bounded correspondence tests, not complete Python/Java
refinement or proofs that larger models will learn. Existing TCB remains explicit.

## Dataset

Select up to 512 train, 64 validation and 96 evaluation source candidates by
SHA-256 ordering, at most 32 per question, from the existing six-problem
non-temporal scope: classroom_fol, graphs, socialMedia, coursesNew, cv_v1,
trash_fol. Keep the existing `corpus-v1` question split. Freeze the selection
before parsing, observing solver outcomes or constructing teachers. Do not refill
quotas based on successes. Keep source hashes and every preparation outcome.

Use the existing `RepairCorpusSource` adapter to append its independently scoped
run command to a derived copy. Never edit classified-data. Remove AST-identical
student/oracle pairs and duplicate AST pairs within a question, recording them.
Other preparation failures remain explicit coverage failures. Generate and freshly
replay labels **only for train**. Missing teachers never create additional
successful samples or cause a replacement draw. Training optimizes on available
validated teachers; reports retain the full attempted/eligible counts.

Validation and evaluation do not use teachers. Every eligible selected held-out
task remains in its split denominator, including unsupported observations,
exceptions, exhausted episodes and semantic failures. Count no-op and uniformly
sampled masked actions under the same query and decision limits. Report whole
question clusters and the paired learned-minus-random success difference.

## Models And Optimization

Screen seed 17 for five configurations: GIN 128x3 (size control), GIN 256x4,
GIN 512x4, GraphSAGE 256x4, and the no-message 256x4 control. All share the exact
existing graph adapter and conditional public action heads. Report parameter
counts, actual memory and runtime; no pretrained features or privileged tokens.

Each configuration receives 3,000 AdamW updates, effective batch 16 semantic
decisions, equal task-then-decision sampling schedules, weight decay 0.001,
gradient clipping at 1, and a common 100-update warmup then cosine schedule
from 0.0003 to 0.00003. This lower learning rate addresses the frequent clipping
observed previously; the 128-wide control uses it too. One micro-example at a
time keeps activation memory bounded. Use CPU teacher caching rather than
retaining the expanded dataset on the GPU. Stop on nonfinite training values.
Log a fixed 128-decision training probe, not a full-training-set accuracy claim.
Record host RSS and the explicitly estimated one-GiB teacher-cache budget;
neither the estimate nor PyTorch allocation includes every process allocation.
Encode only a requested teacher decision, memoizing it under task/decision keys.
Estimate raw record memory from compact JSON rather than indentation bytes;
compare cached/cold tensors and labels in a real replay regression.

Evaluate each final checkpoint on all validation tasks. Select by validation
repairs; smaller parameter count breaks ties, then fixed configuration order.
Write the locked selection before any model evaluates the test split. Train
fresh seeds 29 and 43 for that exact configuration, without further selection;
test all three seeds and matched controls. This is a screening experiment plus
a three-seed evaluation of the selected configuration, not three seeds per arm.

All rollouts preserve two explicit queries, 256 decisions, a 30-second worker
response deadline and a 120-second episode deadline. Rejected terms cannot become
successes; only feasible-context, two-direction Alloy acceptance counts. Model
selection never uses evaluation performance. Report failed/unsupported episodes
separately but never silently remove them from eligible denominators.

Source/proof/test manifests must pass before training; freeze dataset and output
hashes and recheck after execution. No static rewrite, certificate authority or
production repair acceptance changes are part of this study. Later LLM and local
Transformer stages must consume this same clean interface and split rather than
reuse historical privileged-input trainers. This study does not run them.
