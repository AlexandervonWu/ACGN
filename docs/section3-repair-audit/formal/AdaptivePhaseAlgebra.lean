import Phase5SourceRules

/- Unoriented laws for the adaptive theory. Trace positions include the current
instant; neither operands nor their carriers have to be constant over time. -/
namespace AdaptivePhaseAlgebra

theorem after_and (P Q : Nat → Prop) (t : Nat) :
    (fun i => P i ∧ Q i) (t+1) ↔ P (t+1) ∧ Q (t+1) := Iff.rfl

theorem after_or (P Q : Nat → Prop) (t : Nat) :
    (fun i => P i ∨ Q i) (t+1) ↔ P (t+1) ∨ Q (t+1) := Iff.rfl

theorem always_and (P Q : Nat → Prop) (t : Nat) :
    futureAlways (fun i => P i ∧ Q i) t ↔ futureAlways P t ∧ futureAlways Q t :=
  ⟨fun h => ⟨fun i hi => (h i hi).1, fun i hi => (h i hi).2⟩,
   fun ⟨hp, hq⟩ i hi => ⟨hp i hi, hq i hi⟩⟩

theorem eventually_or (P Q : Nat → Prop) (t : Nat) :
    futureEventually (fun i => P i ∨ Q i) t ↔ futureEventually P t ∨ futureEventually Q t := by
  constructor
  · rintro ⟨i, hi, hp | hq⟩
    · exact Or.inl ⟨i, hi, hp⟩
    · exact Or.inr ⟨i, hi, hq⟩
  · rintro (⟨i, hi, hp⟩ | ⟨i, hi, hq⟩)
    · exact ⟨i, hi, Or.inl hp⟩
    · exact ⟨i, hi, Or.inr hq⟩

theorem some_product (R : Rel α) (S : Rel β) :
    relNonempty (relationProduct R S) ↔ relNonempty R ∧ relNonempty S :=
  ⟨fun ⟨(a,b), ha, hb⟩ => ⟨⟨a, ha⟩, ⟨b, hb⟩⟩,
   fun ⟨⟨a, ha⟩, ⟨b, hb⟩⟩ => ⟨(a,b), ha, hb⟩⟩

theorem after_some_product (R : Nat → Rel α) (S : Nat → Rel β) (t : Nat) :
    relNonempty (relationProduct (R (t+1)) (S (t+1))) ↔
      relNonempty (R (t+1)) ∧ relNonempty (S (t+1)) :=
  some_product _ _

theorem no_product (R : Rel α) (S : Rel β) :
    ¬ relNonempty (relationProduct R S) ↔ ¬ relNonempty R ∨ ¬ relNonempty S := by
  rw [some_product]
  exact Classical.not_and_iff_not_or_not

-- The two eventual witnesses need not be at the same time.
theorem distinct_instants :
    (futureEventually (· = 0) 0 ∧ futureEventually (· = 1) 0) ∧
      ¬ futureEventually (fun i => i = 0 ∧ i = 1) 0 :=
  ⟨⟨⟨0, by decide, rfl⟩, ⟨1, by decide, rfl⟩⟩, fun ⟨_, _, h0, h1⟩ => by omega⟩

theorem always_unfold (P : Nat → Prop) (t : Nat) :
    futureAlways P t ↔ P t ∧ futureAlways P (t+1) := by
  constructor
  · intro h
    exact ⟨h t (by omega), fun i hi => h i (by omega)⟩
  · rintro ⟨now, later⟩ i hi
    rcases Nat.eq_or_lt_of_le hi with e | lt
    · exact e ▸ now
    · exact later i lt

theorem eventually_unfold (P : Nat → Prop) (t : Nat) :
    futureEventually P t ↔ P t ∨ futureEventually P (t+1) := by
  constructor
  · rintro ⟨i, hi, h⟩
    rcases Nat.eq_or_lt_of_le hi with rfl | lt
    · exact Or.inl h
    · exact Or.inr ⟨i, lt, h⟩
  · rintro (now | ⟨i, hi, later⟩)
    · exact ⟨t, by omega, now⟩
    · exact ⟨i, by omega, later⟩

