import AdaptiveClassifierArms

namespace AdaptiveClassifierProjection
open AdaptiveCardinality AdaptiveClassifier AdaptiveFiberWitness

-- Project an incident edge, not merely an atom that satisfies the filter.
theorem project (outer inner : Rel α) (d s p : Rel β) (e : BinaryRel α β)
    (typed : subset s d) (covered : ∀ x t, e x t → outer x ∧ inner x)
    (live : ∀ t, d t → p t → ∃ x, e x t) :
    (s = unaryLeftJoin outer (fun x t => inner x ∧ d t ∧ e x t ∧ p t)) ↔ classify d s p := by
  have eq : unaryLeftJoin outer (fun x t => inner x ∧ d t ∧ e x t ∧ p t) =
      fun t => d t ∧ p t := by
    funext t; apply propext
    constructor
    · rintro ⟨_,_,_,hd,_,hp⟩; exact ⟨hd,hp⟩
    · rintro ⟨hd,hp⟩
      obtain ⟨x,hx⟩ := live t hd hp
      exact ⟨x,(covered x t hx).1,(covered x t hx).2,hd,hx,hp⟩
  rw [eq]; exact comprehension d s p typed

theorem project_right (outer inner : Rel α) (d s p : Rel β) (e : BinaryRel α β)
    (typed : subset s d) (covered : ∀ x t, e x t → outer x ∧ inner x)
    (live : ∀ t, d t → p t → ∃ x, e x t) :
    (s = unaryRightJoin (fun t x => d t ∧ inner x ∧ p t ∧ e x t) outer) ↔ classify d s p := by
  have eq : unaryRightJoin (fun t x => d t ∧ inner x ∧ p t ∧ e x t) outer =
      unaryLeftJoin outer (fun x t => inner x ∧ d t ∧ e x t ∧ p t) := by
    funext t; apply propext
    exact ⟨fun ⟨x,⟨hd,hi,hp,he⟩,ho⟩ => ⟨x,ho,hi,hd,he,hp⟩,
      fun ⟨x,ho,hi,hd,he,hp⟩ => ⟨x,⟨hd,hi,hp,he⟩,ho⟩⟩
  rw [eq]; exact project outer inner d s p e typed covered live

theorem rejecting_zero (q : Threshold) (obs : Nat → Int) (zero : obs 0 = 0)
    (reject : ¬q.op.test 0 q.literal) (r : Rel α) (xs : List α) (faithful : ∀ x, x ∈ xs ↔ r x)
    (h : q.op.test (obs xs.length) q.literal) : ∃ x, r x := by
  cases xs with
  | nil => exact False.elim (reject (by simpa [zero] using h))
  | cons a rest => exact ⟨a,(faithful a).mp (by simp)⟩

theorem machine_zero (w : Nat) :
    (BitVec.ofNat w 0).toInt = 0 ∧ ((BitVec.ofNat w 0).toNat : Int) = 0 := by simp

theorem subtract (d s p : Rel α) (typed : subset s d) :
    (s = difference d (fun t => d t ∧ p t)) ↔ classify d s (fun t => ¬p t) := by
  have eq : difference d (fun t => d t ∧ p t) = fun t => d t ∧ ¬p t := by
    funext t; apply propext
    exact ⟨fun ⟨hd,h⟩ => ⟨hd,fun hp => h ⟨hd,hp⟩⟩,
      fun ⟨hd,h⟩ => ⟨hd,fun pair => h pair.2⟩⟩
  rw [eq]; exact comprehension d s _ typed

-- JMR3nQz2QA37fdMKr: the witness belongs to Track and is incident to the
-- very column whose multiplicity is tested. A false-at-zero test supplies it.
theorem station_instance :
    let track : Rel Bool := fun _ => True
    let s : Rel Bool := (· = false)
    let f : BinaryRel Bool Bool := fun _ t => t = false
    let p := fun t => ¬loneOf (fun x => f x t)
    (s = unaryLeftJoin track (fun x t => track x ∧ track t ∧ f x t ∧ p t)) ↔
      classify track s p := by
  intro track s f p
  apply project _ _ _ _ _ _ (fun _ _ => trivial) (fun _ _ _ => ⟨trivial,trivial⟩)
  intro t _ hp
  obtain ⟨x,_,hx,_,_⟩ := (two_iff _).mpr hp
  exact ⟨x,hx⟩

theorem missing_incidence :
    let d : Rel Unit := fun _ => True
    let e : BinaryRel Unit Unit := fun _ _ => False
    classify d d (fun t => loneOf (fun x => e x t)) ∧
      d ≠ unaryLeftJoin d (fun x t => d x ∧ d t ∧ e x t ∧ loneOf (fun z => e z t)) := by
  intro d e
  exact ⟨fun _ _ => ⟨fun _ _ _ h => False.elim h,fun _ => trivial⟩,
    fun h => by obtain ⟨_,_,_,_,no,_⟩ := Eq.mp (congrFun h ()) trivial; exact no⟩

end AdaptiveClassifierProjection
