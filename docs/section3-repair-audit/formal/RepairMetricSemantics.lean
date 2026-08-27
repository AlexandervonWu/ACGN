/-
  Mathematical contract for the established CanDis repair metric.

  The certified representation supplies the finite admissible alignment and
  matching spaces.  This file defines the metric as exact minimization over
  those spaces; it does not replace them with a canonical ordering.
-/

namespace Section3.RepairMetric

inductive ProjectionAuthority where
  | certifiedProjection
  | fixtureClaim
  deriving DecidableEq, Repr

structure ProducerObservationBinding where
  semanticProfile : Nat
  observationKey : Nat
  authority : ProjectionAuthority
  deriving DecidableEq, Repr

def permitsKernelCheckedComparison
    (left right : ProducerObservationBinding) : Bool :=
  left.authority == .certifiedProjection &&
    right.authority == .certifiedProjection &&
    left.semanticProfile == right.semanticProfile

theorem equal_fixture_keys_do_not_authorize_a_kernel_check
    (profile key : Nat) :
    permitsKernelCheckedComparison
      ⟨profile, key, .fixtureClaim⟩
      ⟨profile, key, .fixtureClaim⟩ = false := by
  simp [permitsKernelCheckedComparison]

theorem certified_projection_pair_authorizes_a_kernel_check
    (profile leftKey rightKey : Nat) :
    permitsKernelCheckedComparison
      ⟨profile, leftKey, .certifiedProjection⟩
      ⟨profile, rightKey, .certifiedProjection⟩ = true := by
  simp [permitsKernelCheckedComparison]

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

/- Lexical paths establish source binding identity before prenexing. Once the
   producer has certified a prenex coordinate, metric admissibility consumes
   the complete certified scope payload instead. Keeping the obsolete source
   path in that comparison would reject equivalent presentations; erasing an
   exchange class would allow an unsupported crossing. -/
inductive BindingRole where
  | parameter
  | matrix
  deriving DecidableEq, Repr

structure ScopeOwner where
  role : BindingRole
  phase : Nat
  deriving DecidableEq, Repr

structure CertifiedScopeCore where
  owner : ScopeOwner
  tuple : QuantifierTuple
  certifiedDomain : Nat
  dependencies : List Nat
  deriving DecidableEq, Repr

structure IntraViewOrbitEvidence where
  owner : ScopeOwner
  coordinate : Nat
  orbit : List Nat
  deriving DecidableEq, Repr

def repeatedCoordinateConsistent
    (first second : IntraViewOrbitEvidence) : Prop :=
  first.owner = second.owner →
    first.coordinate = second.coordinate →
    first.orbit = second.orbit

theorem repeated_coordinate_requires_one_orbit
    (first second : IntraViewOrbitEvidence)
    (consistent : repeatedCoordinateConsistent first second)
    (sameOwner : first.owner = second.owner)
    (sameCoordinate : first.coordinate = second.coordinate) :
    first.orbit = second.orbit := by
  exact consistent sameOwner sameCoordinate

structure ProjectedPrenexBinding where
  certified : CertifiedScopeCore
  exchangeClass : Nat
  coordinate : Nat
  sourcePath : List Nat
  certifiedOrbit : List Nat
  prenexPathErasureCertified : Bool
  deriving DecidableEq, Repr

def globalBindingIdentity
    (binding : ProjectedPrenexBinding) : ScopeOwner × Nat :=
  (binding.certified.owner, binding.coordinate)

def sameCertifiedOrbit
    (first second : ProjectedPrenexBinding) : Prop :=
  first.certified.owner = second.certified.owner ∧
    second.coordinate ∈ first.certifiedOrbit ∧
    first.coordinate ∈ second.certifiedOrbit

def matrixPathCompatible
    (left right : ProjectedPrenexBinding) : Prop :=
  (left.prenexPathErasureCertified = true ∧
      right.prenexPathErasureCertified = true) ∨
    left.sourcePath = right.sourcePath

def ProjectedPrenexBinding.EvidenceWellFormed
    (binding : ProjectedPrenexBinding) : Prop :=
  match binding.certified.owner.role with
  | .parameter => binding.certifiedOrbit = [] ∧
      binding.prenexPathErasureCertified = false
  | .matrix => binding.coordinate ∈ binding.certifiedOrbit ∧
      (binding.prenexPathErasureCertified = true ∨
        binding.sourcePath ≠ [])

