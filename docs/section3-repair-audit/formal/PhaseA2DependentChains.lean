import Std

namespace ACGN.Section3.PhaseA2

abbrev Col := Nat

/- ARROW is ordered concatenation, so source association disappears while
   position and multiplicity remain observable. -/
def arrowCols (left right : List Col) : List Col := left ++ right

theorem arrow_reassociation (a b c : List Col) :
    arrowCols (arrowCols a b) c = arrowCols a (arrowCols b c) := by
  simp [arrowCols, List.append_assoc]

theorem arrow_order_is_observable :
    Not (arrowCols [0] [1] = arrowCols [1] [0]) := by
  decide

theorem arrow_duplicate_is_preserved :
    arrowCols [0] [0] = [0, 0] := by
  rfl

/- Both dependent operators retain their operands in a positional sequence.
These two finite witnesses rule out observing that carrier as a Bag or Set. -/
def joinOperandSeq (operands : List (List Col)) : List (List Col) := operands

theorem join_order_is_observable :
    Not (joinOperandSeq [[0], [1]] = joinOperandSeq [[1], [0]]) := by
  decide

theorem join_duplicate_is_preserved :
    joinOperandSeq [[0], [0]] = [[0], [0]] := by
  rfl

/- JOIN is not unconditionally associative. A sound variadic chain therefore
   gives every interior operand distinct left and right boundary positions. -/

structure LeftTuple (Atom : Type) where
  pre : List Atom
  boundary : Atom

structure MiddleTuple (Atom : Type) where
  leftBoundary : Atom
  interior : List Atom
  rightBoundary : Atom

structure RightTuple (Atom : Type) where
  boundary : Atom
  suffix : List Atom

def joinLeftMiddle {Atom : Type}
    (left : LeftTuple Atom) (middle : MiddleTuple Atom)
    (_boundaryEq : left.boundary = middle.leftBoundary) : LeftTuple Atom :=
  { pre := left.pre ++ middle.interior
    boundary := middle.rightBoundary }

def joinMiddleRight {Atom : Type}
    (middle : MiddleTuple Atom) (right : RightTuple Atom)
    (_boundaryEq : middle.rightBoundary = right.boundary) : RightTuple Atom :=
  { boundary := middle.leftBoundary
    suffix := middle.interior ++ right.suffix }

def joinLeftRight {Atom : Type}
    (left : LeftTuple Atom) (right : RightTuple Atom)
    (_matches : left.boundary = right.boundary) : List Atom :=
  left.pre ++ right.suffix

theorem guarded_join_tuple_reassociation {Atom : Type}
    (left : LeftTuple Atom)
    (middle : MiddleTuple Atom)
    (right : RightTuple Atom)
    (leftMatch : left.boundary = middle.leftBoundary)
    (rightMatch : middle.rightBoundary = right.boundary) :
    joinLeftRight
        (joinLeftMiddle left middle leftMatch)
        right rightMatch =
      joinLeftRight
        left
        (joinMiddleRight middle right rightMatch)
        leftMatch := by
  simp [joinLeftRight, joinLeftMiddle, joinMiddleRight, List.append_assoc]

def JoinLM {Atom : Type}
    (R : LeftTuple Atom -> Prop)
    (S : MiddleTuple Atom -> Prop)
    (output : LeftTuple Atom) : Prop :=
  exists left middle,
    R left /\ S middle /\
    exists boundaryEq : left.boundary = middle.leftBoundary,
      output = joinLeftMiddle left middle boundaryEq

def JoinMR {Atom : Type}
    (S : MiddleTuple Atom -> Prop)
    (T : RightTuple Atom -> Prop)
    (output : RightTuple Atom) : Prop :=
  exists middle right,
    S middle /\ T right /\
    exists boundaryEq : middle.rightBoundary = right.boundary,
      output = joinMiddleRight middle right boundaryEq

def JoinLR {Atom : Type}
    (R : LeftTuple Atom -> Prop)
    (T : RightTuple Atom -> Prop)
    (output : List Atom) : Prop :=
  exists left right,
    R left /\ T right /\
    exists boundaryEq : left.boundary = right.boundary,
      output = joinLeftRight left right boundaryEq

