import AdaptiveOwnerFiber

namespace AdaptiveCardinality
open AdaptiveVisibleDiagonal

-- The bound is sharp for equality to one; counts up to the modulus,
-- not merely up to the largest signed integer, are sufficient.
theorem sharp_residue (modulus k cap : Nat) (fits : k < modulus) :
    (∀ n ≤ cap, (n % modulus = k ↔ n = k)) ↔ cap < modulus+k := by
  constructor
  · intro all
    apply Decidable.byContradiction
    intro h
    have collision := (all (modulus + k) (by omega)).mp
    have bad := collision (by simp [Nat.mod_eq_of_lt fits])
    omega
  · intro bound n within
    by_cases small : n < modulus
    · rw [Nat.mod_eq_of_lt small]
    · rw [Nat.mod_eq_sub_mod (by omega : modulus ≤ n),Nat.mod_eq_of_lt (by omega : n-modulus < modulus)]
      omega

theorem sharp_bound (modulus cap : Nat) (wide : 1 < modulus) :
    (∀ n ≤ cap, (n % modulus = 1 ↔ n = 1)) ↔ cap ≤ modulus := by
  rw [sharp_residue modulus 1 cap wide]
  omega

theorem bit_one (w n : Nat) (wide : 1 < 2^w) :
    BitVec.ofNat w n = BitVec.ofNat w 1 ↔ n % 2^w = 1 := by
  constructor
  · intro h
    simpa only [BitVec.toNat_ofNat, Nat.mod_eq_of_lt wide] using congrArg BitVec.toNat h
  · intro h
    apply BitVec.eq_of_toNat_eq
    simpa only [BitVec.toNat_ofNat, Nat.mod_eq_of_lt wide] using h

theorem length_one_iff (xs : List α) (unique : xs.Nodup) :
    xs.length = 1 ↔ oneOf (fun x => x ∈ xs) := by
  cases xs with
  | nil => simp [oneOf, exactlyOne, relNonempty]
  | cons a rest =>
    cases rest with
    | nil => simp [oneOf, exactlyOne, relNonempty, atMostOne]
    | cons b tail =>
      have neq : a ≠ b := fun h => (List.nodup_cons.mp unique).1 (by simp [h])
      constructor
      · simp
      · intro one
        exact False.elim (neq (one.2 a b (by simp) (by simp)))

-- The list is a faithful enumeration of the actual field column at this
-- state, not a claim that arbitrary set cardinality fits the bit width.
theorem bounded_source (w : Nat) (wide : 1 < 2^w)
    (target : Rel β) (edges : BinaryRel α β) (owners : β → List α)
    (unique : ∀ p, target p → (owners p).Nodup)
    (faithful : ∀ p, target p → ∀ u, u ∈ owners p ↔ edges u p)
    (bounded : ∀ p, target p → (owners p).length ≤ 2^w) :
    qAll target (fun p => BitVec.ofNat w (owners p).length = BitVec.ofNat w 1) ↔
      AdaptiveOwnerFiber.columnSpec target edges := by
  unfold AdaptiveOwnerFiber.columnSpec qAll
  simp only [AdaptiveOwnerFiber.column_at]
  have point (p) (hp : target p) :
      (BitVec.ofNat w (owners p).length = BitVec.ofNat w 1) ↔ oneOf (fun u => edges u p) := by
    have same : (fun u => u ∈ owners p) = (fun u => edges u p) :=
      funext (fun u => propext (faithful p hp u))
    rw [bit_one w _ wide, ((sharp_bound _ _ wide).mpr (Nat.le_refl _)) _ (bounded p hp),
      length_one_iff _ (unique p hp), same]
  exact ⟨fun h p hp => (point p hp).mp (h p hp),fun h p hp => (point p hp).mpr (h p hp)⟩

theorem four_bit_witness :
    let xs := List.range 17
    xs.Nodup ∧ BitVec.ofNat 4 xs.length = BitVec.ofNat 4 1 ∧ ¬oneOf (fun u => u ∈ xs) := by
  intro xs
  have hu : xs.Nodup := List.nodup_range
  exact ⟨hu,by decide,fun h => (by decide : (List.range 17).length ≠ 1) ((length_one_iff xs hu).mpr h)⟩

