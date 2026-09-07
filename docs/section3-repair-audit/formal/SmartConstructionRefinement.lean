import ContainerReplay
import Phase2VariadicLaws

namespace ACGN.SmartConstructionRefinement

open ACGN.Section3.Phase2

/- The extracted Java fragment uses no integer arithmetic. Size is a Java
   List.size result, represented by a natural number. Cast/size failure and
   short-circuit evaluation remain explicit. Heap effects and the preceding
   flattenVisible call are outside this small expression semantics. -/
structure Frame where
  isSet : Bool
  size : Nat
  soleIsOne : Bool

inductive NumberExpr where
  | size
  | literal (value : Nat)
  deriving Repr, DecidableEq

inductive Condition where
  | isSet
  | isOne
  | equal (left right : NumberExpr)
  | not (condition : Condition)
  | and (left right : Condition)
  | or (left right : Condition)
  deriving Repr, DecidableEq

def evalNumber (frame : Frame) : NumberExpr → Option Nat
  | .size => if frame.isSet then some frame.size else none
  | .literal value => some value

def evalCondition (frame : Frame) : Condition → Option Bool
  | .isSet => some frame.isSet
  | .isOne => some frame.soleIsOne
  | .equal left right => do
      let l ← evalNumber frame left
      let r ← evalNumber frame right
      pure (l == r)
  | .not condition => (evalCondition frame condition).map (! ·)
  | .and left right => do
      let l ← evalCondition frame left
      if l then evalCondition frame right else pure false
  | .or left right => do
      let l ← evalCondition frame left
      if l then pure true else evalCondition frame right

inductive Outcome where
  | singleton | node | rejected
  deriving Repr, DecidableEq

structure Program where
  condition : Condition
  rejectionGuard : Condition
  whenTrue : Outcome
  whenFalse : Outcome
  deriving Repr, DecidableEq

def execute (program : Program) (frame : Frame) : Outcome :=
  match evalCondition frame program.condition with
  | none => .rejected
  | some false => program.whenFalse
  | some true =>
      match evalCondition frame program.rejectionGuard with
      | none | some true => .rejected
      | some false => program.whenTrue

def expectedProgram : Program :=
  { condition := .and .isSet (.equal .size (.literal 1))
    rejectionGuard := .not .isOne
    whenTrue := .singleton
    whenFalse := .node }

def shape {Operand : Type} : BooleanConstruction Operand → Outcome
  | .constant _ => .rejected
  | .operand _ => .singleton
  | .stored _ _ _ _ => .node

def modelOutcome {Operand : Type} (head : BooleanConnective) (operands : List Operand) : Outcome :=
  match constructBooleanCarrier head operands with
  | none => .rejected
  | some result => shape result

theorem extracted_program_refines_nonempty_carrier
    (program : Program) (correspondence : program = expectedProgram)
    (head : BooleanConnective) (operands : List Nat) (nonempty : operands ≠ []) :
    execute program ⟨true, operands.length, true⟩ = modelOutcome head operands := by
  subst program
  cases operands with
  | nil => contradiction
  | cons first rest =>
      cases rest <;>
        simp [execute, expectedProgram, evalCondition, evalNumber, modelOutcome,
          constructBooleanCarrier, smartBoolean, shape, List.length_cons]

theorem nonset_does_not_evaluate_the_set_cast (size : Nat) (one : Bool) :
    execute expectedProgram ⟨false, size, one⟩ = .node := by
  simp [execute, expectedProgram, evalCondition]

theorem wrongly_typed_singleton_rejects :
    execute expectedProgram ⟨true, 1, false⟩ = .rejected := by decide

theorem nonempty_target_shape_preserves_construction_denotation
    (head : BooleanConnective) (values : List Nat) (interpret : Nat → Bool) :
    (smartBoolean head values).evaluate interpret = head.evaluate interpret values :=
  boolean_smart_constructor_preserves_denotation head interpret values

