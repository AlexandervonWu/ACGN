import Std

namespace ACGN.Section3.Phase2

/- The formal model deliberately keeps arity, sibling quotient, flattening,
   and unit authority in distinct fields. -/

inductive ArityPolicy where
  | finite (admitted : List Nat)
  | atLeast (minimum : Nat)
  deriving DecidableEq, Repr

def ArityPolicy.admits : ArityPolicy -> Nat -> Bool
  | .finite admitted, arity => admitted.contains arity
  | .atLeast minimum, arity => minimum <= arity

def ArityPolicy.positiveDownwardClosed : ArityPolicy -> Bool
  | .atLeast minimum => minimum <= 1
  | .finite admitted => admitted.all fun outer =>
      (List.range outer).all fun offset => admitted.contains (offset + 1)

def ArityPolicy.flatSpliceClosed : ArityPolicy -> Bool
  | .atLeast _ => true
  | .finite admitted => admitted.all fun outer =>
      outer == 0 || admitted.all fun nested =>
        admitted.contains (outer + nested - 1)

inductive SiblingQuotient where
  | sequence
  | bag
  | set
  deriving DecidableEq, Repr

structure Laws where
  associative : Bool
  commutative : Bool
  idempotent : Bool
  unit : Bool
  deriving DecidableEq, Repr

def quotientLawMatch : SiblingQuotient -> Laws -> Bool
  | .sequence, laws => !laws.commutative && !laws.idempotent
  | .bag, laws => laws.commutative && !laws.idempotent
  | .set, laws => laws.commutative && laws.idempotent

structure PortPolicy where
  arities : ArityPolicy
  quotient : SiblingQuotient
  laws : Laws
  flat : Bool
  oneRootContainerPort : Bool
  elementTypeEqualsResultType : Bool
  deriving DecidableEq, Repr

def PortPolicy.valid (policy : PortPolicy) : Bool :=
  quotientLawMatch policy.quotient policy.laws &&
  (policy.quotient != .set || policy.arities.positiveDownwardClosed) &&
  (!policy.laws.unit || policy.arities.admits 0) &&
  (!policy.flat ||
    (policy.oneRootContainerPort &&
     policy.elementTypeEqualsResultType &&
     policy.laws.associative &&
     policy.arities.flatSpliceClosed &&
     (!policy.arities.admits 0 || policy.laws.unit)))

def seqPlus : PortPolicy :=
  { arities := .atLeast 1
    quotient := .sequence
    laws := Laws.mk false false false false
    flat := false
    oneRootContainerPort := true
    elementTypeEqualsResultType := true }

def flatSeqWithoutA : PortPolicy := { seqPlus with flat := true }

def bagTwo : PortPolicy :=
  { arities := .finite [2]
    quotient := .bag
    laws := Laws.mk false true false false
    flat := false
    oneRootContainerPort := true
    elementTypeEqualsResultType := true }

def flatBagPlus : PortPolicy :=
  { arities := .atLeast 1
    quotient := .bag
    laws := Laws.mk true true false false
    flat := true
    oneRootContainerPort := true
    elementTypeEqualsResultType := true }

def ordinaryKZero : PortPolicy :=
  { arities := .finite [0]
    quotient := .sequence
    laws := Laws.mk false false false false
    flat := false
    oneRootContainerPort := true
    elementTypeEqualsResultType := true }

def flatKZeroWithoutAU : PortPolicy := { ordinaryKZero with flat := true }

def flatKZeroWithAU : PortPolicy :=
  { ordinaryKZero with
    laws := Laws.mk true false false true
    flat := true }

def flatSetPlus : PortPolicy :=
  { arities := .atLeast 1
    quotient := .set
    laws := Laws.mk true true true false
    flat := true
    oneRootContainerPort := true
    elementTypeEqualsResultType := true }

theorem ordinary_seq_plus_has_no_associativity_license :
    seqPlus.laws.associative = false := rfl

theorem ordinary_seq_plus_is_valid : seqPlus.valid = true := by native_decide

theorem flat_seq_plus_without_associativity_rejects :
    flatSeqWithoutA.valid = false := by native_decide

theorem nonflat_bag_two_is_commutative_only :
    And (bagTwo.valid = true)
      (And (bagTwo.laws.commutative = true)
        (And (bagTwo.laws.associative = false)
          (bagTwo.laws.idempotent = false))) := by native_decide

theorem flat_bag_plus_requires_exactly_A_and_C_here :
    And (flatBagPlus.valid = true)
      (And (flatBagPlus.laws.associative = true)
        (And (flatBagPlus.laws.commutative = true)
          (And (flatBagPlus.laws.idempotent = false)
            (flatBagPlus.laws.unit = false)))) := by native_decide

theorem ordinary_zero_arity_needs_no_unit : ordinaryKZero.valid = true := by
  native_decide

