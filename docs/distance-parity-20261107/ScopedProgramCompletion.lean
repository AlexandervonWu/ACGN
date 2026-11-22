import AuthenticatedPhaseTransport
import PhaseOwnedJointWitnesses
import SelectedProgramCompletion

/- Supplemental declaration links do not create temporal payments or change
   selected actions. Object identity and original phase ownership are checked
   before a link enters a phase context. Java supplies live reference identity;
   a matching serialized Binding alone cannot discharge this check. -/
namespace ScopedProgramCompletion
open AuthenticatedPhaseTransport PhaseOwnedJointRoutes
open Focused225SharedContracts Focused225Concrete
open SelectedDeclarationCompletion

abbrev Ref (I : Type) := Original I Focused225SharedContracts.Binding

def resolve [DecidableEq I] (originals : List (Ref I)) (scopes : List Scope)
    (phase : Nat) (claimed : Ref I) : Option (Ref I) :=
  if (originals.map Original.object).Nodup ∧ claimed ∈ originals ∧
      resolveBinding scopes phase claimed.data = some claimed.data then
    some claimed
  else none

theorem resolved_original [DecidableEq I] (originals : List (Ref I))
    (scopes : List Scope) (phase : Nat) (claimed actual : Ref I)
    (checked : resolve originals scopes phase claimed = some actual) :
    actual = claimed ∧ actual ∈ originals ∧
      resolveBinding scopes phase actual.data = some actual.data := by
  unfold resolve at checked
  split at checked
  next good =>
    have same : actual = claimed := (Option.some.inj checked).symm
    subst actual
    exact ⟨rfl, good.2.1, good.2.2⟩
  next => cases checked

theorem foreign_object_rejected [DecidableEq I] (originals : List (Ref I))
    (scopes : List Scope) (phase : Nat) (claimed : Ref I)
    (foreign : ∀ original ∈ originals, original.object ≠ claimed.object) :
    resolve originals scopes phase claimed = none := by
  have absent : claimed ∉ originals := by
    intro member
    exact foreign claimed member rfl
  simp [resolve, absent]

def contextLink [DecidableEq I] [DecidableEq J]
    (source : List (Ref I)) (target : List (Ref J))
    (sourceScopes targetScopes : List Scope) (phase : Nat)
    (before : Ref I) (after : Ref J) : Bool :=
  decide (resolve source sourceScopes phase before = some before ∧
    resolve target targetScopes phase after = some after)

theorem checked_context_originals [DecidableEq I] [DecidableEq J]
    (source : List (Ref I)) (target : List (Ref J))
    (sourceScopes targetScopes : List Scope) (phase : Nat)
    (before : Ref I) (after : Ref J)
    (checked : contextLink source target sourceScopes targetScopes phase before after = true) :
    before ∈ source ∧ after ∈ target ∧
      resolveBinding sourceScopes phase before.data = some before.data ∧
      resolveBinding targetScopes phase after.data = some after.data := by
  unfold contextLink at checked
  have h := of_decide_eq_true checked
  have a := resolved_original source sourceScopes phase before before h.1
  have b := resolved_original target targetScopes phase after after h.2
  exact ⟨a.2.1, b.2.1, a.2.2, b.2.2⟩

theorem checked_context_and_execution [DecidableEq I] [DecidableEq J]
    (source : List (Ref I)) (target : List (Ref J))
    (sourceScopes targetScopes : List Scope) (phase : Nat)
    (before : Ref I) (after : Ref J)
    (contextChecked : contextLink source target sourceScopes targetScopes phase before after = true)
    (actions : List Action) (oldMap newMap : Mapping)
    (chargesChecked : SelectedProgramCompletion.unchangedCharges actions oldMap newMap = true)
    (step : State → (Action × Nat) → State) (initial : State) :
    before ∈ source ∧ after ∈ target ∧
      resolveBinding sourceScopes phase before.data = some before.data ∧
      resolveBinding targetScopes phase after.data = some after.data ∧
      (annotated actions oldMap).foldl step initial =
        (annotated actions newMap).foldl step initial := by
  obtain ⟨a,b,c,d⟩ := checked_context_originals source target sourceScopes targetScopes phase before after contextChecked
  refine ⟨a,b,c,d,?_⟩
  rw [SelectedProgramCompletion.checked_program_unchanged actions oldMap newMap chargesChecked]

/- Reuse the source-linked event154 binding and phase witnesses. These token
   indices distinguish original objects; their live Java correspondence is an
   explicit validation obligation, not a claim from compilation. -/
open PhaseOwnedJointWitnesses
def natural0 : Ref Nat := ⟨0,event154_0_source0⟩
def natural1 : Ref Nat := ⟨1,event154_0_source1⟩
def originals : List (Ref Nat) := [natural0,natural1]

theorem original_owner : resolve originals event154_0_sourceScopes 0 natural0 = some natural0 := by
  simp [resolve, originals, natural0, natural1, event154_0_source0_owner]

theorem original_import : resolve originals event154_0_sourceScopes 1 natural0 = some natural0 := by
  simp [resolve, originals, natural0, natural1, event154_0_source0_import]

theorem same_metadata_foreign_object :
    resolve originals event154_0_sourceScopes 1 ⟨99,event154_0_source0⟩ = none := by
  apply foreign_object_rejected
  simp [originals, natural0, natural1]

theorem changed_owner_is_not_import :
    resolve originals event154_0_sourceScopes 1
      ⟨0,{event154_0_source0 with origin := {event154_0_source0.origin with phase := 1}}⟩ = none := by
  simp only [resolve, event154_0_source0_no_rebinding]
  simp

theorem duplicate_object_inventory_rejected (scopes : List Scope) (phase : Nat) :
    resolve [natural0,natural0] scopes phase natural0 = none := by
  simp [resolve]

end ScopedProgramCompletion
