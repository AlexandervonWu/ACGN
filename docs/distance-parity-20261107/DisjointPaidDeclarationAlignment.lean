import Std

/- Paid declaration updates are not free alpha equivalences. The disjoint group
   and source owner remain part of each original tuple and are checked before a
   charged link is available to the matrix. No disjoint guard is erased, and no
   new declaration permutation is authorized by this contract. Java refinement
   and the complete original-source/public edit semantics remain separate. -/
namespace DisjointPaidDeclarationAlignment

structure Occurrence where
  owner : Nat
  slot : Nat
  deriving DecidableEq

structure Payload where
  kind : Nat
  carrier : Nat
  multiplicity : Nat
  disjointGroup : Nat
  deriving DecidableEq

structure Declaration where
  occurrence : Occurrence
  payload : Payload
  deriving DecidableEq

def updateCost (a b : Declaration) : Nat :=
  if a.payload = b.payload then 0 else 1

def paidLink (actual expected target : Declaration) : Option (Occurrence × Occurrence) :=
  if actual = expected ∧ updateCost actual target = 1
    then some (actual.occurrence, target.occurrence) else none

theorem charged_disjoint_link (a b : Declaration)
    (changed : a.payload ≠ b.payload) :
    paidLink a a b = some (a.occurrence, b.occurrence) := by
  simp [paidLink, updateCost, changed]

theorem changed_disjoint_group_is_charged (a b : Declaration)
    (changed : a.payload.disjointGroup ≠ b.payload.disjointGroup) :
    updateCost a b = 1 := by
  have different : a.payload ≠ b.payload := fun h => changed (congrArg Payload.disjointGroup h)
  simp [updateCost, different]

theorem foreign_owner_or_payload_rejected (a expected b : Declaration)
    (foreign : a ≠ expected) : paidLink a expected b = none := by
  simp [paidLink, foreign]

theorem shared_group_does_not_merge_slots (owner i j : Nat) (different : i ≠ j) :
    (Occurrence.mk owner i) ≠ (Occurrence.mk owner j) := by
  intro h
  exact different (congrArg Occurrence.slot h)

-- No inhabitation assumption is needed to keep the original disjoint guard.
def allDisjoint (p : A → A → Prop) : Prop := ∀ x y, x ≠ y → p x y
def someDisjoint (p : A → A → Prop) : Prop := ∃ x y, x ≠ y ∧ p x y

theorem all_guard_preserved (p q : A → A → Prop)
    (body : ∀ x y, p x y ↔ q x y) : allDisjoint p ↔ allDisjoint q := by
  constructor
  · intro h x y different; exact (body x y).mp (h x y different)
  · intro h x y different; exact (body x y).mpr (h x y different)

theorem some_guard_preserved (p q : A → A → Prop)
    (body : ∀ x y, p x y ↔ q x y) : someDisjoint p ↔ someDisjoint q := by
  constructor
  · rintro ⟨x,y,hd,h⟩; exact ⟨x,y,hd,(body x y).mp h⟩
  · rintro ⟨x,y,hd,h⟩; exact ⟨x,y,hd,(body x y).mpr h⟩

theorem empty_disjoint_exists_false (p : Empty → Empty → Prop) : ¬ someDisjoint p := by
  rintro ⟨x, _⟩; exact nomatch x

#print axioms charged_disjoint_link
#print axioms changed_disjoint_group_is_charged
#print axioms foreign_owner_or_payload_rejected
#print axioms shared_group_does_not_merge_slots
#print axioms all_guard_preserved
#print axioms some_guard_preserved
#print axioms empty_disjoint_exists_false
end DisjointPaidDeclarationAlignment
