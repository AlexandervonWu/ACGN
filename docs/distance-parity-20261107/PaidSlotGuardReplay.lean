import PaidSlotDomainIntegration
import Phase5SourceRules

namespace PaidSlotGuardReplay
open PaidSlotGuardAuthentication

/- A carrier requires no matrix atom. An explicit guard must occur in the
   selected native edit, on its own side; its opposite may be a body atom or
   absent. This does not identify a deletion with zero-cost transport. -/
structure Node where
  occurrence : Nat
  path : String
  exactType : String
  opcode : String
  deriving DecidableEq, Repr

structure Edit where
  source : Option Node
  target : Option Node
  cost : Nat
  deriving DecidableEq, Repr

structure Requirement where
  declaration : Occurrence
  guard : Option Node
  deriving DecidableEq, Repr

structure Cover where
  owner : String
  operations : List Edit
  charge : Nat
  deriving DecidableEq, Repr

def covers (sourceSide : Bool) (issued : List Occurrence) (requirement : Requirement)
    (selected : List Cover) (emitted : List Edit) (coverIndex editIndex replayIndex : Nat) : Bool :=
  authentic issued requirement.declaration &&
  match requirement.guard with
  | none => true
  | some guard =>
    match selected[coverIndex]?, emitted[replayIndex]? with
    | some cover, some edit => decide (cover.owner = requirement.declaration.owner ∧
        cover.operations[editIndex]? = some edit ∧
        cover.charge = (cover.operations.map Edit.cost).sum ∧
        (if sourceSide then edit.source else edit.target) = some guard)
    | _, _ => false

theorem carrier_still_authenticated (side : Bool) (issued : List Occurrence)
    (requirement : Requirement) (selected : List Cover) (emitted : List Edit) (c i j : Nat)
    (h : covers side issued requirement selected emitted c i j = true) :
    requirement.declaration ∈ issued := by
  simp only [covers, Bool.and_eq_true] at h
  exact authentic_is_issued _ _ h.1

theorem required_guard_selected_and_paid (side : Bool) (issued : List Occurrence)
    (requirement : Requirement) (selected : List Cover) (emitted : List Edit) (c i j : Nat)
    (guard : Node) (required : requirement.guard = some guard)
    (h : covers side issued requirement selected emitted c i j = true) :
    ∃ cover edit, selected[c]? = some cover ∧ emitted[j]? = some edit ∧
      cover.owner = requirement.declaration.owner ∧ cover.operations[i]? = some edit ∧
      cover.charge = (cover.operations.map Edit.cost).sum ∧
      (if side then edit.source else edit.target) = some guard := by
  simp only [covers, required, Bool.and_eq_true] at h
  cases hc : selected[c]? with
  | none => simp [hc] at h
  | some cover =>
    cases he : emitted[j]? with
    | none => simp [hc, he] at h
    | some edit =>
      exact ⟨cover, edit, rfl, rfl, by simpa [hc, he] using h.2⟩

theorem missing_cover_rejected (side : Bool) (issued : List Occurrence)
    (requirement : Requirement) (emitted : List Edit) (c i j : Nat)
    (guard : Node) (required : requirement.guard = some guard) :
    covers side issued requirement [] emitted c i j = false := by
  simp [covers, required]

theorem carrier_lowering (body : Prop) : (True → body) ↔ body := by simp

/- Only copies of the issued guard in the same Boolean association island may
   share its origin. This is idempotence, not a search for an arbitrary body atom. -/
theorem guard_or_duplicate (guard body alias : Prop) (same : alias ↔ guard) :
    (guard ∨ (body ∨ alias)) ↔ (guard ∨ body) := by
  constructor
  · intro h
    rcases h with g | b | a
    · exact Or.inl g
    · exact Or.inr b
    · exact Or.inl (same.mp a)
  · intro h
    rcases h with g | b
    · exact Or.inl g
    · exact Or.inr (Or.inl b)

theorem guard_and_duplicate (guard body alias : Prop) (same : alias ↔ guard) :
    (guard ∧ (body ∧ alias)) ↔ (guard ∧ body) := by
  constructor
  · intro h
    exact ⟨h.1, h.2.1⟩
  · intro h
    exact ⟨h.1, h.2, same.mpr h.1⟩

theorem duplicate_in_same_context (context : Context) (guard body alias : Prop)
    (same : alias ↔ guard) :
    context.eval (guard ∨ (body ∨ alias)) ↔ context.eval (guard ∨ body) := by
  exact context_transport context _ _ (guard_or_duplicate guard body alias same)

theorem changing_boolean_context_is_not_idempotence :
    ¬ ((True ∨ (False ∧ True)) ↔ (True ∧ False)) := by simp

theorem triggered_dual_in_guard_context (context : Context)
    (left right : Nat → Prop) (now : Nat) :
    context.eval (¬ pastTriggered left right now) ↔
      context.eval (pastSince (fun t => ¬ left t) (fun t => ¬ right t) now) :=
  context_transport context _ _ (negated_triggered_is_since_not left right now)

theorem since_dual_in_guard_context (context : Context)
    (left right : Nat → Prop) (now : Nat) :
    context.eval (¬ pastSince left right now) ↔
      context.eval (pastTriggered (fun t => ¬ left t) (fun t => ¬ right t) now) :=
  context_transport context _ _ (negated_since_is_triggered_not left right now)

def guardNode : Node := ⟨17, "root/child/0", "BOOL", "NOT_IN"⟩
def bodyNode : Node := ⟨18, "root/child/0", "RELATION[1:A]", "JOIN"⟩
def explicit : Requirement := ⟨PaidSlotGuardAuthentication.target, some guardNode⟩
def carrier : Requirement := ⟨PaidSlotGuardAuthentication.source, none⟩
def update : Edit := ⟨some bodyNode, some guardNode, 1⟩
def insert : Edit := ⟨none, some guardNode, 1⟩
def delete : Edit := ⟨some guardNode, none, 1⟩

theorem carrier_to_guard_update :
    covers true [carrier.declaration] carrier [] [] 0 0 0 = true ∧
    covers false [explicit.declaration] explicit [⟨explicit.declaration.owner,[update],1⟩] [update] 0 0 0 = true := by decide
theorem guard_insert_is_paid :
    covers false [explicit.declaration] explicit [⟨explicit.declaration.owner,[insert],1⟩] [insert] 0 0 0 = true := by decide
theorem guard_delete_is_paid :
    covers true [explicit.declaration] explicit [⟨explicit.declaration.owner,[delete],1⟩] [delete] 0 0 0 = true := by decide
theorem wrong_side_rejected :
    covers true [explicit.declaration] explicit [⟨explicit.declaration.owner,[insert],1⟩] [insert] 0 0 0 = false := by decide
theorem unselected_edit_rejected :
    covers false [explicit.declaration] explicit [⟨explicit.declaration.owner,[update],1⟩] [insert] 0 0 0 = false := by decide
theorem wrong_cover_charge_rejected :
    covers false [explicit.declaration] explicit [⟨explicit.declaration.owner,[insert],0⟩] [insert] 0 0 0 = false := by decide

end PaidSlotGuardReplay
