import Std

/-
  Independent bounded model of the Phase 4 schema-v8 wire obligations.

  Scope: three owners, two shapes, six owner-qualified records, and finite
  proof/symmetry identifiers. Acceptance is executable. The theorems expose
  structural consequences of acceptance, while concrete examples exercise
  both valid histories and adversarial mutations. This is not a Java
  refinement proof.
-/

namespace Section3.Phase4WireConservation

inductive Owner where
  | o0 | o1 | o2
  deriving DecidableEq, Repr, BEq

namespace Owner
def all : List Owner := [.o0, .o1, .o2]
end Owner

inductive Shape where
  | s0 | s1
  deriving DecidableEq, Repr, BEq

namespace Shape
def all : List Shape := [.s0, .s1]
end Shape

inductive RecordId where
  | r0 | r1 | r2 | r3 | r4 | r5
  deriving DecidableEq, Repr, BEq

namespace RecordId
def all : List RecordId := [.r0, .r1, .r2, .r3, .r4, .r5]
end RecordId

inductive Interface where
  | intSlot | boolSlot | sharedSlot
  deriving DecidableEq, Repr, BEq

inductive ProofId where
  | p0 | p1 | p2 | p3 | p4 | p5
  deriving DecidableEq, Repr, BEq

inductive SymmetryId where
  | identity | swap
  deriving DecidableEq, Repr, BEq

inductive Endpoint where
  | actedShape : Owner -> Shape -> Nat -> Endpoint
  | ownerWitness : Owner -> Nat -> Endpoint
  deriving DecidableEq, Repr, BEq

structure EqualityEvidence where
  proof : ProofId
  left : Endpoint
  right : Endpoint
  deriving DecidableEq, Repr, BEq

structure OwnerState where
  id : Owner
  interface : Interface
  witness : Nat
  deriving DecidableEq, Repr, BEq

structure LiveRecord where
  id : RecordId
  owner : Owner
  shape : Shape
  shapeTerm : Nat
  ownerWitness : Nat
  ownerEquation : EqualityEvidence
  deriving DecidableEq, Repr, BEq

structure Bucket where
  shape : Shape
  owners : List Owner
  deriving DecidableEq, Repr, BEq

structure SymmetryEntry where
  id : SymmetryId
  owner : Owner
  evidence : EqualityEvidence
  deriving DecidableEq, Repr, BEq

structure Retirement where
  retired : RecordId
  retained : RecordId
  evidence : EqualityEvidence
  deriving DecidableEq, Repr, BEq

structure State where
  owners : List OwnerState
  records : List LiveRecord
  buckets : List Bucket
  symmetries : List SymmetryEntry
  dirty : List RecordId
  retirements : List Retirement
  deriving DecidableEq, Repr, BEq

def noDuplicates [DecidableEq item] (items : List item) : Bool :=
  decide items.Nodup

theorem andTrue {left right : Bool} (both : (left && right) = true) :
    (left = true) ∧ (right = true) := by
  cases left <;> cases right <;> simp_all

def ownerIds (state : State) : List Owner := state.owners.map (fun x => x.id)

def recordIds (records : List LiveRecord) : List RecordId :=
  records.map (fun record => record.id)

def owner? (state : State) (owner : Owner) : Option OwnerState :=
  state.owners.find? (fun candidate => candidate.id = owner)

def record? (records : List LiveRecord) (id : RecordId) : Option LiveRecord :=
  records.find? (fun candidate => candidate.id = id)

def exactShapeOwnerEvidence (record : LiveRecord) : Bool :=
  record.ownerEquation.left ==
      .actedShape record.owner record.shape record.shapeTerm &&
    record.ownerEquation.right ==
      .ownerWitness record.owner record.ownerWitness

def recordLocallyValid (state : State) (record : LiveRecord) : Bool :=
  (ownerIds state).contains record.owner &&
    (owner? state record.owner).map (fun owner => owner.witness) ==
      some record.ownerWitness &&
    exactShapeOwnerEvidence record

def hasLiveRecord (state : State) (owner : Owner) (shape : Shape) : Bool :=
  state.records.any (fun record =>
    record.owner == owner && record.shape == shape)

def deterministicOwners (state : State) (shape : Shape) : List Owner :=
  Owner.all.filter (fun owner =>
    (ownerIds state).contains owner && hasLiveRecord state owner shape)

def deterministicBuckets (state : State) : List Bucket :=
  Shape.all.filterMap (fun shape =>
    let owners := deterministicOwners state shape
    if owners.isEmpty then none else some { shape, owners })

def exactSymmetryEvidence (state : State) (entry : SymmetryEntry) : Bool :=
  match owner? state entry.owner with
  | none => false
  | some owner =>
      entry.evidence.left == .ownerWitness owner.id owner.witness &&
        entry.evidence.right == .ownerWitness owner.id owner.witness

def ValidState (state : State) : Bool :=
  decide (state.buckets = deterministicBuckets state) &&
    (state.records.all exactShapeOwnerEvidence &&
    (state.buckets.all (fun bucket => !bucket.owners.isEmpty) &&
    (noDuplicates (ownerIds state) &&
    (noDuplicates (recordIds state.records) &&
    (state.records.all (recordLocallyValid state) &&
    (noDuplicates state.dirty &&
    (state.dirty.all (fun id => (recordIds state.records).contains id) &&
      state.symmetries.all (exactSymmetryEvidence state))))))))

theorem valid_state_has_deterministic_buckets {state : State}
    (valid : ValidState state = true) :
    state.buckets = deterministicBuckets state := by
  unfold ValidState at valid
  have first := (andTrue valid).1
  exact of_decide_eq_true first

theorem valid_state_has_exact_shape_owner_evidence {state : State}
    (valid : ValidState state = true) :
    state.records.all exactShapeOwnerEvidence = true := by
  unfold ValidState at valid
  exact (andTrue (andTrue valid).2).1

def directedEmbedding : Interface -> Interface -> Bool
  | .intSlot, .intSlot => true
  | .boolSlot, .boolSlot => true
  | .sharedSlot, _ => true
  | _, .sharedSlot => true
  | _, _ => false

