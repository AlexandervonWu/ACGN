import Lean
set_option autoImplicit false

namespace SlotTypingDeadline

structure Observation where
  completed : Bool
  elapsed : Nat
  deadline : Nat

def success (o : Observation) : Prop := o.completed = true ∧ o.elapsed < o.deadline

theorem timeout_is_failure (o : Observation) (h : o.deadline ≤ o.elapsed) :
    ¬ success o := by
  intro hs
  exact (Nat.not_lt.mpr h) hs.2

theorem incomplete_is_failure (o : Observation) (h : o.completed = false) :
    ¬ success o := by
  intro hs
  have hc := hs.1
  rw [h] at hc
  cases hc

theorem success_requires_completion (o : Observation) (h : success o) :
    o.completed = true := h.1

def countSuccess : List Bool → Nat
  | [] => 0
  | b :: bs => (if b then 1 else 0) + countSuccess bs

theorem success_count_bounded (xs : List Bool) : countSuccess xs ≤ xs.length := by
  induction xs with
  | nil => simp [countSuccess]
  | cons b bs ih => cases b <;> simp [countSuccess] <;> omega

#print axioms timeout_is_failure
#print axioms incomplete_is_failure
#print axioms success_requires_completion
#print axioms success_count_bounded

end SlotTypingDeadline
