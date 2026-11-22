import Std

/- Exact source-call correspondence, not function unfolding or equivalence of
   paid edits. A Slot includes its owner and type; alpha spelling is display only.
   Parser normalization and the finite Java extraction are separate trust edges. -/
namespace ScopedCallCorrespondence

structure Slot where
  owner : String
  coordinate : String
  type : String
  phase : Nat
  deriving DecidableEq, Repr

structure Head where
  opcode : String
  sourceName : String
  identity : String
  type : String
  lineage : Nat
  metadata : List String
  deriving DecidableEq, Repr

inductive Term where
  | variable : Slot → Term
  | node : Head → List Term → Term

structure Call where
  head : Head
  owner : Nat
  phase : Nat
  arguments : List Term

-- Evaluation uses the same ordered operations and exact owned variables.
def eval {V : Type} (environment : Slot → V) (operation : Head → List V → V) : Term → V
  | .variable slot => environment slot
  | .node head args => operation head (args.map (eval environment operation))

def evalCall {V : Type} (environment : Slot → V) (operation : Head → List V → V)
    (call : Call) : V :=
  operation call.head (call.arguments.map (eval environment operation))

def admits (original comparison : Call) : Prop := original = comparison

theorem admitted_source_call_sound {V : Type} (environment : Slot → V)
    (operation : Head → List V → V) (original comparison : Call)
    (checked : admits original comparison) :
    evalCall environment operation original = evalCall environment operation comparison := by
  rw [checked]

theorem admitted_preserves_owner (original comparison : Call)
    (checked : admits original comparison) :
    original.owner = comparison.owner ∧ original.phase = comparison.phase ∧
      original.arguments = comparison.arguments ∧ original.head = comparison.head := by
  cases checked
  exact ⟨rfl, rfl, rfl, rfl⟩

-- Exact gate in NativeOperationComparison.Endpoint.census, prior to this repair.
def oldGate (scopedAdmission : Bool) (locals : Nat) (closed bound nullary : Bool) : Bool :=
  scopedAdmission || (decide (locals = 0) && (closed || bound || nullary))

#print axioms admitted_source_call_sound
#print axioms admitted_preserves_owner
end ScopedCallCorrespondence