theorem one_some_lone (R : Rel α) : oneOf R ↔ relNonempty R ∧ loneOf R := Iff.rfl

theorem lone_no_one (R : Rel α) : loneOf R ↔ ¬ relNonempty R ∨ oneOf R := by
  constructor
  · intro h
    by_cases inhabited : relNonempty R
    · exact Or.inr ⟨inhabited, h⟩
    · exact Or.inl inhabited
  · rintro (empty | single)
    · exact fun a _ ha _ => (empty ⟨a, ha⟩).elim
    · exact single.2

theorem product_lone_iff (R : Rel α) (S : Rel β) :
    loneOf (relationProduct R S) ↔
      ¬ relNonempty R ∨ ¬ relNonempty S ∨ (loneOf R ∧ loneOf S) := by
  constructor
  · intro h
    by_cases hr : relNonempty R
    case neg => exact Or.inl hr
    by_cases hs : relNonempty S
    case neg => exact Or.inr (Or.inl hs)
    obtain ⟨x, hx⟩ := hr
    obtain ⟨y, hy⟩ := hs
    exact Or.inr (Or.inr
      ⟨fun a b ha hb => congrArg Prod.fst (h (a,y) (b,y) ⟨ha,hy⟩ ⟨hb,hy⟩),
       fun a b ha hb => congrArg Prod.snd (h (x,a) (x,b) ⟨hx,ha⟩ ⟨hx,hb⟩)⟩)
  · rintro (hr | hs | ⟨hr,hs⟩) a b ha hb
    · exact (hr ⟨a.1, ha.1⟩).elim
    · exact (hs ⟨a.2, ha.2⟩).elim
    · exact Prod.ext (hr _ _ ha.1 hb.1) (hs _ _ ha.2 hb.2)

theorem one_product (R : Rel α) (S : Rel β) :
    oneOf (relationProduct R S) ↔ oneOf R ∧ oneOf S := by
  rw [one_some_lone, some_product, product_lone_iff, one_some_lone R, one_some_lone S]
  grind

theorem pointwise_empty_iff_eq (R : Rel α) :
    (∀ a, R a ↔ False) ↔ R = noneRel := by
  constructor
  · exact fun h => funext (fun a => propext (h a))
  · rintro rfl a
    rfl

theorem eq_empty_iff_no (R : Rel α) : R = noneRel ↔ ¬ relNonempty R := by
  rw [← subset_none_iff_no_members]
  exact ⟨fun h => h ▸ relation_subset_reflexive _, fun h =>
    (pointwise_empty_iff_eq R).mp (fun a => ⟨h a, False.elim⟩)⟩

theorem ne_empty_iff_some (R : Rel α) : R ≠ noneRel ↔ relNonempty R := by
  change (¬ R = noneRel) ↔ _
  rw [← not_subset_none_iff_some_member, eq_empty_iff_no, ← subset_none_iff_no_members]

-- The old root challenge requires both observed tags to be retained and at
-- least one observed (tag, childCount) to be absent from the witness roots.
inductive EmptyRoot | eqNone | neNone | not | some | eventually | always | bindAll
  deriving DecidableEq

def oldArityChallenge (a b l r : EmptyRoot × Nat) : Prop :=
  (l.1 = a.1 ∨ l.1 = b.1) ∧ (r.1 = a.1 ∨ r.1 = b.1) ∧
    ¬ ((l = a ∨ l = b) ∧ (r = a ∨ r = b))

theorem fixed_roots_cannot_change_arity (a b l r : EmptyRoot) :
    ¬ oldArityChallenge (a,1) (b,1) (l,1) (r,1) := by
  simp only [oldArityChallenge, Prod.mk.injEq, and_true]
  exact fun ⟨hl, hr, denied⟩ => denied ⟨hl,hr⟩

