import AdaptiveCardinality

namespace AdaptiveCountingFiber
open AdaptiveCardinality AdaptiveVisibleDiagonal

-- Enumerate the varying coordinate only. Fixing a column does not
-- multiply the count by the number of possible values of that column.
def fiber (carrier : List α) (hit : α → Bool) := carrier.filter hit

def fixedColumn (carrier : List α) (hit : α → Bool) (c : β) :=
  (fiber carrier hit).map (fun u => (u,c))

theorem column_source (carrier : List α) (hit : α → Bool) (c v : β) (u : α) :
    (u,v) ∈ fixedColumn carrier hit c ↔ u ∈ carrier ∧ hit u = true ∧ v = c := by
  simp [fixedColumn, fiber, List.mem_map, List.mem_filter] <;> grind

theorem column_nodup (carrier : List α) (hit : α → Bool) (c : β) (hu : carrier.Nodup) :
    (fixedColumn carrier hit c).Nodup := by
  exact List.Pairwise.map (fun u => (u,c))
    (fun _ _ ne h => ne (congrArg Prod.fst h)) (List.Pairwise.filter hit hu)

theorem column_count (carrier : List α) (hit : α → Bool) (c : β) :
    (fixedColumn carrier hit c).length = (fiber carrier hit).length := List.length_map _

-- The comprehension (eligible -> c) & edge and the unary projection
-- eligible & edge.c read the same owners, including a subset signature.
theorem restricted_column (carrier : List α) (eligible : α → Bool) (edge : α → β → Bool)
    (c v : β) (u : α) :
    (u,v) ∈ fixedColumn carrier (fun x => eligible x && edge x c) c ↔
      u ∈ carrier ∧ eligible u = true ∧ v = c ∧ edge u v = true := by
  rw [column_source, Bool.and_eq_true]
  grind

theorem restricted_column_orders (carrier : List α) (eligible : α → Bool) (edge : α → β → Bool)
    (c v : β) (u : α) :
    ((u,v) ∈ fixedColumn carrier (fun x => eligible x && edge x c) c ↔
      edge u v = true ∧ (u ∈ carrier ∧ eligible u = true ∧ v = c)) ∧
    (u ∈ fiber carrier (fun x => eligible x && edge x c) ↔
      edge u c = true ∧ (u ∈ carrier ∧ eligible u = true)) := by
  rw [restricted_column]
  simp only [fiber, List.mem_filter, Bool.and_eq_true]
  grind

-- Equal counts may be transported under a literal comparison even when
-- the integer wraps. Interpreting that comparison as multiplicity may not.
theorem column_machine (carrier : List α) (hit : α → Bool) (c : β)
    (op : OrderOp) (w : Nat) (k : Int) :
    op.test (BitVec.ofNat w (fixedColumn carrier hit c).length).toInt (BitVec.ofInt w k).toInt ↔
      op.test (BitVec.ofNat w (fiber carrier hit).length).toInt (BitVec.ofInt w k).toInt := by
  rw [column_count]

theorem fiber_cap (carrier : List α) (hit : α → Bool) :
    (fiber carrier hit).length ≤ carrier.length := List.length_filter_le ..

-- Both literal orientations and all six comparisons reuse the signed
-- threshold theorem. A cap on the *other* coordinate would be unsound.
theorem column_threshold (carrier : List α) (hit : α → Bool) (c : β)
    (op : OrderOp) (left : Bool) (w : Nat) (k : Int)
    (width : 0 < w) (safe : 2*carrier.length < 2^w)
    (lo : -2^(w-1) ≤ k) (hi : k < 2^(w-1)) :
    (let n := (BitVec.ofNat w (fixedColumn carrier hit c).length).toInt
     let lit := (BitVec.ofInt w k).toInt
     if left then op.test lit n else op.test n lit) ↔
      (normalize op left k).op.test ((fiber carrier hit).length : Int) k := by
  rw [column_count]
  exact normalized_read op left w _ carrier.length k width (fiber_cap ..) safe lo hi

theorem row_positive (carrier : List α) (hit : α → Bool) (hu : carrier.Nodup)
    (w : Nat) (wide : 2 < 2^w) (safe : 2*carrier.length < 2^w) :
    0 < (BitVec.ofNat w (fiber carrier hit).length).toInt ↔
      someOf (fun u => u ∈ carrier ∧ hit u = true) := by
  exact rewrite_iff .gtZero w carrier.length wide _ (fiber carrier hit) (List.Pairwise.filter hit hu)
    (fun _ => List.mem_filter) (fiber_cap ..) safe

