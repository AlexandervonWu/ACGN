import Lean

set_option autoImplicit false

namespace LocalRepair

-- An occurrence-tree model, not an implementation of Alloy typing or semantics.
inductive Tree where
  | leaf : Nat → Tree
  | node : Nat → List Tree → Tree
  deriving Repr

mutual
  def treeDecEq (a b : Tree) : Decidable (a = b) :=
    match a, b with
    | .leaf x, .leaf y =>
        if h : x = y then isTrue (by cases h; rfl)
        else isFalse (by intro equal; cases equal; exact h rfl)
    | .node x xs, .node y ys =>
        if h : x = y then
          match forestDecEq xs ys with
          | isTrue same => isTrue (by cases h; cases same; rfl)
          | isFalse different => isFalse (by intro equal; exact different (Tree.node.inj equal).2)
        else isFalse (by intro equal; exact h (Tree.node.inj equal).1)
    | .leaf _, .node _ _ => isFalse (by intro equal; cases equal)
    | .node _ _, .leaf _ => isFalse (by intro equal; cases equal)
  termination_by sizeOf a

  def forestDecEq (xs ys : List Tree) : Decidable (xs = ys) :=
    match xs, ys with
    | [], [] => isTrue rfl
    | x :: xs, y :: ys =>
        match treeDecEq x y with
        | isFalse different => isFalse (by intro equal; exact different (List.cons.inj equal).1)
        | isTrue same =>
            match forestDecEq xs ys with
            | isTrue rest => isTrue (by cases same; cases rest; rfl)
            | isFalse different => isFalse (by intro equal; exact different (List.cons.inj equal).2)
    | [], _ :: _ => isFalse (by intro equal; cases equal)
    | _ :: _, [] => isFalse (by intro equal; cases equal)
  termination_by sizeOf xs
end

instance : DecidableEq Tree := treeDecEq

def nodes : Tree → Nat
  | .leaf _ => 1
  | .node _ children => 1 + (children.map nodes).sum

inductive Context where
  | hole
  | child : Nat → List Tree → Context → List Tree → Context

def plug : Context → Tree → Tree
  | .hole, term => term
  | .child op before inside after, term =>
      .node op (before ++ [plug inside term] ++ after)

def frameSize : Context → Nat
  | .hole => 0
  | .child _ before inside after =>
      1 + (before.map nodes).sum + frameSize inside + (after.map nodes).sum

theorem plug_size (frame : Context) (term : Tree) :
    nodes (plug frame term) = frameSize frame + nodes term := by
  induction frame with
  | hole => simp [plug, frameSize]
  | child op before inside after ih =>
      simp [plug, nodes, frameSize, List.map_append, List.sum_append, ih]
      omega

theorem repair_size_delta (frame : Context) (old replacement : Tree) :
    nodes (plug frame replacement) + nodes old =
      nodes (plug frame old) + nodes replacement := by
  rw [plug_size, plug_size]
  omega

theorem unchanged_prefix (before after : List Tree) (inside : Context) (term : Tree) :
    (before ++ [plug inside term] ++ after).take before.length = before := by
  simp [List.append_assoc]

theorem unchanged_suffix (before after : List Tree) (inside : Context) (term : Tree) :
    (before ++ [plug inside term] ++ after).drop (before.length + 1) = after := by
  simp [List.append_assoc, List.drop_append]

theorem equal_occurrences_are_not_global_edits (op : Nat) (old replacement : Tree) :
    plug (.child op [] .hole [old]) replacement = .node op [replacement, old] := rfl

-- These stand for exact controller identities, not authority inferred from IDs.
structure Identity where
  task : Nat
  context : Nat
  profile : Nat
  theory : Nat
  parser : Nat
  deriving DecidableEq, Repr

structure AttemptKey where
  identity : Identity
  revision : Nat
  candidate : Tree
  deriving DecidableEq, Repr

inductive Failure where | stableLocal | transient deriving DecidableEq

def remember (failed : List AttemptKey) (key : AttemptKey) (reason : Failure) :=
  match reason with
  | .stableLocal => key :: failed
  | .transient => failed

def permitted (failed : List AttemptKey) (key : AttemptKey) : Bool :=
  decide (key ∉ failed)

