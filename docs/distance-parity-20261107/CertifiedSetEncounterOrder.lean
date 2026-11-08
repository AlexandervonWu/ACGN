import Std

/- Enumerating already-certified Set fibers in source encounter order changes
   neither a fiber nor its typed occurrence authority. The edit algorithm must
   consume that enumeration before DP/backtrace; receipts are not sorted later.
   No claim is made that ordered edit costs are invariant under permutation. -/
namespace CertifiedSetEncounterOrder

structure Occurrence (A : Type) where
  source : Nat
  owner : Nat
  typeAuthority : Nat
  value : A

abbrev Fiber (A : Type) := List (Occurrence A)

def observed {A : Type} (fibers : List (Fiber A)) (p : Occurrence A → Prop) : Prop :=
  ∃ fiber ∈ fibers, ∃ occurrence ∈ fiber, p occurrence

theorem reordered_fibers_preserve_observation {A : Type}
    {before after : List (Fiber A)} (order : before.Perm after) (p : Occurrence A → Prop) :
    observed before p ↔ observed after p := by
  constructor
  · rintro ⟨fiber, hf, occurrence, ho, hp⟩
    exact ⟨fiber, order.mem_iff.mp hf, occurrence, ho, hp⟩
  · rintro ⟨fiber, hf, occurrence, ho, hp⟩
    exact ⟨fiber, order.mem_iff.mpr hf, occurrence, ho, hp⟩

theorem typed_fiber_authority_preserved {A : Type} {before after : List (Fiber A)}
    (order : before.Perm after) (valid : Fiber A → Prop)
    (checked : ∀ fiber ∈ before, valid fiber) : ∀ fiber ∈ after, valid fiber := by
  intro fiber hf
  exact checked fiber (order.mem_iff.mpr hf)

theorem flatten_preserves_every_occurrence {A : Type} {before after : List (Fiber A)}
    (order : before.Perm after) : before.flatten.Perm after.flatten := by
  induction order with
  | nil => exact .nil
  | cons fiber _ ih => exact List.Perm.append_left fiber ih
  | swap a b tail =>
    simpa [List.flatten_cons, List.append_assoc] using
      (show (b ++ a).Perm (a ++ b) from List.perm_append_comm).append_right tail.flatten
  | trans _ _ ih₁ ih₂ => exact ih₁.trans ih₂

/- The finite Java partition provides sorted nonempty fibers and a disjoint
   full source-index cover. Ordering whole fibers by their first source index
   retains the selected representatives as actual members of those fibers. -/
theorem selected_representatives_retained {A : Type} {before after : List (Fiber A)}
    (order : before.Perm after) :
    (before.map List.head?).Perm (after.map List.head?) := order.map List.head?

theorem ordered_sequence_not_equal : ([0,1] : List Nat) ≠ [1,0] := by decide

theorem empty_set_observation {A : Type} (p : Occurrence A → Prop) :
    ¬ observed [] p := by simp [observed]

#print axioms reordered_fibers_preserve_observation
#print axioms typed_fiber_authority_preserved
#print axioms flatten_preserves_every_occurrence
#print axioms selected_representatives_retained
#print axioms ordered_sequence_not_equal
#print axioms empty_set_observation
end CertifiedSetEncounterOrder