theorem flat_zero_arity_without_A_and_U_rejects :
    flatKZeroWithoutAU.valid = false := by native_decide

theorem flat_zero_arity_with_A_and_U_is_valid :
    flatKZeroWithAU.valid = true := by native_decide

theorem nonempty_variadic_rejects_empty_storage :
    (ArityPolicy.atLeast 1).admits 0 = false := by decide

theorem invalid_set_downward_closure_rejects :
    (ArityPolicy.finite [1, 3]).positiveDownwardClosed = false := by decide

theorem invalid_flat_splice_closure_rejects :
    (ArityPolicy.finite [1, 2]).flatSpliceClosed = false := by decide

theorem valid_set_requires_positive_downward_closure
    (policy : PortPolicy)
    (valid : policy.valid = true)
    (isSet : policy.quotient = .set) :
    policy.arities.positiveDownwardClosed = true := by
  cases policy with
  | mk arities quotient laws flat root types =>
      cases quotient <;> simp_all [PortPolicy.valid]

theorem valid_flat_requires_splice_closure
    (policy : PortPolicy)
    (valid : policy.valid = true)
    (flat : policy.flat = true) :
    policy.arities.flatSpliceClosed = true := by
  cases policy with
  | mk arities quotient laws policyFlat root types =>
      cases splice : arities.flatSpliceClosed <;>
        simp_all [PortPolicy.valid]

theorem valid_zero_admitting_flat_requires_A_and_U
    (policy : PortPolicy)
    (valid : policy.valid = true)
    (flat : policy.flat = true)
    (zero : policy.arities.admits 0 = true) :
    policy.laws.associative = true ∧ policy.laws.unit = true := by
  cases policy with
  | mk arities quotient laws policyFlat root types =>
      cases laws with
      | mk associative commutative idempotent unit =>
          cases associative <;> cases unit <;>
            simp_all [PortPolicy.valid]

theorem positive_at_least_policy_rejects_zero
    (minimum : Nat) (positive : 0 < minimum) :
    (ArityPolicy.atLeast minimum).admits 0 = false := by
  simp [ArityPolicy.admits]
  omega

theorem flat_set_plus_is_ACI_without_unit :
    And (flatSetPlus.valid = true)
      (And (flatSetPlus.laws.associative = true)
        (And (flatSetPlus.laws.commutative = true)
          (And (flatSetPlus.laws.idempotent = true)
            (flatSetPlus.laws.unit = false)))) := by native_decide

theorem policy_fields_jointly_determine_policy
    (left right : PortPolicy)
    (arities : left.arities = right.arities)
    (quotient : left.quotient = right.quotient)
    (laws : left.laws = right.laws)
    (flat : left.flat = right.flat)
    (root : left.oneRootContainerPort = right.oneRootContainerPort)
    (types : left.elementTypeEqualsResultType =
      right.elementTypeEqualsResultType) :
    left = right := by
  cases left
  cases right
  simp_all

theorem valid_flat_requires_one_root_container
    (policy : PortPolicy)
    (valid : policy.valid = true)
    (flat : policy.flat = true) :
    policy.oneRootContainerPort = true := by
  cases policy with
  | mk arities quotient laws policyFlat root types =>
      cases root <;> simp_all [PortPolicy.valid]

theorem valid_flat_requires_homogeneous_element_and_result_types
    (policy : PortPolicy)
    (valid : policy.valid = true)
    (flat : policy.flat = true) :
    policy.elementTypeEqualsResultType = true := by
  cases policy with
  | mk arities quotient laws policyFlat root types =>
      cases types <;> simp_all [PortPolicy.valid]

inductive BooleanFlatResult where
  | constant (value : Bool)
  | stored (first second : Bool) (rest : List Bool)
  deriving DecidableEq, Repr

def smartAnd : List Bool -> BooleanFlatResult
  | [] => .constant true
  | [value] => .constant value
  | first :: second :: rest => .stored first second rest

def BooleanFlatResult.storedArity : BooleanFlatResult -> Nat
  | .constant _ => 0
  | .stored _ _ rest => rest.length + 2

def BooleanFlatResult.hasUnitEvidence : BooleanFlatResult -> Bool
  | _ => false

theorem boolean_empty_collapses_by_smart_constructor :
    smartAnd [] = .constant true := rfl

theorem boolean_singleton_collapses_by_smart_constructor (value : Bool) :
    smartAnd [value] = .constant value := rfl

theorem stored_boolean_carrier_is_nonempty_and_has_no_unit
    (first second : Bool) (rest : List Bool) :
    (.stored first second rest : BooleanFlatResult).storedArity > 0 ∧
      (.stored first second rest : BooleanFlatResult).hasUnitEvidence = false := by
  simp [BooleanFlatResult.storedArity, BooleanFlatResult.hasUnitEvidence]

