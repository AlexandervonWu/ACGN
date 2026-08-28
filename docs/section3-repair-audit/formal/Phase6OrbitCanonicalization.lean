import Std

/-
Independent Phase 6 obligations and countermodels.

This file does not import producer code, fixtures, or certificates. It proves
the abstract contracts named below and deliberately preserves counterexamples
for obligations that the Java/wire implementation has not yet discharged.
Checked with Lean 4.33.0.
-/

namespace Phase6OrbitCanonicalization

inductive LeastState (α : Type) where
  | unset
  | present (value : α)
deriving DecidableEq, Repr

def considerNat : LeastState Nat -> Nat -> LeastState Nat
  | .unset, candidate => .present candidate
  | .present current, candidate => .present (Nat.min current candidate)

def minimumNat : List Nat -> LeastState Nat :=
  List.foldl considerNat .unset

theorem empty_minimum_is_unset : minimumNat [] = .unset := by
  rfl

theorem bottom_is_an_ordinary_minimum :
    minimumNat [4, 0, 3] = .present 0 := by
  decide

theorem first_candidate_is_present (candidate : Nat) :
    minimumNat [candidate] = .present candidate := by
  simp [minimumNat, considerNat]

structure Candidate where
  shape : Nat
  witness : Nat
deriving DecidableEq, Repr

def candidateLess (left right : Candidate) : Bool :=
  left.shape < right.shape ||
    (left.shape == right.shape && left.witness < right.witness)

example : candidateLess ⟨0, 9⟩ ⟨1, 0⟩ = true := by decide
example : candidateLess ⟨4, 1⟩ ⟨4, 8⟩ = true := by decide

/- A term-only wire cannot in general certify a shape-then-witness order. -/
def shapeOnly (candidate : Candidate) : Nat := candidate.shape

def firstTiedCandidate : Candidate := ⟨0, 1⟩
def secondTiedCandidate : Candidate := ⟨0, 8⟩

theorem shape_only_loses_witness :
    firstTiedCandidate ≠ secondTiedCandidate ∧
      shapeOnly firstTiedCandidate = shapeOnly secondTiedCandidate := by
  decide

theorem shape_only_is_not_injective : Not (Function.Injective shapeOnly) := by
  intro injective
  have equalCandidates : firstTiedCandidate = secondTiedCandidate :=
    injective shape_only_loses_witness.right
  exact shape_only_loses_witness.left equalCandidates

def candidatePair (candidate : Candidate) : Nat × Nat :=
  (candidate.shape, candidate.witness)

theorem candidate_pair_is_injective : Function.Injective candidatePair := by
  intro left right equalPairs
  cases left with
  | mk leftShape leftWitness =>
      cases right with
      | mk rightShape rightWitness =>
          have shapeEqual : leftShape = rightShape := congrArg Prod.fst equalPairs
          have witnessEqual : leftWitness = rightWitness := congrArg Prod.snd equalPairs
          cases shapeEqual
          cases witnessEqual
          rfl

/- Producer export and independent replay use this same pair projection. The
   Java refinement obligation is to reconstruct both components from bytes. -/
def producerCandidateKey : Candidate -> Nat × Nat := candidatePair
def verifierCandidateKey : Candidate -> Nat × Nat := candidatePair

theorem producer_and_verifier_candidate_orders_are_identical
    (candidate : Candidate) :
    producerCandidateKey candidate = verifierCandidateKey candidate := by
  rfl

theorem shared_candidate_key_is_injective :
    Function.Injective producerCandidateKey := by
  exact candidate_pair_is_injective

structure PermutationPresentation where
  image : List Nat
deriving DecidableEq, Repr

def permutationActionKey (permutation : PermutationPresentation) : List Nat :=
  permutation.image

theorem complete_permutation_action_key_is_injective :
    Function.Injective permutationActionKey := by
  intro left right equalImages
  cases left with
  | mk leftImage =>
      cases right with
      | mk rightImage =>
          simp only [permutationActionKey] at equalImages
          cases equalImages
          rfl

structure FinitePermutationGroup where
  /- The finite model stores the unique action-key-sorted member sequence. -/
  members : List PermutationPresentation

def canonicalGroupPresentation (group : FinitePermutationGroup) :
    List PermutationPresentation :=
  group.members

theorem canonical_group_presentation_is_extensional
    (left right : FinitePermutationGroup)
    (sameMembers : left.members = right.members) :
    canonicalGroupPresentation left = canonicalGroupPresentation right := by
  cases left
  cases right
  simp only [canonicalGroupPresentation] at sameMembers ⊢
  cases sameMembers
  rfl

