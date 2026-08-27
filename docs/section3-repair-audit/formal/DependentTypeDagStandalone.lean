import Std

/-!
Standalone executable specification of the dependent relation-family DAG.

This file imports no ACGN definitions.  It models the finite nominal hierarchy,
correlated sum-of-products representation, antichain normalization, ordered
ARROW product, and branch-complete JOIN decision matrix used by the Java
implementation.  The small nominal universe is a falsification model: every
constructor and every possible boundary relation in that universe is explicit.
-/

namespace ACGN.DependentTypeDagStandalone

inductive Ty where
  | univ | p | a | b | c
  deriving DecidableEq, BEq, Repr

abbrev Product := List Ty
abbrev Family := List Product

def parent : Ty -> Option Ty
  | .a => some .p
  | .b => some .p
  | .p => some .univ
  | .c => some .univ
  | .univ => none

def ancestry : Ty -> List Ty
  | .a => [.a, .p, .univ]
  | .b => [.b, .p, .univ]
  | .p => [.p, .univ]
  | .c => [.c, .univ]
  | .univ => [.univ]

def subtype : Ty -> Ty -> Bool
  | .a, .a | .a, .p | .a, .univ => true
  | .b, .b | .b, .p | .b, .univ => true
  | .p, .p | .p, .univ => true
  | .c, .c | .c, .univ => true
  | .univ, .univ => true
  | _, _ => false

theorem parent_steps_are_subtypes (child ancestor : Ty)
    (h : parent child = some ancestor) : subtype child ancestor = true := by
  cases child <;> cases ancestor <;> simp_all [parent, subtype]

theorem univ_is_terminal : parent .univ = none := by
  rfl

def productSubtype : Product -> Product -> Bool
  | [], [] => true
  | left :: leftTail, right :: rightTail =>
      subtype left right && productSubtype leftTail rightTail
  | _, _ => false

def strictProductSubtype (left right : Product) : Bool :=
  productSubtype left right && left != right

def normalize (family : Family) : Family :=
  let unique := family.eraseDups
  unique.filter fun candidate =>
    !(unique.any fun other => strictProductSubtype candidate other)

theorem union_absorbs_authenticated_subtype :
    normalize [[.a], [.p]] = [[.p]] := by
  decide

theorem union_retains_disjoint_siblings :
    normalize [[.a], [.b]] = [[.a], [.b]] := by
  decide

theorem union_eliminates_duplicate_products :
    normalize [[.a], [.a]] = [[.a]] := by
  decide

theorem demonstrated_normalization_is_idempotent :
    normalize (normalize [[.a], [.b], [.a], [.p]]) =
      normalize [[.a], [.b], [.a], [.p]] := by
  decide

def firstCommonAncestor (left right : Ty) : Option Ty :=
  (ancestry left).find? fun candidate => (ancestry right).contains candidate

theorem sibling_common_ancestor :
    firstCommonAncestor .a .b = some .p := by
  decide

theorem top_level_common_ancestor_is_univ :
    firstCommonAncestor .p .c = some .univ := by
  decide

inductive Boundary where
  | exact (carrier : Ty)
  | leftSubtype (left right : Ty)
  | rightSubtype (left right : Ty)
  | disjoint (left right common : Ty)
  deriving DecidableEq, Repr

def boundary : Ty -> Ty -> Option Boundary
  | left, right =>
      if left == right then some (.exact left)
      else if subtype left right then some (.leftSubtype left right)
      else if subtype right left then some (.rightSubtype left right)
      else (firstCommonAncestor left right).map (.disjoint left right)

def overlaps : Boundary -> Bool
  | .exact _ | .leftSubtype _ _ | .rightSubtype _ _ => true
  | .disjoint _ _ _ => false

def meet : Boundary -> Option Ty
  | .exact carrier => some carrier
  | .leftSubtype left _ => some left
  | .rightSubtype _ right => some right
  | .disjoint _ _ _ => none

