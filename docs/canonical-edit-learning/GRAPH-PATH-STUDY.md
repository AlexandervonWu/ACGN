# Canonical Graph To Complete Repair Program

## Change From The Ranker

The earlier four-template, one-step menu had a test repair ceiling of 2/192.
This experiment removes that menu. Its supervised pair is:

`key = faulty canonical repair graph; value = complete graph construction patch`.

The key includes the module's declaration schema and the faulty predicate's
temporal topology, phase-local bindings and matrix graph. The correct graph is
used only to construct the target program. No oracle body, correct-graph nodes,
teacher distance, or ground-truth script enters the inference prefix. This study
does not require counterexamples as input and does not compute per-edit rewards.

The graph is the certificate-integrated repair projection, with structural sharing
represented by node references. It is not the full proof-heavy saturation graph.
Editable labels, exact type/domain payloads and explicit phase/binder coordinates
are observations. Structured signature/field names use module-local generic IDs;
opaque semantic payloads are retained losslessly rather than guessed from spelling.
The module's source-only original-to-generic symbol table is also included, so
names of declarations unused by the faulty body are still recoverable. This
input gap was found and corrected before training; retained initial exports are
re-encoded without rerunning Java or selecting by repairability.
Proof objects, source hashes and certified-orbit authority remain sidecars.
The exported candidate graph is not certificate authority or an equality key.

## Complete Programs

Programs recursively use `COPY(source-node-id)` and
`BUILD(label, child-programs...)`, followed by an explicit end marker. Compilation
reuses an identical source subgraph when present and otherwise builds the target
node from recursively compiled children. Root selection replaces the old root;
old unreachable nodes disappear from the resulting graph. Thus programs can
insert, delete and restructure subgraphs, change bindings and temporal topology,
and terminate without making any change. There is no one-edit or four-template
restriction. COPY is checked against the source graph only, never a target table.
COPY preserves graph bytes, not denotation under arbitrary rebinding. Moving a
copied open subgraph into a different binder context is still a proposed edit;
it does not acquire alpha-equivalence or certificate authority by being copied.

This is a persistent graph patch, not an optimal canonical-distance edit witness.
Targets are the paired oracle predicates in the source files, not a newly
minimized selection from the augmented pool of all correct answers.
It does not change the metric's costs or claim that BUILD costs one metric unit.
The old human-readable diagnostic edit strings are retained as diagnostics, not
used as executable training targets. Every admitted pair must replay to its
complete target graph before training. A token or resource bound excludes the
entire pair explicitly; target paths are never truncated.

## Proof Before Implementation

`formal/GraphRepair.lean` compiles eight standalone theorems before code changes:
complete construction under sound COPY lookup; existence without a candidate
menu; COPY lookup behavior; deterministic replay; key/target separation;
target-only supervised positions and preserved target length; and a separate
semantic acceptance gate requiring reparse, feasibility and two UNSAT checks.
Finite n-ary records have a binary term encoding in this model. Concrete graph,
JSON, token and Java correspondence is checked by regression tests and exhaustive
replay of exported training pairs, not asserted as a whole-program Lean proof.
Lean, Java, Python, the canonicalizer, PyTorch/CUDA and numerical kernels retain
their declared trust boundaries. This is not a mechanical closure claim.

## Training And Evaluation

Use the existing approximately 508M, 20-layer backbone with tied vocabulary
output. Removing menu-pointer and auxiliary classification heads leaves
503,576,064 trainable parameters at vocabulary 128. Train from scratch by
teacher-forced next-token prediction over the complete patch, masking the input
prefix and padding from the loss. Inference starts from the faulty graph alone.
Grammar checks constrain COPY references and record structure, not the available
semantic transformations. Generation stops at EOS or the recorded token limit.

Split by question, deduplicate identical graph pairs within each question, and
record ambiguous keys with multiple correct programs rather than silently
overwriting dictionary entries. Retain all admitted pairs in the training split;
do not select them by single-edit repairability. Validation alone selects the
checkpoint. Preserve prior negative results separately.
If an identical input key occurs across splits, retain it only in the earliest
split in the fixed order train, validation, evaluation. Within-split alternative
targets are retained. This input-only purge prevents an exact training input
from being presented as a novel held-out case; it never uses model outcomes.

The first bounded run freezes 4096 source attempts, 200 per question, 12 export
workers, seed 20261003, 8 epochs, effective batch 128, microbatch 8, context 4096,
and maximum complete target 1536. BF16 computation uses FP32 master parameters
with Adafactor at peak learning rate 0.0001, 10% warmup and cosine decay to 10%.
Loss is summed over target tokens and divided by the effective batch's target
token count; input and padding are masked. The checkpoint with minimum validation
target-token loss is selected, earliest on ties. This is a fixed surrogate
selection criterion, not a claim that token loss measures repair success.
All held-out programs are then generated greedily. This is one bounded training
run, not a convergence or scaling study.
After selection, the first 64 training record IDs in lexical order are also
decoded as a memorization diagnostic. This fixed diagnostic is not held-out
evidence and never affects model selection.
The preflight increased microbatch 4 to 8 after two maximum-context updates
measured 8.94 GiB allocated / 10.47 GiB reserved, within the approximately 15 GiB
GPU budget. The probe is synthetic, not evidence of repair performance.

Report teacher-forced target loss, free-running syntax/replay validity, exact
program match, and exact reconstructed target-graph match. **Graph match is not
reported as solver-verified Alloy repair.** A generated candidate needs a source
realization followed by the existing semantic gate before that stronger claim.
That execution bridge is a separately reported boundary, not a reason to shrink
the learning task back to the old menu. Dataset classification/oracle status is
supervision provenance, not a new independent proof of equivalence.
Exact target graph match is stricter than matching any semantically correct
repair; it does not minimize over alternative oracle programs or admissible
alpha permutations at evaluation. Conversely, syntactic replay alone is weaker
than type validity. These two facts limit interpretation of the reported rates.
The key contains no natural-language requirement or full module-fact modality;
different intended repairs can share the same faulty graph and schema.