def collisionAdmissible (left right : OwnerState) : Bool :=
  directedEmbedding left.interface right.interface ||
    directedEmbedding right.interface left.interface

inductive CollisionDecision where
  | merge | coexist
  deriving DecidableEq, Repr, BEq

def decideCollision (left right : OwnerState) : CollisionDecision :=
  if collisionAdmissible left right then .merge else .coexist

theorem incomparable_decision_preserves_coexistence
    (left right : OwnerState)
    (forward : directedEmbedding left.interface right.interface = false)
    (backward : directedEmbedding right.interface left.interface = false) :
    decideCollision left right = .coexist := by
  simp [decideCollision, collisionAdmissible, forward, backward]

def exactTransport
    (evidence : EqualityEvidence)
    (old replacement : LiveRecord) : Bool :=
  evidence.left == .actedShape old.owner old.shape old.shapeTerm &&
    evidence.right ==
      .actedShape replacement.owner replacement.shape replacement.shapeTerm

def eraseRecord (id : RecordId) (records : List LiveRecord) : List LiveRecord :=
  records.filter (fun candidate => candidate.id != id)

inductive UnionEntry where
  | unchanged : RecordId -> UnionEntry
  | rehome : RecordId -> LiveRecord -> EqualityEvidence -> UnionEntry
  | retired : RecordId -> RecordId -> EqualityEvidence -> UnionEntry
  deriving DecidableEq, Repr, BEq

def UnionEntry.sourceId : UnionEntry -> RecordId
  | .unchanged old => old
  | .rehome old _ _ => old
  | .retired old _ _ => old

def UnionEntry.resultRecords
    (before : List LiveRecord) : UnionEntry -> List LiveRecord
  | .unchanged old => (record? before old).toList
  | .rehome _ replacement _ => [replacement]
  | .retired _ _ _ => []

def UnionEntry.retirement? : UnionEntry -> Option Retirement
  | .retired old retained evidence => some { retired := old, retained, evidence }
  | _ => none

def unionResults
    (before : List LiveRecord) (ledger : List UnionEntry) : List LiveRecord :=
  ledger.flatMap (UnionEntry.resultRecords before)

def unionRetirements (ledger : List UnionEntry) : List Retirement :=
  ledger.filterMap UnionEntry.retirement?

def unionEntrySound
    (before : State) (child parent : Owner) : UnionEntry -> Bool
  | .unchanged old =>
      match record? before.records old with
      | none => false
      | some record => record.owner != child
  | .rehome old replacement evidence =>
      match record? before.records old with
      | none => false
      | some source =>
          source.owner == child && replacement.owner == parent &&
            replacement.shape == source.shape &&
            replacement.shapeTerm == source.shapeTerm &&
            exactShapeOwnerEvidence replacement &&
            exactTransport evidence source replacement
  | .retired old retained evidence =>
      match record? before.records old, record? before.records retained with
      | some source, some target =>
          source.owner == child && target.owner == parent &&
            source.shape == target.shape &&
            source.shapeTerm == target.shapeTerm &&
            exactShapeOwnerEvidence target && exactTransport evidence source target
      | _, _ => false

def exactParentEdge
    (before : State) (child parent : Owner) (evidence : EqualityEvidence) : Bool :=
  match owner? before child, owner? before parent with
  | some childState, some parentState =>
      child != parent &&
        evidence.left == .ownerWitness child childState.witness &&
        evidence.right == .ownerWitness parent parentState.witness
  | _, _ => false

def unionSourceExact (before : State) (ledger : List UnionEntry) : Bool :=
  decide (ledger.map UnionEntry.sourceId = recordIds before.records)

def unionResultNoDuplicates
    (before : State) (ledger : List UnionEntry) : Bool :=
  noDuplicates (recordIds (unionResults before.records ledger))

def unionResultExact
    (before after : State) (ledger : List UnionEntry) : Bool :=
  decide (after.records = unionResults before.records ledger)

def unionRetirementExact
    (before after : State) (ledger : List UnionEntry) : Bool :=
  decide (after.retirements = before.retirements ++ unionRetirements ledger)

def transportedSymmetry?
    (before : State) (child parent : Owner)
    (entry : SymmetryEntry) : Option SymmetryEntry :=
  if entry.owner != child || entry.id == .identity then none
  else
    match owner? before parent with
    | none => none
    | some parentState =>
        some {
          id := entry.id
          owner := parent
          evidence := {
            proof := entry.evidence.proof
            left := .ownerWitness parent parentState.witness
            right := .ownerWitness parent parentState.witness
          }
        }

def appendUnique [BEq item] (items : List item) (candidate : item) : List item :=
  if items.contains candidate then items else items ++ [candidate]

def mergedStabilizingSymmetries
    (before : State) (child parent : Owner) : List SymmetryEntry :=
  (before.symmetries.filterMap (transportedSymmetry? before child parent)).foldl
    appendUnique before.symmetries

def ValidUnion
    (before after : State)
    (child parent : Owner)
    (parentEdge : EqualityEvidence)
    (ledger : List UnionEntry) : Bool :=
  unionSourceExact before ledger &&
    (unionResultNoDuplicates before ledger &&
    (unionResultExact before after ledger &&
    (unionRetirementExact before after ledger &&
    (ValidState before &&
    (ValidState after &&
    (exactParentEdge before child parent parentEdge &&
    (noDuplicates (ledger.map UnionEntry.sourceId) &&
    (ledger.all (unionEntrySound before child parent) &&
    (decide (after.owners = before.owners) &&
      decide (after.symmetries =
        mergedStabilizingSymmetries before child parent))))))))))

def unchangedCount : List UnionEntry -> Nat
  | [] => 0
  | .unchanged _ :: rest => 1 + unchangedCount rest
  | _ :: rest => unchangedCount rest

def rehomeCount : List UnionEntry -> Nat
  | [] => 0
  | .rehome _ _ _ :: rest => 1 + rehomeCount rest
  | _ :: rest => rehomeCount rest

def retiredCount : List UnionEntry -> Nat
  | [] => 0
  | .retired _ _ _ :: rest => 1 + retiredCount rest
  | _ :: rest => retiredCount rest

