import AdaptiveMixedRowCounting

namespace AdaptiveMixedReadLaws

theorem equal_filter (row keep : Rel α) :
    row = intersection row keep ↔ subset row keep := by
  constructor
  · intro h x hx
    exact ((congrFun h x).mp hx).2
  · intro h
    exact funext (fun x => propext ⟨fun hx => ⟨hx,h x hx⟩,And.left⟩)

theorem equal_removed (row remove : Rel α) :
    row = difference row remove ↔ noOf (intersection row remove) := by
  change (row = intersection row (fun x => ¬remove x)) ↔ _
  rw [equal_filter]
  exact ⟨fun h ⟨x,hx,r⟩ => h x hx r, fun h x hx r => h ⟨x,hx,r⟩⟩

theorem union_subset (p q r : Rel α) :
    subset (fun x => p x ∨ q x) r ↔ subset p r ∧ subset q r :=
  ⟨fun h => ⟨fun x hx => h x (Or.inl hx),fun x hx => h x (Or.inr hx)⟩,
   fun ⟨a,b⟩ x h => h.elim (a x) (b x)⟩

-- Inequality is not a positive query. Different colors suffice for the
-- lower query; dropping the inequality is only sound for the upper query.
theorem different_lower (color : α → Bool) (x y : α) :
    (color x = true ∧ color y = false ∨ color x = false ∧ color y = true) → x ≠ y := by
  rintro h rfl
  rcases h with ⟨a,b⟩ | ⟨a,b⟩ <;> simp_all

theorem no_middle (edge : BinaryRel α α)
    (disjoint : ∀ x y z, edge x y → edge y z → False) :
    transitiveClosure edge = edge := by
  funext x y
  apply propext
  constructor
  · intro path
    induction path with
    | single e => exact e
    | tail _ next ih => exact (disjoint _ _ _ ih next).elim
  · exact PositivePath.single

theorem typed_closure (edge : BinaryRel α α) (o t : Rel α)
    (typed : ∀ x y, edge x y → o x ∧ t y) (apart : ∀ x, t x → o x → False) :
    transitiveClosure edge = edge :=
  no_middle edge (fun x y z a b => apart y (typed x y a).2 (typed y z b).1)

end AdaptiveMixedReadLaws
