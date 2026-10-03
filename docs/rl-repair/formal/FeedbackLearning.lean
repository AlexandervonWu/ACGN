import Std

/- Abstract RL-2/3 contracts. Solver correctness, floating point/autograd,
   and Java/Python refinement are explicitly outside this model. -/
namespace RepairLearning

inductive Answer where
  | sat | unsat | unknown | error
  deriving DecidableEq, Repr

inductive Verdict where
  | solved | counterexample | vacuous | unresolved
  deriving DecidableEq, Repr

def classify (compatible : Bool) (context extra missing : Answer) : Verdict :=
  if !compatible then .unresolved
  else match context, extra, missing with
    | .unsat, _, _ => .vacuous
    | .sat, .unsat, .unsat => .solved
    | .sat, .sat, .sat | .sat, .sat, .unsat | .sat, .unsat, .sat => .counterexample
    | _, _, _ => .unresolved

theorem solved_requires_two_unsat (compatible : Bool) (context extra missing : Answer)
    (h : classify compatible context extra missing = .solved) :
    compatible = true ∧ context = .sat ∧ extra = .unsat ∧ missing = .unsat := by
  cases compatible <;> cases context <;> cases extra <;> cases missing <;> simp_all [classify]

theorem vacuous_is_not_solved (compatible : Bool) (extra missing : Answer) :
    classify compatible .unsat extra missing ≠ .solved := by
  cases compatible <;> simp [classify]

theorem unknown_is_not_unsat (compatible : Bool) (context missing : Answer) :
    classify compatible context .unknown missing ≠ .solved := by
  cases compatible <;> cases context <;> simp [classify]

theorem two_directions_characterize_equality (C O : α -> Prop)
    (noExtra : ∀ x, ¬ (C x ∧ ¬ O x)) (noMissing : ∀ x, ¬ (O x ∧ ¬ C x)) :
    ∀ x, C x ↔ O x := by
  classical
  intro x
  constructor
  · intro hc
    by_cases ho : O x
    · exact ho
    · exact False.elim (noExtra x ⟨hc, ho⟩)
  · intro ho
    by_cases hc : C x
    · exact hc
    · exact False.elim (noMissing x ⟨ho, hc⟩)

def retain [BEq α] (capacity : Nat) (item : α) (bank : List α) : List α :=
  (item :: bank.filter (fun old => old != item)).take capacity

theorem bank_capacity [BEq α] (capacity : Nat) (item : α) (bank : List α) :
    (retain capacity item bank).length ≤ capacity := by
  simp only [retain, List.length_take]
  exact Nat.min_le_left _ _

theorem new_witness_is_retained [BEq α] (capacity : Nat) (item : α) (bank : List α)
    (positive : 0 < capacity) : (retain capacity item bank).head? = some item := by
  cases capacity with
  | zero => omega
  | succ n => simp [retain]

def compatibleBank (rolloutVersion evaluationVersion : Nat) : Bool :=
  rolloutVersion == evaluationVersion

theorem changed_bank_ends_rollout (version : Nat) :
    compatibleBank version (version + 1) = false := by simp [compatibleBank]

def shaped (base oldPotential newPotential : Int) : Int :=
  base + newPotential - oldPotential

def shapingSum (initial : Int) : List Int -> Int
  | [] => 0
  | next :: rest => next - initial + shapingSum next rest

def finalPotential (initial : Int) : List Int -> Int
  | [] => initial
  | next :: rest => finalPotential next rest

theorem shaping_telescopes (potentials : List Int) (initial : Int) :
    shapingSum initial potentials = finalPotential initial potentials - initial := by
  induction potentials generalizing initial with
  | nil => simp [shapingSum, finalPotential]
  | cons next rest ih => simp only [shapingSum, finalPotential, ih]; omega

theorem terminal_shaping_constant (potentials : List Int) (initial : Int)
    (terminal : finalPotential initial potentials = 0) :
    shapingSum initial potentials = -initial := by
  rw [shaping_telescopes, terminal]
  omega

def maskedWeight (allowed : Bool) (weight : Nat) : Nat := if allowed then weight else 0

theorem invalid_action_zero_weight (weight : Nat) : maskedWeight false weight = 0 := rfl

theorem allowed_positive_weight (weight : Nat) (positive : 0 < weight) :
    0 < maskedWeight true weight := by simpa [maskedWeight] using positive

def baselineTerms (baseline : Int) (derivatives : List Int) : Int :=
  (derivatives.map (fun derivative => baseline * derivative)).sum

theorem baseline_sum (baseline : Int) (derivatives : List Int) :
    baselineTerms baseline derivatives = baseline * derivatives.sum := by
  induction derivatives with
  | nil => simp [baselineTerms]
  | cons d ds ih => simpa [baselineTerms, Int.mul_add] using congrArg (fun x => baseline * d + x) ih

theorem constant_baseline_cancels (baseline : Int) (derivatives : List Int)
    (normalized : derivatives.sum = 0) : baselineTerms baseline derivatives = 0 := by
  rw [baseline_sum, normalized]
  simp

structure PublicState where
  graph : List Nat
  menu : List Nat
  remaining : Nat
  deriving DecidableEq

structure EvaluationState where
  publicState : PublicState
  oracleSource : String

def policyInput (state : EvaluationState) : PublicState := state.publicState

theorem oracle_not_a_policy_input (state : PublicState) (oracle1 oracle2 : String) :
    policyInput ⟨state, oracle1⟩ = policyInput ⟨state, oracle2⟩ := rfl

def answerCode : Answer -> Nat
  | .sat => 0 | .unsat => 1 | .unknown => 2 | .error => 3

def verdictCode : Verdict -> Nat
  | .solved => 0 | .counterexample => 1 | .vacuous => 2 | .unresolved => 3

end RepairLearning

def main : IO Unit := do
  for compatible in [false, true] do
    for context in [RepairLearning.Answer.sat, .unsat, .unknown, .error] do
      for extra in [RepairLearning.Answer.sat, .unsat, .unknown, .error] do
        for missing in [RepairLearning.Answer.sat, .unsat, .unknown, .error] do
          IO.println s!"FEEDBACK,{if compatible then 1 else 0},{RepairLearning.answerCode context},{RepairLearning.answerCode extra},{RepairLearning.answerCode missing},{RepairLearning.verdictCode (RepairLearning.classify compatible context extra missing)}"
  for base in [-50, -10, 1000] do
    for oldPotential in [0, 250, 1000] do
      for newPotential in [0, 500, 1000] do
        IO.println s!"REWARD,{base},{oldPotential},{newPotential},{RepairLearning.shaped base oldPotential newPotential}"