theorem union_partition_count (ledger : List UnionEntry) :
    ledger.length =
      unchangedCount ledger + rehomeCount ledger + retiredCount ledger := by
  induction ledger with
  | nil => rfl
  | cons entry rest ih =>
      cases entry <;> simp [unchangedCount, rehomeCount, retiredCount, ih] <;>
        omega

theorem valid_union_has_no_silent_source_loss
    {before after : State} {child parent : Owner}
    {parentEdge : EqualityEvidence} {ledger : List UnionEntry}
    (valid : ValidUnion before after child parent parentEdge ledger = true) :
    ledger.map UnionEntry.sourceId = recordIds before.records := by
  unfold ValidUnion at valid
  have first := (andTrue valid).1
  unfold unionSourceExact at first
  exact of_decide_eq_true first

theorem valid_union_has_no_result_duplication
    {before after : State} {child parent : Owner}
    {parentEdge : EqualityEvidence} {ledger : List UnionEntry}
    (valid : ValidUnion before after child parent parentEdge ledger = true) :
    (recordIds (unionResults before.records ledger)).Nodup := by
  unfold ValidUnion at valid
  have check := (andTrue (andTrue valid).2).1
  unfold unionResultNoDuplicates noDuplicates at check
  exact of_decide_eq_true check

theorem valid_union_result_is_exact
    {before after : State} {child parent : Owner}
    {parentEdge : EqualityEvidence} {ledger : List UnionEntry}
    (valid : ValidUnion before after child parent parentEdge ledger = true) :
    after.records = unionResults before.records ledger := by
  unfold ValidUnion at valid
  have check :=
    (andTrue (andTrue (andTrue valid).2).2).1
  unfold unionResultExact at check
  exact of_decide_eq_true check

theorem valid_union_retirement_ledger_is_exact
    {before after : State} {child parent : Owner}
    {parentEdge : EqualityEvidence} {ledger : List UnionEntry}
    (valid : ValidUnion before after child parent parentEdge ledger = true) :
    after.retirements = before.retirements ++ unionRetirements ledger := by
  unfold ValidUnion at valid
  have tail1 := (andTrue valid).2
  have tail2 := (andTrue tail1).2
  have tail3 := (andTrue tail2).2
  have check := (andTrue tail3).1
  unfold unionRetirementExact at check
  exact of_decide_eq_true check

theorem valid_union_retains_all_class_records
    {before after : State} {child parent : Owner}
    {parentEdge : EqualityEvidence} {ledger : List UnionEntry}
    (valid : ValidUnion before after child parent parentEdge ledger = true) :
    after.owners = before.owners := by
  unfold ValidUnion at valid
  have tail1 := (andTrue valid).2
  have tail2 := (andTrue tail1).2
  have tail3 := (andTrue tail2).2
  have tail4 := (andTrue tail3).2
  have tail5 := (andTrue tail4).2
  have tail6 := (andTrue tail5).2
  have tail7 := (andTrue tail6).2
  have tail8 := (andTrue tail7).2
  have tail9 := (andTrue tail8).2
  exact of_decide_eq_true (andTrue tail9).1

theorem valid_union_has_exact_transported_symmetries
    {before after : State} {child parent : Owner}
    {parentEdge : EqualityEvidence} {ledger : List UnionEntry}
    (valid : ValidUnion before after child parent parentEdge ledger = true) :
    after.symmetries = mergedStabilizingSymmetries before child parent := by
  unfold ValidUnion at valid
  have tail1 := (andTrue valid).2
  have tail2 := (andTrue tail1).2
  have tail3 := (andTrue tail2).2
  have tail4 := (andTrue tail3).2
  have tail5 := (andTrue tail4).2
  have tail6 := (andTrue tail5).2
  have tail7 := (andTrue tail6).2
  have tail8 := (andTrue tail7).2
  have tail9 := (andTrue tail8).2
  exact of_decide_eq_true (andTrue tail9).2

def symmetryFrameExact (before after : State) : Bool :=
  decide (
    after.owners = before.owners ∧ after.records = before.records ∧
      after.buckets = before.buckets ∧ after.dirty = before.dirty ∧
      after.retirements = before.retirements)

def ValidSymmetryAdd
    (before after : State) (entry : SymmetryEntry) : Bool :=
  decide (after.symmetries = before.symmetries ++ [entry]) &&
    (symmetryFrameExact before after &&
    (ValidState before &&
    (ValidState after &&
    (!(before.symmetries.contains entry) &&
      exactSymmetryEvidence before entry))))

theorem symmetry_add_has_exact_frame
    {before after : State} {entry : SymmetryEntry}
    (valid : ValidSymmetryAdd before after entry = true) :
    after.owners = before.owners ∧ after.records = before.records ∧
      after.buckets = before.buckets ∧ after.dirty = before.dirty ∧
      after.retirements = before.retirements := by
  unfold ValidSymmetryAdd at valid
  have frame := (andTrue (andTrue valid).2).1
  unfold symmetryFrameExact at frame
  exact of_decide_eq_true frame

theorem symmetry_add_cannot_delete_old_entries
    {before after : State} {entry old : SymmetryEntry}
    (valid : ValidSymmetryAdd before after entry = true)
    (member : old ∈ before.symmetries) : old ∈ after.symmetries := by
  unfold ValidSymmetryAdd at valid
  have exactAdd : after.symmetries = before.symmetries ++ [entry] :=
    of_decide_eq_true (andTrue valid).1
  rw [exactAdd]
  simp [member]

inductive RebuildOutcome where
  | keep : RebuildOutcome
  | replace : LiveRecord -> EqualityEvidence -> RebuildOutcome
  | retire : RecordId -> EqualityEvidence -> RebuildOutcome
  deriving DecidableEq, Repr, BEq

def rebuildRecords
    (before : List LiveRecord) (old : RecordId) : RebuildOutcome -> List LiveRecord
  | .keep => before
  | .replace replacement _ => eraseRecord old before ++ [replacement]
  | .retire _ _ => eraseRecord old before

def rebuildRetirements
    (before : List Retirement) (old : RecordId) : RebuildOutcome -> List Retirement
  | .keep => before
  | .replace _ _ => before
  | .retire retained evidence =>
      before ++ [{ retired := old, retained, evidence }]

