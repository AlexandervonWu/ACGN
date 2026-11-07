import Lean
set_option autoImplicit false

namespace IndependentBindingBlocks

theorem all_exchange {A B : Type} (p : A → B → Prop) :
    (∀ a b, p a b) ↔ (∀ b a, p a b) := by
  constructor <;> intro h x y <;> exact h y x

theorem some_exchange {A B : Type} (p : A → B → Prop) :
    (∃ a b, p a b) ↔ (∃ b a, p a b) := by
  constructor
  · rintro ⟨a, b, h⟩; exact ⟨b, a, h⟩
  · rintro ⟨b, a, h⟩; exact ⟨a, b, h⟩

theorem all_combine {A B : Type} (p : A → B → Prop) :
    (∀ a b, p a b) ↔ (∀ pair : A × B, p pair.1 pair.2) := by
  constructor
  · intro h pair; exact h pair.1 pair.2
  · intro h a b; exact h (a, b)

theorem some_combine {A B : Type} (p : A → B → Prop) :
    (∃ a b, p a b) ↔ (∃ pair : A × B, p pair.1 pair.2) := by
  constructor
  · rintro ⟨a, b, h⟩; exact ⟨(a, b), h⟩
  · rintro ⟨pair, h⟩; exact ⟨pair.1, pair.2, h⟩

-- Domains remain attached to their variables; their carriers need not agree.
theorem guarded_all_exchange {A B : Type} (s : A → Prop) (t : B → Prop)
    (p : A → B → Prop) :
    (∀ a, s a → ∀ b, t b → p a b) ↔ (∀ b, t b → ∀ a, s a → p a b) := by
  constructor
  · intro h b hb a ha; exact h a ha b hb
  · intro h a ha b hb; exact h b hb a ha

theorem guarded_all_combine {A B : Type} (s : A → Prop) (t : B → Prop)
    (p : A → B → Prop) :
    (∀ a, s a → ∀ b, t b → p a b) ↔
    (∀ pair : A × B, s pair.1 ∧ t pair.2 → p pair.1 pair.2) := by
  constructor
  · intro h pair guards; exact h pair.1 guards.1 pair.2 guards.2
  · intro h a ha b hb; exact h (a, b) ⟨ha, hb⟩

theorem guarded_some_combine {A B : Type} (s : A → Prop) (t : B → Prop)
    (p : A → B → Prop) :
    (∃ a, s a ∧ ∃ b, t b ∧ p a b) ↔
    (∃ pair : A × B, s pair.1 ∧ t pair.2 ∧ p pair.1 pair.2) := by
  constructor
  · rintro ⟨a, ha, b, hb, h⟩; exact ⟨(a, b), ha, hb, h⟩
  · rintro ⟨pair, ha, hb, h⟩; exact ⟨pair.1, ha, pair.2, hb, h⟩

theorem guarded_some_exchange {A B : Type} (s : A → Prop) (t : B → Prop)
    (p : A → B → Prop) :
    (∃ a, s a ∧ ∃ b, t b ∧ p a b) ↔ (∃ b, t b ∧ ∃ a, s a ∧ p a b) := by
  constructor
  · rintro ⟨a, ha, b, hb, h⟩; exact ⟨b, hb, a, ha, h⟩
  · rintro ⟨b, hb, a, ha, h⟩; exact ⟨a, ha, b, hb, h⟩

-- State/phase is fixed on both sides, including the interpretation of domains.
theorem same_phase_all_combine {State A B : Type}
    (s : State → A → Prop) (t : State → B → Prop) (p : State → A → B → Prop)
    (phase : State) :
    (∀ a, s phase a → ∀ b, t phase b → p phase a b) ↔
    (∀ pair : A × B, s phase pair.1 ∧ t phase pair.2 → p phase pair.1 pair.2) :=
  guarded_all_combine (s phase) (t phase) (p phase)

theorem same_phase_some_combine {State A B : Type}
    (s : State → A → Prop) (t : State → B → Prop) (p : State → A → B → Prop)
    (phase : State) :
    (∃ a, s phase a ∧ ∃ b, t phase b ∧ p phase a b) ↔
    (∃ pair : A × B, s phase pair.1 ∧ t phase pair.2 ∧ p phase pair.1 pair.2) :=
  guarded_some_combine (s phase) (t phase) (p phase)

-- A retained disjointness or other source guard remains part of the matrix.
theorem guarded_all_combine_retains_constraint {A B : Type}
    (s : A → Prop) (t : B → Prop) (constraint p : A → B → Prop) :
    (∀ a, s a → ∀ b, t b → constraint a b → p a b) ↔
    (∀ pair : A × B, s pair.1 ∧ t pair.2 → constraint pair.1 pair.2 → p pair.1 pair.2) :=
  guarded_all_combine s t (fun a b => constraint a b → p a b)

theorem guarded_some_combine_retains_constraint {A B : Type}
    (s : A → Prop) (t : B → Prop) (constraint p : A → B → Prop) :
    (∃ a, s a ∧ ∃ b, t b ∧ constraint a b ∧ p a b) ↔
    (∃ pair : A × B, s pair.1 ∧ t pair.2 ∧ constraint pair.1 pair.2 ∧ p pair.1 pair.2) :=
  guarded_some_combine s t (fun a b => constraint a b ∧ p a b)

-- Concrete negative controls: same phase does not license these transformations.
theorem mixed_quantifier_exchange_is_invalid :
    ¬ ((∀ a : Bool, ∃ b : Bool, a = b) ↔ (∃ b : Bool, ∀ a : Bool, a = b)) := by
  intro equivalence
  obtain ⟨b, same⟩ := equivalence.mp (fun a => ⟨a, rfl⟩)
  have impossible : false = true := (same false).trans (same true).symm
  cases impossible

theorem dropping_disjointness_is_invalid :
    ¬ ((∀ a b : Bool, a ≠ b → a ≠ b) ↔ (∀ a b : Bool, a ≠ b)) := by
  intro equivalence
  have withoutGuard := equivalence.mp (fun _ _ h => h)
  exact withoutGuard false false rfl

-- Eventually over a two-position trace: moving all outside changes meaning.
theorem moving_all_across_eventually_is_invalid :
    ¬ ((∀ a : Bool, ∃ time : Bool, a = time) ↔ (∃ time : Bool, ∀ a : Bool, a = time)) :=
  mixed_quantifier_exchange_is_invalid

#print axioms all_exchange
#print axioms some_exchange
#print axioms all_combine
#print axioms some_combine
#print axioms guarded_all_exchange
#print axioms guarded_all_combine
#print axioms guarded_some_combine
#print axioms guarded_some_exchange
#print axioms same_phase_all_combine
#print axioms same_phase_some_combine
#print axioms guarded_all_combine_retains_constraint
#print axioms guarded_some_combine_retains_constraint
#print axioms mixed_quantifier_exchange_is_invalid
#print axioms dropping_disjointness_is_invalid
#print axioms moving_all_across_eventually_is_invalid

end IndependentBindingBlocks
