import LocalOwnerTrace
import LocalDomainOperand

/- Comparison alpha names are presentation, not source authority. This contract
   preserves each original ordered group, its domain and its lexical slots.
   The Java correspondence is checked separately on captured actual objects. -/
namespace LocalDeclarationProjection

structure Slot where
  coordinate : LocalOwnerTrace.Slot
  occurrence : Nat
  exactType : String
  phase : Nat
  role : String
  dependencies : List LocalOwnerTrace.Slot
  deriving DecidableEq

structure Group where
  opcode : String
  owner : Nat
  parent : Nat
  occurrence : Nat
  domainOccurrence : Nat
  domainType : String
  multiplicity : String
  disjointness : Nat
  slots : List Slot
  deriving DecidableEq

structure View where
  group : Group
  names : List String
  deriving DecidableEq

def copy (rename : Slot → String) (v : View) : View :=
  { group := v.group, names := v.group.slots.map rename }

def exactGroups (original selected : List View) : Bool :=
  decide (original.map View.group = selected.map View.group)

-- Exact conjunct at LocalOwnerCorrespondence.walk's demonstrated first failure.
def oldTupleGate (old current : Group) : Bool :=
  old.opcode == current.opcode && old.occurrence == current.occurrence &&
  old.domainOccurrence == current.domainOccurrence && old.slots.length == current.slots.length

theorem copied_tuple_gate (rename : Slot → String) (v : View) :
    oldTupleGate v.group (copy rename v).group = true := by
  simp [oldTupleGate, copy]

def split (v : View) : List View :=
  v.group.slots.map fun slot =>
    { group := {v.group with slots := [slot]}, names := [] }

theorem copied_group (rename : Slot → String) (v : View) :
    (copy rename v).group = v.group := rfl

theorem copied_groups (rename : Slot → String) (vs : List View) :
    (vs.map (copy rename)).map View.group = vs.map View.group := by
  simp [copy, List.map_map, Function.comp_def]

theorem exact_group_gate_kept (rename : Slot → String) (vs : List View) :
    exactGroups vs (vs.map (copy rename)) = true := by
  unfold exactGroups
  rw [copied_groups]
  simp

-- Domains can depend on all preceding original slots. Copying names does not
-- insert a new scope, split a group, exchange slots, or evaluate its domain later.
def permits (domain : Group → (Slot → α) → α → Prop)
    (env : Slot → α) (v : View) : Prop :=
  ∀ slot ∈ v.group.slots, domain v.group env (env slot)

def comprehension (domain : Group → (Slot → α) → α → Prop)
    (body : (Slot → α) → Prop) (vs : List View) (env : Slot → α) : Prop :=
  (∀ v ∈ vs, permits domain env v) ∧ body env

theorem copied_comprehension (domain : Group → (Slot → α) → α → Prop)
    (body : (Slot → α) → Prop) (rename : Slot → String)
    (vs : List View) (env : Slot → α) :
    comprehension domain body (vs.map (copy rename)) env ↔
      comprehension domain body vs env := by
  simp [comprehension, permits, copy]

theorem ordered_columns_retained (rename : Slot → String) (vs : List View) :
    ((vs.map (copy rename)).flatMap fun v => v.group.slots) =
      (vs.flatMap fun v => v.group.slots) := by
  simp [List.flatMap_map, copy]

theorem original_scope_retained (rename : Slot → String) (v : View) :
    (copy rename v).group.owner = v.group.owner ∧
    (copy rename v).group.parent = v.group.parent ∧
    (copy rename v).group.domainOccurrence = v.group.domainOccurrence ∧
    (copy rename v).group.slots = v.group.slots := by
  exact ⟨rfl, rfl, rfl, rfl⟩

theorem no_foreign_slot (rename : Slot → String) (v : View) (s : Slot)
    (foreign : s ∉ v.group.slots) : s ∉ (copy rename v).group.slots := foreign

theorem changed_group_rejected (a b : View) (h : a.group ≠ b.group) :
    exactGroups [a] [b] = false := by simp [exactGroups, h]

-- The retained local occurrence address is unchanged, including the actual
-- selected operation's before premise and charge, not just a scalar minimum.
theorem retained_operation (s : LocalOwnerTrace.Store) (a : LocalOwnerTrace.Action) :
    LocalOwnerTrace.apply s (LocalOwnerTrace.transport id a) =
      LocalOwnerTrace.apply s a := rfl

def execute (s : LocalOwnerTrace.Store) : List LocalOwnerTrace.Action → Option LocalOwnerTrace.Store
  | [] => some s
  | a :: as => (LocalOwnerTrace.apply s a).bind fun t => execute t as

theorem retained_selected_path (s : LocalOwnerTrace.Store) (as : List LocalOwnerTrace.Action) :
    execute s (as.map (LocalOwnerTrace.transport id)) = execute s as := by
  have h : as.map (LocalOwnerTrace.transport id) = as := by
    induction as with
    | nil => rfl
    | cons a as ih => simp only [List.map_cons, ih]; rfl
  rw [h]

-- Relational meaning of the encountered State/Event comprehension. Empty
-- carriers are permitted; no inhabited-domain premise is silently introduced.
def transitionComprehension (states : S → Prop) (events : E → Prop)
    (trans : S → E → S → Prop) (pair : S × S) : Prop :=
  states pair.1 ∧ states pair.2 ∧ ∃ e, events e ∧ trans pair.1 e pair.2

theorem source_comprehension_columns (states : S → Prop) (events : E → Prop)
    (trans : S → E → S → Prop) (s1 s2 : S) :
    transitionComprehension states events trans (s1,s2) ↔
      states s1 ∧ states s2 ∧ ∃ e, events e ∧ trans s1 e s2 := Iff.rfl