def rebuildOutcomeSound
    (before : State) (old : RecordId) : RebuildOutcome -> Bool
  | .keep => (recordIds before.records).contains old
  | .replace replacement evidence =>
      match record? before.records old with
      | none => false
      | some source =>
          replacement.id != old && replacement.owner == source.owner &&
            exactShapeOwnerEvidence replacement &&
            exactTransport evidence source replacement
  | .retire retained evidence =>
      match record? before.records old, record? before.records retained with
      | some source, some target =>
          old != retained && source.owner == target.owner &&
            source.shape == target.shape &&
            source.shapeTerm == target.shapeTerm &&
            exactTransport evidence source target
      | _, _ => false

def rebuildDirtyExact (before after : State) (old : RecordId) : Bool :=
  decide (after.dirty = before.dirty.erase old)

def rebuildRecordsExact
    (before after : State) (old : RecordId) (outcome : RebuildOutcome) : Bool :=
  decide (after.records = rebuildRecords before.records old outcome)

def rebuildRetirementsExact
    (before after : State) (old : RecordId) (outcome : RebuildOutcome) : Bool :=
  decide (after.retirements = rebuildRetirements before.retirements old outcome)

def ValidRebuild
    (before after : State) (old : RecordId) (outcome : RebuildOutcome) : Bool :=
  rebuildDirtyExact before after old &&
    (rebuildRecordsExact before after old outcome &&
    (rebuildRetirementsExact before after old outcome &&
    (ValidState before &&
    (ValidState after &&
    (before.dirty.contains old &&
    (rebuildOutcomeSound before old outcome &&
    (decide (after.owners = before.owners) &&
    (decide (after.symmetries = before.symmetries) &&
      decide (after.buckets = deterministicBuckets after)))))))))

theorem valid_rebuild_consumes_exact_dirty_record
    {before after : State} {old : RecordId} {outcome : RebuildOutcome}
    (valid : ValidRebuild before after old outcome = true) :
    after.dirty = before.dirty.erase old := by
  unfold ValidRebuild at valid
  have check := (andTrue valid).1
  unfold rebuildDirtyExact at check
  exact of_decide_eq_true check

theorem valid_rebuild_replaces_or_retires_exactly
    {before after : State} {old : RecordId} {outcome : RebuildOutcome}
    (valid : ValidRebuild before after old outcome = true) :
    after.records = rebuildRecords before.records old outcome ∧
      after.retirements = rebuildRetirements before.retirements old outcome := by
  unfold ValidRebuild at valid
  have tail1 := (andTrue valid).2
  have records := (andTrue tail1).1
  have retirements := (andTrue (andTrue tail1).2).1
  unfold rebuildRecordsExact at records
  unfold rebuildRetirementsExact at retirements
  exact ⟨of_decide_eq_true records, of_decide_eq_true retirements⟩

/- Exact bounded transition frames.  Unlike the record-only model above,
   these frames retain every Java-observable administrative component used by
   the schema-v8 transition checker. -/

inductive TraceStatus where
  | dirty | quiescent
  deriving DecidableEq, Repr, BEq

structure ParentStepFrame where
  child : Owner
  parent : Owner
  childInterface : Interface
  parentInterface : Interface
  proof : Option ProofId
  deriving DecidableEq, Repr, BEq

structure ParentFrame where
  child : Owner
  parent : Owner
  path : List ParentStepFrame
  deriving DecidableEq, Repr, BEq

structure InvocationUse where
  child : Owner
  record : RecordId
  deriving DecidableEq, Repr, BEq

structure TraceState where
  core : State
  parents : List ParentFrame
  invocations : List InvocationUse
  reverseUses : List InvocationUse
  restrictions : List Owner
  insertions : List Owner
  revision : Nat
  status : TraceStatus
  deriving DecidableEq, Repr, BEq

def parent? (parents : List ParentFrame) (child : Owner) : Option ParentFrame :=
  parents.find? (fun assignment => assignment.child == child)

def rootWithin (parents : List ParentFrame) (start : Owner) : Nat -> Option Owner
  | 0 => none
  | fuel + 1 =>
      match parent? parents start with
      | none => none
      | some assignment =>
          if assignment.parent == start then some start
          else rootWithin parents assignment.parent fuel

def pathChain : Owner -> List ParentStepFrame -> Owner -> Bool
  | current, [], finish => current == finish
  | current, step :: rest, finish =>
      step.child == current && pathChain step.parent rest finish

def parentStepExact (frame : TraceState) (step : ParentStepFrame) : Bool :=
  match owner? frame.core step.child, owner? frame.core step.parent with
  | some child, some parent =>
      child.interface == step.childInterface &&
        parent.interface == step.parentInterface && step.proof.isSome
  | _, _ => false

def parentFrameExact (frame : TraceState) (assignment : ParentFrame) : Bool :=
  let fuel := frame.parents.length + 1
  let rootsAgree := assignment.path.all (fun step =>
    rootWithin frame.parents step.child fuel ==
      rootWithin frame.parents step.parent fuel)
  (ownerIds frame.core).contains assignment.child &&
    ((ownerIds frame.core).contains assignment.parent &&
    (pathChain assignment.child assignment.path assignment.parent &&
    (assignment.path.all (parentStepExact frame) &&
    (rootsAgree &&
    ((rootWithin frame.parents assignment.child fuel).isSome &&
      if assignment.child == assignment.parent
      then assignment.path.isEmpty
      else !assignment.path.isEmpty)))))

def canonicalUses (uses : List InvocationUse) : List InvocationUse :=
  Owner.all.flatMap (fun child =>
    RecordId.all.filterMap (fun record =>
      let candidate : InvocationUse := { child, record }
      if uses.contains candidate then some candidate else none))

def invocationLocallyValid (frame : TraceState) (use : InvocationUse) : Bool :=
  (ownerIds frame.core).contains use.child &&
    (recordIds frame.core.records).contains use.record

