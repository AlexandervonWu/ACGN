import Std

/- Operational mode separation only; this is not a semantic certificate. -/
namespace DiagnosticScanMode

inductive Mode where
  | certified
  | diagnostic
  deriving DecidableEq

def stop (mode : Mode) (sameComponents replayAvailable : Bool) : Bool :=
  !sameComponents || (mode == .certified && !replayAvailable)

def grantsCertification (_ : Mode) : Bool := false

theorem mismatch_stops (mode : Mode) (replay : Bool) : stop mode false replay = true := by
  simp [stop]

theorem strict_missing_replay_stops : stop .certified true false = true := by
  decide

theorem diagnostic_equality_can_continue : stop .diagnostic true false = false := by
  decide

theorem diagnostic_is_not_certification : grantsCertification .diagnostic = false := rfl

#print axioms mismatch_stops
#print axioms strict_missing_replay_stops
#print axioms diagnostic_equality_can_continue
#print axioms diagnostic_is_not_certification
end DiagnosticScanMode
