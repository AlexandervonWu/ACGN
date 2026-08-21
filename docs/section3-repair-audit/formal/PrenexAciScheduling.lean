import Std

namespace PrenexAciScheduling

open Classical

/- An existential prefix over a carrier is the safe outer prefix for moving a
universal sibling through conjunction, including when the carrier is empty. -/
theorem some_before_all_and
    {α : Type} (p q : α → Prop) :
    ((∃ y, q y) ∧ (∀ x, p x)) ↔
      ∃ y, ∀ x, q y ∧ p x := by
  constructor
  · rintro ⟨⟨y, hy⟩, hp⟩
    exact ⟨y, fun x => ⟨hy, hp x⟩⟩
  · rintro ⟨y, h⟩
    exact ⟨⟨y, (h y).1⟩, fun x => (h x).2⟩

/- Dually, a universal prefix over the same carrier is the safe outer prefix
for moving an existential sibling through disjunction. -/
theorem all_before_some_or
    {α : Type} (p q : α → Prop) :
    ((∀ y, q y) ∨ (∃ x, p x)) ↔
      ∀ y, ∃ x, q y ∨ p x := by
  constructor
  · intro h y
    cases h with
    | inl hq => exact ⟨y, Or.inl (hq y)⟩
    | inr hp =>
        obtain ⟨x, hx⟩ := hp
        exact ⟨x, Or.inr hx⟩
  · intro h
    by_cases hp : ∃ x, p x
    · exact Or.inr hp
    · apply Or.inl
      intro y
      obtain ⟨x, hqx⟩ := h y
      cases hqx with
      | inl hq => exact hq
      | inr hpx => exact False.elim (hp ⟨x, hpx⟩)

def schedule (preferred : Nat → Bool) (indices : List Nat) : List Nat :=
  indices.filter (fun index => preferred index) ++
    indices.filter (fun index => !(preferred index))

theorem schedule_preserves_membership
    (preferred : Nat → Bool) (indices : List Nat) (index : Nat) :
    index ∈ schedule preferred indices ↔ index ∈ indices := by
  cases h : preferred index <;> simp [schedule, h]

theorem schedule_preserves_length
    (preferred : Nat → Bool) (indices : List Nat) :
    (schedule preferred indices).length = indices.length := by
  induction indices with
  | nil => simp [schedule]
  | cons index rest inductionHypothesis =>
      have filteredLength :
          (rest.filter (fun item => preferred item)).length +
              (rest.filter (fun item => !(preferred item))).length =
            rest.length := by
        simpa [schedule] using inductionHypothesis
      cases h : preferred index <;> simp [schedule, h]
      all_goals omega

/- The source-rule layer represents an `exactly none` declaration by one
admissible candidate: the empty relation itself. This models the binding
ledger, not inhabitance of the declared carrier. -/
def exactlyNoneBindings : List (List Nat) := [[]]

theorem exactly_none_retains_one_empty_binding :
    exactlyNoneBindings = [[]] := rfl

theorem exactly_none_binding_count :
    exactlyNoneBindings.length = 1 := rfl

/- A source spelling is presentation metadata. Certified binding identity is
the scope path plus the slot owned by that scope, so a nested declaration may
shadow an outer parameter without merging their types or occurrences. -/
structure ScopedBinding where
  scopePath : List Nat
  slot : Nat
  sourceSpelling : String
  deriving DecidableEq

def bindingIdentity (binding : ScopedBinding) : List Nat × Nat :=
  (binding.scopePath, binding.slot)

theorem different_scope_paths_separate_shadowed_bindings
    (outer inner : ScopedBinding)
    (differentScope : outer.scopePath ≠ inner.scopePath) :
    bindingIdentity outer ≠ bindingIdentity inner := by
  intro sameIdentity
  exact differentScope (Prod.mk.inj sameIdentity).1

theorem same_spelling_does_not_override_scope_identity
    (spelling : String) :
    bindingIdentity ⟨[0], 0, spelling⟩ ≠
      bindingIdentity ⟨[0, 1], 0, spelling⟩ := by
  apply different_scope_paths_separate_shadowed_bindings
  simp

end PrenexAciScheduling
