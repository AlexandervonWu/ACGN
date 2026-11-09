import FormulaCallAdmission
import ScopedPaidAdmission

/- Source-linked formula calls under an unchanged local quantifier. The local
   owner is retained; the paid outer deletion is not a logical equivalence. -/
namespace LocalFormulaCallAdmission
open BoundCallAdmission

structure GateInput where
  kind : String
  result : String
  ordered : Bool
  relationAuthority : Bool
  deriving DecidableEq

def oldGate (c : GateInput) : Bool :=
  c.ordered && c.kind == "call/expression" && c.result == "RELATION" && c.relationAuthority
def newGate (c : GateInput) : Bool := c.ordered &&
  ((c.kind == "call/expression" && c.result == "RELATION" && c.relationAuthority) ||
   (c.kind == "call/formula" && c.result == "BOOL"))
def actualGate : GateInput := ⟨"call/formula","BOOL",true,false⟩
theorem exact_old_rejection : oldGate actualGate = false := by decide
theorem new_result_acceptance : newGate actualGate = true := by decide
theorem wrong_type_rejected : newGate { actualGate with result := "RELATION" } = false := by decide
theorem unordered_rejected : newGate { actualGate with ordered := false } = false := by decide

def actualFrame : ScopedPaidAdmission.Frame := ⟨183,186,189,188,1,1,.some⟩
def actualCall : Occurrence := ⟨⟨0,0,.declaration,0,[1,2]⟩,187,0⟩
structure ArgumentSource where
  occurrence : Nat
  owner : String
  role : String
  phase : Nat
  dependencies : List Nat
  type : String
  slot : Slot
  deriving DecidableEq
def teacher : ArgumentSource :=
  ⟨190,"root/predicate[0]/decl[0]@pos","MATRIX",0,[],"RELATION[6:Person]",⟨0,0⟩⟩
def classroom : ArgumentSource :=
  ⟨191,"root/predicate[0]/or[1]/local-decl[0]","LOCAL",0,[],"RELATION[5:Class]",⟨183,0⟩⟩
def actualArguments := [teacher,classroom]
def unchangedSource (frame : ScopedPaidAdmission.Frame) (call : Occurrence)
    (args : List ArgumentSource) : Bool :=
  decide (frame = actualFrame ∧ call = actualCall ∧ args = actualArguments)
theorem instantiated_source_premises :
    unchangedSource actualFrame actualCall actualArguments = true := by decide
theorem foreign_owner_rejected :
    unchangedSource { actualFrame with owner := 184 } actualCall actualArguments = false := by decide
theorem foreign_occurrence_rejected :
    unchangedSource actualFrame { actualCall with lineage := 188 } actualArguments = false := by decide
theorem argument_capture_rejected :
    unchangedSource actualFrame actualCall [teacher,{ classroom with slot := ⟨0,0⟩ }] = false := by decide
theorem phase_substitution_rejected :
    unchangedSource actualFrame actualCall [teacher,{ classroom with phase := 1 }] = false := by decide
theorem argument_order_rejected :
    unchangedSource actualFrame actualCall [classroom,teacher] = false := by decide

theorem scoped_formula_transport {V A : Type} (kind : ScopedPaidAdmission.Kind)
    (domain : A → Prop) (invoke : Head → List V → Prop) (head : Head)
    (old new : A → Slot → V) (r : Slot → Slot)
    (literal : Nat → V) (join difference : V → V → V)
    (links : ∀ x s, new x (r s) = old x s) (args : List Arg) :
    ScopedPaidAdmission.quantify kind domain
      (fun x => invoke head ((args.map (rename r)).map (eval (new x) literal join difference))) ↔
    ScopedPaidAdmission.quantify kind domain
      (fun x => invoke head (args.map (eval (old x) literal join difference))) :=
  ScopedPaidAdmission.retained_quantifier_congruence kind domain _ _
    (fun x => FormulaCallAdmission.formula_transport invoke head (old x) (new x) r
      literal join difference (links x) args)

