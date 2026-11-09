import Std

namespace OwnerAndPhaseCoordinates
/- Observation position is not declaration ownership. A retained owner lookup
   must be the authority; changing uses cannot change that lookup. -/
structure Binding where
  occurrence : Nat
  owner : Nat
  exactType : Nat
  deriving DecidableEq
def ownerOf (b : Binding) (_uses : List Nat) : Nat := b.owner
theorem use_shift_preserves_owner (b : Binding) (before after : List Nat) :
    ownerOf b before = ownerOf b after := rfl
theorem foreign_occurrence_not_same (a b : Binding) (h : a.occurrence ≠ b.occurrence) :
    a ≠ b := by intro same; exact h (congrArg Binding.occurrence same)

/- Whole temporal references are treated as Boolean values at their original
   owner. ACI child permutation preserves conjunction/disjunction; it does not
   exchange the left/right roles inside a temporal reference. -/
theorem and_permutation (xs ys : List Prop) (h : xs.Perm ys) :
    (∀ p ∈ xs, p) ↔ (∀ p ∈ ys, p) := by
  constructor
  · intro all p hp; exact all p (h.mem_iff.mpr hp)
  · intro all p hp; exact all p (h.mem_iff.mp hp)
theorem or_permutation (xs ys : List Prop) (h : xs.Perm ys) :
    (∃ p ∈ xs, p) ↔ (∃ p ∈ ys, p) := by
  constructor
  · rintro ⟨p,hp,yes⟩; exact ⟨p,h.mem_iff.mp hp,yes⟩
  · rintro ⟨p,hp,yes⟩; exact ⟨p,h.mem_iff.mpr hp,yes⟩
def resolve {A : Type} (source : Nat → A) (newToOld : Nat → Nat) (index : Nat) :=
  source (newToOld index)
theorem coordinate_roundtrip {A : Type} (source : Nat → A)
    (newToOld oldToNew : Nat → Nat) (old : Nat)
    (inverse : newToOld (oldToNew old) = old) :
    resolve source newToOld (oldToNew old) = source old := by simp [resolve,inverse]
theorem unary_role_forced (role : Nat) (valid : role < 1) : role = 0 := by omega

/- A whole-skeleton identity is not authority to redirect an edge to a different
   occurrence. Executing no edits preserves the edge selected by its address. -/
def execute {A : Type} (steps : List (A → A)) (source : A) : A :=
  steps.foldl (fun state step => step state) source
theorem empty_execution_preserves_edge {A B : Type} (source : A) (edge : A → B) :
    edge (execute [] source) = edge source := rfl
theorem different_edge_needs_nonempty_program {A B : Type}
    (source : A) (edge : A → B) (steps : List (A → A))
    (changed : edge (execute steps source) ≠ edge source) : steps ≠ [] := by
  intro empty; subst steps; exact changed rfl

#print axioms use_shift_preserves_owner
#print axioms foreign_occurrence_not_same
#print axioms and_permutation
#print axioms or_permutation
#print axioms coordinate_roundtrip
#print axioms unary_role_forced
#print axioms empty_execution_preserves_edge
#print axioms different_edge_needs_nonempty_program
end OwnerAndPhaseCoordinates