def WellFormedTraceState (frame : TraceState) : Bool :=
  ValidState frame.core &&
    (decide (frame.parents.map (fun assignment => assignment.child) =
      ownerIds frame.core) &&
    (frame.parents.all (parentFrameExact frame) &&
    (noDuplicates frame.invocations &&
    (frame.invocations.all (invocationLocallyValid frame) &&
    (decide (frame.reverseUses = canonicalUses frame.invocations) &&
    (noDuplicates frame.restrictions &&
    (frame.restrictions.all (ownerIds frame.core).contains &&
    (noDuplicates frame.insertions &&
    (frame.insertions.all (ownerIds frame.core).contains &&
      if frame.status == .quiescent
      then frame.core.dirty.isEmpty
      else true)))))))))

def interfaceOf (state : State) (owner : Owner) : Interface :=
  (owner? state owner).map (fun value => value.interface) |>.getD .intSlot

def rootParents (state : State) : List ParentFrame :=
  (ownerIds state).map (fun owner => { child := owner, parent := owner, path := [] })

structure UnionFrame where
  child : Owner
  parent : Owner
  parentEdge : EqualityEvidence
  ledger : List UnionEntry
  publicRevision : Bool
  deriving DecidableEq, Repr, BEq

def unionMappedRecord? (ledger : List UnionEntry) (id : RecordId) : Option RecordId :=
  match ledger.find? (fun entry => entry.sourceId == id) with
  | none => none
  | some (.unchanged old) => some old
  | some (.rehome _ replacement _) => some replacement.id
  | some (.retired _ retained _) => some retained

def unionInvocations
    (before : TraceState) (ledger : List UnionEntry) : List InvocationUse :=
  canonicalUses (before.invocations.filterMap (fun use =>
    (unionMappedRecord? ledger use.record).map (fun mapped =>
      { child := use.child, record := mapped })))

def expectedUnionDirty
    (before : TraceState) (payload : UnionFrame)
    (mappedUses : List InvocationUse) : List RecordId :=
  let symmetryChanged :=
    mergedStabilizingSymmetries before.core payload.child payload.parent !=
      before.core.symmetries
  RecordId.all.filter (fun id =>
    before.core.dirty.any (fun old =>
      unionMappedRecord? payload.ledger old == some id) ||
    mappedUses.any (fun use =>
      use.record == id &&
        (use.child == payload.child ||
          (symmetryChanged && use.child == payload.parent))))

def unionCore (before : TraceState) (payload : UnionFrame) : State :=
  let mappedUses := unionInvocations before payload.ledger
  let provisional : State := {
    before.core with
    records := unionResults before.core.records payload.ledger
    buckets := []
    symmetries := mergedStabilizingSymmetries
      before.core payload.child payload.parent
    dirty := expectedUnionDirty before payload mappedUses
    retirements := before.core.retirements ++ unionRetirements payload.ledger
  }
  { provisional with buckets := deterministicBuckets provisional }

def directParentFrame (before : TraceState) (payload : UnionFrame) : ParentFrame :=
  {
    child := payload.child
    parent := payload.parent
    path := [{
      child := payload.child
      parent := payload.parent
      childInterface := interfaceOf before.core payload.child
      parentInterface := interfaceOf before.core payload.parent
      proof := some payload.parentEdge.proof
    }]
  }

def unionParents (before : TraceState) (payload : UnionFrame) : List ParentFrame :=
  before.parents.map (fun assignment =>
    if assignment.child == payload.child
    then directParentFrame before payload
    else assignment)

def unionEffect (before : TraceState) (payload : UnionFrame) : TraceState :=
  let uses := unionInvocations before payload.ledger
  {
    core := unionCore before payload
    parents := unionParents before payload
    invocations := uses
    reverseUses := canonicalUses uses
    restrictions := before.restrictions
    insertions := before.insertions
    revision := before.revision + if payload.publicRevision then 1 else 0
    status := .dirty
  }

def ValidUnionFrame
    (before after : TraceState) (payload : UnionFrame) : Bool :=
  let expected := unionEffect before payload
  decide (after = expected) &&
    (WellFormedTraceState before &&
    (WellFormedTraceState expected &&
    (ValidUnion before.core expected.core payload.child payload.parent
      payload.parentEdge payload.ledger &&
      if payload.publicRevision
      then before.status == .quiescent
      else before.status == .dirty)))

theorem valid_union_frame_is_the_exact_effect
    {before after : TraceState} {payload : UnionFrame}
    (valid : ValidUnionFrame before after payload = true) :
    after = unionEffect before payload := by
  unfold ValidUnionFrame at valid
  exact of_decide_eq_true (andTrue valid).1

theorem valid_union_frame_fixes_revision_and_status
    {before after : TraceState} {payload : UnionFrame}
    (valid : ValidUnionFrame before after payload = true) :
    after.revision = before.revision + (if payload.publicRevision then 1 else 0) ∧
      after.status = .dirty := by
  rw [valid_union_frame_is_the_exact_effect valid]
  simp [unionEffect]

def rebuildResultRecord (old : RecordId) : RebuildOutcome -> RecordId
  | .keep => old
  | .replace replacement _ => replacement.id
  | .retire retained _ => retained

def rebuildInvocations
    (before : TraceState) (old : RecordId) (outcome : RebuildOutcome) :
    List InvocationUse :=
  canonicalUses (before.invocations.map (fun use =>
    if use.record == old
    then { use with record := rebuildResultRecord old outcome }
    else use))

def rebuildCore
    (before : TraceState) (old : RecordId) (outcome : RebuildOutcome) : State :=
  let provisional : State := {
    before.core with
    records := rebuildRecords before.core.records old outcome
    buckets := []
    dirty := before.core.dirty.erase old
    retirements := rebuildRetirements before.core.retirements old outcome
  }
  { provisional with buckets := deterministicBuckets provisional }

def rebuildBaseEffect
    (before : TraceState) (old : RecordId) (outcome : RebuildOutcome) :
    TraceState :=
  let uses := rebuildInvocations before old outcome
  {
    core := rebuildCore before old outcome
    parents := before.parents
    invocations := uses
    reverseUses := canonicalUses uses
    restrictions := before.restrictions
    insertions := before.insertions
    revision := before.revision
    status := .dirty
  }

