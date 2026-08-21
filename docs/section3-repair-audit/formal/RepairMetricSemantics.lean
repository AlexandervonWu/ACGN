/-
  Mathematical contract for the established CanDis repair metric.

  The certified representation supplies the finite admissible alignment and
  matching spaces.  This file defines the metric as exact minimization over
  those spaces; it does not replace them with a canonical ordering.
-/

namespace Section3.RepairMetric

structure DistanceBreakdown where
  temporal : Nat
  quantifier : Nat
  matrix : Nat
  deriving DecidableEq, Repr

def DistanceBreakdown.total (distance : DistanceBreakdown) : Nat :=
  distance.temporal + distance.quantifier + distance.matrix

theorem decomposition_is_additive (distance : DistanceBreakdown) :
    distance.total = distance.temporal + distance.quantifier + distance.matrix := by
  rfl

inductive Quantifier where
  | all
  | some
  | no
  | one
  | lone
  | notOne
  | notLone
  deriving DecidableEq, Repr

inductive Cardinality where
  | one
  | set
  | some
  | lone
  | exactly (amount : Nat)
  deriving DecidableEq, Repr

structure QuantifierTuple where
  quantifier : Quantifier
  primitiveType : Nat
  cardinality : Cardinality
  disjointnessClass : Nat
  deriving DecidableEq, Repr

def quantifierUpdateCost (left right : QuantifierTuple) : Nat :=
  if left = right then 0 else 1

theorem equal_quantifier_tuple_costs_zero (tuple : QuantifierTuple) :
    quantifierUpdateCost tuple tuple = 0 := by
  simp [quantifierUpdateCost]

theorem unequal_quantifier_tuple_costs_one
    (left right : QuantifierTuple)
    (different : left ≠ right) :
    quantifierUpdateCost left right = 1 := by
  simp [quantifierUpdateCost, different]

inductive QuantifierEdit where
  | insert (newTuple : QuantifierTuple)
  | delete (oldTuple : QuantifierTuple)
  | modify (oldTuple newTuple : QuantifierTuple)
  deriving DecidableEq, Repr

def quantifierEditCost : QuantifierEdit -> Nat
  | .insert _ => 1
  | .delete _ => 1
  | .modify _ _ => 1

theorem every_quantifier_edit_is_one_unit (edit : QuantifierEdit) :
    quantifierEditCost edit = 1 := by
  cases edit <;> rfl

/- A matrix binding may follow a changed declaration only when a selected
   minimum edit plan contains that exact diagonal modification. A positional
   parameter may also follow an explicit zero-cost diagonal in that plan.
   Coordinates alone are never evidence. -/
structure QuantifierEditAlignment where
  paired : List (Nat × Nat)
  modified : List (Nat × Nat)
  positionalParameters : List (Nat × Nat)
  modifiedIsPaired : ∀ pair ∈ modified, pair ∈ paired
  positionalParametersArePaired :
    ∀ pair ∈ positionalParameters, pair ∈ paired
  leftInjective : (paired.map Prod.fst).Nodup
  rightInjective : (paired.map Prod.snd).Nodup

def QuantifierEditAlignment.authorizesBinding
    (alignment : QuantifierEditAlignment)
    (left right : Nat) : Prop :=
  (left, right) ∈ alignment.modified ∨
    (left, right) ∈ alignment.positionalParameters

def emptyQuantifierAlignment : QuantifierEditAlignment := {
  paired := []
  modified := []
  positionalParameters := []
  modifiedIsPaired := by simp
  positionalParametersArePaired := by simp
  leftInjective := by simp
  rightInjective := by simp
}

def oneModifiedQuantifierAlignment : QuantifierEditAlignment := {
  paired := [(0, 0)]
  modified := [(0, 0)]
  positionalParameters := []
  modifiedIsPaired := by simp
  positionalParametersArePaired := by simp
  leftInjective := by simp
  rightInjective := by simp
}

