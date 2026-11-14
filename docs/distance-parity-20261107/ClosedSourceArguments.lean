import Focused225CallViews
import BoundCallAdmission
import Category72Contracts

/- Opaque source CALL congruence. Compound arguments remain ordered and exact;
   integer leaves are not invented module witnesses. Their authority is the
   retained parser-issued CALL anchor and the complete recursive source check. -/
namespace ClosedSourceArguments
open ScopedCallCorrespondence Focused225CallViews

def global (h : Head) : Shape := .node h .nil
def binary (h : Head) (a b : Shape) : Shape := .node h (.cons a (.cons b .nil))

def oldLeafGate : Shape → Bool
  | .node h .nil => h.opcode == "GLOBALBINDING"
  | _ => false

def closed : Shape → Bool
  | .node h .nil => h.opcode == "GLOBALBINDING" || (h.opcode == "CONSTANT" && h.type == "INT")
  | .node h (.cons a (.cons b .nil)) =>
      (h.opcode == "JOIN" || h.opcode == "MINUS" || h.opcode == "PLUS") && closed a && closed b
  | _ => false

structure IssuedCall where
  source : SourceKey
  head : BoundCallAdmission.Head
  arguments : List Shape
  deriving DecidableEq

def admits (issued current : IssuedCall) : Bool :=
  decide (issued.source = current.source ∧ issued.head = current.head ∧
    issued.arguments = current.arguments) && issued.arguments.all closed

theorem admitted_exact (issued current : IssuedCall) (checked : admits issued current = true) :
    issued = current := by
  simp only [admits, Bool.and_eq_true, decide_eq_true_eq] at checked
  have h := checked.1
  cases issued; cases current
  simp_all

def evaluate {V : Type} (environment : Slot → V) (operation : Head → List V → V)
    (invoke : SourceKey → BoundCallAdmission.Head → List V → V) (call : IssuedCall) : Option V := do
  let args ← call.arguments.mapM decode
  pure (invoke call.source call.head (args.map (eval environment operation)))

theorem opaque_congruence {V : Type} (environment : Slot → V)
    (operation : Head → List V → V)
    (invoke : SourceKey → BoundCallAdmission.Head → List V → V)
    (issued current : IssuedCall) (checked : admits issued current = true) :
    evaluate environment operation invoke current = evaluate environment operation invoke issued := by
  rw [admitted_exact issued current checked]

theorem foreign_source_rejected (issued current : IssuedCall)
    (different : issued.source ≠ current.source) : admits issued current = false := by
  simp [admits,different]

theorem reordered_arguments_rejected (issued current : IssuedCall)
    (different : issued.arguments ≠ current.arguments) : admits issued current = false := by
  simp [admits,different]

theorem variable_rejected (slot : Slot) : closed (.variable slot) = false := rfl

/- The ordered equality path above is retained. Relational PLUS inside an
   argument has a second path: exact source leaves, with union permutation.
   CALL slots themselves are never permuted. Java also retains every PLUS
   head's source occurrence and exact type before using this law. -/
def unionView : Shape → Category72.Calls.Argument Shape
  | s@(.node h (.cons a (.cons b .nil))) =>
      if h.opcode = "PLUS" then .plus (unionView a) (unionView b) else .leaf s
  | s => .leaf s

theorem union_argument_congruence {Atom : Type} {arity : Nat}
    (environment : Shape → (Fin arity → Atom) → Prop) (before after : Shape)
    (checked : (Category72.Calls.leaves (unionView before)).Perm
      (Category72.Calls.leaves (unionView after))) :
    Category72.Calls.relation environment (unionView before) =
      Category72.Calls.relation environment (unionView after) :=
  Category72.Calls.permuted_union_sound environment _ _ checked

theorem union_call_congruence {Atom Result : Type} {arity : Nat}
    (environment : Shape → (Fin arity → Atom) → Prop)
    (callee : SourceKey → BoundCallAdmission.Head → List ((Fin arity → Atom) → Prop) → Result)
    (issued current : IssuedCall)
    (source : issued.source = current.source) (head : issued.head = current.head)
    (arguments : Category72.Calls.ArgumentCorrespondence
      (issued.arguments.map unionView) (current.arguments.map unionView)) :
    callee issued.source issued.head
        ((issued.arguments.map unionView).map (Category72.Calls.relation environment)) =
      callee current.source current.head
        ((current.arguments.map unionView).map (Category72.Calls.relation environment)) := by
  rw [← source, ← head]
  exact Category72.Calls.opaque_call_congruence environment _ _ _ arguments

def head (op ty name : String) (lineage : Nat) : Head :=
  ⟨op,name,name,ty,lineage,[]⟩
def component := global (head "GLOBALBINDING" "RELATION[9:Component]" "Component" 50865)
def position := global (head "GLOBALBINDING" "RELATION[9:Component8:Position]" "cposition" 50866)
def joined := binary (head "JOIN" "RELATION[8:Position]" "" 50863) component position
def integer := global (head "CONSTANT" "INT" "1" 50864)
def argument := binary (head "PLUS" "RELATION[3:Int][8:Position]" "" 50860) joined integer
def natural : IssuedCall :=
  ⟨⟨"605999cf097a61cf8e768461c7cf05a8a75beb3ea03ceda4b2269177b409ded6",
    "inv4",50857,0,"phase[0]",0,[]⟩,
    ⟨1,1,.typecheckedImport,1,[2]⟩,[argument]⟩

/- These finite syntax/type observations are checked against the retained
   source probe. Numeric anchor tokens are a model, not Java issuance. -/
theorem natural_old_rejection : oldLeafGate argument = false := by decide
theorem natural_no_prefix_module : (none : Option Nat).isSome = false := rfl
theorem natural_compound_admitted : admits natural natural = true := by decide
def permutedArgument := binary (head "PLUS" "RELATION[3:Int][8:Position]" "" 50860) integer joined
theorem natural_union_permutation :
    (Category72.Calls.leaves (unionView argument)).Perm
      (Category72.Calls.leaves (unionView permutedArgument)) := by
  exact List.Perm.swap _ _ []
theorem natural_wrong_module :
    admits natural {natural with head.module := 2} = false := by decide
theorem natural_wrong_source :
    admits natural {natural with source.sourceHash := "foreign"} = false := by decide
theorem natural_wrong_phase :
    admits natural {natural with source.phase := 1} = false := by decide
theorem natural_wrong_integer :
    admits natural {natural with arguments := [binary
      (head "PLUS" "RELATION[3:Int][8:Position]" "" 50860) joined
      (global (head "CONSTANT" "INT" "2" 50864))]} = false := by decide
theorem natural_swapped_join :
    admits natural {natural with arguments := [binary
      (head "PLUS" "RELATION[3:Int][8:Position]" "" 50860)
      (binary (head "JOIN" "RELATION[8:Position]" "" 50863) position component) integer]} = false := by decide
theorem natural_congruence {V : Type} (environment : Slot → V)
    (operation : Head → List V → V)
    (invoke : SourceKey → BoundCallAdmission.Head → List V → V) :
    evaluate environment operation invoke natural = evaluate environment operation invoke natural :=
  opaque_congruence environment operation invoke natural natural natural_compound_admitted

end ClosedSourceArguments
