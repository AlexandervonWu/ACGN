import Std

/-
  Bounded executable refinement model for the repair metric.

  Scope: finite temporal trees; finite quantifier-tuple lists; one-level atom
  SEQUENCE/BAG/SET containers; and finite predicate/variable alpha clauses.
  The companion Java test reconstructs exactly the named vectors below through
  RepairView and QuotientRepairDistance. This is a bounded cross-language
  refinement check, not a proof about arbitrary Java executions.
-/

namespace Section3.ConcreteRepairMetric

inductive Profile where
  | overflowForbidding
  | modular
  deriving DecidableEq, Repr, BEq

inductive Quantifier where
  | all
  | some
  | no
  deriving DecidableEq, Repr, BEq

inductive Cardinality where
  | one
  | set
  | lone
  deriving DecidableEq, Repr, BEq

structure QuantifierTuple where
  quantifier : Quantifier
  primitiveType : Nat
  cardinality : Cardinality
  disjointnessClass : Nat
  deriving DecidableEq, Repr, BEq

inductive Atom where
  | a
  | b
  | c
  | p
  | q
  | r
  deriving DecidableEq, Repr, BEq

inductive ContainerKind where
  | sequence
  | bag
  | set
  deriving DecidableEq, Repr, BEq

mutual
  inductive TemporalTree where
    | node : Nat -> TemporalForest -> TemporalTree
    deriving DecidableEq, Repr, BEq

  inductive TemporalForest where
    | nil : TemporalForest
    | cons : TemporalTree -> TemporalForest -> TemporalForest
    deriving DecidableEq, Repr, BEq
end

mutual
  def TemporalTree.size : TemporalTree -> Nat
    | .node _ children => 1 + children.size

  def TemporalForest.size : TemporalForest -> Nat
    | .nil => 0
    | .cons tree rest => tree.size + rest.size
end

def TemporalForest.append : TemporalForest -> TemporalForest -> TemporalForest
  | .nil, right => right
  | .cons tree rest, right => .cons tree (rest.append right)

@[simp] theorem temporalForestSizeAppend :
    (left right : TemporalForest) ->
    (left.append right).size = left.size + right.size
  | .nil, right => by simp [TemporalForest.append, TemporalForest.size]
  | .cons tree rest, right => by
      rw [TemporalForest.append, TemporalForest.size, TemporalForest.size,
        temporalForestSizeAppend rest right]
      omega

def temporalForestDistance : TemporalForest -> TemporalForest -> Nat
  | .nil, right => right.size
  | left, .nil => left.size
  | .cons (.node leftLabel leftChildren) leftRest,
      .cons (.node rightLabel rightChildren) rightRest =>
    min
      (1 + temporalForestDistance (leftChildren.append leftRest)
        (.cons (.node rightLabel rightChildren) rightRest))
      (min
        (1 + temporalForestDistance
          (.cons (.node leftLabel leftChildren) leftRest)
          (rightChildren.append rightRest))
        ((if leftLabel = rightLabel then 0 else 1) +
          temporalForestDistance leftChildren rightChildren +
          temporalForestDistance leftRest rightRest))
termination_by left right => left.size + right.size
decreasing_by
  all_goals
    simp_wf
    simp only [TemporalTree.size, TemporalForest.size]
    omega

def temporalDistance (left right : TemporalTree) : Nat :=
  temporalForestDistance (.cons left .nil) (.cons right .nil)

def sequenceDistance [DecidableEq item] : List item -> List item -> Nat
  | [], right => right.length
  | left, [] => left.length
  | leftHead :: leftTail, rightHead :: rightTail =>
    min
      (1 + sequenceDistance leftTail (rightHead :: rightTail))
      (min
        (1 + sequenceDistance (leftHead :: leftTail) rightTail)
        ((if leftHead = rightHead then 0 else 1) +
          sequenceDistance leftTail rightTail))
termination_by left right => left.length + right.length
decreasing_by
  all_goals simp_wf
  all_goals omega

def selections : List item -> List (item × List item)
  | [] => []
  | head :: tail =>
    (head, tail) :: (selections tail).map (fun selected =>
      (selected.1, head :: selected.2))

def minimumOr (fallback : Nat) : List Nat -> Nat
  | [] => fallback
  | head :: tail => tail.foldl min head