def checkedAttempt {Result : Type} (failed : List AttemptKey) (key : AttemptKey)
    (checker : AttemptKey → Result) : Option Result :=
  if permitted failed key then some (checker key) else none

theorem stable_failure_blocks_identical_retry (failed : List AttemptKey) (key : AttemptKey) :
    permitted (remember failed key .stableLocal) key = false := by
  simp [permitted, remember]

theorem blocked_retry_does_not_request_check {R : Type} (failed : List AttemptKey)
    (key : AttemptKey) (checker : AttemptKey → R) :
    checkedAttempt (remember failed key .stableLocal) key checker = none := by
  simp [checkedAttempt, stable_failure_blocks_identical_retry]

theorem different_attempt_remains_permitted (failed : List AttemptKey) (old next : AttemptKey)
    (different : next ≠ old) (fresh : next ∉ failed) :
    permitted (remember failed old .stableLocal) next = true := by
  simp [permitted, remember, different, fresh]

theorem transient_failure_not_cached (failed : List AttemptKey) (key : AttemptKey) :
    remember failed key .transient = failed := rfl

inductive Result where | unsat | sat | unknown | timeout deriving DecidableEq

structure Judgment where
  sourceChecked : Bool
  feasible : Bool
  left : Result
  right : Result

def judgmentAccepted (r : Judgment) : Bool :=
  r.sourceChecked && r.feasible && decide (r.left = .unsat ∧ r.right = .unsat)

theorem acceptance_needs_all_checks (r : Judgment) (h : judgmentAccepted r = true) :
    r.sourceChecked = true ∧ r.feasible = true ∧ r.left = .unsat ∧ r.right = .unsat := by
  simpa [judgmentAccepted, Bool.and_eq_true, and_assoc] using h

theorem unknown_cannot_accept (r : Judgment) (h : r.left = .unknown) :
    judgmentAccepted r = false := by simp [judgmentAccepted, h]

theorem infeasible_cannot_accept (r : Judgment) (h : r.feasible = false) :
    judgmentAccepted r = false := by simp [judgmentAccepted, h]

structure Receipt (World : Type) where
  identity : Identity
  revision : Nat
  candidate : Tree
  judgment : Judgment
  witnesses : List (World × Bool)

structure State (World : Type) where
  initial : Tree
  committed : Tree
  draft : Option Tree
  identity : Identity
  revision : Nat
  decisions : Nat
  queries : Nat
  closed : Bool
  receipts : List (Receipt World)
  failed : List AttemptKey

-- localChecked represents an authenticated structural-check result. It does
-- not assert agreement with the private task target.
def commitAllowed {W : Type} (s : State W) (key : AttemptKey) (localChecked : Bool) : Bool :=
  !s.closed && decide (0 < s.decisions) && localChecked && permitted s.failed key &&
    decide (key.identity = s.identity ∧ key.revision = s.revision ∧
      s.draft = some key.candidate)

def commit {W : Type} (s : State W) (key : AttemptKey) (localChecked : Bool) : State W :=
  if commitAllowed s key localChecked then
    { s with committed := key.candidate, draft := none, revision := s.revision + 1,
             decisions := s.decisions - 1 }
  else s

theorem unchecked_commit_is_unchanged {W : Type} (s : State W) (key : AttemptKey) :
    commit s key false = s := by simp [commit, commitAllowed]

theorem admitted_commit_has_checked_origin {W : Type} (s : State W)
    (key : AttemptKey) (checked : Bool) (h : commitAllowed s key checked = true) :
    checked = true ∧ permitted s.failed key = true ∧ key.identity = s.identity ∧
      key.revision = s.revision ∧ s.draft = some key.candidate := by
  simp only [commitAllowed, Bool.and_eq_true, decide_eq_true_eq] at h
  exact ⟨h.1.1.2, h.1.2, h.2⟩

theorem admitted_commit_is_atomic {W : Type} (s : State W) (key : AttemptKey)
    (checked : Bool) (h : commitAllowed s key checked = true) :
    (commit s key checked).committed = key.candidate ∧
    (commit s key checked).draft = none ∧
    (commit s key checked).revision = s.revision + 1 ∧
    (commit s key checked).decisions + 1 = s.decisions := by
  have positive : 0 < s.decisions := by
    simp only [commitAllowed, Bool.and_eq_true, decide_eq_true_eq] at h
    exact h.1.1.1.2
  rw [commit, if_pos h]
  exact ⟨rfl, rfl, rfl, Nat.sub_add_cancel positive⟩

