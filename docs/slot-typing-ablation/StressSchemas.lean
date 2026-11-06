/- Laws used to label synthetic pairs. These do not certify the generator,
   parser, finite Alloy bounds, or e-graph implementations. -/
namespace SlotStress
theorem alpha {A : Type} (p : A → Prop) : (∀ x, p x) ↔ (∀ renamed, p renamed) := Iff.rfl
theorem exchange {A B : Type} (p : A → B → Prop) :
    (∀ x, ∀ y, p x y) ↔ (∀ y, ∀ x, p x y) :=
  ⟨fun h y x => h x y, fun h x y => h y x⟩
theorem conjunction (a b c : Prop) :
    ((a ∧ b) ∧ (c ∧ a)) ↔ (c ∧ (b ∧ a)) := by
  constructor
  · intro h; exact ⟨h.2.1, h.1.2, h.1.1⟩
  · intro h; exact ⟨⟨h.2.2, h.2.1⟩, h.1, h.2.2⟩
theorem implication (a b : Prop) : (a → b) ↔ (¬a ∨ b) := by
  classical
  by_cases h : a <;> simp [h]
theorem iff_expansion (a b : Prop) : (a ↔ b) ↔ ((a → b) ∧ (b → a)) :=
  ⟨fun h => ⟨h.mp, h.mpr⟩, fun h => ⟨h.1, h.2⟩⟩
theorem ite_expansion (a b c : Prop) [Decidable a] :
    (if a then b else c) ↔ ((a ∧ b) ∨ (¬a ∧ c)) := by
  by_cases h : a <;> simp [h]
theorem beta {A : Type} (p : A → Prop) (x : A) :
    (let bound := x; p bound) ↔ p x := Iff.rfl
theorem union_commute {A : Type} (p q : A → Prop) (x : A) :
    (p x ∨ q x) ↔ (q x ∨ p x) := Or.comm
-- Every temporal constructor preserves equality of its denotation argument.
-- This is congruence, not a claim that binders can cross temporal phases.
theorem context {A B : Type} (f : A → B) (x y : A) (h : x = y) : f x = f y :=
  congrArg f h
theorem context2 {A B C : Type} (f : A → B → C) (x y : A) (z w : B)
    (h : x = y) (k : z = w) : f x z = f y w := by cases h; cases k; rfl
#print axioms alpha
#print axioms exchange
#print axioms conjunction
#print axioms implication
#print axioms iff_expansion
#print axioms ite_expansion
#print axioms beta
#print axioms union_commute
#print axioms context
#print axioms context2
end SlotStress
