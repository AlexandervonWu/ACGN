import AdaptiveUniquePreimage

namespace AdaptiveOwnerFiber

open AdaptiveVisibleDiagonal

def columnSpec (photos : Rel β) (posts : BinaryRel α β) : Prop :=
  qAll photos (fun p => oneOf (unaryRightJoin posts (singletonRel p)))

theorem column_at (posts : BinaryRel α β) (p : β) :
    unaryRightJoin posts (singletonRel p) = fun u => posts u p :=
  (AdaptiveUniquePreimage.backward_fiber posts p).symm.trans
    (AdaptiveRelationalImage.singleton_fiber (converseBinary posts) p)

theorem scoped_one_iff (u test : Rel α) (typed : ∀ x, test x → u x) :
    qOne u test ↔ oneOf test := by
  constructor
  · rintro ⟨x,_,hx,h⟩
    exact ⟨⟨x,hx⟩,fun a b ha hb => (h a (typed a ha) ha).trans (h b (typed b hb) hb).symm⟩
  · rintro ⟨⟨x,hx⟩,h⟩
    exact ⟨x,typed x hx,hx,fun a _ ha => h a x ha hx⟩

-- The independent schema kernel prints unique existence as a witness and
-- a uniqueness implication, both for ONE and the scoped ONE quantifier.
theorem one_as_unique (test : Rel α) :
    oneOf test ↔ ∃ x, test x ∧ ∀ y, test y → y=x :=
  ⟨fun ⟨⟨x,hx⟩,h⟩ => ⟨x,hx,fun y hy => h y x hy hx⟩,
   fun ⟨x,hx,h⟩ => ⟨⟨x,hx⟩,fun a b ha hb => (h a ha).trans (h b hb).symm⟩⟩

theorem owner_witness (users : Rel α) (photos : Rel β) (posts : BinaryRel α β)
    (typed : ∀ u p, posts u p → users u) :
    qAll photos (fun p => qOne users (fun u => posts u p)) ↔ columnSpec photos posts := by
  unfold columnSpec qAll
  simp only [column_at]
  exact ⟨fun h p hp => (scoped_one_iff _ _ (fun u => typed u p)).mp (h p hp),
    fun h p hp => (scoped_one_iff _ _ (fun u => typed u p)).mpr (h p hp)⟩

theorem row_read (posts : BinaryRel α β) (u : α) (p : β) :
    subset (singletonRel p) (unaryLeftJoin (singletonRel u) posts) ↔ posts u p := by
  rw [AdaptiveRelationalImage.singleton_fiber,AdaptivePhaseAlgebra.singleton_membership_read]

theorem tuple_read (posts : BinaryRel α β) (u : α) (p : β) :
    subset (relationProduct (singletonRel u) (singletonRel p)) (pairsOf posts) ↔ posts u p :=
  ⟨fun h => h (u,p) ⟨rfl,rfl⟩,fun h ⟨_,_⟩ ⟨rfl,rfl⟩ => h⟩

theorem quantified_row_source (users : Rel α) (photos : Rel β) (posts : BinaryRel α β)
    (typed : ∀ u p, posts u p → users u) :
    qAll photos (fun p => qOne users (fun u =>
      subset (singletonRel p) (unaryLeftJoin (singletonRel u) posts))) ↔ columnSpec photos posts := by
  simpa only [row_read] using owner_witness users photos posts typed

theorem quantified_tuple_source (users : Rel α) (photos : Rel β) (posts : BinaryRel α β)
    (typed : ∀ u p, posts u p → users u) :
    qAll photos (fun p => qOne users (fun u =>
      subset (relationProduct (singletonRel u) (singletonRel p)) (pairsOf posts))) ↔ columnSpec photos posts := by
  simpa only [tuple_read] using owner_witness users photos posts typed

theorem inverse_source (photos : Rel β) (posts : BinaryRel α β) :
    qAll photos (fun p => oneOf (unaryLeftJoin (singletonRel p) (converseBinary posts))) ↔ columnSpec photos posts := by
  simp only [columnSpec,AdaptiveUniquePreimage.backward_fiber]

-- Left multiplicity ONE is a constraint for each target, not each owner.
theorem inverse_arrow (users : Rel α) (photos : Rel β) (posts : BinaryRel α β)
    (typed : ∀ u p, posts u p → users u ∧ photos p) :
    (subset (pairsOf posts) (relationProduct users photos) ∧
      qAll photos (fun p => qOne users (fun u => posts u p))) ↔ columnSpec photos posts := by
  have h := owner_witness users photos posts (fun u p hp => (typed u p hp).1)
  exact ⟨fun a => h.mp a.2,fun a => ⟨fun ⟨u,p⟩ e => typed u p e,h.mpr a⟩⟩