theorem subtype_boundary_has_specific_meet :
    (boundary .a .p).bind meet = some .a := by
  decide

theorem sibling_boundary_is_explicitly_disjoint :
    boundary .a .b = some (.disjoint .a .b .p) := by
  decide

theorem sharing_only_univ_does_not_create_overlap :
    (boundary .p .c).map overlaps = some false := by
  decide

theorem sharing_only_univ_has_no_meet :
    (boundary .p .c).bind meet = none := by
  decide

theorem explicit_univ_is_an_exact_boundary :
    boundary .univ .univ = some (.exact .univ) := by
  decide

theorem concrete_to_univ_uses_the_subtype_boundary :
    boundary .a .univ = some (.leftSubtype .a .univ) := by
  decide

def productMeet : Product -> Product -> Option Product
  | [], [] => some []
  | left :: leftTail, right :: rightTail => do
      let head <- (boundary left right).bind meet
      let tail <- productMeet leftTail rightTail
      pure (head :: tail)
  | _, _ => none

def familyIntersection (left right : Family) : Family :=
  normalize <| left.flatMap fun leftProduct =>
    right.filterMap fun rightProduct => productMeet leftProduct rightProduct

theorem intersection_keeps_more_specific_product :
    familyIntersection [[.a]] [[.p]] = [[.a]] := by
  decide

theorem intersection_omits_proven_disjoint_product :
    familyIntersection [[.a]] [[.b]] = [] := by
  decide

def familyArrow (left right : Family) : Family :=
  normalize <| left.flatMap fun leftProduct =>
    right.map fun rightProduct => leftProduct ++ rightProduct

theorem arrow_is_cartesian_over_correlated_products :
    familyArrow [[.a], [.b]] [[.a], [.b]] =
      [[.a, .a], [.a, .b], [.b, .a], [.b, .b]] := by
  decide

theorem correlated_union_is_not_independent_column_widening :
    [[.a, .b], [.b, .a]] !=
      familyArrow [[.a], [.b]] [[.a], [.b]] := by
  decide

theorem arrow_preserves_duplicate_columns :
    familyArrow [[.a]] [[.a]] = [[.a, .a]] := by
  decide

theorem arrow_preserves_order :
    familyArrow [[.a]] [[.b]] != familyArrow [[.b]] [[.a]] := by
  decide

inductive JoinDecision where
  | overlap (proof : Boundary) (result : Product)
  | disjoint (proof : Boundary)
  deriving DecidableEq, Repr

def dropBoundary : Product -> Product
  | [] => []
  | [_] => []
  | head :: tail => head :: dropBoundary tail

def joinProduct (left right : Product) : Option JoinDecision :=
  match left.getLast?, right.head? with
  | some leftBoundary, some rightBoundary => do
      let proof <- boundary leftBoundary rightBoundary
      if overlaps proof then
        pure (.overlap proof (dropBoundary left ++ right.drop 1))
      else
        pure (.disjoint proof)
  | _, _ => none

structure JoinMatrix (left right : Family) where
  caseAt : Fin left.length -> Fin right.length -> JoinDecision

def materializeMatrix {left right : Family}
    (matrix : JoinMatrix left right) : List JoinDecision :=
  (List.finRange left.length).flatMap fun leftIndex =>
    (List.finRange right.length).map fun rightIndex =>
      matrix.caseAt leftIndex rightIndex

theorem complete_matrix_has_cartesian_cardinality
    {left right : Family} (matrix : JoinMatrix left right) :
    (materializeMatrix matrix).length = left.length * right.length := by
  have sumConstant {α : Type} (values : List α) (amount : Nat) :
      (values.map fun _ => amount).sum = values.length * amount := by
    induction values with
    | nil => simp
    | cons head tail inductionHypothesis =>
        simp [inductionHypothesis, Nat.succ_mul, Nat.add_comm]
  simp only [materializeMatrix, List.length_flatMap, List.length_map]
  rw [sumConstant]
  simp

