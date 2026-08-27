namespace AssuranceTraceability

structure RequirementEvidence where
  lowLevelCount : Nat
  lowLevelsAtomic : Bool
  codeMapped : Bool
  unsupportedFailClosed : Bool
  nominalTest : Bool
  boundaryTest : Bool
  robustnessTest : Bool
  expectedResultsExplicit : Bool
  leanCompiled : Bool
  explicitAssumptions : Bool
  admissionFree : Bool
  needsDirectConformance : Bool
  directConformance : Bool
  statementCoverageComplete : Bool
  decisionCoverageComplete : Bool
  semanticMcdcRequired : Bool
  semanticMcdcComplete : Bool
  coverageDisposition : Bool
  coverageDispositionIndependent : Bool
  couplingPositive : Bool
  couplingNegative : Bool

structure RunEvidence where
  requirements : List RequirementEvidence
  timeBounded : Bool
  heapBounded : Bool
  inputBounded : Bool
  combinatoricsBounded : Bool
  exhaustionFailsClosed : Bool
  freshProcessCount : Nat
  inputsByteIdentical : Bool
  configurationsIdentical : Bool
  outputsByteIdentical : Bool
  manifestCanonical : Bool
  manifestSourcesComplete : Bool
  manifestDependenciesComplete : Bool
  manifestToolchainComplete : Bool
  manifestOptionsComplete : Bool
  manifestEvidenceComplete : Bool
  manifestHashesVerified : Bool
  openScopedFaults : Nat
  phaseReviewsComplete : Bool
  integratedReviewComplete : Bool
  oneManifestForReviews : Bool
  reviewsFresh : Bool
  reviewsIndependent : Bool

def requirementsDecomposed (run : RunEvidence) : Prop :=
  ∀ requirement ∈ run.requirements,
    0 < requirement.lowLevelCount ∧ requirement.lowLevelsAtomic = true

def codeOrUnsupportedMapped (run : RunEvidence) : Prop :=
  ∀ requirement ∈ run.requirements,
    requirement.codeMapped = true ∨ requirement.unsupportedFailClosed = true

def threeTestClasses (run : RunEvidence) : Prop :=
  ∀ requirement ∈ run.requirements,
    requirement.nominalTest = true ∧
      requirement.boundaryTest = true ∧
      requirement.robustnessTest = true ∧
      requirement.expectedResultsExplicit = true

def formalEvidence (run : RunEvidence) : Prop :=
  ∀ requirement ∈ run.requirements,
    requirement.leanCompiled = true ∧
      requirement.explicitAssumptions = true ∧
      requirement.admissionFree = true

def directConformance (run : RunEvidence) : Prop :=
  ∀ requirement ∈ run.requirements,
    requirement.needsDirectConformance = true →
      requirement.directConformance = true

def coverageOrDisposition (run : RunEvidence) : Prop :=
  ∀ requirement ∈ run.requirements,
    (requirement.statementCoverageComplete = true ∧
      requirement.decisionCoverageComplete = true ∧
      (requirement.semanticMcdcRequired = false ∨
        requirement.semanticMcdcComplete = true)) ∨
    (requirement.coverageDisposition = true ∧
      requirement.coverageDispositionIndependent = true)

def couplingEvidence (run : RunEvidence) : Prop :=
  ∀ requirement ∈ run.requirements,
    requirement.couplingPositive = true ∧ requirement.couplingNegative = true

def resourceBounds (run : RunEvidence) : Prop :=
  run.timeBounded = true ∧
    run.heapBounded = true ∧
    run.inputBounded = true ∧
    run.combinatoricsBounded = true ∧
    run.exhaustionFailsClosed = true

def determinismEvidence (run : RunEvidence) : Prop :=
  2 ≤ run.freshProcessCount ∧
    run.inputsByteIdentical = true ∧
    run.configurationsIdentical = true ∧
    run.outputsByteIdentical = true

def manifestComplete (run : RunEvidence) : Prop :=
  run.manifestCanonical = true ∧
    run.manifestSourcesComplete = true ∧
    run.manifestDependenciesComplete = true ∧
    run.manifestToolchainComplete = true ∧
    run.manifestOptionsComplete = true ∧
    run.manifestEvidenceComplete = true ∧
    run.manifestHashesVerified = true

def noOpenFaults (run : RunEvidence) : Prop := run.openScopedFaults = 0

def independentReviews (run : RunEvidence) : Prop :=
  run.phaseReviewsComplete = true ∧
    run.integratedReviewComplete = true ∧
    run.oneManifestForReviews = true ∧
    run.reviewsFresh = true ∧
    run.reviewsIndependent = true

def GatePass (run : RunEvidence) : Prop :=
  requirementsDecomposed run ∧
    codeOrUnsupportedMapped run ∧
    threeTestClasses run ∧
    formalEvidence run ∧
    directConformance run ∧
    coverageOrDisposition run ∧
    couplingEvidence run ∧
    resourceBounds run ∧
    determinismEvidence run ∧
    manifestComplete run ∧
    noOpenFaults run ∧
    independentReviews run

theorem pass_implies_requirements_decomposed {run : RunEvidence}
    (passed : GatePass run) : requirementsDecomposed run := passed.1

theorem pass_implies_code_or_unsupported_mapping {run : RunEvidence}
    (passed : GatePass run) : codeOrUnsupportedMapped run := passed.2.1

theorem pass_implies_three_test_classes {run : RunEvidence}
    (passed : GatePass run) : threeTestClasses run := passed.2.2.1

theorem pass_implies_formal_evidence {run : RunEvidence}
    (passed : GatePass run) : formalEvidence run := passed.2.2.2.1

theorem pass_implies_direct_conformance {run : RunEvidence}
    (passed : GatePass run) : directConformance run := passed.2.2.2.2.1

theorem pass_implies_coverage_or_disposition {run : RunEvidence}
    (passed : GatePass run) : coverageOrDisposition run :=
  passed.2.2.2.2.2.1

theorem pass_implies_coupling_evidence {run : RunEvidence}
    (passed : GatePass run) : couplingEvidence run :=
  passed.2.2.2.2.2.2.1

theorem pass_implies_resource_bounds {run : RunEvidence}
    (passed : GatePass run) : resourceBounds run :=
  passed.2.2.2.2.2.2.2.1

theorem pass_implies_determinism_evidence {run : RunEvidence}
    (passed : GatePass run) : determinismEvidence run :=
  passed.2.2.2.2.2.2.2.2.1

theorem pass_implies_manifest_complete {run : RunEvidence}
    (passed : GatePass run) : manifestComplete run :=
  passed.2.2.2.2.2.2.2.2.2.1

theorem pass_implies_no_open_faults {run : RunEvidence}
    (passed : GatePass run) : noOpenFaults run :=
  passed.2.2.2.2.2.2.2.2.2.2.1

theorem pass_implies_independent_reviews {run : RunEvidence}
    (passed : GatePass run) : independentReviews run :=
  passed.2.2.2.2.2.2.2.2.2.2.2

theorem missing_formal_evidence_blocks
    {run : RunEvidence} {requirement : RequirementEvidence}
    (member : requirement ∈ run.requirements)
    (missing : requirement.leanCompiled = false) : ¬ GatePass run := by
  intro passed
  have proved := (pass_implies_formal_evidence passed) requirement member
  simp [missing] at proved

theorem open_fault_blocks {run : RunEvidence}
    (openFault : 0 < run.openScopedFaults) : ¬ GatePass run := by
  intro passed
  have closed := pass_implies_no_open_faults passed
  simp [noOpenFaults] at closed
  omega

end AssuranceTraceability
