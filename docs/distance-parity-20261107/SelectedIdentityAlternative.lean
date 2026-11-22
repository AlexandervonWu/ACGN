import SelectedPrimaryCongruence

/- This is an identity presentation, not permission to erase an automorphism.
   The complete ordered body includes typed heads, source objects and local
   coordinates. The producer checks those records recursively before transport. -/
namespace SelectedIdentityAlternative
open DistanceDerivedTrace

abbrev Body (P : Type) := List (List Nat × P)

def sameBody [DecidableEq P] (primary selected : Body P) : Bool :=
  decide (primary = selected)

def bodyStore (body : Body P) : Store (List Nat) P :=
  fun address => (body.find? (fun row => row.1 == address)).map Prod.snd

theorem checked_body_eq [DecidableEq P] (primary selected : Body P)
    (checked : sameBody primary selected = true) : primary = selected :=
  of_decide_eq_true checked

theorem all_selected_reads [DecidableEq P] (primary selected : Body P)
    (checked : sameBody primary selected = true) : bodyStore primary = bodyStore selected := by
  rw [checked_body_eq primary selected checked]

theorem selected_program_preserved [DecidableEq P] (primary selected : Body P)
    (checked : sameBody primary selected = true)
    (program : List (Operation (List Nat) P)) :
    run (bodyStore selected) program = run (bodyStore primary) program := by
  rw [all_selected_reads primary selected checked]

theorem selected_program_of_equality [DecidableEq P] (primary selected : Body P)
    (checked : primary = selected) (program : List (Operation (List Nat) P)) :
    run (bodyStore selected) program = run (bodyStore primary) program := by rw [checked]

theorem invalid_program_rejected [DecidableEq P] (primary selected : Body P)
    (checked : sameBody primary selected = true)
    (program : List (Operation (List Nat) P))
    (invalid : run (bodyStore primary) program = none) :
    run (bodyStore selected) program = none := by
  rw [selected_program_preserved primary selected checked, invalid]

theorem changed_body_rejected [DecidableEq P] (primary selected : Body P)
    (changed : primary ≠ selected) : sameBody primary selected = false := by
  simp [sameBody, changed]

def oldComponentGate (component : String) : Bool :=
  ["matrix", "declaration", "declaration-representation", "phase-representation",
   "temporal", "temporal-read"].contains component

theorem old_selected_rejected : oldComponentGate "representation" = false := by decide

open SelectedPrimaryCongruence in
def presented (index : Nat) (suffix : List Nat) : List Step :=
  .alternative index :: primary suffix

theorem presented_injective (index : Nat) : Function.Injective (presented index) := by
  intro a b h
  have inner := (List.cons.inj h).2
  have inject : ∀ (xs ys : List Nat), SelectedPrimaryCongruence.primary xs =
      SelectedPrimaryCongruence.primary ys → xs = ys := by
    intro xs
    induction xs with
    | nil => intro ys eq; cases ys <;> simp_all [SelectedPrimaryCongruence.primary]
    | cons x xs ih =>
      intro ys eq
      cases ys with
      | nil => simp [SelectedPrimaryCongruence.primary] at eq
      | cons y ys =>
        have parts := List.cons.inj eq
        have head : x = y := by cases parts.1; rfl
        rw [head, ih ys parts.2]
  exact inject a b inner

theorem identity_charge (program : List (Operation A P)) :
    0 + cost program = cost program := Nat.zero_add _

#print axioms selected_program_preserved
#print axioms invalid_program_rejected
end SelectedIdentityAlternative
