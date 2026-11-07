import GuardedJoinChain

/- Shared ordered chain edit units, conditional on exact typed source admission.
   The existing guarded relation theorem supplies semantics; the new arithmetic
   records the cost of deleting one operand, not a binary syntax wrapper.
   This does not prove Java refinement or the full representation-union minimum. -/
namespace FastChainGeometry
open ACGN.Section3.DependentChainSequence
open ACGN.ThirdFive.GuardedJoinChain
open ACGN.BoundedFive.DependentJoinGuard

theorem same_guarded_sequence_same_relation (s t : Tree Atom)
    (same : sourceLeaves s = sourceLeaves t)
    (accepted : guard .JOIN ((sourceLeaves s).map Operand.arity) = true) :
    eval s = eval t := accepted_chain_relational_equality s t same accepted

theorem sequence_deletion_charge (weight : α → Nat) (pre post : List α) (x : α) :
    ((pre ++ x :: post).map weight).sum =
      ((pre ++ post).map weight).sum + weight x := by
  simp [List.map_append, List.sum_append]
  omega

theorem singleton_operand_charge (pre post : List α) (x : α) :
    (pre ++ x :: post).length = (pre ++ post).length + 1 := by simp; omega

theorem sequence_keeps_order (a b : α) (different : a ≠ b) : [a, b] ≠ [b, a] := by
  simp [different]

theorem sequence_keeps_duplicate (a : α) : ([a, a] : List α).length = 2 := rfl

#print axioms same_guarded_sequence_same_relation
#print axioms sequence_deletion_charge
#print axioms singleton_operand_charge
#print axioms sequence_keeps_order
#print axioms sequence_keeps_duplicate
end FastChainGeometry
