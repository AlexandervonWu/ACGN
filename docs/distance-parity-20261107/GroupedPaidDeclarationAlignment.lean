import Std

/- A declaration owner is not a variable occurrence. Distinct slots of one
   independent ALL/SOME declaration may receive distinct charged edit links.
   This is not a free mixed-quantifier exchange or Java/wire correspondence. -/
namespace GroupedPaidDeclarationAlignment

structure Occurrence where
  owner : Nat
  slot : Nat
  deriving DecidableEq

theorem same_owner_distinct_slots (owner i j : Nat) (h : i ≠ j) :
    (Occurrence.mk owner i) ≠ (Occurrence.mk owner j) := by
  intro eq
  exact h (congrArg Occurrence.slot eq)

theorem different_owner_not_same_occurrence (a b : Occurrence) (h : a.owner ≠ b.owner) :
    a ≠ b := by
  intro eq
  exact h (congrArg Occurrence.owner eq)

theorem grouped_exists {A : Type} (p : A → A → A → Prop) :
    (∃ xyz : A × A × A, p xyz.1 xyz.2.1 xyz.2.2) ↔ ∃ x y z, p x y z := by
  constructor
  · rintro ⟨⟨x, y, z⟩, h⟩; exact ⟨x, y, z, h⟩
  · rintro ⟨x, y, z, h⟩; exact ⟨(x, y, z), h⟩

theorem grouped_all {A : Type} (p : A → A → Prop) :
    (∀ xy : A × A, p xy.1 xy.2) ↔ ∀ x y, p x y := by
  constructor
  · intro h x y; exact h (x, y)
  · intro h xy; exact h xy.1 xy.2

theorem empty_group_not_inhabited : ¬ (∃ xyz : Empty × Empty × Empty, True) := by
  rintro ⟨⟨x, _, _⟩, _⟩; exact nomatch x

structure Declaration where
  occurrence : Occurrence
  kind : Nat
  carrier : Nat
  multiplicity : Nat
  deriving DecidableEq

def charged (actual expected target : Declaration) : Option (Nat × (Occurrence × Occurrence)) :=
  if actual = expected then some (1, (actual.occurrence, target.occurrence)) else none

theorem paid_slot_link (a b : Declaration) :
    charged a a b = some (1, (a.occurrence, b.occurrence)) := by simp [charged]

theorem substituted_slot_or_type_rejected (a expected b : Declaration) (h : a ≠ expected) :
    charged a expected b = none := by simp [charged, h]

#print axioms same_owner_distinct_slots
#print axioms different_owner_not_same_occurrence
#print axioms grouped_exists
#print axioms grouped_all
#print axioms empty_group_not_inhabited
#print axioms paid_slot_link
#print axioms substituted_slot_or_type_rejected
end GroupedPaidDeclarationAlignment