theorem guarded_join_relation_reassociation {Atom : Type}
    (R : LeftTuple Atom -> Prop)
    (S : MiddleTuple Atom -> Prop)
    (T : RightTuple Atom -> Prop)
    (output : List Atom) :
    JoinLR (JoinLM R S) T output <-> JoinLR R (JoinMR S T) output := by
  constructor
  · rintro ⟨joined, right, ⟨left, middle, hR, hS, leftMatch, rfl⟩,
      hT, rightMatch, rfl⟩
    exact ⟨left, joinMiddleRight middle right rightMatch, hR,
      ⟨middle, right, hS, hT, rightMatch, rfl⟩,
      leftMatch, guarded_join_tuple_reassociation
        left middle right leftMatch rightMatch⟩
  · rintro ⟨left, joined, hR,
      ⟨middle, right, hS, hT, rightMatch, rfl⟩,
      leftMatch, rfl⟩
    exact ⟨joinLeftMiddle left middle leftMatch, right,
      ⟨left, middle, hR, hS, leftMatch, rfl⟩,
      hT, rightMatch, (guarded_join_tuple_reassociation
        left middle right leftMatch rightMatch).symm⟩

def joinFlatGuard (operands : List (List Col)) : Bool :=
  if operands.length <= 2 then true
  else (operands.drop 1).dropLast.all fun columns => 2 <= columns.length

theorem unary_interior_join_has_no_flat_license :
    joinFlatGuard [[0, 0], [0], [0, 0]] = false := by decide

theorem binary_interior_join_has_flat_license :
    joinFlatGuard [[0, 0], [0, 0], [0, 0]] = true := by decide

inductive CounterAtom where
  | a | b
  deriving DecidableEq, BEq

def splitLast {Atom : Type} : List Atom -> Option (List Atom × Atom)
  | [] => none
  | head :: tail =>
      match splitLast tail with
      | none => some ([], head)
      | some (pre, last) => some (head :: pre, last)

def tupleJoin [BEq Atom] (left right : List Atom) : Option (List Atom) :=
  match splitLast left, right with
  | some (pre, leftBoundary), rightBoundary :: suffix =>
      if leftBoundary == rightBoundary then some (pre ++ suffix) else none
  | _, _ => none

def relationJoin [BEq Atom]
    (left right : List (List Atom)) : List (List Atom) :=
  left.flatMap fun leftTuple => right.filterMap fun rightTuple =>
    tupleJoin leftTuple rightTuple

def counterR : List (List CounterAtom) := [[.a, .b]]
def counterS : List (List CounterAtom) := [[.b]]
def counterT : List (List CounterAtom) := [[.a, .a]]

theorem unguarded_join_left_value :
    relationJoin (relationJoin counterR counterS) counterT = [[.a]] := by
  native_decide

theorem unguarded_join_right_value :
    relationJoin counterR (relationJoin counterS counterT) = [] := by
  native_decide

theorem unguarded_join_is_not_associative :
    Not (relationJoin (relationJoin counterR counterS) counterT =
      relationJoin counterR (relationJoin counterS counterT)) := by
  native_decide

inductive StoredType where
  | int
  | carrier (name : Nat)
  | relation (columns : List Col)
  | unsupported (name : Nat)
  deriving DecidableEq

def primitiveRelationView : StoredType -> Option (List Col)
  | .int => some [0]
  | .carrier name => some [name + 1]
  | _ => none

def relationView : StoredType -> Option (List Col)
  | .relation columns => some columns
  | stored => primitiveRelationView stored

theorem exact_relation_leaf (columns : List Col) :
    relationView (.relation columns) = some columns := by
  rfl

theorem primitive_int_leaf : relationView .int = some [0] := by
  rfl

theorem primitive_carrier_leaf (name : Nat) :
    relationView (.carrier name) = some [name + 1] := by
  rfl

theorem parameter_spelling_has_no_independent_authority (ordinal : Nat) :
    relationView (.unsupported ordinal) = none := by
  rfl

