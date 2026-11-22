import Focused225Observed

/- Concrete checkers within the shared environment. Parser-issued registries
   and selected native programs are inputs; no arbitrary semantic-check Bool
   is used as the conclusion of these route, CALL or payment theorems. -/
namespace Focused225Concrete
open Focused225SharedContracts

inductive Component where
  | declaration | matrix | temporal
  deriving DecidableEq, Repr

/- Logical identities do not include the charging component. A projection
   cannot disguise a second charge by changing declaration/matrix/temporal. -/
structure EffectId where
  sourceHash : String
  targetHash : String := ""
  predicatePair : String
  sourceOccurrence : String
  targetOccurrence : String
  before : String
  after : String
  sourceBinding : Option Binding := none
  targetBinding : Option Binding := none
  sourceTuple : Option (List String) := none
  targetTuple : Option (List String) := none
  deriving DecidableEq

structure Payment where
  effect : EffectId
  owner : Component
  amount : Nat
  deriving DecidableEq

def paymentCheck (selected claimed : List Payment) : Bool :=
  decide ((selected.map Payment.effect).Nodup ∧ claimed.Perm selected)

theorem payment_exact (selected claimed : List Payment)
    (checked : paymentCheck selected claimed = true) :
    (claimed.map Payment.effect).Nodup ∧ claimed.Perm selected ∧
      (claimed.map Payment.amount).sum = (selected.map Payment.amount).sum := by
  have h : (selected.map Payment.effect).Nodup ∧ claimed.Perm selected := of_decide_eq_true checked
  exact ⟨(h.2.map Payment.effect).nodup_iff.mpr h.1, h.2, (h.2.map Payment.amount).sum_nat⟩

theorem unique_effect (payments : List Payment) (unique : (payments.map Payment.effect).Nodup)
    (a b : Payment) (ha : a ∈ payments) (hb : b ∈ payments)
    (same : a.effect = b.effect) : a = b := by
  induction payments with
  | nil => simp at ha
  | cons p ps ih =>
    simp only [List.map_cons, List.nodup_cons] at unique
    simp only [List.mem_cons] at ha hb
    rcases ha with rfl | ha
    · rcases hb with rfl | hb
      · rfl
      · exact False.elim (unique.1 (same.symm ▸ List.mem_map_of_mem hb))
    · rcases hb with rfl | hb
      · exact False.elim (unique.1 (same ▸ List.mem_map_of_mem ha))
      · exact ih unique.2 ha hb

theorem paid_once (selected claimed : List Payment)
    (checked : paymentCheck selected claimed = true)
    (a b : Payment) (ha : a ∈ claimed) (hb : b ∈ claimed)
    (same : a.effect = b.effect) : a = b := by
  exact unique_effect claimed (payment_exact selected claimed checked).1 a b ha hb same

theorem cross_component_duplicate_rejected (selected claimed : List Payment)
    (a b : Payment) (ha : a ∈ claimed) (hb : b ∈ claimed)
    (same : a.effect = b.effect) (other : a.owner ≠ b.owner) :
    paymentCheck selected claimed = false := by
  apply Bool.eq_false_iff.mpr
  intro h
  exact other (congrArg Payment.owner (paid_once selected claimed h a b ha hb same))

theorem missing_payment_rejected (selected claimed : List Payment)
    (p : Payment) (selectedHere : p ∈ selected) (missing : p ∉ claimed) :
    paymentCheck selected claimed = false := by
  apply Bool.eq_false_iff.mpr
  intro h
  exact missing ((payment_exact selected claimed h).2.1.mem_iff.mpr selectedHere)

def owned (component : Component) (payments : List Payment) : Nat :=
  (payments.filter (fun p => p.owner == component)).map Payment.amount |>.sum

theorem component_partition (payments : List Payment) :
    owned .declaration payments + owned .matrix payments + owned .temporal payments =
      (payments.map Payment.amount).sum := by
  induction payments with
  | nil => rfl
  | cons p ps ih =>
    cases owner : p.owner <;> simp [owned, owner] at * <;> omega

/- Exact owned binding lookup, not coordinate/type-name equality. -/
def bindingAt (bindings : List Binding) (ordinal : Option Nat) : Option (Option Binding) :=
  match ordinal with
  | none => some none
  | some index =>
    match bindings.filter (fun b => b.ordinal == index) with
    | [b] => some (some b)
    | _ => none

structure TypedRoute where
  action : Native.NativeAction (List String)
  before : Option Binding
  after : Option Binding
  deriving DecidableEq

