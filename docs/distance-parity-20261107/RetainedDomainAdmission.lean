import Focused225CallViews
import RetainedDifferenceDomain

/- Retention, not domain simplification or free transport between carriers.
   The domain is resolved in its enclosing scope before its slots are bound. -/
namespace RetainedDomainAdmission
open Focused225CallViews ScopedCallCorrespondence

structure Frame where
  sourceHash : String
  predicate : String
  owner : Nat
  parent : Nat
  phase : Nat
  declaration : Nat
  domain : Nat
  kind : String
  type : String
  slots : List Slot
  enclosing : List Slot
  deriving DecidableEq

def uses : Shape → List Slot
  | .variable slot => [slot]
  | .node _ args => uses args
  | .nil => []
  | .cons term rest => uses term ++ uses rest

def wellFormed (frame : Frame) (term : Shape) : Bool :=
  match term with
  | .node wrapper (.cons (.node expression _) .nil) =>
      decide (wrapper.opcode = "ONE" ∧ wrapper.type = frame.type ∧
        expression.type = frame.type ∧ wrapper.lineage = frame.domain) &&
      (uses term).all (fun slot => decide (slot ∈ frame.enclosing ∧ slot ∉ frame.slots)) &&
      (decode term).isSome
  | _ => false

def keyMatches (frame : Frame) (key : SourceKey) : Bool :=
  decide (key.sourceHash = frame.sourceHash ∧ key.predicate = frame.predicate ∧
    key.lineage = frame.domain ∧ key.occurrence = frame.declaration ∧
    key.phase = frame.phase ∧ key.owner = toString frame.owner)

def check (originalFrame currentFrame : Frame) (registry : List View)
    (view : View) : Option Shape := do
  if originalFrame ≠ currentFrame ∨ keyMatches originalFrame view.key = false then none else
    let term ← transport registry view
    if wellFormed originalFrame term then some term else none

theorem checked_original (a b : Frame) (registry : List View) (view : View)
    (term : Shape) (accepted : check a b registry view = some term) :
    a = b ∧ keyMatches a view.key = true ∧ wellFormed a term = true ∧
    ∃ original, sourceAt registry view.key = some original ∧
      resolved original = some term ∧ resolved view = some term := by
  unfold check at accepted
  split at accepted
  next => simp at accepted
  next h =>
    have same : a = b := by simp_all
    have key : keyMatches a view.key = true := by simp_all
    cases ht : transport registry view with
    | none => simp [ht] at accepted
    | some t =>
      by_cases wf : wellFormed a t = true
      · simp [ht,wf] at accepted
        cases accepted
        exact ⟨same,key,wf,checked_transport_exact registry view term ht⟩
      · simp [ht,wf] at accepted

theorem checked_domain_evaluation {V : Type} (environment : Slot → V)
    (operation : Head → List V → V) (a b : Frame) (registry : List View)
    (view : View) (term : Shape) (accepted : check a b registry view = some term) :
    ∃ original, sourceAt registry view.key = some original ∧
      ((resolved original).bind decode).map (eval environment operation) =
      ((resolved view).bind decode).map (eval environment operation) := by
  obtain ⟨_,_,_,original,found,source,target⟩ := checked_original a b registry view term accepted
  exact ⟨original,found,by rw [source,target]⟩

theorem no_new_slot_capture (frame : Frame) (term : Shape)
    (checked : wellFormed frame term = true) (slot : Slot) (used : slot ∈ uses term) :
    slot ∉ frame.slots := by
  unfold wellFormed at checked
  split at checked
  next =>
    simp only [Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at checked
    exact (checked.1.2 slot used).2
  next => contradiction

theorem enclosing_scope_only (frame : Frame) (term : Shape)
    (checked : wellFormed frame term = true) (slot : Slot) (used : slot ∈ uses term) :
    slot ∈ frame.enclosing := by
  unfold wellFormed at checked
  split at checked
  next =>
    simp only [Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq] at checked
    exact (checked.1.2 slot used).1
  next => contradiction

theorem checked_decodable (frame : Frame) (term : Shape)
    (checked : wellFormed frame term = true) : ∃ value, decode term = some value := by
  cases hd : decode term with
  | none =>
    unfold wellFormed at checked
    split at checked <;> simp_all
  | some value => exact ⟨value,rfl⟩

theorem retained_quantifier (a b : Frame) (registry : List View) (view : View)
    (term : Shape) (accepted : check a b registry view = some term)
    (meaning : Shape → A → Prop) (kind : RetainedDifferenceDomain.Kind) (body : A → Prop) :
    ∃ original, sourceAt registry view.key = some original ∧
      ((resolved original).map (fun t => RetainedDifferenceDomain.quantify kind (meaning t) body)) =
      ((resolved view).map (fun t => RetainedDifferenceDomain.quantify kind (meaning t) body)) := by
  obtain ⟨_,_,_,original,found,source,target⟩ := checked_original a b registry view term accepted
  exact ⟨original,found,by rw [source,target]⟩

/- Necessary branch of FastLocalPaidScope.retainedDomain. After the ONE/type
   checks, Java returns false for every other expression opcode regardless of
   the remaining checks. The witness uses CALL, not an assumed domain law. -/
def oldExpressionGate (opcode : String) (globalRest minusRest : Bool) : Bool :=
  if opcode = "GLOBALBINDING" then globalRest
  else if opcode = "MINUS" then minusRest else false

theorem old_call_rejected (globalRest minusRest : Bool) :
    oldExpressionGate "CALL" globalRest minusRest = false := by
  simp [oldExpressionGate]

theorem changed_frame_rejected (a b : Frame) (registry : List View) (view : View)
    (different : a ≠ b) : check a b registry view = none := by simp [check,different]

theorem untransported_domain_rejected (a b : Frame) (registry : List View) (view : View)
    (missing : transport registry view = none) : check a b registry view = none := by
  simp [check,missing]

end RetainedDomainAdmission