theorem parameter_evidence_cannot_claim_orbit_or_prenex_authority
    (binding : ProjectedPrenexBinding)
    (parameter : binding.certified.owner.role = .parameter)
    (wellFormed : binding.EvidenceWellFormed) :
    binding.certifiedOrbit = [] ∧
      binding.prenexPathErasureCertified = false := by
  simpa [ProjectedPrenexBinding.EvidenceWellFormed, parameter] using wellFormed

theorem uncertified_matrix_evidence_retains_nonempty_path
    (binding : ProjectedPrenexBinding)
    (matrix : binding.certified.owner.role = .matrix)
    (uncertified : binding.prenexPathErasureCertified = false)
    (wellFormed : binding.EvidenceWellFormed) :
    binding.sourcePath ≠ [] := by
  have evidence : binding.coordinate ∈ binding.certifiedOrbit ∧
      (binding.prenexPathErasureCertified = true ∨ binding.sourcePath ≠ []) := by
    simpa [ProjectedPrenexBinding.EvidenceWellFormed, matrix] using wellFormed
  exact evidence.2.resolve_left (by simp [uncertified])

structure ScopedExchangePair where
  owner : ScopeOwner
  leftClass : Nat
  rightClass : Nat
  deriving DecidableEq, Repr

def scopedLeftKey (pair : ScopedExchangePair) : ScopeOwner × Nat :=
  (pair.owner, pair.leftClass)

def scopedRightKey (pair : ScopedExchangePair) : ScopeOwner × Nat :=
  (pair.owner, pair.rightClass)

structure ExchangeAlignment where
  pairs : List ScopedExchangePair
  leftInjective : (pairs.map scopedLeftKey).Nodup
  rightInjective : (pairs.map scopedRightKey).Nodup
  orderPreserving :
    ∀ {first second : ScopedExchangePair},
      first ∈ pairs →
      second ∈ pairs →
      first.owner = second.owner →
      first.leftClass < second.leftClass →
      first.rightClass < second.rightClass

def alignedMatrixBlock
    (alignment : ExchangeAlignment)
    (left right : ProjectedPrenexBinding) : Prop :=
  ⟨left.certified.owner, left.exchangeClass, right.exchangeClass⟩ ∈
    alignment.pairs

def projectedPrenexCompatible
    (alignment : ExchangeAlignment)
    (left right : ProjectedPrenexBinding) : Prop :=
  left.certified = right.certified ∧
    match left.certified.owner.role with
    | .parameter => left.coordinate = right.coordinate
    | .matrix => alignedMatrixBlock alignment left right ∧
        matrixPathCompatible left right

theorem certified_prenex_compatibility_ignores_obsolete_source_path
    (payload : CertifiedScopeCore)
    (matrixOwner : payload.owner.role = .matrix)
    (leftExchange rightExchange : Nat)
    (leftCoordinate rightCoordinate : Nat)
    (leftPath rightPath : List Nat)
    (leftOrbit rightOrbit : List Nat)
    (alignment : ExchangeAlignment)
    (aligned :
      ScopedExchangePair.mk payload.owner leftExchange rightExchange ∈
        alignment.pairs) :
    projectedPrenexCompatible alignment
      ⟨payload, leftExchange, leftCoordinate, leftPath, leftOrbit, true⟩
      ⟨payload, rightExchange, rightCoordinate, rightPath, rightOrbit, true⟩ := by
  constructor
  · rfl
  · simp [matrixOwner, alignedMatrixBlock, aligned, matrixPathCompatible]

theorem uncertified_prenex_paths_are_not_erased
    (payload : CertifiedScopeCore)
    (matrixOwner : payload.owner.role = .matrix)
    (leftExchange rightExchange : Nat)
    (leftCoordinate rightCoordinate : Nat)
    (leftPath rightPath : List Nat)
    (differentPath : leftPath ≠ rightPath)
    (leftOrbit rightOrbit : List Nat)
    (alignment : ExchangeAlignment) :
    ¬ projectedPrenexCompatible alignment
      ⟨payload, leftExchange, leftCoordinate, leftPath, leftOrbit, false⟩
      ⟨payload, rightExchange, rightCoordinate, rightPath, rightOrbit, false⟩ := by
  intro compatible
  have matrixCompatible := compatible.2
  rw [matrixOwner] at matrixCompatible
  have pathCompatible : matrixPathCompatible
      ⟨payload, leftExchange, leftCoordinate, leftPath, leftOrbit, false⟩
      ⟨payload, rightExchange, rightCoordinate, rightPath, rightOrbit, false⟩ := by
    exact matrixCompatible.2
  simp [matrixPathCompatible, differentPath] at pathCompatible