def assignmentDistance
    (deleteCost : leftItem -> Nat)
    (insertCost : rightItem -> Nat)
    (pairCost : leftItem -> rightItem -> Nat) :
    List leftItem -> List rightItem -> Nat
  | [], right => (right.map insertCost).sum
  | leftHead :: leftTail, right =>
    minimumOr (deleteCost leftHead + assignmentDistance deleteCost insertCost
      pairCost leftTail right)
      ((deleteCost leftHead + assignmentDistance deleteCost insertCost
          pairCost leftTail right) ::
        (selections right).map (fun selected =>
          pairCost leftHead selected.1 +
            assignmentDistance deleteCost insertCost pairCost
              leftTail selected.2))

def deduplicate [DecidableEq item] : List item -> List item
  | [] => []
  | head :: tail =>
    let reduced := deduplicate tail
    if head ∈ reduced then reduced else head :: reduced

def atomCost (left right : Atom) : Nat :=
  if left = right then 0 else 1

def containerDistance
    (kind : ContainerKind)
    (left right : List Atom) : Nat :=
  match kind with
  | .sequence => sequenceDistance left right
  | .bag => assignmentDistance (fun _ => 1) (fun _ => 1) atomCost left right
  | .set =>
      assignmentDistance (fun _ => 1) (fun _ => 1) atomCost
        (deduplicate left) (deduplicate right)

structure AlphaClause where
  predicate : Atom
  coordinate : Nat
  deriving DecidableEq, Repr, BEq

abbrev AlphaMapping := List (Nat × Nat)

def partialMappings : List Nat -> List Nat -> List AlphaMapping
  | [], _ => [[]]
  | leftHead :: leftTail, right =>
    partialMappings leftTail right ++
      (selections right).flatMap (fun selected =>
        (partialMappings leftTail selected.2).map (fun mapping =>
          (leftHead, selected.1) :: mapping))

def maximumMappings (mappings : List AlphaMapping) : List AlphaMapping :=
  let maximum := mappings.foldl (fun size mapping => max size mapping.length) 0
  mappings.filter (fun mapping => mapping.length = maximum)

def mappedVariableCost
    (mapping : AlphaMapping)
    (left right : Nat) : Nat :=
  match mapping.find? (fun pair => pair.1 = left) with
  | some pair => if pair.2 = right then 0 else 1
  | none => 1

def alphaClauseCost
    (mapping : AlphaMapping)
    (left right : AlphaClause) : Nat :=
  atomCost left.predicate right.predicate +
    mappedVariableCost mapping left.coordinate right.coordinate

def alphaClauseDistance
    (mapping : AlphaMapping)
    (left right : List AlphaClause) : Nat :=
  assignmentDistance (fun _ => 2) (fun _ => 2)
    (alphaClauseCost mapping) left right

def alphaDistance
    (leftBindingCount rightBindingCount : Nat)
    (left right : List AlphaClause) : Nat × Nat :=
  let mappings := maximumMappings
    (partialMappings (List.range leftBindingCount) (List.range rightBindingCount))
  let costs := mappings.map (fun mapping => alphaClauseDistance mapping left right)
  (minimumOr (left.length * 2 + right.length * 2) costs, mappings.length)

inductive Matrix where
  | atom : Atom -> Matrix
  | container : Nat -> ContainerKind -> List Atom -> Matrix
  | alpha : Nat -> List AlphaClause -> Matrix
  deriving DecidableEq, Repr, BEq

def matrixSize : Matrix -> Nat
  | .atom _ => 1
  | .container _ _ operands => 1 + operands.length
  | .alpha _ clauses => 1 + 2 * clauses.length

def matrixDistance : Matrix -> Matrix -> Nat × Nat
  | .atom left, .atom right => (atomCost left right, 1)
  | .container leftOperator leftKind leftOperands,
      .container rightOperator rightKind rightOperands =>
    let rootCost := if leftOperator = rightOperator ∧ leftKind = rightKind then 0 else 1
    let operandCost := if leftKind = rightKind then
      containerDistance leftKind leftOperands rightOperands
    else
      sequenceDistance leftOperands rightOperands
    (rootCost + operandCost, 1)
  | .alpha leftCount leftClauses, .alpha rightCount rightClauses =>
      alphaDistance leftCount rightCount leftClauses rightClauses
  | left, right => (max (matrixSize left) (matrixSize right), 1)

structure Observation where
  profile : Profile
  temporal : TemporalTree
  quantifiers : List QuantifierTuple
  matrix : Matrix
  producerObservation : Nat
  deriving DecidableEq, Repr, BEq

structure Breakdown where
  total : Nat
  temporal : Nat
  quantifier : Nat
  matrix : Nat
  alphaMappings : Nat
  deriving DecidableEq, Repr, BEq

