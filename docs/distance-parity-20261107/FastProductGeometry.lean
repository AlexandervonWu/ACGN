import Std

/- Ordered plain relational product only. Multiplicity-qualified arrows are
   outside this contract. Parser occurrence/type admission and Java refinement
   remain explicit implementation obligations, not consequences of this file. -/
namespace FastProductGeometry

def product (r s : List α → Prop) (tuple : List α) : Prop :=
  ∃ a b, r a ∧ s b ∧ a ++ b = tuple

theorem product_assoc (r s t : List α → Prop) :
    product (product r s) t = product r (product s t) := by
  funext tuple
  apply propext
  constructor
  · rintro ⟨ab, c, ⟨a, b, ha, hb, rfl⟩, hc, rfl⟩
    exact ⟨a, b ++ c, ha, ⟨b, c, hb, hc, rfl⟩, (List.append_assoc a b c).symm⟩
  · rintro ⟨a, bc, ha, ⟨b, c, hb, hc, rfl⟩, rfl⟩
    exact ⟨a ++ b, c, ⟨a, b, ha, hb, rfl⟩, hc, List.append_assoc a b c⟩

def unitRelation (tuple : List α) : Prop := tuple = []

theorem product_unit (r : List α → Prop) : product r unitRelation = r := by
  funext tuple
  apply propext
  simp [product, unitRelation]

theorem unit_product (r : List α → Prop) : product unitRelation r = r := by
  funext tuple
  apply propext
  simp [product, unitRelation]

def sequence (rs : List (List α → Prop)) : List α → Prop :=
  rs.foldr product unitRelation

theorem sequence_append (rs ss : List (List α → Prop)) :
    sequence (rs ++ ss) = product (sequence rs) (sequence ss) := by
  induction rs with
  | nil => simp [sequence, unit_product]
  | cons r rs ih =>
    change product r (sequence (rs ++ ss)) = product (product r (sequence rs)) (sequence ss)
    rw [ih, product_assoc]

inductive Tree (α : Type) where
  | leaf : (List α → Prop) → Tree α
  | arrow : Tree α → Tree α → Tree α

def eval : Tree α → (List α → Prop)
  | .leaf r => r
  | .arrow a b => product (eval a) (eval b)

def operands : Tree α → List (List α → Prop)
  | .leaf r => [r]
  | .arrow a b => operands a ++ operands b

theorem ordered_product_geometry (tree : Tree α) : eval tree = sequence (operands tree) := by
  induction tree with
  | leaf r => simp [eval, operands, sequence, product_unit]
  | arrow a b ha hb => simp [eval, operands, sequence_append, ha, hb]

theorem repeated_operands_retained (r : List α → Prop) : operands (.arrow (.leaf r) (.leaf r)) = [r,r] := rfl
theorem column_order (a b c : List α) : (a ++ b) ++ c = a ++ (b ++ c) := List.append_assoc a b c

#print axioms ordered_product_geometry
#print axioms repeated_operands_retained
#print axioms column_order
end FastProductGeometry