theorem generator_spelling_is_not_group_identity :
    [PermutationPresentation.mk [1, 0], PermutationPresentation.mk [2, 0, 1]] ≠
      [PermutationPresentation.mk [2, 0, 1], PermutationPresentation.mk [1, 0]] := by
  decide

theorem larger_witness_loses_equal_shape_tie :
    candidateLess firstTiedCandidate secondTiedCandidate = true := by
  decide

def candidateBefore (left right : Candidate) : Prop :=
  left.shape < right.shape ∨
    (left.shape = right.shape ∧ left.witness < right.witness)

theorem candidate_key_order_is_total (left right : Candidate) :
    candidateBefore left right ∨ left = right ∨ candidateBefore right left := by
  cases left with
  | mk leftShape leftWitness =>
      cases right with
      | mk rightShape rightWitness =>
          simp [candidateBefore]
          omega

def factorial : Nat -> Nat
  | 0 => 1
  | n + 1 => (n + 1) * factorial n

def globalCandidates (typedClassSizes : List Nat) : Nat :=
  typedClassSizes.foldl (fun total size => total * factorial size) 1

example : globalCandidates [7] = 5040 := by decide
example : globalCandidates [] = 1 := by decide

structure Summary where
  minimum : LeastState Nat
  count : Nat
deriving DecidableEq, Repr

def Summary.push (summary : Summary) (candidate : Nat) : Summary :=
  ⟨considerNat summary.minimum candidate, summary.count + 1⟩

def streamSummary (candidates : List Nat) : Summary :=
  candidates.foldl Summary.push ⟨.unset, 0⟩

theorem fold_count_exact (candidates : List Nat) (initial : Summary) :
    (candidates.foldl Summary.push initial).count =
      initial.count + candidates.length := by
  induction candidates generalizing initial with
  | nil => simp
  | cons candidate rest inductionHypothesis =>
      simp [List.foldl, Summary.push, inductionHypothesis,
        Nat.add_comm, Nat.add_left_comm]

theorem streamed_count_is_exact (candidates : List Nat) :
    (streamSummary candidates).count = candidates.length := by
  simpa [streamSummary] using fold_count_exact candidates ⟨.unset, 0⟩

def boundedStreamSummary (maximum : Nat) (candidates : List Nat) :
    Option Summary :=
  if candidates.length ≤ maximum then some (streamSummary candidates) else none

theorem bounded_stream_rejects_exhaustion
    {maximum : Nat} {candidates : List Nat}
    (exhausted : maximum < candidates.length) :
    boundedStreamSummary maximum candidates = none := by
  simp [boundedStreamSummary, Nat.not_le.mpr exhausted]

theorem bounded_stream_preserves_complete_result
    {maximum : Nat} {candidates : List Nat}
    (withinBound : candidates.length ≤ maximum) :
    boundedStreamSummary maximum candidates = some (streamSummary candidates) := by
  simp [boundedStreamSummary, withinBound]

def streamPairs (left right : List Nat) : Summary :=
  left.foldl
    (fun state x => right.foldl
      (fun nested y => nested.push (10 * x + y)) state)
    ⟨.unset, 0⟩

def materializedPairs (left right : List Nat) : List Nat :=
  left.flatMap (fun x => right.map (fun y => 10 * x + y))

example :
    streamPairs [3, 1] [8, 0, 5] =
      streamSummary (materializedPairs [3, 1] [8, 0, 5]) := by
  decide

theorem inner_stream_count
    (x : Nat) (right : List Nat) (initial : Summary) :
    (right.foldl
      (fun nested y => nested.push (10 * x + y)) initial).count =
      initial.count + right.length := by
  induction right generalizing initial with
  | nil => simp
  | cons y rest inductionHypothesis =>
      simp only [List.foldl]
      rw [inductionHypothesis (initial := initial.push (10 * x + y))]
      simp [Summary.push]
      omega

theorem streamed_cartesian_count_from
    (left right : List Nat) (initial : Summary) :
    (left.foldl
      (fun state x => right.foldl
        (fun nested y => nested.push (10 * x + y)) state)
      initial).count =
      initial.count + left.length * right.length := by
  induction left generalizing initial with
  | nil => simp
  | cons x rest inductionHypothesis =>
      simp only [List.foldl]
      rw [inductionHypothesis]
      rw [inner_stream_count]
      simp [Nat.add_assoc, Nat.add_comm, Nat.succ_mul]