theorem duplicate_counterexample :
    let xs := [true,true]
    oneOf (fun u => u ∈ xs) ∧ BitVec.ofNat 4 xs.length ≠ BitVec.ofNat 4 1 := by
  intro xs
  exact ⟨by simp [xs,oneOf,exactlyOne,relNonempty,atMostOne],by decide⟩
inductive Comparison where
  | eqZero | leOne | gtZero | eqOne
  deriving DecidableEq, Repr

-- The cap is a bound on the number of distinct tuples of X, not a
-- per-signature scope or a bound inferred from sampled models.
def safeAt (op : Comparison) (w cap : Nat) : Prop :=
  match op with
  | .eqZero => cap < 2^w
  | .leOne | .gtZero => 2*cap < 2^w
  | .eqOne => cap ≤ 2^w

def counted (op : Comparison) (w n : Nat) : Prop :=
  match op with
  | .eqZero => BitVec.ofNat w n = BitVec.ofNat w 0
  | .leOne => (BitVec.ofNat w n).toInt ≤ (BitVec.ofNat w 1).toInt
  | .gtZero => 0 < (BitVec.ofNat w n).toInt
  | .eqOne => BitVec.ofNat w n = BitVec.ofNat w 1

def multiplicity (op : Comparison) (r : Rel α) : Prop :=
  match op with
  | .eqZero => noOf r
  | .leOne => loneOf r
  | .gtZero => someOf r
  | .eqOne => oneOf r

theorem length_lone_iff (xs : List α) (unique : xs.Nodup) :
    xs.length ≤ 1 ↔ loneOf (fun x => x ∈ xs) := by
  cases xs with
  | nil => simp [loneOf,atMostOne]
  | cons a rest =>
    cases rest with
    | nil => simp [loneOf,atMostOne]
    | cons b tail =>
      have neq : a ≠ b := fun h => (List.nodup_cons.mp unique).1 (by simp [h])
      constructor
      · simp
      · intro h
        exact False.elim (neq (h a b (by simp) (by simp)))

theorem signed_exact (w n : Nat) (h : 2*n < 2^w) :
    (BitVec.ofNat w n).toInt = (n : Int) := by
  have natVal : (BitVec.ofNat w n).toNat = n := Nat.mod_eq_of_lt (by omega)
  rw [BitVec.toInt_eq_toNat_of_lt (by rwa [natVal]), natVal]

-- Parameterize the literal and even the comparison, not its truth value.
-- Instantiating cmp with (<), (≤), (=), (≠), (≥), or (>) preserves
-- operand order. Bit-width, cap, and the actual signed literal stay bound.
theorem signed_threshold (cmp : Int → Int → Prop) (w n cap : Nat) (k : Int)
    (width : 0 < w) (bound : n ≤ cap) (safe : 2*cap < 2^w)
    (lo : -2^(w-1) ≤ k) (hi : k < 2^(w-1)) :
    cmp (BitVec.ofNat w n).toInt (BitVec.ofInt w k).toInt ↔ cmp (n : Int) k := by
  rw [signed_exact _ _ (by omega),BitVec.toInt_ofInt_eq_self width lo hi]

theorem exact_threshold (w n k cap : Nat) (fits : k < 2^w)
    (bound : n ≤ cap) (safe : cap < 2^w+k) :
    BitVec.ofNat w n = BitVec.ofNat w k ↔ n = k := by
  rw [← BitVec.toNat_inj,BitVec.toNat_ofNat,BitVec.toNat_ofNat,Nat.mod_eq_of_lt fits]
  exact ((sharp_residue _ _ _ fits).mpr safe) _ bound

inductive OrderOp where
  | eq | ne | lt | le | gt | ge
  deriving DecidableEq, Repr

def OrderOp.test : OrderOp → Int → Int → Prop
  | .eq => (· = ·) | .ne => (· ≠ ·) | .lt => (· < ·)
  | .le => (· ≤ ·) | .gt => (· > ·) | .ge => (· ≥ ·)

def OrderOp.swap : OrderOp → OrderOp
  | .eq => .eq | .ne => .ne | .lt => .gt
  | .le => .ge | .gt => .lt | .ge => .le

theorem swap_iff (op : OrderOp) (a b : Int) : op.test a b ↔ op.swap.test b a := by
  cases op <;> simp [OrderOp.test, OrderOp.swap, eq_comm]