-- inv3: Student and Teacher are unary subsets of Person; overlap is allowed.
theorem classroom_overlap_old_rejection :
    ¬ oldArityChallenge (.eqNone,1) (.not,1) (.eqNone,1) (.not,1) ∧
    (intersection (fun p : Bool => p = true) (fun p => p = true) = noneRel ↔
      ¬ relNonempty (intersection (fun p : Bool => p = true) (fun p => p = true))) :=
  ⟨fixed_roots_cannot_change_arity _ _ _ _, eq_empty_iff_no _⟩

theorem classroom_teaches_old_rejection :
    ¬ oldArityChallenge (.neNone,1) (.some,1) (.neNone,1) (.some,1) ∧
    (unaryLeftJoin (fun p : Bool => p = true) (fun (p : Bool) (_ : Unit) => p = true) ≠ noneRel ↔
      relNonempty (unaryLeftJoin (fun p : Bool => p = true) (fun (p : Bool) (_ : Unit) => p = true))) :=
  ⟨fixed_roots_cannot_change_arity _ _ _ _, ne_empty_iff_some _⟩

theorem empty_literal_product :
    relationProduct (noneRel : Rel α) (noneRel : Rel β) = noneRel :=
  empty_relation_product_left _

-- Increasing tuple width can change the answer even on nonempty carrier types.
theorem product_width_negative :
    relNonempty (univRel : Rel Unit) ∧
    ¬ relNonempty (relationProduct (univRel : Rel Unit) (noneRel : Rel Bool)) :=
  ⟨⟨(), True.intro⟩, fun ⟨_, _, impossible⟩ => impossible⟩

-- The domain is read at i, and the chosen atom remains the same at every j.
theorem eventual_witness_always_unfold (D P : Nat → Rel α) (t : Nat) :
    futureEventually (fun i => qSome (D i) (fun x =>
      P i x ∧ futureAlways (fun j => P j x) (i+1))) t ↔
    futureEventually (fun i => qSome (D i) (fun x =>
      futureAlways (fun j => P j x) i)) t := by
  constructor <;> rintro ⟨i, hi, x, hx, h⟩
  · exact ⟨i, hi, x, hx, (always_unfold _ i).mpr h⟩
  · exact ⟨i, hi, x, hx, (always_unfold _ i).mp h⟩

-- File and Trash coincide in this trace: both empty now, both inhabited forever after.
theorem cannot_bind_eventual_witness_now :
    let file : Nat → Rel Unit := fun i _ => 0 < i
    let trash := file
    futureEventually (fun i => qSome (file i) (fun x => futureAlways (fun j => trash j x) i)) 0 ∧
      ¬ qSome (file 0) (fun x => futureEventually (fun i => futureAlways (fun j => trash j x) i) 0) := by
  dsimp only
  exact ⟨⟨1, by decide, (), by decide, fun j hj => by change 0 < j; omega⟩,
         fun ⟨_, h, _⟩ => (Nat.lt_irrefl 0) h⟩

inductive TimeFrame | after | always | eventually

def inFrames : List TimeFrame → (Nat → Prop) → Nat → Prop
  | [], p => p
  | .after :: rest, p => fun t => inFrames rest p (t+1)
  | .always :: rest, p => futureAlways (inFrames rest p)
  | .eventually :: rest, p => futureEventually (inFrames rest p)

theorem witness_context_congr (frames : List TimeFrame) (D P Q : Nat → Rel α)
    (body : ∀ t x, P t x ↔ Q t x) (t : Nat) :
    inFrames frames (fun i => qSome (D i) (P i)) t ↔
    inFrames frames (fun i => qSome (D i) (Q i)) t := by
  have eq : (fun i => qSome (D i) (P i)) = (fun i => qSome (D i) (Q i)) := by
    funext i
    apply propext
    constructor <;> rintro ⟨x, hx, h⟩
    · exact ⟨x, hx, (body i x).mp h⟩
    · exact ⟨x, hx, (body i x).mpr h⟩
  rw [eq]