theorem commit_adds_no_acceptance_or_feedback {W : Type} (s : State W)
    (key : AttemptKey) (checked : Bool) :
    (commit s key checked).closed = s.closed ∧
    (commit s key checked).receipts = s.receipts ∧
    (commit s key checked).queries = s.queries := by
  simp [commit]; split <;> simp

theorem no_fuel_no_commit {W : Type} (s : State W) (key : AttemptKey) (checked : Bool)
    (h : s.decisions = 0) : commit s key checked = s := by
  simp [commit, commitAllowed, h]

def reject {W : Type} (s : State W) (key : AttemptKey) (reason : Failure) : State W :=
  if s.closed || s.decisions == 0 then s
  else { s with decisions := s.decisions - 1, failed := remember s.failed key reason }

def abort {W : Type} (s : State W) : State W :=
  if s.closed || s.decisions == 0 then s
  else { s with decisions := s.decisions - 1, draft := none }

theorem rejection_preserves_committed {W : Type} (s : State W) (k : AttemptKey) (f : Failure) :
    (reject s k f).committed = s.committed := by simp [reject]; split <;> rfl

theorem rejection_has_no_semantic_feedback {W : Type} (s : State W) (k : AttemptKey) (f : Failure) :
    (reject s k f).receipts = s.receipts ∧ (reject s k f).queries = s.queries := by
  simp [reject]; split <;> simp

theorem rejection_spends_decision {W : Type} (s : State W) (k : AttemptKey) (f : Failure)
    (isOpen : s.closed = false) (fuel : 0 < s.decisions) :
    (reject s k f).decisions + 1 = s.decisions := by
  simp [reject, isOpen, Nat.ne_of_gt fuel]
  omega

theorem abort_clears_draft {W : Type} (s : State W)
    (isOpen : s.closed = false) (fuel : 0 < s.decisions) : (abort s).draft = none := by
  simp [abort, isOpen, Nat.ne_of_gt fuel]

theorem abort_preserves_source_and_failure_cache {W : Type} (s : State W) :
    (abort s).committed = s.committed ∧ (abort s).failed = s.failed := by
  simp [abort]; split <;> simp

def bound {W : Type} (s : State W) (r : Receipt W) : Bool :=
  decide (r.identity = s.identity ∧ r.revision = s.revision ∧ r.candidate = s.committed)

def queryAllowed {W : Type} (s : State W) (r : Receipt W) : Bool :=
  !s.closed && s.draft.isNone && decide (0 < s.decisions ∧ 0 < s.queries) && bound s r

-- A supplied receipt must already have been authenticated by the runtime checker.
def query {W : Type} (s : State W) (r : Receipt W) (stop : Bool) : State W × Bool :=
  if queryAllowed s r then
    ({ s with decisions := s.decisions - 1, queries := s.queries - 1,
              receipts := s.receipts ++ [r], closed := judgmentAccepted r.judgment || stop },
     judgmentAccepted r.judgment)
  else (s, false)

theorem query_spends_both_budgets {W : Type} (s : State W) (r : Receipt W) (stop : Bool)
    (h : queryAllowed s r = true) :
    (query s r stop).1.decisions + 1 = s.decisions ∧
    (query s r stop).1.queries + 1 = s.queries := by
  have positive : 0 < s.decisions ∧ 0 < s.queries := by
    simp only [queryAllowed, Bool.and_eq_true, decide_eq_true_eq] at h
    exact h.1.2
  rw [query, if_pos h]
  exact ⟨Nat.sub_add_cancel positive.1, Nat.sub_add_cancel positive.2⟩

theorem query_appends_only_its_receipt {W : Type} (s : State W) (r : Receipt W) (stop : Bool)
    (h : queryAllowed s r = true) : (query s r stop).1.receipts = s.receipts ++ [r] := by
  simp [query, h]

theorem exhausted_queries_cannot_succeed {W : Type} (s : State W) (r : Receipt W) (stop : Bool)
    (h : s.queries = 0) : query s r stop = (s, false) := by
  simp [query, queryAllowed, h]

