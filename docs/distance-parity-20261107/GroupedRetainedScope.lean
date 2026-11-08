import Std

/- Grouped OUTER ALL/SOME slots and a retained LOCAL owner are disjoint
   namespaces. This contract composes eligibility checks, not free exchanges,
   paid edits as semantic equalities, or Java/public-wire correspondence. -/
namespace GroupedRetainedScope

structure Occurrence where
  owner : Nat
  slot : Nat
  deriving DecidableEq

inductive Reference where
  | outer : Occurrence → Reference
  | local : Occurrence → Reference
  deriving DecidableEq

def transport (paid : Occurrence → Option Occurrence) : Reference → Option Reference
  | .outer o => (paid o).map Reference.outer
  | .local o => some (.local o)

theorem grouped_slots_distinct (owner i j : Nat) (h : i ≠ j) :
    Reference.outer ⟨owner,i⟩ ≠ Reference.outer ⟨owner,j⟩ := by
  intro eq
  cases eq
  exact h rfl

theorem retained_owner_unchanged (paid : Occurrence → Option Occurrence) (o : Occurrence) :
    transport paid (.local o) = some (.local o) := rfl

theorem no_group_capture (paid : Occurrence → Option Occurrence) (o g : Occurrence) :
    transport paid (.local o) ≠ some (.outer g) := by simp [transport]

-- Splitting a metadata group by substituting its owner cannot retain the
-- original occurrence key. Group cardinality alone is not source authority.
theorem occurrence_key_requires_owner (actual original : Occurrence)
    (key : actual = original) : actual.owner = original.owner := congrArg Occurrence.owner key

theorem foreign_owner_rejected (actual original : Occurrence)
    (foreign : actual.owner ≠ original.owner) : actual ≠ original := by
  intro key
  exact foreign (occurrence_key_requires_owner actual original key)

-- A local formula is evaluated INSIDE each original outer environment. It
-- may contain ONE/LONE or depend on either outer slot; no hoisting occurs.
theorem grouped_all_retaining_body {A : Type} (domain : A → Prop)
    (localBody : A → A → Prop) :
    (∀ pair : A × A, domain pair.1 → domain pair.2 → localBody pair.1 pair.2)
      ↔ (∀ x, domain x → ∀ y, domain y → localBody x y) := by
  constructor
  · intro h x hx y hy; exact h (x,y) hx hy
  · intro h pair hx hy; exact h pair.1 hx pair.2 hy

theorem grouped_some_retaining_body {A : Type} (domain : A → Prop)
    (localBody : A → A → Prop) :
    (∃ pair : A × A, domain pair.1 ∧ domain pair.2 ∧ localBody pair.1 pair.2)
      ↔ (∃ x, domain x ∧ ∃ y, domain y ∧ localBody x y) := by
  constructor
  · rintro ⟨⟨x,y⟩, hx, hy, hb⟩; exact ⟨x,hx,y,hy,hb⟩
  · rintro ⟨x,hx,y,hy,hb⟩; exact ⟨(x,y),hx,hy,hb⟩

theorem empty_outer_does_not_require_local :
    (∀ _x : Empty, ∃ _z : Empty, True) ∧ ¬ (∃ _z : Empty, True) := by
  constructor
  · intro x; exact nomatch x
  · rintro ⟨z,_⟩; exact nomatch z

structure Admission where
  originalSlots : Prop
  originalLocalOwner : Prop
  nondisjoint : Prop

def admitted (a : Admission) : Prop := a.originalSlots ∧ a.originalLocalOwner ∧ a.nondisjoint

theorem composition_requires_both (a : Admission) (h : admitted a) :
    a.originalSlots ∧ a.originalLocalOwner := ⟨h.1,h.2.1⟩

#print axioms grouped_slots_distinct
#print axioms retained_owner_unchanged
#print axioms no_group_capture
#print axioms occurrence_key_requires_owner
#print axioms foreign_owner_rejected
#print axioms grouped_all_retaining_body
#print axioms grouped_some_retaining_body
#print axioms empty_outer_does_not_require_local
#print axioms composition_requires_both
end GroupedRetainedScope
