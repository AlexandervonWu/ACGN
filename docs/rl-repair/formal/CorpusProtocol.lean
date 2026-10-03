import Lean
import Std

namespace RepairCorpus

def scheduleValid (tasks episodes : Nat) (jobs : List Nat) : Prop :=
  tasks > 0 ∧ episodes > 0 ∧ jobs.mergeSort (· ≤ ·) = List.range (tasks * episodes)

instance (t e : Nat) (j : List Nat) : Decidable (scheduleValid t e j) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _))

def admitted (tasks episodes : Nat) (jobs : List Nat) : Bool :=
  decide (scheduleValid tasks episodes jobs)

theorem admission_valid (t e : Nat) (j : List Nat) (h : admitted t e j = true) :
    scheduleValid t e j := of_decide_eq_true h

theorem admission_positive (t e : Nat) (j : List Nat) (h : admitted t e j = true) :
    t > 0 ∧ e > 0 := ⟨(admission_valid t e j h).1, (admission_valid t e j h).2.1⟩

theorem sorted_schedule_exact (t e : Nat) (j : List Nat) (h : admitted t e j = true) :
    j.mergeSort (· ≤ ·) = List.range (t * e) := (admission_valid t e j h).2.2

theorem split_same_key (assign : Nat → Nat) (a b : Nat) (h : a = b) :
    assign a = assign b := congrArg assign h

structure Paired where
  learned : Nat
  random : Nat
  budget : Nat
  aborted : Nat
  deriving Lean.FromJson, Lean.ToJson, Repr

def usable (r : Paired) : Prop :=
  r.budget > 0 ∧ r.learned ≤ r.budget ∧ r.random ≤ r.budget ∧ r.aborted = 0

instance (r : Paired) : Decidable (usable r) :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _ ∧ _))

def stable (rows : List Paired) : Bool :=
  decide (rows.length = 5 ∧ ∀ r ∈ rows, usable r ∧ r.random < r.learned)

theorem stable_five (rs : List Paired) (h : stable rs = true) : rs.length = 5 :=
  (of_decide_eq_true h).1

theorem stable_each_win (rs : List Paired) (r : Paired) (h : stable rs = true)
    (mem : r ∈ rs) : r.random < r.learned := (of_decide_eq_true h).2 r mem |>.2

theorem stable_no_aborts (rs : List Paired) (r : Paired) (h : stable rs = true)
    (mem : r ∈ rs) : r.aborted = 0 := (of_decide_eq_true h).2 r mem |>.1.2.2.2

theorem stable_bounded (rs : List Paired) (r : Paired) (h : stable rs = true)
    (mem : r ∈ rs) : r.learned ≤ r.budget ∧ r.random ≤ r.budget := by
  have u := (of_decide_eq_true h).2 r mem |>.1
  exact ⟨u.2.1, u.2.2.1⟩

structure Request where
  tasks : Nat
  episodes : Nat
  jobs : List Nat
  rows : List Paired
  deriving Lean.FromJson, Lean.ToJson

end RepairCorpus

def main : IO Unit := do
  let line ← (← IO.getStdin).getLine
  let json ← match Lean.Json.parse line with
    | .ok j => pure j
    | .error e => throw (IO.userError e)
  let r ← match Lean.fromJson? json (α := RepairCorpus.Request) with
    | .ok r => pure r
    | .error e => throw (IO.userError e)
  if !RepairCorpus.admitted r.tasks r.episodes r.jobs then
    throw (IO.userError "Invalid complete training schedule")
  IO.println (Lean.Json.mkObj [("accepted", Lean.toJson true),
    ("stable", Lean.toJson (RepairCorpus.stable r.rows)), ("request", Lean.toJson r)]).compress
