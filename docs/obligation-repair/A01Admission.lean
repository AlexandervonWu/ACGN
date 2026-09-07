namespace ACGN.ObligationRepair

/- These constructors denote evidence available to the current Java gate.
   None supplies a checked semantic reconstruction of the parent contracts.
   No predicate here asserts that all scoped requirements are decomposed. -/
inductive AvailableDecomposition where
  | absent
  | uncheckedRegistry
  deriving DecidableEq

inductive Diagnostic where
  | missingRegistry
  | uncheckedReconstruction
  deriving DecidableEq

def assessDecomposition : AvailableDecomposition → Option Diagnostic
  | .absent => some .missingRegistry
  | .uncheckedRegistry => some .uncheckedReconstruction

theorem missing_registry_is_rejected :
    assessDecomposition .absent = some .missingRegistry := rfl

theorem unchecked_registry_is_rejected :
    assessDecomposition .uncheckedRegistry = some .uncheckedReconstruction := rfl

theorem available_evidence_cannot_discharge_decomposition
    (evidence : AvailableDecomposition) : assessDecomposition evidence ≠ none := by
  cases evidence <;> simp [assessDecomposition]

def requirementReady (evidence : AvailableDecomposition) (labelsReady : Bool) : Bool :=
  labelsReady && (assessDecomposition evidence).isNone

theorem ready_labels_cannot_replace_missing_evidence
    (evidence : AvailableDecomposition) (labelsReady : Bool) :
    requirementReady evidence labelsReady = false := by
  cases evidence <;> simp [requirementReady, assessDecomposition]

end ACGN.ObligationRepair

#print axioms ACGN.ObligationRepair.missing_registry_is_rejected
#print axioms ACGN.ObligationRepair.unchecked_registry_is_rejected
#print axioms ACGN.ObligationRepair.available_evidence_cannot_discharge_decomposition
#print axioms ACGN.ObligationRepair.ready_labels_cannot_replace_missing_evidence