def ValidRebuildBaseFrame
    (before after : TraceState) (old : RecordId) (outcome : RebuildOutcome) : Bool :=
  let expected := rebuildBaseEffect before old outcome
  decide (after = expected) &&
    (before.status == .dirty &&
    (WellFormedTraceState before &&
    (WellFormedTraceState expected &&
      ValidRebuild before.core expected.core old outcome)))

theorem valid_rebuild_base_frame_is_the_exact_effect
    {before after : TraceState} {old : RecordId} {outcome : RebuildOutcome}
    (valid : ValidRebuildBaseFrame before after old outcome = true) :
    after = rebuildBaseEffect before old outcome := by
  unfold ValidRebuildBaseFrame at valid
  exact of_decide_eq_true (andTrue valid).1

def applyInternalUnions : TraceState -> List UnionFrame -> Option TraceState
  | state, [] => some state
  | state, payload :: rest =>
      let next := unionEffect state payload
      if payload.publicRevision || !ValidUnionFrame state next payload
      then none
      else applyInternalUnions next rest

structure RebuildRecordFrame where
  old : RecordId
  outcome : RebuildOutcome
  generatedUnions : List UnionFrame
  deriving DecidableEq, Repr, BEq

def rebuildRecordEffect?
    (before : TraceState) (payload : RebuildRecordFrame) : Option TraceState :=
  let base := rebuildBaseEffect before payload.old payload.outcome
  if ValidRebuildBaseFrame before base payload.old payload.outcome
  then applyInternalUnions base payload.generatedUnions
  else none

def ValidRebuildRecordFrame
    (before after : TraceState) (payload : RebuildRecordFrame) : Bool :=
  decide (rebuildRecordEffect? before payload = some after) &&
    (after.revision == before.revision && after.status == .dirty)

theorem valid_rebuild_record_frame_is_the_exact_effect
    {before after : TraceState} {payload : RebuildRecordFrame}
    (valid : ValidRebuildRecordFrame before after payload = true) :
    rebuildRecordEffect? before payload = some after := by
  unfold ValidRebuildRecordFrame at valid
  exact of_decide_eq_true (andTrue valid).1

def ValidRebuildStart (before after : TraceState) : Bool :=
  decide (after = before) && before.status == .dirty

theorem valid_rebuild_start_is_an_exact_noop
    {before after : TraceState}
    (valid : ValidRebuildStart before after = true) : after = before := by
  unfold ValidRebuildStart at valid
  exact of_decide_eq_true (andTrue valid).1

def completionEffect (before : TraceState) (changed : Bool) : TraceState :=
  {
    before with
    revision := before.revision + if changed then 1 else 0
    status := .quiescent
  }

def ValidRebuildCompletion
    (before after : TraceState) (changed : Bool) : Bool :=
  decide (after = completionEffect before changed) &&
    (before.status == .dirty &&
    (before.core.dirty.isEmpty && WellFormedTraceState after))

theorem valid_rebuild_completion_is_the_exact_effect
    {before after : TraceState} {changed : Bool}
    (valid : ValidRebuildCompletion before after changed = true) :
    after = completionEffect before changed := by
  unfold ValidRebuildCompletion at valid
  exact of_decide_eq_true (andTrue valid).1

structure RebuildReportFrame where
  firstSequence : Nat
  processed : List RecordId
  changed : Nat
  unions : Nat
  maximumDirty : Nat
  deriving DecidableEq, Repr, BEq

structure OpenRebuild where
  firstSequence : Nat
  processed : List RecordId
  changed : Nat
  unions : Nat
  maximumDirty : Nat
  deriving DecidableEq, Repr, BEq

structure IntervalMachine where
  nextSequence : Nat
  openRebuild : Option OpenRebuild
  deriving DecidableEq, Repr, BEq

inductive IntervalBody where
  | ordinary
  | start : Nat -> IntervalBody
  | record : RecordId -> Bool -> Nat -> Nat -> IntervalBody
  | union : Nat -> IntervalBody
  | complete : RebuildReportFrame -> IntervalBody
  deriving DecidableEq, Repr, BEq

structure IntervalEvent where
  sequence : Nat
  body : IntervalBody
  deriving DecidableEq, Repr, BEq

def exactReport (active : OpenRebuild) : RebuildReportFrame := {
  firstSequence := active.firstSequence
  processed := active.processed
  changed := active.changed
  unions := active.unions
  maximumDirty := active.maximumDirty
}

def stepInterval
    (machine : IntervalMachine) (event : IntervalEvent) : Option IntervalMachine :=
  if event.sequence != machine.nextSequence then none
  else
    let next := machine.nextSequence + 1
    match machine.openRebuild, event.body with
    | none, .ordinary => some { nextSequence := next, openRebuild := none }
    | none, .start dirty => some {
        nextSequence := next
        openRebuild := some {
          firstSequence := event.sequence
          processed := []
          changed := 0
          unions := 0
          maximumDirty := dirty
        }
      }
    | some active, .record old changed generated dirty => some {
        nextSequence := next
        openRebuild := some {
          active with
          processed := active.processed ++ [old]
          changed := active.changed + if changed then 1 else 0
          unions := active.unions + generated
          maximumDirty := Nat.max active.maximumDirty dirty
        }
      }
    | some active, .union dirty => some {
        nextSequence := next
        openRebuild := some {
          active with
          unions := active.unions + 1
          maximumDirty := Nat.max active.maximumDirty dirty
        }
      }
    | some active, .complete report =>
        if report == exactReport active
        then some { nextSequence := next, openRebuild := none }
        else none
    | _, _ => none

def closedInterval (machine : IntervalMachine) : Bool :=
  machine.openRebuild.isNone

def intervalInitial : IntervalMachine := {
  nextSequence := 0
  openRebuild := none
}

def exactIntervalReport : RebuildReportFrame := {
  firstSequence := 0
  processed := [.r0]
  changed := 1
  unions := 1
  maximumDirty := 2
}

def exactClosedInterval : Option IntervalMachine := do
  let started <- stepInterval intervalInitial ⟨0, .start 2⟩
  let recorded <- stepInterval started ⟨1, .record .r0 true 1 2⟩
  stepInterval recorded ⟨2, .complete exactIntervalReport⟩

example : exactClosedInterval = some {
    nextSequence := 3, openRebuild := none } := by native_decide
