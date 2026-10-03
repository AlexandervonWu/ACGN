import Std

/- The initial repair kernel. Types and lexical environments are indices.
   Parsing, Alloy denotation, source spans, and the Java runtime are not proved here. -/
namespace ACGNRepair

inductive Ty where
  | formula
  | relation (columns : List Nat)
  deriving DecidableEq, Repr

inductive BoolOp where
  | conj | disj | implies | iff
  deriving DecidableEq, Repr

inductive RelOp where
  | union | intersection | difference
  deriving DecidableEq, Repr

inductive Quantifier where
  | all | some | no | one | lone
  deriving DecidableEq, Repr

inductive Term : List Ty -> Ty -> Type where
  | atom (name : Nat) (sort : Ty) : Term env sort
  | bound (index : Nat) (lookup : env[index]? = some sort) : Term env sort
  | neg : Term env .formula -> Term env .formula
  | binary : BoolOp -> Term env .formula -> Term env .formula -> Term env .formula
  | relation : RelOp -> Term env (.relation cols) -> Term env (.relation cols) ->
      Term env (.relation cols)
  | cardinality : Quantifier -> Term env (.relation cols) -> Term env .formula
  | quantify : Quantifier -> Term env (.relation cols) ->
      Term (.relation cols :: env) .formula -> Term env .formula

/- A typed one-hole context keeps the hole's lexical environment separate from
   the containing expression's environment, including under a quantifier. -/
inductive Context : List Ty -> Ty -> List Ty -> Ty -> Type where
  | hole : Context env sort env sort
  | neg : Context outer .formula inner sort -> Context outer .formula inner sort
  | left : BoolOp -> Context outer .formula inner sort -> Term outer .formula ->
      Context outer .formula inner sort
  | right : BoolOp -> Term outer .formula -> Context outer .formula inner sort ->
      Context outer .formula inner sort
  | relLeft : RelOp -> Context outer (.relation cols) inner sort ->
      Term outer (.relation cols) -> Context outer (.relation cols) inner sort
  | relRight : RelOp -> Term outer (.relation cols) ->
      Context outer (.relation cols) inner sort -> Context outer (.relation cols) inner sort
  | card : Quantifier -> Context outer (.relation cols) inner sort ->
      Context outer .formula inner sort
  | body : Quantifier -> Term outer (.relation cols) ->
      Context (.relation cols :: outer) .formula inner sort ->
      Context outer .formula inner sort

def plug : Context outer result inner sort -> Term inner sort -> Term outer result
  | .hole, replacement => replacement
  | .neg ctx, replacement => .neg (plug ctx replacement)
  | .left op ctx right, replacement => .binary op (plug ctx replacement) right
  | .right op left ctx, replacement => .binary op left (plug ctx replacement)
  | .relLeft op ctx right, replacement => .relation op (plug ctx replacement) right
  | .relRight op left ctx, replacement => .relation op left (plug ctx replacement)
  | .card op ctx, replacement => .cardinality op (plug ctx replacement)
  | .body op domain ctx, replacement => .quantify op domain (plug ctx replacement)

theorem typed_replacement (ctx : Context outer result inner sort)
    (replacement : Term inner sort) :
    Exists fun output : Term outer result => output = plug ctx replacement :=
  ⟨plug ctx replacement, rfl⟩

theorem left_edit_keeps_right (op : BoolOp)
    (ctx : Context outer .formula inner sort) (right : Term outer .formula)
    (replacement : Term inner sort) :
    plug (.left op ctx right) replacement = .binary op (plug ctx replacement) right := rfl

theorem binder_edit_keeps_domain (op : Quantifier) (domain : Term outer (.relation cols))
    (ctx : Context (.relation cols :: outer) .formula inner sort)
    (replacement : Term inner sort) :
    plug (.body op domain ctx) replacement = .quantify op domain (plug ctx replacement) := rfl

def relabelBoolean (replacement : BoolOp) : Term env .formula -> Term env .formula
  | .binary _ left right => .binary replacement left right
  | other => other

theorem relabel_binary_keeps_children (old replacement : BoolOp)
    (left right : Term env .formula) :
    relabelBoolean replacement (.binary old left right) = .binary replacement left right := rfl

theorem absent_binding_cannot_be_used (env : List Ty) (index : Nat) (sort : Ty)
    (absent : env[index]? = none) : env[index]? ≠ some sort := by
  simp [absent]

theorem repair_need_not_preserve_meaning : (!false) != false := by decide

def splice (before replacement after : List α) : List α :=
  before ++ replacement ++ after

