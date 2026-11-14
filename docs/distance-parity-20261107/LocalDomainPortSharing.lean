import LocalDomainOperand

/- Exact typed operand sharing changes storage indices, not declaration order,
   domains, scope, or the number of local result columns. -/
namespace LocalDomainPortSharing

def intern [DecidableEq P] (ports : List P) (port : P) : List P × Nat :=
  if port ∈ ports then (ports, ports.idxOf port)
  else (ports ++ [port], ports.length)

theorem intern_lookup [DecidableEq P] (ports : List P) (port : P) :
    (intern ports port).1[(intern ports port).2]? = some port := by
  unfold intern
  split
  · rename_i h
    change ports[ports.idxOf port]? = some port
    rw [List.getElem?_eq_getElem (List.idxOf_lt_length_of_mem h)]
    simp
  · simp

theorem previous_lookup [DecidableEq P] (ports : List P) (port : P)
    (i : Nat) (within : i < ports.length) :
    (intern ports port).1[i]? = ports[i]? := by
  unfold intern
  split
  · rfl
  · exact List.getElem?_append_left within

def meaningAt (meaning : P → E → A → Prop) (ports : List P)
    (index : Nat) (env : E) (value : A) : Prop :=
  match ports[index]? with
  | none => False
  | some port => meaning port env value

theorem intern_sound [DecidableEq P] (meaning : P → E → A → Prop)
    (ports : List P) (port : P) (env : E) (value : A) :
    meaningAt meaning (intern ports port).1 (intern ports port).2 env value ↔
      meaning port env value := by
  simp only [meaningAt, intern_lookup]

theorem previous_sound [DecidableEq P] (meaning : P → E → A → Prop)
    (ports : List P) (port : P) (i : Nat) (within : i < ports.length)
    (env : E) (value : A) :
    meaningAt meaning (intern ports port).1 i env value ↔
      meaningAt meaning ports i env value := by
  simp only [meaningAt, previous_lookup ports port i within]

theorem same_port_reused [DecidableEq P] (port : P) :
    intern [port] port = ([port], 0) := by simp [intern]

theorem unequal_port_retained [DecidableEq P] (a b : P) (different : a ≠ b) :
    intern [a] b = ([a,b], 1) := by simp [intern, Ne.symm different]

-- Interpretation may depend on every ambient value. No extensional domain
-- equivalence or faithful extraction is assumed to obtain exact-port sharing.
theorem two_ordered_columns [DecidableEq P] (meaning : P → E → A → Prop)
    (port : P) (env : E) (x y : A) (body : A → A → Prop) :
    (meaningAt meaning [port,port] 0 env x ∧
      meaningAt meaning [port,port] 1 env y ∧ body x y) ↔
    (meaningAt meaning (intern [port] port).1 0 env x ∧
      meaningAt meaning (intern [port] port).1 (intern [port] port).2 env y ∧ body x y) := by
  simp [same_port_reused, meaningAt]

mutual
  inductive Key where
    | node : String → List String → KeyList → Key
    deriving DecidableEq
  inductive KeyList where
    | nil
    | cons : Key → KeyList → KeyList
    deriving DecidableEq
end

structure Port where
  schema : String
  caller : String
  support : String
  target : String
  embedding : List (Nat × Nat)
  typedKey : Key
  deriving DecidableEq

def oldObservationGate (a b : Key) : Bool := decide (a = b)

end LocalDomainPortSharing
