import Std

/- A checked Boolean ancestor can erase an entire descendant JOIN occurrence.
   The JOIN's original construction proof is retained; it is not applied to
   a fabricated surviving node. No arbitrary absence or local/temporal scope
   transfer follows from this law. This is not an extracted Java verifier. -/
namespace GuardedJoinBooleanErasure

inductive Formula (A : Type) where
  | atom : A → Formula A
  | disj : Formula A → Formula A → Formula A

def eval (meaning : A → Prop) : Formula A → Prop
  | .atom a => meaning a
  | .disj a b => eval meaning a ∨ eval meaning b

inductive Present (a : A) : Formula A → Prop where
  | here : Present a (.atom a)
  | left : Present a x → Present a (.disj x y)
  | right : Present a y → Present a (.disj x y)

theorem present_true (meaning : A → Prop) (h : Present a f)
    (ha : meaning a) : eval meaning f := by
  induction h with
  | here => exact ha
  | left _ ih => exact Or.inl ih
  | right _ ih => exact Or.inr ih

theorem complement_erases (meaning : A → Prop)
    (hp : Present p f) (hn : Present n f)
    (sameTypedAtom : meaning n ↔ ¬ meaning p) : eval meaning f ↔ True := by
  classical
  constructor
  · intro _; trivial
  · intro _
    by_cases h : meaning p
    · exact present_true meaning hp h
    · exact present_true meaning hn (sameTypedAtom.mpr h)

theorem nested_membership (membership residual : Prop) :
    (¬ membership ∨ (residual ∨ membership)) ↔ True := by
  classical
  simp only [iff_true]
  exact (Classical.em membership).elim (fun h => Or.inr (Or.inr h)) Or.inl

structure Original where
  phase : Nat
  path : List Nat
  lineage : Nat
  deriving DecidableEq

structure Discharge (meaning : A → Prop) (source : Formula A) where
  occurrence : Original
  ancestor : Original
  pathLink : ∃ tail, occurrence.path = ancestor.path ++ tail
  ownerLink : occurrence.phase = ancestor.phase
  checkedTruth : eval meaning source ↔ True

theorem discard_preserves_value (d : Discharge meaning source) :
    eval meaning source ↔ True := d.checkedTruth

theorem no_cross_owner (d : Discharge meaning source) :
    d.occurrence.phase = d.ancestor.phase := d.ownerLink

theorem absence_alone_insufficient : ¬ (∀ p : Prop, p ↔ True) := by
  intro h
  exact (h False).mpr True.intro

#print axioms present_true
#print axioms complement_erases
#print axioms nested_membership
#print axioms discard_preserves_value
#print axioms no_cross_owner
#print axioms absence_alone_insufficient
end GuardedJoinBooleanErasure