inductive Rejection where
  | profileMismatch
  | producerKernelMismatch
  deriving DecidableEq, Repr, BEq

inductive Evaluation where
  | accepted : Breakdown -> Evaluation
  | rejected : Rejection -> Evaluation
  deriving DecidableEq, Repr, BEq

def evaluate (left right : Observation) : Evaluation :=
  if left.profile ≠ right.profile then
    .rejected .profileMismatch
  else
    let temporal := temporalDistance left.temporal right.temporal
    let quantifier := sequenceDistance left.quantifiers right.quantifiers
    let matrixResult := matrixDistance left.matrix right.matrix
    let total := temporal + quantifier + matrixResult.1
    let breakdown : Breakdown := {
      total := total
      temporal := temporal
      quantifier := quantifier
      matrix := matrixResult.1
      alphaMappings := matrixResult.2
    }
    if decide (left.producerObservation = right.producerObservation) ==
        decide (total = 0) then
      .accepted breakdown
    else
      .rejected .producerKernelMismatch

def temporalLeaf (label : Nat) : TemporalTree := .node label .nil

def temporalParent (label childLabel : Nat) : TemporalTree :=
  .node label (.cons (temporalLeaf childLabel) .nil)

def allS : QuantifierTuple := {
  quantifier := .all
  primitiveType := 0
  cardinality := .one
  disjointnessClass := 0
}

def someS : QuantifierTuple := { allS with quantifier := .some }

def changedTuple : QuantifierTuple := {
  quantifier := .no
  primitiveType := 1
  cardinality := .set
  disjointnessClass := 7
}

def observation
    (profile : Profile)
    (temporal : TemporalTree)
    (quantifiers : List QuantifierTuple)
    (matrix : Matrix)
    (producerObservation : Nat) : Observation := {
  profile := profile
  temporal := temporal
  quantifiers := quantifiers
  matrix := matrix
  producerObservation := producerObservation
}

def baseTemporal : TemporalTree := temporalLeaf 0

def additiveLeft : Observation :=
  observation .overflowForbidding baseTemporal [allS] (.atom .a) 0

def additiveRight : Observation :=
  observation .overflowForbidding (temporalParent 0 1) [someS] (.atom .c) 1

def alphaLeft : Observation :=
  observation .overflowForbidding baseTemporal [allS, allS, allS]
    (.alpha 3 [{ predicate := .p, coordinate := 0 },
      { predicate := .q, coordinate := 1 },
      { predicate := .r, coordinate := 2 }]) 0

def alphaRight : Observation :=
  observation .overflowForbidding baseTemporal [allS]
    (.alpha 1 [{ predicate := .q, coordinate := 0 }]) 1

structure Vector where
  name : String
  left : Observation
  right : Observation
  expected : Evaluation
  deriving DecidableEq, Repr, BEq

def accepted
    (total temporal quantifier matrix alphaMappings : Nat) : Evaluation :=
  .accepted {
    total := total
    temporal := temporal
    quantifier := quantifier
    matrix := matrix
    alphaMappings := alphaMappings
  }

def vectors : List Vector := [
  {
    name := "profile_mismatch_precedes_kernel"
    left := observation .overflowForbidding baseTemporal [] (.atom .a) 0
    right := observation .modular baseTemporal [] (.atom .c) 0
    expected := .rejected .profileMismatch
  },
  {
    name := "additive_decomposition"
    left := additiveLeft
    right := additiveRight
    expected := accepted 3 1 1 1 1
  },
  {
    name := "quantifier_full_tuple_modify"
    left := observation .overflowForbidding baseTemporal [allS] (.atom .a) 0
    right := observation .overflowForbidding baseTemporal [changedTuple] (.atom .a) 1
    expected := accepted 1 0 1 0 1
  },
  {
    name := "ordered_sequence_swap"
    left := observation .overflowForbidding baseTemporal []
      (.container 10 .sequence [.a, .b]) 0
    right := observation .overflowForbidding baseTemporal []
      (.container 10 .sequence [.b, .a]) 1
    expected := accepted 2 0 0 2 1
  },
  {
    name := "bag_multiplicity"
    left := observation .overflowForbidding baseTemporal []
      (.container 11 .bag [.a, .a]) 0
    right := observation .overflowForbidding baseTemporal []
      (.container 11 .bag [.a]) 1
    expected := accepted 1 0 0 1 1
  },
  {
    name := "bag_minimum_assignment"
    left := observation .overflowForbidding baseTemporal []
      (.container 11 .bag [.a, .b]) 0
    right := observation .overflowForbidding baseTemporal []
      (.container 11 .bag [.b, .a]) 0
    expected := accepted 0 0 0 0 1
  },
  {
    name := "set_idempotence"
    left := observation .overflowForbidding baseTemporal []
      (.container 12 .set [.a, .a, .b]) 0
    right := observation .overflowForbidding baseTemporal []
      (.container 12 .set [.b, .a]) 0
    expected := accepted 0 0 0 0 1
  },
  {
    name := "set_minimum_assignment"
    left := observation .overflowForbidding baseTemporal []
      (.container 12 .set [.a, .b]) 0
    right := observation .overflowForbidding baseTemporal []
      (.container 12 .set [.b, .c]) 1
    expected := accepted 1 0 0 1 1
  },
  {
    name := "alpha_maximum_cardinality"
    left := alphaLeft
    right := alphaRight
    expected := accepted 6 0 2 4 3
  },
  {
    name := "kernel_zero_different_observation"
    left := observation .overflowForbidding baseTemporal [] (.atom .a) 0
    right := observation .overflowForbidding baseTemporal [] (.atom .a) 1
    expected := .rejected .producerKernelMismatch
  },
  {
    name := "kernel_nonzero_same_observation"
    left := observation .overflowForbidding baseTemporal [] (.atom .a) 0
    right := observation .overflowForbidding baseTemporal [] (.atom .c) 0
    expected := .rejected .producerKernelMismatch
  }
]