theorem certified_prenex_compatibility_requires_explicit_exchange_alignment
    (alignment : ExchangeAlignment)
    (left right : ProjectedPrenexBinding)
    (matrixOwner : left.certified.owner.role = .matrix)
    (notAligned :
      ScopedExchangePair.mk
        left.certified.owner left.exchangeClass right.exchangeClass ∉
          alignment.pairs) :
    ¬ projectedPrenexCompatible alignment left right := by
  intro compatible
  have matrixCompatible := compatible.2
  rw [matrixOwner] at matrixCompatible
  have aligned : alignedMatrixBlock alignment left right := by
    exact matrixCompatible.1
  exact notAligned aligned

theorem parameter_compatibility_requires_its_coordinate
    (alignment : ExchangeAlignment)
    (left right : ProjectedPrenexBinding)
    (sameCore : left.certified = right.certified)
    (parameterOwner : left.certified.owner.role = .parameter) :
    projectedPrenexCompatible alignment left right ↔
      left.coordinate = right.coordinate := by
  have rightOwner : right.certified.owner.role = .parameter := by
    rw [← sameCore]
    exact parameterOwner
  simp [projectedPrenexCompatible, sameCore, rightOwner]

theorem crossing_exchange_blocks_are_rejected
    (alignment : ExchangeAlignment)
    (owner : ScopeOwner)
    (forward : ScopedExchangePair.mk owner 0 1 ∈ alignment.pairs)
    (backward : ScopedExchangePair.mk owner 1 0 ∈ alignment.pairs) : False := by
  have increasing : (0 : Nat) < 1 := by decide
  have impossible : 1 < 0 :=
    alignment.orderPreserving forward backward rfl increasing
  exact (Nat.not_lt_zero 1) impossible

theorem distinct_owners_separate_equal_local_exchange_ids
    (firstOwner secondOwner : ScopeOwner)
    (different : firstOwner ≠ secondOwner) :
    scopedLeftKey ⟨firstOwner, 0, 1⟩ ≠
      scopedLeftKey ⟨secondOwner, 0, 0⟩ := by
  simp [scopedLeftKey, different]

inductive PrenexQuantifier where
  | all
  | some
  | lone
  | one
  | no
  | notOne
  | notLone
  deriving DecidableEq, Repr

structure BinderPresentation where
  quantifier : PrenexQuantifier
  sourcePath : List Nat
  deriving DecidableEq, Repr

def sameExchangeRun
    (left right : BinderPresentation) : Bool :=
  if left.quantifier != right.quantifier then false
  else
    match left.quantifier with
    | .all | .some => true
    | _ => left.sourcePath == right.sourcePath

def nextExchangeClass
    (previousClass : Nat)
    (previous current : BinderPresentation) : Nat :=
  if sameExchangeRun previous current then
    previousClass
  else
    previousClass + 1

theorem all_and_some_ignore_presentation_path
    (leftPath rightPath : List Nat) :
    sameExchangeRun ⟨.all, leftPath⟩ ⟨.all, rightPath⟩ = true ∧
      sameExchangeRun ⟨.some, leftPath⟩ ⟨.some, rightPath⟩ = true := by
  simp [sameExchangeRun]

theorem nonexchangeable_quantifiers_split_distinct_paths :
    sameExchangeRun ⟨.lone, [0]⟩ ⟨.lone, [1]⟩ = false ∧
      sameExchangeRun ⟨.one, [0]⟩ ⟨.one, [1]⟩ = false ∧
      sameExchangeRun ⟨.no, [0]⟩ ⟨.no, [1]⟩ = false ∧
      sameExchangeRun ⟨.notOne, [0]⟩ ⟨.notOne, [1]⟩ = false ∧
      sameExchangeRun ⟨.notLone, [0]⟩ ⟨.notLone, [1]⟩ = false := by
  decide

theorem nonexchangeable_distinct_path_advances_exchange_class
    (previousClass : Nat) :
    nextExchangeClass previousClass
      ⟨.lone, [0]⟩ ⟨.lone, [1]⟩ = previousClass + 1 := by
  simp [nextExchangeClass, sameExchangeRun]

