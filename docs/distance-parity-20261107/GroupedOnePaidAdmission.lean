import Std

/- A grouped ONE quantifies one entire tuple, not nested unique quantifiers.
   Paid slot links retain original order and owner evidence; they are not
   semantic equality between source and edited target. This model is not an
   extracted Java proof or a public source/wire certificate. -/
namespace GroupedOnePaidAdmission

def Unique {A : Type} (p : A → Prop) : Prop :=
  ∃ x, p x ∧ ∀ y, p y → y = x

theorem guarded_tuple {A : Type} (domain p : A → Prop) :
    Unique (fun x : {x // domain x} => p x.val) ↔
    Unique (fun x => domain x ∧ p x) := by
  constructor
  · rintro ⟨⟨x, dx⟩, px, hx⟩
    refine ⟨x, ⟨dx, px⟩, ?_⟩
    intro y hy
    exact congrArg Subtype.val (hx ⟨y, hy.1⟩ hy.2)
  · rintro ⟨x, ⟨dx, px⟩, hx⟩
    refine ⟨⟨x, dx⟩, px, ?_⟩
    intro y hy
    exact Subtype.ext (hx y.val ⟨y.property, hy⟩)

theorem empty_tuple_rejected {A : Type} (domain p : A → Prop)
    (empty : ∀ x, ¬ domain x) : ¬ Unique (fun x => domain x ∧ p x) := by
  rintro ⟨x, hx, _⟩
  exact empty x hx.1

structure Slot where
  owner : Nat
  index : Nat
  carrier : Nat
  occurrence : Nat
  deriving DecidableEq

def admitted (original current : List Slot) : Prop := original = current

theorem ordered_slot_link {original current : List Slot}
    (h : admitted original current) (i : Nat) : original[i]? = current[i]? := by
  cases h
  rfl

theorem foreign_owner_rejected (a b : Slot) (h : a.owner ≠ b.owner) :
    ¬ admitted [a] [b] := by
  intro eq
  have ab : a = b := List.cons.inj eq |>.1
  exact h (congrArg Slot.owner ab)

theorem reversed_distinct_slots_rejected (a b : Slot) (h : a.index ≠ b.index) :
    ¬ admitted [a,b] [b,a] := by
  intro eq
  have ab : a = b := List.cons.inj eq |>.1
  exact h (congrArg Slot.index ab)

-- A fixed edit path may charge a matched occurrence without licensing exchange.
def paid (actual expected target : Slot) : Option (Nat × Slot × Slot) :=
  if actual = expected then some (1, actual, target) else none

theorem paid_link (a b : Slot) : paid a a b = some (1,a,b) := by simp [paid]
theorem wrong_occurrence_rejected (a expected b : Slot) (h : a ≠ expected) :
    paid a expected b = none := by simp [paid,h]

#print axioms guarded_tuple
#print axioms empty_tuple_rejected
#print axioms ordered_slot_link
#print axioms foreign_owner_rejected
#print axioms reversed_distinct_slots_rejected
#print axioms paid_link
#print axioms wrong_occurrence_rejected
end GroupedOnePaidAdmission