def OrderOp.complement : OrderOp → OrderOp
  | .eq => .ne | .ne => .eq | .lt => .ge
  | .le => .gt | .gt => .le | .ge => .lt

theorem complement_iff (op : OrderOp) (a b : Int) :
    (¬ op.test a b) ↔ op.complement.test a b := by
  cases op <;> simp [OrderOp.test, OrderOp.complement]

structure Threshold where
  op : OrderOp
  literal : Int
  deriving Repr, DecidableEq

-- Only move the literal to the right; it remains part of the key.
def normalize (op : OrderOp) (literalFirst : Bool) (k : Int) : Threshold :=
  ⟨if literalFirst then op.swap else op, k⟩

-- Orientation alone preserves machine semantics even when the count wraps.
theorem normalized_machine_read (op : OrderOp) (literalFirst : Bool) (w n : Nat) (k : Int) :
    (let count := (BitVec.ofNat w n).toInt
     let lit := (BitVec.ofInt w k).toInt
     if literalFirst then op.test lit count else op.test count lit) ↔
      (normalize op literalFirst k).op.test (BitVec.ofNat w n).toInt
        (BitVec.ofInt w (normalize op literalFirst k).literal).toInt := by
  cases literalFirst
  · rfl
  · exact swap_iff op _ _

theorem normalized_read (op : OrderOp) (literalFirst : Bool) (w n cap : Nat) (k : Int)
    (width : 0 < w) (bound : n ≤ cap) (safe : 2*cap < 2^w)
    (lo : -2^(w-1) ≤ k) (hi : k < 2^(w-1)) :
    (let count := (BitVec.ofNat w n).toInt
     let lit := (BitVec.ofInt w k).toInt
     if literalFirst then op.test lit count else op.test count lit) ↔
      (normalize op literalFirst k).op.test (n : Int) (normalize op literalFirst k).literal := by
  rw [signed_exact _ _ (by omega),BitVec.toInt_ofInt_eq_self width lo hi]
  cases literalFirst
  · rfl
  · exact swap_iff op _ _

theorem thresholds_distinct (op : OrderOp) (left : Bool) (a b : Int) (h : a ≠ b) :
    normalize op left a ≠ normalize op left b := fun e => h (congrArg Threshold.literal e)

-- A declaration of an element binds a singleton, not its whole domain.
-- The integer literal stays a parameter of the comparison, not a hole.
theorem bound_atom_threshold (op : OrderOp) (left : Bool) (w : Nat) (k : Int)
    (xs : List α) (x : α) (unique : xs.Nodup) (read : ∀ y, y ∈ xs ↔ y = x)
    (width : 2 ≤ w) (lo : -2^(w-1) ≤ k) (hi : k < 2^(w-1)) :
    (let count := (BitVec.ofNat w xs.length).toInt
     let lit := (BitVec.ofInt w k).toInt
     if left then op.test lit count else op.test count lit) ↔
      (normalize op left k).op.test 1 k := by
  have same : (fun y => y ∈ xs) = singletonRel x := funext fun y => propext (read y)
  have size : xs.length = 1 := (length_one_iff xs unique).mpr (same ▸ singleton_exactly_one x)
  have four : 2^2 ≤ 2^w := Nat.pow_le_pow_right (by decide) width
  rw [size]
  exact normalized_read op left w 1 1 k (by omega) (by decide) (by omega) lo hi

theorem bound_atom_controls :
    (BitVec.ofNat 1 1).toInt = -1 ∧ (BitVec.ofNat 4 1).toInt = 1 ∧
      ¬ OrderOp.eq.test 1 0 ∧ OrderOp.eq.test 1 1 := by unfold OrderOp.test; decide

-- The adjustment is on the schema literal, not an Alloy addition in the source.
def inclusiveBound (w : Nat) (q : Threshold) : Threshold :=
  let half : Int := 2^(w-1)
  match q.op with
  | .gt => if q.literal < half-1 then ⟨.ge, q.literal+1⟩ else q
  | .lt => if -half < q.literal then ⟨.le, q.literal-1⟩ else q
  | _ => q

theorem inclusive_test (w : Nat) (q : Threshold) (observed : Int) :
    (inclusiveBound w q).op.test observed (inclusiveBound w q).literal ↔
      q.op.test observed q.literal := by
  rcases q with ⟨op, k⟩
  cases op <;> simp only [inclusiveBound] <;> first | rfl | split <;> simp [OrderOp.test] <;> omega

