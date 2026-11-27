/- Generated from the seven v3.1-to-v3.3 regression pairs by
   scripts/check_historical_cv_proofs.py. Each input file declares
   User.visible : set Work. Carriers may be empty and need not be finite. -/
namespace HistoricalCVPairs

structure Model (Atom : Type) where
  user : Atom → Prop
  work : Atom → Prop
  visible : Atom → Atom → Prop
  profile : Atom → Atom → Prop
  visibleRange : ∀ u w, user u → visible u w → work w

variable {Atom : Type} (m : Model Atom)

/-- cv_v1/correct/Ep8NWF5r49ZbbMFWN_inv1.als, predicate inv1. -/
def ref1484 : Prop :=
  ∀ w, m.work w → ∀ u, m.user u → m.visible u w → m.profile u w

/-- cv_v1/correct/HrLCgEZDqe5ysi6Q2_inv1.als, predicate inv1. -/
def ref1486 : Prop :=
  ∀ u, m.user u → ∀ w, m.work w → m.visible u w → m.profile u w

/-- cv_v1/correct/WFwwpScnibchj44ix_inv1.als, predicate inv1. -/
def ref1487 : Prop :=
  ∀ u, m.user u → ∀ w, m.work w → m.visible u w → m.profile u w

/-- cv_v1/correct/h4vE4HkXy8bbpXp3W_inv1.als, predicate inv1. -/
def ref1488 : Prop :=
  ∀ u, m.user u → ∀ v, m.visible u v → m.profile u v

/-- cv_v1/correct/ipSxbFnKqyoJSJdHu_inv1.als, predicate inv1. -/
def ref1489 : Prop :=
  ∀ u, m.user u → ∀ w, m.visible u w → m.profile u w

/-- cv_v2/correct/JcCGgwaARWfWBY4AY_inv1.als, predicate inv1. -/
def ref1524 : Prop :=
  ∀ u, m.user u → ∀ v, m.visible u v → m.profile u v

/-- cv_v2/correct/Segj9dR5dC3ZdZhok_inv1.als, predicate inv1. -/
def ref1526 : Prop :=
  ∀ w, m.work w → ∀ u, m.user u → m.visible u w → m.profile u w

private theorem workFirst :
    (∀ w, m.work w → ∀ u, m.user u → m.visible u w → m.profile u w) ↔
    (∀ u, m.user u → ∀ w, m.visible u w → m.profile u w) :=
  ⟨fun h u hu w hv => h w (m.visibleRange u w hu hv) u hu hv,
   fun h w _ u hu hv => h u hu w hv⟩

private theorem userFirst :
    (∀ u, m.user u → ∀ w, m.work w → m.visible u w → m.profile u w) ↔
    (∀ u, m.user u → ∀ w, m.visible u w → m.profile u w) :=
  ⟨fun h u hu w hv => h u hu w (m.visibleRange u w hu hv) hv,
   fun h u hu w _ hv => h u hu w hv⟩

theorem pair_1484_1488 : ref1484 m ↔ ref1488 m := by
  first | exact workFirst m | exact userFirst m | exact (workFirst m).symm

theorem pair_1484_1489 : ref1484 m ↔ ref1489 m := by
  first | exact workFirst m | exact userFirst m | exact (workFirst m).symm

theorem pair_1486_1488 : ref1486 m ↔ ref1488 m := by
  first | exact workFirst m | exact userFirst m | exact (workFirst m).symm

theorem pair_1486_1489 : ref1486 m ↔ ref1489 m := by
  first | exact workFirst m | exact userFirst m | exact (workFirst m).symm

theorem pair_1487_1488 : ref1487 m ↔ ref1488 m := by
  first | exact workFirst m | exact userFirst m | exact (workFirst m).symm

theorem pair_1487_1489 : ref1487 m ↔ ref1489 m := by
  first | exact workFirst m | exact userFirst m | exact (workFirst m).symm

theorem pair_1524_1526 : ref1524 m ↔ ref1526 m := by
  first | exact workFirst m | exact userFirst m | exact (workFirst m).symm

end HistoricalCVPairs
