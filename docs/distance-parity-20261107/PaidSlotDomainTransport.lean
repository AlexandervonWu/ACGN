import SelectedSlotTransport
import PaidAlignmentExtension
import PhaseOwnedGuardPayments

/- Paid edits connect different formulas. They do not establish alpha
   equivalence, erase domain guards, or identify values of different types.
   Endpoint inventories and selected programs are inputs whose extraction from
   Java remains a separate correspondence obligation. -/
namespace PaidSlotDomainTransport
open Focused225SharedContracts Focused225Concrete PhaseOwnedJointRoutes
open SelectedSlotTransport (slotTransport slot_transport_sound)
open ACGN.FifthFive.SharedActionBoundary (DKind)

deriving instance DecidableEq for JointCandidate

/- Strengthen the retained route checker with the observed read types. -/
def typedSlotTransport (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) :=
  if before.observedType = before.binding.origin.exactType ∧
      after.observedType = after.binding.origin.exactType then
    slotTransport tuple left right p action sourceUses targetUses before after
  else none

theorem typed_transport_exact (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (route : TypedRoute)
    (h : typedSlotTransport tuple left right p action sourceUses targetUses before after =
      some route) :
    before.observedType = before.binding.origin.exactType ∧
    after.observedType = after.binding.origin.exactType ∧
    slotTransport tuple left right p action sourceUses targetUses before after = some route := by
  unfold typedSlotTransport at h
  split at h
  next types => exact ⟨types.1, types.2, h⟩
  next => cases h

theorem typed_transport_sound (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (route : TypedRoute)
    (h : typedSlotTransport tuple left right p action sourceUses targetUses before after =
      some route)
    (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead route before.binding).map (typedRead Value valuation) =
      some ⟨after.binding.origin.exactType, valuation after.binding⟩ ∧
    p.candidate.actions[action]? = some route.action ∧
    route.action.kind = DKind.update ∧ route.action.cost = 1 ∧
    route.before = some before.binding ∧ route.after = some after.binding ∧
    resolveBinding left.scopes before.phase before.binding = some before.binding ∧
    resolveBinding right.scopes after.phase after.binding = some after.binding ∧
    before ∈ sourceUses ∧ after ∈ targetUses :=
  slot_transport_sound tuple left right p action sourceUses targetUses before after route
    (typed_transport_exact tuple left right p action sourceUses targetUses before after route h).2.2
    Value valuation

theorem wrong_observed_type_rejected (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (bad : before.observedType ≠ before.binding.origin.exactType ∨
      after.observedType ≠ after.binding.origin.exactType) :
    typedSlotTransport tuple left right p action sourceUses targetUses before after = none := by
  rcases bad with bad | bad <;> simp [typedSlotTransport, bad]

/- A dependency list is ordered and refers to actual issued bindings. A pair
   of dependency ordinals may borrow only an already selected declaration
   action, not a fresh same-type guess. Owner-local selection still supplies
   complete original records; no identifier is reinterpreted as a vector index. -/
def dependencyTransport (selected : List (Nat × Nat)) (source target : List Nat) : Bool :=
  decide (source.length = target.length) &&
    (source.zip target).all (fun pair => decide (pair ∈ selected))

theorem dependency_transport_exact (selected : List (Nat × Nat)) (source target : List Nat)
    (h : dependencyTransport selected source target = true) :
    source.length = target.length ∧ ∀ pair ∈ source.zip target, pair ∈ selected := by
  simpa [dependencyTransport, List.all_eq_true] using h

theorem missing_dependency_rejected (selected : List (Nat × Nat)) (source target : List Nat)
    (pair : Nat × Nat) (read : pair ∈ source.zip target) (absent : pair ∉ selected) :
    dependencyTransport selected source target = false := by
  apply Bool.eq_false_iff.mpr
  intro accepted
  exact absent ((dependency_transport_exact selected source target accepted).2 pair read)

structure DependencyInventory where
  source : List (Binding × List Binding)
  target : List (Binding × List Binding)

def dependencyRecords (issued : List (Binding × List Binding)) (binding : Binding) :
    Option (List Binding) :=
  match issued.filter (fun entry => decide (entry.1 = binding)) with
  | [entry] => some entry.2
  | _ => none

def ownedDependency (p : OwnerProgram) (pair : Binding × Binding) : Bool :=
  p.env.authentic true pair.1.vectorIndex pair.1 &&
    p.env.authentic false pair.2.vectorIndex pair.2 &&
    decide (pair.1.origin.phase = p.sourcePhase ∧ pair.2.origin.phase = p.targetPhase ∧
      (pair.1.ordinal, pair.2.ordinal) ∈ links p.candidate.actions)

theorem owned_dependency_sound (p : OwnerProgram) (source target : Binding)
    (h : ownedDependency p (source,target) = true) :
    p.env.source[source.vectorIndex]? = some source ∧
    p.env.target[target.vectorIndex]? = some target ∧
    source.origin.phase = p.sourcePhase ∧ target.origin.phase = p.targetPhase ∧
    ∃ action ∈ p.candidate.actions,
      action.source = some source.ordinal ∧ action.target = some target.ordinal := by
  have checked : p.env.authentic true source.vectorIndex source = true ∧
      p.env.authentic false target.vectorIndex target = true ∧
      source.origin.phase = p.sourcePhase ∧ target.origin.phase = p.targetPhase ∧
      (source.ordinal,target.ordinal) ∈ links p.candidate.actions := by
    simpa [ownedDependency, and_assoc] using h
  exact ⟨(authentic_binding p.env true _ source checked.1).1,
    (authentic_binding p.env false _ target checked.2.1).1,
    checked.2.2.1, checked.2.2.2.1,
    zero_has_selected_declaration p.candidate.actions _ _ (by simp [matrixCharge, checked.2.2.2.2])⟩

def authenticatedDependencies (p : OwnerProgram) (issued : DependencyInventory)
    (before after : Binding) : Bool :=
  match dependencyRecords issued.source before, dependencyRecords issued.target after with
  | some xs, some ys =>
    decide (xs.map (fun b => b.ordinal) = before.origin.dependencies ∧
      ys.map (fun b => b.ordinal) = after.origin.dependencies ∧ xs.length = ys.length) &&
      (xs.zip ys).all (ownedDependency p)
  | _, _ => false

theorem authenticated_dependencies_exact (p : OwnerProgram) (issued : DependencyInventory)
    (before after : Binding) (h : authenticatedDependencies p issued before after = true) :
    ∃ xs ys, dependencyRecords issued.source before = some xs ∧
      dependencyRecords issued.target after = some ys ∧
      xs.map (fun b => b.ordinal) = before.origin.dependencies ∧
      ys.map (fun b => b.ordinal) = after.origin.dependencies ∧ xs.length = ys.length ∧
      ∀ pair ∈ xs.zip ys, ownedDependency p pair = true := by
  unfold authenticatedDependencies at h
  cases hx : dependencyRecords issued.source before with
  | none => simp [hx] at h
  | some xs =>
    cases hy : dependencyRecords issued.target after with
    | none => simp [hx,hy] at h
    | some ys =>
      have facts : (xs.map (fun b => b.ordinal) = before.origin.dependencies ∧
          ys.map (fun b => b.ordinal) = after.origin.dependencies ∧ xs.length = ys.length) ∧
          ∀ pair ∈ xs.zip ys, ownedDependency p pair = true := by
        simpa [hx,hy,List.all_eq_true] using h
      exact ⟨xs,ys,rfl,rfl,facts.1.1,facts.1.2.1,facts.1.2.2,facts.2⟩

theorem foreign_dependency_owner_rejected (p : OwnerProgram) (source target : Binding)
    (foreign : source.origin.phase ≠ p.sourcePhase) :
    ownedDependency p (source,target) = false := by
  simp [ownedDependency, foreign]

/- The issued inventory carries the actual dependency Binding records. Their
   full identity, owner phase and selected action are checked; a coincident
   ordinal from another owner cannot borrow this phase's payment. -/
def dependentSlotTransport (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (issued : DependencyInventory)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) :=
  if authenticatedDependencies p issued before.binding after.binding then
    typedSlotTransport tuple left right p action sourceUses targetUses before after
  else none

theorem dependent_transport_exact (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (issued : DependencyInventory)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (route : TypedRoute)
    (h : dependentSlotTransport tuple left right p issued action sourceUses targetUses before after =
      some route) :
    typedSlotTransport tuple left right p action sourceUses targetUses before after = some route ∧
    authenticatedDependencies p issued before.binding after.binding = true := by
  unfold dependentSlotTransport at h
  split at h
  next checked => exact ⟨h,checked⟩
  next => cases h

open Focused225SelectedConsumers (MatrixPair OperationKey pairAt)

/- Being present in the two endpoint inventories is not enough: the actual
   selected matrix operation must pair THESE two occurrences. -/
def selectedSlotPair (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (issued : DependencyInventory)
    (pairs : List MatrixPair) (key : OperationKey)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) : Option TypedRoute := do
  let op ← pairAt pairs key
  if op.before = before ∧ op.after = after ∧ op.kind = "metric-align" ∧ op.cost = 0 then
    dependentSlotTransport tuple left right p issued op.declarationIndex sourceUses targetUses before after
  else none

theorem selected_slot_pair_exact (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (issued : DependencyInventory)
    (pairs : List MatrixPair) (key : OperationKey)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) (route : TypedRoute)
    (h : selectedSlotPair tuple left right p issued pairs key sourceUses targetUses before after = some route) :
    ∃ op, pairAt pairs key = some op ∧ op.before = before ∧ op.after = after ∧
      op.kind = "metric-align" ∧ op.cost = 0 ∧
      dependentSlotTransport tuple left right p issued op.declarationIndex sourceUses targetUses before after = some route := by
  unfold selectedSlotPair at h
  cases found : pairAt pairs key with
  | none => simp [found] at h
  | some op =>
    simp only [found] at h
    dsimp only [Bind.bind, Option.bind] at h
    split at h
    next checks => exact ⟨op, rfl, checks.1, checks.2.1, checks.2.2.1, checks.2.2.2, h⟩
    next => cases h

theorem cross_paired_read_rejected (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (issued : DependencyInventory)
    (pairs : List MatrixPair) (key : OperationKey) (op : MatrixPair)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (found : pairAt pairs key = some op) (wrong : op.after ≠ after) :
    selectedSlotPair tuple left right p issued pairs key sourceUses targetUses before after = none := by
  simp [selectedSlotPair, found, wrong]

theorem same_quantifier_changed_tuple_is_paid (quantifier : String)
    (sourceFields targetFields : List String) (different : sourceFields ≠ targetFields) :
    (onePaid (quantifier :: sourceFields) (quantifier :: targetFields)).accepts = true ∧
    (onePaid (quantifier :: sourceFields) (quantifier :: targetFields)).total = 1 :=
  paid_transport_not_free _ _ (by simpa using different)

/- Quantification over a dependent domain at one fixed time/environment is
   equivalent to retaining its membership test in the matrix. No temporal
   operator or quantifier is commuted. The carrier may itself be a tuple or
   relation; no nonemptiness or singleton assumption is used. -/
theorem all_guard_lowering (domain : E → A → Prop) (body : E → A → Prop) (env : E) :
    (∀ x, domain env x → body env x) ↔
      (∀ x, ¬ domain env x ∨ body env x) := by
  classical
  constructor
  · intro h x
    by_cases hx : domain env x
    · exact Or.inr (h x hx)
    · exact Or.inl hx
  · intro h x hx
    rcases h x with no | yes
    · exact False.elim (no hx)
    · exact yes

theorem exists_guard_lowering (domain : E → A → Prop) (body : E → A → Prop) (env : E) :
    (∃ x, domain env x ∧ body env x) ↔
      (∃ x : {x // domain env x}, body env x.val) := by
  constructor
  · rintro ⟨x, hx, hb⟩
    exact ⟨⟨x,hx⟩,hb⟩
  · rintro ⟨⟨x,hx⟩,hb⟩
    exact ⟨x,hx,hb⟩

theorem no_guard_lowering (domain : E → A → Prop) (body : E → A → Prop) (env : E) :
    (¬ ∃ x, domain env x ∧ body env x) ↔
      (∀ x, domain env x → ¬ body env x) := by
  constructor
  · intro h x hx hb
    exact h ⟨x,hx,hb⟩
  · rintro h ⟨x,hx,hb⟩
    exact h x hx hb

def atMostOne (p : A → Prop) : Prop := ∀ x y, p x → p y → x = y
def exactlyOne (p : A → Prop) : Prop := ∃ x, p x ∧ ∀ y, p y → y = x

theorem lone_guard_lowering (domain : E → A → Prop) (body : E → A → Prop) (env : E) :
    atMostOne (fun x => domain env x ∧ body env x) ↔
      atMostOne (fun x : {x // domain env x} => body env x.val) := by
  constructor
  · intro h x y hx hy
    apply Subtype.ext
    exact h x.val y.val ⟨x.property,hx⟩ ⟨y.property,hy⟩
  · intro h x y hx hy
    exact congrArg Subtype.val (h ⟨x,hx.1⟩ ⟨y,hy.1⟩ hx.2 hy.2)

theorem one_guard_lowering (domain : E → A → Prop) (body : E → A → Prop) (env : E) :
    exactlyOne (fun x => domain env x ∧ body env x) ↔
      exactlyOne (fun x : {x // domain env x} => body env x.val) := by
  constructor
  · rintro ⟨x,hx,unique⟩
    refine ⟨⟨x,hx.1⟩, hx.2, ?_⟩
    intro y hy
    apply Subtype.ext
    exact unique y.val ⟨y.property,hy⟩
  · rintro ⟨x,hx,unique⟩
    refine ⟨x.val, ⟨x.property,hx⟩, ?_⟩
    intro y hy
    exact congrArg Subtype.val (unique ⟨y,hy.1⟩ hy.2)

theorem phase_local_guard_lowering (domain : Time → E → A → Prop)
    (body : Time → E → A → Prop) (time : Time) (env : E) :
    (∀ x, domain time env x → body time env x) ↔
      (∀ x, ¬ domain time env x ∨ body time env x) :=
  all_guard_lowering (domain time) (body time) env

/- Guard records carry the original binding, including the ordered dependency
   list, exact domain and type. They are not just a domain name or cost scalar. -/
structure GuardToken where
  binding : Binding
  usePhase : Nat
  occurrence : String
  deriving DecidableEq

inductive Payload where
  | guard (token : GuardToken)
  | read (use : MatrixUse)
  deriving DecidableEq

def Payload.binding : Payload → Binding
  | .guard token => token.binding
  | .read use => use.binding

def guardIssued (scopes : List Scope) (issued : List GuardToken) (token : GuardToken) : Bool :=
  decide (token ∈ issued ∧ resolveBinding scopes token.usePhase token.binding = some token.binding)

theorem issued_guard_original (scopes : List Scope) (issued : List GuardToken)
    (token : GuardToken) (h : guardIssued scopes issued token = true) :
    token ∈ issued ∧ resolveBinding scopes token.usePhase token.binding = some token.binding := by
  simpa [guardIssued] using h

theorem owned_lowered_clause_sound (scopes : List Scope) (issued guards : List GuardToken)
    (body actual : List (PhaseOwnedGuardPayments.Literal GuardToken))
    (meaning : GuardToken → Prop)
    (owners : guards.all (guardIssued scopes issued) = true)
    (lowered : PhaseOwnedGuardPayments.clauseCheck guards body actual = true) :
    (∀ token ∈ guards, token ∈ issued ∧
      resolveBinding scopes token.usePhase token.binding = some token.binding) ∧
    (((∀ guard ∈ guards, meaning guard) → PhaseOwnedGuardPayments.clauseEval meaning body) ↔
      PhaseOwnedGuardPayments.clauseEval meaning actual) := by
  exact ⟨fun token member => issued_guard_original scopes issued token
    (List.all_eq_true.mp owners token member),
    PhaseOwnedGuardPayments.checked_clause_preserves_guard meaning guards body actual lowered⟩

/- This executable check ties both guard occurrences to the complete selected
   matrix and temporal program. Route checks for other matrix operations remain
   explicit parameters of ExecutableJoint.check, not conclusions of this lemma. -/
def guardedJointCheck (tuple : Binding → List String) (env : Environment)
    (selected : SelectedPrograms n Payload)
    (routes : List (Native.NativeAction (List String)) → Trace.Operation (Fin n) Payload → Bool)
    (phases : Trace.Operation (Fin n) Payload → Bool)
    (joint : ExecutableJoint n (List String) Payload)
    (left right : List Scope) (sourceGuards targetGuards : List GuardToken)
    (sourceAddress targetAddress : Fin n) (before after : GuardToken) : Bool :=
  joint.check tuple env selected routes phases &&
    guardIssued left sourceGuards before && guardIssued right targetGuards after &&
    decide (joint.source sourceAddress = some (.guard before) ∧ joint.target targetAddress = some (.guard after))

theorem guarded_joint_exact (tuple : Binding → List String) (env : Environment)
    (selected : SelectedPrograms n Payload)
    (routes : List (Native.NativeAction (List String)) → Trace.Operation (Fin n) Payload → Bool)
    (phases : Trace.Operation (Fin n) Payload → Bool)
    (joint : ExecutableJoint n (List String) Payload)
    (left right : List Scope) (sourceGuards targetGuards : List GuardToken)
    (sourceAddress targetAddress : Fin n) (before after : GuardToken)
    (h : guardedJointCheck tuple env selected routes phases joint left right
      sourceGuards targetGuards sourceAddress targetAddress before after = true) :
    joint.check tuple env selected routes phases = true ∧
    guardIssued left sourceGuards before = true ∧ guardIssued right targetGuards after = true ∧
    joint.source sourceAddress = some (.guard before) ∧ joint.target targetAddress = some (.guard after) := by
  simpa [guardedJointCheck, and_assoc] using h

theorem differing_domains_remain_in_replay (tuple : Binding → List String) (env : Environment)
    (selected : SelectedPrograms n Payload)
    (routes : List (Native.NativeAction (List String)) → Trace.Operation (Fin n) Payload → Bool)
    (phases : Trace.Operation (Fin n) Payload → Bool)
    (joint : ExecutableJoint n (List String) Payload)
    (left right : List Scope) (sourceGuards targetGuards : List GuardToken)
    (sourceAddress targetAddress : Fin n) (before after : GuardToken)
    (h : guardedJointCheck tuple env selected routes phases joint left right
      sourceGuards targetGuards sourceAddress targetAddress before after = true) :
    Trace.run joint.source (selected.matrix ++ selected.temporal) = some joint.target ∧
    (joint.source sourceAddress).map (fun t => t.binding.origin.domain) =
      some before.binding.origin.domain ∧
    (joint.target targetAddress).map (fun t => t.binding.origin.domain) =
      some after.binding.origin.domain ∧
    joint.total = Native.programCost selected.declarations +
      Trace.cost (selected.matrix ++ selected.temporal) := by
  have checked := guarded_joint_exact tuple env selected routes phases joint left right
    sourceGuards targetGuards sourceAddress targetAddress before after h
  have replay := complete_joint_replay tuple env selected routes phases joint checked.1
  rcases replay with ⟨_, decl, matrix, temporal, _, _, ran, paid⟩
  rw [matrix, temporal] at ran paid
  rw [decl] at paid
  exact ⟨ran, by rw [checked.2.2.2.1]; rfl, by rw [checked.2.2.2.2]; rfl, paid⟩

theorem removed_source_guard_rejected (tuple : Binding → List String) (env : Environment)
    (selected : SelectedPrograms n Payload)
    (routes : List (Native.NativeAction (List String)) → Trace.Operation (Fin n) Payload → Bool)
    (phases : Trace.Operation (Fin n) Payload → Bool)
    (joint : ExecutableJoint n (List String) Payload)
    (left right : List Scope) (sourceGuards targetGuards : List GuardToken)
    (sourceAddress targetAddress : Fin n) (before after : GuardToken)
    (absent : joint.source sourceAddress ≠ some (.guard before)) :
    guardedJointCheck tuple env selected routes phases joint left right
      sourceGuards targetGuards sourceAddress targetAddress before after = false := by
  simp [guardedJointCheck, absent]

/- Reusable independent facts. The stronger composition below also connects
   the exact selected read pair to the replayed matrix operation. -/
theorem independent_route_and_guard_facts (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (route : TypedRoute) (selected : SelectedPrograms n Payload)
    (routes : List (Native.NativeAction (List String)) → Trace.Operation (Fin n) Payload → Bool)
    (phases : Trace.Operation (Fin n) Payload → Bool)
    (joint : ExecutableJoint n (List String) Payload)
    (sourceGuards targetGuards : List GuardToken) (sourceAddress targetAddress : Fin n)
    (sourceGuard targetGuard : GuardToken)
    (routeChecked : typedSlotTransport tuple left right p action sourceUses targetUses
      before after = some route)
    (guardChecked : guardedJointCheck tuple p.env selected routes phases joint left.scopes
      right.scopes sourceGuards targetGuards sourceAddress targetAddress sourceGuard targetGuard = true)
    (sameProgram : joint.declaration = p.candidate)
    (sameSource : sourceGuard.binding = before.binding)
    (sameTarget : targetGuard.binding = after.binding)
    (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    joint.declaration.actions[action]? = some route.action ∧
    route.action.kind = DKind.update ∧ route.action.cost = 1 ∧
    (routeRead route before.binding).map (typedRead Value valuation) =
      some ⟨after.binding.origin.exactType, valuation after.binding⟩ ∧
    Trace.run joint.source (selected.matrix ++ selected.temporal) = some joint.target ∧
    (joint.source sourceAddress).map (fun t => t.binding.origin.domain) =
      some before.binding.origin.domain ∧
    (joint.target targetAddress).map (fun t => t.binding.origin.domain) =
      some after.binding.origin.domain ∧
    joint.total = Native.programCost selected.declarations +
      Trace.cost (selected.matrix ++ selected.temporal) := by
  have routeSound := typed_transport_sound tuple left right p action sourceUses targetUses
    before after route routeChecked Value valuation
  have guardSound := differing_domains_remain_in_replay tuple p.env selected routes phases
    joint left.scopes right.scopes sourceGuards targetGuards sourceAddress targetAddress
    sourceGuard targetGuard guardChecked
  rw [sameSource, sameTarget] at guardSound
  exact ⟨by rw [sameProgram]; exact routeSound.2.1,
    routeSound.2.2.1, routeSound.2.2.2.1, routeSound.1, guardSound⟩

def readOperation (address : Fin n) (before after : MatrixUse) :
    Trace.Operation (Fin n) Payload :=
  ⟨address, some (.read before), some (.read after), 0⟩

/- Keys are the source-issued keys of this selected matrix, in the same order.
   Both key lookup and the entire typed operation must agree at the same index. -/
def readInReplay (selected : SelectedPrograms n Payload) (keys : List OperationKey)
    (index : Nat) (address : Fin n) (op : MatrixPair) : Bool :=
  decide (keys.length = selected.matrix.length ∧ keys.Nodup ∧
    keys[index]? = some op.key ∧
    selected.matrix[index]? = some (readOperation address op.before op.after))

def selectedRepairCheck (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (issued : DependencyInventory) (pairs : List MatrixPair) (op : MatrixPair)
    (sourceUses targetUses : List MatrixUse) (route : TypedRoute)
    (selected : SelectedPrograms n Payload) (keys : List OperationKey)
    (index : Nat) (readAddress : Fin n)
    (routes : List (Native.NativeAction (List String)) → Trace.Operation (Fin n) Payload → Bool)
    (phases : Trace.Operation (Fin n) Payload → Bool)
    (joint : ExecutableJoint n (List String) Payload)
    (sourceGuards targetGuards : List GuardToken) (sourceAddress targetAddress : Fin n)
    (sourceGuard targetGuard : GuardToken) : Bool :=
  guardedJointCheck tuple p.env selected routes phases joint left.scopes right.scopes
    sourceGuards targetGuards sourceAddress targetAddress sourceGuard targetGuard &&
  decide (selectedSlotPair tuple left right p issued pairs op.key sourceUses targetUses
    op.before op.after = some route) && readInReplay selected keys index readAddress op &&
  decide (pairAt pairs op.key = some op ∧ joint.declaration = p.candidate ∧
    sourceGuard.binding = op.before.binding ∧ targetGuard.binding = op.after.binding)

theorem selected_repair_sound (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (issued : DependencyInventory) (pairs : List MatrixPair) (op : MatrixPair)
    (sourceUses targetUses : List MatrixUse) (route : TypedRoute)
    (selected : SelectedPrograms n Payload) (keys : List OperationKey)
    (index : Nat) (readAddress : Fin n)
    (routes : List (Native.NativeAction (List String)) → Trace.Operation (Fin n) Payload → Bool)
    (phases : Trace.Operation (Fin n) Payload → Bool)
    (joint : ExecutableJoint n (List String) Payload)
    (sourceGuards targetGuards : List GuardToken) (sourceAddress targetAddress : Fin n)
    (sourceGuard targetGuard : GuardToken)
    (h : selectedRepairCheck tuple left right p issued pairs op sourceUses targetUses route
      selected keys index readAddress routes phases joint sourceGuards targetGuards
      sourceAddress targetAddress sourceGuard targetGuard = true)
    (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    authenticatedDependencies p issued op.before.binding op.after.binding = true ∧
    keys[index]? = some op.key ∧
    selected.matrix[index]? = some (readOperation readAddress op.before op.after) ∧
    joint.declaration.actions[op.declarationIndex]? = some route.action ∧
    route.action.kind = DKind.update ∧ route.action.cost = 1 ∧
    (routeRead route op.before.binding).map (typedRead Value valuation) =
      some ⟨op.after.binding.origin.exactType, valuation op.after.binding⟩ ∧
    Trace.run joint.source (selected.matrix ++ selected.temporal) = some joint.target ∧
    (joint.source sourceAddress).map (fun t => t.binding.origin.domain) =
      some op.before.binding.origin.domain ∧
    (joint.target targetAddress).map (fun t => t.binding.origin.domain) =
      some op.after.binding.origin.domain ∧
    joint.total = Native.programCost selected.declarations +
      Trace.cost (selected.matrix ++ selected.temporal) := by
  have checks :
      guardedJointCheck tuple p.env selected routes phases joint left.scopes right.scopes
        sourceGuards targetGuards sourceAddress targetAddress sourceGuard targetGuard = true ∧
      selectedSlotPair tuple left right p issued pairs op.key sourceUses targetUses op.before op.after = some route ∧
      readInReplay selected keys index readAddress op = true ∧
      pairAt pairs op.key = some op ∧ joint.declaration = p.candidate ∧
      sourceGuard.binding = op.before.binding ∧ targetGuard.binding = op.after.binding := by
    simpa [selectedRepairCheck, and_assoc] using h
  obtain ⟨actual, found, _, _, _, _, dependent⟩ := selected_slot_pair_exact tuple left right p
    issued pairs op.key sourceUses targetUses op.before op.after route checks.2.1
  have same : actual = op := Option.some.inj (found.symm.trans checks.2.2.2.1)
  subst actual
  have deps := dependent_transport_exact tuple left right p issued op.declarationIndex
    sourceUses targetUses op.before op.after route dependent
  have readFacts : keys.length = selected.matrix.length ∧ keys.Nodup ∧
      keys[index]? = some op.key ∧
      selected.matrix[index]? = some (readOperation readAddress op.before op.after) := by
    simpa [readInReplay] using checks.2.2.1
  have joined := independent_route_and_guard_facts tuple left right p op.declarationIndex
    sourceUses targetUses op.before op.after route selected routes phases joint sourceGuards
    targetGuards sourceAddress targetAddress sourceGuard targetGuard deps.1 checks.1
    checks.2.2.2.2.1 checks.2.2.2.2.2.1 checks.2.2.2.2.2.2 Value valuation
  exact ⟨deps.2,readFacts.2.2.1,readFacts.2.2.2,joined⟩

theorem unselected_read_rejected (selected : SelectedPrograms n Payload) (keys : List OperationKey)
    (index : Nat) (address : Fin n) (op : MatrixPair)
    (different : selected.matrix[index]? ≠ some (readOperation address op.before op.after)) :
    readInReplay selected keys index address op = false := by
  simp [readInReplay,different]

/- These countermodels prevent interpreting the paid edit theorems as free
   equivalence of different domains, types, multiplicities or temporal phases. -/
theorem deleting_domain_guard_changes_truth :
    (∀ _x : Unit, False → False) ∧ ¬ (∀ _x : Unit, False) := by
  exact ⟨fun _ h => h, fun h => h ()⟩

theorem changing_cardinality_is_not_alpha :
    (∃ _x : Bool, True) ∧ ¬ exactlyOne (fun _x : Bool => True) := by
  refine ⟨⟨false, trivial⟩, ?_⟩
  rintro ⟨x, _, unique⟩
  have equal := (unique false trivial).trans (unique true trivial).symm
  cases equal

theorem moving_binder_across_phase_changes_truth :
    (∀ t : Bool, ∃ x : Bool, x = t) ∧ ¬ (∃ x : Bool, ∀ t : Bool, x = t) := by
  refine ⟨fun t => ⟨t,rfl⟩, ?_⟩
  rintro ⟨x,h⟩
  have equal := (h false).symm.trans (h true)
  cases equal

end PaidSlotDomainTransport