theorem successful_relation_view_has_only_two_rule_families
    (stored : StoredType)
    (columns : List Col)
    (success : relationView stored = some columns) :
    (exists exact, stored = .relation exact /\ columns = exact) \/
    (stored = .int /\ columns = [0]) \/
    (exists name, stored = .carrier name /\ columns = [name + 1]) := by
  cases stored with
  | int =>
      simp [relationView, primitiveRelationView] at success
      exact Or.inr (Or.inl ⟨rfl, success.symm⟩)
  | carrier name =>
      simp [relationView, primitiveRelationView] at success
      exact Or.inr (Or.inr ⟨name, rfl, success.symm⟩)
  | relation exact =>
      simp [relationView] at success
      exact Or.inl ⟨exact, rfl, success.symm⟩
  | unsupported name =>
      simp [relationView, primitiveRelationView] at success

theorem unsupported_leaf_has_no_proof (name : Nat) :
    relationView (.unsupported name) = none := by
  rfl

inductive TypeProvenance where
  | exact (columns : List Col)
  | absent
  deriving DecidableEq

def exactColumns : TypeProvenance -> Option (List Col)
  | .exact columns => some columns
  | .absent => none

theorem absent_type_does_not_invent_univ :
    exactColumns .absent = none := by
  rfl

theorem explicit_univ_is_retained (univColumn : Col) :
    exactColumns (.exact [univColumn]) = some [univColumn] := by
  rfl

def chainTypingEligible (univColumn : Col) (columns : List Col) : Bool :=
  !columns.contains univColumn

theorem explicit_univ_has_no_chain_typing_authority (univColumn : Col) :
    chainTypingEligible univColumn [univColumn] = false := by
  simp [chainTypingEligible]

inductive ChainKind where
  | join
  | arrow
  deriving DecidableEq

structure ChainIndex where
  kind : ChainKind
  operands : List (List Col)
  result : List Col
  deriving DecidableEq

theorem exact_index_retains_kind
    (left right : ChainIndex) (h : left = right) : left.kind = right.kind := by
  exact congrArg ChainIndex.kind h

theorem exact_index_retains_operands
    (left right : ChainIndex) (h : left = right) :
    left.operands = right.operands := by
  exact congrArg ChainIndex.operands h

theorem exact_index_retains_result
    (left right : ChainIndex) (h : left = right) : left.result = right.result := by
  exact congrArg ChainIndex.result h

def joinTypeStep (left right : List Col) : Option (List Col) :=
  match splitLast left, right with
  | some (pre, leftBoundary), rightBoundary :: suffix =>
      if leftBoundary = rightBoundary then some (pre ++ suffix) else none
  | _, _ => none

def chainTypeStep (kind : ChainKind)
    (left right : List Col) : Option (List Col) :=
  match kind with
  | .arrow => some (left ++ right)
  | .join => joinTypeStep left right

def dependentTypeFold (kind : ChainKind) :
    List (List Col) -> Option (List Col)
  | [] => none
  | first :: rest => rest.foldlM (chainTypeStep kind) first

structure ValidDependentFold (index : ChainIndex) : Prop where
  nonemptyOperands : index.operands ≠ []
  exactResult : dependentTypeFold index.kind index.operands = some index.result

theorem valid_dependent_fold_rechecks_every_step_and_exact_result
    (index : ChainIndex) (valid : ValidDependentFold index) :
    index.operands ≠ [] /\
      dependentTypeFold index.kind index.operands = some index.result :=
  ⟨valid.nonemptyOperands, valid.exactResult⟩

theorem dependent_fold_result_is_unique
    (kind : ChainKind) (operands : List (List Col))
    (leftResult rightResult : List Col)
    (left : dependentTypeFold kind operands = some leftResult)
    (right : dependentTypeFold kind operands = some rightResult) :
    leftResult = rightResult := by
  rw [left] at right
  exact Option.some.inj right

structure CompleteChainIndex where
  kind : ChainKind
  profile : String
  sourceAssociation : String
  operandTypes : List (List Col)
  result : List Col
  target : String
  theoryVersion : String
  theoryDigest : String
  deriving DecidableEq

