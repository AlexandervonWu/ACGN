/-
  Standalone kernel checks for the adaptive augmentation mechanism.
  Runtime schema admission additionally compiles one digest-bound theorem per
  candidate; this file proves the fixed lifecycle and generation obligations.
-/

inductive AugmentationState where
  | observed
  | candidate
  | falsified
  | verifiedLocal
  | verifiedSchema
  | admitted
  deriving DecidableEq

inductive LocalStep : AugmentationState -> AugmentationState -> Prop where
  | observeCandidate : LocalStep .observed .candidate
  | rejectLocal : LocalStep .candidate .falsified
  | verifyLocal : LocalStep .candidate .verifiedLocal

inductive SchemaStep : AugmentationState -> AugmentationState -> Prop where
  | rejectSchema : SchemaStep .candidate .falsified
  | verifySchema : SchemaStep .candidate .verifiedSchema
  | admitSchema : SchemaStep .verifiedSchema .admitted

theorem localCannotAdmitDirectly
    (step : LocalStep AugmentationState.verifiedLocal AugmentationState.admitted) :
    False := by
  cases step

theorem schemaAdmissionRequiresVerification
    (step : SchemaStep s AugmentationState.admitted) :
    s = AugmentationState.verifiedSchema := by
  cases step
  rfl

theorem generationStrictlyAdvances (generation : Nat) :
    generation < Nat.succ generation := by
  exact Nat.lt_succ_self generation

/- The implementation constructs `actual` from parser-owned Alloy `Type` and
   accepts a claimed graph type only through this equality. The abstract lemma
   records the fail-closed consequence used by EA-F30: a different spelling
   with the same arity cannot replace the authenticated carrier. -/
structure AuthenticatedType (TypeId : Type) where
  actual : TypeId
  expected : TypeId
  exact : actual = expected

theorem forgedExactTypeCannotAuthenticate
    {TypeId : Type} [DecidableEq TypeId]
    (evidence : AuthenticatedType TypeId)
    (forged : TypeId)
    (different : forged ≠ evidence.actual) :
    forged ≠ evidence.expected := by
  intro alleged
  apply different
  calc
    forged = evidence.expected := alleged
    _ = evidence.actual := evidence.exact.symm

/- A source-bound claim executes under its parser-owned command context. The
   request scope remains an input identifier but cannot replace that context. -/
structure CommandContext where
  scope : Int
  bitwidth : Nat
  optionDigest : Nat
  deriving DecidableEq

def effectiveContext
    (sourceBound : Bool)
    (source request : CommandContext) : CommandContext :=
  if sourceBound then source else request

theorem sourceCommandContextCannotBeOverridden
    (source request : CommandContext) :
    effectiveContext true source request = source := by
  rfl

def effectiveScopeIdentity
    (sourceScope : Option Nat)
    (requestScope : Nat) : Nat :=
  match sourceScope with
  | some scope => scope
  | none => requestScope

theorem sourceBoundConvenienceScopesHaveOneIdentity
    (sourceScope firstRequest secondRequest : Nat) :
    effectiveScopeIdentity (some sourceScope) firstRequest =
      effectiveScopeIdentity (some sourceScope) secondRequest := by
  rfl

theorem unboundRequestScopeRemainsEffective (requestScope : Nat) :
    effectiveScopeIdentity none requestScope = requestScope := by
  rfl

def resolvedEndpointContext
    (declarationIdentity : Nat)
    (_sourceSpelling : String) : Nat :=
  declarationIdentity

theorem parserEquivalentEndpointSpellingsHaveOneContext
    (declarationIdentity : Nat)
    (firstSpelling secondSpelling : String) :
    resolvedEndpointContext declarationIdentity firstSpelling =
      resolvedEndpointContext declarationIdentity secondSpelling := by
  rfl

/- An admitted schema is global as an equality, but each concrete application
   still carries source/profile provenance. Runtime application authority is
   constructible only after the request context equals the endpoint context. -/
inductive SchemaApplicationAuthorized
    (endpointContext requestContext : Nat) : Prop where
  | authenticated
      (same : requestContext = endpointContext) :
      SchemaApplicationAuthorized endpointContext requestContext

theorem mismatchedApplicationContextHasNoAuthority
    (endpointContext requestContext : Nat)
    (different : requestContext ≠ endpointContext) :
    ¬ SchemaApplicationAuthorized endpointContext requestContext := by
  intro authority
  cases authority with
  | authenticated same => exact different same

/- The current adaptive boundary commits the root Alloy source bytes but not
   the contents of explicitly opened modules. Authority is therefore
   constructible only for a closed root. This is deliberately fail-closed;
   ordinary parsing and canonicalization may still use opened modules. -/
inductive SourceClosureAuthorized : Bool -> Prop where
  | closedRoot : SourceClosureAuthorized false

