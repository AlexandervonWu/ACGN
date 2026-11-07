import Std

/- First-incident state contract, not a proof of Java concurrency or IO. Native
   diagnostic completion cannot authorize a public replay or clear a stop. -/
namespace IncidentReplay

structure State where
  first : Option Nat
  diagnostics : Option Nat
  deriving DecidableEq

def latch (s : State) (incident : Nat) : State :=
  match s.first with
  | some _ => s
  | none => { s with first := some incident }

def attach (s : State) (receipt : Option Nat) : State :=
  { s with diagnostics := receipt }

def mayDispatch (s : State) : Prop := s.first = none

theorem first_preserved (s : State) (first later : Nat)
    (h : s.first = some first) : (latch s later).first = some first := by
  simp [latch, h]

theorem latched_before_diagnostics (s : State) (incident : Nat)
    (h : s.first = none) : ¬ mayDispatch (latch s incident) := by
  simp [mayDispatch, latch, h]

theorem diagnostics_cannot_resume (s : State) (receipt : Option Nat)
    (h : ¬ mayDispatch s) : ¬ mayDispatch (attach s receipt) := h

theorem failed_diagnostics_keeps_incident (s : State) :
    (attach s none).first = s.first := rfl

#print axioms first_preserved
#print axioms latched_before_diagnostics
#print axioms diagnostics_cannot_resume
#print axioms failed_diagnostics_keeps_incident
end IncidentReplay