theorem coverage_and_unique (users : Rel α) (photos : Rel β) (posts : BinaryRel α β)
    (typed : ∀ u p, posts u p → users u ∧ photos p) :
    columnSpec photos posts ↔
      subset photos (unaryLeftJoin users posts) ∧ AdaptiveUniquePreimage.uniquePreimage posts := by
  unfold columnSpec qAll
  simp only [column_at]
  constructor
  · intro h
    constructor
    · intro p hp
      obtain ⟨u,edge⟩ := (h p hp).1
      exact ⟨u,(typed u p edge).1,edge⟩
    · intro p u v a b
      exact (h p (typed u p a).2).2 u v a b
  · rintro ⟨covers,unique⟩ p hp
    obtain ⟨u,_,edge⟩ := covers p hp
    exact ⟨⟨u,edge⟩,unique p⟩

theorem lone_misses_unposted : loneOf (noneRel : Rel Unit) ∧ ¬ oneOf (noneRel : Rel Unit) :=
  ⟨fun _ _ h => False.elim h,fun ⟨⟨_,h⟩,_⟩ => h⟩

theorem some_misses_two_owners :
    relNonempty (univRel : Rel Bool) ∧ ¬ oneOf (univRel : Rel Bool) := by
  refine ⟨⟨false,trivial⟩,?_⟩
  intro h
  cases h.2 false true trivial trivial

theorem untyped_owner_violates_witness :
    qOne (fun x : Bool => x=false) univRel ∧ ¬ oneOf (univRel : Rel Bool) :=
  ⟨⟨false,rfl,trivial,fun _ hx _ => hx⟩,some_misses_two_owners.2⟩

-- One photo without an owner is a real failing model for the source
-- oracle; adding an unused binder with empty domain masks that failure.
theorem empty_extra_photo_scope :
    let posts : BinaryRel Bool Unit := fun _ _ => False
    let photos : Rel Unit := univRel
    let users : Rel Bool := univRel
    (∀ u p, posts u p → users u ∧ photos p) ∧
    qAll photos (fun p => qAll (noneRel : Rel Unit) (fun _ =>
      qOne users (fun u => posts u p))) ∧ ¬ columnSpec photos posts := by
  intro posts photos users
  refine ⟨fun _ _ h => False.elim h,fun _ _ _ h => False.elim h,?_⟩
  intro h
  obtain ⟨u,edge⟩ := (h () trivial).1
  obtain ⟨p,no,_⟩ := edge
  exact no

theorem extra_on_oracle_masks_unposted :
    let posts : BinaryRel Bool Unit := fun _ _ => False
    let photos : Rel Unit := univRel
    let users : Rel Bool := univRel
    qAll photos (fun p => qAll (noneRel : Rel Unit) (fun _ =>
      oneOf (unaryRightJoin posts (singletonRel p)))) ∧
    ¬ qAll photos (fun p => qOne users (fun u => posts u p)) := by
  intro posts photos users
  refine ⟨fun _ _ _ h => False.elim h,?_⟩
  intro got
  obtain ⟨_,_,no,_⟩ := got () trivial
  exact no

-- Exact distinct-root test in EquivalenceAugmenter.changedRootArity.
private def oldRoot (a b l r : String × Nat) :=
  a ≠ b ∧ (l.1=a.1 ∨ l.1=b.1) ∧ (r.1=a.1 ∨ r.1=b.1) ∧ ¬((l=a ∨ l=b) ∧ (r=a ∨ r=b))

theorem extra_scope_iff (target extra body : Rel α) :
    qAll target (fun p => qAll extra (fun _ => body p)) ↔
      (relNonempty extra → qAll target body) :=
  AdaptivePhaseAlgebra.extra_universal_iff _ _ _

-- socialMedia/inv1, one owner and one photo joined by a real post.
-- Both quantified roots have two children; another source declaration on
-- the oracle changes its arity but cannot pass the old distinct-root check.
theorem quantified_old_gate_and_path :
    let read := ("rd/target-all",2)
    let posts : BinaryRel Bool Unit := fun u _ => u = true
    let users : Rel Bool := univRel
    let photos : Rel Unit := univRel
    ¬ oldRoot read read read ("rd/target-all",3) ∧
      (∀ u p, posts u p → users u ∧ photos p) ∧
      qAll photos (fun p => qOne users (fun u =>
        subset (relationProduct (singletonRel u) (singletonRel p)) (pairsOf posts))) ∧
      columnSpec photos posts := by
  intro read posts users photos
  have h : qAll photos (fun p => qOne users (fun u => posts u p)) :=
    fun _ _ => ⟨true,trivial,rfl,fun _ _ edge => edge⟩
  have typed : ∀ u p, posts u p → users u := fun _ _ _ => trivial
  have oracle := (owner_witness users photos posts typed).mp h
  exact ⟨fun rejected => rejected.1 rfl,fun _ _ _ => ⟨trivial,trivial⟩,
    (quantified_tuple_source users photos posts typed).mpr oracle,oracle⟩

end AdaptiveOwnerFiber