theorem streamed_cartesian_count_is_exact
    (left right : List Nat) :
    (streamPairs left right).count = left.length * right.length := by
  simpa [streamPairs] using
    streamed_cartesian_count_from left right ⟨.unset, 0⟩

theorem fold_minimum_exact (candidates : List Nat) (initial : Summary) :
    (candidates.foldl Summary.push initial).minimum =
      candidates.foldl considerNat initial.minimum := by
  induction candidates generalizing initial with
  | nil => rfl
  | cons candidate rest inductionHypothesis =>
      simp only [List.foldl]
      rw [inductionHypothesis]
      rfl

theorem stream_summary_retains_only_minimum_and_count
    (candidates : List Nat) :
    (streamSummary candidates).minimum = minimumNat candidates ∧
      (streamSummary candidates).count = candidates.length := by
  constructor
  · simpa [streamSummary, minimumNat] using
      fold_minimum_exact candidates ⟨.unset, 0⟩
  · exact streamed_count_is_exact candidates

def s7StabilizerOrbitWidths : List Nat := [7, 6, 5, 4, 3, 2]

theorem s7_stabilizer_state_is_strictly_smaller_than_orbit :
    s7StabilizerOrbitWidths.sum = 27 ∧ factorial 7 = 5040 ∧
      s7StabilizerOrbitWidths.sum < factorial 7 := by
  decide

/- This equality proves a bounded extensional traversal fact, not a Java heap
   bound. Retained-object nonmaterialization remains an implementation gate. -/

abbrev Path := List Nat

structure LocalOccurrenceKey where
  path : Path
  descriptorMap : List Nat
  action : List Nat
deriving DecidableEq, Repr

structure RootedOccurrence where
  root : Nat
  localKey : LocalOccurrenceKey
deriving DecidableEq, Repr

def rootlessKey (occurrence : RootedOccurrence) : LocalOccurrenceKey :=
  occurrence.localKey

def leftOccurrence : RootedOccurrence :=
  ⟨17, ⟨[0], [0, 1], [1, 0]⟩⟩

def rightOccurrence : RootedOccurrence :=
  ⟨29, ⟨[0], [0, 1], [1, 0]⟩⟩

theorem distinct_roots_collide_under_rootless_key :
    leftOccurrence ≠ rightOccurrence ∧
      rootlessKey leftOccurrence = rootlessKey rightOccurrence := by
  decide

theorem rootless_key_is_not_injective :
    Not (Function.Injective rootlessKey) := by
  intro injective
  have equalOccurrences : leftOccurrence = rightOccurrence :=
    injective distinct_roots_collide_under_rootless_key.right
  exact distinct_roots_collide_under_rootless_key.left equalOccurrences

def rootedKey (occurrence : RootedOccurrence) : Nat × LocalOccurrenceKey :=
  (occurrence.root, occurrence.localKey)

theorem rooted_key_is_injective : Function.Injective rootedKey := by
  intro left right equalKeys
  cases left with
  | mk leftRoot leftLocal =>
      cases right with
      | mk rightRoot rightLocal =>
          have rootEqual : leftRoot = rightRoot := congrArg Prod.fst equalKeys
          have localEqual : leftLocal = rightLocal := congrArg Prod.snd equalKeys
          cases rootEqual
          cases localEqual
          rfl

inductive SchemaVersion where
  | v5
  | v6
  | v7
  | v8
  | v9
  | v10
  | future
deriving DecidableEq, Repr

structure ContractFeatures where
  rootedBinder : Bool
  callProvenance : Bool
  exactTransitions : Bool
  witnessUnfold : Bool
  dependentSubtypeEvidence : Bool
  dependentCorrelatedDag : Bool
deriving DecidableEq, Repr

def completeContract : ContractFeatures :=
  ⟨true, true, true, true, true, true⟩

def contractFeatures : SchemaVersion → ContractFeatures
  | .v5 => ⟨false, false, false, false, false, false⟩
  | .v6 => ⟨true, false, false, false, false, false⟩
  | .v7 => ⟨true, true, false, false, false, false⟩
  | .v8 => ⟨true, true, true, true, false, false⟩
  | .v9 => ⟨true, true, true, true, true, false⟩
  | .v10 => completeContract
  | .future => ⟨false, false, false, false, false, false⟩

theorem schema_v10_admits_complete_contract :
    contractFeatures .v10 = completeContract := by
  rfl

theorem only_schema_v10_admits_complete_contract (version : SchemaVersion) :
    contractFeatures version = completeContract ↔ version = .v10 := by
  cases version <;> decide

