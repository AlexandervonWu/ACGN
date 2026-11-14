import CarrierFrameMultiplicity

namespace OneSidedDomainDependencies
open Focused225SharedContracts Focused225Concrete PhaseOwnedJointRoutes
open PaidSlotDomainTransport
open ACGN.FifthFive.SharedActionBoundary (DKind)

structure DependencyCharge where
  binding : Binding
  actionIndex : Nat
  frames : List CarrierFrameMultiplicity.Frame
  deriving DecidableEq

def paidDependency (p : OwnerProgram) (sourceSide : Bool)
    (issued : List CarrierFrameMultiplicity.Frame) (d : DependencyCharge) : Bool :=
  match p.candidate.actions[d.actionIndex]? with
  | none => false
  | some action =>
    p.env.authentic sourceSide d.binding.vectorIndex d.binding &&
    CarrierFrameMultiplicity.carrierFrames issued
      (if sourceSide then p.sourcePhase else p.targetPhase) d.binding d.frames &&
    decide (action.cost = 1 ∧
      action.kind = (if sourceSide then DKind.delete else DKind.insert) ∧
      (if sourceSide then action.source else action.target) = some d.binding.ordinal ∧
      (if sourceSide then action.target else action.source) = none)

theorem paid_dependency_exact (p : OwnerProgram) (side : Bool)
    (issued : List CarrierFrameMultiplicity.Frame) (d : DependencyCharge)
    (h : paidDependency p side issued d = true) :
    (if side then p.env.source else p.env.target)[d.binding.vectorIndex]? = some d.binding ∧
    CarrierFrameMultiplicity.carrierFrames issued
      (if side then p.sourcePhase else p.targetPhase) d.binding d.frames = true ∧
    ∃ action, p.candidate.actions[d.actionIndex]? = some action ∧ action.cost = 1 ∧
      action.kind = (if side then DKind.delete else DKind.insert) ∧
      (if side then action.source else action.target) = some d.binding.ordinal ∧
      (if side then action.target else action.source) = none := by
  unfold paidDependency at h
  cases found : p.candidate.actions[d.actionIndex]? with
  | none => simp [found] at h
  | some action =>
    have facts : p.env.authentic side d.binding.vectorIndex d.binding = true ∧
        CarrierFrameMultiplicity.carrierFrames issued
          (if side then p.sourcePhase else p.targetPhase) d.binding d.frames = true ∧
        action.cost = 1 ∧ action.kind = (if side then DKind.delete else DKind.insert) ∧
        (if side then action.source else action.target) = some d.binding.ordinal ∧
        (if side then action.target else action.source) = none := by
      simpa [found, and_assoc] using h
    exact ⟨(authentic_binding p.env side _ _ facts.1).1, facts.2.1,
      action, rfl, facts.2.2⟩

def dependenciesChecked (p : OwnerProgram) (side : Bool)
    (inventory : DependencyInventory) (issued : List CarrierFrameMultiplicity.Frame)
    (parent : Binding) (charges : List DependencyCharge) : Bool :=
  match dependencyRecords (if side then inventory.source else inventory.target) parent with
  | none => false
  | some actual => decide (actual.map (fun b => b.ordinal) = parent.origin.dependencies ∧
      charges.map DependencyCharge.binding = actual) && charges.all (paidDependency p side issued)

theorem dependencies_checked_exact (p : OwnerProgram) (side : Bool)
    (inventory : DependencyInventory) (issued : List CarrierFrameMultiplicity.Frame)
    (parent : Binding) (charges : List DependencyCharge)
    (h : dependenciesChecked p side inventory issued parent charges = true) :
    (charges.map (fun d => d.binding.ordinal)) = parent.origin.dependencies ∧
    ∀ d ∈ charges, paidDependency p side issued d = true := by
  unfold dependenciesChecked at h
  cases found : dependencyRecords (if side then inventory.source else inventory.target) parent with
  | none => simp [found] at h
  | some actual =>
    have facts : (actual.map (fun b => b.ordinal) = parent.origin.dependencies ∧
        charges.map DependencyCharge.binding = actual) ∧
        ∀ d ∈ charges, paidDependency p side issued d = true := by
      simpa [found, List.all_eq_true] using h
    refine ⟨?_, facts.2⟩
    have names := congrArg (List.map (fun (b : Binding) => b.ordinal)) facts.1.2
    simpa only [List.map_map, Function.comp_def] using names.trans facts.1.1

