import Std

/- Semantic witnesses for the audit. These are not a Java refinement proof. -/
namespace DistanceParityIncident

theorem mutual_exclusion (a b : Prop) :
    (¬ a ∨ ¬ b) ↔ ((a → ¬ b) ∧ (b → ¬ a)) := by
  constructor
  · intro h
    constructor
    · intro ha hb
      exact h.elim (fun hn => hn ha) (fun hn => hn hb)
    · intro hb ha
      exact h.elim (fun hn => hn ha) (fun hn => hn hb)
  · intro h
    classical
    by_cases ha : a
    · exact Or.inr (h.1 ha)
    · exact Or.inl ha

theorem fixed_predicate_presentation {A : Type} (meaning : A → Prop)
    (_sourceLabel _derivedLabel : String) (x : A) : meaning x ↔ meaning x := Iff.rfl

theorem independent_all_grouping {A : Type} (p : A → A → Prop) :
    (∀ x y, p x y) ↔ (∀ x, ∀ y, p x y) := Iff.rfl

theorem distinct_slot_map_order_irrelevant (a b va vb fallback : Nat) (different : a ≠ b) :
    (fun k => if k = a then va else if k = b then vb else fallback) =
    (fun k => if k = b then vb else if k = a then va else fallback) := by
  funext k
  by_cases ha : k = a
  · subst k
    simp [different]
  · by_cases hb : k = b <;> simp [ha, hb, Ne.symm different]

def typedHeadCost (identityLeft identityRight typeLeft typeRight : String) : Nat :=
  if identityLeft = identityRight ∧ typeLeft = typeRight then 0 else 1

theorem result_type_change_is_one_edit (identity leftType rightType : String)
    (different : leftType ≠ rightType) :
    typedHeadCost identity identity leftType rightType = 1 := by
  simp [typedHeadCost, different]

theorem identical_typed_head_is_free (identity resultType : String) :
    typedHeadCost identity identity resultType resultType = 0 := by
  simp [typedHeadCost]

theorem identity_and_type_change_is_one_edit (left right leftType rightType : String)
    (different : left ≠ right) :
    typedHeadCost left right leftType rightType = 1 := by
  simp [typedHeadCost, different]

-- r : A -> B, s : B -> C -> D, c : set C, d : set D.
-- Neither unary operand is treated as an unrestricted middle JOIN operand.
theorem partial_join {A B C D : Type}
    (r : A → B → Prop) (s : B → C → D → Prop)
    (c : C → Prop) (d : D → Prop) (a : A) :
    (∃ b, r a b ∧ ∃ x, (∃ y, s b x y ∧ d y) ∧ c x) ↔
    (∃ x, (∃ y, (∃ b, r a b ∧ s b x y) ∧ d y) ∧ c x) := by
  constructor
  · rintro ⟨b, hr, x, ⟨y, hs, hd⟩, hc⟩
    exact ⟨x, ⟨y, ⟨b, hr, hs⟩, hd⟩, hc⟩
  · rintro ⟨x, ⟨y, ⟨b, hr, hs⟩, hd⟩, hc⟩
    exact ⟨b, hr, x, ⟨y, hs, hd⟩, hc⟩

#print axioms mutual_exclusion
#print axioms fixed_predicate_presentation
#print axioms independent_all_grouping
#print axioms distinct_slot_map_order_irrelevant
#print axioms partial_join
#print axioms result_type_change_is_one_edit
#print axioms identical_typed_head_is_free
#print axioms identity_and_type_change_is_one_edit
end DistanceParityIncident