example : stepInterval intervalInitial ⟨0, .record .r0 true 0 1⟩ = none := by
  native_decide
example : stepInterval intervalInitial ⟨0, .complete exactIntervalReport⟩ = none := by
  native_decide
example :
    (stepInterval intervalInitial ⟨0, .start 1⟩).map closedInterval = some false := by
  native_decide
example :
    (do
      let started <- stepInterval intervalInitial ⟨0, .start 1⟩
      stepInterval started ⟨1, .ordinary⟩) = none := by
  native_decide
example :
    (do
      let started <- stepInterval intervalInitial ⟨0, .start 1⟩
      stepInterval started ⟨1, .start 1⟩) = none := by
  native_decide
example :
    (do
      let started <- stepInterval intervalInitial ⟨0, .start 2⟩
      let recorded <- stepInterval started ⟨1, .record .r0 true 1 2⟩
      stepInterval recorded ⟨2, .complete {
        exactIntervalReport with firstSequence := 1 }⟩) = none := by
  native_decide

def owner0Int : OwnerState := ⟨.o0, .intSlot, 10⟩
def owner1Bool : OwnerState := ⟨.o1, .boolSlot, 20⟩
def owner1Int : OwnerState := ⟨.o1, .intSlot, 20⟩
def owner2Int : OwnerState := ⟨.o2, .intSlot, 30⟩

def exactRecord
    (id : RecordId) (owner : Owner) (shape : Shape)
    (shapeTerm ownerWitness : Nat) (proof : ProofId) : LiveRecord :=
  {
    id, owner, shape, shapeTerm, ownerWitness
    ownerEquation := {
      proof
      left := .actedShape owner shape shapeTerm
      right := .ownerWitness owner ownerWitness
    }
  }

def r0 : LiveRecord := exactRecord .r0 .o0 .s0 100 10 .p0
def r1 : LiveRecord := exactRecord .r1 .o0 .s1 101 10 .p1
def r2 : LiveRecord := exactRecord .r2 .o2 .s0 100 30 .p2
def r3 : LiveRecord := exactRecord .r3 .o1 .s1 101 20 .p3
def r4 : LiveRecord := exactRecord .r4 .o1 .s0 100 20 .p4

def transport (old replacement : LiveRecord) (proof : ProofId) : EqualityEvidence :=
  {
    proof
    left := .actedShape old.owner old.shape old.shapeTerm
    right := .actedShape replacement.owner replacement.shape replacement.shapeTerm
  }

def parentEdge : EqualityEvidence :=
  { proof := .p5, left := .ownerWitness .o0 10, right := .ownerWitness .o1 20 }

def baseState
    (owners : List OwnerState) (records : List LiveRecord)
    (symmetries : List SymmetryEntry := [])
    (dirty : List RecordId := [])
    (retirements : List Retirement := []) : State :=
  let initial : State := {
    owners, records, buckets := [], symmetries, dirty, retirements
  }
  { initial with buckets := deterministicBuckets initial }

def incomparableState : State :=
  baseState [owner0Int, owner1Bool]
    [r0, exactRecord .r3 .o1 .s0 100 20 .p3]

def unionBefore : State :=
  baseState [owner0Int, owner1Int, owner2Int] [r0, r1, r2, r3]

def unionLedger : List UnionEntry :=
  [
    .rehome .r0 r4 (transport r0 r4 .p4),
    .retired .r1 .r3 (transport r1 r3 .p5),
    .unchanged .r2,
    .unchanged .r3
  ]

def unionAfter : State :=
  baseState [owner0Int, owner1Int, owner2Int]
    (unionResults unionBefore.records unionLedger)
    (mergedStabilizingSymmetries unionBefore .o0 .o1)
    [] (unionRetirements unionLedger)

def traceUnionBefore : TraceState := {
  core := unionBefore
  parents := rootParents unionBefore
  invocations := []
  reverseUses := []
  restrictions := []
  insertions := []
  revision := 4
  status := .quiescent
}

def traceUnionPayload : UnionFrame := {
  child := .o0
  parent := .o1
  parentEdge
  ledger := unionLedger
  publicRevision := true
}

def traceUnionAfter : TraceState := unionEffect traceUnionBefore traceUnionPayload

def arbitraryDirtyTraceUnionAfter : TraceState :=
  let core := { traceUnionAfter.core with dirty := [.r2] }
  { traceUnionAfter with core }

def exactSymmetry : SymmetryEntry := {
  id := .identity
  owner := .o0
  evidence := {
    proof := .p0
    left := .ownerWitness .o0 10
    right := .ownerWitness .o0 10
  }
}

def childSwap : SymmetryEntry := {
  id := .swap
  owner := .o0
  evidence := {
    proof := .p1
    left := .ownerWitness .o0 10
    right := .ownerWitness .o0 10
  }
}

def transportedParentSwap : SymmetryEntry := {
  id := .swap
  owner := .o1
  evidence := {
    proof := .p1
    left := .ownerWitness .o1 20
    right := .ownerWitness .o1 20
  }
}

def symmetryUnionBefore : State :=
  baseState [owner0Int, owner1Int, owner2Int]
    [r0, r1, r2, r3] [childSwap]

def symmetryUnionAfter : State :=
  baseState [owner0Int, owner1Int, owner2Int]
    (unionResults symmetryUnionBefore.records unionLedger)
    (mergedStabilizingSymmetries symmetryUnionBefore .o0 .o1)
    [] (unionRetirements unionLedger)

def symmetryBefore : State := baseState [owner0Int] [r0]
def symmetryAfter : State := baseState [owner0Int] [r0] [exactSymmetry]
def symmetryDeletion : State := baseState [owner0Int] [r0]
def symmetryCoreMutation : State :=
  baseState [owner0Int, owner2Int] [r0, r2] [exactSymmetry]

def rebuildBefore : State := baseState [owner0Int] [r0, r1] [] [.r0]
def rebuiltR4 : LiveRecord := exactRecord .r4 .o0 .s0 102 10 .p4
def replaceOutcome : RebuildOutcome :=
  .replace rebuiltR4 (transport r0 rebuiltR4 .p5)