-- A concrete mutable File/Trash interpretation: the atom appears at t=1.
theorem trash_inv12_old_root_rejected :
    let file : Nat → Rel Unit := fun i _ => 0 < i
    let trash := file
    ¬ oldArityChallenge (.eventually,1) (.eventually,1) (.eventually,1) (.eventually,1) ∧
    (futureEventually (fun i => qSome (file i) (fun x =>
      trash i x ∧ futureAlways (fun j => trash j x) (i+1))) 0 ↔
     futureEventually (fun i => qSome (file i) (fun x => futureAlways (fun j => trash j x) i)) 0) :=
  ⟨fixed_roots_cannot_change_arity _ _ _ _, eventual_witness_always_unfold _ _ _⟩

-- trash_ltl/inv6: an already selected member is retained at every later
-- instant iff each successor step preserves the relation.
def retainsMembers (D S : Nat → Rel α) (i : Nat) : Prop :=
  qAll (D i) (fun x => S i x → futureAlways (fun j => S j x) (i+1))

theorem persistence_iff_next_subset (D S : Nat → Rel α) (t : Nat)
    (typed : futureAlways (fun i => subset (S i) (D i)) t) :
    futureAlways (retainsMembers D S) t ↔
      futureAlways (fun i => subset (S i) (S (i+1))) t := by
  constructor
  · intro keep i hi x hx
    exact keep i hi x (typed i hi x hx) hx (i+1) (Nat.le_refl _)
  · intro step i hi x _ hx j hj
    have advance (n : Nat) : S (i+n) x := by
      induction n with
      | zero => exact hx
      | succ n ih => exact step (i+n) (by omega) x ih
    have eq : i+(j-i) = j := by omega
    exact eq ▸ advance (j-i)

theorem initial_subset_is_insufficient :
    let d : Nat → Rel Unit := fun _ => noneRel
    let s : Nat → Rel Unit := fun i _ => i = 1
    subset (s 0) (d 0) ∧ futureAlways (retainsMembers d s) 0 ∧
      ¬ futureAlways (fun i => subset (s i) (s (i+1))) 0 := by
  dsimp only
  exact ⟨fun _ h => by contradiction, fun _ _ _ h => h.elim,
         fun h => (by decide : 1+1 ≠ 1) (h 1 (by decide) () rfl)⟩

def childView (D R : Nat → Rel α) (i : Nat) : Rel α :=
  fun x => R i x ∧ D i x

theorem declared_child_view (D R : Nat → Rel α) (decl : ∀ i, subset (R i) (D i)) :
    childView D R = R := by
  funext i x
  exact propext ⟨And.left, fun h => ⟨h, decl i x h⟩⟩

theorem persistence_of_child_view (D R : Nat → Rel α) (t : Nat) :
    futureAlways (retainsMembers D (childView D R)) t ↔
      futureAlways (fun i => subset (childView D R i) (childView D R (i+1))) t :=
  persistence_iff_next_subset _ _ _ (fun _ _ _ h => h.2)

-- Parser declaration identity is represented by its resolved index, not its spelling.
def readsNextSubset (env : Nat → Nat → Rel α) (left primed : Nat) (i : Nat) :=
  subset (env left i) (env primed (i+1))

theorem authenticated_self_read (env : Nat → Nat → Rel α) (l r i : Nat) (same : l = r) :
    readsNextSubset env l r i ↔ subset (env l i) (env l (i+1)) := by subst r; rfl

-- Census of the operators the old FutureFragment visitor marked unsupported.
inductive TemporalRead where
  | always | prime | after | eventually | before | historically | once
  | until | releases | since | triggered
  deriving DecidableEq

def oldFutureFragment (ops : List TemporalRead) : Bool :=
  ops.all fun op => [TemporalRead.always, .after, .eventually].contains op

