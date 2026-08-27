import Std

namespace TemporalAciPhasePresentation

/- This finite model represents the three temporal phase keys exercised by the
Java regression. `keyUniverse` is the independently fixed StructuralKey order;
filtering it by membership gives an order independent of the source ACI
presentation. -/
def keyUniverse : List Nat := [0, 1, 2]

def canonicalOrder (source : List Nat) : List Nat :=
  keyUniverse.filter source.contains

def canonicalIndex (order : List Nat) (key : Nat) : Nat :=
  order.idxOf key

def coherentPresentation (source : List Nat) : List (Nat × Nat) :=
  let order := canonicalOrder source
  order.map fun key => (key, canonicalIndex order key)

theorem same_order_has_same_coherent_presentation
    {left right : List Nat}
    (sameOrder : canonicalOrder left = canonicalOrder right) :
    coherentPresentation left = coherentPresentation right := by
  simp [coherentPresentation, sameOrder]

/- The bounded two-phase counterexample from the adversarial review. -/
theorem pair_permutation_has_one_presentation :
    coherentPresentation [0, 1] = coherentPresentation [1, 0] := by
  decide

/- Every source permutation of the bounded three-phase region receives the
same phase IDs and owner/reference presentation. -/
theorem triple_permutations_have_one_presentation :
    let expected := coherentPresentation [0, 1, 2]
    expected = coherentPresentation [0, 2, 1] ∧
    expected = coherentPresentation [1, 0, 2] ∧
    expected = coherentPresentation [1, 2, 0] ∧
    expected = coherentPresentation [2, 0, 1] ∧
    expected = coherentPresentation [2, 1, 0] := by
  decide

def presentationDistance (left right : List (Nat × Nat)) : Nat :=
  if left = right then 0 else 1

theorem bounded_certified_aci_pair_has_zero_projection_distance :
    presentationDistance
        (coherentPresentation [0, 1])
        (coherentPresentation [1, 0]) = 0 := by
  decide

theorem bounded_certified_aci_triple_has_zero_projection_distance :
    presentationDistance
        (coherentPresentation [0, 1, 2])
        (coherentPresentation [2, 0, 1]) = 0 := by
  decide

/- Binary temporal operands use a sequence, not the ACI presentation above. -/
def orderedBinary (left right : Nat) : List Nat := [left, right]

theorem ordered_binary_roles_remain_distinct :
    orderedBinary 0 1 ≠ orderedBinary 1 0 := by
  decide

end TemporalAciPhasePresentation
