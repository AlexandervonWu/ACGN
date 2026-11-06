import LocalRepair

set_option autoImplicit false
open LocalRepair

namespace LocalRepairChecks

def identity : Identity := ⟨1, 2, 3, 4, 5⟩
def base : State Nat :=
  { initial := .leaf 1, committed := .leaf 1, draft := none,
    identity := identity, revision := 0, decisions := 4, queries := 4,
    closed := false, receipts := [], failed := [] }
def key : AttemptKey := ⟨identity, 0, .leaf 2⟩
def good : Receipt Nat :=
  { identity := identity, revision := 0, candidate := .leaf 1,
    judgment := ⟨true, true, .unsat, .unsat⟩, witnesses := [] }
def recovery : Evidence :=
  ⟨.train, true, true, true, .recovery, false, true⟩

theorem stable_retry_is_blocked : permitted (remember [] key .stableLocal) key = false :=
  stable_failure_blocks_identical_retry [] key

theorem changed_candidate_is_allowed :
    permitted (remember [] key .stableLocal) { key with candidate := .leaf 3 } = true := by
  apply different_attempt_remains_permitted
  · simp [key, AttemptKey.mk.injEq]
  · simp

theorem transient_retry_is_allowed : permitted (remember [] key .transient) key = true := by decide

theorem checked_draft_commits :
    let next := commit { base with draft := some (.leaf 2) } key true
    next.committed = .leaf 2 ∧ next.draft = none ∧ next.revision = 1 ∧
      next.decisions = 3 ∧ next.queries = 4 ∧ next.receipts = [] := by
  simp [commit, commitAllowed, base, key, permitted]

theorem stale_commit_fails :
    let current := { base with revision := 1, draft := some (.leaf 2) }
    commit current key true = current := by
  simp [commit, commitAllowed, base, key, permitted]

theorem wrong_draft_commit_fails :
    let current := { base with draft := some (.leaf 3) }
    commit current key true = current := by
  simp [commit, commitAllowed, base, key, permitted]

theorem old_success_cannot_certify_new_revision :
    let next := commit { base with draft := some (.leaf 2) } key true
    (query next good true).2 = false := by
  simp [commit, commitAllowed, base, key, permitted, query, queryAllowed, bound, good]

theorem rejected_source_is_unchanged :
    (reject { base with draft := some (.leaf 2) } key .stableLocal).committed = .leaf 1 := by
  rw [rejection_preserves_committed]
  rfl

theorem abort_does_not_forget_failure :
    let rejected := reject { base with draft := some (.leaf 2) } key .stableLocal
    (abort rejected).draft = none ∧ permitted (abort rejected).failed key = false := by
  simp [reject, abort, base, permitted, remember]

theorem successful_receipt_is_inhabited : (query base good true).2 = true := by
  simp [query, queryAllowed, bound, base, good, judgmentAccepted]

theorem wrong_revision_fails : (query base { good with revision := 1 } true).2 = false := by decide

theorem wrong_candidate_fails :
    (query base { good with candidate := .leaf 9 } true).2 = false := by
  simp [query, queryAllowed, bound, base, good]

theorem wrong_context_fails :
    (query base { good with identity := { identity with context := 9 } } true).2 = false := by decide

theorem unknown_fails :
    (query base { good with judgment := ⟨true, true, .unknown, .unsat⟩ } true).2 = false := by
  apply stop_is_not_acceptance
  rfl

theorem empty_query_budget_fails : (query { base with queries := 0 } good true).2 = false := by decide

theorem active_draft_fails :
    (query { base with draft := some (.leaf 2) } good true).2 = false := by decide

theorem recovery_is_admitted_but_not_semantic_success :
    admit recovery = true ∧ semanticContinuation recovery = false := by decide

theorem both_heldout_splits_fail :
    admit { recovery with split := .validation } = false ∧
    admit { recovery with split := .test } = false := by decide

theorem unbound_snapshot_fails : admit { recovery with rollinBound := false } = false := by decide

theorem occurrence_edit_retains_equal_sibling :
    plug (.child 0 [] .hole [.leaf 1]) (.leaf 2) = .node 0 [.leaf 2, .leaf 1] := rfl

#print axioms stable_retry_is_blocked
#print axioms changed_candidate_is_allowed
#print axioms transient_retry_is_allowed
#print axioms checked_draft_commits
#print axioms stale_commit_fails
#print axioms wrong_draft_commit_fails
#print axioms old_success_cannot_certify_new_revision
#print axioms rejected_source_is_unchanged
#print axioms abort_does_not_forget_failure
#print axioms successful_receipt_is_inhabited
#print axioms wrong_revision_fails
#print axioms wrong_candidate_fails
#print axioms wrong_context_fails
#print axioms unknown_fails
#print axioms empty_query_budget_fails
#print axioms active_draft_fails
#print axioms recovery_is_admitted_but_not_semantic_success
#print axioms both_heldout_splits_fail
#print axioms unbound_snapshot_fails
#print axioms occurrence_edit_retains_equal_sibling

end LocalRepairChecks