theorem continuous_all_run_preserves_exchange_class
    (previousClass : Nat)
    (leftPath rightPath : List Nat) :
    nextExchangeClass previousClass
      ⟨.all, leftPath⟩ ⟨.all, rightPath⟩ = previousClass := by
  simp [nextExchangeClass, sameExchangeRun]

structure ScopedMatchingProblem where
  leftBindings : List ProjectedPrenexBinding
  rightBindings : List ProjectedPrenexBinding
  fixedPairs : List (Nat × Nat)
  leftGlobalIdentitiesUnique :
    (leftBindings.map globalBindingIdentity).Nodup
  rightGlobalIdentitiesUnique :
    (rightBindings.map globalBindingIdentity).Nodup
  leftEvidenceWellFormed :
    ∀ binding ∈ leftBindings, binding.EvidenceWellFormed
  rightEvidenceWellFormed :
    ∀ binding ∈ rightBindings, binding.EvidenceWellFormed

structure ScopedBindingCandidate where
  pairs : List (Nat × Nat)
  deriving DecidableEq, Repr

def ScopedBindingCandidate.PreservesCertifiedOrbits
    (problem : ScopedMatchingProblem)
    (candidate : ScopedBindingCandidate) : Prop :=
  ∀ first ∈ candidate.pairs,
    first ∉ problem.fixedPairs →
    ∀ second ∈ candidate.pairs,
      second ∉ problem.fixedPairs →
      ∀ leftFirst rightFirst leftSecond rightSecond,
        problem.leftBindings[first.1]? = some leftFirst →
        problem.rightBindings[first.2]? = some rightFirst →
        problem.leftBindings[second.1]? = some leftSecond →
        problem.rightBindings[second.2]? = some rightSecond →
        (sameCertifiedOrbit leftFirst leftSecond ↔
          sameCertifiedOrbit rightFirst rightSecond)

def ScopedBindingCandidate.Valid
    (problem : ScopedMatchingProblem)
    (alignment : ExchangeAlignment)
    (candidate : ScopedBindingCandidate) : Prop :=
  (∀ pair ∈ problem.fixedPairs, pair ∈ candidate.pairs) ∧
    (candidate.pairs.map Prod.fst).Nodup ∧
    (candidate.pairs.map Prod.snd).Nodup ∧
    (∀ pair ∈ candidate.pairs,
      ∃ left right,
          problem.leftBindings[pair.1]? = some left ∧
          problem.rightBindings[pair.2]? = some right ∧
          (pair ∈ problem.fixedPairs ∨
            projectedPrenexCompatible alignment left right)) ∧
    candidate.PreservesCertifiedOrbits problem

def ScopedBindingCandidate.Maximum
    (problem : ScopedMatchingProblem)
    (alignment : ExchangeAlignment)
    (candidate : ScopedBindingCandidate) : Prop :=
  candidate.Valid problem alignment ∧
    ∀ other : ScopedBindingCandidate,
      other.Valid problem alignment →
      other.pairs.length ≤ candidate.pairs.length

theorem maximum_scoped_matching_uses_only_owned_compatible_bindings
    (problem : ScopedMatchingProblem)
    (alignment : ExchangeAlignment)
    (candidate : ScopedBindingCandidate)
    (maximum : candidate.Maximum problem alignment)
    (pair : Nat × Nat)
    (member : pair ∈ candidate.pairs) :
    ∃ left right,
      problem.leftBindings[pair.1]? = some left ∧
      problem.rightBindings[pair.2]? = some right ∧
      (pair ∈ problem.fixedPairs ∨
        projectedPrenexCompatible alignment left right) := by
  exact maximum.1.2.2.2.1 pair member

theorem maximum_scoped_matching_preserves_certified_orbits
    (problem : ScopedMatchingProblem)
    (alignment : ExchangeAlignment)
    (candidate : ScopedBindingCandidate)
    (maximum : candidate.Maximum problem alignment) :
    candidate.PreservesCertifiedOrbits problem := by
  exact maximum.1.2.2.2.2

