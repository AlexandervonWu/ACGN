import Std

/- Add an attaining canonical paid path without replacing the existing alpha
   candidate family. Each candidate includes its own actions and source-linked
   scope evidence; this is not a minimum of independently reported scalars.
   Java admission/replay must discharge the explicit validity premises below. -/
namespace RetainedPaidCandidateUnion

structure Endpoint where
  source : Nat
  target : Nat
  typeAuthority : Nat
  deriving DecidableEq

structure Frame where
  owner : Nat
  parent : Option Nat
  declaration : Nat
  domain : Nat
  parserAuthority : Nat
  deriving DecidableEq

structure Candidate where
  endpoints : Endpoint
  frames : List Frame
  paidLinks : List (Nat × Nat)
  declarationActions : List Nat
  matrixActions : List Nat

def cost (c : Candidate) := c.declarationActions.sum + c.matrixActions.sum

def valid (e : Endpoint) (frames : List Frame) (replays : Candidate → Prop)
    (c : Candidate) : Prop := c.endpoints = e ∧ c.frames = frames ∧ replays c

def choose (existing canonical : Candidate) : Candidate :=
  if cost canonical ≤ cost existing then canonical else existing

theorem attaining_member (existing canonical : Candidate) :
    choose existing canonical = canonical ∨ choose existing canonical = existing := by
  unfold choose
  split <;> simp_all

theorem checked_endpoints_scopes_and_replay_retained
    (e : Endpoint) (frames : List Frame) (replays : Candidate → Prop)
    (existing canonical : Candidate)
    (he : valid e frames replays existing) (hc : valid e frames replays canonical) :
    valid e frames replays (choose existing canonical) := by
  rcases attaining_member existing canonical with h | h <;> simpa [h] using (by assumption : valid e frames replays _)

theorem preserves_existing_bound (existing canonical : Candidate) :
    cost (choose existing canonical) ≤ cost existing := by
  unfold choose
  split
  · assumption
  · exact Nat.le_refl _

theorem canonical_bound (existing canonical : Candidate) :
    cost (choose existing canonical) ≤ cost canonical := by
  unfold choose
  split
  · exact Nat.le_refl _
  · omega

theorem equal_cost_prefers_actual_canonical_path (existing canonical : Candidate)
    (h : cost canonical = cost existing) : choose existing canonical = canonical := by
  simp [choose, h]

theorem cheaper_exchange_not_discarded (existing canonical : Candidate)
    (h : cost existing < cost canonical) : choose existing canonical = existing := by
  simp [choose, Nat.not_le.mpr h]

theorem same_declaration_cost_allows_body_comparison (existing canonical : Candidate)
    (h : existing.declarationActions.sum = canonical.declarationActions.sum) :
    (cost canonical ≤ cost existing) ↔ (canonical.matrixActions.sum ≤ existing.matrixActions.sum) := by
  unfold cost
  omega

theorem selected_has_no_substituted_scope
    (e : Endpoint) (frames : List Frame) (replays : Candidate → Prop)
    (existing canonical : Candidate)
    (he : valid e frames replays existing) (hc : valid e frames replays canonical) :
    (choose existing canonical).frames = frames :=
  (checked_endpoints_scopes_and_replay_retained e frames replays existing canonical he hc).2.1

#print axioms checked_endpoints_scopes_and_replay_retained
#print axioms preserves_existing_bound
#print axioms canonical_bound
#print axioms equal_cost_prefers_actual_canonical_path
#print axioms cheaper_exchange_not_discarded
#print axioms same_declaration_cost_allows_body_comparison
#print axioms selected_has_no_substituted_scope
end RetainedPaidCandidateUnion
