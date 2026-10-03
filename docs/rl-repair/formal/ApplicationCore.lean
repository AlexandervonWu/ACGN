import Std

/- Application-level contracts above external tensor/solver primitives.
   No tensor numerical law or producer fidelity is assumed implicitly. -/
namespace RepairApplication

structure Step where
  budgetBefore : Nat
  budgetAfter : Nat
  menuSize : Nat
  action : Nat
  bankBefore : Nat
  bankAfter : Nat
  tokenBefore : String
  tokenAfter : String
  profileBefore : String
  profileAfter : String
  phiBefore : Int
  phiAfter : Int
  reward : Int
  base : Int
  terminal : Bool
  solved : Bool
  rejected : Bool
  contextSat : Bool
  extraUnsat : Bool
  missingUnsat : Bool
  deriving DecidableEq, Repr

def ValidStep (s : Step) : Prop :=
  0 < s.menuSize ∧ s.menuSize ≤ 512 ∧ s.action < s.menuSize ∧
  0 < s.budgetBefore ∧ s.budgetBefore ≤ 32 ∧ s.budgetAfter + 1 = s.budgetBefore ∧
  s.bankBefore ≤ s.bankAfter ∧ s.tokenBefore ≠ s.tokenAfter ∧
  s.profileBefore = s.profileAfter ∧
  0 ≤ s.phiBefore ∧ s.phiBefore ≤ 1000 ∧ 0 ≤ s.phiAfter ∧ s.phiAfter ≤ 1000 ∧
  s.reward = s.base + s.phiAfter - s.phiBefore ∧
  s.base = (if s.solved then 1000 else if s.rejected then -50 else -10) ∧
  (s.terminal = true → s.phiAfter = 0) ∧
  (s.terminal = false → s.bankAfter = s.bankBefore ∧ 0 < s.budgetAfter) ∧
  (s.solved = true → s.terminal = true ∧ s.contextSat = true ∧
    s.extraUnsat = true ∧ s.missingUnsat = true)

instance (s : Step) : Decidable (ValidStep s) := inferInstanceAs (Decidable (_ ∧ _))

def Linked (a b : Step) : Prop :=
  a.terminal = false ∧ a.budgetAfter = b.budgetBefore ∧ a.bankAfter = b.bankBefore ∧
  a.tokenAfter = b.tokenBefore ∧ a.profileAfter = b.profileBefore ∧ a.phiAfter = b.phiBefore

instance (a b : Step) : Decidable (Linked a b) := inferInstanceAs (Decidable (_ ∧ _))

def Chain : List Step -> Prop
  | [] => False
  | [s] => s.terminal = true
  | a :: b :: rest => Linked a b ∧ Chain (b :: rest)

def decideChain : (xs : List Step) -> Decidable (Chain xs)
  | [] => isFalse id
  | [a] => inferInstanceAs (Decidable (a.terminal = true))
  | a :: b :: tail =>
    @instDecidableAnd _ _ (inferInstanceAs (Decidable (Linked a b))) (decideChain (b :: tail))

instance (xs : List Step) : Decidable (Chain xs) := decideChain xs

def ValidRollout (xs : List Step) : Prop :=
  xs.length ≤ 32 ∧ (∀ s ∈ xs, ValidStep s) ∧ Chain xs

instance (xs : List Step) : Decidable (ValidRollout xs) :=
  inferInstanceAs (Decidable (_ ∧ _))

