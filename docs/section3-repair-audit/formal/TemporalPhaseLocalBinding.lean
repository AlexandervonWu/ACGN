/-
  Bounded proof obligations for importing one lexical binder into distinct
  temporal phases. Every result is proved from the definitions below.
-/

namespace TemporalPhaseLocalBinding

inductive UnaryTemporalKind where
  | before
  | historically
  | once
  | always
  | eventually
  | after
  deriving DecidableEq, Repr

inductive BinaryTemporalKind where
  | until
  | releases
  | since
  | triggered
  deriving DecidableEq, Repr

inductive Term where
  | var (index : Nat)
  | all (body : Term)
  | implies (left right : Term)
  | unaryTemporal (kind : UnaryTemporalKind) (body : Term)
  | binaryTemporal (kind : BinaryTemporalKind) (left right : Term)
  deriving DecidableEq, Repr

def wellScoped : Nat -> Term -> Bool
  | depth, .var index => decide (index < depth)
  | depth, .all body => wellScoped (depth + 1) body
  | depth, .implies left right => wellScoped depth left && wellScoped depth right
  | depth, .unaryTemporal _ body => wellScoped depth body
  | depth, .binaryTemporal _ left right =>
      wellScoped depth left && wellScoped depth right

theorem unary_temporal_preserves_lexical_depth
    (kind : UnaryTemporalKind) (depth : Nat) (body : Term) :
    wellScoped depth (.unaryTemporal kind body) = wellScoped depth body := by
  rfl

theorem binary_temporal_preserves_lexical_depth_in_both_roles
    (kind : BinaryTemporalKind) (depth : Nat) (left right : Term) :
    wellScoped depth (.binaryTemporal kind left right)
      = (wellScoped depth left && wellScoped depth right) := by
  rfl

theorem unary_temporal_vocabulary_is_exhaustive (kind : UnaryTemporalKind) :
    kind = .before
      ∨ kind = .historically
      ∨ kind = .once
      ∨ kind = .always
      ∨ kind = .eventually
      ∨ kind = .after := by
  cases kind <;> simp

theorem binary_temporal_vocabulary_is_exhaustive (kind : BinaryTemporalKind) :
    kind = .until
      ∨ kind = .releases
      ∨ kind = .since
      ∨ kind = .triggered := by
  cases kind <;> simp

theorem outer_binder_scopes_every_unary_temporal_operator
    (kind : UnaryTemporalKind) :
    wellScoped 0 (.all (.unaryTemporal kind (.var 0))) = true := by
  cases kind <;> decide

theorem outer_binder_scopes_both_roles_of_every_binary_temporal_operator
    (kind : BinaryTemporalKind) :
    wellScoped 0 (.all (.binaryTemporal kind (.var 0) (.var 0))) = true := by
  cases kind <;> decide

theorem detached_unary_temporal_child_is_not_closed
    (kind : UnaryTemporalKind) :
    wellScoped 0 (.unaryTemporal kind (.var 0)) = false := by
  cases kind <;> decide

theorem detached_binary_temporal_children_are_not_closed
    (kind : BinaryTemporalKind) :
    wellScoped 0 (.binaryTemporal kind (.var 0) (.var 0)) = false := by
  cases kind <;> decide

def siblingTemporalUse : Term :=
  .all (.implies
    (.unaryTemporal .once (.var 0))
    (.unaryTemporal .always (.var 0)))

theorem outer_binder_scopes_both_temporal_branches :
    wellScoped 0 siblingTemporalUse = true := by
  decide

theorem detached_temporal_child_is_not_closed :
    wellScoped 0 (.unaryTemporal .always (.var 0)) = false := by
  decide

structure BinderOrigin where
  sourceLineage : Nat
  ownerPhase : Nat
  binderContext : Nat
  coordinate : Nat
  deriving DecidableEq, Repr

inductive TemporalPhaseRole where
  | unary (kind : UnaryTemporalKind)
  | binaryLeft (kind : BinaryTemporalKind)
  | binaryRight (kind : BinaryTemporalKind)
  deriving DecidableEq, Repr

structure PhaseImport where
  origin : BinderOrigin
  targetPath : List TemporalPhaseRole
  deriving DecidableEq, Repr

def admits (active : BinderOrigin) (imported : PhaseImport) : Bool :=
  decide (active = imported.origin)

