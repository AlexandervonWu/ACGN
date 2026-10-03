# Proof And Evidence Ledger

## Proved Model Properties

All eight statements are in `formal/SearchLearning.lean`, checked by Lean 4.33.0
before implementation. The initial failed compilation and subsequent successful
compilation are part of development, not empirical training failures.

1. `two_direction_check`: absence of a contextual extra or missing model entails
   pointwise equivalence. Proof: introduce a contextual world; in each implication,
   the opposite result contradicts the corresponding no-counterexample premise.
2. `counterexample_refutes`: one contextual disagreement refutes equivalence.
   Proof: instantiate the proposed universal equivalence at that witness.
3. `bank_extension`: passing a larger witness list implies passing its tail.
   Proof: embed membership of the tail into membership of the extended list.
4. `true_solution_survives_bank`: an equivalent candidate agrees with every
   context-valid stored witness. Proof: instantiate equivalence at each member.
5. `budget_decreases`: spending one positive natural-number fuel unit strictly
   decreases it. Proof: natural-number arithmetic.
6. `accepted_has_checks`: executable admission requires satisfiable context and
   both recorded UNSAT checks. Proof: expand the Boolean conjunction and project.
7. `accepted_training_is_train`: a training admission has split `train`.
   Proof: simplify the kind branch and project its split condition.
8. `accepted_bound`: executable admission respects the attempt bound.
   Proof: expand the conjunction and project its numeric condition.

## Implementation Connections

`RepairEvaluator.validate` performs the two directional checks in the same
parsed context. `retain` checks context and oracle label before retaining a
witness. The new `witnesses` method exports those stored valuations. No claim of
general solver soundness is derived from the model theorem; bounded Alloy
translation and SAT4J are trusted here.

`RepairEnvironment.propose` reuses `RepairTask.prepare`, including source-boundary,
forbidden-call, semantic-profile, and certified-preparation checks. It is a
whole-body search proposal, not a newly admitted semantic equality. Existing
typed-menu `step` remains unchanged. `RepairStudyWorker` limits attempts and
keeps an isolated task/context per process. It validates bank-passing candidates
and explicitly forced proposals; bank failure does not prune descendants.

`search_study.admit` runs the Lean executable on each reported successful repair
and each positive training target, requiring an exact request echo and recording
the proof hash. Provenance checks compare the task/context and profile identities
with the loaded root. These are checked receipts over solver-produced data,
not independent Lean proofs of the particular Alloy formula.

The policy/value learner uses visit targets and empirically successful search
paths. A zero target means no successful continuation was recorded in that
bounded search, not a proof of unrepairability. Only training tasks update
weights; evaluation checks unchanged parameters.

`language_study.messages` explicitly selects schema, facts, faulty body and
labelled witnesses, excluding the training-only teacher field. Training gold
bodies pass the common solver and Lean admission. CEGIS additions arise only
from actual semantic counterexamples to base-model training proposals. Invalid
syntax is logged, not promoted to semantic counterexample evidence.

## Executed Tests

- `test_search_study.py`: five tests passed. The Lean matrix includes two accepted
  cases and nine rejected cases. The live Java test covers a valid repair,
  oracle-call rejection, body escape, syntax errors, wrong task/profile identities,
  and exclusion of evaluation targets from training admission.
  The fifth test checks reporting of incomplete responses and output-token
  limits separately from semantic counterexamples.
- `RepairEnvironmentTest`: 64 checks passed after the additions.
- `RepairLearningTest`: 38 checks passed after the additions.

The local AIx trainer additionally checks chunked cross-entropy gradients against
native PyTorch, finite nonzero LoRA gradients, changed adapter weights, and exact
adapter save/reload. Those checks must pass on each executed training run before
export. They are numerical tests, not proofs of PyTorch or the quantized model.

## Open Boundaries

Full Java/Python-to-Lean refinement, quantization/adapter semantic preservation,
generalization, statistical superiority, and universal Alloy validity are not
established. The original completed RL gate applies to its old frozen snapshot;
these additions do not inherit its closure status. This pilot reports scoped
proofs and tests, not a new whole-application mechanical closure.

The upstream TAR bundled JAR is hashed and executed, but not asserted byte-for-byte
identical to a fresh build of its current source checkout. Every claimed TAR repair
is independently revalidated under this study's common profile.

The completed pilot additionally retains a fresh-build evidence audit of all
five successful evaluation results and 16 supervised training targets. It checks
source/data hashes, disjoint question groups, base-model provenance, adapter
updates and save/reload, and the two documented reporting/test changes after the
training snapshot. This is a bounded evidence check, not a new refinement proof.
See [the results](RESULTS.md) and `results/audit.json`.

## Resource Incident

The first SFT attempt hit the 13-GiB allocator cap on the 2,260-token dataset
(device still had approximately 1.16 GiB free). Its failure and checkpoints are
retained under the run's `failed/sft-cap13` directory. The CE dataset reaches
2,987 tokens. Both training arms now use non-reentrant checkpointing on the four
resident trainable decoder layers, with the frozen streamed prefix excluded.
The 13-GiB cap, full sequences, examples, optimizer and objective are unchanged.
A detached-input CUDA checkpoint-gradient test and the existing numerical
gradient/save-reload checks gate execution. This is a tested use of the ML TCB,
not a claim of independently proved checkpointing implementation correctness.