theorem mismatched_receipt_cannot_succeed {W : Type} (s : State W) (r : Receipt W) (stop : Bool)
    (h : bound s r = false) : query s r stop = (s, false) := by
  simp [query, queryAllowed, h]

theorem successful_query_is_source_bound {W : Type} (s : State W) (r : Receipt W) (stop : Bool)
    (h : (query s r stop).2 = true) :
    r.identity = s.identity ∧ r.revision = s.revision ∧ r.candidate = s.committed ∧
      judgmentAccepted r.judgment = true := by
  unfold query at h
  split at h
  next allowed =>
    have identities : r.identity = s.identity ∧ r.revision = s.revision ∧ r.candidate = s.committed := by
      simp only [queryAllowed, Bool.and_eq_true, bound, decide_eq_true_eq] at allowed
      exact allowed.2
    exact ⟨identities.1, identities.2.1, identities.2.2, h⟩
  next denied => simp at h

theorem stop_is_not_acceptance {W : Type} (s : State W) (r : Receipt W)
    (h : judgmentAccepted r.judgment = false) : (query s r true).2 = false := by
  simp [query, h]; split <;> rfl

-- Fuel accounting for any trace of charged primitive decisions. Connecting every
-- runtime decision to this relation is a separate implementation obligation.
inductive FuelTrace : Nat → Nat → Nat → Prop where
  | nil (fuel : Nat) : FuelTrace fuel 0 fuel
  | step {fuel count left : Nat} : FuelTrace fuel count left → FuelTrace (fuel + 1) (count + 1) left

theorem trace_conserves_fuel {start count left : Nat} (h : FuelTrace start count left) :
    left + count = start := by induction h <;> omega

theorem trace_is_bounded {start count left : Nat} (h : FuelTrace start count left) :
    count ≤ start := by have := trace_conserves_fuel h; omega

def compatible {W : Type} (candidate : W → Bool) (seen : List (W × Bool)) : Prop :=
  ∀ witness ∈ seen, candidate witness.1 = witness.2

theorem counterexample_excludes_candidate {W : Type} (candidate : W → Bool)
    (seen : List (W × Bool)) (world : W) (expected : Bool)
    (different : candidate world ≠ expected) :
    ¬ compatible candidate (seen ++ [(world, expected)]) := by
  intro consistent
  exact different (consistent (world, expected) (by simp))

theorem feedback_extension_cannot_restore_eliminated_candidate {W : Type}
    (candidate : W → Bool) (old more : List (W × Bool))
    (excluded : ¬ compatible candidate old) : ¬ compatible candidate (old ++ more) := by
  intro consistent
  apply excluded
  intro witness member
  exact consistent witness (List.mem_append_left more member)

theorem fixed_target_stays_compatible {W : Type} (target : W → Bool)
    (seen : List (W × Bool)) (correct : ∀ witness ∈ seen, target witness.1 = witness.2) :
    compatible target seen := correct

theorem two_directions_establish_scoped_agreement {W : Type}
    (scope : W → Prop) (candidate target : W → Bool)
    (forward : ∀ w, scope w → candidate w = true → target w = true)
    (backward : ∀ w, scope w → target w = true → candidate w = true) :
    ∀ w, scope w → candidate w = target w := by
  intro w inside
  cases hc : candidate w <;> cases ht : target w
  · rfl
  · have := backward w inside ht; simp [hc] at this
  · have := forward w inside hc; simp [ht] at this
  · rfl

structure Observation (W : Type) where
  initial : Tree
  committed : Tree
  draft : Option Tree
  returned : List (W × Bool)
  decisions : Nat
  queries : Nat

def observe {W : Type} (s : State W) : Observation W :=
  ⟨s.initial, s.committed, s.draft, (s.receipts.map Receipt.witnesses).flatten, s.decisions, s.queries⟩

structure Annotated (W Goal Label : Type) where
  state : State W
  privateGoal : Goal
  teacher : Label
  future : List (Receipt W)

def policyInput {W G L : Type} (sample : Annotated W G L) := observe sample.state

theorem private_goal_and_future_hidden {W G L : Type} (s : State W)
    (a b : G) (la lb : L) (fa fb : List (Receipt W)) :
    policyInput (Annotated.mk s a la fa) = policyInput (Annotated.mk s b lb fb) := rfl