theorem row_lt_two (carrier : List α) (hit : α → Bool) (hu : carrier.Nodup)
    (w : Nat) (twoFits : 4 < 2^w) (safe : 2*carrier.length < 2^w) :
    (BitVec.ofNat w (fiber carrier hit).length).toInt < (BitVec.ofNat w 2).toInt ↔
      loneOf (fun u => u ∈ carrier ∧ hit u = true) := by
  have lengthBound := fiber_cap carrier hit
  rw [signed_exact _ _ (by omega), signed_exact _ 2 (by omega)]
  have lone := length_lone_iff (fiber carrier hit) (List.Pairwise.filter hit hu)
  simp only [fiber, List.mem_filter] at lone
  change ((carrier.filter hit).length : Int) < 2 ↔ _
  exact (by omega : ((carrier.filter hit).length : Int) < 2 ↔ (carrier.filter hit).length ≤ 1) |>.trans lone

theorem column_lt_two (carrier : List α) (hit : α → Bool) (c : β) (hu : carrier.Nodup)
    (w : Nat) (twoFits : 4 < 2^w) (safe : 2*carrier.length < 2^w) :
    (BitVec.ofNat w (fixedColumn carrier hit c).length).toInt < (BitVec.ofNat w 2).toInt ↔
      loneOf (fun u => u ∈ carrier ∧ hit u = true) := by
  rw [column_count]
  exact row_lt_two carrier hit hu w twoFits safe

theorem quantified_column (classes : Rel β) (people : List α) (hu : people.Nodup)
    (allPeople : ∀ u, u ∈ people) (teacher : α → Bool) (teaches : α → β → Bool)
    (w : Nat) (twoFits : 4 < 2^w) (safe : 2*people.length < 2^w) :
    qAll classes (fun c => (BitVec.ofNat w
      (fixedColumn people (fun t => teacher t && teaches t c) c).length).toInt <
        (BitVec.ofNat w 2).toInt) ↔
      qAll classes (fun c => loneOf (fun t => teacher t = true ∧ teaches t c = true)) := by
  have point (c : β) := column_lt_two people (fun t => teacher t && teaches t c) c hu w twoFits safe
  simp only [allPeople, true_and, Bool.and_eq_true] at point
  exact ⟨fun h c hc => (point c).mp (h c hc), fun h c hc => (point c).mpr (h c hc)⟩

theorem width_and_literal_controls :
    let n := (fixedColumn (List.range 8) (fun _ => true) ()).length
    (BitVec.ofNat 4 n).toInt = -8 ∧ (BitVec.ofNat 5 n).toInt = 8 ∧
    ¬(0 < (BitVec.ofNat 4 n).toInt) ∧
    (BitVec.ofNat 4 n).toInt < 2 ∧ ¬((BitVec.ofNat 5 n).toInt < 2) ∧
    ¬((BitVec.ofNat 4 2).toInt < 2) ∧ (BitVec.ofNat 4 2).toInt < 3 := by decide

-- One fixed target admits eight distinct incident tuples. Even an exact
-- cap of one on targets cannot justify dropping the width guard on owners.
theorem wrong_coordinate_witness :
    let owners := List.range 8
    let n := (fixedColumn owners (fun _ => true) ()).length
    someOf (fun x => x ∈ owners) ∧ ¬loneOf (fun x => x ∈ owners) ∧
    ¬counted .gtZero 4 n ∧ counted .leOne 4 n := by
  intro owners n
  exact ⟨⟨0,by decide⟩, fun h => (by decide : ¬ (List.range 8).length ≤ 1)
    ((length_lone_iff owners List.nodup_range).mpr h), by unfold counted; decide,
      by unfold counted; decide⟩

def multiplicityKey : Comparison → Threshold
  | .eqZero => ⟨.eq, 0⟩ | .eqOne => ⟨.eq, 1⟩
  | .leOne => ⟨.le, 1⟩ | .gtZero => ⟨.ge, 1⟩

theorem key_meaning (kind : Comparison) (w n : Nat) (wide : 2 < 2^w) :
    (multiplicityKey kind).op.test (BitVec.ofNat w n).toInt
      (BitVec.ofInt w (multiplicityKey kind).literal).toInt ↔ counted kind w n := by
  cases kind
  case eqZero => exact BitVec.toInt_inj
  case eqOne => exact BitVec.toInt_inj
  case leOne => rfl
  case gtZero =>
    change (BitVec.ofNat w 1).toInt ≤ _ ↔ 0 < _
    rw [signed_exact w 1 (by omega)]
    omega