def familyJoin (left right : Family) : Family :=
  normalize <| left.flatMap fun leftProduct =>
    right.filterMap fun rightProduct =>
      match joinProduct leftProduct rightProduct with
      | some (.overlap _ result) => some result
      | some (.disjoint _) | none => none

structure TypedFamily where
  arity : Nat
  products : Family
  deriving DecidableEq, Repr

def validTypedFamily (family : TypedFamily) : Bool :=
  family.arity > 0 &&
    family.products.all fun product => product.length == family.arity

def typedFamily (arity : Nat) (products : Family) : Option TypedFamily :=
  if arity == 0 || products.any fun product => product.length != arity then
    none
  else
    some { arity := arity, products := normalize products }

def typedFamilyArrow (left right : TypedFamily) : Option TypedFamily :=
  if validTypedFamily left && validTypedFamily right then
    some
      { arity := left.arity + right.arity
        products := familyArrow left.products right.products }
  else
    none

theorem explicit_univ_arrow_is_certified :
    typedFamilyArrow
        { arity := 1, products := [[.univ]] }
        { arity := 1, products := [[.a]] } =
      some { arity := 2, products := [[.univ, .a]] } := by
  decide

def typedFamilyUnion
    (left right : TypedFamily) : Option TypedFamily :=
  if validTypedFamily left && validTypedFamily right &&
      left.arity == right.arity then
    some
      { arity := left.arity
        products := normalize (left.products ++ right.products) }
  else
    none

def typedFamilyIntersection
    (left right : TypedFamily) : Option TypedFamily :=
  if validTypedFamily left && validTypedFamily right &&
      left.arity == right.arity then
    some
      { arity := left.arity
        products := familyIntersection left.products right.products }
  else
    none

def typedFamilyJoin (left right : TypedFamily) : Option TypedFamily :=
  if validTypedFamily left && validTypedFamily right &&
      2 < left.arity + right.arity then
    some
      { arity := left.arity + right.arity - 2
        products := familyJoin left.products right.products }
  else
    none

/- A binary JOIN requires no reassociation.  Variadic certification below
checks the source-chain arity guard before recursively applying this step. -/
def certifiedBinaryFamilyJoin
    (left right : TypedFamily) : Option TypedFamily :=
  typedFamilyJoin left right

def everyProductHasTwoBoundaries (family : TypedFamily) : Bool :=
  validTypedFamily family && family.arity >= 2

def joinFlatGuard : List TypedFamily -> Bool
  | first :: second :: [] =>
      validTypedFamily first && validTypedFamily second
  | first :: middle :: next :: rest =>
      validTypedFamily first && everyProductHasTwoBoundaries middle &&
        joinFlatGuard (middle :: next :: rest)
  | _ => false

def familyJoinFold : TypedFamily -> List TypedFamily -> Option TypedFamily
  | current, [] =>
      if validTypedFamily current then some current else none
  | current, next :: rest => do
      let joined <- typedFamilyJoin current next
      familyJoinFold joined rest

def familyJoinChain : List TypedFamily -> Option TypedFamily
  | first :: second :: rest => do
      let joined <- typedFamilyJoin first second
      familyJoinFold joined rest
  | _ => none

def certifiedFamilyJoinChain
    (operands : List TypedFamily) : Option TypedFamily :=
  if operands.all validTypedFamily && joinFlatGuard operands then
    familyJoinChain operands
  else
    none

theorem join_omits_disjoint_branch_pair :
    familyJoin [[.a, .a]] [[.b, .c]] = [] := by
  decide

theorem join_retains_exact_branch_pair :
    familyJoin [[.a, .a]] [[.a, .c]] = [[.a, .c]] := by
  decide

theorem join_retains_subtype_branch_pair :
    familyJoin [[.a, .p]] [[.a, .c]] = [[.a, .c]] := by
  decide

theorem two_by_two_join_has_only_correlated_results :
    familyJoin
        [[.a, .a], [.b, .b]]
        [[.a, .c], [.b, .c]] =
      [[.a, .c], [.b, .c]] := by
  decide

