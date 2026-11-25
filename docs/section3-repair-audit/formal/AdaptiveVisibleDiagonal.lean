import Phase5SourceRules

namespace AdaptiveVisibleDiagonal

def pairsOf (r : BinaryRel α β) : Rel (α × β) := fun p => r p.1 p.2

def diagonal (v : Rel α) (r : BinaryRel α α) : Prop :=
  subset (intersection (relationProduct v v) (pairsOf r)) identityPairRelation

theorem diagonal_iff (v : Rel α) (r : BinaryRel α α) :
    diagonal v r ↔ ∀ x y, v x → v y → r x y → x = y :=
  ⟨fun h x y hx hy hr => h (x,y) ⟨⟨hx,hy⟩,hr⟩,
   fun h ⟨x,y⟩ ⟨⟨hx,hy⟩,hr⟩ => h x y hx hy hr⟩

-- Both slots range over the same set; the relation need not be symmetric.
theorem disjoint_visible (v : Rel α) (r : BinaryRel α α) :
    diagonal v r ↔ qAll v (fun x => qAll v (fun y => x ≠ y → ¬ r y x)) := by
  rw [diagonal_iff]
  constructor
  · intro h x hx y hy hne hr
    exact hne (h y x hy hx hr).symm
  · intro h x y hx hy hr
    exact Classical.byContradiction fun hne => h y hy x hx (Ne.symm hne) hr

theorem restricted_diagonal (v : Rel α) (r : BinaryRel α α) :
    subset (pairsOf (rangeRestrictionBinary (domainRestrictionBinary v r) v))
      identityPairRelation ↔ diagonal v r := by
  rw [diagonal_iff]
  exact ⟨fun h x y hx hy hr => h (x,y) ⟨⟨hx,hr⟩,hy⟩,
    fun h ⟨x,y⟩ ⟨⟨hx,hr⟩,hy⟩ => h x y hx hy hr⟩

theorem restricted_diagonal_range_first (v : Rel α) (r : BinaryRel α α) :
    subset (pairsOf (domainRestrictionBinary v (rangeRestrictionBinary r v)))
      identityPairRelation ↔ diagonal v r := by
  rw [diagonal_iff]
  exact ⟨fun h x y hx hy hr => h (x,y) ⟨hx,hr,hy⟩,
    fun h ⟨x,y⟩ ⟨hx,hr,hy⟩ => h x y hx hy hr⟩

theorem singleton_pair_member (x y : α) (r : BinaryRel α α) :
    relNonempty (intersection (relationProduct (singletonRel x) (singletonRel y)) (pairsOf r))
      ↔ r x y := by
  constructor
  · rintro ⟨⟨a,b⟩, ⟨rfl,rfl⟩, h⟩
    exact h
  · exact fun h => ⟨(x,y), ⟨rfl,rfl⟩, h⟩

theorem singleton_pair_diagonal (x y : α) (r : BinaryRel α α) :
    subset (intersection (relationProduct (singletonRel x) (singletonRel y)) (pairsOf r))
      identityPairRelation ↔ (r x y → x = y) :=
  ⟨fun h hr => h (x,y) ⟨⟨rfl,rfl⟩,hr⟩,
   fun h ⟨_,_⟩ ⟨⟨rfl,rfl⟩,hr⟩ => h hr⟩

theorem singleton_image_member (x y : α) (r : BinaryRel α α) :
    subset (singletonRel x) (unaryLeftJoin (singletonRel y) r) ↔ r y x := by
  constructor
  · intro h
    obtain ⟨_,rfl,hr⟩ := h x rfl
    exact hr
  · rintro hr _ rfl
    exact ⟨y,rfl,hr⟩

theorem diagonal_star_iff_positive (v : Rel α) (r : BinaryRel α α) :
    diagonal v (reflexiveTransitiveClosure r) ↔ diagonal v (transitiveClosure r) := by
  rw [diagonal_iff, diagonal_iff]
  exact ⟨fun h x y hx hy path => h x y hx hy (Or.inr path),
    fun h x y hx hy hp => hp.elim id (h x y hx hy)⟩

