import GuardedJoinDuplicate

/- Boolean factoring transports retained JOIN construction premises. JOIN
   arguments, intermediate types, owned slots and brackets stay opaque and exact. -/
namespace GuardedJoinFactoring
open GuardedJoinDuplicate

theorem and_append (meaning : A → Prop) (xs ys : List A) :
    (∀ x ∈ xs ++ ys, meaning x) ↔ (∀ x ∈ xs, meaning x) ∧ (∀ x ∈ ys, meaning x) := by
  constructor
  · intro h
    exact ⟨fun x hx => h x (List.mem_append_left ys hx),
      fun x hx => h x (List.mem_append_right xs hx)⟩
  · rintro ⟨hx, hy⟩ x h
    exact (List.mem_append.mp h).elim (hx x) (hy x)

theorem factor_or (meaning : A → Prop) (common : List A) (branches : List (List A)) :
    (∃ branch ∈ branches, ∀ x ∈ common ++ branch, meaning x) ↔
      (∀ x ∈ common, meaning x) ∧ (∃ branch ∈ branches, ∀ x ∈ branch, meaning x) := by
  constructor
  · rintro ⟨b, hb, h⟩
    exact ⟨((and_append meaning common b).mp h).1,
      b, hb, ((and_append meaning common b).mp h).2⟩
  · rintro ⟨hc, b, hb, h⟩
    exact ⟨b, hb, (and_append meaning common b).mpr ⟨hc, h⟩⟩

theorem factor_and (meaning : A → Prop) (common : List A) (branches : List (List A)) :
    (∀ branch ∈ branches, ∃ x ∈ common ++ branch, meaning x) ↔
      (∃ x ∈ common, meaning x) ∨ (∀ branch ∈ branches, ∃ x ∈ branch, meaning x) := by
  classical
  by_cases hc : ∃ x ∈ common, meaning x
  · constructor
    · intro _; exact Or.inl hc
    · intro _ b _; obtain ⟨x, hx, hm⟩ := hc
      exact ⟨x, List.mem_append_left b hx, hm⟩
  · constructor
    · intro h; right; intro b hb
      obtain ⟨x, hx, hm⟩ := h b hb
      rcases List.mem_append.mp hx with hx | hx
      · exact False.elim (hc ⟨x, hx, hm⟩)
      · exact ⟨x, hx, hm⟩
    · rintro (h | h)
      · exact False.elim (hc h)
      · intro b hb; obtain ⟨x, hx, hm⟩ := h b hb
        exact ⟨x, List.mem_append_right common hx, hm⟩

theorem observed_factor (g p q : Prop) :
    ((g ∧ g ∧ p) ∨ (g ∧ q)) ↔ ((p ∨ q) ∧ g) := by
  constructor
  · rintro (⟨hg, _, hp⟩ | ⟨hg, hq⟩)
    · exact ⟨Or.inl hp, hg⟩
    · exact ⟨Or.inr hq, hg⟩
  · rintro ⟨hp | hq, hg⟩
    · exact Or.inl ⟨hg, hg, hp⟩
    · exact Or.inr ⟨hg, hq⟩

theorem scoped_factor (context : (Env → Prop) → Prop) (g p q : Env → Prop) :
    context (fun env => ((g env ∧ g env ∧ p env) ∨ (g env ∧ q env))) ↔
      context (fun env => (p env ∨ q env) ∧ g env) := by
  rw [funext fun env => propext (observed_factor (g env) (p env) (q env))]

-- Actual unary-middle JOIN is interpreted left-associated, never rotated.
def guard (carrier : A → Prop) (relation : A → A → Prop) : Prop :=
  ∃ z x, (∃ y, relation x y ∧ carrier y) ∧ relation x z

theorem typed_fixture (carrier : A → Prop) (relation : A → A → Prop) (x : A) :
    ((guard carrier relation ∧ guard carrier relation ∧ (∃ a, relation a x)) ∨
      (guard carrier relation ∧ (∃ b, relation x b))) ↔
    (((∃ a, relation a x) ∨ (∃ b, relation x b)) ∧ guard carrier relation) :=
  observed_factor _ _ _

theorem cross_owner_deletion_invalid :
    ¬ (((False ∧ False ∧ True) ∨ (False ∧ True)) ↔
      ((True ∧ True) ∨ (False ∧ True))) := by simp

#print axioms factor_or
#print axioms factor_and
#print axioms scoped_factor
#print axioms typed_fixture
end GuardedJoinFactoring