theorem univ_commonality_cannot_create_join_result :
    familyJoin [[.a, .p]] [[.c, .a]] = [] := by
  decide

theorem explicit_univ_join_is_certified :
    certifiedBinaryFamilyJoin
        { arity := 2, products := [[.a, .univ]] }
        { arity := 2, products := [[.univ, .b]] } =
      some { arity := 2, products := [[.a, .b]] } := by
  decide

theorem right_univ_endpoint_chain_flattens :
    certifiedFamilyJoinChain
        [{ arity := 1, products := [[.a]] },
         { arity := 3, products := [[.a, .b, .c]] },
         { arity := 1, products := [[.univ]] }] =
      some { arity := 1, products := [[.b]] } := by
  decide

theorem left_univ_endpoint_chain_flattens :
    certifiedFamilyJoinChain
        [{ arity := 1, products := [[.univ]] },
         { arity := 3, products := [[.a, .b, .c]] },
         { arity := 1, products := [[.c]] }] =
      some { arity := 1, products := [[.b]] } := by
  decide

theorem interior_unary_chain_does_not_flatten :
    certifiedFamilyJoinChain
        [{ arity := 2, products := [[.a, .a]] },
         { arity := 1, products := [[.a]] },
         { arity := 2, products := [[.a, .a]] }] = none := by
  decide

theorem all_disjoint_join_retains_positive_empty_arity :
    certifiedBinaryFamilyJoin
        { arity := 2, products := [[.a, .a]] }
        { arity := 2, products := [[.b, .c]] } =
      some { arity := 2, products := [] } := by
  decide

theorem nullary_join_is_outside_the_typed_family_slice :
    certifiedBinaryFamilyJoin
        { arity := 1, products := [[.a]] }
        { arity := 1, products := [[.a]] } = none := by
  decide

theorem forged_nullary_empty_join_is_rejected :
    certifiedBinaryFamilyJoin
        { arity := 0, products := [] }
        { arity := 3, products := [[.a, .b, .c]] } = none := by
  decide

theorem wrong_width_family_join_is_rejected :
    certifiedBinaryFamilyJoin
        { arity := 2, products := [[.a]] }
        { arity := 2, products := [[.a, .b]] } = none := by
  decide

theorem forged_nullary_family_join_fold_base_is_rejected :
    familyJoinFold { arity := 0, products := [] } [] = none := by
  decide

theorem wrong_width_family_join_fold_base_is_rejected :
    familyJoinFold { arity := 2, products := [[.a]] } [] = none := by
  decide

theorem malformed_interior_family_fails_the_flat_guard :
    joinFlatGuard
        [{ arity := 1, products := [[.a]] },
         { arity := 2, products := [[]] },
         { arity := 1, products := [[.a]] }] = false := by
  decide

theorem typed_empty_union_retains_positive_arity :
    typedFamilyUnion
        { arity := 2, products := [] }
        { arity := 2, products := [] } =
      some { arity := 2, products := [] } := by
  decide

theorem all_disjoint_intersection_retains_positive_empty_arity :
    typedFamilyIntersection
        { arity := 2, products := [[.a, .a]] }
        { arity := 2, products := [[.b, .c]] } =
      some { arity := 2, products := [] } := by
  decide

theorem mixed_arity_set_operation_rejects :
    typedFamilyUnion
        { arity := 1, products := [] }
        { arity := 2, products := [] } = none := by
  decide

/- The term carrier for both operators is an ordered source sequence.  It is
not a bag or set: order and repeated source occurrences remain observable. -/
def sourceSeq (operands : Family) : Family := operands

theorem source_sequence_preserves_order :
    sourceSeq [[.a], [.b]] != sourceSeq [[.b], [.a]] := by
  decide

theorem source_sequence_preserves_duplicates :
    sourceSeq [[.a], [.a]] = [[.a], [.a]] := by
  rfl

end ACGN.DependentTypeDagStandalone
