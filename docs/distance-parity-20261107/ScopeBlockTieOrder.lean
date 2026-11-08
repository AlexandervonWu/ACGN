import Std

/- Reordering already admitted scope-search branches, not granting a binder
   exchange. Java compatibility/owner/certificate checks remain obligations.
   The scalar objective first maximizes compatible matches, then minimizes
   native matrix cost; exact ties retain the first actual candidate. -/
namespace ScopeBlockTieOrder

structure Candidate where
  matchedCount : Nat
  cost : Nat
  deriving DecidableEq

def Optimal (chosen : Candidate) (candidates : List Candidate) : Prop :=
  chosen ∈ candidates ∧ ∀ other ∈ candidates,
    other.matchedCount ≤ chosen.matchedCount ∧
    (other.matchedCount = chosen.matchedCount → chosen.cost ≤ other.cost)

theorem same_admitted_candidates {α : Type} (x : α) (matched skipped : List α) :
    x ∈ skipped ++ matched ↔ x ∈ matched ++ skipped := by
  simp only [List.mem_append]
  exact or_comm

theorem preserves_scalar_optimality (chosen : Candidate)
    (matched skipped : List Candidate) :
    Optimal chosen (skipped ++ matched) ↔ Optimal chosen (matched ++ skipped) := by
  constructor
  · rintro ⟨member, optimal⟩
    exact ⟨(same_admitted_candidates chosen matched skipped).mp member,
      fun other h => optimal other ((same_admitted_candidates other matched skipped).mpr h)⟩
  · rintro ⟨member, optimal⟩
    exact ⟨(same_admitted_candidates chosen matched skipped).mpr member,
      fun other h => optimal other ((same_admitted_candidates other matched skipped).mp h)⟩

theorem preserves_actual_premises {α : Type} (Admitted : α → Prop)
    (matched skipped : List α) (checked : ∀ x ∈ skipped ++ matched, Admitted x) :
    ∀ x ∈ matched ++ skipped, Admitted x := by
  intro x hx
  exact checked x ((same_admitted_candidates x matched skipped).mpr hx)

def retainBest (best next : Candidate) : Candidate :=
  if next.matchedCount > best.matchedCount then next
  else if next.matchedCount = best.matchedCount ∧ next.cost < best.cost then next else best

theorem equal_score_keeps_first (first next : Candidate)
    (hmatches : next.matchedCount = first.matchedCount) (cost : next.cost = first.cost) :
    retainBest first next = first := by
  simp [retainBest, hmatches, cost]

theorem lower_cost_still_wins (first next : Candidate)
    (hmatches : next.matchedCount = first.matchedCount) (cost : next.cost < first.cost) :
    retainBest first next = next := by
  simp [retainBest, hmatches, cost]

theorem more_matches_still_wins (first next : Candidate)
    (hmatches : next.matchedCount > first.matchedCount) : retainBest first next = next := by
  simp [retainBest, hmatches]

#print axioms same_admitted_candidates
#print axioms preserves_scalar_optimality
#print axioms preserves_actual_premises
#print axioms equal_score_keeps_first
#print axioms lower_cost_still_wins
#print axioms more_matches_still_wins
end ScopeBlockTieOrder
