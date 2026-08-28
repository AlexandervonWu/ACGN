/-
Independent finite Phase 4 collision model. This proves the abstract bucket,
orientation, owner-identity, memo-invalidation, and version obligations below.
It does not constitute a refinement proof for Java or the wire verifier.
Checked with Lean 4.33.0.
-/

namespace Phase4CollisionBuckets

inductive Owner where
  | left
  | right
deriving DecidableEq, BEq, Repr

inductive Coord where
  | c0
  | c1
deriving DecidableEq, BEq, Repr

structure Interface where
  owner : Owner
  exposed : Coord
  witnessSwaps : Bool
deriving DecidableEq, Repr

def applyWitness (swaps : Bool) : Coord -> Coord
  | .c0 => if swaps then .c1 else .c0
  | .c1 => if swaps then .c0 else .c1

theorem witness_is_involutive (swaps : Bool) (coordinate : Coord) :
    applyWitness swaps (applyWitness swaps coordinate) = coordinate := by
  cases swaps <;> cases coordinate <;> rfl

def directedEmbedding (child parent : Interface) : Bool :=
  decide
    (applyWitness child.witnessSwaps
      (applyWitness parent.witnessSwaps parent.exposed) = child.exposed)

def bothOrientations (left right : Interface) : Bool :=
  directedEmbedding left right || directedEmbedding right left

def initialLeft : Interface := ⟨.left, .c0, false⟩
def initialRight : Interface := ⟨.right, .c1, false⟩
def changedRight : Interface := ⟨.right, .c1, true⟩

example : bothOrientations initialLeft initialRight = false := by
  native_decide

example : bothOrientations initialLeft changedRight = true := by
  native_decide

theorem second_orientation_is_considered
    (left right : Interface)
    (firstFails : directedEmbedding left right = false)
    (secondSucceeds : directedEmbedding right left = true) :
    bothOrientations left right = true := by
  simp [bothOrientations, firstFails, secondSucceeds]

structure UnionDecision where
  child : Owner
  parent : Owner
  admitted : Bool
deriving DecidableEq, Repr

structure CollisionEvaluation where
  preferredAttempt : Bool
  oppositeAttempt : Bool
  decision : UnionDecision
deriving DecidableEq, Repr

def evaluateCollision (left right : Interface) : CollisionEvaluation :=
  let preferred := directedEmbedding right left
  let opposite := directedEmbedding left right
  let decision :=
    if preferred then ⟨right.owner, left.owner, true⟩
    else if opposite then ⟨left.owner, right.owner, true⟩
    else ⟨right.owner, left.owner, false⟩
  ⟨preferred, opposite, decision⟩

def decideUnion (left right : Interface) : UnionDecision :=
  (evaluateCollision left right).decision

theorem evaluation_records_both_directed_attempts
    (left right : Interface) :
    (evaluateCollision left right).preferredAttempt =
        directedEmbedding right left ∧
      (evaluateCollision left right).oppositeAttempt =
        directedEmbedding left right := by
  simp [evaluateCollision]

theorem admission_requires_an_orientation
    (left right : Interface)
    (admitted : (decideUnion left right).admitted = true) :
    bothOrientations left right = true := by
  simp [decideUnion, bothOrientations] at admitted ⊢
  simp [evaluateCollision] at admitted
  split at admitted <;> rename_i rightToLeft
  · simp [rightToLeft]
  · split at admitted <;> rename_i leftToRight
    · simp [leftToRight]
    · simp_all

def postCollisionOwners (left right : Interface) : List Owner :=
  let result := decideUnion left right
  if result.admitted then [result.parent] else [left.owner, right.owner]

theorem failed_collision_preserves_both_owners
    (left right : Interface)
    (preferredFails : directedEmbedding right left = false)
    (oppositeFails : directedEmbedding left right = false) :
    postCollisionOwners left right = [left.owner, right.owner] := by
  simp [postCollisionOwners, decideUnion, evaluateCollision,
    preferredFails, oppositeFails]

theorem admitted_collision_has_one_retained_owner
    (left right : Interface)
    (admitted : (decideUnion left right).admitted = true) :
    postCollisionOwners left right = [(decideUnion left right).parent] := by
  simp [postCollisionOwners, admitted]

structure Bucket where
  owners : List Owner
  live : Owner -> Bool

def Bucket.valid (bucket : Bucket) : Prop :=
  bucket.owners ≠ [] ∧ bucket.owners.Nodup ∧
    ∀ owner, owner ∈ bucket.owners -> bucket.live owner = true

