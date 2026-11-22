import RetainedDomainMapWitnesses
import StructuralDeclarationTyping

/- Phase inventories are source-issued inputs. This checker never moves a
   declaration across a temporal operator; an import refers to its full original
   Binding. Selected declaration programs, rather than equal scalar minima,
   authorize paid matrix links. -/
namespace PhaseOwnedJointRoutes
open Focused225SharedContracts Focused225Concrete
local instance : BEq Binding := instBEqOfDecidableEq

/- Dependent domains become guards at the declaration's time, not empty
   dependency environments. Keep the surrounding value `u` fixed. -/
theorem dependent_disjoint_guard_lowering (domain : U → W → Prop)
    (body : U → W → W → Prop) (u : U) :
    StructuralDeclarationTyping.sourceAllDisjoint (domain u) (body u) ↔
      (∀ x y, x ≠ y → ¬ domain u x ∨ ¬ domain u y ∨ body u x y) := by
  classical
  constructor
  · intro h x y different
    by_cases hx : domain u x
    · by_cases hy : domain u y
      · exact Or.inr (Or.inr (h x y hx hy different))
      · exact Or.inr (Or.inl hy)
    · exact Or.inl hx
  · intro h x y hx hy different
    rcases h x y different with noX | noY | yes
    · exact False.elim (noX hx)
    · exact False.elim (noY hy)
    · exact yes

structure Scope where
  phase : Nat
  path : List Nat
  owned : List Binding
  imports : List Binding
  deriving DecidableEq

def scopeAt (scopes : List Scope) (phase : Nat) : Option Scope :=
  match scopes.filter (fun s => s.phase == phase) with
  | [s] => some s
  | _ => none

def resolveBinding (scopes : List Scope) (phase : Nat) (b : Binding) : Option Binding := do
  let owner ← scopeAt scopes b.origin.phase
  let use ← scopeAt scopes phase
  if b ∈ owner.owned ∧ use.path.take owner.path.length = owner.path ∧
      ((phase = b.origin.phase ∧ b ∈ use.owned) ∨
       (phase ≠ b.origin.phase ∧ b ∈ use.imports)) then
    some b
  else none

theorem resolved_binding_is_original (scopes : List Scope) (phase : Nat)
    (b actual : Binding) (checked : resolveBinding scopes phase b = some actual) :
    actual = b ∧ ∃ owner use,
      scopeAt scopes b.origin.phase = some owner ∧ scopeAt scopes phase = some use ∧
      b ∈ owner.owned ∧ use.path.take owner.path.length = owner.path ∧
      ((phase = b.origin.phase ∧ b ∈ use.owned) ∨
       (phase ≠ b.origin.phase ∧ b ∈ use.imports)) := by
  unfold resolveBinding at checked
  cases ho : scopeAt scopes b.origin.phase with
  | none => simp [ho] at checked
  | some owner =>
    cases hu : scopeAt scopes phase with
    | none => simp [ho, hu] at checked
    | some use =>
      simp only [ho, hu] at checked
      dsimp only [Bind.bind, Option.bind] at checked
      split at checked
      next good => exact ⟨(Option.some.inj checked).symm, owner, use, rfl, rfl, good⟩
      next => cases checked

