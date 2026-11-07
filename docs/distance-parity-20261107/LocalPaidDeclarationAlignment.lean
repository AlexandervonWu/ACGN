import Std

/- Outer paid declaration links act on outer occurrences only. A retained
   existential is not hoisted, and a local owner/slot never becomes an outer
   occurrence. This model is not an extracted Java implementation. -/
namespace LocalPaidDeclarationAlignment

inductive Slot where
  | outer : Nat → Slot
  | local : Nat → Nat → Slot
  deriving DecidableEq

def transport (paid : Nat → Option Nat) : Slot → Option Slot
  | .outer n => (paid n).map Slot.outer
  | .local owner n => some (.local owner n)

theorem paid_outer_link (paid : Nat → Option Nat) (a b : Nat) (h : paid a = some b) :
    transport paid (.outer a) = some (.outer b) := by simp [transport, h]

theorem local_owner_untouched (paid : Nat → Option Nat) (owner n : Nat) :
    transport paid (.local owner n) = some (.local owner n) := rfl

theorem no_local_capture (paid : Nat → Option Nat) (owner n target : Nat) :
    transport paid (.local owner n) ≠ some (.outer target) := by simp [transport]

theorem foreign_owner_distinct (a b n : Nat) (h : a ≠ b) :
    Slot.local a n ≠ Slot.local b n := by simp [h]

-- Only independent existential coordinates in the SAME original block move.
theorem independent_exists_exchange {A B : Type} (p : A → B → Prop) :
    (∃ a, ∃ b, p a b) ↔ (∃ b, ∃ a, p a b) := by
  constructor
  · rintro ⟨a, b, h⟩; exact ⟨b, a, h⟩
  · rintro ⟨b, a, h⟩; exact ⟨a, b, h⟩

-- The incident's Teacher domain may be empty even when Person/Student is not.
theorem empty_teacher_forbids_hoist :
    (False → ∃ _t : Unit, False ∧ True) ∧
    ¬ (∃ _t : Unit, False ∧ (False → True)) := by simp

theorem retained_exists_congruence {A : Type} (domain : A → Prop)
    (p q : A → Prop) (h : ∀ x, p x ↔ q x) :
    (∃ x, domain x ∧ p x) ↔ (∃ x, domain x ∧ q x) := by
  constructor
  · rintro ⟨x, d, hx⟩; exact ⟨x, d, (h x).mp hx⟩
  · rintro ⟨x, d, hx⟩; exact ⟨x, d, (h x).mpr hx⟩

#print axioms paid_outer_link
#print axioms local_owner_untouched
#print axioms no_local_capture
#print axioms foreign_owner_distinct
#print axioms independent_exists_exchange
#print axioms empty_teacher_forbids_hoist
#print axioms retained_exists_congruence
end LocalPaidDeclarationAlignment