def shiftedPositionalParameterAlignment : QuantifierEditAlignment := {
  paired := [(0, 1)]
  modified := []
  positionalParameters := [(0, 1)]
  modifiedIsPaired := by simp
  positionalParametersArePaired := by simp
  leftInjective := by simp
  rightInjective := by simp
}

theorem same_coordinate_without_paid_edit_is_not_authorized :
    Not (emptyQuantifierAlignment.authorizesBinding 0 0) := by
  simp [QuantifierEditAlignment.authorizesBinding,
    emptyQuantifierAlignment]

theorem paid_parameter_modification_authorizes_its_exact_pair :
    oneModifiedQuantifierAlignment.authorizesBinding 0 0 := by
  simp [QuantifierEditAlignment.authorizesBinding,
    oneModifiedQuantifierAlignment]

theorem selected_positional_parameter_diagonal_authorizes_its_exact_pair :
    shiftedPositionalParameterAlignment.authorizesBinding 0 1 := by
  simp [QuantifierEditAlignment.authorizesBinding,
    shiftedPositionalParameterAlignment]

theorem selected_positional_parameter_diagonal_does_not_authorize_coordinate :
    Not (shiftedPositionalParameterAlignment.authorizesBinding 0 0) := by
  simp [QuantifierEditAlignment.authorizesBinding,
    shiftedPositionalParameterAlignment]

inductive VariableIdentity where
  | free (name : String)
  | bound (coordinate : Nat)
  deriving DecidableEq, Repr

def variableIdentityUpdateCost
    (left right : VariableIdentity) : Nat :=
  if left = right then 0 else 1

theorem bound_and_same_spelled_free_variables_cost_one_both_directions
    (coordinate : Nat)
    (name : String) :
    variableIdentityUpdateCost (.bound coordinate) (.free name) = 1 /\
      variableIdentityUpdateCost (.free name) (.bound coordinate) = 1 := by
  simp [variableIdentityUpdateCost]

theorem paid_correspondence_has_no_duplicate_left
    (alignment : QuantifierEditAlignment) :
    (alignment.paired.map Prod.fst).Nodup :=
  alignment.leftInjective

theorem paid_correspondence_has_no_duplicate_right
    (alignment : QuantifierEditAlignment) :
    (alignment.paired.map Prod.snd).Nodup :=
  alignment.rightInjective

def exactMinimum (costs : List Nat) : Option Nat := costs.min?

theorem exact_minimum_specification (costs : List Nat) (minimum : Nat) :
    exactMinimum costs = some minimum <->
      minimum ∈ costs /\ (forall candidate, candidate ∈ costs -> minimum <= candidate) := by
  exact List.min?_eq_some_iff

structure AlphaAlignment where
  mappingCode : List (Nat × Nat)
  deriving DecidableEq, Repr

structure AlignmentProblem where
  leftTypes : List Nat
  rightTypes : List Nat
  certifiedCompatiblePairs : List (Nat × Nat)
  pairBounds : ∀ pair ∈ certifiedCompatiblePairs,
    pair.1 < leftTypes.length ∧ pair.2 < rightTypes.length
  pairTypes : ∀ pair ∈ certifiedCompatiblePairs,
    leftTypes[pair.1]? = rightTypes[pair.2]?

def AlphaAlignment.Compatible
    (problem : AlignmentProblem)
    (alignment : AlphaAlignment) : Prop :=
  (alignment.mappingCode.map Prod.fst).Nodup ∧
  (alignment.mappingCode.map Prod.snd).Nodup ∧
  ∀ pair ∈ alignment.mappingCode,
    pair ∈ problem.certifiedCompatiblePairs

def AlphaAlignment.Admissible
    (problem : AlignmentProblem)
    (alignment : AlphaAlignment) : Prop :=
  AlphaAlignment.Compatible problem alignment ∧
  ∀ candidate : AlphaAlignment,
    AlphaAlignment.Compatible problem candidate ->
    candidate.mappingCode.length ≤ alignment.mappingCode.length

