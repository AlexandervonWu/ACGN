import AdaptiveVisibleDiagonal
import AdaptiveRelationalImage

namespace AdaptiveEndpointBounds

def inside (r : BinaryRel α β) (a : Rel α) (b : Rel β) :=
  subset (AdaptiveVisibleDiagonal.pairsOf r) (relationProduct a b)

theorem inside_iff (r : BinaryRel α β) (a : Rel α) (b : Rel β) :
    inside r a b ↔ ∀ x y, r x y → a x ∧ b y :=
  ⟨fun h x y edge => h (x,y) edge, fun h ⟨x,y⟩ => h x y⟩

theorem projections (r : BinaryRel α β) (o a : Rel α) (t b : Rel β)
    (typed : ∀ x y, r x y → o x ∧ t y) :
    (subset (unaryLeftJoin o r) b ∧ subset (unaryRightJoin r t) a) ↔ inside r a b := by
  rw [inside_iff]
  exact ⟨fun ⟨l,h⟩ x y e => ⟨h x ⟨y,e,(typed x y e).2⟩,l y ⟨x,(typed x y e).1,e⟩⟩,
    fun h => ⟨fun y ⟨x,_,e⟩ => (h x y e).2,fun x ⟨y,e,_⟩ => (h x y e).1⟩⟩

theorem coupled_projection (r : BinaryRel α β) (a : Rel α) (t b : Rel β)
    (typed : ∀ x y, r x y → t y) :
    (subset (unaryLeftJoin a r) b ∧ subset (unaryRightJoin r t) a) ↔ inside r a b := by
  rw [inside_iff]
  constructor
  · rintro ⟨l,h⟩ x y e
    have ax := h x ⟨y,e,typed x y e⟩
    exact ⟨ax,l y ⟨x,ax,e⟩⟩
  · exact fun h => ⟨fun y ⟨x,_,e⟩ => (h x y e).2,fun x ⟨y,e,_⟩ => (h x y e).1⟩

theorem exclusions (r : BinaryRel α β) (o a : Rel α) (t b : Rel β)
    (typed : ∀ x y, r x y → o x ∧ t y) :
    (noOf (unaryLeftJoin (difference o a) r) ∧ noOf (unaryRightJoin r (difference t b))) ↔
      inside r a b := by
  rw [inside_iff]
  exact ⟨fun ⟨l,h⟩ x y e =>
    ⟨Classical.byContradiction fun n => l ⟨y,x,⟨(typed x y e).1,n⟩,e⟩,
     Classical.byContradiction fun n => h ⟨x,y,e,(typed x y e).2,n⟩⟩,
    fun h => ⟨fun ⟨y,x,⟨_,n⟩,e⟩ => n (h x y e).1,fun ⟨x,y,e,_,n⟩ => n (h x y e).2⟩⟩

theorem occupied (r : BinaryRel α β) (o a : Rel α) (t b : Rel β)
    (typed : ∀ x y, r x y → o x ∧ t y) :
    ((∀ x, o x → relNonempty (unaryLeftJoin (singletonRel x) r) → a x) ∧
     (∀ y, t y → relNonempty (unaryRightJoin r (singletonRel y)) → b y)) ↔ inside r a b := by
  rw [inside_iff]
  simp only [AdaptiveRelationalImage.singleton_fiber]
  exact ⟨fun ⟨l,h⟩ x y e => ⟨l x (typed x y e).1 ⟨y,e⟩,h y (typed x y e).2 ⟨x,y,e,rfl⟩⟩,
    fun h => ⟨fun x _ ⟨y,e⟩ => (h x y e).1,fun _ _ ⟨x,y,e,eq⟩ => (show y = _ from eq) ▸ (h x y e).2⟩⟩

-- A nonempty path has a last edge. Its source need not be the start of the path.
theorem positive_image (r : BinaryRel α α) (o : Rel α) (typed : ∀ x y, r x y → o x) :
    unaryLeftJoin o (transitiveClosure r) = unaryLeftJoin o r := by
  funext y
  apply propext
  constructor
  · rintro ⟨x,_,h⟩
    cases h with
    | single e => exact ⟨_,typed _ _ e,e⟩
    | tail _ e => exact ⟨_,typed _ _ e,e⟩
  · exact fun ⟨x,h,e⟩ => ⟨x,h,.single e⟩

theorem reverse_image (r : BinaryRel α β) (t : Rel β) :
    unaryLeftJoin t (converseBinary r) = unaryRightJoin r t := by
  funext x
  exact propext ⟨fun ⟨y,h,e⟩ => ⟨y,e,h⟩,fun ⟨y,e,h⟩ => ⟨y,h,e⟩⟩

theorem clipped_projection_is_not_enough :
    let r : BinaryRel Bool Unit := fun x _ => x = false
    let a : Rel Bool := fun x => x = true
    subset (unaryLeftJoin a r) noneRel ∧ ¬ inside r a noneRel := by
  intro r a
  exact ⟨fun _ ⟨_,e,h⟩ => Bool.noConfusion (e.symm.trans h),
    fun h => Bool.noConfusion ((inside_iff _ _ _).mp h false () rfl).1⟩

theorem positive_image_needs_full_source :
    let r : BinaryRel Nat Nat := fun x y => y = x+1
    unaryLeftJoin (singletonRel 0) (transitiveClosure r) 2 ∧
      ¬ unaryLeftJoin (singletonRel 0) r 2 := by
  exact ⟨⟨0,rfl,.tail (.single (right := 1) rfl) rfl⟩,
    fun ⟨x,h,e⟩ => by change x = 0 at h; subst x; contradiction⟩

theorem reflexive_image_can_add_an_isolated_atom :
    let r : BinaryRel Unit Unit := fun _ _ => False
    noOf (unaryLeftJoin univRel r) ∧
      relNonempty (unaryLeftJoin univRel (reflexiveTransitiveClosure r)) := by
  exact ⟨fun ⟨_,_,_,h⟩ => h,⟨(),(),trivial,Or.inl rfl⟩⟩

end AdaptiveEndpointBounds
