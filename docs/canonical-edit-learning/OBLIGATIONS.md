# Proof And Implementation Boundaries

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

## Open Correspondences

- J01: actual certified incidence export plus checked canonical ID/alpha
  transport, including cycles, CALL and dependent-chain evidence.
- J02: structured counterexample atom/tuple encoding and interpretation in the
  exact candidate source context, with no oracle-syntax leakage.
- J03: executable edit coverage and source realization with charges matching
  the existing scalar metric. Readable edit strings are not a substitute.
- J04: real-data label generation, group-disjoint split and deterministic
  codec round trips, including symmetric action target sets.
- P01: the Python prototype's structural correspondence to the Lean model.
  Formula/count and codec tests are bounded tests, not a refinement proof.
- P02: concrete low-memory training backend. Resident fake quantization does
  not satisfy a packed training memory claim. Deferred/streamed updates need
  recurrence tests and measured device/host peaks before full-sized training.
- E01: real repair effectiveness and precision/capacity comparison. Tiny tensor
  learning, parameter counts and loss reduction do not discharge this claim.

## Declared Trust

Lean kernel, standard library, compiler/runtime, Python, PyTorch, CUDA/cuBLAS/
attention kernels, driver, OS, CPU/GPU and hash implementation are trusted for
their respective checks. Numerical autodiff and the identity straight-through
estimator are declared experimental mechanisms, not semantic proof engines.
Java canonicalization, metric semantics, Alloy interpretation and independent
certificate replay retain their existing trust/proof boundaries unchanged.

## Development Incidents

The first proof draft required a constructor-equality correction in the commit
gate lemma. Two hand-calculated candidate parameter totals were rejected by
Lean's `decide` and corrected before code was written. These were specification
development failures, not successful proof runs or changes to the Java artifact.
All such model/count assertions must compile again with the final source.
