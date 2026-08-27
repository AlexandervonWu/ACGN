/-
  Cross-phase proof obligations for the Section 3 repair.

  This file models the trust boundary independently of Java certificates.  It
  deliberately gives a certificate no authority of its own: authority comes
  from a fixed theory lookup and from an externally supplied expected index.
-/

namespace Section3.CrossPhase

inductive Quotient where
  | seq
  | bag
  | set
  deriving DecidableEq, Repr

inductive Law where
  | commutative
  | idempotent
  | associative
  | unit
  deriving DecidableEq, Repr

structure SemanticProfile where
  bitwidth : Nat
  overflowForbidding : Bool
  temporalMode : Nat
  rewriteMode : Nat
  signatureVersion : Nat
  deriving DecidableEq, Repr

structure EvidenceIndex where
  profile : SemanticProfile
  operator : Nat
  schemaPath : List Nat
  carrier : Nat
  admittedArities : List Nat
  lawParameter : List Nat
  sourceEndpoint : Nat
  targetEndpoint : Nat
  deriving DecidableEq, Repr

structure FixedTheory where
  digest : Nat
  lookup : EvidenceIndex -> Option Law

structure Certificate where
  index : EvidenceIndex
  law : Law
  claimedTheoryDigest : Nat
  encodedSource : Nat
  encodedTarget : Nat
  deriving DecidableEq, Repr

def CertificateAccepted (theory : FixedTheory) (certificate : Certificate) : Prop :=
  certificate.claimedTheoryDigest = theory.digest /\
  theory.lookup certificate.index = some certificate.law /\
  certificate.encodedSource = certificate.index.sourceEndpoint /\
  certificate.encodedTarget = certificate.index.targetEndpoint

def CertificateAcceptedAt
    (theory : FixedTheory)
    (expected : EvidenceIndex)
    (certificate : Certificate) : Prop :=
  certificate.index = expected /\ CertificateAccepted theory certificate

theorem accepted_authority_is_fixed_theory_authority
    (theory : FixedTheory)
    (certificate : Certificate)
    (accepted : CertificateAccepted theory certificate) :
    theory.lookup certificate.index = some certificate.law := by
  exact accepted.2.1

theorem label_without_fixed_authority_rejects
    (theory : FixedTheory)
    (certificate : Certificate)
    (missing : theory.lookup certificate.index = none) :
    Not (CertificateAccepted theory certificate) := by
  intro accepted
  rcases accepted with ⟨_, lawAuthority, _, _⟩
  rw [missing] at lawAuthority
  cases lawAuthority

theorem accepted_at_retains_the_complete_index
    (theory : FixedTheory)
    (expected : EvidenceIndex)
    (certificate : Certificate)
    (accepted : CertificateAcceptedAt theory expected certificate) :
    certificate.index.profile = expected.profile /\
    certificate.index.operator = expected.operator /\
    certificate.index.schemaPath = expected.schemaPath /\
    certificate.index.carrier = expected.carrier /\
    certificate.index.admittedArities = expected.admittedArities /\
    certificate.index.lawParameter = expected.lawParameter /\
    certificate.index.sourceEndpoint = expected.sourceEndpoint /\
    certificate.index.targetEndpoint = expected.targetEndpoint := by
  rw [accepted.1]
  simp

theorem any_index_mutation_rejects_replay
    (theory : FixedTheory)
    (expected : EvidenceIndex)
    (certificate : Certificate)
    (changed : certificate.index ≠ expected) :
    Not (CertificateAcceptedAt theory expected certificate) := by
  intro accepted
  exact changed accepted.1

theorem wrong_theory_digest_rejects
    (theory : FixedTheory)
    (certificate : Certificate)
    (changed : certificate.claimedTheoryDigest ≠ theory.digest) :
    Not (CertificateAccepted theory certificate) := by
  intro accepted
  exact changed accepted.1

theorem wrong_source_endpoint_rejects
    (theory : FixedTheory)
    (certificate : Certificate)
    (changed : certificate.encodedSource ≠ certificate.index.sourceEndpoint) :
    Not (CertificateAccepted theory certificate) := by
  intro accepted
  exact changed accepted.2.2.1

theorem wrong_target_endpoint_rejects
    (theory : FixedTheory)
    (certificate : Certificate)
    (changed : certificate.encodedTarget ≠ certificate.index.targetEndpoint) :
    Not (CertificateAccepted theory certificate) := by
  intro accepted
  exact changed accepted.2.2.2

structure PortPolicy where
  arityPolicy : Nat
  siblingQuotient : Quotient
  flatLicense : Option Nat
  unitLicense : Option Nat
  deriving DecidableEq, Repr

