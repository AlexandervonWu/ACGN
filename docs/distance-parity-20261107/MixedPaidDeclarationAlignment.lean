import Std

/- Paid declaration updates do not exchange source quantifiers. Homogeneity
   is needed for a free block permutation, not for a charged diagonal between
   two fixed declaration sequences. Java correspondence and public wire replay
   are separate obligations; this contract does not discharge them. -/
namespace MixedPaidDeclarationAlignment

structure Declaration where
  occurrence : Nat
  block : Nat
  quantifier : Bool
  carrier : Nat
  deriving DecidableEq

def paidPair (actual expected target : Declaration) :
    Option (Declaration × Nat × (Nat × Nat)) :=
  if actual = expected then some (target, 1, (actual.occurrence, target.occurrence))
  else none

theorem paid_pair_keeps_occurrences (a b : Declaration) :
    paidPair a a b = some (b, 1, (a.occurrence, b.occurrence)) := by
  simp [paidPair]

theorem source_substitution_rejected (a expected b : Declaration) (h : a ≠ expected) :
    paidPair a expected b = none := by simp [paidPair, h]

-- Free permutations are admitted independently inside each original block.
-- No whole-prefix sort or exchange across an ALL/SOME boundary is justified.
theorem blockwise_permutation {α : Type} (a a' b b' : List α)
    (ha : a.Perm a') (hb : b.Perm b') : (a ++ b).Perm (a' ++ b') :=
  ha.append hb

theorem mixed_exchange_invalid :
    (∀ x : Bool, ∃ y : Bool, x = y) ∧ ¬ (∃ y : Bool, ∀ x : Bool, x = y) := by
  constructor
  · intro x; exact ⟨x, rfl⟩
  · rintro ⟨y, h⟩
    have bad : false = true := (h false).trans (h true).symm
    contradiction

-- The actual incident's inner Person witness may be the outer p. This
-- implication lift does NOT assume a globally inhabited Person signature.
theorem implication_exists_with_outer_witness {P : Type} (p : P)
    (antecedent : Prop) (body : P → Prop) :
    (antecedent → ∃ q, body q) ↔ ∃ q, antecedent → body q := by
  classical
  constructor
  · intro h
    by_cases a : antecedent
    · obtain ⟨q, hq⟩ := h a
      exact ⟨q, fun _ => hq⟩
    · exact ⟨p, fun h' => False.elim (a h')⟩
  · rintro ⟨q, h⟩ a
    exact ⟨q, h a⟩

theorem incident_prenex {P C G : Type} (a : P → C → G → Prop)
    (b : P → C → P → Prop) :
    (∀ p, ∃ c, ∃ g, a p c g → ∃ q, b p c q) ↔
    (∀ p, ∃ c, ∃ g, ∃ q, a p c g → b p c q) := by
  constructor
  · intro h p
    obtain ⟨c, g, hcg⟩ := h p
    exact ⟨c, g, (implication_exists_with_outer_witness p _ _).mp hcg⟩
  · intro h p
    obtain ⟨c, g, hcg⟩ := h p
    exact ⟨c, g, (implication_exists_with_outer_witness p _ _).mpr hcg⟩

#print axioms paid_pair_keeps_occurrences
#print axioms source_substitution_rejected
#print axioms blockwise_permutation
#print axioms mixed_exchange_invalid
#print axioms incident_prenex
end MixedPaidDeclarationAlignment
