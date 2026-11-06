# Proof And Implementation Boundaries

For the current predicate-only, feedback-conditioned table/pointer redesign, see
[INTENT-PATH-OBLIGATIONS.md](INTENT-PATH-OBLIGATIONS.md): 27 new compiled
model theorems and explicitly open feedback, executor, dataflow and learning
correspondences. The historical obligations below are not silently discharged
or inherited by that specification-only redesign.

This is a finite design/prototype ledger, not a completed mechanical-closure
package. The proposed whole source-to-repair system remains BLOCKED on the
implementation correspondences and data bridges below. No application-level
closure result is inherited from standalone theorem compilation.

## Lean Model Contracts

`formal/HybridRepair.lean` uses the Lean kernel and its imported standard
library. It introduces no `sorry`, user-declared `axiom`, `unsafe`, or
`native_decide`. Standard classical reasoning is explicit in the logical
two-direction acceptance theorem; it is not an executable solver proof.

- H01: the edit-family enumeration is exhaustive and has nine entries.
  `dictionary_complete`, `dictionary_size`.
- H02: container record examples preserve sequence order and bag multiplicity;
  bag concatenation commutes and set-code duplication is idempotent.
  `bag_concat_commutes`, `bag_retains_duplicates`, `set_idempotent`,
  `sequence_retains_ports`. No new Alloy operator laws are inferred.
- H03: differing temporal-use phases distinguish binder occurrences.
  `phase_occurrences_distinct`. Actual provenance imports remain Java obligations.
- H04: a codec with a left inverse is injective.
  `lossless_encoding_injective`. The concrete full graph/world codec is missing.
- H05: finite nonempty menu minimization returns an admitted optimal member.
  `choose_member`, `choose_minimal`, `choose_optimal`. Cost-preserving transport
  preserves optimality (`optimal_rename`); cost invariance itself is a premise.
- H06: signed distance gains telescope and positivity means strict decrease.
  `gains_telescope`, `positive_gain_means_drop`. These are not shortest-path or
  triangle-inequality results for source edits.
- H07: the abstract commit gate requires legality, realization and acceptance;
  a rejected action does not commit, and the property holds for any policy.
  `checked_commit_requirements`, `rejected_action_no_commit`,
  `arbitrary_policy_preserves_commit_gate`. Boolean checker soundness is assumed,
  not derived; a changed but still faulty intermediate candidate is not thereby
  a final successful repair.
- H08: fuel decreases; a concrete counterexample refutes equivalence; an
  equivalent solution passes context-valid witnesses; ruling out both
  counterexample directions implies equivalence in the specified world domain.
  `attempt_decreases_fuel`, `counterexample_refutes`,
  `solution_passes_witnesses`, `two_direction_acceptance`. Bounded Alloy scopes
  remain bounded, and source interpretation is not proved here.
- H09: exact parameter counts for the stated architecture and integer storage
  lower bounds. `reference_four_billion`, `reference_model_four_billion`,
  `reference_full_adam_storage_exceeds_16gib`,
  `small_high_precision_candidate`, `large_low_precision_candidate`,
  `cpu_master_and_gradient_cost`, `packed_storage_is_not_training_storage`.
  These do not bound activation/workspace or predict hardware fit.
- H10: two four-bit unsigned codes fit a byte and are exactly recoverable.
  `packed_nibbles_fit_byte`, `packed_nibbles_roundtrip`. This proves packing,
  not lossless real-weight quantization, numerical stability or convergence.
- H11: the pilot's four templates map only to existing update families; its
  abstract admission requires source, budget and type gates; its numeric code
  fits 128 IDs and round-trips all unsigned 16-bit values; the 508M/710M/911M
  parameter counts are exact. `pilot_families_are_updates`,
  `pilot_admission_requires_all_checks`, `pilot_digits_in_vocabulary`,
  `pilot_numeric_roundtrip`, `pilot_508m_parameters`, `pilot_710m_parameters`,
  `pilot_911m_parameters`. The inventory supplied by an adapter still requires
  source correspondence; passing an alphabet gate is not parsing or certification.
- H12: compact signature, slot and relation banks are bounded, injective,
  mutually disjoint and disjoint from integer-literal and numeric-digit tokens.
  Each compact coordinate and literal has an exact model decoder. The nine
  `compact_*`, `*_token_roundtrip` and `*_token_injective` lemmas establish
  token arithmetic, not correctness of the upstream certified naming map.
  Python separately checks bitwidth admission for literals and bank exhaustion.
- H13: partitioning preserves exact scalar sums, sample count and the normalized
  sum, with the requested effective-batch products.
  `accumulated_sum_matches_flat_batch`, `accumulation_preserves_example_count`,
  `accumulated_mean_matches_flat_batch`, `requested_effective_batch_counts`.
  Per-example contributions at unchanged weights are a premise. These integer/
  rational model theorems do not prove floating-point autograd or Adafactor.
  `test_batching.py` separately compares full and uneven accumulated gradients
  and updates, checks one optimizer step per batch, and checks failed-chunk
  cleanup without a step. Those are bounded implementation tests.

## Open Correspondences

