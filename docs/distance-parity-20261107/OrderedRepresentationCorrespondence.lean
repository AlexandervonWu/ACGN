import Std

namespace OrderedRepresentationCorrespondence
structure Step (S : Type) where
  apply : S → S
  charge : Nat
def execute {S : Type} (xs : List (Step S)) (s : S) : S :=
  xs.foldl (fun state step => step.apply state) s
def charge {S : Type} (xs : List (Step S)) : Nat := (xs.map Step.charge).sum

theorem block_execution {S : Type} (a b : List (Step S)) (s : S) :
    execute (a ++ b) s = execute b (execute a s) := by
  simp [execute, List.foldl_append]
theorem block_charge {S : Type} (a b : List (Step S)) :
    charge (a ++ b) = charge a + charge b := by simp [charge]

/- An additional identity operation remains in the trace; its effect and charge
   must both be checked before block correspondence can use it. -/
theorem retained_identity_step {S : Type} (a b : List (Step S)) (s : S)
    (step : Step S) (effect : ∀ x, step.apply x = x) (cost : step.charge = 0) :
    execute (a ++ step :: b) s = execute (a ++ b) s ∧
    charge (a ++ step :: b) = charge (a ++ b) := by
  constructor
  · simp [block_execution, execute, effect]
  · simp [charge, cost]

/- Original occurrences are the authority, not equal phase ordinals. -/
theorem independent_reindex_agrees {A : Type} (source : Nat → A)
    (fast certified : List Nat) (sameOccurrences : fast = certified) :
    fast.map source = certified.map source := by rw [sameOccurrences]

structure UnaryInsertion where
  operatorIsAlways : Bool
  ownerIsNone : Bool
  incomingRole : Nat
  childRole : Nat
def admitted (e : Option UnaryInsertion) : Prop :=
  ∃ w, e = some w ∧ w.operatorIsAlways = true ∧ w.ownerIsNone = true ∧
    w.incomingRole < 1 ∧ w.childRole < 1
theorem absent_is_not_admitted : ¬ admitted none := by simp [admitted]
theorem admitted_roles (w : UnaryInsertion) (h : admitted (some w)) :
    w.incomingRole = 0 ∧ w.childRole = 0 := by
  obtain ⟨v, same, _, _, incoming, child⟩ := h
  cases Option.some.inj same
  omega

#print axioms block_execution
#print axioms block_charge
#print axioms retained_identity_step
#print axioms independent_reindex_agrees
#print axioms absent_is_not_admitted
#print axioms admitted_roles
end OrderedRepresentationCorrespondence
