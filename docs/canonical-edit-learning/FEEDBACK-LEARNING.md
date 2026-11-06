# Bounded Feedback Learning

This extension implements the small learned gates of `feedback-intent-path-v1`.
It does not authorize the large model runs when a gate fails. Teacher replay,
training-set free-running repair, and held-out generalization are distinct results.

## Proof Before Implementation

`formal/FeedbackLearning.lean` models ten boundary obligations: read-only metadata
preserves the metric component; bijective address transport round-trips edges;
roles, positions and multiplicity survive transport; labels/private records do
not enter encoded inputs or fixed-policy predictions; query counts stay bounded;
failed or below-threshold learnability gates cannot pass.

These are pure dataflow and arithmetic theorems. The implementation must still
be checked for correspondence. They do not prove graph neural network accuracy,
Alloy solver completeness, floating-point equivariance, or universal Java/Python
refinement. Lean, Java, Alloy/SAT4J, Python, PyTorch, CUDA and the OS remain TCB.

## Implementation Boundary

Retain structured exact types in the certified repair projection without changing
its metric fields or comparison operations. Export canonical nodes, typed ports,
phase references and binder data into numeric tables. Only symbols already in
the predicate's permitted source namespace may resolve a canonical reference.
Unsupported semantic payloads are rejected, never hashed or silently erased.

The learner consumes public observations only. Teacher labels are separate loss
targets, never features. Address-valued columns become graph edges or pointer
head candidates; no learned row-ID embedding is permitted. Literal numeric values
are distinct from pointers. Static categories use bounded dictionaries.

Train a small structured graph policy first, selecting semantic controls followed
by conditional argument heads. Execute its own predictions through the same Java
worker used for replay. Compare with matched no-op and uniform masked controls.
The controller enforces the teacher's two-query budget, fresh revision/turn,
256 decisions and subprocess deadlines. A final SAT-based validation, not a
teacher-forced score or a STOP prediction, determines repair success.

## Bounded Gate Schedule

Use the frozen training split in task-file order, with nested sets of 1, 8 and 64.
Caps are 1,000, 1,000 and 5,000 optimizer updates; thresholds are 1, 8 and 60
validated repairs, with every generated action structurally well formed.
Do not select these tasks by teacher success. Missing teachers stay failures.
Stop at the first failed gate and record the cause; do not increase model size,
change the target, or weaken validation. This is a learnability diagnostic,
not a final three-seed comparison or evidence of held-out repair ability.
