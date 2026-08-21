/-
Independent Phase 3 contracts for exact types, semantic profiles, endpoint
indices, and evidence ownership.

This file deliberately models the contract rather than importing producer
classes, wire fixtures, hashes, or test results. Compilation proves only the
stated abstract obligations. Java/parser/serialization refinement remains a
separate blocked gate. Checked with Lean 4.33.0.
-/

namespace Phase3ExactTypesEndpoints

inductive TypeKind where
  | bool
  | int
  | relation
  | constructor
deriving DecidableEq, Repr

structure ExactType where
  kind : TypeKind
  symbol : String
  columns : List String
  arguments : List String
deriving DecidableEq, Repr

def wellFormedType (exact : ExactType) : Prop :=
  match exact.kind with
  | .bool | .int => exact.symbol = "" ∧ exact.columns = [] ∧ exact.arguments = []
  | .relation => exact.symbol = "" ∧ exact.columns ≠ [] ∧ exact.arguments = []
  | .constructor => exact.symbol ≠ "" ∧ exact.columns = []

def relationArity : ExactType -> Option Nat
  | ⟨.relation, _, columns, _⟩ => some columns.length
  | _ => none

def relationColumns : ExactType -> Option (List String)
  | ⟨.relation, _, columns, _⟩ => some columns
  | _ => none

def unaryA : ExactType := ⟨.relation, "", ["A"], []⟩
def binaryAB : ExactType := ⟨.relation, "", ["A", "B"], []⟩
def binaryBA : ExactType := ⟨.relation, "", ["B", "A"], []⟩

theorem binaryAB_is_well_formed : wellFormedType binaryAB := by
  simp [wellFormedType, binaryAB]

theorem exact_relation_arity_is_retained :
    relationArity binaryAB = some 2 := by
  rfl

theorem ordered_columns_are_observable : binaryAB ≠ binaryBA := by
  decide

theorem relation_is_not_generic_unary : binaryAB ≠ unaryA := by
  decide

inductive MissingTypeDecision where
  | accept (exact : ExactType)
  | reject
deriving DecidableEq, Repr

def requireExactType : Option ExactType -> MissingTypeDecision
  | some exact => .accept exact
  | none => .reject

theorem missing_type_fails_closed : requireExactType none = .reject := by
  rfl

theorem missing_type_does_not_invent_relation :
    requireExactType none ≠ .accept unaryA := by
  decide

inductive OverflowMode where
  | forbid
  | modular
deriving DecidableEq, Repr

structure SemanticProfile where
  bitwidth : Nat
  overflow : OverflowMode
  temporalMode : String
  rewriteMode : String
  signatureVersion : String
deriving DecidableEq, Repr

def profilePayload (profile : SemanticProfile) :
    Nat × OverflowMode × String × String × String :=
  (profile.bitwidth, profile.overflow, profile.temporalMode,
    profile.rewriteMode, profile.signatureVersion)

theorem profile_payload_is_injective : Function.Injective profilePayload := by
  intro left right equalPayload
  cases left with
  | mk leftWidth leftOverflow leftTemporal leftRewrite leftSignature =>
      cases right with
      | mk rightWidth rightOverflow rightTemporal rightRewrite rightSignature =>
          simp only [profilePayload, Prod.mk.injEq] at equalPayload
          rcases equalPayload with
            ⟨widthEq, overflowEq, temporalEq, rewriteEq, signatureEq⟩
          cases widthEq
          cases overflowEq
          cases temporalEq
          cases rewriteEq
          cases signatureEq
          rfl

inductive Carrier where
  | seq
  | bag
  | set
deriving DecidableEq, Repr

inductive LawParameter where
  | associativity (outerArity nestedArity splicePosition : Nat)
  | commutativity (permutation : List Nat)
  | idempotence (quotientSurjection : List Nat)
  | unit (emptyEndpoint deletionEndpoint : String)
deriving DecidableEq, Repr

structure LawIndex where
  profile : SemanticProfile
  operatorIdentity : String
  resultType : ExactType
  elementType : ExactType
  schemaPath : List Nat
  carrier : Carrier
  admittedArities : List Nat
  parameter : LawParameter
  sourceTheoryDigest : String
  leftEndpoint : String
  rightEndpoint : String
deriving DecidableEq, Repr

def lawIndexPayload (index : LawIndex) :=
  (index.profile, index.operatorIdentity, index.resultType, index.elementType,
    index.schemaPath, index.carrier, index.admittedArities, index.parameter,
    index.sourceTheoryDigest, index.leftEndpoint, index.rightEndpoint)