def incomparableBucket : Bucket :=
  ⟨[.left, .right], fun _ => true⟩

example : incomparableBucket.valid := by
  simp [Bucket.valid, incomparableBucket]

structure StoredShape where
  owner : Nat
  shape : Nat
deriving DecidableEq, Repr

def liveOwnerMember
    (shape : Nat)
    (live : Nat -> Bool)
    (stored : List StoredShape)
    (owner : Nat) : Bool :=
  decide (⟨owner, shape⟩ ∈ stored) && live owner

/- Public buckets are modeled as a canonical bounded enumeration of an
   extensional owner predicate. The bound is part of the finite graph state;
   unlike the old filtered-list model, source record order and duplicates do
   not affect this observation. -/
def liveOwnerBucket
    (ownerLimit shape : Nat)
    (live : Nat -> Bool)
  (stored : List StoredShape) : List Nat :=
  (List.range ownerLimit).filter fun owner =>
    liveOwnerMember shape live stored owner

theorem stored_live_owner_is_in_bucket
    {shape owner : Nat}
    {live : Nat -> Bool}
    {stored : List StoredShape}
    {ownerLimit : Nat}
    (storedHere : ⟨owner, shape⟩ ∈ stored)
    (ownerLive : live owner = true)
    (ownerBound : owner < ownerLimit) :
    owner ∈ liveOwnerBucket ownerLimit shape live stored := by
  apply List.mem_filter.mpr
  constructor
  · exact List.mem_range.mpr ownerBound
  · simp [liveOwnerMember, storedHere, ownerLive]

theorem stored_live_shape_has_nonempty_finite_bucket
    {shape owner : Nat}
    {live : Nat -> Bool}
    {stored : List StoredShape}
    {ownerLimit : Nat}
    (storedHere : ⟨owner, shape⟩ ∈ stored)
    (ownerLive : live owner = true)
    (ownerBound : owner < ownerLimit) :
    liveOwnerBucket ownerLimit shape live stored ≠ [] := by
  intro empty
  have member := stored_live_owner_is_in_bucket storedHere ownerLive ownerBound
  rw [empty] at member
  simp at member

theorem bucket_contains_only_live_owners
    {shape owner : Nat}
    {live : Nat -> Bool}
    {stored : List StoredShape}
    {ownerLimit : Nat}
    (member : owner ∈ liveOwnerBucket ownerLimit shape live stored) :
    live owner = true := by
  have selected := (List.mem_filter.mp member).2
  simp [liveOwnerMember] at selected
  exact selected.2

theorem live_owner_membership_is_permutation_invariant
    {shape owner : Nat}
    {live : Nat -> Bool}
    {left right : List StoredShape}
    (permutation : left.Perm right) :
    liveOwnerMember shape live left owner =
      liveOwnerMember shape live right owner := by
  unfold liveOwnerMember
  have membership := permutation.mem_iff (a := (⟨owner, shape⟩ : StoredShape))
  by_cases leftMember : (⟨owner, shape⟩ : StoredShape) ∈ left
  · have rightMember := membership.mp leftMember
    simp [leftMember, rightMember]
  · have rightNotMember : (⟨owner, shape⟩ : StoredShape) ∉ right := by
      intro rightMember
      exact leftMember (membership.mpr rightMember)
    simp [leftMember, rightNotMember]

theorem duplicate_stored_records_do_not_change_membership
    (shape owner : Nat)
    (live : Nat -> Bool)
    (record : StoredShape)
    (stored : List StoredShape) :
    liveOwnerMember shape live (record :: record :: stored) owner =
      liveOwnerMember shape live (record :: stored) owner := by
  simp [liveOwnerMember]

theorem live_owner_bucket_is_deterministic
    (ownerLimit shape : Nat)
    (live : Nat -> Bool)
    {left right : List StoredShape}
    (permutation : left.Perm right) :
    liveOwnerBucket ownerLimit shape live left =
      liveOwnerBucket ownerLimit shape live right := by
  unfold liveOwnerBucket
  congr 1
  funext owner
  exact live_owner_membership_is_permutation_invariant permutation

inductive GraphStatus where
  | dirty
  | quiescent
deriving DecidableEq, Repr

structure GraphState where
  ownerLimit : Nat
  stored : List StoredShape
  storedOwnersBounded :
    ∀ record, record ∈ stored -> record.owner < ownerLimit
  live : Nat -> Bool
  bucketIndex : Nat -> Nat -> Bool
  status : GraphStatus

def expectedOwner (state : GraphState) (shape owner : Nat) : Bool :=
  liveOwnerMember shape state.live state.stored owner