def excludedFromMap (side : Bool) (charges : List DependencyCharge)
    (mapping : List (Binding × Binding)) : Bool :=
  charges.all fun d => mapping.all fun pair =>
    decide ((if side then pair.1 else pair.2) ≠ d.binding)

theorem no_invented_dependency_pair (side : Bool) (charges : List DependencyCharge)
    (mapping : List (Binding × Binding)) (h : excludedFromMap side charges mapping = true)
    (d : DependencyCharge) (member : d ∈ charges) (pair : Binding × Binding)
    (selected : pair ∈ mapping) : (if side then pair.1 else pair.2) ≠ d.binding := by
  have all : ∀ d ∈ charges, ∀ pair ∈ mapping,
      (if side then pair.1 else pair.2) ≠ d.binding := by
    simpa [excludedFromMap, List.all_eq_true] using h
  exact all d member pair selected

structure GuardUse where
  requirement : PaidSlotGuardReplay.Requirement
  coverIndex : Nat
  editIndex : Nat
  replayIndex : Nat
  deriving DecidableEq

-- The full issued list binds each lowering requirement to its original slot.
def requirements (issued : List (Binding × PaidSlotGuardReplay.Requirement))
    (binding : Binding) : List PaidSlotGuardReplay.Requirement :=
  (issued.filter (fun item => decide (item.1 = binding))).map Prod.snd

def guardsChecked (side : Bool) (issued : List (Binding × PaidSlotGuardReplay.Requirement))
    (binding : Binding) (uses : List GuardUse) (selected : List PaidSlotGuardReplay.Cover)
    (emitted : List PaidSlotGuardReplay.Edit) : Bool :=
  !uses.isEmpty && decide (uses.map GuardUse.requirement = requirements issued binding) &&
    uses.all (fun use => PaidSlotGuardReplay.covers side
      (issued.map (fun item => item.2.declaration)) use.requirement selected emitted
      use.coverIndex use.editIndex use.replayIndex)

theorem every_required_guard_paid (side : Bool)
    (issued : List (Binding × PaidSlotGuardReplay.Requirement)) (binding : Binding)
    (uses : List GuardUse) (selected : List PaidSlotGuardReplay.Cover)
    (emitted : List PaidSlotGuardReplay.Edit)
    (h : guardsChecked side issued binding uses selected emitted = true)
    (requirement : PaidSlotGuardReplay.Requirement)
    (member : requirement ∈ requirements issued binding) (guard : PaidSlotGuardReplay.Node)
    (explicit : requirement.guard = some guard) :
    ∃ use ∈ uses, use.requirement = requirement ∧
      ∃ cover edit, selected[use.coverIndex]? = some cover ∧ emitted[use.replayIndex]? = some edit ∧
        cover.owner = requirement.declaration.owner ∧ cover.operations[use.editIndex]? = some edit ∧
        cover.charge = (cover.operations.map PaidSlotGuardReplay.Edit.cost).sum ∧
        (if side then edit.source else edit.target) = some guard := by
  have facts : uses ≠ [] ∧ uses.map GuardUse.requirement = requirements issued binding ∧
      ∀ use ∈ uses, PaidSlotGuardReplay.covers side
        (issued.map (fun item => item.2.declaration)) use.requirement selected emitted
        use.coverIndex use.editIndex use.replayIndex = true := by
    simpa [guardsChecked, List.all_eq_true, and_assoc] using h
  rw [← facts.2.1] at member
  obtain ⟨use, hu, equal⟩ := List.mem_map.mp member
  refine ⟨use, hu, equal, ?_⟩
  have paid := PaidSlotGuardReplay.required_guard_selected_and_paid side
    (issued.map (fun item => item.2.declaration)) use.requirement selected emitted
    use.coverIndex use.editIndex use.replayIndex guard (by simpa [equal] using explicit)
    (facts.2.2 use hu)
  simpa [equal] using paid

