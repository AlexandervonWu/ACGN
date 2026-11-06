# Source-Backed 508M Training Results

## Conclusion

The 508,313,088-parameter model completed eight epochs of full-parameter,
from-scratch training on the RTX 5080. It did **not demonstrate a repair advantage
over random choices**. This is a bounded one-step pilot, not a full-corpus,
multi-step, convergence, or unbounded semantic-equivalence result.

The dominant measured limitation is action coverage: only **2 of 192 held-out
predicates** have any successful repair in the four-template, one-step menu.
The other 190 cannot be repaired by this experiment regardless of model quality.
This makes the test too sparse to rank architectures reliably. A larger model
or more epochs cannot remove that menu's one-step ceiling.

## Data And Protocol

- 4,096 deterministically selected files from six question sets were inspected,
  capped at 160 attempts per question. This is a corpus slice, not all 66,080 files.
- 1,643 AST-distinct examples were admitted. There were 2,453 exclusions and no
  unresolved runtime failures after one bounded transport-error retry.
- Splits were 1,192 training / 221 validation / 192 test examples, from 31 / 7 / 5
  disjoint questions. Another 38 examples from two development-test questions
  were excluded from the final test, not moved into training.
- Source information includes typed AST occurrences, schema, bindings,
  certificate-derived canonical repair views, source-edit pointers and labelled
  user-domain counterexample tuples. Oracle syntax, distances and candidate
  solver outcomes are not policy input. The view is not the full proof graph.
- The separate corpus codec assigns 102 of 128 IDs; it uses generic signatures,
  relations and alpha slots. Unsupported features are excluded, not truncated.
- Labels retain every edit attaining minimum residual canonical distance to the
  paired oracle. This target is not a guarantee of semantic repair.
- Effective batch 128, microbatch 8, BF16 compute, FP32 parameters/gradients,
  Adafactor rate cap 0.00003, seed 19, 80 optimizer updates, 9,536 training
  example exposures. Architecture: 20 layers, width 1,536, GQA 12 query / 4 KV
  heads, feed-forward width 4,096. No pretrained or frozen weights.
- Checkpoint selection used validation top-1 repair, with validation loss breaking
  ties. Epoch 8 was selected. The held-out set was evaluated after that selection.

## Repair Results

- One attempt: **0/192 (0.00%)**, versus random expectation **0.533/192 (0.28%)**.
- Three attempts: **1/192 (0.52%)**, versus random expectation **1.6/192 (0.83%)**.
- Exhaustive one-step upper bound: **2/192 (1.04%)**.
- Same-seed untrained model: 0/192 with one attempt, 2/192 with three.
- Exhaustive candidate-counterexample-score lookahead: 2/192 with one attempt.
  It evaluates every candidate before ranking and is not an equal-cost baseline.

Three attempts mean three different single edits from the original state, not
three sequential edits. Random numbers are exact expectations for sampling
without replacement, not outcomes of a favorable random seed. All successes
require feasible context and UNSAT in both behavioral-difference directions at
independent Alloy run scope 3. No standalone certificate replay or unbounded
equivalence claim is made. Both repairable test cases belong to `socialMedia:inv3`.

The learned-minus-random top-1 difference is -0.28 percentage points, with a
paired question-bootstrap 95% interval of [-0.49, 0.00] over only five clusters.
One seed and two repairable cases support no stable-superiority claim.

## Diagnostic Findings

Training loss fell from 2.8262 to 1.7357; validation loss fell from 2.0924 after
epoch 1 to 1.7327 after epoch 8. These improvements did not yield useful repair.
The held-out top choice belongs to the teacher-optimal set in 140/192 cases,
versus random expectation 128.819/192, but 74 cases have every action tied.
Training similarly contains 475 examples with entirely tied targets.

Mean canonical distance was initially 16.3177. After the model's forced top
choice it was **16.6250**, compared with random expectation 16.9128. Thus the
model is less damaging than random on this secondary mean, but still increases
distance relative to leaving the predicate unchanged. The menu has no STOP
choice and does not guarantee a distance-decreasing edit. The metric proxy,
limited supervision and action coverage must not be confused with full repair.

The largest exclusions were explicit imports (1,163), duplicate AST pairs (462),
and unsupported canonical/source operators or symbols. See the complete ledger;
coverage figures are conditional on these scope gates. The next useful study
is broader executable-edit coverage and multi-step evaluation, before another
model-size increase. That work is not silently substituted into this result.

## Resources And Checks

- Export: 25.58 minutes; training, validation and final evaluation: 20.11 minutes.
- CUDA peak allocated/reserved: **7.151 / 10.666 GiB**. These exclude desktop and
  other external allocations. No OOM or nonfinite update occurred.
- 36 Python tests passed, including live Java/source tests, padding invariance,
  alpha-renaming, label separation and rejection of contradictory solver labels.
- Java `RepairEnvironmentTest`: 64 checks; `RepairLearningTest`: 38 checks.
- Both standalone Lean files compile: 50 prior model theorems and 13 corpus
  contracts. They are abstract contracts, not an end-to-end Java/Python refinement
  or a proof of PyTorch/CUDA, optimization or learning effectiveness.
- Fresh source replay checked seven held-out predicates and 13 edits, including
  all edits of both repairable test cases. Source/profile hashes, transition
  validity, candidate hashes, distances and semantic outcomes agree.
- All 4,096 original source hashes remained unchanged. Protected publication
  result directories and Java canonicalization/certificate semantics were not
  modified. No experiment artifacts were replaced in those directories.

## Retained Artifacts

The [generated report](results/corpus_508m_20261003/summary.md),
[comparison JSON](results/corpus_508m_20261003/comparison.json),
[diagnostics](results/corpus_508m_20261003/diagnostics.json) and
[fresh replay receipt](results/corpus_508m_20261003/replay-receipt.json) are retained
in the repository. The full dataset, logs, source snapshot and checkpoint are at
`/home/augustus/acgn-hybrid508-20261003`.

Checkpoint: `model508/best.pt`, SHA-256
`0ce94a78c983df5810f9f79f8348d711c78dc841f1d329dcc3f79aa9bf68254d`.
This contains weights, configuration and provenance, not optimizer state for
exact resume. The 1.9 GiB checkpoint is kept outside Git. The run's dirty-tree
flag is explicit; source hashes and snapshot bind the measured implementation.

Reproduction uses `scripts/run_hybrid_corpus_training.sh` with a fresh absolute
output directory. See the [protocol](CORPUS-STUDY.md),
[development incidents](CORPUS-INCIDENTS.md), and
[runner instructions](../../experiments/hybrid_edit/README.md).
