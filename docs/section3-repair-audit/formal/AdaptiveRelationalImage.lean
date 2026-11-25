import Phase5SourceRules

/- Unoriented relational-image laws. The bound on the image is fixed for a
   given outer binding; it need not be fixed across different outer bindings. -/
namespace AdaptiveRelationalImage

theorem image_subset_iff_all_fibers (parts : Rel α) (field : BinaryRel α β) (target : Rel β) :
    subset (unaryLeftJoin parts field) target ↔ qAll parts (fun p => subset (field p) target) := by
  constructor
  · intro h p hp w hw
    exact h w ⟨p, hp, hw⟩
  · rintro h w ⟨p, hp, hw⟩
    exact h p hp w hw

theorem typed_image_subset (owner parts : Rel α) (field : BinaryRel α β) (target : Rel β)
    (typed : ∀ p w, field p w → owner p) :
    subset (unaryLeftJoin (intersection owner parts) field) target ↔
      qAll parts (fun p => subset (field p) target) := by
  constructor
  · intro h p hp w hw
    exact h w ⟨p, ⟨typed p w hw, hp⟩, hw⟩
  · rintro h w ⟨p, ⟨_, hp⟩, hw⟩
    exact h p hp w hw

theorem owner_local_image (domain owner : Rel α) (parts : BinaryRel α α)
    (field : BinaryRel α β) (target : α → Rel β) (typed : ∀ p w, field p w → owner p) :
    qAll domain (fun c => subset (unaryLeftJoin (intersection owner (parts c)) field) (target c)) ↔
      qAll domain (fun c => qAll (parts c) (fun p => subset (field p) (target c))) :=
  ⟨fun h c hc => (typed_image_subset _ _ _ _ typed).mp (h c hc),
   fun h c hc => (typed_image_subset _ _ _ _ typed).mpr (h c hc)⟩

-- Omitting an untyped part really can hide a destination outside the target.
theorem wrong_field_owner :
    subset (unaryLeftJoin (intersection (noneRel : Rel Unit) univRel)
      (fun _ _ : Unit => True)) noneRel ∧
    ¬ qAll (univRel : Rel Unit) (fun _ => subset (univRel : Rel Unit) noneRel) :=
  ⟨fun _ ⟨_, ⟨h, _⟩, _⟩ => h, fun h => h () trivial () trivial⟩

-- An image inclusion over an empty parts set is true; there need be no witness.
theorem cannot_use_existential :
    subset (unaryLeftJoin (noneRel : Rel Unit) (fun _ _ : Unit => True)) noneRel ∧
    ¬ qSome (noneRel : Rel Unit) (fun _ => subset (univRel : Rel Unit) noneRel) :=
  ⟨fun _ ⟨_, h, _⟩ => h, fun ⟨_, h, _⟩ => h⟩

-- Rendering the declared owner as an explicit conjunct gives an arbitrary
-- raw field a correctly typed interpretation, and preserves every legal field.
theorem declared_field_view (owner : Rel α) (field : BinaryRel α β)
    (typed : ∀ p w, field p w → owner p) :
    (fun p w => field p w ∧ owner p) = field := by
  funext p w
  exact propext ⟨And.left, fun h => ⟨h, typed p w h⟩⟩

theorem cannot_rebind_target :
    let domain : Rel Bool := fun c => c = false
    let parts : BinaryRel Bool Bool := fun _ p => p = true
    let field : BinaryRel Bool Unit := fun _ _ => True
    let target : BinaryRel Bool Unit := fun c _ => c = false
    qAll domain (fun c => subset (unaryLeftJoin (parts c) field) (target c)) ∧
      ¬ qAll domain (fun c => qAll (parts c) (fun p => subset (field p) (target p))) :=
  ⟨fun _ hc _ _ => hc, fun h => Bool.noConfusion (h false rfl true rfl () trivial)⟩

theorem image_at_same_instant (parts : Nat → Rel α) (field : Nat → BinaryRel α β)
    (target : Nat → Rel β) (t : Nat) :
    subset (unaryLeftJoin (parts t) (field t)) (target t) ↔
      qAll (parts t) (fun p => subset (field t p) (target t)) :=
  image_subset_iff_all_fibers _ _ _