theorem historical_and_future_schemas_reject_complete_contract :
    contractFeatures .v5 ≠ completeContract ∧
      contractFeatures .v6 ≠ completeContract ∧
      contractFeatures .v7 ≠ completeContract ∧
      contractFeatures .v8 ≠ completeContract ∧
      contractFeatures .v9 ≠ completeContract ∧
      contractFeatures .future ≠ completeContract := by
  decide

structure WitnessEquation where
  left : Nat
  right : Nat
deriving DecidableEq, Repr

def unfoldWitness (equation : WitnessEquation) : Prop :=
  equation.left = equation.right

theorem witness_unfold_is_definitional (equation : WitnessEquation) :
    unfoldWitness equation ↔ equation.left = equation.right := by
  rfl

def occurrenceCoordinate (base index : Nat) : Nat := base + index

theorem occurrence_coordinate_injective {base left right : Nat}
    (equal : occurrenceCoordinate base left = occurrenceCoordinate base right) :
    left = right := by
  simp [occurrenceCoordinate] at equal
  omega

theorem directly_nested_occurrences_are_disjoint
    {base outerSize innerSize outerIndex innerIndex : Nat}
    (outerBound : outerIndex < outerSize)
    (_innerBound : innerIndex < innerSize) :
    occurrenceCoordinate base outerIndex ≠
      occurrenceCoordinate (base + outerSize) innerIndex := by
  intro equal
  simp [occurrenceCoordinate, Nat.add_assoc] at equal
  omega

theorem descriptor_occurrence_round_trip
    {base index : Nat} :
    occurrenceCoordinate base index - base = index := by
  simp [occurrenceCoordinate]

structure OccurrenceAlignment where
  root : Nat
  path : List Nat
  descriptorCoordinates : List Nat
  action : List Nat
deriving DecidableEq, Repr

def encodeAlignment (alignment : OccurrenceAlignment) :
    Nat × List Nat × List Nat × List Nat :=
  (alignment.root, alignment.path,
    alignment.descriptorCoordinates, alignment.action)

def decodeAlignment
    (encoded : Nat × List Nat × List Nat × List Nat) : OccurrenceAlignment :=
  ⟨encoded.1, encoded.2.1, encoded.2.2.1, encoded.2.2.2⟩

def actAlignment (rho : Nat → Nat)
    (alignment : OccurrenceAlignment) : OccurrenceAlignment :=
  { alignment with action := alignment.action.map rho }

def alphaCompareAlignment (alignment : OccurrenceAlignment) : OccurrenceAlignment :=
  alignment

def canonicalizeAlignment (alignment : OccurrenceAlignment) : OccurrenceAlignment :=
  alignment

theorem alignment_replay_preserves_complete_occurrence
    (alignment : OccurrenceAlignment) :
    decodeAlignment (encodeAlignment alignment) = alignment := by
  cases alignment
  rfl

theorem action_alpha_canonical_serialization_commutes
    (rho : Nat → Nat) (alignment : OccurrenceAlignment) :
    decodeAlignment (encodeAlignment
      (canonicalizeAlignment (alphaCompareAlignment
        (actAlignment rho alignment)))) =
      actAlignment rho alignment := by
  simp [canonicalizeAlignment, alphaCompareAlignment,
    alignment_replay_preserves_complete_occurrence]

def extendByCallerIdentity (callerSize : Nat) (outer : Nat → Nat)
    (slot : Nat) : Nat :=
  if slot < callerSize then slot else callerSize + outer (slot - callerSize)

theorem extended_action_fixes_caller_slot
    (callerSize : Nat) (outer : Nat → Nat) {slot : Nat}
    (caller : slot < callerSize) :
    extendByCallerIdentity callerSize outer slot = slot := by
  simp [extendByCallerIdentity, caller]

def actNestedLayers (callerSize : Nat) (outer : Nat → Nat)
    (layers : List (List Nat)) : List (List Nat) :=
  layers.map (List.map (extendByCallerIdentity callerSize outer))

theorem map_caller_layer_is_capture_avoiding
    (callerSize : Nat) (outer : Nat → Nat) (slots : List Nat)
    (allCaller : ∀ slot ∈ slots, slot < callerSize) :
    slots.map (extendByCallerIdentity callerSize outer) = slots := by
  induction slots with
  | nil => rfl
  | cons slot rest inductionHypothesis =>
      have slotCaller : slot < callerSize := allCaller slot (by simp)
      have restCaller : ∀ item ∈ rest, item < callerSize := by
        intro item member
        exact allCaller item (by simp [member])
      simp [extended_action_fixes_caller_slot callerSize outer slotCaller,
        inductionHypothesis restCaller]