theorem trash_inv6_prime_instance :
    let d : Nat → Rel Unit := fun _ => univRel
    let r : Nat → Rel Unit := fun i _ => 0 < i
    let env := fun (k : Nat) => if k = 0 then d else r
    oldFutureFragment [.always, .prime] = false ∧
    ¬ oldArityChallenge (.always,1) (.always,1) (.always,1) (.always,1) ∧
    (∀ i, subset (r i) (d i)) ∧
    futureAlways (readsNextSubset env 1 1) 0 ∧ futureAlways (retainsMembers d r) 0 := by
  dsimp only
  have step : futureAlways (fun i => subset ((fun _ : Unit => 0 < i)) (fun _ => 0 < i+1)) 0 := by
    intro i _ _ hi
    omega
  exact ⟨rfl, fixed_roots_cannot_change_arity _ _ _ _, fun _ _ _ => True.intro, step,
    (persistence_iff_next_subset _ _ _ (fun _ _ _ _ => True.intro)).mpr step⟩

-- At a universal binding site, dropping E is sound exactly when the
-- obligations on D ∩ E are already satisfied (not just when E is nonempty).
theorem universal_difference_partition (D E P : Rel α) :
    qAll D P ↔ qAll (difference D E) P ∧ qAll (intersection D E) P := by
  constructor
  · intro h
    exact ⟨fun x hx => h x hx.1, fun x hx => h x hx.1⟩
  · intro h x hx
    by_cases he : E x
    · exact h.2 x ⟨hx,he⟩
    · exact h.1 x ⟨hx,he⟩

theorem eventual_current_domain (D S : Nat → Rel α) (t : Nat) :
    qAll (difference (D t) (S t)) (fun x => futureEventually (fun j => S j x) t) ↔
      qAll (D t) (fun x => futureEventually (fun j => S j x) t) := by
  rw [universal_difference_partition (D t) (S t)]
  exact ⟨fun h => ⟨h, fun _ hx => ⟨t, Nat.le_refl _, hx.2⟩⟩, And.left⟩

theorem eventual_current_under_frames (frames : List TimeFrame) (D S : Nat → Rel α) (t : Nat) :
    inFrames frames (fun i => qAll (difference (D i) (S i)) (fun x => futureEventually (fun j => S j x) i)) t ↔
    inFrames frames (fun i => qAll (D i) (fun x => futureEventually (fun j => S j x) i)) t := by
  have h := funext fun i => propext (eventual_current_domain D S i)
  rw [h]

-- Appending a fresh, independent singleton universal leaves both the
-- original domain and body intact. The only additional premise is whether
-- the new domain is inhabited at THIS instant.
theorem extra_universal_iff (D E P : Rel α) :
    qAll D (fun x => qAll E (fun _ => P x)) ↔ (relNonempty E → qAll D P) :=
  ⟨fun h ⟨z,hz⟩ x hx => h x hx z hz, fun h x hx z hz => h ⟨z,hz⟩ x hx⟩

-- Necessary head tests for the *three previous* non-root alternatives.
-- This deliberately overapproximates them: they also checked children,
-- retained endpoints, mutation arity and an actual Alloy counterexample.
inductive ScopeHead | universal | existential | nextSubset | other deriving DecidableEq
def priorNonRootHeads (l r : EmptyRoot) (a b : ScopeHead) : Prop :=
  (l = .eqNone ∨ l = .neNone ∨ r = .eqNone ∨ r = .neNone) ∨
  (a = .existential ∧ b = .existential) ∨ (a = .nextSubset ∨ b = .nextSubset)

theorem inv15_no_prior_alternative :
    ¬ (oldArityChallenge (.always,1) (.always,1) (.always,1) (.always,1) ∨
       priorNonRootHeads .always .always .universal .universal) := by
  rintro (root | inner)
  · exact fixed_roots_cannot_change_arity _ _ _ _ root
  · simp [priorNonRootHeads] at inner