theorem policy_fields_are_independently_observable
    (left right : PortPolicy)
    (different : left ≠ right) :
    left.arityPolicy ≠ right.arityPolicy \/
    left.siblingQuotient ≠ right.siblingQuotient \/
    left.flatLicense ≠ right.flatLicense \/
    left.unitLicense ≠ right.unitLicense := by
  by_cases arity : left.arityPolicy = right.arityPolicy
  · by_cases quotient : left.siblingQuotient = right.siblingQuotient
    · by_cases flat : left.flatLicense = right.flatLicense
      · by_cases unit : left.unitLicense = right.unitLicense
        · apply False.elim
          apply different
          cases left
          cases right
          simp_all
        · exact Or.inr (Or.inr (Or.inr unit))
      · exact Or.inr (Or.inr (Or.inl flat))
    · exact Or.inr (Or.inl quotient)
  · exact Or.inl arity

structure SourceOccurrence where
  path : List Nat
  typedSource : Nat
  sourceContent : Nat
  deriving DecidableEq, Repr

structure OccurrenceBinding where
  occurrence : SourceOccurrence
  certificateSource : SourceOccurrence
  transferLineage : Nat
  currentLineage : Nat
  deriving DecidableEq, Repr

def BindingAccepted (binding : OccurrenceBinding) : Prop :=
  binding.occurrence = binding.certificateSource /\
  binding.transferLineage = binding.currentLineage

theorem accepted_binding_preserves_exact_occurrence
    (binding : OccurrenceBinding)
    (accepted : BindingAccepted binding) :
    binding.occurrence.path = binding.certificateSource.path /\
    binding.occurrence.typedSource = binding.certificateSource.typedSource /\
    binding.occurrence.sourceContent = binding.certificateSource.sourceContent := by
  rw [accepted.1]
  simp

theorem occurrence_substitution_rejects
    (binding : OccurrenceBinding)
    (changed : binding.occurrence ≠ binding.certificateSource) :
    Not (BindingAccepted binding) := by
  intro accepted
  exact changed accepted.1

theorem lineage_substitution_rejects
    (binding : OccurrenceBinding)
    (changed : binding.transferLineage ≠ binding.currentLineage) :
    Not (BindingAccepted binding) := by
  intro accepted
  exact changed accepted.2

/-
  The next definitions isolate the zero-kernel property of a repair metric.
  They do not assume tree distance.  `admissible` is the certified quotient
  relation and `atomicCost` is any separating source-level edit cost.
-/

def checkedQuotientRepairDistance
    {Observation : Type}
    (atomicCost : Observation -> Observation -> Nat)
    (admissible : Observation -> Observation -> Bool)
    (left right : Observation) : Option Nat :=
  let cost := atomicCost left right
  if admissible left right = (cost = 0) then some cost else none

theorem certified_equality_has_zero_distance
    {Observation : Type}
    (atomicCost : Observation -> Observation -> Nat)
    (admissible : Observation -> Observation -> Bool)
    (left right : Observation)
    (certified : admissible left right = true)
    (zeroCost : atomicCost left right = 0) :
    checkedQuotientRepairDistance atomicCost admissible left right = some 0 := by
  simp [checkedQuotientRepairDistance, certified, zeroCost]

theorem zero_distance_has_certified_equality
    {Observation : Type}
    (atomicCost : Observation -> Observation -> Nat)
    (admissible : Observation -> Observation -> Bool)
    (left right : Observation)
    (zero : checkedQuotientRepairDistance atomicCost admissible left right = some 0) :
    admissible left right = true := by
  simp [checkedQuotientRepairDistance] at zero
  exact zero.1.mpr zero.2

theorem certified_nonzero_disagreement_rejects
    {Observation : Type}
    (atomicCost : Observation -> Observation -> Nat)
    (admissible : Observation -> Observation -> Bool)
    (left right : Observation)
    (certified : admissible left right = true)
    (nonzero : atomicCost left right ≠ 0) :
    checkedQuotientRepairDistance atomicCost admissible left right = none := by
  simp [checkedQuotientRepairDistance, certified, nonzero]

theorem uncertified_zero_disagreement_rejects
    {Observation : Type}
    (atomicCost : Observation -> Observation -> Nat)
    (admissible : Observation -> Observation -> Bool)
    (left right : Observation)
    (uncertified : admissible left right = false)
    (zero : atomicCost left right = 0) :
    checkedQuotientRepairDistance atomicCost admissible left right = none := by
  simp [checkedQuotientRepairDistance, uncertified, zero]

/- Unsupported cases have no fixed-theory entry and therefore no authority. -/

def unsupportedTheory : FixedTheory := {
  digest := 0
  lookup := fun _ => none
}

theorem unsupported_cases_cannot_receive_law_authority
    (certificate : Certificate) :
    Not (CertificateAccepted unsupportedTheory certificate) := by
  exact label_without_fixed_authority_rejects unsupportedTheory certificate rfl

end Section3.CrossPhase