theorem import_does_not_rebind (scopes : List Scope) (phase : Nat) (b actual : Binding)
    (checked : resolveBinding scopes phase b = some actual)
    (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    typedRead Value valuation actual = typedRead Value valuation b := by
  rw [(resolved_binding_is_original scopes phase b actual checked).1]

theorem foreign_owner_rejected (scopes : List Scope) (phase : Nat) (b : Binding)
    (absent : ∀ owner, scopeAt scopes b.origin.phase = some owner → b ∉ owner.owned) :
    resolveBinding scopes phase b = none := by
  cases h : resolveBinding scopes phase b with
  | none => rfl
  | some actual =>
    obtain ⟨_, owner, use, ho, _, hb, _⟩ := resolved_binding_is_original scopes phase b actual h
    exact False.elim (absent owner ho hb)

structure OwnerProgram where
  sourcePhase : Nat
  targetPhase : Nat
  env : Environment
  candidate : JointCandidate (List String)

def ownerProgramCheck (tuple : Binding → List String) (left right : List Scope)
    (p : OwnerProgram) : Bool :=
  match scopeAt left p.sourcePhase, scopeAt right p.targetPhase with
  | some a, some b =>
    boundCandidate tuple p.env p.candidate && decide
      (p.env.source = a.owned ∧ p.env.target = b.owned ∧
       ∀ x ∈ a.owned, x.origin.phase = p.sourcePhase) &&
      decide (∀ y ∈ b.owned, y.origin.phase = p.targetPhase)
  | _, _ => false

def selectedOwnedRoute (tuple : Binding → List String) (left right : List Scope)
    (p : OwnerProgram) (action : Nat) (sourceUses targetUses : List MatrixUse)
    (before after : MatrixUse) : Option TypedRoute := do
  if !ownerProgramCheck tuple left right p then none else
    let route ← selectedRoute tuple p.env p.candidate action (some before.binding) (some after.binding)
    if before ∈ sourceUses ∧ after ∈ targetUses ∧
        resolveBinding left before.phase before.binding = some before.binding ∧
        resolveBinding right after.phase after.binding = some after.binding then
      some route
    else none

theorem owned_route_exact (tuple : Binding → List String) (left right : List Scope)
    (p : OwnerProgram) (action : Nat) (sourceUses targetUses : List MatrixUse)
    (before after : MatrixUse) (route : TypedRoute)
    (checked : selectedOwnedRoute tuple left right p action sourceUses targetUses before after = some route) :
    ownerProgramCheck tuple left right p = true ∧
    selectedRoute tuple p.env p.candidate action (some before.binding) (some after.binding) = some route ∧
    before ∈ sourceUses ∧ after ∈ targetUses ∧
    resolveBinding left before.phase before.binding = some before.binding ∧
    resolveBinding right after.phase after.binding = some after.binding := by
  unfold selectedOwnedRoute at checked
  split at checked
  next => simp at checked
  next good =>
    have hp : ownerProgramCheck tuple left right p = true := by simpa using good
    cases hr : selectedRoute tuple p.env p.candidate action (some before.binding) (some after.binding) with
    | none => simp [hr] at checked
    | some selected =>
      simp only [hr] at checked
      dsimp only [Bind.bind, Option.bind] at checked
      split at checked
      next valid =>
        cases checked
        exact ⟨hp, rfl, valid⟩
      next => cases checked

theorem owned_route_has_paid_or_keep_action (tuple : Binding → List String)
    (left right : List Scope) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) (route : TypedRoute)
    (checked : selectedOwnedRoute tuple left right p action sourceUses targetUses before after = some route) :
    boundCandidate tuple p.env p.candidate = true ∧
    p.candidate.actions[action]? = some route.action ∧
    route.before = some before.binding ∧ route.after = some after.binding := by
  have h := (owned_route_exact tuple left right p action sourceUses targetUses before after route checked).2.1
  have exactRoute := selected_route_exact tuple p.env p.candidate action _ _ route h
  exact ⟨exactRoute.1, exactRoute.2.1, exactRoute.2.2.2.2⟩

theorem owned_route_reads_typed_target (tuple : Binding → List String)
    (left right : List Scope) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) (route : TypedRoute)
    (checked : selectedOwnedRoute tuple left right p action sourceUses targetUses before after = some route)
    (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead route before.binding).map (typedRead Value valuation) =
      some ⟨after.binding.origin.exactType, valuation after.binding⟩ := by
  have h := owned_route_has_paid_or_keep_action tuple left right p action sourceUses targetUses before after route checked
  exact typed_paid_read Value valuation route before.binding after.binding h.2.2.1 h.2.2.2

/- Exact necessary conjuncts of CanonicalDistance.paidImportIdentity. Other
   guards remain in `rest`; rejection here implies rejection of the old gate. -/
def oldPaidImportGate (a b : Binding) (rest : Bool) : Bool :=
  rest && decide (a.origin.quantifier ≠ b.origin.quantifier) &&
    decide (a.origin.cardinality = b.origin.cardinality) &&
    decide (a.origin.disjointness = b.origin.disjointness) &&
    decide (a.origin.exactType = b.origin.exactType)

theorem old_same_quantifier_rejected (a b : Binding) (rest : Bool)
    (same : a.origin.quantifier = b.origin.quantifier) :
    oldPaidImportGate a b rest = false := by simp [oldPaidImportGate, same]

end PhaseOwnedJointRoutes