theorem split_target_orbits_block_a_dynamic_pairing
    (problem : ScopedMatchingProblem)
    (alignment : ExchangeAlignment)
    (candidate : ScopedBindingCandidate)
    (valid : candidate.Valid problem alignment)
    (first second : Nat × Nat)
    (firstMember : first ∈ candidate.pairs)
    (secondMember : second ∈ candidate.pairs)
    (firstDynamic : first ∉ problem.fixedPairs)
    (secondDynamic : second ∉ problem.fixedPairs)
    (leftFirst rightFirst leftSecond rightSecond : ProjectedPrenexBinding)
    (leftFirstAt : problem.leftBindings[first.1]? = some leftFirst)
    (rightFirstAt : problem.rightBindings[first.2]? = some rightFirst)
    (leftSecondAt : problem.leftBindings[second.1]? = some leftSecond)
    (rightSecondAt : problem.rightBindings[second.2]? = some rightSecond)
    (sameLeftOrbit : sameCertifiedOrbit leftFirst leftSecond)
    (differentRightOrbit : ¬ sameCertifiedOrbit rightFirst rightSecond) : False := by
  have preserves := valid.2.2.2.2 first firstMember firstDynamic
    second secondMember secondDynamic leftFirst rightFirst leftSecond rightSecond
    leftFirstAt rightFirstAt leftSecondAt rightSecondAt
  exact differentRightOrbit (preserves.mp sameLeftOrbit)

theorem scoped_problem_contains_one_entry_per_global_identity
    (problem : ScopedMatchingProblem) :
    (problem.leftBindings.map globalBindingIdentity).Nodup ∧
      (problem.rightBindings.map globalBindingIdentity).Nodup := by
  exact ⟨problem.leftGlobalIdentitiesUnique,
    problem.rightGlobalIdentitiesUnique⟩

theorem maximum_scoped_matching_has_maximum_cardinality
    (problem : ScopedMatchingProblem)
    (alignment : ExchangeAlignment)
    (candidate other : ScopedBindingCandidate)
    (maximum : candidate.Maximum problem alignment)
    (validOther : other.Valid problem alignment) :
    other.pairs.length ≤ candidate.pairs.length := by
  exact maximum.2 other validOther

def ScopedBindingCandidate.Optimal
    (problem : ScopedMatchingProblem)
    (alignment : ExchangeAlignment)
    (matrixCost : ScopedBindingCandidate → Nat)
    (candidate : ScopedBindingCandidate) : Prop :=
  candidate.Maximum problem alignment ∧
    ∀ other : ScopedBindingCandidate,
      other.Maximum problem alignment →
      matrixCost candidate ≤ matrixCost other

theorem optimal_scoped_matching_minimizes_matrix_cost_among_maximum
    (problem : ScopedMatchingProblem)
    (alignment : ExchangeAlignment)
    (matrixCost : ScopedBindingCandidate → Nat)
    (candidate other : ScopedBindingCandidate)
    (optimal : candidate.Optimal problem alignment matrixCost)
    (otherMaximum : other.Maximum problem alignment) :
    matrixCost candidate ≤ matrixCost other := by
  exact optimal.2 other otherMaximum

structure GlobalBindingOccurrence where
  identity : ScopeOwner × Nat
  usePhase : Nat
  localIndex : Nat
  deriving DecidableEq, Repr

def applyGlobalBindingMap
    (mapping : ScopeOwner × Nat → Option (ScopeOwner × Nat))
    (occurrence : GlobalBindingOccurrence) : Option (ScopeOwner × Nat) :=
  mapping occurrence.identity

theorem repeated_temporal_owner_occurrences_share_one_mapping
    (mapping : ScopeOwner × Nat → Option (ScopeOwner × Nat))
    (first second : GlobalBindingOccurrence)
    (sameIdentity : first.identity = second.identity) :
    applyGlobalBindingMap mapping first =
      applyGlobalBindingMap mapping second := by
  simp [applyGlobalBindingMap, sameIdentity]

structure CanonicalPhaseReindex where
  forward : Nat → Nat
  injective : Function.Injective forward

def reindexScopeOwner
    (reindex : CanonicalPhaseReindex)
    (owner : ScopeOwner) : ScopeOwner :=
  match owner.role with
  | .parameter => owner
  | .matrix => ⟨.matrix, reindex.forward owner.phase⟩

def reindexGlobalBindingIdentity
    (reindex : CanonicalPhaseReindex)
    (identity : ScopeOwner × Nat) : ScopeOwner × Nat :=
  (reindexScopeOwner reindex identity.1, identity.2)