def environment {Person Class : Type} (t : Person) (c : Class) (s : Slot) : Sum Person Class :=
  if s.owner = 183 then .inr c else .inl t
def actualArgs : List Arg := [.bound ⟨0,0⟩,.bound ⟨183,0⟩]
def invoke {Person Class : Type} (teaches : Person → Class → Prop)
    (_ : Head) : List (Sum Person Class) → Prop
  | [.inl t,.inr c] => teaches t c
  | _ => False

theorem concrete_call_body {Person Class : Type}
    (teaches : Person → Class → Prop) (t : Person) (c : Class) :
    invoke teaches actualCall.head
      (actualArgs.map (eval (environment t c) (fun _ => .inl t)
        (fun x _ => x) (fun x _ => x))) ↔ teaches t c := Iff.rfl

theorem actual_retained_existential_transport {Person Class : Type}
    (teaches : Person → Class → Prop) (t : Person) :
    ScopedPaidAdmission.quantify .some (fun _ : Class => True)
      (fun c => invoke teaches actualCall.head
        ((actualArgs.map (rename id)).map (eval (environment t c)
          (fun _ => .inl t) (fun x _ => x) (fun x _ => x)))) ↔
    ∃ c, teaches t c := by
  have h := scoped_formula_transport .some (fun _ : Class => True) (invoke teaches)
    actualCall.head (environment t) (environment t) id
    (fun _ => Sum.inl t) (fun x _ => x) (fun x _ => x) (fun _ _ => rfl) actualArgs
  simpa [ScopedPaidAdmission.quantify, actualArgs, eval, environment, invoke] using h

theorem actual_retained_existential_transport_reverse {Person Class : Type}
    (teaches : Person → Class → Prop) (t : Person) :
    (∃ c, teaches t c) ↔
    ScopedPaidAdmission.quantify .some (fun _ : Class => True)
      (fun c => invoke teaches actualCall.head
        ((actualArgs.map (rename id)).map (eval (environment t c)
          (fun _ => .inl t) (fun x _ => x) (fun x _ => x)))) :=
  (actual_retained_existential_transport teaches t).symm

def localCoordinate := ScopedPaidAdmission.Coordinate.local [actualFrame] 0
theorem paid_outer_deletion_does_not_capture_local :
    ScopedPaidAdmission.link (fun _ => none) localCoordinate = some localCoordinate := rfl

def callNode : FormulaCallAdmission.SelectedNode :=
  ⟨187,"root/child/0/child/0/child/1","BOOL"⟩
def tNode : FormulaCallAdmission.SelectedNode :=
  ⟨190,"root/child/0/child/0/child/1/child/0","RELATION[6:Person]"⟩
def cNode : FormulaCallAdmission.SelectedNode :=
  ⟨191,"root/child/0/child/0/child/1/child/1","RELATION[5:Class]"⟩
def selectedSubtree := [callNode,tNode,cNode]
theorem selected_operations_7_8_9_delete :
    MatrixReplay.Replay FormulaCallAdmission.ChargedEdit selectedSubtree [] 3 :=
  .next (FormulaCallAdmission.ChargedEdit.delete _ _)
    (.next (FormulaCallAdmission.ChargedEdit.delete _ _)
      (.next (FormulaCallAdmission.ChargedEdit.delete _ _) (.done _)))
theorem selected_operations_7_8_9_insert :
    MatrixReplay.Replay FormulaCallAdmission.ChargedEdit [] selectedSubtree 3 :=
  .next (FormulaCallAdmission.ChargedEdit.insert callNode [])
    (.next (FormulaCallAdmission.ChargedEdit.insert tNode [callNode])
      (.next (FormulaCallAdmission.ChargedEdit.insert cNode [callNode,tNode]) (.done _)))

#print axioms scoped_formula_transport
#print axioms actual_retained_existential_transport
#print axioms actual_retained_existential_transport_reverse
#print axioms exact_old_rejection
#print axioms instantiated_source_premises
#print axioms selected_operations_7_8_9_delete
#print axioms selected_operations_7_8_9_insert
end LocalFormulaCallAdmission