theorem empty_state_not_in_comprehension (events : E → Prop) (trans : S → E → S → Prop)
    (pair : S × S) : ¬ transitionComprehension (fun _ => False) events trans pair := by
  intro h; exact h.1

theorem swapped_columns_not_sound :
    transitionComprehension (fun _ : Bool => True) (fun _ : Unit => True)
      (fun a _ b => a = false ∧ b = true) (false,true) ∧
    ¬ transitionComprehension (fun _ : Bool => True) (fun _ : Unit => True)
      (fun a _ b => a = false ∧ b = true) (true,false) := by
  constructor
  · exact ⟨trivial,trivial,(),trivial,rfl,rfl⟩
  · rintro ⟨_,_,_,_,h,_⟩; cases h

namespace Regrouping

-- Term is the checked, typed domain expression, not its occurrence label.
-- Its interpretation may depend on the ambient environment. Java checks
-- expression correspondence and retained object identity separately.
structure Declaration (Term : Type) where
  view : View
  domain : Term
  deriving DecidableEq

def compatible [DecidableEq Term] (a b : Declaration Term) : Bool :=
  decide (a.domain = b.domain ∧ a.view.group.opcode = "GENERICRELDECL" ∧
    b.view.group.opcode = "GENERICRELDECL" ∧
    a.view.group.owner = b.view.group.owner ∧ a.view.group.parent = b.view.group.parent ∧
    a.view.group.domainType = b.view.group.domainType ∧
    a.view.group.multiplicity = b.view.group.multiplicity ∧
    a.view.group.disjointness = 0 ∧ b.view.group.disjointness = 0)

def merge (a b : Declaration Term) : Declaration Term :=
  { domain := a.domain
    view := { group := { a.view.group with slots := a.view.group.slots ++ b.view.group.slots }
              names := a.view.names ++ b.view.names } }

def accepts (meaning : Term → (Slot → A) → A → Prop)
    (env : Slot → A) (d : Declaration Term) : Prop :=
  ∀ s ∈ d.view.group.slots, meaning d.domain env (env s)

theorem merge_sound [DecidableEq Term] (a b : Declaration Term)
    (checked : compatible a b = true)
    (meaning : Term → (Slot → A) → A → Prop) (env : Slot → A) :
    accepts meaning env (merge a b) ↔ accepts meaning env a ∧ accepts meaning env b := by
  have terms : a.domain = b.domain := (of_decide_eq_true checked).1
  constructor
  · intro h
    constructor
    · intro s hs
      exact h s (List.mem_append_left _ hs)
    · intro s hs
      rw [← terms]
      exact h s (List.mem_append_right _ hs)
  · rintro ⟨ha, hb⟩ s hs
    cases List.mem_append.mp hs with
    | inl h => exact ha s h
    | inr h =>
      change meaning a.domain env (env s)
      rw [terms]
      exact hb s h

theorem comprehension_sound [DecidableEq Term] (a b : Declaration Term)
    (checked : compatible a b = true)
    (meaning : Term → (Slot → A) → A → Prop) (body : (Slot → A) → Prop)
    (env : Slot → A) :
    (accepts meaning env (merge a b) ∧ body env) ↔
      ((accepts meaning env a ∧ accepts meaning env b) ∧ body env) := by
  rw [merge_sound a b checked]

theorem columns_and_original_coordinates (a b : Declaration Term) :
    (merge a b).view.group.slots = a.view.group.slots ++ b.view.group.slots := rfl

-- Object tokens stand for references captured before serialization. The Java
-- checker uses reference equality and rechecks each original group; metadata
-- equality is deliberately absent from this identity condition.
structure Invocation where
  targetClass : Nat
  targetOccurrence : Nat
  slotMap : List (String × String)
  deriving DecidableEq

def invoke (edge : Invocation) (env : String → A) (slot : String) : Option A :=
  ((edge.slotMap.find? fun p => p.1 == slot).map Prod.snd).map env

def sameInvocation (captured actual : Invocation) : Bool := decide (captured = actual)

theorem checked_invocation_environment (captured actual : Invocation)
    (checked : sameInvocation captured actual = true) (env : String → A) (slot : String) :
    invoke captured env slot = invoke actual env slot := by
  have equal : captured = actual := of_decide_eq_true checked
  rw [equal]

theorem checked_invocation_meaning (captured actual : Invocation)
    (checked : sameInvocation captured actual = true)
    (env : String → A) (meaning : (String → Option A) → Prop) :
    meaning (invoke captured env) ↔ meaning (invoke actual env) := by
  have equal : captured = actual := of_decide_eq_true checked
  rw [equal]

structure Capture (Term : Type) where
  ownerObject : Nat
  groupObjects : List Nat
  domainObjects : List Nat
  declarations : List (Declaration Term)
  invocations : List Invocation := []
  deriving DecidableEq

def sameCapture [DecidableEq Term] (retained supplied : Capture Term) : Bool :=
  decide (retained = supplied)

theorem capture_recovers_originals [DecidableEq Term] (a b : Capture Term)
    (checked : sameCapture a b = true) : a = b := of_decide_eq_true checked

theorem capture_preserves_invocations [DecidableEq Term] (a b : Capture Term)
    (checked : sameCapture a b = true) : a.invocations = b.invocations := by
  rw [capture_recovers_originals a b checked]

theorem foreign_capture_rejected [DecidableEq Term] (a b : Capture Term)
    (different : a ≠ b) : sameCapture a b = false := by simp [sameCapture, different]

end Regrouping

end LocalDeclarationProjection
