/-
  Standalone, bounded proof obligations for the full-corpus preflight fixes.
  Every declaration below is closed by an explicit proof term.
-/

namespace FullCorpusPreflight

inductive Column where
  | int
  | sig (name : Nat)
  deriving DecidableEq, Repr

inductive StoredType where
  | int
  | relation (columns : List Column)
  | unsupported
  deriving DecidableEq, Repr

def relationView : StoredType -> Option (List Column)
  | .int => some [.int]
  | .relation columns => some columns
  | .unsupported => none

def joinType (left right : List Column) : Option (List Column) :=
  match left.getLast?, right.head? with
  | some leftBoundary, some rightBoundary =>
      if leftBoundary = rightBoundary then
        some (left.dropLast ++ right.drop 1)
      else
        none
  | _, _ => none

def integerNextSignature : Prod Nat (List Column) :=
  (0, [.int, .int])

theorem integer_next_is_zero_arity :
    integerNextSignature.1 = 0 := by
  rfl

theorem integer_next_returns_binary_int_relation :
    integerNextSignature.2 = [.int, .int] := by
  rfl

theorem primitive_int_has_unary_relation_view :
    relationView .int = some [.int] := by
  rfl

theorem unary_int_join_integer_next_is_unary_int :
    joinType [.int] integerNextSignature.2 = some [.int] := by
  decide

theorem stored_int_and_join_result_share_the_certified_relation_view :
    relationView .int = joinType [.int] integerNextSignature.2 := by
  decide

theorem a_mismatched_join_boundary_is_rejected (name : Nat) :
    joinType [Column.sig name] integerNextSignature.2 = none := by
  simp [joinType, integerNextSignature]

inductive Term where
  | atom (name : Nat)
  | bound
  | after (body : Term)
  | pair (left right : Term)
  | letE (value body : Term)
  deriving DecidableEq, Repr

def substituteBound (replacement : Term) : Term -> Term
  | .atom name => .atom name
  | .bound => replacement
  | .after body => .after (substituteBound replacement body)
  | .pair left right =>
      .pair (substituteBound replacement left)
        (substituteBound replacement right)
  | .letE value body =>
      .letE (substituteBound replacement value) body

def betaLet (value body : Term) : Term :=
  substituteBound value body

theorem beta_substitution_reaches_an_after_phase (value : Term) :
    betaLet value (.after .bound) = .after value := by
  rfl

theorem beta_substitution_reaches_each_temporal_use (value : Term) :
    betaLet value (.pair .bound (.after .bound)) =
      .pair value (.after value) := by
  rfl

structure ContainerLawKey where
  operator : Nat
  carrier : StoredType
  deriving DecidableEq, Repr

structure Occurrence where
  lawKey : ContainerLawKey
  sourceLineage : Nat
  deriving DecidableEq, Repr

def rebindExistingLaw (source repaired : Occurrence) : Option ContainerLawKey :=
  if source.lawKey = repaired.lawKey then some source.lawKey else none

theorem repaired_occurrence_cannot_change_the_authorized_law
    (source repaired : Occurrence)
    (same : source.lawKey = repaired.lawKey) :
    rebindExistingLaw source repaired = some source.lawKey := by
  simp [rebindExistingLaw, same]

theorem another_carrier_cannot_receive_the_authorized_law
    (source repaired : Occurrence)
    (different : Not (source.lawKey = repaired.lawKey)) :
    rebindExistingLaw source repaired = none := by
  simp [rebindExistingLaw, different]

def quotientSetPair {α : Type} [DecidableEq α]
    (left right : α) : List α :=
  if left = right then [left] else [left, right]

theorem certified_eclass_equality_licenses_set_idempotence
    {α : Type} [DecidableEq α]
    (left right : α)
    (certified : left = right) :
    quotientSetPair left right = [left] := by
  simp [quotientSetPair, certified]

theorem idempotent_operation_respects_certified_eclass_equality
    {α : Type}
    (combine : α -> α -> α)
    (left right : α)
    (certified : left = right)
    (idempotent : combine left left = left) :
    combine left right = left := by
  simpa [certified] using idempotent

def sequencePair {α : Type} (left right : α) : List α :=
  [left, right]

theorem ordered_or_bag_occurrences_are_not_removed_by_the_set_step
    {α : Type} (left right : α) :
    sequencePair left right = [left, right] := by
  rfl

def pairwiseMinimum
    {α : Type}
    (cost : α -> α -> Nat)
    (first second target : α) : Nat :=
  Nat.min (cost first target) (cost second target)

theorem certified_representatives_are_compared_by_pairwise_minimum
    {α : Type}
    (cost : α -> α -> Nat)
    (first second target : α)
    (secondMatches : cost second target = 0) :
    pairwiseMinimum cost first second target = 0 := by
  simp [pairwiseMinimum, secondMatches]

def remapFiber (sourceToRepaired : Nat -> Nat) (fiber : List Nat) : List Nat :=
  fiber.map sourceToRepaired

theorem lineage_remapping_preserves_exact_fiber_membership
    (sourceToRepaired : Nat -> Nat)
    (fiber : List Nat)
    (repaired : Nat) :
    repaired ∈ remapFiber sourceToRepaired fiber ↔
      ∃ certifiedSource ∈ fiber,
        sourceToRepaired certifiedSource = repaired := by
  simp [remapFiber]

theorem certified_duplicate_temporal_phase_has_one_repair_occurrence
    {α : Type} [DecidableEq α] (phase : α) :
    quotientSetPair phase phase = [phase] := by
  simp [quotientSetPair]

def temporalBranchSurvivesBooleanOr (guard temporal : Bool) : Bool :=
  !guard && !(guard || !guard || temporal)

theorem complementary_guard_makes_temporal_or_branch_unreachable
    (guard temporal : Bool) :
    guard || !guard || temporal = true := by
  cases guard <;> simp

theorem unreachable_temporal_branch_has_no_observable_occurrence
    (guard temporal : Bool) :
    temporalBranchSurvivesBooleanOr guard temporal = false := by
  cases guard <;> simp [temporalBranchSurvivesBooleanOr]

end FullCorpusPreflight