def shared (f : BinaryRel α β) := relationJoin f (converseBinary f)

theorem shared_symmetric (f : BinaryRel α β) : ∀ {x y}, shared f x y → shared f y x :=
  fun ⟨i,hx,hy⟩ => ⟨i,hy,hx⟩

theorem reverse_shared_path (f : BinaryRel α β) {x y} (p : PositivePath (shared f) x y) :
    PositivePath (shared f) y x := by
  induction p with
  | single e => exact .single (shared_symmetric f e)
  | tail _ e ih => exact positive_path_prepend (shared_symmetric f e) ih

-- R.R~ = R for this positive reachability relation, including isolated atoms:
-- a nonempty path supplies its own return path; no global self-loops assumed.
theorem shared_successor_iff (f : BinaryRel α β) (x y : α) :
    relationJoin (transitiveClosure (shared f)) (converseBinary (transitiveClosure (shared f))) x y
      ↔ transitiveClosure (shared f) x y :=
  ⟨fun ⟨_,hx,hy⟩ => positive_path_transitive hx (reverse_shared_path f hy),
   fun h => ⟨y,h,positive_path_transitive (reverse_shared_path f h) h⟩⟩

theorem visible_common_successor (v : Rel α) (f : BinaryRel α β) :
    let source := domainRestrictionBinary v (transitiveClosure (shared f))
    subset (pairsOf (relationJoin source (converseBinary source))) identityPairRelation
      ↔ diagonal v (transitiveClosure (shared f)) := by
  dsimp only
  rw [diagonal_iff]
  constructor
  · intro h x y hx hy path
    obtain ⟨z,hxz,hyz⟩ := (shared_successor_iff f x y).mpr path
    exact h (x,y) ⟨z,⟨hx,hxz⟩,hy,hyz⟩
  · rintro h ⟨x,y⟩ ⟨z,⟨hx,hxz⟩,hy,hyz⟩
    exact h x y hx hy ((shared_successor_iff f x y).mp ⟨z,hxz,hyz⟩)

-- Alloy parses V <: R . ~(V <: R) with the first restriction outside JOIN.
theorem visible_common_successor_source (v : Rel α) (f : BinaryRel α β) :
    let r := transitiveClosure (shared f)
    subset (pairsOf (domainRestrictionBinary v
      (relationJoin r (converseBinary (domainRestrictionBinary v r))))) identityPairRelation
      ↔ diagonal v r := by
  dsimp only
  refine Iff.trans ?_ (visible_common_successor v f)
  exact ⟨fun h ⟨x,y⟩ ⟨z,⟨vx,xz⟩,vy,yz⟩ => h (x,y) ⟨vx,z,xz,vy,yz⟩,
         fun h ⟨x,y⟩ ⟨vx,z,xz,vy,yz⟩ => h (x,y) ⟨z,⟨vx,xz⟩,vy,yz⟩⟩

theorem path_start_in_profile (p : Rel α) (ids : BinaryRel α β) {x y}
    (h : PositivePath (shared (domainRestrictionBinary p ids)) x y) : p x := by
  induction h with
  | single e => exact e.choose_spec.1.1
  | tail _ _ ih => exact ih

-- Starting inside the profile is essential: every subsequent state is
-- already guarded by the range restriction on each edge.
theorem profile_reach (p : Rel α) (ids : BinaryRel α β) {x y} (hx : p x) :
    PositivePath (rangeRestrictionBinary (shared ids) p) x y ↔
      PositivePath (shared (domainRestrictionBinary p ids)) x y := by
  constructor
  · intro h
    suffices aux : p y ∧ PositivePath (shared (domainRestrictionBinary p ids)) x y from aux.2
    induction h with
    | single e =>
      obtain ⟨⟨i,hi,hj⟩,hk⟩ := e
      exact ⟨hk,.single ⟨i,⟨hx,hi⟩,hk,hj⟩⟩
    | tail _ e ih =>
      obtain ⟨⟨i,hi,hj⟩,hk⟩ := e
      exact ⟨hk,.tail ih.2 ⟨i,⟨ih.1,hi⟩,hk,hj⟩⟩
  · intro h
    induction h with
    | single e =>
      obtain ⟨i,⟨_,hi⟩,hk,hj⟩ := e
      exact .single ⟨⟨i,hi,hj⟩,hk⟩
    | tail _ e ih =>
      obtain ⟨i,⟨_,hi⟩,hk,hj⟩ := e
      exact .tail ih ⟨⟨i,hi,hj⟩,hk⟩

