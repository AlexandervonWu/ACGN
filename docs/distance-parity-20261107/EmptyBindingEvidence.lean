import Std

/- Retaining an authenticated empty type is evidence transport, not a new
   rewrite of the quantified formula or a free link to a nonempty carrier.
   The Java parser/module/occurrence correspondence remains a separate check. -/
namespace EmptyBindingEvidence

structure Source where
  moduleId : Nat
  owner : Nat
  slot : Nat
  arity : Nat
  deriving DecidableEq

structure Evidence where
  source : Source
  authenticated : Bool
  emptyType : Bool
  deriving DecidableEq

def retain (actual expected : Source) (e : Evidence) : Option Evidence :=
  if actual = expected ∧ e.source = actual ∧ e.authenticated = true ∧
      e.emptyType = true ∧ actual.arity = 1 then some e else none

theorem retained_exact (actual expected : Source) (e out : Evidence)
    (h : retain actual expected e = some out) :
    actual = expected ∧ e.source = actual ∧ e.authenticated = true ∧
      e.emptyType = true ∧ actual.arity = 1 ∧ out = e := by
  unfold retain at h
  split at h
  · rename_i premise
    exact ⟨premise.1, premise.2.1, premise.2.2.1, premise.2.2.2.1,
      premise.2.2.2.2, (Option.some.inj h).symm⟩
  · contradiction

theorem authentic_unary_retained (s : Source) (e : Evidence)
    (source : e.source = s) (auth : e.authenticated = true)
    (empty : e.emptyType = true) (unary : s.arity = 1) :
    retain s s e = some e := by simp [retain, source, auth, empty, unary]

theorem foreign_source_rejected (s t : Source) (e : Evidence) (h : s ≠ t) :
    retain s t e = none := by simp [retain, h]

theorem unauthenticated_rejected (s t : Source) (e : Evidence)
    (h : e.authenticated = false) : retain s t e = none := by simp [retain, h]

-- The generated membership guard still uses the actual declared domain.
def guardedAll (d : A → Prop) (p : A → Prop) : Prop := ∀ x, d x → p x
def guardedSome (d : A → Prop) (p : A → Prop) : Prop := ∃ x, d x ∧ p x

theorem transport_preserves_all (d : A → Prop) (p : A → Prop)
    (s : Source) (e : Evidence) :
    (retain s s e, guardedAll d p).2 ↔ guardedAll d p := Iff.rfl

theorem empty_all (d : A → Prop) (p : A → Prop) (empty : ∀ x, ¬ d x) :
    guardedAll d p := by intro x hx; exact False.elim (empty x hx)

theorem empty_some (d : A → Prop) (p : A → Prop) (empty : ∀ x, ¬ d x) :
    ¬ guardedSome d p := by rintro ⟨x,hx,_⟩; exact empty x hx

-- A paid carrier change does not assert equality or inhabitation of carriers.
def updateCost (a b : Nat) : Nat := if a = b then 0 else 1
theorem changed_carrier_is_paid (a b : Nat) (h : a ≠ b) :
    updateCost a b = 1 := by simp [updateCost, h]

#print axioms retained_exact
#print axioms authentic_unary_retained
#print axioms foreign_source_rejected
#print axioms unauthenticated_rejected
#print axioms transport_preserves_all
#print axioms empty_all
#print axioms empty_some
#print axioms changed_carrier_is_paid
end EmptyBindingEvidence
