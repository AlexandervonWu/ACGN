import Std

/- Executable occurrence-store contract. Addresses include component, phase and
   child/owner coordinates in the implementation; payloads include literal types.
   This model is not a proof of Java, parser normalization or wire certification. -/
namespace DistanceDerivedTrace

abbrev Store (A P : Type) := A → Option P

structure Operation (A P : Type) where
  address : A
  before : Option P
  after : Option P
  charge : Nat

def apply [DecidableEq A] [DecidableEq P] (s : Store A P) (op : Operation A P) :
    Option (Store A P) :=
  if s op.address = op.before then
    some (fun a => if a = op.address then op.after else s a)
  else none

def run [DecidableEq A] [DecidableEq P] (s : Store A P) :
    List (Operation A P) → Option (Store A P)
  | [] => some s
  | op :: ops => (apply s op).bind (fun next => run next ops)

def cost (ops : List (Operation A P)) : Nat := (ops.map Operation.charge).sum

theorem stale_rejected [DecidableEq A] [DecidableEq P] (s : Store A P)
    (op : Operation A P) (h : s op.address ≠ op.before) : apply s op = none := by
  simp [apply, h]

theorem outside_unchanged [DecidableEq A] [DecidableEq P] (s : Store A P)
    (op : Operation A P) (h : s op.address = op.before) (a : A)
    (different : a ≠ op.address) :
    (apply s op).map (fun next => next a) = some (s a) := by
  simp [apply, h, different]

theorem run_append [DecidableEq A] [DecidableEq P] (xs ys : List (Operation A P))
    (s : Store A P) : run s (xs ++ ys) = (run s xs).bind (fun next => run next ys) := by
  induction xs generalizing s with
  | nil => rfl
  | cons op xs ih =>
    simp only [List.cons_append, run]
    cases h : apply s op with
    | none => rfl
    | some next => exact ih next

theorem cost_append (xs ys : List (Operation A P)) : cost (xs ++ ys) = cost xs + cost ys := by
  simp [cost]

structure Decision (A P : Type) where
  operations : List (Operation A P)
  value : Nat
  charged : cost operations = value

/- Both projections consume the very same selected object. Ties retain the
   first candidate; replay must not select another member of the optimum. -/
def choose (a b : Decision A P) : Decision A P := if a.value ≤ b.value then a else b

theorem choose_min (a b : Decision A P) : (choose a b).value = min a.value b.value := by
  unfold choose
  split <;> rename_i h
  · simp [Nat.min_eq_left h]
  · simp [Nat.min_eq_right (Nat.le_of_lt (Nat.lt_of_not_ge h))]

theorem choose_tie (a b : Decision A P) (h : a.value = b.value) : choose a b = a := by
  simp [choose, h]

theorem chosen_trace_cost (a b : Decision A P) :
    cost (choose a b).operations = min a.value b.value :=
  (choose a b).charged.trans (choose_min a b)

/- The certified producer has an additional canonical-witness tie priority.
   Either tie policy retains an attaining decision, not a copied scalar. -/
def chooseWithTie (preferLeft : Bool) (a b : Decision A P) : Decision A P :=
  if a.value < b.value ∨ (a.value = b.value ∧ preferLeft = true) then a else b

theorem policy_trace_cost (preferLeft : Bool) (a b : Decision A P) :
    cost (chooseWithTie preferLeft a b).operations = min a.value b.value := by
  unfold chooseWithTie
  split <;> rename_i h
  · rw [a.charged, Nat.min_eq_left (by omega)]
  · rw [b.charged, Nat.min_eq_right (by omega)]

theorem composed_endpoint [DecidableEq A] [DecidableEq P]
    (a b : Decision A P) (source middle target : Store A P)
    (first : run source a.operations = some middle)
    (second : run middle b.operations = some target) :
    run source (a.operations ++ b.operations) = some target ∧
      cost (a.operations ++ b.operations) = a.value + b.value := by
  constructor
  · rw [run_append, first]; exact second
  · rw [cost_append, a.charged, b.charged]

#print axioms stale_rejected
#print axioms outside_unchanged
#print axioms run_append
#print axioms cost_append
#print axioms choose_min
#print axioms choose_tie
#print axioms chosen_trace_cost
#print axioms policy_trace_cost
#print axioms composed_endpoint

/- A matrix head edit consumes one original occurrence and produces one target
   occurrence. Child addresses and native type/owner observations are payloads.
   The selected metric head charge belongs to this transfer, not to two CRUDs. -/
def transfer [DecidableEq A] [DecidableEq P] (source target : Store A P)
    (a b : A) (before after : P) : Option (Store A P × Store A P) :=
  if source a = some before ∧ target b = none then
    some ((fun x => if x = a then none else source x),
      (fun x => if x = b then some after else target x))
  else none

theorem transfer_consumes [DecidableEq A] [DecidableEq P] (source target : Store A P)
    (a b : A) (before after : P) (h : source a = some before ∧ target b = none) :
    (transfer source target a b before after).map (fun next => next.1 a) = some none := by
  simp [transfer, h]

theorem transfer_produces [DecidableEq A] [DecidableEq P] (source target : Store A P)
    (a b : A) (before after : P) (h : source a = some before ∧ target b = none) :
    (transfer source target a b before after).map (fun next => next.2 b) = some (some after) := by
  simp [transfer, h]

theorem transfer_rejects_stale [DecidableEq A] [DecidableEq P] (source target : Store A P)
    (a b : A) (before after : P) (h : source a ≠ some before) :
    transfer source target a b before after = none := by
  simp [transfer, h]

theorem transfer_rejects_overwrite [DecidableEq A] [DecidableEq P] (source target : Store A P)
    (a b : A) (before after : P) (h : target b ≠ none) :
    transfer source target a b before after = none := by
  simp [transfer, h]

#print axioms transfer_consumes
#print axioms transfer_produces
#print axioms transfer_rejects_stale
#print axioms transfer_rejects_overwrite
end DistanceDerivedTrace