/- Exact relational alternatives need not have the same column names to share
   the UNION/INTERSECTION ACI carrier.  They do have to be nonempty relation
   types of one common arity.  This is a type-admission model, not a proof that
   the Java exact-type bridge refines it. -/

structure RelationAlternative where
  identity : String
  arity : Nat
  deriving DecidableEq, Repr

def samePositiveArity : List RelationAlternative -> Bool
  | [] => false
  | first :: rest =>
      first.arity > 0 && rest.all (fun alternative => alternative.arity == first.arity)

def unrelatedUnaryAlternatives : List RelationAlternative :=
  [{ identity := "A", arity := 1 }, { identity := "B", arity := 1 }]

theorem unrelated_same_arity_relations_admit_one_flat_carrier :
    samePositiveArity unrelatedUnaryAlternatives = true := by decide

theorem mixed_arity_relations_reject_one_flat_carrier :
    samePositiveArity
      [{ identity := "A", arity := 1 }, { identity := "R", arity := 2 }] = false := by
  decide

/- Multiplicity is observable in a bag and membership alone is observable in
   a set. These two observations separate AC from ACI. -/

def multiplicity (needle : Nat) (values : List Nat) : Nat :=
  (values.filter (fun value => value == needle)).length

def membership (needle : Nat) (values : List Nat) : Bool :=
  values.contains needle

theorem bag_retains_duplicate_occurrences : multiplicity 5 [5, 5] = 2 := by decide

theorem set_observation_is_idempotent :
    membership 5 [5, 5] = membership 5 [5] := by decide

theorem role_sensitive_sequence_observes_swap :
    Not ([11, 12] = [12, 11]) := by decide

/- This finite policy is the formal counterpart of AlloyOperatorPolicy's
   conservative matrix. -/

inductive Opcode where
  | and | or | union | intersect
  | integerAdd | integerMultiply
  | equality | inequality | iff | disjoint
  | join | arrow | call | list | disjointList | totalOrderList
  | quantifier | declaration
  deriving DecidableEq, Repr

inductive OverflowMode where
  | modular
  | forbid
  deriving DecidableEq, Repr

structure Profile where
  overflow : OverflowMode
  deriving DecidableEq, Repr

structure CommutativityWitnessIndex where
  operator : Opcode
  profile : Profile
  arity : Nat
  permutation : List Nat
  deriving DecidableEq, Repr

structure IdempotenceWitnessIndex where
  operator : Opcode
  profile : Profile
  outerArity : Nat
  quotientSurjection : List Nat
  deriving DecidableEq, Repr

structure AssociativityWitnessIndex where
  operator : Opcode
  profile : Profile
  outerArity : Nat
  nestedArity : Nat
  splicePosition : Nat
  deriving DecidableEq, Repr

structure UnitWitnessIndex where
  operator : Opcode
  profile : Profile
  emptyEndpoint : List Nat
  deletionEndpoint : List Nat
  deriving DecidableEq, Repr

theorem commutativity_witness_index_is_injective :
    Function.Injective (fun witness : CommutativityWitnessIndex =>
      (witness.operator, witness.profile, witness.arity,
        witness.permutation)) := by
  intro left right equal
  cases left
  cases right
  simp_all

theorem idempotence_witness_index_is_injective :
    Function.Injective (fun witness : IdempotenceWitnessIndex =>
      (witness.operator, witness.profile, witness.outerArity,
        witness.quotientSurjection)) := by
  intro left right equal
  cases left
  cases right
  simp_all

theorem associativity_witness_index_is_injective :
    Function.Injective (fun witness : AssociativityWitnessIndex =>
      (witness.operator, witness.profile, witness.outerArity,
        witness.nestedArity, witness.splicePosition)) := by
  intro left right equal
  cases left
  cases right
  simp_all

theorem unit_witness_index_is_injective :
    Function.Injective (fun witness : UnitWitnessIndex =>
      (witness.operator, witness.profile, witness.emptyEndpoint,
        witness.deletionEndpoint)) := by
  intro left right equal
  cases left
  cases right
  simp_all

def isAlwaysFlat : Opcode -> Bool
  | .and | .or | .union | .intersect => true
  | _ => false

def usesFlatConstruction (profile : Profile) : Opcode -> Bool
  | .integerAdd | .integerMultiply => profile.overflow == .modular
  | opcode => isAlwaysFlat opcode

def siblingQuotient (_profile : Profile) : Opcode -> SiblingQuotient
  | .and | .or | .union | .intersect => .set
  | .integerAdd | .integerMultiply => .bag
  | .equality | .inequality | .iff | .disjoint => .bag
  | _ => .sequence

