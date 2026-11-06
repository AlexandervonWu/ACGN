import Lean
set_option autoImplicit false

namespace ContextualRepair

inductive Verdict where
  | counterexample | unknown | solved
  deriving DecidableEq, Repr

structure Receipt where
  revision : Nat
  verdict : Verdict
  deriving DecidableEq, Repr

structure State where
  revision : Nat
  decisions : Nat
  queries : Nat
  receipt : Option Receipt
  deriving DecidableEq, Repr

def accepted (s : State) : Prop :=
  ∃ r, s.receipt = some r ∧ r.revision = s.revision ∧ r.verdict = .solved

def commit (s : State) : State :=
  { s with revision := s.revision + 1, decisions := s.decisions - 1, receipt := none }

def observe (s : State) (r : Receipt) : State :=
  if s.decisions > 0 ∧ s.queries > 0 ∧ r.revision = s.revision then
    { s with decisions := s.decisions - 1, queries := s.queries - 1, receipt := some r }
  else s

theorem commit_invalidates_success (s : State) : ¬ accepted (commit s) := by
  simp [accepted, commit]

theorem query_accounting (s : State) (r : Receipt)
    (h : s.decisions > 0 ∧ s.queries > 0 ∧ r.revision = s.revision) :
    (observe s r).decisions + 1 = s.decisions ∧
    (observe s r).queries + 1 = s.queries := by
  simp [observe, h]
  omega

theorem receipt_bound (s : State) (r : Receipt)
    (h : s.decisions > 0 ∧ s.queries > 0 ∧ r.revision = s.revision) :
    accepted (observe s r) ↔ r.verdict = .solved := by
  simp [observe, h, accepted]

theorem counterexample_not_success (s : State) (r : Receipt)
    (h : s.decisions > 0 ∧ s.queries > 0 ∧ r.revision = s.revision)
    (v : r.verdict = .counterexample) : ¬ accepted (observe s r) := by
  rw [receipt_bound s r h, v]
  decide

theorem unknown_not_success (s : State) (r : Receipt)
    (h : s.decisions > 0 ∧ s.queries > 0 ∧ r.revision = s.revision)
    (v : r.verdict = .unknown) : ¬ accepted (observe s r) := by
  rw [receipt_bound s r h, v]
  decide

theorem stale_receipt_unchanged (s : State) (r : Receipt)
    (h : r.revision ≠ s.revision) : observe s r = s := by
  simp [observe, h]

theorem exhausted_query_unchanged (s : State) (r : Receipt)
    (h : s.queries = 0) : observe s r = s := by
  simp [observe, h]

theorem exhausted_decision_unchanged (s : State) (r : Receipt)
    (h : s.decisions = 0) : observe s r = s := by
  simp [observe, h]

-- A rejected construction consumes a decision, not a new semantic receipt.
def reject (s : State) : State := { s with decisions := s.decisions - 1 }

theorem rejection_preserves_receipt (s : State) :
    (reject s).receipt = s.receipt := rfl

theorem rejection_cannot_create_success (s : State) :
    accepted (reject s) ↔ accepted s := Iff.rfl

def contextAt {Public Memory : Type} (step : Memory → Public → Memory)
    (initial : Memory) (events : List Public) (n : Nat) : Memory :=
  (events.take n).foldl step initial

theorem no_future_context {Public Memory : Type} (step : Memory → Public → Memory)
    (initial : Memory) (past future : List Public) :
    contextAt step initial (past ++ future) past.length = past.foldl step initial := by
  simp [contextAt]

theorem reset_is_empty_context {Public Memory : Type} (step : Memory → Public → Memory)
    (initial : Memory) (events : List Public) :
    contextAt step initial events 0 = initial := by
  simp [contextAt]

theorem same_public_prefix_same_prediction {Public Memory Action Private : Type}
    (step : Memory → Public → Memory) (initial : Memory) (policy : Memory → Action)
    (events : List Public) (a b : Private) :
    policy ((events.foldl step initial, a).1) =
    policy ((events.foldl step initial, b).1) := rfl

theorem ordered_context_example :
    contextAt (fun h e : Nat => 2 * h + e) 0 [1, 2] 2 ≠
    contextAt (fun h e : Nat => 2 * h + e) 0 [2, 1] 2 := by decide

def admitTraining (splitIsTrain replayMatches : Bool) : Bool :=
  splitIsTrain && replayMatches

theorem no_heldout_training (replayed : Bool) :
    admitTraining false replayed = false := by simp [admitTraining]

theorem unreplayed_not_admitted (train : Bool) :
    admitTraining train false = false := by simp [admitTraining]

#print axioms commit_invalidates_success
#print axioms query_accounting
#print axioms receipt_bound
#print axioms counterexample_not_success
#print axioms unknown_not_success
#print axioms stale_receipt_unchanged
#print axioms exhausted_query_unchanged
#print axioms exhausted_decision_unchanged
#print axioms rejection_preserves_receipt
#print axioms rejection_cannot_create_success
#print axioms no_future_context
#print axioms reset_is_empty_context
#print axioms same_public_prefix_same_prediction
#print axioms ordered_context_example
#print axioms no_heldout_training
#print axioms unreplayed_not_admitted

end ContextualRepair
