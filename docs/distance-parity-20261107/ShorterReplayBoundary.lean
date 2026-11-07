import Std

/- Diagnostic admission boundary only. No assertion that the Java/source bridge
   or any currently missing public alignment has been established. -/
namespace ShorterReplayBoundary

structure Alignment where
  originalOccurrence : Bool
  leanCorrespondence : Bool
  sourceCertificate : Bool
  selectedRepresentative : Bool
  executableEdits : Bool
  endpointsAndCost : Bool
  scopeAndTemporalOwnership : Bool
  publicSequence : Bool

def complete (a : Alignment) : Bool :=
  a.originalOccurrence && a.leanCorrespondence && a.sourceCertificate &&
  a.selectedRepresentative && a.executableEdits && a.endpointsAndCost &&
  a.scopeAndTemporalOwnership && a.publicSequence

inductive Route where
  | blockedAlignment
  | repairShorter
  | investigateLonger
  deriving DecidableEq

def route (a : Alignment) (replayValid : Bool) : Route :=
  if complete a then
    if replayValid then .investigateLonger else .repairShorter
  else .blockedAlignment

theorem missing_public_blocks (a : Alignment) (h : a.publicSequence = false)
    (replayValid : Bool) : route a replayValid = .blockedAlignment := by
  simp [route, complete, h]

theorem missing_certificate_blocks (a : Alignment) (h : a.sourceCertificate = false)
    (replayValid : Bool) : route a replayValid = .blockedAlignment := by
  simp [route, complete, h]

theorem failed_complete_replay_targets_shorter (a : Alignment)
    (h : complete a = true) : route a false = .repairShorter := by
  simp [route, h]

theorem longer_branch_requires_full_alignment (a : Alignment) (valid : Bool)
    (h : route a valid = .investigateLonger) : complete a = true ∧ valid = true := by
  cases hc : complete a <;> cases valid <;> simp_all [route]

#print axioms missing_public_blocks
#print axioms missing_certificate_blocks
#print axioms failed_complete_replay_targets_shorter
#print axioms longer_branch_requires_full_alignment
end ShorterReplayBoundary
