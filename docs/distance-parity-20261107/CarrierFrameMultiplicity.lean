import PaidSlotGuardReplay
import SelectedDeclarationPathTransport

namespace CarrierFrameMultiplicity
open Focused225SharedContracts Focused225Concrete PhaseOwnedJointRoutes
open PaidSlotDomainTransport

structure Frame where
  binding : Binding
  declarationOccurrence : Nat
  variableOccurrence : Nat
  tupleSlot : Nat
  domain : String
  guard : Option PaidSlotGuardReplay.Node
  deriving DecidableEq

-- Issuance includes the complete original binding and lowering evidence.
def carrierFrames (issued : List Frame) (owner : Nat) (binding : Binding)
    (frames : List Frame) : Bool :=
  !frames.isEmpty && frames.all (fun f => decide
    (f ∈ issued ∧ f.binding = binding ∧ binding.origin.phase = owner ∧
     binding.origin.dependencies = [] ∧ f.domain = binding.origin.domain ∧ f.guard = none))

def oldFrameGate (source target : List Frame) : Bool :=
  !source.isEmpty && decide (source.length = target.length)

theorem every_frame_authenticated (issued : List Frame) (owner : Nat) (binding : Binding)
    (frames : List Frame) (h : carrierFrames issued owner binding frames = true) :
    frames ≠ [] ∧ ∀ f ∈ frames, f ∈ issued ∧ f.binding = binding ∧
      binding.origin.phase = owner ∧ binding.origin.dependencies = [] ∧
      f.domain = binding.origin.domain ∧ f.guard = none := by
  simpa [carrierFrames, List.all_eq_true] using h

def guardMeaning (meaning : PaidSlotGuardReplay.Node → Prop) (f : Frame) : Prop :=
  match f.guard with
  | none => True
  | some guard => meaning guard

theorem carriers_add_no_guard (issued : List Frame) (owner : Nat) (binding : Binding)
    (frames : List Frame) (h : carrierFrames issued owner binding frames = true)
    (meaning : PaidSlotGuardReplay.Node → Prop) (body : Prop) :
    ((∀ f ∈ frames, guardMeaning meaning f) → body) ↔ body := by
  have all : ∀ f ∈ frames, guardMeaning meaning f := by
    intro f member
    rw [guardMeaning, (every_frame_authenticated issued owner binding frames h).2 f member |>.2.2.2.2.2]
    trivial
  exact ⟨fun h => h all, fun h _ => h⟩

def carrierSlot (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (sourceIssued targetIssued sourceFrames targetFrames : List Frame)
    (action : Nat) (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) :=
  if carrierFrames sourceIssued p.sourcePhase before.binding sourceFrames &&
      carrierFrames targetIssued p.targetPhase after.binding targetFrames then
    typedSlotTransport tuple left right p action sourceUses targetUses before after
  else none

theorem carrier_slot_exact (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (si ti sf tf : List Frame) (action : Nat) (su tu : List MatrixUse)
    (before after : MatrixUse) (route : TypedRoute)
    (h : carrierSlot tuple left right p si ti sf tf action su tu before after = some route) :
    carrierFrames si p.sourcePhase before.binding sf = true ∧
    carrierFrames ti p.targetPhase after.binding tf = true ∧
    typedSlotTransport tuple left right p action su tu before after = some route := by
  unfold carrierSlot at h
  split at h
  next good =>
    simp only [Bool.and_eq_true] at good
    exact ⟨good.1, good.2, h⟩
  next => cases h

theorem carrier_slot_typed_read (tuple : Binding → List String)
    (left right : SelectedSlotTransport.Endpoint) (p : OwnerProgram)
    (si ti sf tf : List Frame) (action : Nat) (su tu : List MatrixUse)
    (before after : MatrixUse) (route : TypedRoute)
    (h : carrierSlot tuple left right p si ti sf tf action su tu before after = some route)
    (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead route before.binding).map (typedRead Value valuation) =
      some ⟨after.binding.origin.exactType, valuation after.binding⟩ ∧
    p.candidate.actions[action]? = some route.action ∧ route.action.cost = 1 := by
  have sound := typed_transport_sound tuple left right p action su tu before after route
    (carrier_slot_exact tuple left right p si ti sf tf action su tu before after route h).2.2 Value valuation
  exact ⟨sound.1, sound.2.1, sound.2.2.2.1⟩

theorem unissued_frame_rejected (issued : List Frame) (owner : Nat) (binding : Binding)
    (frames : List Frame) (f : Frame) (member : f ∈ frames) (absent : f ∉ issued) :
    carrierFrames issued owner binding frames = false := by
  apply Bool.eq_false_iff.mpr
  intro h
  exact absent ((every_frame_authenticated issued owner binding frames h).2 f member).1

theorem explicit_guard_not_carrier (issued : List Frame) (owner : Nat) (binding : Binding)
    (frames : List Frame) (f : Frame) (member : f ∈ frames) (present : f.guard ≠ none) :
    carrierFrames issued owner binding frames = false := by
  apply Bool.eq_false_iff.mpr
  intro h
  exact present ((every_frame_authenticated issued owner binding frames h).2 f member).2.2.2.2.2

theorem unequal_count_old_rejected (source target : List Frame) (h : source.length ≠ target.length) :
    oldFrameGate source target = false := by simp [oldFrameGate, h]

-- Preference is among actually attaining equal-cost candidates, not a scalar repair.
def preferLinked (oldCost newCost : Nat) (oldLinked newLinked : Bool) : Bool :=
  decide (newCost < oldCost) || (decide (newCost = oldCost) && !oldLinked && newLinked)

theorem equal_preference_has_link (oldCost newCost : Nat) (oldLinked newLinked : Bool)
    (notLower : ¬ newCost < oldCost) (h : preferLinked oldCost newCost oldLinked newLinked = true) :
    newCost = oldCost ∧ oldLinked = false ∧ newLinked = true := by
  simpa [preferLinked, notLower, and_assoc] using h

end CarrierFrameMultiplicity
