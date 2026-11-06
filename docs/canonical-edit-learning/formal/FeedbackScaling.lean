import Lean

namespace FeedbackScaling

inductive Split where | train | validation | evaluation deriving DecidableEq

def gradientAllowed (split : Split) : Bool := split == .train

theorem no_validation_gradient : gradientAllowed .validation = false := rfl
theorem no_evaluation_gradient : gradientAllowed .evaluation = false := rfl

theorem same_question_same_split {Q : Type} (assign : Q → Split)
    (a b : Q) (h : a = b) : assign a = assign b := congrArg assign h

def selected {A Evidence : Type} (ordered : List A) (quota : Nat)
    (_teacherEvidence : Evidence) := ordered.take quota

theorem selection_ignores_teacher {A E : Type} (xs : List A) (quota : Nat) (a b : E) :
    selected xs quota a = selected xs quota b := rfl

theorem selection_bound {A E : Type} (xs : List A) (quota : Nat) (e : E) :
    (selected xs quota e).length ≤ quota := by
  simp only [selected, List.length_take]
  exact Nat.min_le_left _ _

def repaired (supported accepted : Bool) := supported && accepted

theorem unsupported_not_repaired (accepted : Bool) : repaired false accepted = false := rfl

def denominator (outcomes : List Bool) := outcomes.length

theorem failure_retained (outcomes : List Bool) :
    denominator (false :: outcomes) = denominator outcomes + 1 := rfl

structure Candidate where
  validationRepairs : Nat
  parameters : Nat
  deriving DecidableEq

def prefer (a b : Candidate) : Bool :=
  decide (a.validationRepairs > b.validationRepairs ∨
    (a.validationRepairs = b.validationRepairs ∧ a.parameters < b.parameters))

theorem smaller_wins_validation_tie (a b : Candidate)
    (h : a.validationRepairs = b.validationRepairs) (small : a.parameters < b.parameters) :
    prefer a b = true := by simp [prefer, h, small]

def selectionKey (c : Candidate) (_evaluationRepairs : Nat) := c

theorem test_does_not_select (c : Candidate) (a b : Nat) :
    selectionKey c a = selectionKey c b := rfl

def cachedRead {E : Type} (source : Nat → E) (key : Nat)
    (stored : Option {value : E // value = source key}) : E :=
  match stored with
  | none => source key
  | some entry => entry.val

theorem cache_preserves_example {E : Type} (source : Nat → E) (key : Nat)
    (stored : Option {value : E // value = source key}) :
    cachedRead source key stored = source key := by
  cases stored with
  | none => rfl
  | some entry => exact entry.property

#print axioms no_validation_gradient
#print axioms no_evaluation_gradient
#print axioms same_question_same_split
#print axioms selection_ignores_teacher
#print axioms selection_bound
#print axioms unsupported_not_repaired
#print axioms failure_retained
#print axioms smaller_wins_validation_tie
#print axioms test_does_not_select
#print axioms cache_preserves_example
end FeedbackScaling