theorem complete_law_index_is_injective : Function.Injective lawIndexPayload := by
  intro left right equalPayload
  cases left
  cases right
  simp only [lawIndexPayload, Prod.mk.injEq] at equalPayload
  rcases equalPayload with
    ⟨profileEq, operatorEq, resultEq, elementEq, pathEq, carrierEq,
      aritiesEq, parameterEq, theoryEq, leftEq, rightEq⟩
  cases profileEq
  cases operatorEq
  cases resultEq
  cases elementEq
  cases pathEq
  cases carrierEq
  cases aritiesEq
  cases parameterEq
  cases theoryEq
  cases leftEq
  cases rightEq
  rfl

/- A bounded replay model makes the construction evidence an independently
   derived function of visible source data.  It does not model Java decoding. -/

structure FlatReplaySource where
  sourceTree : List String
  sourceContext : String
  operatorIdentity : String
deriving DecidableEq, Repr

structure FlatReplayEvidence where
  sourceTree : List String
  spliceLedger : List (List Nat × Nat × Nat × Nat × String)
  applicationTrace : List (Nat × String × List Nat)
deriving DecidableEq, Repr

def deriveFlatReplay
    (source : FlatReplaySource)
    (splices : List (List Nat × Nat × Nat × Nat × String))
    (trace : List (Nat × String × List Nat)) : FlatReplayEvidence :=
  ⟨source.sourceTree, splices, trace⟩

def acceptsFlatReplay
    (source : FlatReplaySource)
    (splices : List (List Nat × Nat × Nat × Nat × String))
    (trace : List (Nat × String × List Nat))
    (evidence : FlatReplayEvidence) : Bool :=
  decide (evidence = deriveFlatReplay source splices trace)

theorem exact_flat_replay_accepts
    (source : FlatReplaySource)
    (splices : List (List Nat × Nat × Nat × Nat × String))
    (trace : List (Nat × String × List Nat)) :
    acceptsFlatReplay source splices trace
      (deriveFlatReplay source splices trace) = true := by
  simp [acceptsFlatReplay]

theorem flat_replay_payload_is_injective
    (source : FlatReplaySource) :
    Function.Injective (fun pair :
        List (List Nat × Nat × Nat × Nat × String) ×
          List (Nat × String × List Nat) =>
      deriveFlatReplay source pair.1 pair.2) := by
  intro left right equalEvidence
  cases left with
  | mk leftSplices leftTrace =>
      cases right with
      | mk rightSplices rightTrace =>
          simp only [deriveFlatReplay, FlatReplayEvidence.mk.injEq] at equalEvidence
          exact Prod.ext equalEvidence.2.1 equalEvidence.2.2

structure ContainerReplaySource where
  orderedInputs : List String
  schemaIdentity : String
  sourceContext : String
deriving DecidableEq, Repr

structure ContainerReplayEvidence where
  orderedInputs : List String
  normalizedOutputs : List String
  quotientFibers : List (List Nat)
deriving DecidableEq, Repr

def deriveContainerReplay
    (source : ContainerReplaySource)
    (outputs : List String)
    (fibers : List (List Nat)) : ContainerReplayEvidence :=
  ⟨source.orderedInputs, outputs, fibers⟩

def acceptsContainerReplay
    (source : ContainerReplaySource)
    (outputs : List String)
    (fibers : List (List Nat))
    (evidence : ContainerReplayEvidence) : Bool :=
  decide (evidence = deriveContainerReplay source outputs fibers)

theorem exact_container_replay_accepts
    (source : ContainerReplaySource)
    (outputs : List String)
    (fibers : List (List Nat)) :
    acceptsContainerReplay source outputs fibers
      (deriveContainerReplay source outputs fibers) = true := by
  simp [acceptsContainerReplay]

theorem container_replay_payload_is_injective
    (source : ContainerReplaySource) :
    Function.Injective (fun pair : List String × List (List Nat) =>
      deriveContainerReplay source pair.1 pair.2) := by
  intro left right equalEvidence
  cases left with
  | mk leftOutputs leftFibers =>
      cases right with
      | mk rightOutputs rightFibers =>
          simp only [deriveContainerReplay,
            ContainerReplayEvidence.mk.injEq] at equalEvidence
          exact Prod.ext equalEvidence.2.1 equalEvidence.2.2

inductive BinderActionKind where
  | freshAlpha
  | descriptorAutomorphism (permutation : List Nat)
deriving DecidableEq, Repr