theorem different_instant_can_change_image :
    let parts : Rel Unit := univRel
    let field : Nat → BinaryRel Unit Unit := fun t _ _ => t=0
    subset (unaryLeftJoin parts (field 1)) noneRel ∧
      ¬ qAll parts (fun p => subset (field 0 p) noneRel) :=
  ⟨fun _ ⟨_, _, h⟩ => Nat.noConfusion h, fun h => h () trivial () rfl⟩

theorem predecessor_via_reversed_paths (selected : Rel α) (edge : BinaryRel α α) :
    unaryLeftJoin selected (transitiveClosure (converseBinary edge)) =
      unaryRightJoin (transitiveClosure edge) selected := by
  rw [← converse_transitive_closure]
  funext a
  exact propext ⟨fun ⟨w, hs, path⟩ => ⟨w, path, hs⟩, fun ⟨w, path, hs⟩ => ⟨w, hs, path⟩⟩

-- The independently generated theorem can use the standard library's
-- nonempty paths without importing the project's formalization.
theorem transgen_iff_positive_path (edge : BinaryRel α α) (a b : α) :
    Relation.TransGen edge a b ↔ PositivePath edge a b := by
  constructor <;> intro path <;> induction path with
  | single e => exact .single e
  | tail _ e ih => exact .tail ih e

theorem positive_self_path_not_free :
    ¬ Relation.TransGen (fun _ _ : Unit => False) () () := by
  intro h
  cases h with
  | single e => exact e
  | tail _ e => exact e

-- A fiber must fit into the observation at one instant, not one instant per element.
def eventualFibers (owner : Rel α) (field : BinaryRel α β) (seen : Nat → Rel β) (t : Nat) :=
  qAll owner (fun x => futureEventually (fun j => subset (field x) (seen j)) t)

def eventualAtoms (target : Rel β) (seen : Nat → Rel β) (t : Nat) :=
  qAll target (fun y => futureEventually (fun j => seen j y) t)

theorem eventual_covered_fibers (owner : Rel α) (target : Rel β) (field : BinaryRel α β)
    (seen : Nat → Rel β) (t : Nat)
    (covers : ∀ y, target y → ∃ x, owner x ∧ field x y)
    (typed : ∀ x y, owner x → field x y → target y)
    (lone : ∀ x y z, owner x → field x y → field x z → y = z) :
    eventualFibers owner field seen t ↔ eventualAtoms target seen t := by
  constructor
  · intro h y hy
    obtain ⟨x, hx, hxy⟩ := covers y hy
    obtain ⟨j, hj, allSeen⟩ := h x hx
    exact ⟨j, hj, allSeen y hxy⟩
  · intro h x hx
    by_cases inhabited : ∃ y, field x y
    · obtain ⟨y, hy⟩ := inhabited
      obtain ⟨j, hj, seenY⟩ := h y (typed x y hx hy)
      exact ⟨j, hj, fun z hz => (lone x y z hx hy hz) ▸ seenY⟩
    · exact ⟨t, Nat.le_refl _, fun z hz => False.elim (inhabited ⟨z, hz⟩)⟩

-- The Layout conjunct "all s : Signal | one signal.s" gives the required
-- preimage by relational join on the singleton s. Its uniqueness is not needed.
theorem unique_preimage_covers (owner : Rel α) (target : Rel β) (field : BinaryRel α β)
    (typed : ∀ x y, field x y → owner x)
    (layout : qAll target (fun y => qOne (unaryRightJoin field (fun z => z = y)) (fun _ => True))) :
    ∀ y, target y → ∃ x, owner x ∧ field x y := by
  intro y hy
  obtain ⟨x, ⟨z, hxz, rfl⟩, _⟩ := layout y hy
  exact ⟨x, typed x z hxz, hxz⟩

theorem singleton_fiber (field : BinaryRel α β) (x : α) :
    unaryLeftJoin (singletonRel x) field = field x := by
  funext y
  exact propext ⟨fun ⟨_, e, h⟩ => e ▸ h, fun h => ⟨x, rfl, h⟩⟩