theorem coherent_phase_reindex_preserves_repeated_owner_identity
    (reindex : CanonicalPhaseReindex)
    (first second : ScopeOwner × Nat)
    (sameIdentity : first = second) :
    reindexGlobalBindingIdentity reindex first =
      reindexGlobalBindingIdentity reindex second := by
  exact congrArg (reindexGlobalBindingIdentity reindex) sameIdentity

theorem canonical_phase_reindex_is_injective_on_matrix_identities
    (reindex : CanonicalPhaseReindex)
    (first second : ScopeOwner × Nat)
    (firstMatrix : first.1.role = .matrix)
    (secondMatrix : second.1.role = .matrix)
    (sameReindex : reindexGlobalBindingIdentity reindex first =
      reindexGlobalBindingIdentity reindex second) :
    first.1.phase = second.1.phase ∧ first.2 = second.2 := by
  constructor
  · apply reindex.injective
    simpa [reindexGlobalBindingIdentity, reindexScopeOwner,
      firstMatrix, secondMatrix] using
        congrArg (fun value => value.1.phase) sameReindex
  · simpa [reindexGlobalBindingIdentity] using
      congrArg (fun value => value.2) sameReindex

def sameOwnerScopedOrbitPayload
    (left right : ProjectedPrenexBinding) : Bool :=
  left.certified == right.certified &&
    left.exchangeClass == right.exchangeClass

def expectedCertifiedOrbit
    (bindings : List ProjectedPrenexBinding)
    (binding : ProjectedPrenexBinding) : List Nat :=
  (bindings.filter (sameOwnerScopedOrbitPayload binding)).map
    ProjectedPrenexBinding.coordinate

def completeCertifiedOrbitLedger
    (bindings : List ProjectedPrenexBinding) : Bool :=
  bindings.all (fun binding =>
    binding.certifiedOrbit == expectedCertifiedOrbit bindings binding)

def orbitLedgerTuple : QuantifierTuple :=
  ⟨.all, 0, .one, 0⟩

def orbitLedgerOwner : ScopeOwner := ⟨.matrix, 0⟩

def orbitLedgerCore : CertifiedScopeCore :=
  ⟨orbitLedgerOwner, orbitLedgerTuple, 0, []⟩

def orbitLedgerBinding (coordinate : Nat) (orbit : List Nat) :
    ProjectedPrenexBinding :=
  ⟨orbitLedgerCore, 0, coordinate, [], orbit, true⟩

theorem complete_two_coordinate_orbit_ledger_is_accepted :
    completeCertifiedOrbitLedger
      [orbitLedgerBinding 0 [0, 1], orbitLedgerBinding 1 [0, 1]] = true := by
  decide

theorem split_two_coordinate_orbit_ledger_is_rejected :
    completeCertifiedOrbitLedger
      [orbitLedgerBinding 0 [0], orbitLedgerBinding 1 [1]] = false := by
  decide

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

inductive Permutation3 where
  | p012
  | p021
  | p102
  | p120
  | p201
  | p210
  deriving DecidableEq, Repr

def allPermutation3 : List Permutation3 :=
  [.p012, .p021, .p102, .p120, .p201, .p210]

def applyPermutation3 (permutation : Permutation3) (coordinate : Fin 3) : Fin 3 :=
  match permutation, coordinate with
  | .p012, 0 => 0 | .p012, 1 => 1 | .p012, 2 => 2
  | .p021, 0 => 0 | .p021, 1 => 2 | .p021, 2 => 1
  | .p102, 0 => 1 | .p102, 1 => 0 | .p102, 2 => 2
  | .p120, 0 => 1 | .p120, 1 => 2 | .p120, 2 => 0
  | .p201, 0 => 2 | .p201, 1 => 0 | .p201, 2 => 1
  | .p210, 0 => 2 | .p210, 1 => 1 | .p210, 2 => 0

theorem bounded_three_coordinate_enumerator_is_complete
    (permutation : Permutation3) :
    permutation ∈ allPermutation3 := by
  cases permutation <;> simp [allPermutation3]

theorem every_bounded_three_coordinate_candidate_is_evaluated
    (cost : Permutation3 → Nat)
    (permutation : Permutation3) :
    cost permutation ∈ allPermutation3.map cost := by
  exact List.mem_map_of_mem
    (bounded_three_coordinate_enumerator_is_complete permutation)

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
