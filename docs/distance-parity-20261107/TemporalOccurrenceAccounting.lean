import Std

/- A temporal occurrence is owned by a phase and names an ordered source
   branch group. Boolean expansion can use that occurrence more than once;
   the inventory records it once, without changing any formula use or binding.
   Java/source correspondence and public wire replay remain separate obligations. -/
namespace TemporalOccurrenceAccounting

structure Occurrence where
  owner : Nat
  branches : List Nat
  deriving DecidableEq

def register (seen : List Occurrence) (r : Occurrence) : List Occurrence :=
  if r ∈ seen then seen else seen ++ [r]

theorem register_present (seen : List Occurrence) (r : Occurrence) :
    r ∈ register seen r := by
  by_cases h : r ∈ seen <;> simp [register, h]

theorem repeated_use_not_new_occurrence (seen : List Occurrence) (r : Occurrence) :
    register (register seen r) r = register seen r := by
  by_cases h : r ∈ seen <;> simp [register, h]

theorem preserve_existing (seen : List Occurrence) (r q : Occurrence)
    (h : q ∈ seen) : q ∈ register seen r := by
  by_cases hr : r ∈ seen <;> simp_all [register]

theorem different_owner_distinct (a b : Nat) (branches : List Nat) (h : a ≠ b) :
    (Occurrence.mk a branches) ≠ Occurrence.mk b branches := by
  intro eq
  exact h (congrArg Occurrence.owner eq)

theorem different_branch_group_distinct (owner : Nat) (a b : List Nat) (h : a ≠ b) :
    (Occurrence.mk owner a) ≠ Occurrence.mk owner b := by
  intro eq
  exact h (congrArg Occurrence.branches eq)

-- Inventory normalization does not deduplicate the actual ordered formula uses.
def uses (env : Occurrence → α) (refs : List Occurrence) : List α := refs.map env
theorem repeated_uses_preserved (env : Occurrence → α) (r : Occurrence) :
    uses env [r,r] = [env r,env r] := rfl

#print axioms repeated_use_not_new_occurrence
#print axioms preserve_existing
#print axioms different_owner_distinct
#print axioms different_branch_group_distinct
#print axioms repeated_uses_preserved
end TemporalOccurrenceAccounting