theorem station_source_cover (owner : Rel α) (target : Rel β) (field : BinaryRel α β)
    (seen : Nat → Rel β) (t : Nat)
    (typed : ∀ x y, field x y → owner x ∧ target y)
    (multiplicity : ∀ x, owner x → qLone target (field x))
    (layout : qAll target (fun y => qOne (unaryRightJoin field (singletonRel y)) (fun _ => True))) :
    qAll owner (fun x => futureEventually (fun j => subset (unaryLeftJoin (singletonRel x) field) (seen j)) t) ↔
      eventualAtoms target seen t := by
  simp only [singleton_fiber]
  exact eventual_covered_fibers owner target field seen t
    (unique_preimage_covers _ _ _ (fun x y h => (typed x y h).1) layout)
    (fun x y _ h => (typed x y h).2)
    (fun x y z hx hy hz => multiplicity x hx y z (typed x y hy).2 hy (typed x z hz).2 hz)

-- Two signals with disjoint green times, two assigned tracks and one unassigned
-- track. With empty prox and Junction and all tracks in Entry and Exit, the
-- other Layout conjuncts of the selected source place no further restriction.
theorem station_partial_instance :
    let field : BinaryRel (Option Bool) Bool := fun x y => x = some y
    let green : Nat → Rel Bool := fun j b => j = (if b then 1 else 0)
    (qAll univRel (fun y => qOne (unaryRightJoin field (singletonRel y)) (fun _ => True))) ∧
      eventualFibers univRel field green 0 ∧ eventualAtoms univRel green 0 ∧
      ¬ relNonempty (field none) := by
  intro field green
  have layout : qAll univRel (fun y => qOne (unaryRightJoin field (singletonRel y)) (fun _ => True)) := by
    intro y _
    refine ⟨some y, ⟨y, rfl, rfl⟩, trivial, ?_⟩
    rintro x ⟨z, hx, rfl⟩ _
    exact hx
  have each : eventualAtoms univRel green 0 := fun b _ => ⟨_, Nat.zero_le _, rfl⟩
  have law := station_source_cover univRel univRel field green 0 (fun _ _ _ => ⟨trivial,trivial⟩)
    (fun _ _ _ _ _ h _ h' => Option.some.inj (h.symm.trans h')) layout
  simp only [singleton_fiber] at law
  refine ⟨layout, law.mpr each, each, ?_⟩
  rintro ⟨y, h⟩
  change (none : Option Bool) = some y at h
  cases h

theorem uncovered_signal :
    eventualFibers (univRel : Rel Unit) (fun _ _ : Unit => False) (fun _ => noneRel) 0 ∧
      ¬ eventualAtoms (univRel : Rel Unit) (fun _ => noneRel) 0 :=
  ⟨fun _ _ => ⟨0, Nat.le_refl _, fun _ h => h⟩, fun h => (h () trivial).choose_spec.2⟩

theorem multiple_signals_need_not_coincide :
    let seen : Nat → Rel Bool := fun j b => j = (if b then 1 else 0)
    eventualAtoms univRel seen 0 ∧
      ¬ eventualFibers (univRel : Rel Unit) (fun _ _ => True) seen 0 := by
  intro seen
  refine ⟨fun b _ => ⟨_, Nat.zero_le _, rfl⟩, ?_⟩
  intro h
  obtain ⟨_, _, both⟩ := h () trivial
  exact (by decide : 0 ≠ 1) ((both false trivial).symm.trans (both true trivial))

-- Even a bijection at every instant does not fix which signal a track reads.
theorem moving_field_is_not_a_static_cover :
    let f : Nat → Bool → Bool := fun i x => if i = 0 then x else !x
    (∀ i y, ∃ x, f i x = y) ∧
    (∀ x, futureEventually (fun i => f i x = true) 0) ∧
    ¬ eventualAtoms (univRel : Rel Bool) (fun _ y => y = true) 0 := by
  intro f
  constructor
  · intro i y
    by_cases hi : i = 0
    · exact ⟨y, by simp [f, hi]⟩
    · exact ⟨!y, by simp [f, hi]⟩
  · refine ⟨?_, fun h => Bool.noConfusion ((h false trivial).choose_spec.2)⟩
    intro x
    cases x with
    | false => exact ⟨1, by decide, rfl⟩
    | true => exact ⟨0, Nat.le_refl _, rfl⟩

end AdaptiveRelationalImage
