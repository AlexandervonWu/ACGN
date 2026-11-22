import Phase5SourceRules
import TemporalPhaseLocalBinding

namespace ImportedSingleUseBinding

def oldNeedsOwner (uses : List Nat) : Bool := decide (uses.length > 1)
def needsOwner (owner : Nat) (uses : List Nat) : Bool :=
  oldNeedsOwner uses || !uses.contains owner

theorem imported_single_use_checked (owner use : Nat) (imported : use ≠ owner) :
    needsOwner owner [use] = true := by
  simp [needsOwner, oldNeedsOwner, Ne.symm imported]

theorem old_single_use_unchecked (use : Nat) : oldNeedsOwner [use] = false := by
  simp [oldNeedsOwner]

theorem retained_old_owner_checks (owner : Nat) (uses : List Nat)
    (old : oldNeedsOwner uses = true) : needsOwner owner uses = true := by
  simp [needsOwner, old]

theorem local_route_has_no_import (owner use : Nat) (uses : List Nat)
    (present : use ∈ uses) (localRoute : needsOwner owner uses = false) : use = owner := by
  cases uses with
  | nil => simp at present
  | cons first rest =>
    cases rest with
    | nil => simp_all [needsOwner, oldNeedsOwner]
    | cons second tail => simp [needsOwner, oldNeedsOwner] at localRoute

/- The existing import semantics require the exact lexical origin, independent
   of the number of matrices that happen to read it. No new phase limit. -/
theorem exact_import_survives_single_use
    (origin : TemporalPhaseLocalBinding.BinderOrigin)
    (role : TemporalPhaseLocalBinding.TemporalPhaseRole) :
    TemporalPhaseLocalBinding.admits origin
      (TemporalPhaseLocalBinding.importInto origin role) = true := by
  simp [TemporalPhaseLocalBinding.admits, TemporalPhaseLocalBinding.importInto]

theorem foreign_owner_not_a_free_import
    (origin foreign : TemporalPhaseLocalBinding.BinderOrigin)
    (role : TemporalPhaseLocalBinding.TemporalPhaseRole)
    (different : origin.ownerPhase ≠ foreign.ownerPhase) :
    TemporalPhaseLocalBinding.admits origin
      (TemporalPhaseLocalBinding.importInto foreign role) = false := by
  have unequal : origin ≠ foreign := fun same => different (congrArg (fun x => x.ownerPhase) same)
  simp [TemporalPhaseLocalBinding.admits, TemporalPhaseLocalBinding.importInto, unequal]

/- Exact inv12/inv12c source shapes. The mutable carrier is observed at the
   binder's owner, not at its later matrix use. The formulas are not equivalent. -/
def rootBound (File : Type) (existsAt trash : Nat → File → Prop) (now : Nat) : Prop :=
  ∃ file, existsAt now file ∧
    futureEventually (fun instant => futureAlways (fun next => trash next file) instant) now

def temporalBound (File : Type) (existsAt trash : Nat → File → Prop) (now : Nat) : Prop :=
  futureEventually (fun instant => ∃ file, existsAt instant file ∧
    futureAlways (fun next => trash next file) instant) now

def appearingFile (time : Nat) (_ : Bool) : Prop := 0 < time

theorem natural_source_owner_counterexample :
    ¬ rootBound Bool appearingFile appearingFile 0 ∧
    temporalBound Bool appearingFile appearingFile 0 := by
  constructor
  · simp [rootBound, appearingFile]
  · refine ⟨1, by decide, true, by change 0 < 1; decide, ?_⟩
    intro next afterOne
    exact Nat.lt_of_lt_of_le (by decide : 0 < 1) afterOne

theorem natural_owner_relocation_not_equivalence :
    ¬ (rootBound Bool appearingFile appearingFile 0 ↔
       temporalBound Bool appearingFile appearingFile 0) := by
  intro same
  exact natural_source_owner_counterexample.1 (same.mpr natural_source_owner_counterexample.2)

#print axioms imported_single_use_checked
#print axioms local_route_has_no_import
#print axioms exact_import_survives_single_use
#print axioms foreign_owner_not_a_free_import
#print axioms natural_source_owner_counterexample
end ImportedSingleUseBinding
