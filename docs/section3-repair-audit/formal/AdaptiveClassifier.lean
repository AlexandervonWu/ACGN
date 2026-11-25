import AdaptiveCountingFiber

namespace AdaptiveClassifier
open AdaptiveCardinality

def polarity (neg : Bool) (p : Prop) := if neg then ¬p else p
def classify (domain selected test : Rel α) := qAll domain (fun x => selected x ↔ test x)

theorem member_iff (neg : Bool) (s p : Prop) :
    (polarity neg s ↔ p) ↔ (s ↔ polarity neg p) := by
  cases neg
  · rfl
  · by_cases hs : s <;> by_cases hp : p <;> simp [polarity,hs,hp]

theorem comprehension (d s p : Rel α) (typed : subset s d) :
    (s = fun x => d x ∧ p x) ↔ classify d s p := by
  constructor
  · rintro rfl x hx
    exact ⟨And.right,fun hp => ⟨hx,hp⟩⟩
  · intro h; funext x; apply propext
    exact ⟨fun hs => ⟨typed x hs,(h x (typed x hs)).mp hs⟩,fun ⟨hd,hp⟩ => (h x hd).mpr hp⟩

theorem outside_domain :
    classify (fun _ : Unit => False) (fun _ => True) (fun _ => True) ∧
    (fun _ : Unit => True) ≠ (fun _ => False ∧ True) :=
  ⟨fun _ h => False.elim h,fun eq => (Eq.mp (congrFun eq ()) trivial).1⟩

def key (w : Nat) (neg : Bool) (q : Threshold) :=
  inclusiveBound w ⟨if neg then q.op.complement else q.op, q.literal⟩

theorem key_test (w : Nat) (neg : Bool) (q : Threshold) (v : Int) :
    polarity neg (q.op.test v q.literal) ↔ (key w neg q).op.test v (key w neg q).literal := by
  unfold key
  rw [inclusive_test]
  cases neg
  · rfl
  · exact complement_iff _ _ _

-- Like interpretations may compare their actual signed readings even when they
-- wrap; like tuple counts may instead instantiate v with the mathematical size.
theorem same_observation (d s : Rel α) (v : α → Int) (w : Nat)
    (n m : Bool) (a b : Threshold) (same : key w n a = key w m b) :
    classify d s (fun x => polarity n (a.op.test (v x) a.literal)) ↔
    classify d s (fun x => polarity m (b.op.test (v x) b.literal)) := by
  have point (x) : polarity n (a.op.test (v x) a.literal) ↔ polarity m (b.op.test (v x) b.literal) := by
    rw [key_test,key_test,same]
  exact ⟨fun h x hx => (h x hx).trans (point x),fun h x hx => (h x hx).trans (point x).symm⟩

theorem converse_column (d s : Rel β) (f : BinaryRel α β) (left right : β → List α)
    (w : Nat) (q : Threshold) (ub : ∀ p, (left p).Nodup) (ud : ∀ p, (right p).Nodup)
    (rb : ∀ p x, x ∈ left p ↔ unaryLeftJoin (singletonRel p) (converseBinary f) x)
    (rd : ∀ p x, x ∈ right p ↔ unaryRightJoin f (singletonRel p) x) :
    classify d s (fun x => q.op.test (BitVec.ofNat w (left x).length).toInt q.literal) ↔
    classify d s (fun x => q.op.test (BitVec.ofNat w (right x).length).toInt q.literal) := by
  have eq (p) := AdaptiveCountingFiber.converse_column_count f p _ _ (ub p) (ud p) (rb p) (rd p)
  simp only [eq]

def multCode : Comparison → Threshold
  | .eqZero => ⟨.eq,0⟩ | .gtZero => ⟨.gt,0⟩ | .leOne => ⟨.le,1⟩ | .eqOne => ⟨.eq,1⟩

