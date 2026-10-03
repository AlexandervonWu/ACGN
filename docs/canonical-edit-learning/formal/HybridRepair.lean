import Lean

namespace HybridRepair

-- Parameterized payloads are not an unbounded dictionary of operation names.
inductive EditFamily where
  | temporalInsert | temporalDelete | temporalUpdate
  | bindingInsert | bindingDelete | bindingUpdate
  | matrixInsert | matrixDelete | matrixUpdate
  deriving DecidableEq, Repr

def operationDictionary : List EditFamily :=
  [.temporalInsert, .temporalDelete, .temporalUpdate,
   .bindingInsert, .bindingDelete, .bindingUpdate,
   .matrixInsert, .matrixDelete, .matrixUpdate]

theorem dictionary_complete (op : EditFamily) : op ∈ operationDictionary := by
  cases op <;> simp [operationDictionary]

theorem dictionary_size : operationDictionary.length = 9 := by decide

-- These codes describe one finite incidence record's child IDs, not a proof
-- that arbitrary Alloy operators admit a particular container law.
def bagCode (children : List Nat) (id : Nat) : Nat := children.count id
def setCode (children : List Nat) (id : Nat) : Bool := decide (id ∈ children)

theorem bag_concat_commutes (xs ys : List Nat) :
    bagCode (xs ++ ys) = bagCode (ys ++ xs) := by
  funext id
  simp [bagCode, List.count_append, Nat.add_comm]

theorem bag_retains_duplicates : bagCode [7, 7] 7 ≠ bagCode [7] 7 := by decide

theorem set_idempotent (xs : List Nat) : setCode (xs ++ xs) = setCode xs := by
  funext id
  simp [setCode]

theorem sequence_retains_ports : ([3, 7] : List Nat) ≠ [7, 3] := by decide

structure BinderOccurrence where
  ownerPhase : Nat
  ownerContext : List Nat
  ownerCoordinate : Nat
  usePhase : Nat
  useContext : List Nat
  deriving DecidableEq, Repr

theorem phase_occurrences_distinct (a b : BinderOccurrence)
    (h : a.usePhase ≠ b.usePhase) : a ≠ b := by
  intro equal
  exact h (congrArg BinderOccurrence.usePhase equal)

-- A real serializer must discharge this left-inverse premise for its schema.
theorem lossless_encoding_injective {S Token : Type}
    (encode : S → List Token) (decode : List Token → Option S)
    (roundtrip : ∀ s, decode (encode s) = some s)
    (a b : S) (h : encode a = encode b) : a = b := by
  have equal := congrArg decode h
  rw [roundtrip a, roundtrip b] at equal
  exact Option.some.inj equal

def choose {A : Type} (cost : A → Nat) (first : A) : List A → A
  | [] => first
  | a :: rest =>
    let tail := choose cost first rest
    if cost a ≤ cost tail then a else tail

theorem choose_member {A : Type} (cost : A → Nat) (first : A) (rest : List A) :
    choose cost first rest ∈ first :: rest := by
  induction rest with
  | nil => simp [choose]
  | cons a rest ih =>
    simp only [choose]
    split
    · simp
    · rcases List.mem_cons.mp ih with h | h
      · simp [h]
      · exact List.mem_cons_of_mem first (List.mem_cons_of_mem a h)

theorem choose_minimal {A : Type} (cost : A → Nat) (first : A) (rest : List A) :
    ∀ a ∈ first :: rest, cost (choose cost first rest) ≤ cost a := by
  induction rest with
  | nil =>
    intro a ha
    have h : a = first := by simpa using ha
    simp [h, choose]
  | cons b rest ih =>
    intro a ha
    rcases List.mem_cons.mp ha with hfirst | hrest
    · subst a
      simp only [choose]
      split
      · exact Nat.le_trans (by assumption) (ih first (by simp))
      · exact ih first (by simp)
    · rcases List.mem_cons.mp hrest with hb | htail
      · subst a
        simp only [choose]
        split
        · exact Nat.le_refl _
        · exact Nat.le_of_lt (Nat.lt_of_not_ge (by assumption))
      · have bound := ih a (List.mem_cons_of_mem first htail)
        simp only [choose]
        split
        · exact Nat.le_trans (by assumption) bound
        · exact bound

def Optimal {A : Type} (cost : A → Nat) (menu : List A) (a : A) : Prop :=
  a ∈ menu ∧ ∀ b ∈ menu, cost a ≤ cost b

theorem choose_optimal {A : Type} (cost : A → Nat) (first : A) (rest : List A) :
    Optimal cost (first :: rest) (choose cost first rest) :=
  ⟨choose_member cost first rest, choose_minimal cost first rest⟩