/- The finite execution family includes n-ary words and all binary same-head
   associations through four leaves. The following source semantics and
   preservation theorems are independent of that finite bound. -/
inductive Source where
  | flat (values : List Nat)
  | binary (left right : Source)
  deriving Repr, DecidableEq

def Source.leaves : Source → List Nat
  | .flat values => values
  | .binary left right => left.leaves ++ right.leaves

def Source.denote (head : BooleanConnective) (interpret : Nat → Bool) : Source → Bool
  | .flat values => head.evaluate interpret values
  | .binary left right =>
      match head with
      | .and => left.denote head interpret && right.denote head interpret
      | .or => left.denote head interpret || right.denote head interpret

theorem same_head_flattening_preserves_denotation
    (source : Source) (head : BooleanConnective) (interpret : Nat → Bool) :
    source.denote head interpret = head.evaluate interpret source.leaves := by
  induction source with
  | flat values => rfl
  | binary left right hl hr =>
      cases head <;>
        simp_all [Source.denote, Source.leaves, BooleanConnective.evaluate,
          List.all_append, List.any_append]

structure Observation where
  source : Source
  outcome : Outcome
  trace : ACGN.ContainerReplay.Trace
  hasUnit : Bool

def observationValid (observation : Observation) : Bool :=
  observation.trace.input == observation.source.leaves &&
  observation.trace.kind == .set &&
  ACGN.ContainerReplay.valid observation.trace &&
  !observation.hasUnit &&
  !observation.trace.output.isEmpty &&
  (observation.outcome ==
    if observation.trace.output.length == 1 then .singleton else .node)

theorem observation_preserves_source_support (observation : Observation)
    (accepted : observationValid observation = true) :
    ∀ x, x ∈ observation.source.leaves ↔ x ∈ observation.trace.output := by
  simp only [observationValid, Bool.and_eq_true, beq_iff_eq] at accepted
  have source := accepted.1.1.1.1.1
  have kind := accepted.1.1.1.1.2
  have valid := accepted.1.1.1.2
  rw [← source]
  exact ACGN.ContainerReplay.set_preserves_support _ valid kind

theorem observation_preserves_boolean_denotation (observation : Observation)
    (accepted : observationValid observation = true)
    (head : BooleanConnective) (interpret : Nat → Bool) :
    observation.source.denote head interpret =
      head.evaluate interpret observation.trace.output := by
  rw [same_head_flattening_preserves_denotation]
  have support := observation_preserves_source_support observation accepted
  cases head <;> simp only [BooleanConnective.evaluate]
  · apply Bool.eq_iff_iff.mpr
    simp only [List.all_eq_true]
    constructor
    · intro h x member
      exact h x ((support x).mpr member)
    · intro h x member
      exact h x ((support x).mp member)
  · apply Bool.eq_iff_iff.mpr
    simp only [List.any_eq_true]
    constructor
    · rintro ⟨x, member, hx⟩
      exact ⟨x, (support x).mp member, hx⟩
    · rintro ⟨x, member, hx⟩
      exact ⟨x, (support x).mpr member, hx⟩

theorem observation_mints_no_unit (observation : Observation)
    (accepted : observationValid observation = true) : observation.hasUnit = false := by
  simp only [observationValid, Bool.and_eq_true, beq_iff_eq] at accepted
  simpa using accepted.1.1.2

theorem observation_target_matches_extracted_program
    (program : Program) (correspondence : program = expectedProgram)
    (observation : Observation) (accepted : observationValid observation = true) :
    observation.outcome = execute program ⟨true, observation.trace.output.length, true⟩ := by
  subst program
  simp only [observationValid, Bool.and_eq_true] at accepted
  cases one : (observation.trace.output.length == 1) <;>
    simpa [execute, expectedProgram, evalCondition, evalNumber, one] using accepted.2

end ACGN.SmartConstructionRefinement
