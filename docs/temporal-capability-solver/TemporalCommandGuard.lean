import Std

/- Command-only mode exposure for Alloy's total, infinite-trace semantics.
   This proves the logical guard, not correctness of the Java or SAT backend. -/
namespace CapabilityTemporalGuard

def after (next : S → S) (predicate : S → Prop) (state : S) : Prop :=
  predicate (next state)

def expose (next : S → S) (query : S → Prop) (state : S) : Prop :=
  query state ∧ after next (fun _ => True) state

theorem after_true (next : S → S) (state : S) :
    after next (fun _ => True) state := by
  trivial

theorem expose_iff (next : S → S) (query : S → Prop) (state : S) :
    expose next query state ↔ query state := by
  exact ⟨And.left, fun h => ⟨h, after_true next state⟩⟩

theorem preserves_satisfiability (next : S → S) (query : S → Prop) :
    (∃ state, expose next query state) ↔ ∃ state, query state := by
  constructor
  · rintro ⟨state, h⟩
    exact ⟨state, (expose_iff next query state).mp h⟩
  · rintro ⟨state, h⟩
    exact ⟨state, (expose_iff next query state).mpr h⟩

theorem preserves_unsatisfiability (next : S → S) (query : S → Prop) :
    (¬ ∃ state, expose next query state) ↔ ¬ ∃ state, query state := by
  exact not_congr (preserves_satisfiability next query)

theorem preserves_counterexample_query (next : S → S)
    (facts left right : S → Prop) (state : S) :
    expose next (fun s => facts s ∧ ¬ (left s ↔ right s)) state ↔
      (facts state ∧ ¬ (left state ↔ right state)) := by
  exact expose_iff next _ state

end CapabilityTemporalGuard
