import Lean
set_option autoImplicit false

namespace MultistepScaling

inductive Card where
  | no | one | lone | some
  deriving DecidableEq, Repr

def holds (c : Card) (n : Nat) : Bool :=
  match c with
  | .no => n == 0
  | .one => n == 1
  | .lone => n <= 1
  | .some => n > 0

theorem clipped_cardinality (c : Card) (n : Nat) : holds c (min n 2) = holds c n := by
  cases n with
  | zero => cases c <;> rfl
  | succ n =>
    cases n with
    | zero => cases c <;> rfl
    | succ n =>
      have h : min (n + 1 + 1) 2 = 2 := by omega
      cases c <;> simp [holds, h]

def eval (disjunction : Bool) : List (Card × Nat) → Bool
  | [] => !disjunction
  | (c, n) :: xs => if disjunction then holds c n || eval disjunction xs
                   else holds c n && eval disjunction xs

theorem variadic_clipping (op : Bool) (xs : List (Card × Nat)) :
    eval op (xs.map (fun (c, n) => (c, min n 2))) = eval op xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [eval, clipped_cardinality, ih]

def validArity (plans worlds : Nat) : Bool := plans == worlds
theorem mismatched_arity_refused (p w : Nat) (h : p ≠ w) : validArity p w = false := by
  simp [validArity, h]

def eligible {P W : Type} [BEq P] (predict : P → W → Bool)
    (tried : List P) (evidence : List (W × Bool)) (p : P) : Bool :=
  !tried.contains p && evidence.all (fun (w, label) => predict p w == label)

theorem filter_retains_truth {P W : Type} [BEq P] [LawfulBEq P]
    (predict : P → W → Bool) (tried : List P) (es : List (W × Bool)) (p : P)
    (fresh : p ∉ tried) (authentic : ∀ e ∈ es, predict p e.1 = e.2) :
    eligible predict tried es p = true := by
  simp only [eligible, Bool.and_eq_true]
  constructor
  · simpa using fresh
  · apply List.all_eq_true.mpr
    intro e he
    simp [authentic e he]

theorem filter_no_repeat {P W : Type} [BEq P] [LawfulBEq P]
    (predict : P → W → Bool) (tried : List P) (es : List (W × Bool)) (p : P)
    (h : eligible predict tried es p = true) : p ∉ tried := by
  simp only [eligible, Bool.and_eq_true] at h
  simpa using h.1

theorem filter_every_witness {P W : Type} [BEq P]
    (predict : P → W → Bool) (tried : List P) (es : List (W × Bool)) (p : P)
    (h : eligible predict tried es p = true) : ∀ e ∈ es, predict p e.1 = e.2 := by
  simp only [eligible, Bool.and_eq_true] at h
  simpa [List.all_eq_true] using h.2

theorem more_evidence_never_readmits {P W : Type} [BEq P]
    (predict : P → W → Bool) (tried : List P) (past future : List (W × Bool)) (p : P)
    (h : eligible predict tried (past ++ future) p = true) : eligible predict tried past p = true := by
  simp only [eligible, List.all_append, Bool.and_eq_true] at h ⊢
  exact ⟨h.1, h.2.1⟩

theorem masked_choice_consistent {P W : Type} [BEq P]
    (predict : P → W → Bool) (tried candidates : List P) (es : List (W × Bool)) (p : P)
    (h : p ∈ candidates.filter (eligible predict tried es)) :
    ∀ e ∈ es, predict p e.1 = e.2 :=
  filter_every_witness predict tried es p (List.mem_filter.mp h).2

def prefixEvents {E : Type} (past future : List E) := (past ++ future).take past.length
theorem no_future_evidence {E : Type} (past future : List E) : prefixEvents past future = past := by
  simp [prefixEvents]

def trainAdmission (isTrain replayed : Bool) := isTrain && replayed
theorem heldout_refused (r : Bool) : trainAdmission false r = false := by simp [trainAdmission]
theorem unreplayed_refused (t : Bool) : trainAdmission t false = false := by simp [trainAdmission]

-- A deterministic group key is assigned one split, regardless of file spelling.
theorem group_split_consistent {Task Key Split : Type} (key : Task → Key) (split : Key → Split)
    (a b : Task) (same : key a = key b) : split (key a) = split (key b) := congrArg split same

def pathLength (arity : Nat) := 3 * arity + 1
theorem four_query_decision_bound (arity : Nat) (h : arity <= 4) :
    1 + 3 * (pathLength arity + 1) <= 43 := by simp [pathLength]; omega

theorem pool_bound (n : Nat) (h : n <= 4) : 4 ^ n <= 256 := by
  have cases : n = 0 ∨ n = 1 ∨ n = 2 ∨ n = 3 ∨ n = 4 := by omega
  rcases cases with h | h | h | h | h <;> subst n <;> decide

-- Neither a finite evidence filter nor a neural score is an equivalence checker.
theorem finite_evidence_not_acceptance :
    eval false [(.some, 1)] = eval false [(.one, 1)] ∧
    eval false [(.some, 2)] ≠ eval false [(.one, 2)] := by decide

#print axioms clipped_cardinality
#print axioms variadic_clipping
#print axioms mismatched_arity_refused
#print axioms filter_retains_truth
#print axioms filter_no_repeat
#print axioms filter_every_witness
#print axioms more_evidence_never_readmits
#print axioms masked_choice_consistent
#print axioms no_future_evidence
#print axioms heldout_refused
#print axioms unreplayed_refused
#print axioms group_split_consistent
#print axioms four_query_decision_bound
#print axioms pool_bound
#print axioms finite_evidence_not_acceptance

end MultistepScaling