theorem fixed_policy_noninterference {W G L A : Type} (policy : Observation W → A)
    (a b : Annotated W G L) (h : policyInput a = policyInput b) :
    policy (policyInput a) = policy (policyInput b) := congrArg policy h

inductive Split where | train | validation | test deriving DecidableEq
inductive LabelKind where | continuation | recovery deriving DecidableEq

structure Evidence where
  split : Split
  causalSnapshot : Bool
  rollinBound : Bool
  firstStepReplayed : Bool
  kind : LabelKind
  suffixAccepted : Bool
  rollbackChecked : Bool

def admit (e : Evidence) : Bool :=
  decide (e.split = .train) && e.causalSnapshot && e.rollinBound && e.firstStepReplayed &&
    match e.kind with
    | .continuation => e.suffixAccepted
    | .recovery => e.rollbackChecked

def semanticContinuation (e : Evidence) : Bool := admit e && decide (e.kind = .continuation)

theorem heldout_has_no_training_labels (e : Evidence) (h : e.split ≠ .train) :
    admit e = false := by cases e.kind <;> simp [admit, h]

theorem unreplayed_label_not_admitted (e : Evidence) (h : e.firstStepReplayed = false) :
    admit e = false := by cases e.kind <;> simp [admit, h]

theorem unbound_rollin_not_admitted (e : Evidence) (h : e.rollinBound = false) :
    admit e = false := by cases e.kind <;> simp [admit, h]

theorem recovery_label_is_not_semantic_success (e : Evidence) (h : e.kind = .recovery) :
    semanticContinuation e = false := by simp [semanticContinuation, h]

-- Alternatives are complete joint labels; independent field marginals are weaker.
def checkedAlternatives : List (Nat × Nat) := [(0, 1), (1, 0)]

theorem fieldwise_label_mixing_is_unsound :
    0 ∈ checkedAlternatives.map Prod.fst ∧ 0 ∈ checkedAlternatives.map Prod.snd ∧
      (0, 0) ∉ checkedAlternatives := by decide

theorem expert_search_bound {A : Type} (proposals : List A) (budget : Nat) :
    (proposals.take budget).length ≤ budget := by
  simp only [List.length_take]
  exact Nat.min_le_left _ _

#print axioms plug_size
#print axioms repair_size_delta
#print axioms unchanged_prefix
#print axioms unchanged_suffix
#print axioms equal_occurrences_are_not_global_edits
#print axioms stable_failure_blocks_identical_retry
#print axioms blocked_retry_does_not_request_check
#print axioms different_attempt_remains_permitted
#print axioms transient_failure_not_cached
#print axioms acceptance_needs_all_checks
#print axioms unknown_cannot_accept
#print axioms infeasible_cannot_accept
#print axioms unchecked_commit_is_unchanged
#print axioms admitted_commit_has_checked_origin
#print axioms admitted_commit_is_atomic
#print axioms commit_adds_no_acceptance_or_feedback
#print axioms no_fuel_no_commit
#print axioms rejection_preserves_committed
#print axioms rejection_has_no_semantic_feedback
#print axioms rejection_spends_decision
#print axioms abort_clears_draft
#print axioms abort_preserves_source_and_failure_cache
#print axioms query_spends_both_budgets
#print axioms query_appends_only_its_receipt
#print axioms exhausted_queries_cannot_succeed
#print axioms mismatched_receipt_cannot_succeed
#print axioms successful_query_is_source_bound
#print axioms stop_is_not_acceptance
#print axioms trace_conserves_fuel
#print axioms trace_is_bounded
#print axioms counterexample_excludes_candidate
#print axioms feedback_extension_cannot_restore_eliminated_candidate
#print axioms fixed_target_stays_compatible
#print axioms two_directions_establish_scoped_agreement
#print axioms private_goal_and_future_hidden
#print axioms fixed_policy_noninterference
#print axioms heldout_has_no_training_labels
#print axioms unreplayed_label_not_admitted
#print axioms unbound_rollin_not_admitted
#print axioms recovery_label_is_not_semantic_success
#print axioms fieldwise_label_mixing_is_unsound
#print axioms expert_search_bound

end LocalRepair