theorem optimal_rename {A B : Type} (cost : A → Nat) (cost' : B → Nat)
    (rename : A → B) (invariant : ∀ a, cost' (rename a) = cost a)
    (menu : List A) (a : A) (h : Optimal cost menu a) :
    Optimal cost' (menu.map rename) (rename a) := by
  constructor
  · exact List.mem_map.mpr ⟨a, h.1, rfl⟩
  · intro b hb
    rcases List.mem_map.mp hb with ⟨x, hx, rfl⟩
    rw [invariant, invariant]
    exact h.2 x hx

def gain (before after : Nat) : Int := (before : Int) - (after : Int)

theorem gains_telescope (a b c : Nat) : gain a b + gain b c = gain a c := by
  unfold gain
  omega

-- No triangle inequality or shortest-path property of CanonicalDistance is
-- assumed here. Its drop is a supervised label, not an optimality certificate.
theorem positive_gain_means_drop (a b : Nat) : 0 < gain a b ↔ b < a := by
  unfold gain
  omega

def checkedCommit {S A : Type} (legal : S → A → Bool)
    (realize : S → A → Option S) (accept : S → S → Bool) (s : S) (a : A) : Option S :=
  if legal s a then
    match realize s a with
    | none => none
    | some next => if accept s next then some next else none
  else none

theorem checked_commit_requirements {S A : Type} (legal : S → A → Bool)
    (realize : S → A → Option S) (accept : S → S → Bool) (s next : S) (a : A)
    (h : checkedCommit legal realize accept s a = some next) :
    legal s a = true ∧ realize s a = some next ∧ accept s next = true := by
  cases hl : legal s a with
  | false => simp [checkedCommit, hl] at h
  | true =>
    cases hr : realize s a with
    | none => simp [checkedCommit, hl, hr] at h
    | some proposed =>
      cases hc : accept s proposed with
      | false => simp [checkedCommit, hl, hr, hc] at h
      | true =>
        have equal : proposed = next := by simpa [checkedCommit, hl, hr, hc] using h
        subst next
        exact ⟨rfl, rfl, hc⟩

theorem rejected_action_no_commit {S A : Type} (legal : S → A → Bool)
    (realize : S → A → Option S) (accept : S → S → Bool) (s : S) (a : A)
    (h : legal s a = false) : checkedCommit legal realize accept s a = none := by
  simp [checkedCommit, h]

theorem attempt_decreases_fuel (fuel : Nat) (h : 0 < fuel) : fuel - 1 < fuel := by
  omega

def Equivalent {W : Type} (context candidate target : W → Prop) : Prop :=
  ∀ w, context w → (candidate w ↔ target w)

theorem counterexample_refutes {W : Type} (context candidate target : W → Prop)
    (w : W) (hc : context w) (hd : ¬ (candidate w ↔ target w)) :
    ¬ Equivalent context candidate target := by
  intro h
  exact hd (h w hc)

theorem solution_passes_witnesses {W : Type} (context candidate target : W → Prop)
    (bank : List W) (valid : ∀ w ∈ bank, context w)
    (h : Equivalent context candidate target) :
    ∀ w ∈ bank, candidate w ↔ target w := by
  intro w hw
  exact h w (valid w hw)

theorem two_direction_acceptance {W : Type} (context candidate target : W → Prop)
    (noExtra : ∀ w, ¬ (context w ∧ candidate w ∧ ¬ target w))
    (noMissing : ∀ w, ¬ (context w ∧ target w ∧ ¬ candidate w)) :
    Equivalent context candidate target := by
  intro w hc
  constructor
  · intro hp
    exact Classical.byContradiction (fun hq => noExtra w ⟨hc, hp, hq⟩)
  · intro hq
    exact Classical.byContradiction (fun hp => noMissing w ⟨hc, hq, hp⟩)

-- Dense reference GQA/SwiGLU backbone, no biases, tied input/output embedding.
-- This is accounting, not a claim that a particular pretrained model has it.
def backboneParameters (vocab width layers heads kvHeads headDim ff : Nat) : Nat :=
  vocab * width + layers *
    (2 * width * heads * headDim + 2 * width * kvHeads * headDim +
     3 * width * ff + 2 * width) + width

theorem reference_four_billion :
    backboneParameters 4096 3072 40 24 8 128 8192 = 4039363584 := by decide

def modelParameters (vocab width layers heads kvHeads headDim ff : Nat) : Nat :=
  backboneParameters vocab width layers heads kvHeads headDim ff +
  2 * width * width + 12 * width

theorem reference_model_four_billion :
    modelParameters 4096 3072 40 24 8 128 8192 = 4058274816 := by decide

-- Numeric budgets below exclude activations, workspace, metadata and adapters.
theorem reference_full_adam_storage_exceeds_16gib :
    16 * backboneParameters 4096 3072 40 24 8 128 8192 > 16 * 2^30 := by decide

-- Packing proves a storage codec, not differentiability of quantization.
def packNibbles (low high : Fin 16) : Nat := low.val + 16 * high.val

theorem packed_nibbles_fit_byte (low high : Fin 16) : packNibbles low high < 256 := by
  have hl := low.isLt
  have hh := high.isLt
  unfold packNibbles
  omega

theorem packed_nibbles_roundtrip (low high : Fin 16) :
    (packNibbles low high % 16, packNibbles low high / 16) = (low.val, high.val) := by
  have hl := low.isLt
  have hh := high.isLt
  unfold packNibbles
  apply Prod.ext <;> simp only <;> omega

def trainingStorage (packed masters gradients optimizer workspace : Nat) : Nat :=
  packed + masters + gradients + optimizer + workspace

theorem packed_storage_is_not_training_storage (p m g o w : Nat) :
    p + m + g ≤ trainingStorage p m g o w := by
  unfold trainingStorage
  omega

theorem cpu_master_and_gradient_cost :
    8 * modelParameters 4096 3072 48 24 8 128 8192 > 32 * 2^30 := by decide

theorem small_high_precision_candidate :
    modelParameters 4096 3072 16 24 8 128 8192 = 1642208256 := by decide

theorem large_low_precision_candidate :
    modelParameters 4096 3072 48 24 8 128 8192 = 4863630336 := by decide

-- Model scores, at any numerical precision, can only propose a checked action.
theorem arbitrary_policy_preserves_commit_gate {S A : Type}
    (policy : S → A) (legal : S → A → Bool) (realize : S → A → Option S)
    (accept : S → S → Bool) (s next : S)
    (h : checkedCommit legal realize accept s (policy s) = some next) :
    legal s (policy s) = true ∧ realize s (policy s) = some next ∧
      accept s next = true := checked_commit_requirements legal realize accept s next (policy s) h

end HybridRepair
