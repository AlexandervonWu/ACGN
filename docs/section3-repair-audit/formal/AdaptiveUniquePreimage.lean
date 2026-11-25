import AdaptiveVisibleDiagonal
import AdaptiveRelationalImage
import AdaptivePhaseAlgebra

namespace AdaptiveUniquePreimage

def uniquePreimage (f : BinaryRel α β) := ∀ z, loneOf (fun x => f x z)
def disjointRows (f : BinaryRel α β) := ∀ x y, x ≠ y → noOf (intersection (f x) (f y))

theorem backward_fiber (f : BinaryRel α β) (z : β) :
    unaryLeftJoin (singletonRel z) (converseBinary f) =
      unaryRightJoin f (singletonRel z) := by
  rw [AdaptiveRelationalImage.singleton_fiber]
  ext x
  exact ⟨fun h => ⟨z,h,rfl⟩, fun ⟨_,h,e⟩ => e ▸ h⟩

theorem source_preimage (f : BinaryRel α β) :
    (∀ z, loneOf (unaryRightJoin f (singletonRel z))) ↔ uniquePreimage f := by
  simp only [← backward_fiber, AdaptiveRelationalImage.singleton_fiber]
  rfl

theorem shared_diagonal (f : BinaryRel α β) :
    subset (AdaptiveVisibleDiagonal.pairsOf (AdaptiveVisibleDiagonal.shared f))
      identityPairRelation ↔ uniquePreimage f :=
  ⟨fun h z x y a b => h (x,y) ⟨z,a,b⟩,
   fun h ⟨x,y⟩ ⟨z,a,b⟩ => h z x y a b⟩

theorem disjoint_iff (f : BinaryRel α β) : disjointRows f ↔ uniquePreimage f :=
  ⟨fun h z x y a b => Classical.byContradiction fun ne => h x y ne ⟨z,a,b⟩,
   fun h x y ne ⟨z,a,b⟩ => ne (h z x y a b)⟩

theorem row_eq_of_share (a b : Rel β) (ha : loneOf a) (hb : loneOf b)
    (z : β) (az : a z) (bz : b z) : a = b := by
  ext w
  exact ⟨fun aw => (ha _ _ az aw) ▸ bz,fun bw => (hb _ _ bz bw) ▸ az⟩

-- Either guard is reflexively inhabited for equal, nonempty rows.
theorem unequal_iff (f : BinaryRel α β) (rows : ∀ x, loneOf (f x))
    (either : Bool) :
    (∀ x y, x ≠ y → relNonempty (if either then union (f x) (f y) else f x) →
      f x ≠ f y) ↔ uniquePreimage f := by
  constructor
  · intro h z x y a b
    apply Classical.byContradiction
    intro ne
    have occ : relNonempty (if either then union (f x) (f y) else f x) := by
      cases either
      · exact ⟨z,a⟩
      · exact ⟨z,Or.inl a⟩
    exact h x y ne occ (row_eq_of_share _ _ (rows x) (rows y) z a b)
  · rintro h x y ne ⟨z,occ⟩ e
    have a : f x z := by
      rw [← e] at occ
      cases either
      · exact occ
      · exact occ.elim id id
    exact ne (h z x y a (Eq.mp (congrFun e z) a))

theorem always_fixed_scope (p : Nat → α → Prop) (t : Nat) :
    (∀ x, futureAlways (fun i => p i x) t) ↔ futureAlways (fun i => ∀ x, p i x) t :=
  ⟨fun h i hi x => h x i hi,fun h x i hi => h i hi x⟩

theorem always_fixed_distinct (p : Nat → α → α → Prop) (t : Nat) :
    (∀ x y, x ≠ y → futureAlways (fun i => p i x y) t) ↔
      futureAlways (fun i => ∀ x y, x ≠ y → p i x y) t :=
  ⟨fun h i hi x y ne => h x y ne i hi, fun h x y ne i hi => h i hi x y ne⟩

theorem extra_target_iff (f : Nat → BinaryRel α β) (extra : Type) (t : Nat) :
    futureAlways (fun i => ∀ z, extra → loneOf (fun x => f i x z)) t ↔
      (Nonempty extra → futureAlways (fun i => uniquePreimage (f i)) t) :=
  ⟨fun h ⟨e⟩ i hi z => h i hi z e,fun h i hi z e => h ⟨e⟩ i hi z⟩

theorem growing_target_counterexample :
    let target : Nat → Rel Unit := fun i _ => i > 0
    let f : Nat → BinaryRel Bool Unit := fun i _ _ => i > 0
    (∀ i x z, f i x z → target i z) ∧
    (∀ z, target 0 z → futureAlways (fun i => loneOf (fun x => f i x z)) 0) ∧
    ¬ futureAlways (fun i => ∀ z, target i z → loneOf (fun x => f i x z)) 0 := by
  intro target f
  refine ⟨fun _ _ _ h => h,fun _ h => False.elim (Nat.lt_irrefl _ h),?_⟩
  intro h
  cases h 1 (by decide) () (by decide) false true (by decide) (by decide)

theorem original_root_rejects_and_widening_differs :
    let f : Nat → BinaryRel Bool Unit := fun i x _ => x = false ∨ i = 1
    (∀ i x, loneOf (f i x)) ∧
    ¬ AdaptivePhaseAlgebra.oldArityChallenge (.always,1) (.always,1) (.always,1) (.always,1) ∧
    (futureAlways (fun i => subset (AdaptiveVisibleDiagonal.pairsOf (AdaptiveVisibleDiagonal.shared (f i)))
      identityPairRelation) 0 ↔ futureAlways (fun i => uniquePreimage (f i)) 0) ∧
    (futureAlways (fun i => ∀ z, Empty → loneOf (fun x => f i x z)) 0) ∧
    ¬ futureAlways (fun i => uniquePreimage (f i)) 0 := by
  intro f
  refine ⟨fun _ _ _ _ _ _ => rfl, AdaptivePhaseAlgebra.fixed_roots_cannot_change_arity _ _ _ _, ?_,
    (fun _ _ _ x => nomatch x), ?_⟩
  · exact ⟨fun h i hi => (shared_diagonal _).mp (h i hi),
      fun h i hi => (shared_diagonal _).mpr (h i hi)⟩
  · intro h
    have e := h 1 (by decide) () false true (Or.inr rfl) (Or.inr rfl)
    cases e

theorem multivalued_counterexample :
    let f : BinaryRel Bool Bool := fun x z => x = true ∨ z = false
    (∀ x y, x ≠ y → f x ≠ f y) ∧ ¬ uniquePreimage f := by
  intro f
  constructor
  · intro x y ne eq
    have obs := congrFun eq true
    cases x <;> cases y <;> simp_all [f]
  · intro h
    exact Bool.noConfusion (h false false true (Or.inr rfl) (Or.inr rfl))

end AdaptiveUniquePreimage
