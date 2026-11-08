import Std

/- Finite diagnostic gate model only. Endpoint admission, extraction and the
   independent replayers remain separate Java obligations, not axioms discharged
   by this theorem. No diagnostic outcome grants public certification. -/
namespace NativeOperationGate
inductive Status | matched | mismatch | uncheckable | invalidReplay | extractionFailure
  deriving DecidableEq

def compare (supported valid : Bool) (left right : List Nat) : Status :=
  if !supported then .uncheckable else if !valid then .invalidReplay
  else if left = right then .matched else .mismatch

def stop : Status → Bool
  | .mismatch | .invalidReplay | .uncheckable | .extractionFailure => true
  | _ => false

theorem unsupported_never_matched (valid : Bool) (a b : List Nat) :
    compare false valid a b = .uncheckable := by simp [compare]
theorem missing_correspondence_stops (valid : Bool) (a b : List Nat) :
    stop (compare false valid a b) = true := by simp [compare, stop]
theorem invalid_stops (a b : List Nat) : stop (compare true false a b) = true := by
  simp [compare, stop]
theorem extraction_failure_stops : stop .extractionFailure = true := rfl
theorem checked_equal_continues (a : List Nat) :
    compare true true a a = .matched ∧ stop (compare true true a a) = false := by
  simp [compare, stop]
theorem checked_different_stops (a b : List Nat) (different : a ≠ b) :
    compare true true a b = .mismatch ∧ stop (compare true true a b) = true := by
  simp [compare, different, stop]
theorem equal_total_not_sequence :
    ([0, 1] : List Nat).sum = ([1, 0] : List Nat).sum ∧
    compare true true [0, 1] [1, 0] = .mismatch := by decide

def latch {Incident : Type} (first : Option Incident) (next : Incident) : Option Incident :=
  match first with | some x => some x | none => some next
theorem first_immutable {Incident : Type} (first next : Incident) :
    latch (some first) next = some first := rfl

def certificateGranted (_ : Status) := false
theorem no_diagnostic_certification (status : Status) : certificateGranted status = false := rfl

#print axioms unsupported_never_matched
#print axioms missing_correspondence_stops
#print axioms invalid_stops
#print axioms extraction_failure_stops
#print axioms checked_equal_continues
#print axioms checked_different_stops
#print axioms equal_total_not_sequence
#print axioms first_immutable
#print axioms no_diagnostic_certification
end NativeOperationGate
