# Type-Preserving Slotted Pass Repair

This document records `slotted-type-preserving-order-v2`. The subsequent v3
[bind-block combination](independent-binding-blocks.md) preserves its operand
orientation fix while extending eligible declaration exchange blocks.

## Behavior

`slotted-type-preserving-order-v2` separates two operations:

1. **Slot permutations:** `SlotPermutationSearch.collect` partitions
   each existing admissible declaration group by its exact `slotType` string.
   Candidate mappings permute names only inside one partition. Separate scope
   and declaration groups remain separate. The untyped arm has the single erased
   color and retains its untyped treatment; it is not silently made typed.
2. **Commutative operand order:** slotted rewriting and alpha normalization now
   share `SlotCanonicalizer.sortOperands`. Local-slot structure/type is the
   primary key; the full term is the tie-break. No variable changes type.
   An equality's operands can still commute across compatible different declared
   types, such as `User` and its subtype `Influencer`. This is an operator law,
   not authorization to exchange those binders.

`AlloyRewriteSystem.rewriteSlottedOnce` selects the shared orientation only for
slotted execution. Raw e-graph and Java-Egglog execution retain their existing
ordering. Bounded comparison, normal-form inspection, and uncapped synthetic
construction all use the repaired slotted pass. Limits and admission rules are
unchanged. Graph insertions, unions, and rebuilds are not skipped as a shortcut.

The initial shared-key implementation used only local slot keys. The existing
nested ACI regression immediately failed: different variables can tie under a
local key, leaving equal terms nonadjacent while deduplication checks adjacent
terms. The final comparator adds the full-term tie-break, making identical
operands adjacent and retaining ACI. No failed candidate was used for a full run.

## Lean and Java Correspondence

`TypedPass.lean` is standalone and uses no `sorry`, custom axiom, or `unsafe`.
Lean's `#print axioms` reports no axioms for all six lemmas:

- `same_type_exchange`: an exchange within a type partition preserves colors.
  Java correspondence: each generated permutation is confined to one
  `namesByType` partition.
- `different_type_exchange_rejected`: a cross-color exchange cannot satisfy
  that invariant. Java correspondence: differently typed names never enter
  the same candidate group; existing union color checks remain in force.
- `same_scope_exchange`: the same exchange argument preserves scope labels.
  Java retains declaration/scope boundaries before partitioning by type.
- `composed_exchanges_preserve`: composing admissible exchanges preserves types.
  Java enumerates permutations of each partition, then combines the groups.
- `same_domain_all_exchange`: universal bindings over the same domain may
  exchange. This is a semantic example, not a new permission for arbitrary
  quantifier-block movement; existing restrictions remain.
- `equality_operand_exchange`: equality remains commutative independently of
  binding permutations. Java's shared operand orientation uses the existing
  commutativity rule inventory, not a new equality axiom.

The existing `Model.lean` additionally proves that typed admissible mappings
are a subset of the untyped space. The sorting implementation, parser extraction,
and Java-to-Lean correspondence are checked by bounded executable witnesses,
not claimed as a machine-checked refinement of every Java instruction.
The equality rules themselves remain the existing Lean-linked rule inventory.

## Mixed Smoke Gate

Run `bash scripts/run_slot_typing_ablation_tests.sh`. It checks the slot model,
typed-pass and partition-generator Lean files,
40 slot/type/census assertions, the mixed-corpus behavior gate, and existing
e-graph regressions (including nested ACI flattening and eight-variable
same-type permutation). `SlotPermutationSearchTest` additionally checks the
streamed candidate space directly; see [the generator contract](partition-generator-contract.md).

`SlotRewriteOrderTest` uses these existing files without changing them:

- Natural `socialMedia/under/x9CXb8pLEAhJgTSFk_inv5.als`: typed rewriting falls
  from the observed 32 rounds to one round; both arms retain positive distance
  14 to the oracle.
- Synthetic `heterogeneous_alpha/.../generated_stress0010.als`: both arms
  stabilize in one round per predicate and retain distance zero.
- Synthetic `boolean_aci/.../generated_stress0050.als`: both arms stabilize in
  one round per predicate and retain distance zero.
- Synthetic `negative_cross_type/.../generated_stress0210.als`: both arms
  stabilize in one round per predicate and retain positive distance 2.

The mixed test also constructs smaller valid Alloy controls: equality operand
exchange and same-domain binder exchange have no counterexample at scope 3;
a cross-type relational-argument exchange has a counterexample. The typed engine
agrees with all three results. These bounded solver checks supplement the Lean
schemas; they are not unbounded proofs of the generated corpus. The test rejects
positive rewrite counts whose subsequent alpha normalization restores the same
frontier, and requires all selected examples to stabilize within eight rounds.

The completed mixed smoke run passed 66 assertions. Evidence log:
`/tmp/acgn-slot-mixed-smoke.log`. No full-corpus performance numbers are claimed
from this smoke run.

The broader bounded Java CI script also passed, including rewrite traceability,
certificate/pipeline regressions, and distance-artifact regeneration. The
synthetic runner suite passed its 12 Python tests and 18 construction checks;
the 40 slot/census checks and baseline e-graph regressions passed there too.
Logs: `/tmp/acgn-slot-order-bounded-ci.log` and
`/tmp/acgn-slot-order-synthetic-tests.log`.

## Rerun Boundary

The user-requested stop terminated the active synthetic schedule of
`acgn-full-20261106T204318Z-resume01`. Its partial observations and all completed
prior arm results remain preserved. A fresh run must regenerate the seven-arm
ablation, semantic checks, capability studies, natural typed/untyped comparison,
and synthetic schedule, serially, from a separately hashed repaired snapshot.
The completed CanonicalBatchTest and Alloy4FunAugmenter outputs may be inherited
with explicit original build/output hashes: their paths do not call this
experimental slotted engine. New slot censuses accompany the new natural run.

New rerun directory: `/home/augustus/acgn-slot-order-rerun-20261107T0105Z`.
The supervisor reruns both the synthetic preflight and mixed Lean/Java smoke
gate before starting the serial experimental stages. Full-run completion is
reported by its own `run-status.json`, not inferred from the smoke gates.