theorem boundedVectorExpectations :
    vectors.all (fun vector => decide (evaluate vector.left vector.right =
      vector.expected)) = true := by
  native_decide

theorem profileMismatchIsFirst :
    evaluate
      (observation .overflowForbidding baseTemporal [] (.atom .a) 0)
      (observation .modular baseTemporal [] (.atom .c) 0) =
      .rejected .profileMismatch := by
  native_decide

theorem temporalQuantifierMatrixCompositionIsAdditive :
    evaluate additiveLeft additiveRight = accepted 3 1 1 1 1 := by
  native_decide

theorem quantifierTupleReplacementIsOneUnit :
    sequenceDistance [allS] [changedTuple] = 1 := by
  native_decide

theorem orderedSequencePreservesOrder :
    containerDistance .sequence [.a, .b] [.b, .a] = 2 := by
  native_decide

theorem bagMultiplicityIsPreserved :
    containerDistance .bag [.a, .a] [.a] = 1 := by
  native_decide

theorem bagUsesMinimumAssignment :
    containerDistance .bag [.a, .b] [.b, .a] = 0 := by
  native_decide

theorem setOperandsAreIdempotent :
    containerDistance .set [.a, .a, .b] [.b, .a] = 0 := by
  native_decide

theorem setUsesMinimumAssignmentAfterDeduplication :
    containerDistance .set [.a, .b] [.b, .c] = 1 := by
  native_decide

theorem matrixOperandDeletionRemovesTheWholeSubtree :
    matrixDistance (.container 99 .sequence [.a]) (.atom .a) = (2, 1) := by
  native_decide

theorem alphaUsesAllMaximumCardinalityMappings :
    alphaDistance 3 1
      [{ predicate := .p, coordinate := 0 },
       { predicate := .q, coordinate := 1 },
       { predicate := .r, coordinate := 2 }]
      [{ predicate := .q, coordinate := 0 }] = (4, 3) := by
  native_decide

def renderEvaluation : Evaluation -> List String
  | .accepted breakdown => [
      "ACCEPT",
      toString breakdown.total,
      toString breakdown.temporal,
      toString breakdown.quantifier,
      toString breakdown.matrix]
  | .rejected .profileMismatch =>
      ["REJECT_PROFILE_MISMATCH", "-", "-", "-", "-"]
  | .rejected .producerKernelMismatch =>
      ["REJECT_KERNEL_MISMATCH", "-", "-", "-", "-"]

def renderVector (vector : Vector) : String :=
  String.intercalate "\t" (vector.name :: renderEvaluation (evaluate vector.left vector.right))

def vectorTsv : String :=
  String.intercalate "\n"
    ("name\toutcome\ttotal\ttemporal\tquantifier\tmatrix" ::
      vectors.map renderVector) ++ "\n"

def main (arguments : List String) : IO Unit := do
  match arguments with
  | [path] => IO.FS.writeFile path vectorTsv
  | _ => throw (IO.userError
      "usage: lean --run ConcreteRepairMetric.lean OUTPUT.tsv")

end Section3.ConcreteRepairMetric

def main (arguments : List String) : IO Unit :=
  Section3.ConcreteRepairMetric.main arguments