theorem tuple_read (m : Comparison) (r : Rel α) (xs : List α)
    (nd : xs.Nodup) (faithful : ∀ a, a ∈ xs ↔ r a) :
    multiplicity m r ↔ (multCode m).op.test (xs.length : Int) (multCode m).literal := by
  have eq : r = fun a => a ∈ xs := funext fun a => propext (faithful a).symm
  subst r
  cases m with
  | eqZero => cases xs <;> simp [multiplicity,noOf,someOf,multCode,OrderOp.test] <;> omega
  | gtZero => cases xs <;> simp [multiplicity,someOf,multCode,OrderOp.test]
  | leOne => exact (length_lone_iff xs nd).symm.trans (by change xs.length ≤ 1 ↔ (xs.length : Int) ≤ 1; omega)
  | eqOne => exact (length_one_iff xs nd).symm.trans (by change xs.length = 1 ↔ (xs.length : Int) = 1; omega)

theorem machine_mult (m : Comparison) (w n : Nat) (wide : 2 < 2^w) :
    counted m w n ↔ (multCode m).op.test (BitVec.ofNat w n).toInt (multCode m).literal := by
  have one : (BitVec.ofNat w 1).toInt = 1 := signed_exact w 1 (by omega)
  cases m <;> simp [counted,multCode,OrderOp.test,← BitVec.toInt_inj,one]

-- The list is an enumeration of this oriented fiber, not the atom in the fixed slot.
theorem classified_fiber (d s : Rel β) (e : BinaryRel α β) (carrier : List α)
    (xs : β → List α) (nd : ∀ t, d t → (xs t).Nodup)
    (faithful : ∀ t, d t → ∀ x, x ∈ xs t ↔ e x t)
    (typed : ∀ x t, e x t → x ∈ carrier) (w cap : Nat)
    (bound : carrier.length ≤ cap) (wide : 2 < 2^w)
    (q : Threshold) (m : Comparison) (leftNeg rightNeg : Bool)
    (same : key w leftNeg q = key w rightNeg (multCode m)) (safe : safeAt m w cap) :
    classify d s (fun t => polarity leftNeg (q.op.test (BitVec.ofNat w (xs t).length).toInt q.literal)) ↔
    classify d s (fun t => polarity rightNeg (multiplicity m (fun x => e x t))) := by
  have point (t) (ht : d t) := rewrite_iff m w cap wide (fun x => e x t) (xs t) (nd t ht)
    (faithful t ht) (Nat.le_trans ((nd t ht).length_le_of_subset
       (fun x hx => typed x t ((faithful t ht x).mp hx))) bound) safe
  have eq (t) (ht : d t) : polarity leftNeg (q.op.test (BitVec.ofNat w (xs t).length).toInt q.literal) ↔
      polarity rightNeg (multiplicity m (fun x => e x t)) := by
    rw [← point t ht, machine_mult _ _ _ wide, key_test, key_test, same]
  exact ⟨fun h t ht => (h t ht).trans (eq t ht), fun h t ht => (h t ht).trans (eq t ht).symm⟩

-- ehuPMAHDvwaXdGXzX / inv5: two tracks lead into false, neither into true.
private def preds (t : Bool) : List Bool := if t then [] else [true,false]
theorem junction_instance :
    classify (fun _ => True) (· = false) (fun t => (BitVec.ofNat 4 (preds t).length).toInt ≥ 2) ↔
    qAll (fun _ => True) (fun t => (t ≠ false) ↔ loneOf (fun x => x ∈ preds t)) := by
  have h := classified_fiber (fun _ => True) (· = false) (fun x t => x ∈ preds t)
    [true,false] preds (fun t _ => by cases t <;> decide) (fun _ _ _ => Iff.rfl)
    (fun x _ _ => by cases x <;> decide) 4 3 (by decide) (by decide)
    ⟨.ge,2⟩ .leOne false true rfl (by change 2*3 < 2^4; decide)
  apply h.trans
  exact ⟨fun h t ht => (member_iff true _ _).mpr (h t ht),
         fun h t ht => (member_iff true _ _).mp (h t ht)⟩

theorem wrap_and_literal_controls :
    ¬ ((BitVec.ofNat 4 8).toInt ≥ 2) ∧ 2 ≤ (BitVec.ofNat 5 8).toInt ∧
    key 4 false ⟨.gt,1⟩ = key 4 false ⟨.ge,2⟩ ∧
    key 4 false ⟨.ge,2⟩ ≠ key 4 false ⟨.ge,3⟩ := by decide

end AdaptiveClassifier