theorem equal_complete_chain_indices_bind_every_field
    (left right : CompleteChainIndex) (same : left = right) :
    left.kind = right.kind /\
    left.profile = right.profile /\
    left.sourceAssociation = right.sourceAssociation /\
    left.operandTypes = right.operandTypes /\
    left.result = right.result /\
    left.target = right.target /\
    left.theoryVersion = right.theoryVersion /\
    left.theoryDigest = right.theoryDigest := by
  subst right
  simp

theorem complete_chain_index_fields_are_injective
    (left right : CompleteChainIndex)
    (kind : left.kind = right.kind)
    (profile : left.profile = right.profile)
    (source : left.sourceAssociation = right.sourceAssociation)
    (operands : left.operandTypes = right.operandTypes)
    (result : left.result = right.result)
    (target : left.target = right.target)
    (version : left.theoryVersion = right.theoryVersion)
    (digest : left.theoryDigest = right.theoryDigest) :
    left = right := by
  cases left
  cases right
  simp_all

structure SourcePlan where
  lineage : Nat
  certificate : Nat
  deriving DecidableEq

def UniqueLineages (plans : List SourcePlan) : Prop :=
  forall p, p ∈ plans -> forall q, q ∈ plans -> p.lineage = q.lineage -> p = q

theorem lineage_transfer_is_functional
    (plans : List SourcePlan)
    (hUnique : UniqueLineages plans)
    (p q : SourcePlan)
    (hp : p ∈ plans)
    (hq : q ∈ plans)
    (same : p.lineage = q.lineage) :
    p.certificate = q.certificate := by
  exact congrArg SourcePlan.certificate (hUnique p hp q hq same)

def ReplayInjective {Root Certificate : Type}
    (assignment : Root -> Certificate) : Prop :=
  Function.Injective assignment

theorem one_certificate_cannot_replay_over_two_roots
    {Root Certificate : Type}
    (assignment : Root -> Certificate)
    (injective : ReplayInjective assignment)
    (left right : Root)
    (different : Not (left = right)) :
    Not (assignment left = assignment right) := by
  intro same
  exact different (injective same)

structure SourceCommitment where
  path : String
  typedSource : String
  content : String
  deriving DecidableEq

structure OccurrenceCertificate where
  source : SourceCommitment
  proofId : Nat
  deriving DecidableEq

structure OccurrenceBinding where
  lineage : Nat
  source : SourceCommitment
  certificate : OccurrenceCertificate
  deriving DecidableEq

def BindingAccepts
    (currentLineage : Nat)
    (currentSource : SourceCommitment)
    (binding : OccurrenceBinding) : Prop :=
  And (currentLineage = binding.lineage)
    (And (currentSource = binding.source)
      (binding.certificate.source = binding.source))

theorem accepted_binding_has_exact_lineage
    (currentLineage : Nat)
    (currentSource : SourceCommitment)
    (binding : OccurrenceBinding)
    (accepted : BindingAccepts currentLineage currentSource binding) :
    currentLineage = binding.lineage := accepted.1

theorem accepted_binding_has_exact_path_and_content
    (currentLineage : Nat)
    (currentSource : SourceCommitment)
    (binding : OccurrenceBinding)
    (accepted : BindingAccepts currentLineage currentSource binding) :
    currentSource = binding.source := accepted.2.1

theorem accepted_binding_certificate_commits_to_source
    (currentLineage : Nat)
    (currentSource : SourceCommitment)
    (binding : OccurrenceBinding)
    (accepted : BindingAccepts currentLineage currentSource binding) :
    binding.certificate.source = currentSource := by
  rw [accepted.2.1]
  exact accepted.2.2

theorem same_typed_source_swap_rejects
    (lineage : Nat)
    (currentSource boundSource : SourceCommitment)
    (different : Not (currentSource = boundSource))
    (certificate : OccurrenceCertificate) :
    Not (BindingAccepts lineage currentSource
      { lineage := lineage,
        source := boundSource,
        certificate := certificate }) := by
  intro accepted
  exact different accepted.2.1

