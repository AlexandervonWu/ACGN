import Lean

namespace FeedbackGNN

-- Algebraic boundary specifications. Floating-point autodiff remains in the TCB.
def total (xs : List Int) : Int := xs.sum

theorem aggregate_permutation (xs ys : List Int) (h : xs.Perm ys) :
    total xs = total ys := by
  induction h with
  | nil => rfl
  | cons a h ih => simpa [total, List.sum_cons] using congrArg (a + ·) ih
  | swap a b xs => simp [total, List.sum_cons, Int.add_left_comm]
  | trans h₁ h₂ ih₁ ih₂ => exact ih₁.trans ih₂

def channel (kind : Nat) (rows : List (Nat × Int)) :=
  (rows.filter (fun r => r.1 == kind)).map Prod.snd

theorem channel_ignores_other (kind other : Nat) (v : Int)
    (rows : List (Nat × Int)) (h : other ≠ kind) :
    channel kind ((other, v) :: rows) = channel kind rows := by
  simp [channel, h]

theorem channel_retains_member (kind : Nat) (v : Int) (rows : List (Nat × Int)) :
    channel kind ((kind, v) :: rows) = v :: channel kind rows := by
  simp [channel]

def score (query candidate : Int) := query * candidate

theorem score_context_difference (q delta candidate : Int) :
    score (q + delta) candidate - score q candidate = delta * candidate := by
  simp only [score, Int.add_mul]
  omega

theorem score_choice_difference (q a b : Int) :
    score q a - score q b = q * (a - b) := by
  simp [score, Int.mul_sub]

theorem context_sensitive_witness : score 1 2 - score 0 2 = 2 := rfl

structure PublicInput (Graph History Feedback : Type) where
  graph : Graph
  history : History
  feedback : Feedback

def predict {G H F Private Action : Type}
    (policy : PublicInput G H F → Action) (view : PublicInput G H F)
    (_hidden : Private) := policy view

theorem variant_private_independence {G H F P A : Type}
    (policy : PublicInput G H F → A) (view : PublicInput G H F) (a b : P) :
    predict policy view a = predict policy view b := rfl

-- Identical schedules compare algorithms without changing sampling by outcome.
def schedule (draw : Nat → Nat) (updates : Nat) := (List.range updates).map draw

theorem schedule_length (draw : Nat → Nat) (updates : Nat) :
    (schedule draw updates).length = updates := by simp [schedule]

theorem paired_schedule (draw : Nat → Nat) (updates : Nat) :
    schedule draw updates = schedule draw updates := rfl

def repaired (solverAccepted : Bool) (_gradientNorm : Int) := solverAccepted

theorem gradients_not_authority (accepted : Bool) (g1 g2 : Int) :
    repaired accepted g1 = repaired accepted g2 := rfl

theorem nonzero_gradient_cannot_certify (g : Int) : repaired false g = false := rfl

#print axioms aggregate_permutation
#print axioms channel_ignores_other
#print axioms channel_retains_member
#print axioms score_context_difference
#print axioms score_choice_difference
#print axioms context_sensitive_witness
#print axioms variant_private_independence
#print axioms schedule_length
#print axioms paired_schedule
#print axioms gradients_not_authority
#print axioms nonzero_gradient_cannot_certify
end FeedbackGNN