theorem alpha_is_not_nonidentity_automorphism (permutation : List Nat) :
    BinderActionKind.freshAlpha ≠
      BinderActionKind.descriptorAutomorphism permutation := by
  intro impossible
  cases impossible

structure BinderOccurrenceIndex where
  descriptor : String
  occurrenceMap : List (String × String)
  action : BinderActionKind
  root : String
  path : List Nat
  context : List (String × ExactType)
  leftEndpoint : String
  rightEndpoint : String
deriving DecidableEq, Repr

def binderIndexPayload (index : BinderOccurrenceIndex) :=
  (index.descriptor, index.occurrenceMap, index.action, index.root,
    index.path, index.context, index.leftEndpoint, index.rightEndpoint)

theorem complete_binder_index_is_injective :
    Function.Injective binderIndexPayload := by
  intro left right equalPayload
  cases left
  cases right
  simp only [binderIndexPayload, Prod.mk.injEq] at equalPayload
  rcases equalPayload with
    ⟨descriptorEq, occurrenceEq, actionEq, rootEq, pathEq, contextEq,
      leftEq, rightEq⟩
  cases descriptorEq
  cases occurrenceEq
  cases actionEq
  cases rootEq
  cases pathEq
  cases contextEq
  cases leftEq
  cases rightEq
  rfl

/- This finite S2 instance is deliberately executable: the verifier derives
   the full closure from generators and derives each occurrence conjugation. -/

inductive Permutation2 where
  | identity
  | swap
deriving DecidableEq, Repr

def compose2 : Permutation2 -> Permutation2 -> Permutation2
  | .identity, right => right
  | left, .identity => left
  | .swap, .swap => .identity

def inverse2 (value : Permutation2) : Permutation2 := value

def closure2 (generators : List Permutation2) : List Permutation2 :=
  if .swap ∈ generators then [.identity, .swap] else [.identity]

def occurrenceConjugation2
    (embedding automorphism : Permutation2) : Permutation2 :=
  compose2 (compose2 (inverse2 embedding) automorphism) embedding

structure BinderReplaySource2 where
  generators : List Permutation2
  occurrenceEmbeddings : List Permutation2
deriving DecidableEq, Repr

structure BinderReplayEvidence2 where
  completeClosure : List Permutation2
  occurrenceConjugations : List (List Permutation2)
deriving DecidableEq, Repr

def deriveBinderReplay2 (source : BinderReplaySource2) : BinderReplayEvidence2 :=
  let closure := closure2 source.generators
  ⟨closure,
    source.occurrenceEmbeddings.map (fun embedding =>
      closure.map (occurrenceConjugation2 embedding))⟩

def acceptsBinderReplay2
    (source : BinderReplaySource2)
    (evidence : BinderReplayEvidence2) : Bool :=
  decide (evidence = deriveBinderReplay2 source)

theorem exact_binder_closure_and_conjugations_accept
    (source : BinderReplaySource2) :
    acceptsBinderReplay2 source (deriveBinderReplay2 source) = true := by
  simp [acceptsBinderReplay2]

theorem missing_swap_from_generated_closure_rejects :
    acceptsBinderReplay2
      ⟨[.swap], [.identity]⟩
      ⟨[.identity], [[.identity]]⟩ = false := by
  native_decide

theorem missing_occurrence_conjugation_rejects :
    acceptsBinderReplay2
      ⟨[.swap], [.identity, .swap]⟩
      ⟨[.identity, .swap], [[.identity, .swap]]⟩ = false := by
  native_decide

inductive ConstructionKind where
  | none
  | flat
  | container
deriving DecidableEq, Repr

structure ReplaySource where
  owner : String
  operatorIdentity : String
  schemaPath : List Nat
  construction : ConstructionKind
deriving DecidableEq, Repr

structure EvidenceReference where
  owner : String
  operatorIdentity : String
  schemaPath : List Nat
  construction : ConstructionKind
deriving DecidableEq, Repr

def obligationFromSource (source : ReplaySource) : EvidenceReference :=
  ⟨source.owner, source.operatorIdentity, source.schemaPath,
    source.construction⟩

def acceptsEvidence (source : ReplaySource) (reference : EvidenceReference) : Bool :=
  decide (obligationFromSource source = reference)

theorem exact_source_obligation_accepts (source : ReplaySource) :
    acceptsEvidence source (obligationFromSource source) = true := by
  simp [acceptsEvidence]

