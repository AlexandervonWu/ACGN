import Lean
set_option autoImplicit false

namespace TypedSlotPass

def exchange (a b i : Nat) : Nat := if i = a then b else if i = b then a else i

theorem same_type_exchange (types : Nat → Nat) (a b : Nat)
    (same : types a = types b) : ∀ i, types (exchange a b i) = types i := by
  intro i
  unfold exchange
  split
  · rename_i ha
    exact same.symm.trans (congrArg types ha.symm)
  · split
    · rename_i hb
      exact same.trans (congrArg types hb.symm)
    · rfl

theorem different_type_exchange_rejected (types : Nat → Nat) (a b : Nat)
    (different : types a ≠ types b) : ¬ (∀ i, types (exchange a b i) = types i) := by
  intro h
  have atA := h a
  unfold exchange at atA
  rw [ite_eq_left rfl] at atA
  exact different atA.symm

theorem same_scope_exchange (scopes : Nat → Nat) (a b : Nat)
    (same : scopes a = scopes b) : ∀ i, scopes (exchange a b i) = scopes i :=
  same_type_exchange scopes a b same

theorem composed_exchanges_preserve (types f g : Nat → Nat)
    (hf : ∀ i, types (f i) = types i) (hg : ∀ i, types (g i) = types i) :
    ∀ i, types (f (g i)) = types i := by
  intro i
  exact (hf (g i)).trans (hg i)

theorem same_domain_all_exchange {A : Type} (p : A → A → Prop) :
    (∀ a b, p a b) ↔ (∀ b a, p a b) := by
  constructor
  · intro h b a
    exact h a b
  · intro h a b
    exact h b a

-- Operand commutativity remains distinct from admissible slot mappings.
theorem equality_operand_exchange {A : Type} (a b : A) : (a = b) ↔ (b = a) := by
  constructor <;> intro h <;> exact h.symm

#print axioms same_type_exchange
#print axioms different_type_exchange_rejected
#print axioms same_scope_exchange
#print axioms composed_exchanges_preserve
#print axioms same_domain_all_exchange
#print axioms equality_operand_exchange

end TypedSlotPass