def selectedRoute (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (index : Nat)
    (before after : Option Binding) : Option TypedRoute := do
  if !boundCandidate tuple env candidate then none else
    let action ← candidate.actions[index]?
    let actualBefore ← bindingAt env.source action.source
    let actualAfter ← bindingAt env.target action.target
    if actualBefore = before ∧ actualAfter = after then
      some ⟨action, actualBefore, actualAfter⟩
    else none

theorem selected_route_exact (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (index : Nat)
    (before after : Option Binding) (route : TypedRoute)
    (checked : selectedRoute tuple env candidate index before after = some route) :
    boundCandidate tuple env candidate = true ∧
    candidate.actions[index]? = some route.action ∧
    bindingAt env.source route.action.source = some route.before ∧
    bindingAt env.target route.action.target = some route.after ∧
    route.before = before ∧ route.after = after := by
  unfold selectedRoute at checked
  split at checked
  next bad => simp at checked
  next good =>
    have bound : boundCandidate tuple env candidate = true := by simpa using good
    cases act : candidate.actions[index]? with
    | none => simp [act] at checked
    | some action =>
      cases left : bindingAt env.source action.source with
      | none => simp [act, left] at checked
      | some actualBefore =>
        cases right : bindingAt env.target action.target with
        | none => simp [act, left, right] at checked
        | some actualAfter =>
          by_cases eq : actualBefore = before ∧ actualAfter = after
          · simp [act, left, right, eq] at checked
            cases checked
            exact ⟨bound,rfl,by simpa [eq.1] using left,by simpa [eq.2] using right,rfl,rfl⟩
          · simp [act, left, right, eq] at checked

theorem binding_lookup_issued (bindings : List Binding) (index : Nat) (b : Binding)
    (checked : bindingAt bindings (some index) = some (some b)) :
    b ∈ bindings ∧ b.ordinal = index := by
  cases h : bindings.filter (fun b => b.ordinal == index) with
  | nil => simp [bindingAt,h] at checked
  | cons x rest =>
    cases rest with
    | cons y ys => simp [bindingAt,h] at checked
    | nil =>
      have eq : x = b := by simpa [bindingAt,h] using checked
      subst x
      have member : b ∈ bindings.filter (fun b => b.ordinal == index) := by rw [h]; simp
      simpa using List.mem_filter.mp member

/- A paid route replaces a binding in the edited context. It does not cast a
   source value between distinct carrier types or assert formula equivalence. -/
def routeRead (route : TypedRoute) (read : Binding) : Option Binding :=
  if route.before = some read then route.after else some read

theorem routed_read_is_exact_target (route : TypedRoute) (source target : Binding)
    (before : route.before = some source) (after : route.after = some target) :
    routeRead route source = some target := by simp [routeRead, before, after]

theorem unrelated_owner_read_unchanged (route : TypedRoute) (source other : Binding)
    (before : route.before = some source) (different : source.origin.owner ≠ other.origin.owner) :
    routeRead route other = some other := by
  have ne : source ≠ other := fun h => different (congrArg (fun b => b.origin.owner) h)
  simp [routeRead, before, ne]

def typedRead (Value : String → Type) (env : (b : Binding) → Value b.origin.exactType)
    (binding : Binding) : Sigma Value := ⟨binding.origin.exactType, env binding⟩

theorem typed_paid_read (Value : String → Type)
    (env : (b : Binding) → Value b.origin.exactType)
    (route : TypedRoute) (source target : Binding)
    (before : route.before = some source) (after : route.after = some target) :
    (routeRead route source).map (typedRead Value env) =
      some ⟨target.origin.exactType, env target⟩ := by
  rw [routed_read_is_exact_target route source target before after]
  rfl

theorem deleted_binding_has_no_orphan (route : TypedRoute) (source : Binding)
    (before : route.before = some source) (after : route.after = none) :
    routeRead route source = none := by simp [routeRead, before, after]

/- A source CALL registry holds complete typed, ordered expression payloads.
   Source anchors are parser-issued identities scoped by the source hash;
   normalized tree paths are presentation, not substitutes for those identities. -/
structure CallArgument where
  exactType : String
  sourceTree : String
  lineage : Nat
  deriving DecidableEq, Repr

structure CallRecord where
  sourceHash : String
  predicate : String
  anchor : Nat
  parserOccurrence : Nat
  lineage : Nat
  owner : String
  phase : Nat
  sourceBranch : List Nat
  semanticProfile : String
  callee : String
  sourceName : String
  kind : String
  authority : String
  resultType : String
  declaredArity : Nat
  arguments : List CallArgument
  nodeTree : String
  scopeBindings : String
  deriving DecidableEq, Repr

def resolveCall (issued : List CallRecord) (claimed : CallRecord) : Option CallRecord :=
  match issued.filter (fun c => c.sourceHash == claimed.sourceHash && c.anchor == claimed.anchor) with
  | [original] =>
    if original = claimed ∧ original.declaredArity = original.arguments.length then some original else none
  | _ => none

theorem resolved_call_issued (issued : List CallRecord) (claimed actual : CallRecord)
    (checked : resolveCall issued claimed = some actual) :
    actual ∈ issued ∧ actual = claimed ∧ actual.declaredArity = actual.arguments.length := by
  cases h : issued.filter (fun c => c.sourceHash == claimed.sourceHash && c.anchor == claimed.anchor) with
  | nil => simp [resolveCall,h] at checked
  | cons original rest =>
    cases rest with
    | cons x xs => simp [resolveCall,h] at checked
    | nil =>
      simp only [resolveCall,h] at checked
      split at checked
      next good =>
        have eq : original = actual := Option.some.inj checked
        subst original
        have member : actual ∈ issued.filter
            (fun c => c.sourceHash == claimed.sourceHash && c.anchor == claimed.anchor) := by rw [h]; simp
        exact ⟨(List.mem_filter.mp member).1,good.1,good.2⟩
      next => cases checked

def callValue (Value : String → Type)
    (interpret : (call : CallRecord) → Value call.resultType) (call : CallRecord) : Sigma Value :=
  ⟨call.resultType, interpret call⟩

theorem source_call_resolves (original : CallRecord)
    (arity : original.declaredArity = original.arguments.length) :
    resolveCall [original] original = some original := by
  simp [resolveCall,arity]

theorem duplicate_call_anchor_rejected (original : CallRecord) :
    resolveCall [original,original] original = none := by simp [resolveCall]

theorem resolved_call_evaluation (Value : String → Type)
    (interpret : (call : CallRecord) → Value call.resultType)
    (issued : List CallRecord) (claimed actual : CallRecord)
    (checked : resolveCall issued claimed = some actual) :
    (resolveCall issued claimed).map (callValue Value interpret) = some (callValue Value interpret actual) := by
  rw [checked]; rfl

theorem source_call_typed_sound (Value : String → Type)
    (interpret : (call : CallRecord) → Value call.resultType)
    (issued : List CallRecord) (claimed actual : CallRecord)
    (checked : resolveCall issued claimed = some actual) :
    callValue Value interpret claimed = callValue Value interpret actual ∧
    claimed.resultType = actual.resultType ∧ claimed.arguments = actual.arguments ∧
    claimed.owner = actual.owner ∧ claimed.phase = actual.phase ∧
    claimed.sourceBranch = actual.sourceBranch := by
  have same := (resolved_call_issued issued claimed actual checked).2.1
  cases same
  exact ⟨rfl,rfl,rfl,rfl,rfl,rfl⟩

theorem forged_call_rejected (issued : List CallRecord) (claimed : CallRecord)
    (foreign : claimed ∉ issued) : resolveCall issued claimed = none := by
  cases h : resolveCall issued claimed with
  | none => rfl
  | some actual =>
    obtain ⟨member,same,_⟩ := resolved_call_issued issued claimed actual h
    exact False.elim (foreign (same ▸ member))

theorem singleton_field_mismatch (original claimed : CallRecord) (field : CallRecord → α)
    (different : field claimed ≠ field original) : resolveCall [original] claimed = none := by
  apply forged_call_rejected
  intro h
  have eq : claimed = original := List.mem_singleton.mp h
  exact different (congrArg field eq)

theorem appended_payload_differs (s : String) : s ++ "!" ≠ s := by
  intro h
  have sizes := congrArg String.length h
  rw [String.length_append] at sizes
  have one : "!".length = 1 := rfl
  omega

structure MatrixUse where
  binding : Binding
  phase : Nat
  typedRole : String
  phasePath : String
  nodePath : String
  observedType : String
  payload : String
  deriving DecidableEq

def selectedMatrixUse (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (actionIndex : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) : Option MatrixUse := do
  let _ ← selectedRoute tuple env candidate actionIndex (some before.binding) (some after.binding)
  if before ∈ sourceUses ∧ after ∈ targetUses then some after else none

theorem selected_matrix_use_exact (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (actionIndex : Nat)
    (sourceUses targetUses : List MatrixUse) (before after actual : MatrixUse)
    (checked : selectedMatrixUse tuple env candidate actionIndex sourceUses targetUses before after = some actual) :
    before ∈ sourceUses ∧ after ∈ targetUses ∧ actual = after ∧
    ∃ route, selectedRoute tuple env candidate actionIndex (some before.binding) (some after.binding) = some route := by
  unfold selectedMatrixUse at checked
  cases hr : selectedRoute tuple env candidate actionIndex (some before.binding) (some after.binding) with
  | none => simp [hr] at checked
  | some route =>
    simp only [hr] at checked
    split at checked
    next member => exact ⟨member.1,member.2,(Option.some.inj checked).symm,route,rfl⟩
    next => cases checked

theorem source_matrix_use_accepts (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (actionIndex : Nat) (before after : MatrixUse)
    (route : TypedRoute)
    (selected : selectedRoute tuple env candidate actionIndex (some before.binding) (some after.binding) = some route) :
    selectedMatrixUse tuple env candidate actionIndex [before] [after] before after = some after := by
  simp [selectedMatrixUse, selected]

theorem foreign_matrix_use_rejected (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (actionIndex : Nat) (original claimed after : MatrixUse)
    (field : MatrixUse → α) (different : field claimed ≠ field original) :
    selectedMatrixUse tuple env candidate actionIndex [original] [after] claimed after = none := by
  cases h : selectedMatrixUse tuple env candidate actionIndex [original] [after] claimed after with
  | none => rfl
  | some actual =>
    have member := (selected_matrix_use_exact tuple env candidate actionIndex [original] [after] claimed after actual h).1
    have eq : claimed = original := List.mem_singleton.mp member
    exact False.elim (different (congrArg field eq))

def matrixValue (Value : String → Type)
    (valuation : (use : MatrixUse) → Value use.observedType) (use : MatrixUse) : Sigma Value :=
  ⟨use.observedType,valuation use⟩

theorem selected_matrix_typed_value (tuple : Binding → List String) (env : Environment)
    (candidate : JointCandidate (List String)) (actionIndex : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (checked : selectedMatrixUse tuple env candidate actionIndex sourceUses targetUses before after = some after)
    (Value : String → Type) (valuation : (use : MatrixUse) → Value use.observedType) :
    (selectedMatrixUse tuple env candidate actionIndex sourceUses targetUses before after).map
      (matrixValue Value valuation) = some ⟨after.observedType,valuation after⟩ := by
  rw [checked]; rfl

/- Exact result-type conjunct of ClosedCallEvidence.nullary for expression
   calls. INT is parser-typed but rejected by the historical RELATION test. -/
def oldNullaryResult (kind result : String) : Bool :=
  if kind = "call/formula" then result == "BOOL" else result.startsWith "RELATION["

theorem integer_old_nullary_rejected : oldNullaryResult "call/expression" "INT" = false := by decide

/- This is the old argument grammar's operator conjunct, not a substitute
   for its type/owner checks. Rejection here entails rejection of that gate. -/
inductive ArgumentShape where
  | variable | global
  | join (left right : ArgumentShape)
  | difference (left right : ArgumentShape)
  | closure (body : ArgumentShape)
  deriving DecidableEq

def oldArgumentGrammar : ArgumentShape → Bool
  | .variable | .global => true
  | .join a b | .difference a b => oldArgumentGrammar a && oldArgumentGrammar b
  | .closure _ => false

theorem closure_old_argument_rejected (a : ArgumentShape) :
    oldArgumentGrammar (.closure a) = false := rfl

def oldClosedNecessary (call : CallRecord) : Bool :=
  call.kind == "call/expression" && call.resultType.startsWith "RELATION["

def oldBoundNecessary (call : CallRecord) (args : List ArgumentShape) : Bool :=
  call.declaredArity != 0 && args.all oldArgumentGrammar

def oldNullaryNecessary (call : CallRecord) : Bool :=
  call.declaredArity == 0 && call.arguments.isEmpty && oldNullaryResult call.kind call.resultType

/- Exact census disjunction with necessary conjuncts factored out of each
   legacy alternative. The remainder contains every unchanged source/type/
   owner check. Rejection below holds for every possible remainder, not an
   assumed false answer from the checker being disputed. -/
def oldCensusGate (call : CallRecord) (args : List ArgumentShape)
    (scopedAdmission : Bool) (locals : Nat) (closedRest boundRest nullaryRest : Bool) : Bool :=
  scopedAdmission || locals == 0 &&
    (oldClosedNecessary call && closedRest || oldBoundNecessary call args && boundRest ||
      oldNullaryNecessary call && nullaryRest)

theorem old_census_rejected_by_conjuncts (call : CallRecord) (args : List ArgumentShape)
    (closed : oldClosedNecessary call = false) (bound : oldBoundNecessary call args = false)
    (nullary : oldNullaryNecessary call = false) (locals : Nat)
    (closedRest boundRest nullaryRest : Bool) :
    oldCensusGate call args false locals closedRest boundRest nullaryRest = false := by
  simp [oldCensusGate,closed,bound,nullary]

/- Uses are not another payment. The consumer names the original owner's
   token, and exact membership authenticates the entire amount/owner/key. -/
inductive PaymentUse where
  | charge (payment : Payment)
  | borrow (consumer : Component) (payment : Payment)
  deriving DecidableEq

def claims (uses : List PaymentUse) : List Payment := uses.filterMap fun use =>
  match use with
  | .charge p => some p
  | .borrow _ _ => none

def useCheck (selected : List Payment) (uses : List PaymentUse) : Bool :=
  paymentCheck selected (claims uses) && uses.all (fun use =>
    match use with
    | .charge p | .borrow _ p => decide (p ∈ selected))

def useCost : PaymentUse → Nat
  | .charge p => p.amount
  | .borrow _ _ => 0

theorem uses_cost_is_claims (uses : List PaymentUse) :
    (uses.map useCost).sum = ((claims uses).map Payment.amount).sum := by
  induction uses with
  | nil => rfl
  | cons use rest ih => cases use <;> simp [claims, useCost] at * <;> omega

theorem checked_uses_total (selected : List Payment) (uses : List PaymentUse)
    (checked : useCheck selected uses = true) :
    (uses.map useCost).sum = (selected.map Payment.amount).sum ∧
    ((claims uses).map Payment.effect).Nodup := by
  have h : paymentCheck selected (claims uses) = true := (Bool.and_eq_true_iff.mp checked).1
  have exact := payment_exact selected (claims uses) h
  exact ⟨(uses_cost_is_claims uses).trans exact.2.2, exact.1⟩

theorem checked_borrow_issued (selected : List Payment) (uses : List PaymentUse)
    (checked : useCheck selected uses = true)
    (consumer : Component) (p : Payment) (member : .borrow consumer p ∈ uses) :
    p ∈ selected := by
  have all := (Bool.and_eq_true_iff.mp checked).2
  have h := List.all_eq_true.mp all (.borrow consumer p) member
  exact of_decide_eq_true h

theorem borrow_does_not_charge (consumer : Component) (p : Payment) (uses : List PaymentUse) :
    ((.borrow consumer p :: uses).map useCost).sum = (uses.map useCost).sum := by
  simp [useCost]

/- Link a use to the exact selected route action, not to an equal scalar. -/
def routeEffect (route : TypedRoute) : EffectId :=
  let before := route.before.map (fun b => b.origin)
  let after := route.after.map (fun b => b.origin)
  { sourceHash := (before.map (fun b => b.sourceHash)).getD ((after.map (fun b => b.sourceHash)).getD "")
    targetHash := (after.map (fun b => b.sourceHash)).getD ""
    predicatePair := (before.map (fun b => b.predicate)).getD "" ++ "->" ++ (after.map (fun b => b.predicate)).getD ""
    sourceOccurrence := (before.map (fun b => b.occurrence)).getD ""
    targetOccurrence := (after.map (fun b => b.occurrence)).getD ""
    before := ""
    after := ""
    sourceBinding := route.before
    targetBinding := route.after
    sourceTuple := route.action.sourceTuple
    targetTuple := route.action.targetTuple }

def routePayment (route : TypedRoute) : Payment := ⟨routeEffect route, .declaration, route.action.cost⟩

def paidRouteUse (selected : List Payment) (route : TypedRoute) : Option PaymentUse :=
  if routePayment route ∈ selected then some (.borrow .matrix (routePayment route)) else none

theorem paid_route_use_exact (selected : List Payment) (route : TypedRoute) (use : PaymentUse)
    (checked : paidRouteUse selected route = some use) :
    routePayment route ∈ selected ∧ useCost use = 0 ∧
    (routePayment route).amount = route.action.cost ∧ (routePayment route).owner = .declaration := by
  unfold paidRouteUse at checked
  split at checked
  next h => cases checked; exact ⟨h,rfl,rfl,rfl⟩
  next => cases checked

end Focused225Concrete
