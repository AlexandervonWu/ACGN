import Std

/- Outer alpha coordinates are not global identities. The Boolean flags below
   mark endpoints requiring an external selected binder alignment. Fast's
   existing local structural-binder projection owns a separate coordinate
   comparison; this contract does not prove or extend that projection. Only
   two endpoints outside the external-alignment slice retain its old fallback.
   No new semantic equivalence or local grouping admission is added. -/
namespace BoundVariableCorrespondence

-- The producer uses the phase's actual declaration registry, not the spelling
-- of an alpha-labelled lexical node, to select the external-alignment slice.
def externalCoordinate (registered : Nat → Bool) (x : Nat) : Bool := registered x

theorem unregistered_is_lexical (registered : Nat → Bool) (x : Nat)
    (absent : registered x = false) : externalCoordinate registered x = false := absent

def Matches (m : Nat → Option Nat) (boundL boundR : Bool) (x y : Nat) : Prop :=
  m x = some y ∨ (boundL = false ∧ boundR = false ∧ m x = none ∧ x = y ∧
    ∀ z, m z ≠ some y)

theorem bound_requires_selected (m : Nat → Option Nat) (l r : Bool) (x y : Nat)
    (bound : l = true ∨ r = true) (h : Matches m l r x y) : m x = some y := by
  rcases h with selected | ⟨hl, hr, _⟩
  · exact selected
  · rcases bound with bl | br
    · simp [bl] at hl
    · simp [br] at hr

theorem unmatched_bound_rejected (m : Nat → Option Nat) (l r : Bool) (x y : Nat)
    (bound : l = true ∨ r = true) (absent : m x = none) : ¬ Matches m l r x y := by
  intro h
  have selected := bound_requires_selected m l r x y bound h
  rw [absent] at selected
  contradiction

theorem selected_preserved (m : Nat → Option Nat) (l r : Bool) (x y : Nat)
    (selected : m x = some y) : Matches m l r x y := Or.inl selected

theorem checked_premise_required (m : Nat → Option Nat) (admitted : Nat → Nat → Prop)
    (checked : ∀ x y, m x = some y → admitted x y) (l r : Bool) (x y : Nat)
    (bound : l = true ∨ r = true) (h : Matches m l r x y) : admitted x y :=
  checked x y (bound_requires_selected m l r x y bound h)

theorem lexical_identity_retained (m : Nat → Option Nat) (x : Nat)
    (absent : m x = none) (unused : ∀ z, m z ≠ some x) :
    Matches m false false x x := Or.inr ⟨rfl, rfl, absent, rfl, unused⟩

def cost (m : Nat → Option Nat) (l r : Bool) (x y : Nat)
    [Decidable (Matches m l r x y)] : Nat := if Matches m l r x y then 0 else 1

theorem unmatched_bound_costs_one (m : Nat → Option Nat) (l r : Bool) (x y : Nat)
    [Decidable (Matches m l r x y)] (bound : l = true ∨ r = true) (absent : m x = none) :
    cost m l r x y = 1 := by
  simp [cost, unmatched_bound_rejected m l r x y bound absent]

#print axioms bound_requires_selected
#print axioms checked_premise_required
#print axioms unmatched_bound_costs_one
end BoundVariableCorrespondence