-- Without an outer ALWAYS the wider root really has a different arity,
-- but changedRootArity first rejects identical inferred root signatures.
theorem station_inv2_old_gate_and_path :
    let sig := (EmptyRoot.bindAll,2)
    let signals : Nat → Rel Bool := fun _ => univRel
    let green : Nat → Rel Bool := fun i x => i = (if x then 2 else 1)
    ¬ ((sig ≠ sig ∧ oldArityChallenge sig sig (.bindAll,3) sig) ∨
      priorNonRootHeads .bindAll .bindAll .universal .universal) ∧
    (∀ i, subset (green i) (signals i)) ∧
    (qAll (difference (signals 0) (green 0)) (fun x => futureEventually (fun j => green j x) 0) ↔
      qAll (signals 0) (fun x => futureEventually (fun j => green j x) 0)) := by
  intro sig signals green
  exact ⟨by simp [priorNonRootHeads], fun _ _ _ => True.intro, eventual_current_domain signals green 0⟩

theorem trash_inv15_old_root_and_wide_control :
    let file : Nat → Rel Unit := fun i _ => i = 0
    let trash : Nat → Rel Unit := fun _ => noneRel
    let extra : Nat → Rel Unit := fun _ => noneRel
    let eventual := fun i (x : Unit) => futureEventually (fun j => trash j x) i
    ¬ oldArityChallenge (.always,1) (.always,1) (.always,1) (.always,1) ∧
      (∀ i, subset (trash i) (file i)) ∧ (∀ i, subset (extra i) (file i)) ∧
      (futureAlways (fun i => qAll (difference (file i) (trash i)) (eventual i)) 0 ↔
       futureAlways (fun i => qAll (file i) (eventual i)) 0) ∧
      futureAlways (fun i => qAll (file i) (fun x => qAll (extra i) (fun _ => eventual i x))) 0 ∧
      ¬ futureAlways (fun i => qAll (file i) (eventual i)) 0 := by
  dsimp only
  refine ⟨fixed_roots_cannot_change_arity _ _ _ _, fun _ _ h => False.elim h,
    fun _ _ h => False.elim h, eventual_current_under_frames [.always] _ _ 0,
    fun _ _ _ _ _ hz => False.elim hz, ?_⟩
  intro h
  obtain ⟨_,_,never⟩ := h 0 (Nat.le_refl _) () rfl
  exact never

theorem strict_future_cannot_discharge_current :
    let live : Nat → Rel Unit := fun i _ => i = 0
    let later := fun i (x : Unit) => futureEventually (fun j => live j x) (i+1)
    futureAlways (fun i => qAll (difference (live i) (live i)) (later i)) 0 ∧
      ¬ futureAlways (fun i => qAll (live i) (later i)) 0 := by
  dsimp only
  refine ⟨fun _ _ _ hx => False.elim (hx.2 hx.1), ?_⟩
  intro h
  obtain ⟨j,hj,e⟩ := h 0 (Nat.le_refl _) () rfl
  change j = 0 at e
  omega

theorem different_atom_does_not_discharge :
    let d : Rel Bool := univRel
    let s : Nat → Rel Bool := fun _ x => x = true
    qAll d (fun _ => futureEventually (fun j => relNonempty (s j)) 0) ∧
      ¬ qAll d (fun x => futureEventually (fun j => s j x) 0) :=
  ⟨fun _ _ => ⟨0,Nat.le_refl _,true,rfl⟩, fun h => Bool.noConfusion ((h false trivial).choose_spec.2)⟩

-- A different future witness is allowed for each initially bound atom.
def eachEventually (D S : Nat → Rel α) (t : Nat) : Prop :=
  qAll (D t) (fun x => futureEventually (fun j => S j x) t)

theorem delayed_universal_eventual (D S : Nat → Rel α) (t : Nat)
    (retain : ∀ i, t ≤ i → subset (D t) (D i)) :
    futureEventually (eachEventually D S) t ↔ eachEventually D S t := by
  constructor
  · rintro ⟨i, hi, h⟩ x hx
    obtain ⟨j, hj, hxj⟩ := h x (retain i hi x hx)
    exact ⟨j, Nat.le_trans hi hj, hxj⟩
  · exact fun h => ⟨t, Nat.le_refl _, h⟩

