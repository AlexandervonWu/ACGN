import Lean

namespace CorpusTraining

inductive Split where | train | validation | test deriving DecidableEq

theorem same_question_same_split {Group : Type} (assign : Group → Split)
    (a b : Group) (h : a = b) : assign a = assign b := congrArg assign h

theorem split_isolation {Group : Type} (assign : Group → Split) (g : Group)
    (train : assign g = .train) : assign g ≠ .test := by
  simp [train]

structure Record (Input Label : Type) where
  observation : Input
  target : Label

def policyInput {I L : Type} (r : Record I L) : I := r.observation

theorem labels_not_in_policy_input {I L : Type} (x : I) (a b : L) :
    policyInput (Record.mk x a) = policyInput (Record.mk x b) := rfl

def best (costs : List Nat) (cost : Nat) : Prop :=
  cost ∈ costs ∧ ∀ other ∈ costs, cost ≤ other

theorem optimal_ties_retained (costs : List Nat) (a b : Nat)
    (optimal : best costs a) (equalCost : a = b) : best costs b := by
  simpa [← equalCost] using optimal

def success (feasible noExtra noMissing : Bool) : Bool :=
  feasible && noExtra && noMissing

theorem solver_success_requires_both_directions (f e m : Bool)
    (h : success f e m = true) : f = true ∧ e = true ∧ m = true := by
  cases f <;> cases e <;> cases m <;> simp_all [success]

theorem failed_attempt_is_not_success (f m : Bool) : success f false m = false := by
  simp [success]

def withinBudget {A : Type} (ranked : List A) (budget : Nat) := ranked.take budget

theorem matched_attempt_bound {A : Type} (ranked : List A) (budget : Nat) :
    (withinBudget ranked budget).length ≤ budget := by
  simp only [withinBudget, List.length_take]
  exact Nat.min_le_left _ _

theorem no_extra_attempt_at_zero {A : Type} (ranked : List A) :
    withinBudget ranked 0 = [] := by simp [withinBudget]

def readOnlyOperatorToken (op : Fin 5) : Nat := 104 + op.val

theorem read_only_tokens_fit (op : Fin 5) : readOnlyOperatorToken op < 128 := by
  have h := op.isLt
  simp only [readOnlyOperatorToken]
  omega

theorem read_only_tokens_injective (a b : Fin 5)
    (h : readOnlyOperatorToken a = readOnlyOperatorToken b) : a = b := by
  apply Fin.ext
  simp only [readOnlyOperatorToken] at h
  omega

theorem read_only_tokens_separate (op : Fin 5) (old : Nat) (h : old < 104) :
    readOnlyOperatorToken op ≠ old := by
  simp only [readOnlyOperatorToken]
  omega

def compactNat (n : Fin 65536) : List Nat :=
  if n.val < 16 then [64 + n.val]
  else [14, 64 + n.val % 16, 64 + n.val / 16 % 16,
    64 + n.val / 256 % 16, 64 + n.val / 4096]

def decodeCompact : List Nat → Nat
  | [x] => x - 64
  | [14, a, b, c, d] => a - 64 + 16 * (b - 64) + 256 * (c - 64) + 4096 * (d - 64)
  | _ => 65536

theorem compact_roundtrip (n : Fin 65536) : decodeCompact (compactNat n) = n.val := by
  simp only [compactNat]
  split
  · simp [decodeCompact]
  · simp only [decodeCompact, Nat.add_sub_cancel_left]
    omega

theorem compact_injective (a b : Fin 65536) (h : compactNat a = compactNat b) : a = b := by
  apply Fin.ext
  have equal := congrArg decodeCompact h
  simpa [compact_roundtrip] using equal

end CorpusTraining