theorem stale_owner_rejects
    (source : ReplaySource)
    (otherOwner : String)
    (different : otherOwner ≠ source.owner) :
    acceptsEvidence source
      ⟨otherOwner, source.operatorIdentity, source.schemaPath,
        source.construction⟩ = false := by
  have reversed : source.owner ≠ otherOwner := Ne.symm different
  simp [acceptsEvidence, obligationFromSource, reversed]

structure WireRecord where
  tag : String
  scalars : List String
  orderedChildIds : List String
deriving DecidableEq, Repr

def canonicalWirePayload (record : WireRecord) :=
  (record.tag, record.scalars, record.orderedChildIds)

structure WireClaim where
  contentPayload : String × List String × List String
  orderedChildIds : List String
deriving DecidableEq, Repr

def deriveWireClaim (record : WireRecord) : WireClaim :=
  ⟨canonicalWirePayload record, record.orderedChildIds⟩

def acceptsWireClaim (record : WireRecord) (claim : WireClaim) : Bool :=
  decide (claim = deriveWireClaim record)

theorem canonical_wire_payload_is_injective :
    Function.Injective canonicalWirePayload := by
  intro left right equalPayload
  cases left
  cases right
  simp only [canonicalWirePayload, Prod.mk.injEq] at equalPayload
  rcases equalPayload with ⟨tagEq, scalarsEq, childrenEq⟩
  cases tagEq
  cases scalarsEq
  cases childrenEq
  rfl

theorem exact_wire_claim_accepts (record : WireRecord) :
    acceptsWireClaim record (deriveWireClaim record) = true := by
  simp [acceptsWireClaim]

theorem reordered_wire_children_reject
    (record : WireRecord)
    (replacement : List String)
    (different : replacement ≠ record.orderedChildIds) :
    acceptsWireClaim record
      ⟨canonicalWirePayload record, replacement⟩ = false := by
  simp [acceptsWireClaim, deriveWireClaim, canonicalWirePayload, different]

structure CertifiedArtifact where
  exactType : ExactType
  profile : SemanticProfile
  lawIndices : List LawIndex
  binderIndices : List BinderOccurrenceIndex
  replaySources : List ReplaySource
deriving DecidableEq, Repr

def retainedArtifactPayload (artifact : CertifiedArtifact) :=
  (artifact.exactType, artifact.profile, artifact.lawIndices,
    artifact.binderIndices, artifact.replaySources)

theorem retained_artifact_payload_is_injective :
    Function.Injective retainedArtifactPayload := by
  intro left right equalPayload
  cases left
  cases right
  simp only [retainedArtifactPayload, Prod.mk.injEq] at equalPayload
  rcases equalPayload with
    ⟨typeEq, profileEq, lawsEq, bindersEq, sourcesEq⟩
  cases typeEq
  cases profileEq
  cases lawsEq
  cases bindersEq
  cases sourcesEq
  rfl

inductive ProjectionLifecycle where
  | mutable
  | certified
deriving DecidableEq, Repr

structure ProjectionSource where
  phaseTopology : List String
  binderPayloads : List String
  matrixPayloads : List String
  occurrenceIdentities : List Nat
deriving DecidableEq, Repr

structure ProjectionEvidence where
  source : ProjectionSource
  canonicalDigest : String
deriving DecidableEq, Repr

def mutateProjectionSource
    (lifecycle : ProjectionLifecycle)
    (replacement : ProjectionSource) : Option ProjectionSource :=
  match lifecycle with
  | .mutable => some replacement
  | .certified => none

def acceptsProjection
    (evidence : ProjectionEvidence)
    (source : ProjectionSource)
    (digest : String) : Bool :=
  decide (source = evidence.source ∧ digest = evidence.canonicalDigest)

theorem certified_source_mutation_rejects
    (replacement : ProjectionSource) :
    mutateProjectionSource .certified replacement = none := by
  rfl

theorem exact_projection_source_accepts (evidence : ProjectionEvidence) :
    acceptsProjection evidence evidence.source evidence.canonicalDigest = true := by
  simp [acceptsProjection]

theorem stale_projection_source_rejects
    (evidence : ProjectionEvidence)
    (replacement : ProjectionSource)
    (different : replacement ≠ evidence.source) :
    acceptsProjection evidence replacement evidence.canonicalDigest = false := by
  simp [acceptsProjection, different]

theorem forged_projection_digest_rejects
    (evidence : ProjectionEvidence)
    (digest : String)
    (different : digest ≠ evidence.canonicalDigest) :
    acceptsProjection evidence evidence.source digest = false := by
  simp [acceptsProjection, different]

end Phase3ExactTypesEndpoints
