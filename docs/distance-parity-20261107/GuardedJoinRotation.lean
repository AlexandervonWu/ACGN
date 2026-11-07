import Std

/- The middle relation retains TWO boundary positions. L/M/R represent arbitrary
   retained tuples (including empty tuples), not just scalar relation columns.
   This is a semantic rotation/context contract, not Java or parser refinement. -/
namespace GuardedJoinRotation

def rightAssociated (r : L → B → Prop) (s : B → M → C → Prop)
    (t : C → R → Prop) (l : L) (m : M) (v : R) : Prop :=
  ∃ b, r l b ∧ ∃ c, s b m c ∧ t c v

def leftAssociated (r : L → B → Prop) (s : B → M → C → Prop)
    (t : C → R → Prop) (l : L) (m : M) (v : R) : Prop :=
  ∃ c, (∃ b, r l b ∧ s b m c) ∧ t c v

theorem local_rotation (r : L → B → Prop) (s : B → M → C → Prop)
    (t : C → R → Prop) (l : L) (m : M) (v : R) :
    rightAssociated r s t l m v ↔ leftAssociated r s t l m v := by
  constructor
  · rintro ⟨b, hr, c, hs, ht⟩
    exact ⟨c, ⟨b, hr, hs⟩, ht⟩
  · rintro ⟨c, ⟨b, hr, hs⟩, ht⟩
    exact ⟨b, hr, c, hs, ht⟩

theorem occurrence_congruence (context : (X → Prop) → Y → Prop)
    (source target : X → Prop) (premise : ∀ x, source x ↔ target x) :
    ∀ y, context source y ↔ context target y := by
  have eq : source = target := funext fun x => propext (premise x)
  rw [eq]
  intro y
  exact Iff.rfl

theorem compose (source middle target : X → Prop)
    (first : ∀ x, source x ↔ middle x) (second : ∀ x, middle x ↔ target x) :
    ∀ x, source x ↔ target x := fun x => (first x).trans (second x)

-- A unary middle relation does not have the two distinct column positions used
-- by local_rotation. Even both well-typed bracketings can differ.
theorem unary_middle_counterexample :
    (∃ a : Bool, (∃ b : Bool, (a = true ∧ b = false) ∧ b = false) ∧
      (a = true ∧ false = false)) ∧
    ¬ (∃ b : Bool, (false = true ∧ b = false) ∧
      ∃ a : Bool, a = false ∧ (a = true ∧ b = false)) := by
  constructor
  · exact ⟨true, ⟨false, ⟨rfl, rfl⟩, rfl⟩, rfl, rfl⟩
  · simp

#print axioms local_rotation
#print axioms occurrence_congruence
#print axioms compose
#print axioms unary_middle_counterexample
end GuardedJoinRotation