def certify (xs : List Step) : Option { ys : List Step // ValidRollout ys } :=
  if h : ValidRollout xs then some ⟨xs, h⟩ else none

theorem certified_input (xs : List Step) (w : {ys : List Step // ValidRollout ys})
    (accepted : certify xs = some w) : w.val = xs := by
  unfold certify at accepted
  split at accepted
  · cases accepted; rfl
  · contradiction

theorem certified_valid (w : {ys : List Step // ValidRollout ys}) : ValidRollout w.val := w.property

theorem empty_not_admitted : certify [] = none := by decide

theorem admitted_action_in_menu (xs : List Step) (valid : ValidRollout xs)
    (s : Step) (member : s ∈ xs) : s.action < s.menuSize := by
  have h := valid.2.1 s member
  exact h.2.2.1

theorem admitted_reward_equation (s : Step) (h : ValidStep s) :
    s.reward = s.base + s.phiAfter - s.phiBefore := h.2.2.2.2.2.2.2.2.2.2.2.2.2.1

theorem solved_has_evidence (s : Step) (h : ValidStep s) (solved : s.solved = true) :
    s.contextSat = true ∧ s.extraUnsat = true ∧ s.missingUnsat = true := by
  have evidence := h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2 solved
  exact evidence.2

theorem continuing_bank_is_fixed (s : Step) (h : ValidStep s) (active : s.terminal = false) :
    s.bankAfter = s.bankBefore := (h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1 active).1

theorem terminal_potential_zero (s : Step) (h : ValidStep s) (terminal : s.terminal = true) :
    s.phiAfter = 0 := h.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1 terminal

def returns : List Int -> List Int
  | [] => []
  | x :: xs => (x + xs.sum) :: returns xs

theorem returns_length (xs : List Int) : (returns xs).length = xs.length := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [returns, ih]

theorem return_head_is_total (x : Int) (xs : List Int) :
    (returns (x :: xs)).head? = some ((x :: xs).sum) := rfl

theorem returns_tail (x : Int) (xs : List Int) : (returns (x :: xs)).tail = returns xs := rfl

theorem return_at_suffix (xs : List Int) (n : Nat) :
    (returns xs).drop n = returns (xs.drop n) := by
  induction n generalizing xs with
  | zero => simp
  | succ n ih =>
    cases xs with
    | nil => simp [returns]
    | cons x xs => simpa [returns] using ih xs

def totalReward (xs : List Step) : Int := (xs.map Step.reward).sum
def totalBase (xs : List Step) : Int := (xs.map Step.base).sum

theorem rollout_shaping_constant (s : Step) (rest : List Step)
    (valid : ∀ t ∈ s :: rest, ValidStep t) (chain : Chain (s :: rest)) :
    totalReward (s :: rest) = totalBase (s :: rest) - s.phiBefore := by
  induction rest generalizing s with
  | nil =>
    have h := valid s (by simp)
    have reward := admitted_reward_equation s h
    have terminal := terminal_potential_zero s h chain
    simp only [totalReward, totalBase, List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
    omega
  | cons next rest ih =>
    have h := valid s (by simp)
    have tailValid : ∀ t ∈ next :: rest, ValidStep t := by
      intro t ht; exact valid t (by simp [ht])
    have tail := ih next tailValid chain.2
    have link := chain.1.2.2.2.2.2
    have reward := admitted_reward_equation s h
    change s.reward + totalReward (next :: rest) = s.base + totalBase (next :: rest) - s.phiBefore
    omega

structure Request where
  train : Bool
  uncensored : Bool
  policyBefore : Nat
  policyAfter : Nat
  expectedProfile : String
  steps : List Step
  deriving DecidableEq, Repr

def ValidRequest (r : Request) : Prop :=
  r.train = true ∧ r.uncensored = true ∧ r.policyBefore = r.policyAfter ∧
  r.expectedProfile ≠ "" ∧ (∀ s ∈ r.steps, s.profileBefore = r.expectedProfile) ∧
  ValidRollout r.steps

instance (r : Request) : Decidable (ValidRequest r) := inferInstanceAs (Decidable (_ ∧ _))

def admit (r : Request) : Option { q : Request // ValidRequest q } :=
  if h : ValidRequest r then some ⟨r, h⟩ else none

def targets (r : { q : Request // ValidRequest q }) : List Int :=
  returns (r.val.steps.map Step.reward)

theorem admitted_request_is_input (r : Request) (w : { q : Request // ValidRequest q })
    (accepted : admit r = some w) : w.val = r := by
  unfold admit at accepted
  split at accepted
  · cases accepted; rfl
  · contradiction

theorem admitted_request_is_training (r : { q : Request // ValidRequest q }) :
    r.val.train = true ∧ r.val.uncensored = true ∧ r.val.policyBefore = r.val.policyAfter :=
  ⟨r.property.1, r.property.2.1, r.property.2.2.1⟩

theorem admitted_request_has_valid_rollout (r : { q : Request // ValidRequest q }) :
    ValidRollout r.val.steps := r.property.2.2.2.2.2

theorem target_count (r : { q : Request // ValidRequest q }) :
    (targets r).length = r.val.steps.length := by simp [targets, returns_length]

theorem target_suffix_total (r : { q : Request // ValidRequest q }) (n : Nat)
    (s : Step) (rest : List Step) (suffix : r.val.steps.drop n = s :: rest) :
    ((targets r).drop n).head? = some ((s :: rest).map Step.reward).sum := by
  simp only [targets, return_at_suffix, ← List.map_drop, suffix]
  rfl

def trainingAllowed (train complete uncensored samePolicy sameBank : Bool) : Bool :=
  train && complete && uncensored && samePolicy && sameBank

theorem evaluation_never_updates (complete uncensored samePolicy sameBank : Bool) :
    trainingAllowed false complete uncensored samePolicy sameBank = false := by simp [trainingAllowed]

theorem censored_never_updates (train complete samePolicy sameBank : Bool) :
    trainingAllowed train complete false samePolicy sameBank = false := by simp [trainingAllowed]

theorem update_requires_all_guards (a b c d e : Bool)
    (h : trainingAllowed a b c d e = true) :
    a = true ∧ b = true ∧ c = true ∧ d = true ∧ e = true := by
  simpa [trainingAllowed, and_assoc] using h

def boundedFeature (value bound : Nat) : Nat := min value bound
theorem feature_bound (value bound : Nat) : boundedFeature value bound ≤ bound := Nat.min_le_right _ _
theorem bucket_bound (hash : Nat) : hash % 4096 < 4096 := Nat.mod_lt _ (by decide)

structure Edge (n : Nat) where
  source : Fin n
  target : Fin n
  position : Nat

def reverseEdge (e : Edge n) : Edge n := ⟨e.target, e.source, e.position⟩
def directedPairs (edges : List (Edge n)) : List (Edge n) :=
  edges.flatMap (fun e => [e, reverseEdge e])

theorem edge_reverse_preserves_position (e : Edge n) : (reverseEdge e).position = e.position := rfl
theorem edge_reverse_involution (e : Edge n) : reverseEdge (reverseEdge e) = e := rfl
theorem edge_occurrences_preserved (edges : List (Edge n)) :
    (directedPairs edges).length = 2 * edges.length := by
  induction edges with
  | nil => rfl
  | cons e es ih =>
    change ([e, reverseEdge e] ++ directedPairs es).length = 2 * (es.length + 1)
    simp only [List.length_append, List.length_cons, List.length_nil, ih]
    omega

inductive Shape where
  | scalar | vector (n : Nat)
  deriving DecidableEq

/- A loss expression's shape and gradient inputs are separate from the trusted
   backend's floating-point evaluation of its primitives. -/
inductive TensorExpr : Shape -> Type where
  | input (id : Nat) : TensorExpr shape
  | data (id : Nat) : TensorExpr shape
  | constant (numerator : Int) (denominator : Nat) (positive : 0 < denominator) : TensorExpr shape
  | add : TensorExpr shape -> TensorExpr shape -> TensorExpr shape
  | sub : TensorExpr shape -> TensorExpr shape -> TensorExpr shape
  | mul : TensorExpr shape -> TensorExpr shape -> TensorExpr shape
  | neg : TensorExpr shape -> TensorExpr shape
  | square : TensorExpr shape -> TensorExpr shape
  | detach : TensorExpr shape -> TensorExpr shape
  | mean (positive : 0 < n) : TensorExpr (.vector n) -> TensorExpr .scalar

def dependsOn (id : Nat) : TensorExpr shape -> Bool
  | .input other => id == other
  | .data _ => false
  | .constant _ _ _ => false
  | .add a b | .sub a b | .mul a b => dependsOn id a || dependsOn id b
  | .neg a | .square a => dependsOn id a
  | .detach _ => false
  | .mean _ a => dependsOn id a

def actor (positive : 0 < n) : TensorExpr .scalar :=
  .neg (.mean positive (.mul (.input 0) (.sub (.data 2) (.detach (.input 1)))))

def critic (positive : 0 < n) : TensorExpr .scalar :=
  .mean positive (.square (.sub (.input 1) (.data 2)))

theorem detached_baseline_has_no_actor_path (positive : 0 < n) :
    dependsOn 1 (actor positive) = false := rfl
theorem actor_keeps_logprob_path (positive : 0 < n) : dependsOn 0 (actor positive) = true := rfl
theorem critic_keeps_value_path (positive : 0 < n) : dependsOn 1 (critic positive) = true := rfl
theorem critic_has_no_logprob_path (positive : 0 < n) : dependsOn 0 (critic positive) = false := rfl
theorem detach_cuts_dependency (id : Nat) (e : TensorExpr shape) : dependsOn id (.detach e) = false := rfl

def selectedIndex (mask : List Bool) (index : Nat) : Bool := mask[index]?.getD false
theorem selected_index_exists (mask : List Bool) (index : Nat)
    (selected : selectedIndex mask index = true) : index < mask.length := by
  by_cases bound : index < mask.length
  · exact bound
  · have missing : mask[index]? = none := List.getElem?_eq_none (by omega)
    simp [selectedIndex, missing] at selected

structure Architecture where
  hidden : Nat
  layers : Nat
  schema : String
  contractHash : String
  deriving DecidableEq

def checkpointAccepted (expected actual : Architecture) : Bool := expected == actual
theorem checkpoint_matches_architecture (a b : Architecture)
    (h : checkpointAccepted a b = true) : a = b := by simpa [checkpointAccepted] using h

end RepairApplication