The source-backed corpus pilot adds `formal/CorpusTraining.lean` with 13
model-level theorems: question-consistent splits, record-level label separation,
optimal ties, two-direction success, finite attempt budgets, five extra read-only
operator codes, and the compact integer codec's round trip/injectivity. See
CORPUS-STUDY.md for the fixed experiment protocol and explicit trust. The tests
cover numeric codes exhaustively, source export, live reparsing/solver labels,
alpha-renamed source bindings, causal action-pointer placement, padding
invariance, teacher-field exclusion, and exact random-choice expectations.
Neither these tests nor the new Lean models discharge whole-program refinement.

- J01: actual certified incidence export plus checked canonical ID/alpha
  transport, including cycles, CALL and dependent-chain evidence.
  The corpus worker exports the bounded certified repair projection and source
  occurrence graph. Full proof-heavy e-graph export and general lineage transport
  remain open; source and canonical slot namespaces are distinct graph sections.
- J02: structured counterexample atom/tuple encoding and interpretation in the
  exact candidate source context, with no oracle-syntax leakage.
  The static pilot now exports typed user-signature/field tuples directly from
  A4TupleSet, plus expected/actual Boolean values. Built-in atom universes and
  temporal traces are not fully serialized. This is a scoped projection, not a
  universal lossless Alloy-instance codec.
- J03: executable edit coverage and source realization with charges matching
  the existing scalar metric. Readable edit strings are not a substitute.
- J04: real-data label generation, group-disjoint split and deterministic
  codec round trips, including symmetric action target sets.
  The one-step pilot implements oracle-distance-minimum target sets and
  question-disjoint splits. It checks zero-distance labels against the solver;
  general multi-step teacher scripts and full packet decoding remain open.
- P01: the Python prototype's structural correspondence to the Lean model.
  Formula/count and codec tests are bounded tests, not a refinement proof.
- P02: concrete low-memory training backend. Resident fake quantization does
  not satisfy a packed training memory claim. Deferred/streamed updates need
  recurrence tests and measured device/host peaks before full-sized training.
  The BF16-compute/FP32-master Adafactor accumulation path now has bounded
  full-sized GPU measurements and small-model gradient/update comparison tests;
  this does not discharge packed INT4 training, checkpointing peaks or long-run
  optimizer efficacy. See BATCH-RESULTS.md.
- E01: real repair effectiveness and precision/capacity comparison. Tiny tensor
  learning, parameter counts and loss reduction do not discharge this claim.
  The first source-backed eight-epoch 508M run is now measured, with 0/192
  top-1 repairs and 1/192 at budget 3. It shows no repair advantage over random,
  with only two one-step-repairable held-out cases. E01 remains open; see
  CORPUS-RESULTS.md. No architecture or convergence claim is closed by this run.
  The complete-program study removes the menu ceiling for 3,184 replay-checked
  pairs, but yields 0/652 held-out exact graphs and 0/64 training-sample exact
  graphs. No generated test ROOT is well shaped. E01 and the source-realization
  part of J03 remain open; see GRAPH-PATH-RESULTS.md. Numerical loss reduction
  is not accepted as evidence of behavioral repair.

## Declared Trust

The graph-program study adds eight model theorems in `formal/GraphRepair.lean`:
`complete_path`, `no_menu_required`, `copy_requires_existing_node`,
`replay_deterministic`, `target_not_in_key`, `prefix_not_supervised`,
`target_length_preserved`, and `semantic_success_gate`. The first two prove
expressibility of a complete target term assuming a sound source lookup, not
that a learned program will be correct or minimal. The record-projection theorem
does not itself prove implementation dataflow; source-only prefix and decoder
tests check the concrete separation. The graph codec and Python replay are not
kernel-verified refinements. All exported admitted pairs undergo replay and
source-prefix round-trip checks. Java source realization and behavioral evaluation
of generated graph programs remain open under J03/E01. No certificate authority
is learned, inferred from graph equality, or bypassed by this study.

Lean kernel, standard library, compiler/runtime, Python, PyTorch, CUDA/cuBLAS/
attention kernels, driver, OS, CPU/GPU and hash implementation are trusted for
their respective checks. Numerical autodiff and the identity straight-through
estimator are declared experimental mechanisms, not semantic proof engines.
PyTorch's installed Adafactor implementation is also trusted. The final batch
repeats hash its constructor/step implementation source and retain optimizer
defaults. Initial records hashed only its public re-export module; see the
provenance correction in BATCH-RESULTS.md.
Java canonicalization, metric semantics, Alloy interpretation and independent
certificate replay retain their existing trust/proof boundaries unchanged.

## Development Incidents

The first proof draft required a constructor-equality correction in the commit
gate lemma. Two hand-calculated candidate parameter totals were rejected by
Lean's `decide` and corrected before code was written. These were specification
development failures, not successful proof runs or changes to the Java artifact.
All such model/count assertions must compile again with the final source.

The 508M pilot exposed a separate numerical issue: the tiny fixture's SGD rate
0.03 increased the loss. Its reproduced failed record is retained; at 0.001 the
bounded probes decrease loss. This is experimental optimizer evidence, not a
new logical obligation or a repair-effectiveness result. See PILOT-RESULTS.md.

The effective-batch study separately found that Adafactor's initial rate cap
0.001 increased the fixed-batch loss for all three model sizes. Those records
are retained as numerical failures, even though every batch/gradient/optimizer
step completed. The 508M and 710M retries at 0.0001 reduced the loss after two
updates at 512 tokens. This is not evidence of convergence or repair success.
The 911M initial trial completed before the user deferred that size; no further
911M trial was run. See BATCH-RESULTS.md for the complete measured settings.