theorem retention_iff_delay_for_all_bodies (D : Nat → Rel α) (t : Nat) :
    (∀ i, t ≤ i → subset (D t) (D i)) ↔
      ∀ S, futureEventually (eachEventually D S) t ↔ eachEventually D S t := by
  refine ⟨fun h S => delayed_universal_eventual D S t h, ?_⟩
  intro h i hi x hx
  apply Classical.byContradiction
  intro lost
  let S : Nat → Rel α := fun _ y => y ≠ x
  have delayed : futureEventually (eachEventually D S) t := by
    refine ⟨i, hi, fun y hy => ⟨i, Nat.le_refl _, ?_⟩⟩
    exact fun e => lost (e ▸ hy)
  obtain ⟨_, _, never⟩ := (h S).mp delayed x hx
  exact never rfl

theorem static_signature_read (D : Nat → Rel α) (stable : ∀ i, D i = D 0) (i : Nat) (x : α) :
    D i x ↔ D 0 x := by rw [stable i]

theorem static_delayed_universal (D : Rel α) (S : Nat → Rel α) (t : Nat) :
    futureEventually (eachEventually (fun _ => D) S) t ↔ eachEventually (fun _ => D) S t :=
  delayed_universal_eventual _ _ _ (fun _ _ _ hx => hx)

-- v10 allowed this shrinking interpretation even for the top-level static Signal.
theorem shrinking_domain_disproves_delay :
    let D : Nat → Rel Unit := fun i _ => i = 0
    let S : Nat → Rel Unit := fun _ => noneRel
    futureEventually (eachEventually D S) 0 ∧ ¬ eachEventually D S 0 := by
  dsimp only
  exact ⟨⟨1, by decide, fun _ h => False.elim ((by decide : 1 ≠ 0) h)⟩,
    fun h => (h () rfl).choose_spec.2⟩

theorem station_delayed_distinct_times :
    let signal : Nat → Rel Bool := fun _ => univRel
    let green : Nat → Rel Bool := fun j x => j = (if x then 1 else 0)
    (∀ i, subset (green i) (signal i)) ∧
      futureEventually (eachEventually signal green) 0 ∧
      eachEventually signal green 0 ∧
      ¬ futureEventually (fun j => qAll (signal j) (green j)) 0 := by
  intro signal green
  have h : eachEventually signal green 0 :=
    fun x _ => ⟨if x then 1 else 0, Nat.zero_le _, rfl⟩
  refine ⟨fun _ _ _ => trivial, (static_delayed_universal _ _ _).mpr h, h, ?_⟩
  rintro ⟨j, _, allGreen⟩
  exact (by decide : 0 ≠ 1) ((allGreen false trivial).symm.trans (allGreen true trivial))

theorem singleton_membership_read (x : α) (R : Rel α) :
    subset (singletonRel x) R ↔ R x :=
  ⟨fun h => h x rfl, fun h _ hy => hy ▸ h⟩

theorem singleton_negative_difference_reads (x : α) (D S : Rel α) :
    (¬ subset (singletonRel x) S ↔ ¬ S x) ∧
      (subset (singletonRel x) (difference D S) ↔ D x ∧ ¬ S x) :=
  ⟨not_congr (singleton_membership_read _ _), singleton_membership_read _ _⟩

def recurringBoth (D : Rel α) (S : Nat → Rel α) (t : Nat) :=
  qAll D (fun x => futureAlways (futureEventually (fun j => S j x)) t ∧
                     futureAlways (futureEventually (fun j => ¬ S j x)) t)

def colorResponses (D S : Nat → Rel α) (t : Nat) :=
  futureAlways (fun i => qAll (D i) (fun x =>
    (S i x → futureEventually (fun j => ¬ S j x) i) ∧
    (¬ S i x → futureEventually (fun j => S j x) i))) t

def partitionResponses (D S : Nat → Rel α) (t : Nat) :=
  futureAlways (fun i => qAll (difference (D i) (S i)) (fun x => futureEventually (fun j => S j x) i)) t ∧
  futureAlways (fun i => qAll (S i) (fun x => futureEventually (fun j => difference (D j) (S j) x) i)) t