theorem explicitOpenHasNoSourceClosureAuthority :
    Not (SourceClosureAuthorized true) := by
  intro authority
  cases authority

/- Local callable identity contains call kind and arity. This is the bounded
   overload-separation invariant exercised by EA-F32. -/
inductive CallKind where
  | formula
  | expression
  deriving DecidableEq

structure CallableKey where
  declaration : Nat
  kind : CallKind
  arity : Nat
  deriving DecidableEq

theorem distinctAritiesHaveDistinctCallableKeys
    (declaration : Nat)
    (kind : CallKind)
    (leftArity rightArity : Nat)
    (different : leftArity ≠ rightArity) :
    CallableKey.mk declaration kind leftArity ≠
      CallableKey.mk declaration kind rightArity := by
  intro alleged
  apply different
  exact congrArg CallableKey.arity alleged

/- A solver result denotes the generated validation formula only when that
   command executes independently. Alloy follow-up commands may execute an
   ancestor first, so the Java profile boundary rejects them rather than
   erasing this control dependency. -/
inductive CommandAuthority where
  | independent
  | followUp (parentFormula : Nat)
  deriving DecidableEq

structure ValidationCommand where
  formula : Nat
  authority : CommandAuthority

def executedFormula (command : ValidationCommand) : Nat :=
  match command.authority with
  | .independent => command.formula
  | .followUp parentFormula => parentFormula

theorem independentValidationExecutesItsOwnFormula (formula : Nat) :
    executedFormula { formula := formula, authority := .independent } = formula := by
  rfl

theorem copiedParentCanSubstituteAnotherFormula
    (formula parentFormula : Nat) (different : parentFormula ≠ formula) :
    executedFormula { formula := formula, authority := .followUp parentFormula }
      ≠ formula := by
  simpa [executedFormula] using different

/- A source command contributes its actual solver search domain. A run searches
   models satisfying its formula; a check searches counterexamples satisfying
   its negation. Equality evidence is therefore the implication from that
   domain, not an unguarded query that discards the committed command formula. -/
inductive CommandTarget where
  | run
  | check
  deriving DecidableEq

def commandSearchGuard (target : CommandTarget) (formula : Prop) : Prop :=
  match target with
  | .run => formula
  | .check => Not formula

theorem runSearchGuardIsFormula (formula : Prop) :
    commandSearchGuard .run formula ↔ formula := by
  rfl

theorem checkSearchGuardIsCounterexampleDomain (formula : Prop) :
    commandSearchGuard .check formula ↔ Not formula := by
  rfl

theorem guardedEqualityAppliesInSearchDomain
    (target : CommandTarget)
    (commandFormula equality : Prop)
    (inside : commandSearchGuard target commandFormula)
    (validated : commandSearchGuard target commandFormula → equality) :
    equality := by
  exact validated inside

def contextualCounterexample
    (target : CommandTarget)
    (commandFormula equality : Prop) : Prop :=
  commandSearchGuard target commandFormula ∧ Not equality

theorem noContextualCounterexampleProvesEqualityInSearchDomain
    (target : CommandTarget)
    (commandFormula equality : Prop)
    (none : Not (contextualCounterexample target commandFormula equality))
    (inside : commandSearchGuard target commandFormula) :
    equality := by
  cases Classical.em equality with
  | inl established => exact established
  | inr notEquality => exact False.elim (none ⟨inside, notEquality⟩)

/- Quantified formulas with different domains cannot be collapsed onto one
   proposition merely because a pretty-printer omits their declarations. -/
theorem erasedQuantifierDomainSchemaIsNotValid :
    ¬ (∀ (qLeft qRight p : Prop),
        (qLeft ∧ (p ∧ p)) ↔ (qRight ∧ p)) := by
  intro alleged
  have counterexample := alleged False True True
  simp at counterexample

/- Representative mechanically derived Boolean schema obligation used by the
   executable regression. It is independent of Alloy atoms and therefore
   proves the equality for every interpretation of the three propositions. -/
theorem consensusSchema (p0 p1 p2 : Prop) :
    (Or (And p1 p2) (And (Not p1) p0)) <->
    (Or (And p1 p2) (Or (And (Not p1) p0) (And p2 p0))) := by
  constructor
  case mp =>
    intro h
    cases h with
    | inl hpq => exact Or.inl hpq
    | inr hnpr => exact Or.inr (Or.inl hnpr)
  case mpr =>
    intro h
    cases h with
    | inl hpq => exact Or.inl hpq
    | inr hrest =>
      cases hrest with
      | inl hnpr => exact Or.inr hnpr
      | inr hqr =>
        cases Classical.em p1 with
        | inl hp => exact Or.inl (And.intro hp hqr.left)
        | inr hnp => exact Or.inr (And.intro hnp hqr.right)
