import BoundCallAdmission

/- A nullary call keeps its parser-resolved opaque interpretation. No body is
   unfolded and no caller binder is captured. The producer must authenticate
   the issued source anchor; serialized metadata alone is not that authority. -/
namespace NullarySourceCall
universe u

inductive Kind where | formula | expression deriving DecidableEq
inductive Ty where | bool | relation (carrier : String) deriving DecidableEq

structure Head where
  callee : String
  sourceName : String
  kind : Kind
  authority : BoundCallAdmission.Authority
  result : Ty
  arity : Nat
  deriving DecidableEq

structure Call where
  head : Head
  lineage : Nat
  parserOccurrence : Nat
  sourceAnchor : Nat
  arguments : List Nat
  unordered : Bool
  relationAncestry : Bool
  phase : Nat
  role : String
  branch : List Nat
  deriving DecidableEq

def resultWellTyped (h : Head) : Prop :=
  match h.kind, h.result with
  | .formula, .bool => True
  | .expression, .relation _ => True
  | _, _ => False
instance (h : Head) : Decidable (resultWellTyped h) := by
  unfold resultWellTyped; split <;> infer_instance

/- Exact old ClosedCallEvidence shape gate restricted to empty children. -/
def relationResult : Ty → Bool
  | .relation _ => true
  | .bool => false

def oldClosed (c : Call) : Bool := decide (
  c.head.kind = .expression ∧ c.head.authority = .typecheckedImport ∧
  c.head.arity ≤ 64 ∧ c.unordered = false ∧
  relationResult c.head.result = true ∧
  c.relationAncestry = true)

def oldBoundArity (c : Call) : Bool := decide (0 < c.head.arity ∧ c.head.arity ≤ 64)

def admits (issued : Call) (current : Call) : Bool := decide (
  current = issued ∧ issued.head.arity = 0 ∧ issued.arguments = [] ∧
  issued.unordered = false ∧ resultWellTyped issued.head ∧
  (relationResult issued.head.result = true → issued.relationAncestry = true))

theorem admitted_exact (issued current : Call) (h : admits issued current = true) :
    current = issued ∧ issued.head.arity = 0 ∧ issued.arguments = [] ∧
    issued.unordered = false ∧ resultWellTyped issued.head ∧
    (relationResult issued.head.result = true → issued.relationAncestry = true) := of_decide_eq_true h

def value (Value : Ty → Type u)
    (interpret : Nat → String → List Nat → (head : Head) → Value head.result)
    (call : Call) : Sigma Value :=
  ⟨call.head.result, interpret call.phase call.role call.branch call.head⟩

theorem typed_opaque_call_preserved (Value : Ty → Type u)
    (interpret : Nat → String → List Nat → (head : Head) → Value head.result) (issued current : Call)
    (checked : admits issued current = true) :
    value Value interpret current = value Value interpret issued ∧
    current.head.result = issued.head.result ∧ current.arguments = [] := by
  obtain ⟨rfl, _, args, _, _⟩ := admitted_exact issued current checked
  exact ⟨rfl, rfl, args⟩

/- Caller environments are intentionally not inputs to a resolved nullary
   callee. The same interpretation and exact phase/role/branch are retained;
   this is not transport to a different time or a different source owner. -/
theorem ambient_independent (Value : Ty → Type u)
    (interpret : Nat → String → List Nat → (head : Head) → Value head.result) (issued current : Call)
    (checked : admits issued current = true) (oldEnv : A) (newEnv : B) :
    (fun (_ : A) => value Value interpret issued) oldEnv =
      (fun (_ : B) => value Value interpret current) newEnv :=
  (typed_opaque_call_preserved Value interpret issued current checked).1.symm

theorem foreign_source_rejected (issued current : Call)
    (different : current.sourceAnchor ≠ issued.sourceAnchor) :
    admits issued current = false := by
  have ne : current ≠ issued := fun h => different (congrArg Call.sourceAnchor h)
  simp [admits, ne]

theorem wrong_occurrence_rejected (issued current : Call)
    (different : current.lineage ≠ issued.lineage) : admits issued current = false := by
  have ne : current ≠ issued := fun h => different (congrArg Call.lineage h)
  simp [admits, ne]

theorem nonempty_arguments_rejected (issued current : Call)
    (nonempty : issued.arguments ≠ []) : admits issued current = false := by
  simp [admits, nonempty]

def natural : Call :=
  ⟨⟨"anonymous/sha256-728a21e9b31d59497cc1c0ba9ca869cb1bf744a7a16e16cf1361e71121b3a710/inv3",
    "inv3", .formula, .declaration, .bool, 0⟩,125,0,1,[],false,false,0,"NONE",[0,0,0]⟩

theorem natural_old_closed_rejection : oldClosed natural = false := by decide
theorem natural_old_bound_rejection : oldBoundArity natural = false := by decide
theorem natural_admission : admits natural natural = true := by decide
theorem natural_reverse : admits natural natural = true := natural_admission
theorem natural_foreign_source : admits natural { natural with sourceAnchor := 2 } = false := by decide
theorem natural_wrong_occurrence : admits natural { natural with lineage := 126 } = false := by decide
theorem natural_wrong_callee : admits natural { natural with head := { natural.head with callee := "foreign/inv3" } } = false := by decide
theorem natural_wrong_type : admits natural { natural with head := { natural.head with result := .relation "Person" } } = false := by decide
theorem natural_added_argument : admits natural { natural with arguments := [7] } = false := by decide
theorem natural_wrong_phase : admits natural { natural with phase := 1 } = false := by decide
theorem natural_wrong_role : admits natural { natural with role := "ALWAYS" } = false := by decide
theorem natural_wrong_branch : admits natural { natural with branch := [0,1,0] } = false := by decide

/- Held-out declared relation-valued nullary shape, not another natural source.
   The rule is parameterized; these constants never dispatch corpus cases. -/
def heldout : Call :=
  ⟨⟨"module/f", "f", .expression, .declaration, .relation "A", 0⟩,9,3,7,[],false,true,2,"ALWAYS",[1,0]⟩
theorem heldout_old_rejection : oldClosed heldout = false := by decide
theorem heldout_admission : admits heldout heldout = true := by decide
theorem untyped_relation_rejected :
    admits {heldout with relationAncestry := false}
      {heldout with relationAncestry := false} = false := by decide
theorem invalid_result_rejected :
    admits {heldout with head := {heldout.head with result := .bool}}
      {heldout with head := {heldout.head with result := .bool}} = false := by decide

#print axioms typed_opaque_call_preserved
#print axioms ambient_independent
#print axioms foreign_source_rejected
#print axioms natural_admission
end NullarySourceCall
