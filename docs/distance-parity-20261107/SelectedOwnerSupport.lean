import RetainedOwnerRevisits

/- A registry contains issued source owners, not a demand that normalization
   retain every owner. Selected owners must still resolve to their exact source
   records. This does not erase any binder or change any repair operation. -/
namespace SelectedOwnerSupport
open RetainedOwnerRevisits

def checkedSupport (issued selected : List SlotOrigin) : Bool :=
  selected.all (fun slot => decide (slot ∈ issued))

theorem every_selected_origin (issued selected : List SlotOrigin)
    (checked : checkedSupport issued selected = true) :
    ∀ slot ∈ selected, slot ∈ issued := by
  simpa [checkedSupport, List.all_eq_true] using checked

def selectedLookup (selected : List SlotOrigin) (value : SlotOrigin → Value)
    (slot : SlotOrigin) : Option Value := if slot ∈ selected then some (value slot) else none

theorem every_selected_read_unchanged (selected : List SlotOrigin) (value : SlotOrigin → Value) :
    selected.map (selectedLookup selected value) = selected.map (fun slot => some (value slot)) := by
  apply List.map_congr_left
  intro slot member
  simp [selectedLookup, member]

theorem selected_program_unchanged (selected : List SlotOrigin) (value : SlotOrigin → Value)
    (step : State → Option Value → State) (initial : State) :
    (selected.map (selectedLookup selected value)).foldl step initial =
      (selected.map (fun slot => some (value slot))).foldl step initial := by
  rw [every_selected_read_unchanged]

theorem foreign_selected_origin_rejected (issued selected : List SlotOrigin) (foreign : SlotOrigin)
    (present : foreign ∈ selected) (missing : foreign ∉ issued) : checkedSupport issued selected = false := by
  cases h : checkedSupport issued selected with
  | false => rfl
  | true => exact False.elim (missing (every_selected_origin issued selected h foreign present))

def oldInventoryGate (issued selected : List SlotOrigin) : Bool := decide (selected.length = issued.length)

def projectSlot (owner : Nat) (parent : Option Nat) (declaration variableId : Nat) : SlotOrigin :=
  ⟨owner,parent,declaration,variableId,0,
   ⟨"2ea808111dbae11c034cc548698973ea26bbba8b31161338f253b779c6d0f77f", "inv14",
     toString variableId,toString owner,0,"local",[],[],"RELATION[7:Project]","Project",
     if parent.isSome then "ALL" else "SOME","ONE",0⟩⟩

def keptOuter := projectSlot 1058 none 1060 1065
def keptInner := projectSlot 1066 (some 1058) 1075 1089
def droppedOuter := projectSlot 1059 none 1062 1070
def droppedInner := projectSlot 1071 (some 1059) 1082 1097
def issued := [keptOuter,keptInner,droppedOuter,droppedInner]
def selected := [keptOuter,keptInner]

theorem measured_old_rejection : oldInventoryGate issued selected = false := by decide
theorem measured_new_support : checkedSupport issued selected = true := by decide
theorem changed_owner_rejected :
    checkedSupport issued [{keptInner with parent := some 1059}] = false := by decide
theorem changed_type_rejected : checkedSupport issued
    [{keptInner with source := {keptInner.source with exactType := "RELATION[6:Person]"}}] = false := by decide

/- The two actual inv14 conjuncts differ in the orientation of the forbidden
   shared project. The owner disappears by duplicate-formula normalization,
   not by assuming Project inhabited or by dropping an unused existential. -/
def clause (projects : Person → Project → Prop) (a b : Person) : Prop :=
  ∃ p, (projects a p ∧ projects b p) → ∀ q, projects a q → ¬ projects b q

def reverseClause (projects : Person → Project → Prop) (a b : Person) : Prop :=
  ∃ p, (projects a p ∧ projects b p) → ∀ q, projects b q → ¬ projects a q

theorem oriented_nonintersection (projects : Person → Project → Prop) (a b : Person) :
    clause projects a b ↔ reverseClause projects a b := by
  constructor
  · rintro ⟨p,h⟩
    exact ⟨p,fun common q bq aq => h common q aq bq⟩
  · rintro ⟨p,h⟩
    exact ⟨p,fun common q aq bq => h common q bq aq⟩

theorem natural_duplicate_conjunct (students : Person → Prop) (projects : Person → Project → Prop) :
    ((∀ a, students a → ∀ b, students b → clause projects a b) ∧
      (∀ a, students a → ∀ b, students b → reverseClause projects a b)) ↔
      (∀ a, students a → ∀ b, students b → clause projects a b) := by
  constructor
  · exact And.left
  · intro h
    exact ⟨h,fun a ha b hb => (oriented_nonintersection projects a b).mp (h a ha b hb)⟩

theorem empty_project_not_erased (projects : Person → Empty → Prop) (a b : Person) :
    ¬ clause projects a b := by rintro ⟨p,_⟩; exact nomatch p

end SelectedOwnerSupport
