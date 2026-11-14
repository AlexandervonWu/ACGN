import Focused225ConcreteWitnesses

namespace Focused225SelectedConsumers
open Focused225Concrete Focused225SharedContracts

structure OperationKey where
  receipt : String
  pointer : String
  deriving DecidableEq

structure MatrixPair where
  key : OperationKey
  declarationIndex : Nat
  kind : String
  cost : Nat
  before : MatrixUse
  after : MatrixUse
  deriving DecidableEq

def pairAt (selected : List MatrixPair) (key : OperationKey) : Option MatrixPair :=
  match selected.filter (fun op => decide (op.key = key)) with
  | [op] => some op
  | _ => none

def pairedRoute (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (selected : List MatrixPair)
    (key : OperationKey) (before after : MatrixUse) : Option TypedRoute := do
  let op ← pairAt selected key
  if op.before = before ∧ op.after = after ∧ op.kind = "metric-align" ∧ op.cost = 0 then
    selectedRoute tuple env candidate op.declarationIndex (some before.binding) (some after.binding)
  else none

theorem paired_route_exact (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (selected : List MatrixPair)
    (key : OperationKey) (before after : MatrixUse) (route : TypedRoute)
    (checked : pairedRoute tuple env candidate selected key before after = some route) :
    ∃ op, pairAt selected key = some op ∧ op.before = before ∧ op.after = after ∧
      op.kind = "metric-align" ∧ op.cost = 0 ∧
      selectedRoute tuple env candidate op.declarationIndex (some before.binding) (some after.binding) = some route := by
  unfold pairedRoute at checked
  cases h : pairAt selected key with
  | none => simp [h] at checked
  | some op =>
    by_cases pair : op.before = before ∧ op.after = after ∧ op.kind = "metric-align" ∧ op.cost = 0
    · simp [h,pair] at checked
      exact ⟨op,rfl,pair.1,pair.2.1,pair.2.2.1,pair.2.2.2,checked⟩
    · simp [h,pair] at checked

theorem genuine_cross_pair_rejected (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (selected : List MatrixPair)
    (key : OperationKey) (op : MatrixPair) (before after : MatrixUse)
    (found : pairAt selected key = some op) (wrong : op.after ≠ after) :
    pairedRoute tuple env candidate selected key before after = none := by
  simp [pairedRoute,found,wrong]

theorem selected_pair_accepts (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (op : MatrixPair) (route : TypedRoute)
    (kind : op.kind = "metric-align") (cost : op.cost = 0)
    (selected : selectedRoute tuple env candidate op.declarationIndex
      (some op.before.binding) (some op.after.binding) = some route) :
    pairedRoute tuple env candidate [op] op.key op.before op.after = some route := by
  simp [pairedRoute,pairAt,kind,cost,selected]

/- A display label has no authority. Charge identity is the exact immutable
   selected native operation, shared by every component that borrows it. -/
structure ChargeEntry where
  displayLabel : String
  nativeOperation : OperationKey
  payment : Payment
  deriving DecidableEq

def ChargeEntry.key (entry : ChargeEntry) : OperationKey := entry.nativeOperation

structure HeadPoint where
  sourceHash : String
  predicate : String
  phase : Nat
  ownerPhase : Nat
  role : String
  sourcePath : String
  operator : String
  deriving DecidableEq

structure TemporalEdit where
  key : OperationKey
  before : Option HeadPoint
  after : Option HeadPoint
  charge : ChargeEntry
  deriving DecidableEq

structure ReferenceUse where
  key : OperationKey
  sourceSide : Bool
  head : HeadPoint
  nodePath : String
  originalPayload : String
  deriving DecidableEq

structure Borrow where
  consumer : OperationKey
  chargeKey : OperationKey
  deriving DecidableEq

structure Context where
  tuple : Binding → List String
  env : Environment
  candidate : JointCandidate (List String)
  matrixPairs : List MatrixPair
  temporalEdits : List TemporalEdit
  references : List ReferenceUse
  charges : List ChargeEntry

def chargeAt (charges : List ChargeEntry) (key : OperationKey) : Option ChargeEntry :=
  match charges.filter (fun entry => decide (entry.key = key)) with
  | [entry] => some entry
  | _ => none

def referenceAt (refs : List ReferenceUse) (key : OperationKey) : Option ReferenceUse :=
  match refs.filter (fun ref => decide (ref.key = key)) with
  | [ref] => some ref
  | _ => none

def temporalOwner (edits : List TemporalEdit) (ref : ReferenceUse) : Option ChargeEntry :=
  match edits.filter (fun edit => decide
      (edit.key = edit.charge.nativeOperation ∧
       (if ref.sourceSide then edit.before else edit.after) = some ref.head)) with
  | [edit] => some edit.charge
  | _ => none

/- A consumer's authority is computed from its selected operation, never
   supplied as an arbitrary permission Boolean or an existing-token lookup. -/
def authorize (ctx : Context) (request : Borrow) : Option ChargeEntry := do
  let charge ← chargeAt ctx.charges request.chargeKey
  match pairAt ctx.matrixPairs request.consumer, referenceAt ctx.references request.consumer with
  | some op, none => do
    let route ← pairedRoute ctx.tuple ctx.env ctx.candidate ctx.matrixPairs
      request.consumer op.before op.after
    if charge.payment = routePayment route then some charge else none
  | none, some ref =>
    if temporalOwner ctx.temporalEdits ref = some charge then some charge else none
  | _, _ => none

def consumers (ctx : Context) : List OperationKey :=
  ctx.matrixPairs.map MatrixPair.key ++ ctx.references.map ReferenceUse.key

def ownershipCheck (ctx : Context) (claimed : List ChargeEntry) (borrows : List Borrow) : Bool :=
  decide ((ctx.charges.map ChargeEntry.key).Nodup ∧ claimed.Perm ctx.charges ∧
    (consumers ctx).Nodup ∧ (borrows.map Borrow.consumer).Perm (consumers ctx)) &&
  (ctx.temporalEdits.all (fun edit => decide
    (edit.key = edit.charge.nativeOperation ∧ edit.charge ∈ ctx.charges)) &&
   borrows.all (fun b => (authorize ctx b).isSome))

theorem display_alias_has_same_identity (entry : ChargeEntry) (alias : String) :
    ({ entry with displayLabel := alias } : ChargeEntry).key = entry.key := rfl

theorem duplicate_native_origin_rejected (ctx : Context) (a b : ChargeEntry)
    (rest claimed : List ChargeEntry) (borrows : List Borrow)
    (same : a.nativeOperation = b.nativeOperation) :
    ownershipCheck { ctx with charges := a :: b :: rest } claimed borrows = false := by
  simp [ownershipCheck,ChargeEntry.key,List.nodup_cons,same]

theorem checked_ownership_complete (ctx : Context) (claimed : List ChargeEntry) (borrows : List Borrow)
    (checked : ownershipCheck ctx claimed borrows = true) :
    (claimed.map ChargeEntry.key).Nodup ∧ claimed.Perm ctx.charges ∧
    (borrows.map Borrow.consumer).Perm (consumers ctx) ∧
    (claimed.map (fun c => c.payment.amount)).sum = (ctx.charges.map (fun c => c.payment.amount)).sum := by
  have h := of_decide_eq_true (Bool.and_eq_true_iff.mp checked).1
  exact ⟨(h.2.1.map ChargeEntry.key).nodup_iff.mpr h.1,h.2.1,h.2.2.2,
    (h.2.1.map (fun c => c.payment.amount)).sum_nat⟩

theorem every_consumer_authorized (ctx : Context) (claimed : List ChargeEntry) (borrows : List Borrow)
    (checked : ownershipCheck ctx claimed borrows = true) (request : Borrow) (member : request ∈ borrows) :
    ∃ charge, authorize ctx request = some charge := by
  have valid := List.all_eq_true.mp (Bool.and_eq_true_iff.mp
    (Bool.and_eq_true_iff.mp checked).2).2 request member
  cases h : authorize ctx request with
  | none => simp [h] at valid
  | some charge => exact ⟨charge,rfl⟩

theorem checked_temporal_issuance (ctx : Context) (claimed : List ChargeEntry)
    (borrows : List Borrow) (edit : TemporalEdit)
    (checked : ownershipCheck ctx claimed borrows = true) (member : edit ∈ ctx.temporalEdits) :
    edit.key = edit.charge.nativeOperation ∧ edit.charge ∈ ctx.charges := by
  exact of_decide_eq_true (List.all_eq_true.mp
    (Bool.and_eq_true_iff.mp (Bool.and_eq_true_iff.mp checked).2).1 edit member)

theorem matrix_borrow_bound_to_selected_route (ctx : Context) (request : Borrow)
    (op : MatrixPair) (charge : ChargeEntry)
    (matrix : pairAt ctx.matrixPairs request.consumer = some op)
    (reference : referenceAt ctx.references request.consumer = none)
    (checked : authorize ctx request = some charge) :
    ∃ route, pairedRoute ctx.tuple ctx.env ctx.candidate ctx.matrixPairs request.consumer
      op.before op.after = some route ∧ charge.payment = routePayment route := by
  unfold authorize at checked
  cases hc : chargeAt ctx.charges request.chargeKey with
  | none => simp [hc] at checked
  | some issued =>
    cases hr : pairedRoute ctx.tuple ctx.env ctx.candidate ctx.matrixPairs request.consumer op.before op.after with
    | none => simp [hc,matrix,reference,hr] at checked
    | some route =>
      by_cases same : issued.payment = routePayment route
      · simp [hc,matrix,reference,hr,same] at checked
        cases checked
        exact ⟨route,rfl,same⟩
      · simp [hc,matrix,reference,hr,same] at checked

theorem temporal_borrow_bound_to_selected_head (ctx : Context) (request : Borrow)
    (ref : ReferenceUse) (charge : ChargeEntry)
    (matrix : pairAt ctx.matrixPairs request.consumer = none)
    (reference : referenceAt ctx.references request.consumer = some ref)
    (checked : authorize ctx request = some charge) :
    temporalOwner ctx.temporalEdits ref = some charge := by
  unfold authorize at checked
  cases hc : chargeAt ctx.charges request.chargeKey with
  | none => simp [hc] at checked
  | some issued =>
    by_cases same : temporalOwner ctx.temporalEdits ref = some issued
    · simp [hc,matrix,reference,same] at checked
      cases checked
      exact same
    · simp [hc,matrix,reference,same] at checked

theorem absent_consumer_rejected (ctx : Context) (request : Borrow)
    (matrix : pairAt ctx.matrixPairs request.consumer = none)
    (reference : referenceAt ctx.references request.consumer = none) :
    authorize ctx request = none := by
  unfold authorize
  cases h : chargeAt ctx.charges request.chargeKey <;> simp [matrix,reference]

end Focused225SelectedConsumers
