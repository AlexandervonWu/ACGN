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

def factorial : Nat -> Nat
  | 0 => 1
  | n + 1 => (n + 1) * factorial n

def globalCandidates (typedClassSizes : List Nat) : Nat :=
  typedClassSizes.foldl (fun total size => total * factorial size) 1

example : globalCandidates [7] = 5040 := by native_decide
example : globalCandidates [] = 1 := by native_decide

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
  native_decide

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
  | future
deriving DecidableEq, Repr

structure ContractFeatures where
  rootedBinder : Bool
  callProvenance : Bool
  exactTransitions : Bool
  witnessUnfold : Bool
deriving DecidableEq, Repr

def completeContract : ContractFeatures := ⟨true, true, true, true⟩

def contractFeatures : SchemaVersion → ContractFeatures
  | .v5 => ⟨false, false, false, false⟩
  | .v6 => ⟨true, false, false, false⟩
  | .v7 => ⟨true, true, false, false⟩
  | .v8 => completeContract
  | .future => ⟨false, false, false, false⟩

theorem schema_v8_admits_complete_contract :
    contractFeatures .v8 = completeContract := by
  rfl

theorem only_schema_v8_admits_complete_contract (version : SchemaVersion) :
    contractFeatures version = completeContract ↔ version = .v8 := by
  cases version <;> decide

theorem historical_and_future_schemas_reject_complete_contract :
    contractFeatures .v5 ≠ completeContract ∧
      contractFeatures .v6 ≠ completeContract ∧
      contractFeatures .v7 ≠ completeContract ∧
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

end Phase6OrbitCanonicalization