theorem inclusive_literal_fits (w : Nat) (q : Threshold)
    (lo : -((2 : Int)^(w-1)) ≤ q.literal) (hi : q.literal < (2 : Int)^(w-1)) :
    -((2 : Int)^(w-1)) ≤ (inclusiveBound w q).literal ∧
      (inclusiveBound w q).literal < (2 : Int)^(w-1) := by
  rcases q with ⟨op, k⟩
  cases op <;> simp only [inclusiveBound] <;> first | exact ⟨lo, hi⟩ | split <;> dsimp at * <;> omega

theorem inclusive_machine_read (op : OrderOp) (left : Bool) (w n : Nat) (k : Int)
    (width : 0 < w) (lo : -((2 : Int)^(w-1)) ≤ k) (hi : k < (2 : Int)^(w-1)) :
    let count := (BitVec.ofNat w n).toInt
    let literal := (BitVec.ofInt w k).toInt
    let key := inclusiveBound w (normalize op left k)
    (if left then op.test literal count else op.test count literal) ↔
      key.op.test count (BitVec.ofInt w key.literal).toInt := by
  dsimp only
  have fits := inclusive_literal_fits w (normalize op left k) lo hi
  rw [BitVec.toInt_ofInt_eq_self width fits.1 fits.2, inclusive_test,
      BitVec.toInt_ofInt_eq_self width lo hi]
  cases left
  · rfl
  · exact swap_iff op _ _

-- Negate the source comparison before converting a strict bound to an
-- inclusive one. Neither operation interprets the tuple count as unbounded.
theorem negated_inclusive_machine_read (op : OrderOp) (left : Bool) (w n : Nat) (k : Int)
    (width : 0 < w) (lo : -((2 : Int)^(w-1)) ≤ k) (hi : k < 2^(w-1)) :
    let count := (BitVec.ofNat w n).toInt
    let literal := (BitVec.ofInt w k).toInt
    let key := inclusiveBound w (normalize op.complement left k)
    (¬ (if left then op.test literal count else op.test count literal)) ↔
      key.op.test count (BitVec.ofInt w key.literal).toInt := by
  dsimp only
  refine Iff.trans ?_ (inclusive_machine_read op.complement left w n k width lo hi)
  cases left <;> exact complement_iff op _ _

theorem inclusive_controls :
    inclusiveBound 4 ⟨.gt, 2⟩ = inclusiveBound 4 ⟨.ge, 3⟩ ∧
    inclusiveBound 4 ⟨.gt, 2⟩ ≠ inclusiveBound 4 ⟨.gt, 3⟩ ∧
    inclusiveBound 4 ⟨.gt, 7⟩ = ⟨.gt, 7⟩ ∧ inclusiveBound 4 ⟨.lt, -8⟩ = ⟨.lt, -8⟩ := by decide

structure Interval where
  lo : Int
  hi : Int
  deriving DecidableEq, Repr

def Interval.holds (i : Interval) (x : Int) : Prop := i.lo ≤ x ∧ x ≤ i.hi

def Interval.meet (a b : Interval) : Interval := ⟨max a.lo b.lo, min a.hi b.hi⟩

theorem Interval.meet_iff (a b : Interval) (x : Int) :
    (a.meet b).holds x ↔ a.holds x ∧ b.holds x := by
  simp only [meet, holds, Int.max_le, Int.le_min]; omega

def machineDomain (w : Nat) : Interval := ⟨-2^(w-1), 2^(w-1)-1⟩

def Threshold.asInterval (w : Nat) (q : Threshold) : Option Interval :=
  match q.op with
  | .eq => some ⟨q.literal,q.literal⟩
  | .ge => some ⟨q.literal,(machineDomain w).hi⟩
  | .le => some ⟨(machineDomain w).lo,q.literal⟩
  | _ => none

theorem interval_leaf (w : Nat) (q : Threshold) (i : Interval) (x : Int)
    (dom : (machineDomain w).holds x) (read : q.asInterval w = some i) :
    i.holds x ↔ q.op.test x q.literal := by
  rcases q with ⟨op,k⟩
  cases op <;> simp [Threshold.asInterval] at read <;> subst i <;>
    simp [Interval.holds, OrderOp.test] at * <;> omega