theorem splice_preserves_prefix (before replacement after : List α) :
    (splice before replacement after).take before.length = before := by
  simp [splice, List.append_assoc]

theorem splice_preserves_suffix (before replacement after : List α) :
    (splice before replacement after).drop (before.length + replacement.length) = after := by
  simp [splice]

structure State where
  revision : Nat
  remaining : Nat
  edits : Nat
  stopped : Bool
  context : String
  theory : String
  deriving DecidableEq, Repr

inductive Outcome where
  | closed | exhausted | stale | stopRequested | rejected | applied
  deriving DecidableEq, Repr

structure Result where
  state : State
  outcome : Outcome
  deriving DecidableEq, Repr

def step (s : State) (fresh stop admitted : Bool) : Result :=
  if s.stopped then ⟨s, .closed⟩
  else if s.remaining = 0 then ⟨s, .exhausted⟩
  else
    let next := { s with remaining := s.remaining - 1 }
    if !fresh then ⟨next, .stale⟩
    else if stop then ⟨{ next with stopped := true }, .stopRequested⟩
    else if !admitted then ⟨next, .rejected⟩
    else ⟨{ next with revision := s.revision + 1, edits := s.edits + 1 }, .applied⟩

theorem context_preserved (s : State) (fresh stop admitted : Bool) :
    (step s fresh stop admitted).state.context = s.context := by
  cases hs : s.stopped <;> cases fresh <;> cases stop <;> cases admitted <;>
    by_cases hz : s.remaining = 0 <;> simp [step, hs, hz]

theorem theory_preserved (s : State) (fresh stop admitted : Bool) :
    (step s fresh stop admitted).state.theory = s.theory := by
  cases hs : s.stopped <;> cases fresh <;> cases stop <;> cases admitted <;>
    by_cases hz : s.remaining = 0 <;> simp [step, hs, hz]

theorem bounded_attempt (s : State) (fresh stop admitted : Bool)
    (active : s.stopped = false) (fuel : 0 < s.remaining) :
    (step s fresh stop admitted).state.remaining + 1 = s.remaining := by
  cases fresh <;> cases stop <;> cases admitted <;>
    simp [step, active, Nat.ne_of_gt fuel] <;> omega

theorem rejected_keeps_revision (s : State) (fresh stop admitted : Bool)
    (h : (step s fresh stop admitted).outcome ≠ .applied) :
    (step s fresh stop admitted).state.revision = s.revision := by
  cases hs : s.stopped <;> cases fresh <;> cases stop <;> cases admitted <;>
    by_cases hz : s.remaining = 0 <;> simp_all [step]

theorem stop_is_not_applied (s : State) (fresh admitted : Bool) :
    (step s fresh true admitted).outcome ≠ .applied := by
  cases hs : s.stopped <;> cases fresh <;> cases admitted <;>
    by_cases hz : s.remaining = 0 <;> simp [step, hs, hz]

theorem stale_is_not_applied (s : State) (stop admitted : Bool) :
    (step s false stop admitted).outcome ≠ .applied := by
  cases hs : s.stopped <;> cases stop <;> cases admitted <;>
    by_cases hz : s.remaining = 0 <;> simp [step, hs, hz]

theorem unadmitted_is_not_applied (s : State) (fresh stop : Bool) :
    (step s fresh stop false).outcome ≠ .applied := by
  cases hs : s.stopped <;> cases fresh <;> cases stop <;>
    by_cases hz : s.remaining = 0 <;> simp [step, hs, hz]

def outcomeCode : Outcome -> Nat
  | .closed => 0 | .exhausted => 1 | .stale => 2
  | .stopRequested => 3 | .rejected => 4 | .applied => 5

def bit (b : Bool) : Nat := if b then 1 else 0

end ACGNRepair

/- A finite, mechanically compared control-flow fixture, not a proof of Java. -/
def main : IO Unit := do
  for remaining in [0, 1, 2, 5] do
    for revision in [0, 3] do
      for stopped in [false, true] do
        for fresh in [false, true] do
          for stop in [false, true] do
            for admitted in [false, true] do
              let s : ACGNRepair.State := ⟨revision, remaining, revision, stopped, "ctx", "R0"⟩
              let r := ACGNRepair.step s fresh stop admitted
              IO.println s!"CONTROL,{remaining},{revision},{ACGNRepair.bit stopped},{ACGNRepair.bit fresh},{ACGNRepair.bit stop},{ACGNRepair.bit admitted},{ACGNRepair.outcomeCode r.outcome},{r.state.remaining},{r.state.revision},{r.state.edits},{ACGNRepair.bit r.state.stopped},{r.state.context},{r.state.theory}"