theorem current_or_response (P : Nat → Prop) (i : Nat) :
    ((P i → futureEventually (fun j => ¬ P j) i) ∧ (¬ P i → futureEventually P i)) ↔
    futureEventually P i ∧ futureEventually (fun j => ¬ P j) i := by
  constructor
  · intro h
    by_cases hp : P i
    · exact ⟨⟨i, Nat.le_refl _, hp⟩, h.1 hp⟩
    · exact ⟨h.2 hp, ⟨i, Nat.le_refl _, hp⟩⟩
  · exact fun h => ⟨fun _ => h.2, fun _ => h.1⟩

theorem responses_iff_recurring (D : Rel α) (S : Nat → Rel α) (t : Nat) :
    colorResponses (fun _ => D) S t ↔ recurringBoth D S t := by
  constructor
  · intro h x hx
    have both := (static_all_commutes_with_always D _ t).mpr h x hx
    exact ⟨fun i hi => ((current_or_response _ i).mp (both i hi)).1,
           fun i hi => ((current_or_response _ i).mp (both i hi)).2⟩
  · intro h i hi x hx
    exact (current_or_response _ i).mpr ⟨(h x hx).1 i hi, (h x hx).2 i hi⟩

theorem partition_iff_recurring (D : Rel α) (S : Nat → Rel α) (t : Nat)
    (typed : ∀ i, subset (S i) D) :
    partitionResponses (fun _ => D) S t ↔ recurringBoth D S t := by
  constructor
  · intro h x hx
    refine ⟨fun i hi => (eventual_current_domain (fun _ => D) S i).mp (h.1 i hi) x hx, ?_⟩
    intro i hi
    by_cases green : S i x
    · obtain ⟨j, hj, _, noGreen⟩ := h.2 i hi x green
      exact ⟨j, hj, noGreen⟩
    · exact ⟨i, Nat.le_refl _, green⟩
  · intro h
    refine ⟨fun i hi x hx => (h x hx.1).1 i hi, ?_⟩
    intro i hi x green
    have hx := typed i x green
    obtain ⟨j, hj, noGreen⟩ := (h x hx).2 i hi
    exact ⟨j, hj, hx, noGreen⟩

theorem recurring_growing_domain_counterexample :
    let d : Nat → Rel Unit := fun i _ => i > 0
    let s : Nat → Rel Unit := fun _ => noneRel
    recurringBoth (d 0) s 0 ∧ ¬ colorResponses d s 0 ∧ ¬ partitionResponses d s 0 := by
  dsimp only
  refine ⟨fun _ h => False.elim ((Nat.lt_irrefl _) h), ?_, ?_⟩
  · intro h
    exact ((h 1 (by decide) () (by decide)).2 (fun n => n)).choose_spec.2
  · intro h
    exact (h.1 1 (by decide) () ⟨by decide, fun n => n⟩).choose_spec.2

theorem alternating_signal_instance :
    let s : Nat → Rel Bool := fun j x => j % 2 = (if x then 1 else 0)
    recurringBoth univRel s 0 ∧ colorResponses (fun _ => univRel) s 0 ∧
      partitionResponses (fun _ => univRel) s 0 ∧
      ¬ futureEventually (fun i => qAll univRel (s i)) 0 := by
  intro s
  have h : recurringBoth univRel s 0 := by
    intro x _
    constructor <;> intro i _
    · refine ⟨2*i+(if x then 1 else 0), ?_, ?_⟩ <;> cases x <;> simp [s] <;> omega
    · refine ⟨2*i+(if x then 0 else 1), ?_, ?_⟩ <;> cases x <;> simp [s] <;> omega
  refine ⟨h, (responses_iff_recurring _ _ _).mpr h,
    (partition_iff_recurring _ _ _ (fun _ _ _ => trivial)).mpr h, ?_⟩
  rintro ⟨_, _, allGreen⟩
  exact (by decide : 0 ≠ 1) ((allGreen false trivial).symm.trans (allGreen true trivial))

end AdaptivePhaseAlgebra
