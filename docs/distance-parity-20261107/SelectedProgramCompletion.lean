import SelectedDeclarationCompletion
import DeclarationReplay
import JointDeclarationMatrixReplay

/- Completion links are extracted from the already selected declaration edits.
   They do not replace that program, move binders, or equate edited predicates.
   The selected matrix program must pass every primitive charge check again. -/
namespace SelectedProgramCompletion
open SelectedDeclarationCompletion

def unchangedCharges (actions : List Action) (before after : Mapping) : Bool :=
  actions.all (fun action => charge before action == charge after action)

theorem checked_program_unchanged (actions : List Action) (before after : Mapping)
    (checked : unchangedCharges actions before after = true) :
    annotated actions before = annotated actions after := by
  apply List.map_congr_left
  intro action member
  have eq : charge before action = charge after action := by
    have h := (List.all_eq_true.mp checked) action member
    exact beq_iff_eq.mp h
  rw [eq]

theorem checked_execution_unchanged {State : Type}
    (step : State → (Action × Nat) → State) (initial : State)
    (actions : List Action) (before after : Mapping)
    (checked : unchangedCharges actions before after = true) :
    (annotated actions before).foldl step initial =
      (annotated actions after).foldl step initial := by
  rw [checked_program_unchanged actions before after checked]

theorem checked_total_unchanged (actions : List Action) (before after : Mapping)
    (checked : unchangedCharges actions before after = true) :
    (actions.map (charge before)).sum = (actions.map (charge after)).sum := by
  apply congrArg List.sum
  apply List.map_congr_left
  intro action member
  exact beq_iff_eq.mp ((List.all_eq_true.mp checked) action member)

theorem no_reads_check (actions : List Action) (before after : Mapping)
    (noReads : ∀ action ∈ actions, readPair action = none) :
    unchangedCharges actions before after = true := by
  apply List.all_eq_true.mpr
  intro action member
  simp [charge, noReads action member]

theorem changed_read_rejected (actions : List Action) (before after : Mapping)
    (action : Action) (member : action ∈ actions)
    (changed : charge before action ≠ charge after action) :
    unchangedCharges actions before after = false := by
  cases h : unchangedCharges actions before after with
  | false => rfl
  | true => exact False.elim (changed (beq_iff_eq.mp ((List.all_eq_true.mp h) action member)))

-- Exact diagonal branch of the old Java link check, with no fixed-path callback.
def oldAllows (mapping : Mapping) (targets leftSeen rightSeen : List Nat)
    (source target cost : Nat) : Bool :=
  decide (mapping source = some target) ||
    (cost == 0 && decide (mapping source = none) && !targets.contains target &&
      (!leftSeen.contains source || !rightSeen.contains target))

theorem old_unmapped_paid_rejected (mapping : Mapping) (targets leftSeen rightSeen : List Nat)
    (source target cost : Nat) (fresh : mapping source = none) (paid : cost ≠ 0) :
    oldAllows mapping targets leftSeen rightSeen source target cost = false := by
  simp [oldAllows, fresh, paid]

#print axioms checked_program_unchanged
#print axioms checked_execution_unchanged
#print axioms checked_total_unchanged
#print axioms no_reads_check
#print axioms changed_read_rejected
#print axioms old_unmapped_paid_rejected
end SelectedProgramCompletion