def sourceBinder : BinderOrigin :=
  { sourceLineage := 41, ownerPhase := 0, binderContext := 7, coordinate := 0 }

def onceImport : PhaseImport :=
  { origin := sourceBinder, targetPath := [.unary .once] }

def alwaysImport : PhaseImport :=
  { origin := sourceBinder, targetPath := [.unary .always] }

def importInto (origin : BinderOrigin) (role : TemporalPhaseRole) : PhaseImport :=
  { origin := origin, targetPath := [role] }

def acceptsRepeatedSnapshot
    (first second : List PhaseImport) : Bool :=
  decide (first = second)

theorem repeating_the_exact_scope_snapshot_is_idempotent
    (role : TemporalPhaseRole) :
    acceptsRepeatedSnapshot
      [importInto sourceBinder role]
      [importInto sourceBinder role] = true := by
  simp [acceptsRepeatedSnapshot]

theorem a_repeated_reference_under_another_context_is_rejected
    (role : TemporalPhaseRole) :
    acceptsRepeatedSnapshot
      [importInto sourceBinder role]
      [importInto { sourceBinder with binderContext := 8 } role] = false := by
  simp [acceptsRepeatedSnapshot, importInto, sourceBinder]

theorem every_temporal_phase_role_admits_the_exact_owner
    (role : TemporalPhaseRole) :
    admits sourceBinder (importInto sourceBinder role) = true := by
  rfl

theorem binary_temporal_phase_roles_remain_distinct
    (kind : BinaryTemporalKind) :
    (importInto sourceBinder (.binaryLeft kind)).targetPath
      ≠ (importInto sourceBinder (.binaryRight kind)).targetPath := by
  cases kind <;> decide

theorem sibling_phases_reuse_the_exact_owner_coordinate :
    admits sourceBinder onceImport = true
      ∧ admits sourceBinder alwaysImport = true
      ∧ onceImport.targetPath ≠ alwaysImport.targetPath := by
  decide

theorem another_source_lineage_is_rejected :
    admits
      { sourceBinder with sourceLineage := 42 }
      alwaysImport = false := by
  decide

theorem another_binder_context_is_rejected :
    admits
      { sourceBinder with binderContext := 8 }
      alwaysImport = false := by
  decide

def allOver {α : Type} (carrier : α -> Prop) (body : α -> Prop) : Prop :=
  ∀ value, carrier value -> body value

theorem global_prenex_over_conjunction_fails_for_an_empty_carrier :
    let carrier : Bool -> Prop := fun _ => False
    let body : Bool -> Prop := fun _ => True
    let outside : Prop := False
    ((allOver carrier body) ∧ outside)
      ≠ allOver carrier (fun value => body value ∧ outside) := by
  simp [allOver]

def snapshotSingletonIsEmpty {α : Type} (_value : α) : Prop := False

def currentCarrierIntersectionIsEmpty
    {α : Type} (currentCarrier : α → Prop) (value : α) : Prop :=
  ¬ currentCarrier value

theorem mutable_carrier_can_drop_an_imported_snapshot_value :
    snapshotSingletonIsEmpty true ≠
      currentCarrierIntersectionIsEmpty (fun _ : Bool => False) true := by
  simp [snapshotSingletonIsEmpty, currentCarrierIntersectionIsEmpty]

theorem preserved_membership_licenses_static_carrier_absorption
    {α : Type} (currentCarrier : α → Prop) (value : α)
    (membershipPersists : currentCarrier value) :
    snapshotSingletonIsEmpty value ↔
      currentCarrierIntersectionIsEmpty currentCarrier value := by
  simp [snapshotSingletonIsEmpty, currentCarrierIntersectionIsEmpty,
    membershipPersists]

def carrierAbsorptionAdmitted
    (importedSnapshot parserVariableCarrier : Bool) : Bool :=
  !importedSnapshot || !parserVariableCarrier

theorem imported_snapshot_rejects_mutable_carrier_absorption :
    carrierAbsorptionAdmitted true true = false := by
  decide

theorem imported_snapshot_retains_static_carrier_absorption :
    carrierAbsorptionAdmitted true false = true := by
  decide

theorem same_phase_value_retains_carrier_absorption
    (parserVariableCarrier : Bool) :
    carrierAbsorptionAdmitted false parserVariableCarrier = true := by
  cases parserVariableCarrier <;> decide

end TemporalPhaseLocalBinding
