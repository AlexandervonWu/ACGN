import Std

/- Generated domain-membership occurrences use the original binding but a new
   occurrence identity. Neither a paid edit nor this transport removes the
   domain guard or equates distinct source slots. Java correspondence is not
   established by these model laws. -/
namespace DomainVariableEvidence
structure Binding where
  moduleId : Nat
  owner : Nat
  slot : Nat
  literalType : Nat
  deriving DecidableEq
structure Occurrence where
  binding : Binding
  lineage : Nat
  authenticated : Bool
  deriving DecidableEq

def derive (expected : Binding) (source : Occurrence) (fresh : Nat) : Option Occurrence :=
  if source.binding = expected ∧ source.authenticated = true ∧ fresh ≠ source.lineage
  then some ⟨source.binding, fresh, true⟩ else none

theorem exact_source_binding (b : Binding) (s out : Occurrence) (fresh : Nat)
    (h : derive b s fresh = some out) :
    s.binding = b ∧ s.authenticated = true ∧ out.binding = s.binding ∧
      out.lineage = fresh ∧ out.lineage ≠ s.lineage := by
  unfold derive at h
  split at h
  · rename_i premises
    have eq := Option.some.inj h
    subst out
    exact ⟨premises.1, premises.2.1, rfl, rfl, premises.2.2⟩
  · contradiction

theorem foreign_binding_rejected (b : Binding) (s : Occurrence) (fresh : Nat)
    (foreign : s.binding ≠ b) : derive b s fresh = none := by simp [derive, foreign]

theorem unauthenticated_rejected (b : Binding) (s : Occurrence) (fresh : Nat)
    (missing : s.authenticated = false) : derive b s fresh = none := by simp [derive, missing]

theorem reused_lineage_rejected (b : Binding) (s : Occurrence) :
    derive b s s.lineage = none := by simp [derive]

-- Both fresh occurrences read precisely the same original binder valuation.
def value (env : Binding → A) (o : Occurrence) : A := env o.binding
theorem membership_preserved (env : Binding → A) (domain : A → Prop)
    (b : Binding) (s out : Occurrence) (fresh : Nat)
    (h : derive b s fresh = some out) :
    domain (value env out) ↔ domain (value env s) := by
  have same := (exact_source_binding b s out fresh h).2.2.1
  simp [value, same]

theorem guarded_all_preserved (d d' p : A → Prop) (same : ∀ x, d' x ↔ d x) :
    (∀ x, d' x → p x) ↔ (∀ x, d x → p x) := by
  constructor
  · intro h x hx; exact h x ((same x).mpr hx)
  · intro h x hx; exact h x ((same x).mp hx)

theorem guarded_some_preserved (d d' p : A → Prop) (same : ∀ x, d' x ↔ d x) :
    (∃ x, d' x ∧ p x) ↔ (∃ x, d x ∧ p x) := by
  constructor
  · rintro ⟨x,hx,hp⟩; exact ⟨x,(same x).mp hx,hp⟩
  · rintro ⟨x,hx,hp⟩; exact ⟨x,(same x).mpr hx,hp⟩

#print axioms exact_source_binding
#print axioms foreign_binding_rejected
#print axioms unauthenticated_rejected
#print axioms reused_lineage_rejected
#print axioms membership_preserved
#print axioms guarded_all_preserved
#print axioms guarded_some_preserved
end DomainVariableEvidence