-- These predicates supplement the existing typed paid route; they never turn
-- unequal domains into alpha equivalence or omit a selected guard operation.
def independentSlot (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (inventory : DependencyInventory) (sf tf : List CarrierFrameMultiplicity.Frame)
    (sourceCharges targetCharges : List DependencyCharge) (mapping : List (Binding × Binding))
    (si ti : List (Binding × PaidSlotGuardReplay.Requirement)) (su tu : List GuardUse)
    (selected : List PaidSlotGuardReplay.Cover) (emitted : List PaidSlotGuardReplay.Edit)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) :=
  if dependenciesChecked p true inventory sf before.binding sourceCharges &&
      dependenciesChecked p false inventory tf after.binding targetCharges &&
      excludedFromMap true sourceCharges mapping && excludedFromMap false targetCharges mapping &&
      guardsChecked true si before.binding su selected emitted &&
      guardsChecked false ti after.binding tu selected emitted then
    typedSlotTransport tuple left right p action sourceUses targetUses before after
  else none

theorem independent_slot_exact (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (inventory : DependencyInventory) (sf tf : List CarrierFrameMultiplicity.Frame)
    (sc tc : List DependencyCharge) (mapping : List (Binding × Binding))
    (si ti : List (Binding × PaidSlotGuardReplay.Requirement)) (su tu : List GuardUse)
    (selected : List PaidSlotGuardReplay.Cover) (emitted : List PaidSlotGuardReplay.Edit)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (route : TypedRoute) (h : independentSlot tuple left right p inventory sf tf sc tc mapping
      si ti su tu selected emitted action sourceUses targetUses before after = some route) :
    dependenciesChecked p true inventory sf before.binding sc = true ∧
    dependenciesChecked p false inventory tf after.binding tc = true ∧
    excludedFromMap true sc mapping = true ∧ excludedFromMap false tc mapping = true ∧
    guardsChecked true si before.binding su selected emitted = true ∧
    guardsChecked false ti after.binding tu selected emitted = true ∧
    typedSlotTransport tuple left right p action sourceUses targetUses before after = some route := by
  unfold independentSlot at h
  split at h
  next checked =>
    have facts := checked
    simp only [Bool.and_eq_true] at facts
    exact ⟨facts.1.1.1.1.1, facts.1.1.1.1.2, facts.1.1.1.2,
      facts.1.1.2, facts.1.2, facts.2, h⟩
  next => cases h

theorem independent_slot_typed_read (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (inventory : DependencyInventory) (sf tf : List CarrierFrameMultiplicity.Frame)
    (sc tc : List DependencyCharge) (mapping : List (Binding × Binding))
    (si ti : List (Binding × PaidSlotGuardReplay.Requirement)) (su tu : List GuardUse)
    (selected : List PaidSlotGuardReplay.Cover) (emitted : List PaidSlotGuardReplay.Edit)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (route : TypedRoute) (h : independentSlot tuple left right p inventory sf tf sc tc mapping
      si ti su tu selected emitted action sourceUses targetUses before after = some route)
    (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead route before.binding).map (typedRead Value valuation) =
      some ⟨after.binding.origin.exactType, valuation after.binding⟩ ∧
    p.candidate.actions[action]? = some route.action ∧ route.action.cost = 1 := by
  have checked := independent_slot_exact tuple left right p inventory sf tf sc tc mapping
    si ti su tu selected emitted action sourceUses targetUses before after route h
  have sound := typed_transport_sound tuple left right p action sourceUses targetUses before after
    route checked.2.2.2.2.2.2 Value valuation
  exact ⟨sound.1, sound.2.1, sound.2.2.2.1⟩

def oldDependencyGate (source target : Binding) : Bool :=
  decide (source.origin.dependencies.length = target.origin.dependencies.length)

theorem unequal_dependencies_old_rejected (source target : Binding)
    (h : source.origin.dependencies.length ≠ target.origin.dependencies.length) :
    oldDependencyGate source target = false := by simp [oldDependencyGate, h]

end OneSidedDomainDependencies
