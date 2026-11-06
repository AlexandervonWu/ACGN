import Lean
set_option autoImplicit false

namespace SlotTypingAblation

structure Slot where
  scope : Nat
  coordinate : Nat
  sort : Nat
  deriving DecidableEq

def erase (s : Slot) : Nat × Nat := (s.scope, s.coordinate)

theorem typed_equality_erases (a b : Slot) (h : a = b) : erase a = erase b := by
  exact congrArg erase h

theorem different_sorts_distinct (a b : Slot) (h : a.sort ≠ b.sort) : a ≠ b := by
  intro same
  exact h (congrArg Slot.sort same)

theorem erasure_can_collide :
    erase ⟨0, 0, 1⟩ = erase ⟨0, 0, 2⟩ ∧ (Slot.mk 0 0 1) ≠ ⟨0, 0, 2⟩ := by
  decide

def preserves (types : Nat → Nat) (mapping : Nat → Nat) : Prop :=
  ∀ i, types (mapping i) = types i

theorem identity_preserves (types : Nat → Nat) : preserves types id := by
  intro i
  rfl

theorem composition_preserves (types f g : Nat → Nat)
    (hf : preserves types f) (hg : preserves types g) :
    preserves types (f ∘ g) := by
  intro i
  exact (hf (g i)).trans (hg i)

theorem inverse_preserves (types f g : Nat → Nat)
    (hf : preserves types f) (inverse : ∀ i, f (g i) = i) :
    preserves types g := by
  intro i
  have h := hf (g i)
  rw [inverse i] at h
  exact h.symm

theorem typed_mappings_subset (allowed : (Nat → Nat) → Prop)
    (types f : Nat → Nat) (h : allowed f ∧ preserves types f) : allowed f := h.1

-- The scope/coordinate boundary is unchanged by the experimental type erasure.
theorem erasure_retains_scope (a b : Slot) (h : erase a = erase b) : a.scope = b.scope := by
  exact congrArg Prod.fst h

#print axioms typed_equality_erases
#print axioms different_sorts_distinct
#print axioms erasure_can_collide
#print axioms identity_preserves
#print axioms composition_preserves
#print axioms inverse_preserves
#print axioms typed_mappings_subset
#print axioms erasure_retains_scope

end SlotTypingAblation
