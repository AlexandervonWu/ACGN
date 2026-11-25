import AdaptiveFiberWitness

namespace AdaptiveClassifierArms
open AdaptiveClassifier AdaptiveFiberWitness

def split (d s p q : Rel α) :=
  qAll d (fun t => s t → p t) ∧ qAll d (fun t => q t → s t)

theorem separate (d s p q : Rel α) :
    qAll d (fun t => (s t → p t) ∧ (q t → s t)) ↔ split d s p q :=
  ⟨fun h => ⟨fun t hd => (h t hd).1,fun t hd => (h t hd).2⟩,
   fun h t hd => ⟨h.1 t hd,h.2 t hd⟩⟩

theorem restricted (d s p : Rel α) (typed : subset s d) :
    qAll s p ↔ qAll d (fun t => s t → p t) :=
  ⟨fun h t _ => h t,fun h t hs => h t (typed t hs) hs⟩

theorem classify_split (d s p q r : Rel α)
    (necessary : ∀ t, d t → (p t ↔ r t)) (sufficient : ∀ t, d t → (q t ↔ r t)) :
    split d s p q ↔ classify d s r := by
  exact ⟨fun h t hd => ⟨fun hs => (necessary t hd).mp (h.1 t hd hs),
      fun hr => h.2 t hd ((sufficient t hd).mpr hr)⟩,
    fun h => ⟨fun t hd hs => (necessary t hd).mpr ((h t hd).mp hs),
      fun t hd hq => (h t hd).mpr ((sufficient t hd).mp hq)⟩⟩

theorem duplicate (a b c : Prop) (left : a ↔ c) (right : b ↔ c) :
    (a ∧ b) ↔ c := ⟨fun h => left.mp h.1,fun h => ⟨left.mpr h,right.mpr h⟩⟩

theorem witnesses_imply (a b : Rel α) (test : α → α → Prop) (p : Prop) :
    (∀ x, a x → ∀ y, b y → test x y → p) ↔ ((∃ x y, a x ∧ b y ∧ test x y) → p) :=
  ⟨fun h ⟨x,y,hx,hy,ht⟩ => h x hx y hy ht, fun h x hx y hy ht => h ⟨x,y,hx,hy,ht⟩⟩

theorem edge_intersection (a b : Rel β) (t : β) : intersection a b t ↔ a t ∧ b t := Iff.rfl

-- WvDpxudQQsquLFgeo/inv5: necessary reads a signed count; sufficient
-- quantifies two distinct predecessors of the same junction candidate.
theorem mixed_station (d s : Rel β) (f : BinaryRel α β) (witness : Rel α)
    (xs : β → List α) (typed : subset s d) (cover : ∀ x t, f x t → witness x)
    (nd : ∀ t, d t → (xs t).Nodup) (faithful : ∀ t, d t → ∀ x, x ∈ xs t ↔ f x t)
    (w cap : Nat) (bound : ∀ t, d t → (xs t).length ≤ cap) (safe : 2*cap < 2^w) :
    (qAll s (fun t => (BitVec.ofNat w (xs t).length).toInt > 1) ∧
      qAll d (fun t => ∀ x, witness x → ∀ y, witness y → x ≠ y →
        subset (union (singletonRel x) (singletonRel y)) (fun z => f z t) → s t)) ↔
      classify d s (fun t => ¬loneOf (fun z => f z t)) := by
  have count (t) (ht : d t) : ((BitVec.ofNat w (xs t).length).toInt > 1) ↔
      ¬loneOf (fun z => f z t) := by
    have eq : (fun z => f z t) = fun z => z ∈ xs t :=
      funext fun z => propext (faithful t ht z).symm
    rw [eq,← AdaptiveCardinality.length_lone_iff _ (nd t ht),
      AdaptiveCardinality.signed_exact _ _ (by have := bound t ht; omega)]
    omega
  have back (t) : (∀ x, witness x → ∀ y, witness y → x ≠ y →
      subset (union (singletonRel x) (singletonRel y)) (fun z => f z t) → s t) ↔
      (¬loneOf (fun z => f z t) → s t) := by
    simp only [pair_union,← two_iff]
    exact ⟨fun h ⟨x,y,hx,hy,ne⟩ => h x (cover x t hx) y (cover y t hy) ne ⟨hx,hy⟩,
      fun h x _ y _ ne ⟨hx,hy⟩ => h ⟨x,y,hx,hy,ne⟩⟩
  rw [restricted d s _ typed,← classify_split d s _ _ _ count (fun _ _ => Iff.rfl)]
  exact and_congr_right fun _ => ⟨fun h t hd => (back t).mp (h t hd),
    fun h t hd => (back t).mpr (h t hd)⟩

theorem original_scope_instance :
    let d : Rel Bool := fun _ => True
    let s : Rel Bool := (· = false)
    let e : BinaryRel Bool Bool := fun _ t => t = false
    let xs (t : Bool) := if t then [] else [true,false]
    (qAll s (fun t => (BitVec.ofNat 4 (xs t).length).toInt > 1) ∧
      qAll d (fun t => ∀ x : Bool, True → ∀ y : Bool, True → x ≠ y →
        subset (union (singletonRel x) (singletonRel y)) (fun z => e z t) → s t)) ↔
      classify d s (fun t => ¬loneOf (fun z => e z t)) := by
  intro d s e xs
  exact mixed_station d s e (fun _ => True) xs (fun _ _ => trivial) (fun _ _ _ => trivial)
    (fun t _ => by cases t <;> decide) (fun t _ x => by cases t <;> cases x <;> decide)
    4 3 (fun t _ => by cases t <;> decide) (by decide)

theorem overflow_separates :
    let f : Rel (Fin 8) := fun _ => True
    ¬loneOf f ∧ ¬((BitVec.ofNat 4 (List.finRange 8).length).toInt > 1) := by
  intro f
  exact ⟨(two_iff f).mp ⟨0,1,trivial,trivial,by decide⟩,by decide⟩

end AdaptiveClassifierArms
