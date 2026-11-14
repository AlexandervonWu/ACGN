import AuthenticatedPhaseTransport

/- Alternatives are a candidate inventory, not extra children of a selected
   endpoint. This law does not select an alternative or establish its semantic
   validity. Native selection/replay and source authentication remain separate. -/
namespace SelectedPrimaryCongruence

structure Node (Payload : Type) where
  payload : Payload
  children : List Nat
  alternatives : List Nat
  deriving DecidableEq, Repr

abbrev Graph (Payload : Type) := Nat → Option (Node Payload)

inductive Step where
  | child (index : Nat)
  | alternative (index : Nat)
  deriving DecidableEq, Repr

def walk (graph : Graph P) (root : Nat) : List Step → Option (Node P)
  | [] => graph root
  | step :: rest => do
    let node ← graph root
    let next ← match step with
      | .child i => node.children[i]?
      | .alternative i => node.alternatives[i]?
    walk graph next rest

def eraseAlternatives (graph : Graph P) : Graph P :=
  fun root => (graph root).map (fun node => { node with alternatives := [] })

def primary (address : List Nat) : List Step := address.map Step.child

theorem primary_lookup (graph : Graph P) (root : Nat) (address : List Nat) :
    walk (eraseAlternatives graph) root (primary address) =
      (walk graph root (primary address)).map (fun node => { node with alternatives := [] }) := by
  induction address generalizing root with
  | nil => rfl
  | cons index rest ih =>
    cases h : graph root with
    | none => simp [walk, primary, eraseAlternatives, h]
    | some node =>
      cases hc : node.children[index]? with
      | none => simp [walk, primary, eraseAlternatives, h, hc]
      | some next => simpa [walk, primary, eraseAlternatives, h, hc] using ih next

def store (graph : Graph P) (root : Nat) : DistanceDerivedTrace.Store (List Nat) P :=
  fun address => (walk graph root (primary address)).map Node.payload

theorem all_primary_payloads (graph : Graph P) (root : Nat) :
    store (eraseAlternatives graph) root = store graph root := by
  funext address
  simp [store, primary_lookup, Option.map_map, Function.comp_def]

theorem selected_program_unchanged [DecidableEq P] (graph : Graph P) (root : Nat)
    (program : List (DistanceDerivedTrace.Operation (List Nat) P)) :
    DistanceDerivedTrace.run (store (eraseAlternatives graph) root) program =
      DistanceDerivedTrace.run (store graph root) program := by
  rw [all_primary_payloads]

theorem invalid_program_stays_invalid [DecidableEq P] (graph : Graph P) (root : Nat)
    (program : List (DistanceDerivedTrace.Operation (List Nat) P))
    (invalid : DistanceDerivedTrace.run (store graph root) program = none) :
    DistanceDerivedTrace.run (store (eraseAlternatives graph) root) program = none := by
  rw [selected_program_unchanged, invalid]

def oldGate (node : Node P) : Bool := node.alternatives.isEmpty

theorem unused_alternative_old_rejection (payload : P) (children : List Nat)
    (first : Nat) (others : List Nat) :
    oldGate (Node.mk payload children (first :: others)) = false := rfl

theorem alternate_address_is_not_primary (index : Nat) (rest : List Step) (path : List Nat) :
    Step.alternative index :: rest ≠ primary path := by
  cases path <;> simp [primary]

theorem erased_alternate_rejected (graph : Graph P) (root index : Nat) (rest : List Step) :
    walk (eraseAlternatives graph) root (.alternative index :: rest) = none := by
  cases h : graph root <;> simp [walk, eraseAlternatives, h]

end SelectedPrimaryCongruence