theorem post_certificate_content_mutation_rejects
    (lineage : Nat)
    (path typedSource oldContent newContent : String)
    (different : Not (newContent = oldContent))
    (certificate : OccurrenceCertificate) :
    Not (BindingAccepts lineage
      (SourceCommitment.mk path typedSource newContent)
      (OccurrenceBinding.mk lineage
        (SourceCommitment.mk path typedSource oldContent)
        certificate)) := by
  intro accepted
  exact different (congrArg SourceCommitment.content accepted.2.1)

theorem typed_source_substitution_rejects
    (lineage : Nat)
    (path content oldTypedSource newTypedSource : String)
    (different : Not (newTypedSource = oldTypedSource))
    (certificate : OccurrenceCertificate) :
    Not (BindingAccepts lineage
      (SourceCommitment.mk path newTypedSource content)
      (OccurrenceBinding.mk lineage
        (SourceCommitment.mk path oldTypedSource content)
        certificate)) := by
  intro accepted
  exact different (congrArg SourceCommitment.typedSource accepted.2.1)

theorem certificate_source_substitution_rejects
    (lineage : Nat)
    (source otherSource : SourceCommitment)
    (different : Not (otherSource = source))
    (proofId : Nat) :
    Not (BindingAccepts lineage source
      { lineage := lineage,
        source := source,
        certificate := { source := otherSource, proofId := proofId } }) := by
  intro accepted
  exact different accepted.2.2

structure LedgerApplication where
  occurrencePath : String
  source : SourceCommitment
  deriving DecidableEq

structure LedgerConstruction where
  application : LedgerApplication
  certificateIndex : CompleteChainIndex
  deriving DecidableEq

def ConstructionAdmitted
    (sourceLedger : List LedgerApplication)
    (construction : LedgerConstruction) : Prop :=
  construction.application ∈ sourceLedger

theorem admitted_construction_has_concrete_recorded_source_application
    (sourceLedger : List LedgerApplication)
    (construction : LedgerConstruction)
    (accepted : ConstructionAdmitted sourceLedger construction) :
    construction.application ∈ sourceLedger :=
  accepted

theorem unrecorded_construction_is_not_admitted
    (sourceLedger : List LedgerApplication)
    (construction : LedgerConstruction)
    (absent : construction.application ∉ sourceLedger) :
    Not (ConstructionAdmitted sourceLedger construction) :=
  absent

inductive ChainAdmission where
  | certified (index : ChainIndex)
  | exactFixedBinary (kind : ChainKind) (left right : List Col)
  deriving DecidableEq

def hasChainEqualityAuthority : ChainAdmission -> Bool
  | .certified _ => true
  | .exactFixedBinary _ _ _ => false

def unsupportedChainFallback
    (kind : ChainKind) (left right : List Col) : ChainAdmission :=
  .exactFixedBinary kind left right

theorem unsupported_chain_falls_back_to_exact_fixed_binary
    (kind : ChainKind) (left right : List Col) :
    unsupportedChainFallback kind left right =
      .exactFixedBinary kind left right := by
  rfl

theorem unsupported_chain_fallback_has_no_equality_authority
    (kind : ChainKind) (left right : List Col) :
    hasChainEqualityAuthority (unsupportedChainFallback kind left right) = false := by
  rfl

structure ProjectionRequest where
  lineage : Nat
  source : SourceCommitment
  expectedIndex : CompleteChainIndex
  deriving DecidableEq

structure ProjectionEvidence where
  binding : OccurrenceBinding
  index : CompleteChainIndex
  deriving DecidableEq

def ProjectionAccepts
    (request : ProjectionRequest) (evidence : ProjectionEvidence) : Prop :=
  BindingAccepts request.lineage request.source evidence.binding /\
    evidence.index = request.expectedIndex

theorem accepted_projection_rechecks_occurrence_and_every_bound_index
    (request : ProjectionRequest)
    (evidence : ProjectionEvidence)
    (accepted : ProjectionAccepts request evidence) :
    request.lineage = evidence.binding.lineage /\
    request.source = evidence.binding.source /\
    evidence.binding.certificate.source = evidence.binding.source /\
    evidence.index = request.expectedIndex := by
  exact ⟨accepted.1.1, accepted.1.2.1, accepted.1.2.2, accepted.2⟩