def ExactBucketIndex (state : GraphState) : Prop :=
  ∀ shape owner, owner < state.ownerLimit ->
    state.bucketIndex shape owner = expectedOwner state shape owner

def QuiescentExact (state : GraphState) : Prop :=
  state.status = .quiescent -> ExactBucketIndex state

def initialGraph (ownerLimit : Nat) : GraphState :=
  ⟨ownerLimit, [], by simp, fun _ => false, fun _ _ => false, .quiescent⟩

inductive SupportedOperation where
  | mutate
      (ownerLimit : Nat)
      (stored : List StoredShape)
      (storedOwnersBounded :
        ∀ record, record ∈ stored -> record.owner < ownerLimit)
      (live : Nat -> Bool)
  | rebuild

theorem supported_mutation_owner_is_bounded
    {ownerLimit : Nat}
    {stored : List StoredShape}
    (storedOwnersBounded :
      ∀ record, record ∈ stored -> record.owner < ownerLimit)
    {record : StoredShape}
    (storedHere : record ∈ stored) :
    record.owner < ownerLimit :=
  storedOwnersBounded record storedHere

theorem out_of_bound_mutation_is_not_supported :
    ¬ (∀ record, record ∈ [({ owner := 1, shape := 0 } : StoredShape)] ->
      record.owner < 1) := by
  intro allegedlyBounded
  have impossible := allegedlyBounded
    ({ owner := 1, shape := 0 } : StoredShape) (by simp)
  exact (Nat.lt_irrefl 1) impossible

def applySupportedOperation
  (state : GraphState) : SupportedOperation -> GraphState
  | .mutate ownerLimit stored storedOwnersBounded live =>
      { state with
        ownerLimit := ownerLimit
        stored := stored
        storedOwnersBounded := storedOwnersBounded
        live := live
        status := .dirty }
  | .rebuild =>
      { state with
        bucketIndex := fun shape owner => expectedOwner state shape owner
        status := .quiescent }

def runSupportedOperations
    (state : GraphState) : List SupportedOperation -> GraphState
  | [] => state
  | operation :: rest =>
      runSupportedOperations (applySupportedOperation state operation) rest

theorem initial_graph_is_quiescent_exact (ownerLimit : Nat) :
    QuiescentExact (initialGraph ownerLimit) := by
  intro _ shape owner _
  simp [initialGraph, expectedOwner, liveOwnerMember]

theorem stored_live_shape_has_state_bounded_nonempty_bucket
    {state : GraphState}
    {shape owner : Nat}
    (storedHere : ⟨owner, shape⟩ ∈ state.stored)
    (ownerLive : state.live owner = true) :
    liveOwnerBucket state.ownerLimit shape state.live state.stored ≠ [] := by
  exact stored_live_shape_has_nonempty_finite_bucket
    storedHere ownerLive (state.storedOwnersBounded _ storedHere)

theorem supported_operation_preserves_quiescent_exact
    {state : GraphState}
    (_stateExact : QuiescentExact state)
    (operation : SupportedOperation) :
    QuiescentExact (applySupportedOperation state operation) := by
  cases operation with
  | mutate ownerLimit stored storedOwnersBounded live =>
      intro impossible
      simp [applySupportedOperation] at impossible
  | rebuild =>
      intro _ shape owner _
      rfl

theorem supported_run_preserves_quiescent_exact
    {state : GraphState}
    (stateExact : QuiescentExact state)
    (operations : List SupportedOperation) :
    QuiescentExact (runSupportedOperations state operations) := by
  induction operations generalizing state with
  | nil => exact stateExact
  | cons operation rest inductionHypothesis =>
      apply inductionHypothesis
      exact supported_operation_preserves_quiescent_exact stateExact operation

def publicOwnerObservation
    (state : GraphState) (shape owner : Nat) : Option Bool :=
  if state.status = .quiescent && owner < state.ownerLimit then
    some (state.bucketIndex shape owner)
  else none

theorem out_of_bound_public_observation_rejects
    (state : GraphState)
    (shape owner : Nat)
    (outOfBound : ¬ owner < state.ownerLimit) :
    publicOwnerObservation state shape owner = none := by
  simp [publicOwnerObservation, outOfBound]

theorem supported_quiescent_public_observation_is_exact
    {state : GraphState}
    (stateExact : QuiescentExact state)
    {shape owner : Nat}
    (ownerBound : owner < state.ownerLimit)
    {observed : Bool}
    (observation : publicOwnerObservation state shape owner = some observed) :
    observed = expectedOwner state shape owner := by
  unfold publicOwnerObservation at observation
  split at observation <;> rename_i admitted
  · simp at admitted
    have statusCase : state.status = .quiescent := admitted.1
    have indexExact := stateExact statusCase shape owner ownerBound
    simp at observation
    simpa [observation] using indexExact
  · simp at observation

