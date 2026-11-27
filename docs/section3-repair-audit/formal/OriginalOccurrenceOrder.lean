import SurvivorWitnessOrder

namespace OriginalOccurrenceOrder

/-- A bijection from the positions used to score a declaration to its original
    occurrences. Each endpoint has its own coordinates. -/
structure Coordinates (Metric Original : Type) where
  toOriginal : Metric → Original
  toMetric : Original → Metric
  recoverMetric : ∀ m, toMetric (toOriginal m) = m
  recoverOriginal : ∀ o, toOriginal (toMetric o) = o

def inOriginal (c : Coordinates M O) (move : M → M) (o : O) : O :=
  c.toOriginal (move (c.toMetric o))

def inMetric (c : Coordinates M O) (move : O → O) (m : M) : M :=
  c.toMetric (move (c.toOriginal m))

/-- Writing a metric choice in source coordinates and back recovers that exact
    choice, including every unaffected binder. -/
theorem recover_metric_choice (c : Coordinates M O) (p : M → M) :
    inMetric c (inOriginal c p) = p := by
  funext m
  simp only [inMetric, inOriginal, c.recoverMetric]

theorem recover_original_choice (c : Coordinates M O) (p : O → O) :
    inOriginal c (inMetric c p) = p := by
  funext o
  simp only [inMetric, inOriginal, c.recoverOriginal]

theorem original_position_fixed_iff (c : Coordinates M O) (p : M → M) (m : M) :
    inOriginal c p (c.toOriginal m) = c.toOriginal m ↔ p m = m := by
  simp only [inOriginal, c.recoverMetric]
  constructor
  · intro h
    have translated := congrArg c.toMetric h
    simpa only [c.recoverMetric] using translated
  · exact congrArg c.toOriginal

/-- Re-expressing all admitted permutations in their original coordinates keeps
    every minimizer and its charge, for any scoring function on the metric. -/
theorem minimum_corresponds (c : Coordinates M O) (cost : (M → M) → Nat)
    (p : M → M) (admitted : List (M → M)) :
    SurvivorWitnessOrder.IsMinimum cost p admitted ↔
    SurvivorWitnessOrder.IsMinimum (fun q => cost (inMetric c q)) (inOriginal c p)
      (admitted.map (inOriginal c)) := by
  constructor
  · rintro ⟨member, least⟩
    refine ⟨List.mem_map.mpr ⟨p, member, rfl⟩, ?_⟩
    intro y hy
    obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hy
    simp only [recover_metric_choice]
    exact least q hq
  · rintro ⟨member, least⟩
    obtain ⟨x, hx, eq⟩ := List.mem_map.mp member
    have xp := congrArg (inMetric c) eq
    simp only [recover_metric_choice] at xp
    refine ⟨xp ▸ hx, ?_⟩
    intro q hq
    have l := least (inOriginal c q) (List.mem_map.mpr ⟨q, hq, rfl⟩)
    simpa only [recover_metric_choice] using l

/-- Source binder order for the trash_rl/inv6 witness was e1:univ, e2:univ,
    f:File. The scorer put File first. Original links, before either of the
    competing target permutations, were e1→1, e2→2, f→0. Inspect the first
    paired survivor in each coordinate traversal. -/
theorem target_preference_reverses_at_cost_seven :
    let fast : SurvivorWitnessOrder.Orders := ⟨[0,1,2], [1,0,2]⟩
    let certified : SurvivorWitnessOrder.Orders := ⟨[0,1,2], [2,1,0]⟩
    let metricTraversal := [(2,0),(0,1),(1,2)]
    let originalTraversal := [(0,1),(1,2),(2,0)]
    (SurvivorWitnessOrder.key metricTraversal fast).survivors.head? = some (0,2) ∧
    (SurvivorWitnessOrder.key metricTraversal certified).survivors.head? = some (0,3) ∧
    (SurvivorWitnessOrder.key originalTraversal fast).survivors.head? = some (0,1) ∧
    (SurvivorWitnessOrder.key originalTraversal certified).survivors.head? = some (0,0) := by
  exact ⟨rfl, rfl, rfl, rfl⟩

#print axioms minimum_corresponds
#print axioms recover_metric_choice
#print axioms recover_original_choice
#print axioms original_position_fixed_iff
#print axioms target_preference_reverses_at_cost_seven
end OriginalOccurrenceOrder