-- Single reading shared by all leaves, at the same state and binder valuation.
theorem meet_machine (w n : Nat) (bounds : List Interval) :
    let x := (BitVec.ofNat w n).toInt
    (bounds.foldl Interval.meet (machineDomain w)).holds x ↔ ∀ i ∈ bounds, i.holds x := by
  intro x
  have fold (start : Interval) (bs : List Interval) :
      (bs.foldl Interval.meet start).holds x ↔ start.holds x ∧ ∀ i ∈ bs, i.holds x := by
    induction bs generalizing start with
    | nil => simp
    | cons a rest ih =>
      simp only [List.foldl_cons, ih, Interval.meet_iff, List.mem_cons, forall_eq_or_imp]
      grind
  have dom : (machineDomain w).holds x := ⟨BitVec.le_toInt _, by
    have := BitVec.toInt_lt (x := BitVec.ofNat w n); dsimp [x, machineDomain]; omega⟩
  simp [fold, dom]

theorem singleton_interval (k x : Int) : (Interval.mk k k).holds x ↔ x = k := by
  change (k ≤ x ∧ x ≤ k) ↔ x = k; omega

-- With the explicit lower bound, negative machine readings cannot pass.
-- The first new small nonnegative reading occurs at the full modulus.
theorem prefix_interval (w n k : Nat) (fits : 2*k < 2^w) (bound : n < 2^w) :
    (Interval.mk 0 k).holds (BitVec.ofNat w n).toInt ↔ n ≤ k := by
  have natVal : (BitVec.ofNat w n).toNat = n := Nat.mod_eq_of_lt bound
  change (0 ≤ _ ∧ _ ≤ (k : Int)) ↔ _
  simp only [BitVec.toInt_eq_toNat_cond, natVal]
  split <;> omega

theorem prefix_bound_sharp (w k cap : Nat) (fits : 2*k < 2^w) :
    (∀ n ≤ cap, ((Interval.mk 0 k).holds (BitVec.ofNat w n).toInt ↔ n ≤ k)) ↔ cap < 2^w := by
  constructor
  · intro all
    apply Decidable.byContradiction; intro h
    have wrap : (BitVec.ofNat w (2^w)).toInt = 0 := by
      simp [BitVec.toInt_eq_toNat_cond]
    have atWrap := all (2^w) (by omega)
    rw [wrap] at atWrap
    have bad := atWrap.mp (by simp [Interval.holds])
    omega
  · intro h n hn; exact prefix_interval w n k fits (by omega)

theorem row_interval_lone (w : Nat) (wide : 2 < 2^w) (row : Rel α) (xs : List α)
    (unique : xs.Nodup) (read : ∀ x, x ∈ xs ↔ row x) (bound : xs.length < 2^w) :
    (Interval.mk 0 1).holds (BitVec.ofNat w xs.length).toInt ↔ loneOf row := by
  have same : row = fun x => x ∈ xs := funext fun x => propext (read x).symm
  rw [same]
  exact (prefix_interval w xs.length 1 (by omega) bound).trans (length_lone_iff xs unique)

theorem classroom_interval_instance :
    let posts : Nat → Nat → Prop := fun t c => t = 0 ∧ c < 8
    let row := List.range 8
    ((Interval.mk 0 1).holds (BitVec.ofNat 4 row.length).toInt ↔ loneOf (posts 0)) ∧
      counted .leOne 4 row.length ∧ ¬loneOf (posts 0) := by
  intro posts row
  refine ⟨row_interval_lone 4 (by decide) _ row List.nodup_range (by simp [posts,row]) (by decide),
    by unfold counted; decide, ?_⟩
  intro lone
  exact (by decide : (0 : Nat) ≠ 1) (lone 0 1 (by decide) (by decide))

theorem classroom_rows (w : Nat) (wide : 2 < 2^w) (teacher : Rel α) (teaches : BinaryRel α β)
    (classes : α → List β) (unique : ∀ t, teacher t → (classes t).Nodup)
    (read : ∀ t, teacher t → ∀ c, c ∈ classes t ↔ teaches t c)
    (bounded : ∀ t, teacher t → (classes t).length < 2^w) :
    qAll teacher (fun t => (Interval.mk 0 1).holds (BitVec.ofNat w (classes t).length).toInt) ↔
      qAll teacher (fun t => loneOf (teaches t)) := by
  have each t ht := row_interval_lone w wide (teaches t) (classes t) (unique t ht) (read t ht) (bounded t ht)
  exact ⟨fun h t ht => (each t ht).mp (h t ht), fun h t ht => (each t ht).mpr (h t ht)⟩