def exactRegistryAssociativityAuthority
    (requestedOperator registeredOperator : Opcode)
    (requestedProfile registeredProfile : Profile) : Bool :=
  (requestedOperator == registeredOperator) &&
    (requestedProfile == registeredProfile) &&
    usesFlatConstruction registeredProfile registeredOperator

theorem issued_associativity_requires_exact_registry_entry
    {requestedOperator registeredOperator : Opcode}
    {requestedProfile registeredProfile : Profile}
    (accepted : exactRegistryAssociativityAuthority
      requestedOperator registeredOperator
      requestedProfile registeredProfile = true) :
    requestedOperator = registeredOperator ∧
      requestedProfile = registeredProfile ∧
      usesFlatConstruction registeredProfile registeredOperator = true := by
  simp [exactRegistryAssociativityAuthority] at accepted
  exact ⟨accepted.1.1, accepted.1.2, accepted.2⟩

def recursiveFlattenAllowed
    (sameHead typedAssociativityEvidence : Bool) : Bool :=
  sameHead && typedAssociativityEvidence

theorem recursive_flatten_iff_same_head_and_typed_A_evidence
    (sameHead typedAssociativityEvidence : Bool) :
    recursiveFlattenAllowed sameHead typedAssociativityEvidence = true ↔
      sameHead = true ∧ typedAssociativityEvidence = true := by
  cases sameHead <;> cases typedAssociativityEvidence <;>
    decide

theorem alloy_flat_whitelist_is_exact (profile : Profile) (opcode : Opcode) :
    usesFlatConstruction profile opcode = true <->
      Or (isAlwaysFlat opcode = true)
        (And (Or (opcode = .integerAdd) (opcode = .integerMultiply))
          (profile.overflow = .modular)) := by
  cases profile with
  | mk overflow => cases overflow <;> cases opcode <;> decide

theorem calls_joins_arrows_lists_binders_and_decls_are_not_flat
    (profile : Profile) :
    And (usesFlatConstruction profile .call = false)
      (And (usesFlatConstruction profile .join = false)
        (And (usesFlatConstruction profile .arrow = false)
          (And (usesFlatConstruction profile .list = false)
            (And (usesFlatConstruction profile .disjointList = false)
              (And (usesFlatConstruction profile .totalOrderList = false)
                (And (usesFlatConstruction profile .quantifier = false)
                  (usesFlatConstruction profile .declaration = false))))))) := by
  cases profile with
  | mk overflow => cases overflow <;> decide

theorem equality_inequality_and_iff_are_C_not_A_or_I (profile : Profile) :
    And (siblingQuotient profile .equality = .bag)
      (And (siblingQuotient profile .inequality = .bag)
        (And (siblingQuotient profile .iff = .bag)
          (And (usesFlatConstruction profile .equality = false)
            (And (usesFlatConstruction profile .inequality = false)
              (usesFlatConstruction profile .iff = false))))) := by
  cases profile with
  | mk overflow => cases overflow <;> decide

theorem disjoint_is_nonflat_bag (profile : Profile) :
    And (siblingQuotient profile .disjoint = .bag)
      (usesFlatConstruction profile .disjoint = false) := by
  cases profile with
  | mk overflow => cases overflow <;> decide

theorem semantic_disjoint_and_structural_disjoint_list_are_distinct
    (profile : Profile) :
    siblingQuotient profile .disjoint = .bag ∧
    siblingQuotient profile .disjointList = .sequence ∧
    usesFlatConstruction profile .disjoint = false ∧
    usesFlatConstruction profile .disjointList = false := by
  cases profile with
  | mk overflow => cases overflow <;> decide

theorem integer_flattening_is_profile_bounded :
    And (usesFlatConstruction { overflow := .modular } .integerAdd = true)
      (And (usesFlatConstruction { overflow := .forbid } .integerAdd = false)
        (And (usesFlatConstruction { overflow := .modular } .integerMultiply = true)
          (usesFlatConstruction { overflow := .forbid } .integerMultiply = false))) := by
  decide

/- Four-bit, signed, overflow-forbidding addition is not associative as a
   partial operation: the left association overflows before the final -1. -/

def add4 (left right : Int) : Option Int :=
  let total := left + right
  if -8 <= total && total <= 7 then some total else none

def optionAdd4 : Option Int -> Int -> Option Int
  | some left, right => add4 left right
  | none, _ => none

theorem four_bit_left_association_overflows :
    optionAdd4 (add4 7 1) (-1) = none := by native_decide

theorem four_bit_right_association_succeeds :
    optionAdd4 (add4 1 (-1)) 7 = some 7 := by native_decide

theorem no_overflow_addition_reassociation_is_unsound :
    Not (optionAdd4 (add4 7 1) (-1) = optionAdd4 (add4 1 (-1)) 7) := by
  native_decide

end ACGN.Section3.Phase2