theorem initial_supported_run_has_exact_public_observations
    (ownerLimit : Nat)
    (operations : List SupportedOperation) :
    QuiescentExact
      (runSupportedOperations (initialGraph ownerLimit) operations) := by
  exact supported_run_preserves_quiescent_exact
    (initial_graph_is_quiescent_exact ownerLimit) operations

structure Record where
  owner : Owner
  shape : Nat
  proof : Nat
deriving DecidableEq, Repr

def rehome (child parent : Owner) (records : List Record) : List Record :=
  records.map fun record =>
    if record.owner = child then { record with owner := parent } else record

theorem rehome_preserves_count
    (child parent : Owner) (records : List Record) :
    (rehome child parent records).length = records.length := by
  simp [rehome]

structure Retirement where
  retired : Record
  retained : Record
  transferredProof : Nat
  retainedProof : Nat
  parentEdgeProof : Nat
deriving DecidableEq, Repr

def rehomeOrRetire
    (child parent : Owner)
    (parentShapes : List Nat)
    (edgeProof : Nat) :
    List Record -> List Record × List Retirement
  | [] => ([], [])
  | record :: rest =>
      let tail := rehomeOrRetire child parent parentShapes edgeProof rest
      if record.owner = child then
        if record.shape ∈ parentShapes then
          (tail.1,
            ⟨record,
              ⟨parent, record.shape, record.proof⟩,
              record.proof,
              record.proof,
              edgeProof⟩ :: tail.2)
        else
          ({ record with owner := parent } :: tail.1, tail.2)
      else
        (record :: tail.1, tail.2)

theorem rehome_or_retire_accounts_for_every_record
    (child parent : Owner)
    (parentShapes : List Nat)
    (edgeProof : Nat)
    (records : List Record) :
    (rehomeOrRetire child parent parentShapes edgeProof records).1.length +
      (rehomeOrRetire child parent parentShapes edgeProof records).2.length =
      records.length := by
  induction records with
  | nil => rfl
  | cons record rest inductionHypothesis =>
      by_cases ownerCase : record.owner = child
      · by_cases shapeCase : record.shape ∈ parentShapes
        · simp [rehomeOrRetire, ownerCase, shapeCase]
          omega
        · simp [rehomeOrRetire, ownerCase, shapeCase]
          omega
      · simp [rehomeOrRetire, ownerCase]
        omega

theorem duplicate_child_record_is_explicitly_retired
    (shape proof edgeProof : Nat) :
    (rehomeOrRetire .left .right [shape] edgeProof
      [⟨.left, shape, proof⟩]).2 =
      [⟨⟨.left, shape, proof⟩,
        ⟨.right, shape, proof⟩,
        proof,
        proof,
        edgeProof⟩] := by
  simp [rehomeOrRetire]

def mergeLeaderCount (leaders : Nat) (admitted : Bool) : Nat :=
  if admitted && 0 < leaders then leaders - 1 else leaders

theorem admitted_merge_strictly_decreases_positive_leaders
    {leaders : Nat}
    (positive : 0 < leaders) :
    mergeLeaderCount leaders true < leaders := by
  simp [mergeLeaderCount, positive]
  omega

/- Rebuild runs over a fixed finite record batch. A record step without a
   union consumes dirty work. A certified union may dirty every record again,
   but it strictly consumes one leader. This mixed-radix rank therefore
   decreases on either production transition. -/
def rebuildRank (recordCount leaderCount dirtyCount : Nat) : Nat :=
  leaderCount * (recordCount + 1) + dirtyCount

theorem rebuild_record_step_strictly_decreases_rank
    {recordCount leaderCount dirtyBefore dirtyAfter : Nat}
    (decreases : dirtyAfter < dirtyBefore) :
    rebuildRank recordCount leaderCount dirtyAfter <
      rebuildRank recordCount leaderCount dirtyBefore := by
  simp only [rebuildRank]
  omega

theorem rebuild_union_step_strictly_decreases_rank
    {recordCount leaderCount dirtyBefore dirtyAfter : Nat}
    (positive : 0 < leaderCount)
    (bounded : dirtyAfter ≤ recordCount) :
    rebuildRank recordCount (leaderCount - 1) dirtyAfter <
      rebuildRank recordCount leaderCount dirtyBefore := by
  have leaderStep : leaderCount = (leaderCount - 1) + 1 := by omega
  rw [leaderStep]
  simp [rebuildRank, Nat.add_mul]
  omega

