import Lean

namespace FeedbackSession

-- This models the controller boundary, not the solver or source exporter.
structure State (View Feedback Private : Type) where
  view : View
  returned : List Feedback
  remaining : Nat
  privateContract : Private

def start {V F P : Type} (view : V) (budget : Nat) (contract : P) : State V F P :=
  ⟨view, [], budget, contract⟩

def publicView {V F P : Type} (s : State V F P) :=
  (s.view, s.returned, s.remaining)

-- Only a completed, explicit query contributes its response to the history.
-- The meaning and authenticity of that response remain verifier obligations.
def query {V F P : Type} (s : State V F P) (response : F) : State V F P :=
  match s.remaining with
  | 0 => s
  | n + 1 => { s with returned := s.returned ++ [response], remaining := n }

def reject {V F P : Type} (s : State V F P) : State V F P :=
  { s with remaining := s.remaining - 1 }

theorem initial_feedback_empty {V F P : Type} (v : V) (n : Nat) (p : P) :
    (start (F := F) v n p).returned = [] := rfl

theorem private_change_hidden {V F P : Type} (v : V) (n : Nat) (a b : P) :
    publicView (start (F := F) v n a) = publicView (start (F := F) v n b) := rfl

theorem query_consumes_budget {V F P : Type} (s : State V F P) (f : F)
    (h : 0 < s.remaining) : (query s f).remaining + 1 = s.remaining := by
  cases hr : s.remaining with
  | zero => omega
  | succ n => simp [query, hr]

theorem query_appends_exact_response {V F P : Type} (s : State V F P) (f : F)
    (h : 0 < s.remaining) : (query s f).returned = s.returned ++ [f] := by
  cases hr : s.remaining with
  | zero => omega
  | succ n => simp [query, hr]

theorem query_preserves_private_contract {V F P : Type} (s : State V F P) (f : F) :
    (query s f).privateContract = s.privateContract := by
  cases hr : s.remaining <;> simp [query, hr]

theorem exhausted_query_unchanged {V F P : Type} (s : State V F P) (f : F)
    (h : s.remaining = 0) : query s f = s := by simp [query, h]

theorem rejected_attempt_no_feedback {V F P : Type} (s : State V F P) :
    (reject s).returned = s.returned := rfl

theorem rejected_attempt_keeps_view {V F P : Type} (s : State V F P) :
    (reject s).view = s.view := rfl

theorem rejected_attempt_consumes_budget {V F P : Type} (s : State V F P)
    (h : 0 < s.remaining) : (reject s).remaining + 1 = s.remaining := by
  simp only [reject]
  omega

theorem response_prefix_preserved {V F P : Type} (s : State V F P) (f : F) :
    (query s f).returned.take s.returned.length = s.returned := by
  cases hr : s.remaining <;> simp [query, hr]

theorem query_same_public_response {V F P : Type} (a b : State V F P) (f : F)
    (h : publicView a = publicView b) : publicView (query a f) = publicView (query b f) := by
  rcases a with ⟨av, af, an, ap⟩
  rcases b with ⟨bv, bf, bn, bp⟩
  simp only [publicView, Prod.mk.injEq] at h
  rcases h with ⟨rfl, rfl, rfl⟩
  cases an <;> rfl

-- Alloy surface syntax realizes Boolean constants through cardinality of none.
theorem no_empty_is_true (Atom : Type) : ¬ (∃ _ : Atom, False) := by
  rintro ⟨_, h⟩
  exact h

theorem some_empty_is_false (Atom : Type) : (∃ _ : Atom, False) ↔ False := by
  constructor
  · rintro ⟨_, h⟩; exact h
  · intro h; exact h.elim

-- Extending a parser span to include paired delimiters must never discard its core.
-- This interval fact does not establish correspondence of Java tokenization to Alloy.
theorem enclosing_span_keeps_core (start finish pairedStart pairedFinish : Nat) :
    min start pairedStart ≤ start ∧ finish ≤ max finish pairedFinish := by
  exact ⟨Nat.min_le_left _ _, Nat.le_max_left _ _⟩

-- Local action masks restrict public choices, not semantic correctness.
def masked {Action Public Private : Type} (choices : List Action)
    (allowed : Public → Action → Bool) (view : Public) (_contract : Private) :=
  choices.filter (allowed view)

theorem masks_ignore_private {A V P : Type} (xs : List A) (p : V → A → Bool)
    (v : V) (left right : P) : masked xs p v left = masked xs p v right := rfl

theorem masked_choice_from_public {A V P : Type} (xs : List A) (p : V → A → Bool)
    (v : V) (contract : P) (a : A) (h : a ∈ masked xs p v contract) :
    a ∈ xs ∧ p v a = true := by
  simpa [masked] using h

-- A replay example captures its key before the action is run. The response can
-- change the next key, not the key on which the chosen action was supervised.
def replayKey {V F P : Type} (s : State V F P) (_future : List F) := publicView s

theorem replay_key_excludes_future {V F P : Type} (s : State V F P) (a b : List F) :
    replayKey s a = replayKey s b := rfl

theorem exhausted_replay_does_not_query {V F P : Type} (s : State V F P)
    (f : F) (h : s.remaining = 0) : publicView (query s f) = publicView s := by
  rw [exhausted_query_unchanged s f h]

def declarationScope {Slot : Type} (groups : List (List Slot)) (domain : Nat) :=
  (groups.take domain).flatten

theorem first_domain_has_no_draft_bindings {S : Type} (groups : List (List S)) :
    declarationScope groups 0 = [] := by simp [declarationScope]

theorem domain_scope_is_preceding_groups {S : Type} (groups : List (List S))
    (domain : Nat) (slot : S) : slot ∈ declarationScope groups domain ↔
    ∃ group ∈ groups.take domain, slot ∈ group := by
  simp [declarationScope, List.mem_flatten]

theorem returned_signature_member_retained {Atom : Type} (relations : List (List Atom))
    (members : List Atom) (atom : Atom) (sig : members ∈ relations) (member : atom ∈ members) :
    atom ∈ relations.flatten := by
  exact List.mem_flatten.mpr ⟨members, sig, member⟩

#print axioms initial_feedback_empty
#print axioms private_change_hidden
#print axioms query_consumes_budget
#print axioms query_appends_exact_response
#print axioms query_preserves_private_contract
#print axioms exhausted_query_unchanged
#print axioms rejected_attempt_no_feedback
#print axioms rejected_attempt_keeps_view
#print axioms rejected_attempt_consumes_budget
#print axioms response_prefix_preserved
#print axioms query_same_public_response
#print axioms no_empty_is_true
#print axioms some_empty_is_false
#print axioms enclosing_span_keeps_core
#print axioms masks_ignore_private
#print axioms masked_choice_from_public
#print axioms replay_key_excludes_future
#print axioms exhausted_replay_does_not_query
#print axioms first_domain_has_no_draft_bindings
#print axioms domain_scope_is_preceding_groups
#print axioms returned_signature_member_retained

end FeedbackSession