-- Counting Teacher -> c for one c does not restrict the product to teaching edges.
theorem classroom_product_control :
    let teachers := [(false, ()), (true, ())]
    let count := (BitVec.ofNat 4 teachers.length).toInt
    ((0 < count ∧ count < 2) ↔ count = 1) ∧ count ≠ 1 ∧
      loneOf (fun t : Bool => t = false) := by
  intro teachers count
  exact ⟨by omega, by decide, fun a b ha hb => ha.trans hb.symm⟩

theorem strict_pair_machine (w n : Nat) (k : Int) :
    let x := (BitVec.ofNat w n).toInt
    (k-1 < x ∧ x < k+1) ↔ x = k := by intro x; omega

theorem moving_operand_control :
    let now := (BitVec.ofNat 4 3).toInt
    let later := (BitVec.ofNat 4 2).toInt
    2 ≤ now ∧ later ≤ 2 ∧ now ≠ 2 := by decide

theorem same_relation_count (a b : List α) (ua : a.Nodup) (ub : b.Nodup)
    (read : ∀ x, x ∈ a ↔ x ∈ b) : a.length = b.length :=
  Nat.le_antisymm (ua.length_le_of_subset (fun x hx => (read x).mp hx))
    (ub.length_le_of_subset (fun x hx => (read x).mpr hx))

-- Works for sets of tuples of any arity, including the empty relation.
theorem rewrite_iff (op : Comparison) (w cap : Nat) (wide : 2 < 2^w)
    (r : Rel α) (xs : List α) (unique : xs.Nodup) (read : ∀ x, x ∈ xs ↔ r x)
    (bound : xs.length ≤ cap) (guard : safeAt op w cap) :
    counted op w xs.length ↔ multiplicity op r := by
  have same : r = fun x => x ∈ xs := funext (fun x => propext (read x).symm)
  subst r
  cases op with
  | eqZero =>
    change cap < 2^w at guard
    have hn : (BitVec.ofNat w xs.length).toNat = xs.length := Nat.mod_eq_of_lt (by omega)
    have hz : (BitVec.ofNat w 0).toNat = 0 := by simp
    change BitVec.ofNat w xs.length = BitVec.ofNat w 0 ↔ noOf _
    rw [← BitVec.toNat_inj,hn,hz]
    cases xs <;> simp [noOf,someOf]
  | leOne =>
    change 2*cap < 2^w at guard
    change (BitVec.ofNat w xs.length).toInt ≤ (BitVec.ofNat w 1).toInt ↔ loneOf _
    rw [signed_exact _ _ (by omega),signed_exact _ 1 (by omega), ← length_lone_iff _ unique]
    omega
  | gtZero =>
    change 2*cap < 2^w at guard
    change 0 < (BitVec.ofNat w xs.length).toInt ↔ someOf _
    rw [signed_exact _ _ (by omega)]
    cases xs <;> simp [someOf]
  | eqOne =>
    change cap ≤ 2^w at guard
    change BitVec.ofNat w xs.length = BitVec.ofNat w 1 ↔ oneOf _
    have oneFits : 1 < 2^w := by omega
    rw [bit_one _ _ oneFits, ((sharp_bound _ _ oneFits).mpr guard) _ bound,
      length_one_iff _ unique]

-- First failures at width four; a count of eight reads as minus eight.
theorem wrap_controls :
    counted .eqZero 4 16 ∧ counted .leOne 4 8 ∧
    ¬counted .gtZero 4 8 ∧ counted .eqOne 4 17 := by unfold counted; decide

theorem literal_controls :
    BitVec.ofNat 4 18 = BitVec.ofNat 4 2 ∧ (18 : Nat) ≠ 2 ∧
    (BitVec.ofNat 4 2).toInt > (BitVec.ofInt 4 (-1)).toInt ∧
    (BitVec.ofInt 4 8).toInt ≠ 8 ∧
    (BitVec.ofNat 4 2 = BitVec.ofNat 4 2) ∧ BitVec.ofNat 4 2 ≠ BitVec.ofNat 4 1 := by decide

end AdaptiveCardinality