def rebuildProcessingBudget
    (initialDirty recordCount leaderCount : Nat) : Nat :=
  initialDirty + recordCount * (leaderCount - 1)

theorem fixed_batch_processing_budget_covers_all_union_epochs
    {initialDirty recordCount leaderCount unionCount processed : Nat}
    (unionBound : unionCount ≤ leaderCount - 1)
    (processedBound : processed ≤ initialDirty + recordCount * unionCount) :
    processed ≤ rebuildProcessingBudget initialDirty recordCount leaderCount := by
  unfold rebuildProcessingBudget
  exact Nat.le_trans processedBound
    (Nat.add_le_add_left (Nat.mul_le_mul_left recordCount unionBound) initialDirty)

example : rebuildProcessingBudget 3 5 4 = 18 := by decide

structure ParentRecordKey where
  owner : Owner
  shape : Nat
deriving DecidableEq, Repr

def canonicalPreimage (key : ParentRecordKey) : Owner × Nat :=
  (key.owner, key.shape)

theorem canonical_preimage_is_injective :
    Function.Injective canonicalPreimage := by
  intro left right equalKeys
  cases left with
  | mk leftOwner leftShape =>
      cases right with
      | mk rightOwner rightShape =>
          have ownerEqual : leftOwner = rightOwner := congrArg Prod.fst equalKeys
          have shapeEqual : leftShape = rightShape := congrArg Prod.snd equalKeys
          cases ownerEqual
          cases shapeEqual
          rfl

example : canonicalPreimage ⟨.left, 7⟩ ≠
    canonicalPreimage ⟨.right, 7⟩ := by
  native_decide

/- The old revision-only memo has a concrete stale-cache counterexample. -/
structure OldMemoState where
  revision : Nat
  rejectedAt : Option Nat
  compatibleNow : Bool
deriving DecidableEq, Repr

def oldResolve (state : OldMemoState) : Bool :=
  if state.rejectedAt = some state.revision then false
  else state.compatibleNow

def staleSameRevision : OldMemoState := ⟨4, some 4, true⟩

theorem revision_only_memo_is_unsound :
    ∃ state : OldMemoState,
      state.compatibleNow = true ∧ oldResolve state = false := by
  exact ⟨staleSameRevision, by decide, by decide⟩

/- The repaired abstract transition invalidates the negative entry whenever a
   compatibility-bearing record changes. -/
def invalidateOnRecordChange (state : OldMemoState) : OldMemoState :=
  { state with rejectedAt := none }

theorem changed_record_is_reconsidered (state : OldMemoState)
    (compatible : state.compatibleNow = true) :
    oldResolve (invalidateOnRecordChange state) = true := by
  simp [oldResolve, invalidateOnRecordChange, compatible]

example : oldResolve (invalidateOnRecordChange staleSameRevision) = true := by
  decide

/- Final quiescence is based on a fresh compatibility result, not a stale
   negative memo. -/
structure RebuildState where
  dirtyCount : Nat
  compatibleNow : Bool
deriving DecidableEq, Repr

def semanticallyQuiescent (state : RebuildState) : Bool :=
  decide (state.dirtyCount = 0) && !state.compatibleNow

example : semanticallyQuiescent ⟨0, true⟩ = false := by decide
example : semanticallyQuiescent ⟨0, false⟩ = true := by decide

def acceptedWireVersion (version : Nat) : Bool := decide (version = 10)

theorem schema_v10_is_accepted : acceptedWireVersion 10 = true := by decide

theorem historical_and_future_schema_versions_reject :
    ([2, 3, 4, 5, 6, 7, 8, 9, 11].all fun version =>
      !acceptedWireVersion version) = true := by
  native_decide

def allInterfaces : List Interface := [
  ⟨.left, .c0, false⟩,
  ⟨.left, .c0, true⟩,
  ⟨.left, .c1, false⟩,
  ⟨.left, .c1, true⟩,
  ⟨.right, .c0, false⟩,
  ⟨.right, .c0, true⟩,
  ⟨.right, .c1, false⟩,
  ⟨.right, .c1, true⟩]

def finiteAdmissionSound : Bool :=
  allInterfaces.all fun left =>
    allInterfaces.all fun right =>
      (!(decideUnion left right).admitted) || bothOrientations left right

example : finiteAdmissionSound = true := by native_decide

end Phase4CollisionBuckets
