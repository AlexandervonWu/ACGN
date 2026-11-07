import Std

/- A selected partial binder alignment may be extended by identity only at
   unused targets. This is an edit-correspondence contract, not an assertion
   that equally spelled source binders are semantically identical. -/
namespace InjectiveVariableFallback

def Matches (m : Nat → Option Nat) (x y : Nat) : Prop :=
  m x = some y ∨ (m x = none ∧ x = y ∧ ∀ z, m z ≠ some y)

theorem reserved_target_rejects_fallback (m : Nat → Option Nat) (x y z : Nat)
    (unmatched : m x = none) (reserved : m z = some y) : ¬ Matches m x y := by
  intro h
  rcases h with explicit | ⟨_, _, unused⟩
  · rw [unmatched] at explicit
    contradiction
  · exact unused z reserved

theorem extension_injective (m : Nat → Option Nat)
    (injective : ∀ a b y, m a = some y → m b = some y → a = b)
    (a b y : Nat) (ha : Matches m a y) (hb : Matches m b y) : a = b := by
  rcases ha with ea | ⟨_, ay, freea⟩
  · rcases hb with eb | ⟨_, _, freeb⟩
    · exact injective a b y ea eb
    · exact False.elim (freeb a ea)
  · rcases hb with eb | ⟨_, eqb, _⟩
    · exact False.elim (freea b eb)
    · exact ay.trans eqb.symm

theorem explicit_match_retained (m : Nat → Option Nat) (x y : Nat)
    (h : m x = some y) : Matches m x y := Or.inl h

theorem unused_identity_retained (m : Nat → Option Nat) (x : Nat)
    (unmatched : m x = none) (unused : ∀ z, m z ≠ some x) : Matches m x x :=
  Or.inr ⟨unmatched, rfl, unused⟩

def editCost (m : Nat → Option Nat) (x y : Nat) [Decidable (Matches m x y)] : Nat :=
  if Matches m x y then 0 else 1

theorem rejected_match_costs_one (m : Nat → Option Nat) (x y : Nat)
    [Decidable (Matches m x y)] (h : ¬ Matches m x y) : editCost m x y = 1 := by
  simp [editCost, h]

#print axioms reserved_target_rejects_fallback
#print axioms extension_injective
#print axioms explicit_match_retained
#print axioms unused_identity_retained
#print axioms rejected_match_costs_one
end InjectiveVariableFallback
