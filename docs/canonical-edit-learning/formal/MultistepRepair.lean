import Lean
set_option autoImplicit false

namespace MultistepRepair

inductive Card where
  | no | one | lone | some
  deriving DecidableEq, Repr

def holds (c : Card) (n : Nat) : Bool :=
  match c with
  | .no => n == 0
  | .one => n == 1
  | .lone => n <= 1
  | .some => n > 0

-- Cardinality two represents every cardinality greater than one in this grammar.
def cap (n : Nat) : Nat := min n 2

theorem cardinality_abstraction (c : Card) (n : Nat) :
    holds c (cap n) = holds c n := by
  cases n with
  | zero => cases c <;> rfl
  | succ n =>
    cases n with
    | zero => cases c <;> rfl
    | succ n =>
      have h : min (n + 1 + 1) 2 = 2 := by omega
      cases c <;> simp [holds, cap, h]

abbrev Plan := Card × Card
abbrev World := Nat × Nat

def evaluate (p : Plan) (w : World) : Bool := holds p.1 w.1 && holds p.2 w.2

theorem world_abstraction (p : Plan) (w : World) :
    evaluate p (cap w.1, cap w.2) = evaluate p w := by
  simp [evaluate, cardinality_abstraction]

structure Evidence where
  world : World
  expected : Bool

def agrees (p : Plan) (e : Evidence) : Bool := evaluate p e.world == e.expected
def survivors (plans : List Plan) (e : Evidence) : List Plan := plans.filter (agrees · e)

theorem survivor_origin (p : Plan) (ps : List Plan) (e : Evidence)
    (h : p ∈ survivors ps e) : p ∈ ps := (List.mem_filter.mp h).1

theorem survivor_consistent (p : Plan) (ps : List Plan) (e : Evidence)
    (h : p ∈ survivors ps e) : evaluate p e.world = e.expected := by
  simpa [agrees] using (List.mem_filter.mp h).2

theorem authentic_target_retained (p : Plan) (ps : List Plan) (e : Evidence)
    (h : p ∈ ps) (authentic : evaluate p e.world = e.expected) :
    p ∈ survivors ps e := by
  simp [survivors, agrees, h, authentic]

theorem contradicted_candidate_removed (p : Plan) (ps : List Plan) (e : Evidence)
    (h : evaluate p e.world ≠ e.expected) : p ∉ survivors ps e := by
  simp [survivors, agrees, h]

theorem evidence_cannot_grow_pool (ps : List Plan) (e : Evidence) :
    (survivors ps e).length <= ps.length := List.length_filter_le _ _

def accumulate (ps : List Plan) (es : List Evidence) : List Plan :=
  es.foldl survivors ps

theorem causal_evidence (ps : List Plan) (past future : List Evidence) :
    accumulate ps ((past ++ future).take past.length) = accumulate ps past := by
  simp

theorem target_retained_over_history (p : Plan) (ps : List Plan) (es : List Evidence)
    (h : p ∈ ps) (authentic : ∀ e ∈ es, evaluate p e.world = e.expected) :
    p ∈ accumulate ps es := by
  induction es generalizing ps with
  | nil => exact h
  | cons e es ih =>
    apply ih
    · exact authentic_target_retained p ps e h (authentic e (by simp))
    · intro x hx
      exact authentic x (by simp [hx])

def available (ps tried : List Plan) : List Plan := ps.filter (fun p => !tried.contains p)

theorem selected_plan_not_repeated (p : Plan) (ps tried : List Plan)
    (h : p ∈ available ps tried) : p ∉ tried := by
  simpa using (List.mem_filter.mp h).2

def spend (fuel : Nat) : Nat := fuel - 1
theorem attempt_decreases_fuel (fuel : Nat) (h : fuel > 0) : spend fuel < fuel := by
  simp [spend]
  omega

def context {Event Memory : Type} (step : Memory → Event → Memory)
    (zero : Memory) (events : List Event) : Memory := events.foldl step zero

theorem context_extension {Event Memory : Type} (step : Memory → Event → Memory)
    (zero : Memory) (events : List Event) (e : Event) :
    context step zero (events ++ [e]) = step (context step zero events) e := by
  simp [context, List.foldl_append]

theorem public_only {Public Private Output : Type} (policy : Public → Output)
    (p : Public) (a b : Private) : policy (p, a).1 = policy (p, b).1 := rfl

-- Finite evidence agreement is deliberately not a success receipt.
theorem consistency_is_not_equivalence :
    agrees (.some, .some) ⟨(1, 1), true⟩ = true ∧
    evaluate (.some, .some) (2, 1) ≠ evaluate (.one, .some) (2, 1) := by decide

-- The same faulty predicate can require different plans after different evidence.
theorem feedback_branches :
    agrees (.one, .some) ⟨(2, 1), false⟩ = true ∧
    agrees (.some, .one) ⟨(2, 1), false⟩ = false ∧
    agrees (.one, .some) ⟨(1, 2), false⟩ = false ∧
    agrees (.some, .one) ⟨(1, 2), false⟩ = true := by decide

#print axioms cardinality_abstraction
#print axioms world_abstraction
#print axioms survivor_origin
#print axioms survivor_consistent
#print axioms authentic_target_retained
#print axioms contradicted_candidate_removed
#print axioms evidence_cannot_grow_pool
#print axioms causal_evidence
#print axioms target_retained_over_history
#print axioms selected_plan_not_repeated
#print axioms attempt_decreases_fuel
#print axioms context_extension
#print axioms public_only
#print axioms consistency_is_not_equivalence
#print axioms feedback_branches

end MultistepRepair