theorem nested_caller_layers_are_capture_avoiding
    (callerSize : Nat) (outer : Nat → Nat) (layers : List (List Nat))
    (allCaller : ∀ layer ∈ layers, ∀ slot ∈ layer, slot < callerSize) :
    actNestedLayers callerSize outer layers = layers := by
  induction layers with
  | nil => rfl
  | cons layer rest inductionHypothesis =>
      have layerCaller : ∀ slot ∈ layer, slot < callerSize := by
        intro slot member
        exact allCaller layer (by simp) slot member
      have restCaller : ∀ item ∈ rest, ∀ slot ∈ item, slot < callerSize := by
        intro item itemMember slot slotMember
        exact allCaller item (by simp [itemMember]) slot slotMember
      change
        layer.map (extendByCallerIdentity callerSize outer) ::
            actNestedLayers callerSize outer rest = layer :: rest
      rw [map_caller_layer_is_capture_avoiding
            callerSize outer layer layerCaller]
      rw [inductionHypothesis restCaller]

structure CanonicalMetrics where
  findOccurrences : Nat
  parentSteps : Nat
  containerNormalizations : Nat
deriving DecidableEq, Repr

def retainedTraceLength (metrics : CanonicalMetrics) : Nat :=
  metrics.findOccurrences + metrics.parentSteps +
    metrics.containerNormalizations

theorem trace_length_decomposition (metrics : CanonicalMetrics) :
    retainedTraceLength metrics =
      metrics.findOccurrences + metrics.parentSteps +
        metrics.containerNormalizations := by
  rfl

structure ReportedCounters where
  inputBytes : Nat
  kernelBytes : Nat
  retainedPathTraceLength : Nat
  globalRenamingCandidates : Nat
  localQuotientWork : Nat
  serializedBinderCandidates : Nat
  certificateBytes : Nat
deriving DecidableEq, Repr

def counterTuple (counters : ReportedCounters) :
    Nat × Nat × Nat × Nat × Nat × Nat × Nat :=
  (counters.inputBytes,
    counters.kernelBytes,
    counters.retainedPathTraceLength,
    counters.globalRenamingCandidates,
    counters.localQuotientWork,
    counters.serializedBinderCandidates,
    counters.certificateBytes)

theorem counter_tuple_is_injective : Function.Injective counterTuple := by
  intro left right equal
  cases left
  cases right
  simp only [counterTuple] at equal
  cases equal
  rfl

def byteDerivedCounters (bytes : List UInt8) : ReportedCounters :=
  ⟨bytes.length, bytes.length, 0, 0, 0, 0, bytes.length⟩

theorem certificate_byte_count_is_encoded_length (bytes : List UInt8) :
    (byteDerivedCounters bytes).certificateBytes = bytes.length := by
  rfl

theorem byte_identical_runs_have_identical_derived_counters
    (left right : List UInt8) (sameBytes : left = right) :
    byteDerivedCounters left = byteDerivedCounters right := by
  cases sameBytes
  rfl

def candidateKeys (candidates : List Candidate) : List (Nat × Nat) :=
  candidates.map producerCandidateKey

theorem equal_complete_candidate_sets_have_equal_ordered_keys
    (producer verifier : List Candidate)
    (sameCandidates : producer = verifier) :
    candidateKeys producer = verifier.map verifierCandidateKey := by
  cases sameCandidates
  simp [candidateKeys, producerCandidateKey, verifierCandidateKey]

structure VerifiedObservation where
  sourceDerivation : Nat
  kernelDerivation : Nat
  leastShape : Nat × Nat
deriving DecidableEq, Repr

structure PairResult where
  left : VerifiedObservation
  right : VerifiedObservation
  equalLeastShapes : Bool
deriving DecidableEq, Repr

def comparePair (left right : VerifiedObservation) : PairResult :=
  ⟨left, right, decide (left.leastShape = right.leastShape)⟩

theorem pair_comparison_preserves_separate_derivation_owners
    (left right : VerifiedObservation) :
    (comparePair left right).left.sourceDerivation = left.sourceDerivation ∧
      (comparePair left right).left.kernelDerivation = left.kernelDerivation ∧
      (comparePair left right).right.sourceDerivation = right.sourceDerivation ∧
      (comparePair left right).right.kernelDerivation = right.kernelDerivation := by
  simp [comparePair]

theorem pair_result_compares_exact_least_shapes
    (left right : VerifiedObservation) :
    (comparePair left right).equalLeastShapes =
      decide (left.leastShape = right.leastShape) := by
  rfl

end Phase6OrbitCanonicalization