structure CertifiedAlphaAlignment (problem : AlignmentProblem) where
  alignment : AlphaAlignment
  admissible : AlphaAlignment.Admissible problem alignment

def alphaDistance
    {Observation : Type}
    (problem : AlignmentProblem)
    (matrixCost : Observation -> Observation -> AlphaAlignment -> Nat)
    (left right : Observation)
    (mappings : List (CertifiedAlphaAlignment problem)) : Option Nat :=
  exactMinimum
    (mappings.map (fun mapping => matrixCost left right mapping.alignment))

theorem alpha_distance_is_exact_pairwise_minimum
    {Observation : Type}
    (problem : AlignmentProblem)
    (matrixCost : Observation -> Observation -> AlphaAlignment -> Nat)
    (left right : Observation)
    (mappings : List (CertifiedAlphaAlignment problem))
    (minimum : Nat) :
    alphaDistance problem matrixCost left right mappings = some minimum <->
      (exists mapping, mapping ∈ mappings /\
        matrixCost left right mapping.alignment = minimum) /\
      (forall mapping, mapping ∈ mappings ->
        minimum <= matrixCost left right mapping.alignment) := by
  rw [alphaDistance, exactMinimum, List.min?_eq_some_iff]
  constructor
  · intro result
    constructor
    · exact List.mem_map.mp result.1
    · intro mapping member
      exact result.2 _ (List.mem_map_of_mem member)
  · rintro ⟨⟨mapping, member, cost⟩, least⟩
    constructor
    · exact List.mem_map.mpr ⟨mapping, member, cost⟩
    · intro candidate candidateMember
      rcases List.mem_map.mp candidateMember with ⟨mapping, member, mappedCost⟩
      rw [<- mappedCost]
      exact least mapping member

structure Assignment where
  matchedPairs : List (Nat × Nat)
  deletedLeft : List Nat
  insertedRight : List Nat
  deriving DecidableEq, Repr

structure AssignmentProblem where
  leftSize : Nat
  rightSize : Nat
  deriving DecidableEq, Repr

def Assignment.Admissible
    (problem : AssignmentProblem)
    (assignment : Assignment) : Prop :=
  (assignment.matchedPairs.map Prod.fst ++ assignment.deletedLeft).Perm
      (List.range problem.leftSize) ∧
  (assignment.matchedPairs.map Prod.snd ++ assignment.insertedRight).Perm
      (List.range problem.rightSize)

structure CertifiedAssignment (problem : AssignmentProblem) where
  assignment : Assignment
  admissible : assignment.Admissible problem

def assignmentCost
    (pairCost : Nat -> Nat -> Nat)
    (deleteCost insertCost : Nat -> Nat)
    (assignment : Assignment) : Nat :=
  (assignment.matchedPairs.map (fun pair => pairCost pair.1 pair.2)).sum +
  (assignment.deletedLeft.map deleteCost).sum +
  (assignment.insertedRight.map insertCost).sum

def aciDistance
    (problem : AssignmentProblem)
    (pairCost : Nat -> Nat -> Nat)
    (deleteCost insertCost : Nat -> Nat)
    (assignments : List (CertifiedAssignment problem)) : Option Nat :=
  exactMinimum
    (assignments.map (fun assignment =>
      assignmentCost pairCost deleteCost insertCost assignment.assignment))

