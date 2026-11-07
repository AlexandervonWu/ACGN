import Std

/- A source-certified homogeneous binder permutation may precede a charged
   declaration edit. Retaining only one stable ordering of equal tuples loses
   attaining paths. Neither a mixed exchange nor Java/wire extraction is claimed. -/
namespace CertifiedDeclarationOrbit

theorem all_exchange {A : Type} (p : A → A → Prop) :
    (∀ x y, p x y) ↔ ∀ y x, p x y := by
  constructor <;> intro h x y <;> exact h y x

theorem some_exchange {A : Type} (p : A → A → Prop) :
    (∃ x y, p x y) ↔ ∃ y x, p x y := by
  constructor
  · rintro ⟨x, y, h⟩; exact ⟨y, x, h⟩
  · rintro ⟨y, x, h⟩; exact ⟨x, y, h⟩

def cost (a b : Nat) : Nat := if a = b then 0 else 1

theorem typed_permutation_preserves_declaration_charge
    (payload : Nat → Nat) (perm : Nat → Nat)
    (typed : ∀ i, payload (perm i) = payload i) (i target : Nat) :
    cost (payload (perm i)) target = cost (payload i) target := by rw [typed]

structure Occurrence where
  owner : Nat
  coordinate : Nat
  deriving DecidableEq

def transport (owner : Nat) (perm : Nat → Nat) (x : Occurrence) : Occurrence :=
  if x.owner = owner then ⟨x.owner, perm x.coordinate⟩ else x

theorem unrelated_owner_untouched (owner : Nat) (perm : Nat → Nat) (x : Occurrence)
    (h : x.owner ≠ owner) : transport owner perm x = x := by simp [transport, h]

theorem owner_preserved (owner : Nat) (perm : Nat → Nat) (x : Occurrence) :
    (transport owner perm x).owner = x.owner := by simp [transport]; split <;> rfl

theorem fixed_receipt_conflicts (mapping : Nat → Nat) (s c p : Nat)
    (charged : mapping s = c) (matrix : mapping s = p) (different : c ≠ p) : False := by
  exact different (charged.symm.trans matrix)

-- Canonical tie preference is global across all minimum declaration paths,
-- not merely the first orbit candidate of each individual path.
def selectedCost (best candidate : Nat) (bestBase candidateBase : Bool) : Nat :=
  if candidate < best ∨ candidate = best ∧ candidateBase = true ∧ bestBase = false
  then candidate else best

theorem tie_preference_keeps_minimum (best candidate : Nat) (b c : Bool) :
    selectedCost best candidate b c = min best candidate := by
  unfold selectedCost
  split <;> omega

theorem canonical_tie_has_same_cost (cost : Nat) :
    selectedCost cost cost false true = cost := by simp [selectedCost]

#print axioms all_exchange
#print axioms some_exchange
#print axioms typed_permutation_preserves_declaration_charge
#print axioms unrelated_owner_untouched
#print axioms owner_preserved
#print axioms fixed_receipt_conflicts
#print axioms tie_preference_keeps_minimum
#print axioms canonical_tie_has_same_cost
end CertifiedDeclarationOrbit