def rebuildAfterReplace : State :=
  baseState [owner0Int]
    (rebuildRecords rebuildBefore.records .r0 replaceOutcome)

def traceRebuildBefore : TraceState := {
  core := rebuildBefore
  parents := rootParents rebuildBefore
  invocations := []
  reverseUses := []
  restrictions := []
  insertions := []
  revision := 7
  status := .dirty
}

def traceRebuildPayload : RebuildRecordFrame := {
  old := .r0
  outcome := replaceOutcome
  generatedUnions := []
}

def traceRebuildAfter : TraceState :=
  rebuildBaseEffect traceRebuildBefore .r0 replaceOutcome

def duplicateShapeR1 : LiveRecord := exactRecord .r1 .o0 .s0 100 10 .p1
def retireOutcome : RebuildOutcome :=
  .retire .r1 (transport r0 duplicateShapeR1 .p5)
def rebuildRetireBefore : State :=
  baseState [owner0Int] [r0, duplicateShapeR1] [] [.r0]
def rebuildAfterRetire : State :=
  baseState [owner0Int]
    (rebuildRecords rebuildRetireBefore.records .r0 retireOutcome)
    [] [] (rebuildRetirements [] .r0 retireOutcome)

def staleOwnerEvidence : LiveRecord :=
  { r4 with ownerEquation := {
      proof := .p4
      left := .actedShape .o0 .s0 100
      right := .ownerWitness .o0 10
    } }

def silentLossLedger : List UnionEntry := unionLedger.erase (.unchanged .r2)
def duplicateLedger : List UnionEntry := unionLedger ++ [.unchanged .r3]

def phase4FiniteChecks : List (String × Bool) :=
  [
    ("valid-incomparable-state", ValidState incomparableState),
    ("incomparable-owners-coexist",
      decide (decideCollision owner0Int owner1Bool = .coexist)),
    ("deterministic-owner-order",
      decide (deterministicOwners incomparableState .s0 = [.o0, .o1])),
    ("valid-union-partition",
      ValidUnion unionBefore unionAfter .o0 .o1 parentEdge unionLedger),
    ("valid-exact-union-transition-frame",
      ValidUnionFrame traceUnionBefore traceUnionAfter traceUnionPayload),
    ("reject-arbitrary-dirty-union-frame",
      !ValidUnionFrame traceUnionBefore arbitraryDirtyTraceUnionAfter
        traceUnionPayload),
    ("reject-zero-revision-public-union-frame",
      !ValidUnionFrame traceUnionBefore
        (unionEffect traceUnionBefore
          { traceUnionPayload with publicRevision := false })
        { traceUnionPayload with publicRevision := false }),
    ("valid-union-retains-child-and-transports-symmetry",
      ValidUnion symmetryUnionBefore symmetryUnionAfter
        .o0 .o1 parentEdge unionLedger),
    ("union-symmetry-transfer-is-exact",
      decide (symmetryUnionAfter.symmetries =
        [childSwap, transportedParentSwap])),
    ("reject-silent-union-loss",
      !ValidUnion unionBefore unionAfter .o0 .o1 parentEdge silentLossLedger),
    ("reject-duplicate-union-source",
      !ValidUnion unionBefore unionAfter .o0 .o1 parentEdge duplicateLedger),
    ("reject-stale-shape-owner-evidence",
      !exactShapeOwnerEvidence staleOwnerEvidence),
    ("valid-exact-symmetry-add",
      ValidSymmetryAdd symmetryBefore symmetryAfter exactSymmetry),
    ("reject-symmetry-deletion",
      !ValidSymmetryAdd symmetryAfter symmetryDeletion exactSymmetry),
    ("reject-symmetry-core-mutation",
      !ValidSymmetryAdd symmetryBefore symmetryCoreMutation exactSymmetry),
    ("valid-rebuild-replacement",
      ValidRebuild rebuildBefore rebuildAfterReplace .r0 replaceOutcome),
    ("valid-exact-rebuild-record-frame",
      ValidRebuildRecordFrame traceRebuildBefore traceRebuildAfter
        traceRebuildPayload),
    ("valid-rebuild-retirement",
      ValidRebuild rebuildRetireBefore rebuildAfterRetire .r0 retireOutcome),
    ("reject-rebuild-without-dirty-consumption",
      !ValidRebuild
        { rebuildBefore with dirty := [] } rebuildAfterReplace .r0 replaceOutcome),
    ("reject-rebuild-drop-without-retirement",
      !ValidRebuild rebuildRetireBefore
        (baseState [owner0Int] [duplicateShapeR1]) .r0 retireOutcome)
  ]

example : ValidState incomparableState = true := by native_decide
example : decideCollision owner0Int owner1Bool = .coexist := by native_decide
example : deterministicOwners incomparableState .s0 = [.o0, .o1] := by
  native_decide
example : ValidUnion unionBefore unionAfter .o0 .o1 parentEdge unionLedger =
    true := by native_decide
example : ValidUnion symmetryUnionBefore symmetryUnionAfter
    .o0 .o1 parentEdge unionLedger = true := by native_decide
example : symmetryUnionAfter.symmetries =
    [childSwap, transportedParentSwap] := by native_decide
example : ValidUnion unionBefore unionAfter .o0 .o1 parentEdge silentLossLedger =
    false := by native_decide
example : ValidUnion unionBefore unionAfter .o0 .o1 parentEdge duplicateLedger =
    false := by native_decide
example : exactShapeOwnerEvidence staleOwnerEvidence = false := by native_decide
example : ValidSymmetryAdd symmetryBefore symmetryAfter exactSymmetry = true := by
  native_decide
example : ValidSymmetryAdd symmetryAfter symmetryDeletion exactSymmetry = false := by
  native_decide
example : ValidSymmetryAdd symmetryBefore symmetryCoreMutation exactSymmetry =
    false := by native_decide
example : ValidRebuild rebuildBefore rebuildAfterReplace .r0 replaceOutcome =
    true := by native_decide
example : ValidRebuild rebuildRetireBefore rebuildAfterRetire .r0 retireOutcome =
    true := by native_decide
example : phase4FiniteChecks.all (fun check => check.2) = true := by
  native_decide

#eval phase4FiniteChecks

end Section3.Phase4WireConservation