theorem aci_distance_is_exact_minimum_cost_assignment
    (problem : AssignmentProblem)
    (pairCost : Nat -> Nat -> Nat)
    (deleteCost insertCost : Nat -> Nat)
    (assignments : List (CertifiedAssignment problem))
    (minimum : Nat) :
    aciDistance problem pairCost deleteCost insertCost assignments = some minimum <->
      (exists assignment, assignment ∈ assignments /\
        assignmentCost pairCost deleteCost insertCost assignment.assignment = minimum) /\
      (forall assignment, assignment ∈ assignments ->
        minimum <= assignmentCost pairCost deleteCost insertCost
          assignment.assignment) := by
  rw [aciDistance, exactMinimum, List.min?_eq_some_iff]
  constructor
  · intro result
    constructor
    · exact List.mem_map.mp result.1
    · intro assignment member
      exact result.2 _ (List.mem_map_of_mem member)
  · rintro ⟨⟨assignment, member, cost⟩, least⟩
    constructor
    · exact List.mem_map.mpr ⟨assignment, member, cost⟩
    · intro candidate candidateMember
      rcases List.mem_map.mp candidateMember with ⟨assignment, member, mappedCost⟩
      rw [<- mappedCost]
      exact least assignment member

theorem exact_minimum_does_not_use_positional_choice :
    exactMinimum [7, 2, 5] = some 2 /\
    exactMinimum [5, 7, 2] = some 2 := by
  native_decide

theorem alpha_minimization_can_choose_a_nonfirst_mapping :
    exactMinimum [9, 3, 8] = some 3 := by
  native_decide

theorem assignment_minimization_can_choose_crossed_pairs :
    let problem : AssignmentProblem := { leftSize := 2, rightSize := 2 }
    let direct : Assignment := {
      matchedPairs := [(0, 0), (1, 1)]
      deletedLeft := []
      insertedRight := []
    }
    let crossed : Assignment := {
      matchedPairs := [(0, 1), (1, 0)]
      deletedLeft := []
      insertedRight := []
    }
    let cost (left right : Nat) : Nat :=
      if left = right then 8 else 1
    let certifiedDirect : CertifiedAssignment problem := {
      assignment := direct
      admissible := by
        constructor
        · change [0, 1].Perm [0, 1]
          exact List.Perm.refl _
        · change [0, 1].Perm [0, 1]
          exact List.Perm.refl _
    }
    let certifiedCrossed : CertifiedAssignment problem := {
      assignment := crossed
      admissible := by
        constructor
        · change [0, 1].Perm [0, 1]
          exact List.Perm.refl _
        · change [1, 0].Perm [0, 1]
          exact List.Perm.swap 0 1 []
    }
    aciDistance problem cost (fun _ => 1) (fun _ => 1)
      [certifiedDirect, certifiedCrossed] = some 2 := by
  native_decide

def javaIntMax : Nat := 2147483647

theorem two_maximum_java_int_costs_do_not_fit_java_int :
    javaIntMax + javaIntMax > javaIntMax := by
  native_decide

theorem checked_assignment_boundary_must_reject_two_maximum_costs
    (result : Nat)
    (exact : result = javaIntMax + javaIntMax) :
    result > javaIntMax := by
  rw [exact]
  exact two_maximum_java_int_costs_do_not_fit_java_int

def singletonAlignmentProblem : AlignmentProblem := {
  leftTypes := [7]
  rightTypes := [7]
  certifiedCompatiblePairs := [(0, 0)]
  pairBounds := by
    intro pair member
    simp at member
    subst pair
    decide
  pairTypes := by
    intro pair member
    simp at member
    subst pair
    rfl
}

def emptyAlignment : AlphaAlignment := { mappingCode := [] }
def singletonAlignment : AlphaAlignment := { mappingCode := [(0, 0)] }

theorem singleton_alignment_is_compatible :
    AlphaAlignment.Compatible singletonAlignmentProblem singletonAlignment := by
  simp [AlphaAlignment.Compatible, singletonAlignment,
    singletonAlignmentProblem]

theorem nonmaximum_empty_alignment_is_not_admissible :
    Not (AlphaAlignment.Admissible singletonAlignmentProblem emptyAlignment) := by
  intro admitted
  have maximum := admitted.2 singletonAlignment
    singleton_alignment_is_compatible
  simp [emptyAlignment, singletonAlignment] at maximum

end Section3.RepairMetric