-- The reported scope can exceed the population in a particular instance.
-- Keep that inequality explicit; it is not an equality with a sample count.
theorem scoped_fiber_test (column left : Bool) (op : OrderOp) (k : Int)
    (kind : Comparison) (w cap : Nat) (bound : List α) (hit : α → Bool)
    (c : β) (hu : bound.Nodup) (size : bound.length ≤ cap) (guard : safeAt kind w cap)
    (width : 0 < w) (wide : 2 < 2^w) (lo : -2^(w-1) ≤ k) (hi : k < 2^(w-1))
    (key : inclusiveBound w (normalize op left k) = multiplicityKey kind) :
    (let n := if column then (fixedColumn bound hit c).length else (fiber bound hit).length
     let count := (BitVec.ofNat w n).toInt
     let literal := (BitVec.ofInt w k).toInt
     if left then op.test literal count else op.test count literal) ↔
      multiplicity kind (fun x => x ∈ bound ∧ hit x = true) := by
  simp only [column_count, ite_self]
  have orientation := inclusive_machine_read op left w (fiber bound hit).length k width lo hi
  dsimp only at orientation
  rw [orientation, key, key_meaning _ _ _ wide]
  exact rewrite_iff kind w cap wide _ (fiber bound hit) (List.Pairwise.filter hit hu)
    (fun _ => List.mem_filter) (Nat.le_trans (fiber_cap ..) size) guard

-- A nominal cap of one would accept the rewrite. With an actual cap of
-- eight the same source has a concrete nonempty but signed-negative row.
theorem raised_scope_control :
    safeAt .gtZero 4 1 ∧ ¬safeAt .gtZero 4 8 ∧
    someOf (fun x => x ∈ List.range 8) ∧ ¬counted .gtZero 4 (List.range 8).length := by
  exact ⟨by unfold safeAt; decide, by unfold safeAt; decide,
    wrong_coordinate_witness.1, wrong_coordinate_witness.2.2.1⟩

-- Both endpoints re-evaluate the binder domain and the varying coordinate
-- at the same time. Nothing is moved outside its original temporal frame.
theorem scoped_frames (fs : List AdaptivePhaseAlgebra.TimeFrame) (D : Nat → Rel β)
    (column left : Bool) (op : OrderOp) (k : Int) (kind : Comparison) (w cap : Nat)
    (carrier : Nat → List α) (hit : Nat → β → α → Bool)
    (hu : ∀ i, (carrier i).Nodup) (size : ∀ i, (carrier i).length ≤ cap)
    (guard : safeAt kind w cap) (width : 0 < w) (wide : 2 < 2^w)
    (lo : -2^(w-1) ≤ k) (hi : k < 2^(w-1))
    (key : inclusiveBound w (normalize op left k) = multiplicityKey kind) (t : Nat) :
    AdaptivePhaseAlgebra.inFrames fs (fun i => qAll (D i) (fun c =>
      let n := if column then (fixedColumn (carrier i) (hit i c) c).length
               else (fiber (carrier i) (hit i c)).length
      let a := (BitVec.ofNat w n).toInt
      let b := (BitVec.ofInt w k).toInt
      if left then op.test b a else op.test a b)) t ↔
    AdaptivePhaseAlgebra.inFrames fs (fun i => qAll (D i) (fun c =>
      multiplicity kind (fun x => x ∈ carrier i ∧ hit i c x = true))) t := by
  apply Iff.of_eq
  congr 2
  funext i
  apply propext
  have point (c : β) := scoped_fiber_test column left op k kind w cap (carrier i)
    (hit i c) c (hu i) (size i) guard width wide lo hi key
  exact ⟨fun h c hc => (point c).mp (h c hc), fun h c hc => (point c).mpr (h c hc)⟩

-- A transpose switches the side of the join as well as the field's
-- coordinate. This is equality of tuple counts, including after wrapping.
theorem converse_column_count (f : BinaryRel α β) (p : β) (back direct : List α)
    (ub : back.Nodup) (ud : direct.Nodup)
    (rb : ∀ x, x ∈ back ↔ unaryLeftJoin (singletonRel p) (converseBinary f) x)
    (rd : ∀ x, x ∈ direct ↔ unaryRightJoin f (singletonRel p) x) :
    back.length = direct.length := by
  rw [AdaptiveUniquePreimage.backward_fiber] at rb
  exact same_relation_count back direct ub ud (fun x => (rb x).trans (rd x).symm)

theorem converse_row_read (f : BinaryRel α β) (p : α) :
    unaryRightJoin (converseBinary f) (singletonRel p) = unaryLeftJoin (singletonRel p) f := by
  simpa only [converse_binary_involutive] using
    (AdaptiveUniquePreimage.backward_fiber (converseBinary f) p).symm

end AdaptiveCountingFiber