structure AtomKey where
  identity : String
  exactType : String
  deriving DecidableEq

structure RepairAtom where
  display : String
  semantic : AtomKey
  deriving DecidableEq

def atomUpdateCost (left right : RepairAtom) : Nat :=
  if left.semantic = right.semantic then 0 else 1

theorem readable_spelling_is_not_an_edit
    (leftDisplay rightDisplay : String) (semantic : AtomKey) :
    atomUpdateCost
      { display := leftDisplay, semantic := semantic }
      { display := rightDisplay, semantic := semantic } = 0 := by
  simp [atomUpdateCost]

theorem exact_type_change_is_one_edit
    (display identity leftType rightType : String)
    (different : Not (leftType = rightType)) :
    atomUpdateCost
      { display := display,
        semantic := { identity := identity, exactType := leftType } }
      { display := display,
        semantic := { identity := identity, exactType := rightType } } = 1 := by
  simp [atomUpdateCost, different]

def admitConcreteDependent
    (declared derived : List Col) (hasExplicitPolymorphicUniv : Bool) : Bool :=
  if hasExplicitPolymorphicUniv then false else decide (declared = derived)

theorem concrete_result_mismatch_rejects
    (declared derived : List Col)
    (different : Not (declared = derived)) :
    admitConcreteDependent declared derived false = false := by
  simp [admitConcreteDependent, different]

theorem explicit_polymorphism_receives_no_flat_certificate
    (declared derived : List Col) :
    admitConcreteDependent declared derived true = false := by
  rfl

inductive AssociationLicense where
  | licensed
  | unlicensed
  deriving DecidableEq

def associationRepairDistance : AssociationLicense -> Nat
  | .licensed => 0
  | .unlicensed => 1

def associationCertifiedEqual : AssociationLicense -> Prop
  | .licensed => True
  | .unlicensed => False

theorem licensed_reassociation_is_certified_equal_and_zero_distance :
    associationCertifiedEqual .licensed /\
      associationRepairDistance .licensed = 0 := by
  exact ⟨True.intro, rfl⟩

theorem unlicensed_reassociation_is_not_certified_and_remains_nonzero :
    Not (associationCertifiedEqual .unlicensed) /\
      associationRepairDistance .unlicensed ≠ 0 := by
  constructor
  · intro impossible
    exact impossible
  · decide

structure ChainWireEvidence where
  index : CompleteChainIndex
  source : SourceCommitment
  typedSourceTree : String
  leafRules : List String
  leafProofs : List String
  applications : List String
  positionalSchemas : List String
  deriving DecidableEq

def replayChainWire
    (expected : ChainWireEvidence) (encoded : ChainWireEvidence) : Prop :=
  encoded = expected

theorem accepted_chain_wire_replay_reconstructs_every_committed_field
    (expected encoded : ChainWireEvidence)
    (accepted : replayChainWire expected encoded) :
    encoded.index = expected.index /\
    encoded.source = expected.source /\
    encoded.typedSourceTree = expected.typedSourceTree /\
    encoded.leafRules = expected.leafRules /\
    encoded.leafProofs = expected.leafProofs /\
    encoded.applications = expected.applications /\
    encoded.positionalSchemas = expected.positionalSchemas := by
  subst encoded
  simp

theorem any_chain_wire_field_difference_rejects
    (expected encoded : ChainWireEvidence)
    (different : encoded ≠ expected) :
    Not (replayChainWire expected encoded) :=
  different

structure SourceClass where
  memberCount : Nat
  leader : Nat
  self : Nat
  canonical : Nat

def PristineSource (source : SourceClass) : Prop :=
  And (source.memberCount = 1)
    (And (source.leader = source.self)
      (source.canonical = source.self))

theorem nonleader_union_is_not_pristine
    (source : SourceClass)
    (different : Not (source.leader = source.self)) :
    Not (PristineSource source) := by
  intro pristine
  exact different pristine.2.1

theorem noncanonical_union_is_not_pristine
    (source : SourceClass)
    (different : Not (source.canonical = source.self)) :
    Not (PristineSource source) := by
  intro pristine
  exact different pristine.2.2

end ACGN.Section3.PhaseA2
