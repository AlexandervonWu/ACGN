import Std

/- Closed predicates have no binder/import environment. The SAME temporal
   operator is required. Java's source admission and key correspondence are
   tested separately; this file does not prove that implementation bridge. -/
namespace ClosedTemporalPhase

-- A synthetic phase root is an explicitly Boolean identity wrapper, not an
-- arbitrary missing type. Its child supplies the Boolean proposition.
def temporalRoot (body : Prop) : Prop := body
theorem boolean_root_identity (body : Prop) : temporalRoot body ↔ body := Iff.rfl

theorem same_operator (op : (W → Prop) → W → Prop) (p q : W → Prop)
    (sameBody : ∀ w, p w ↔ q w) : ∀ w, op p w ↔ op q w := by
  have eq : p = q := funext fun w => propext (sameBody w)
  rw [eq]
  intro w
  exact Iff.rfl

theorem and_drop_duplicate (p q rest : Prop) (same : p ↔ q) :
    (p ∧ q ∧ rest) ↔ (p ∧ rest) := by
  constructor
  · intro h; exact ⟨h.1, h.2.2⟩
  · intro h; exact ⟨h.1, same.mp h.1, h.2⟩

theorem or_drop_duplicate (p q rest : Prop) (same : p ↔ q) :
    (p ∨ q ∨ rest) ↔ (p ∨ rest) := by
  constructor
  · intro h
    rcases h with hp | hq | hr
    · exact Or.inl hp
    · exact Or.inl (same.mpr hq)
    · exact Or.inr hr
  · intro h
    exact h.elim Or.inl (fun hr => Or.inr (Or.inr hr))

def allRefs (env : Nat → W → Prop) (refs : List Nat) (w : W) : Prop :=
  ∀ i ∈ refs, env i w

theorem prune_only_unreferenced (env replacement : Nat → W → Prop)
    (refs : List Nat) (removed : Nat)
    (unused : removed ∉ refs)
    (sameElsewhere : ∀ i, i ≠ removed → env i = replacement i) :
    ∀ w, allRefs env refs w ↔ allRefs replacement refs w := by
  intro w
  have sameUsed : ∀ i ∈ refs, env i = replacement i := by
    intro i hi
    apply sameElsewhere i
    intro eq
    exact unused (eq ▸ hi)
  constructor
  · intro h i hi
    rw [← sameUsed i hi]
    exact h i hi
  · intro h i hi
    rw [sameUsed i hi]
    exact h i hi

-- Equal closed bodies alone cannot erase a distinct temporal operator.
theorem reindex_surviving_references (env metricEnv : Nat → W → Prop)
    (refs : List Nat) (reindex : Nat → Nat)
    (alignment : ∀ i ∈ refs, env i = metricEnv (reindex i)) :
    ∀ w, allRefs env refs w ↔ allRefs metricEnv (refs.map reindex) w := by
  intro w
  constructor
  · intro h j hj
    obtain ⟨i, hi, eq⟩ := List.mem_map.mp hj
    subst j
    rw [← alignment i hi]
    exact h i hi
  · intro h i hi
    rw [alignment i hi]
    exact h (reindex i) (List.mem_map.mpr ⟨i, hi, rfl⟩)

-- Equal closed bodies alone cannot erase a distinct temporal operator.
theorem different_operator_not_authorized (p : Unit → Prop) :
    ¬ ((fun _ : Unit → Prop => True) p ↔ (fun _ : Unit → Prop => False) p) := by
  simp

#print axioms same_operator
#print axioms boolean_root_identity
#print axioms and_drop_duplicate
#print axioms or_drop_duplicate
#print axioms prune_only_unreferenced
#print axioms reindex_surviving_references
#print axioms different_operator_not_authorized
end ClosedTemporalPhase