theorem lone_visible_image (p v : Rel α) (ids : BinaryRel α β) :
    qAll p (fun w => qLone v ((transitiveClosure (rangeRestrictionBinary (shared ids) p)) w))
      ↔ diagonal v (transitiveClosure (shared (domainRestrictionBinary p ids))) := by
  rw [diagonal_iff]
  let f := domainRestrictionBinary p ids
  constructor
  · intro h x y hx hy path
    have hp := path_start_in_profile p ids path
    have cycle := positive_path_transitive path (reverse_shared_path f path)
    exact h x hp x y hx ((profile_reach p ids hp).mpr cycle) hy ((profile_reach p ids hp).mpr path)
  · intro h w hw x y hx h1 hy h2
    have first := (profile_reach p ids hw).mp h1
    have second := (profile_reach p ids hw).mp h2
    exact h x y hx hy (positive_path_transitive (reverse_shared_path f first) second)

theorem same_owner_at_same_instant (owners : Nat → Rel β) (visible : Nat → β → Rel α)
    (paths : Nat → β → BinaryRel α α) (t : Nat) :
    qAll (owners t) (fun u => diagonal (visible t u) (paths t u)) ↔
      qAll (owners t) (fun u => qAll (visible t u) (fun x =>
        qAll (visible t u) (fun y => x ≠ y → ¬ paths t u y x))) :=
  ⟨fun h u hu => (disjoint_visible _ _).mp (h u hu),
   fun h u hu => (disjoint_visible _ _).mpr (h u hu)⟩

theorem dropping_distinct_changes_result :
    diagonal (univRel : Rel Unit) (fun _ _ => True) ∧ ¬ (∀ _x _y : Unit, ¬ True) :=
  ⟨(diagonal_iff _ _).mpr (fun _ _ _ _ _ => Subsingleton.elim ..), fun h => h () () trivial⟩

theorem directed_fork_is_not_reachability :
    let edges : BinaryRel Nat Nat := fun x y => x < 2 ∧ y = 2
    relationJoin edges (converseBinary edges) 0 1 ∧ ¬ edges 0 1 := by
  exact ⟨⟨2,⟨by decide,rfl⟩,by decide,rfl⟩,fun h => (by decide : 1 ≠ 2) h.2⟩

theorem crossing_owners_changes_result :
    let seen : Bool → Rel Bool := fun u x => x = u
    let allEdges : BinaryRel Bool Bool := fun _ _ => True
    (∀ u, diagonal (seen u) allEdges) ∧
      ¬ subset (intersection (relationProduct (seen false) (seen true)) (pairsOf allEdges))
        identityPairRelation :=
  ⟨fun _ => (diagonal_iff _ _).mpr (fun _ _ hx hy _ => hx.trans hy.symm),
   fun h => Bool.noConfusion (h (false,true) ⟨⟨rfl,rfl⟩,trivial⟩)⟩

theorem outside_profile_can_enter :
    let p : Rel Bool := fun x => x = true
    let ids : BinaryRel Bool Unit := fun _ _ => True
    PositivePath (rangeRestrictionBinary (shared ids) p) false true ∧
      ¬ PositivePath (shared (domainRestrictionBinary p ids)) false true :=
  ⟨.single ⟨⟨(),trivial,trivial⟩,rfl⟩,fun h => (by decide : false ≠ true)
      (path_start_in_profile (fun x => x = true) (fun _ (_ : Unit) => True) h)⟩

end AdaptiveVisibleDiagonal
