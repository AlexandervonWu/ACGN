/- Ordered declarations under one lexical owner do not imply a single
   declaration. Transport retains owner, declaration and tuple coordinates.
   This models the correspondence checks, not the Java implementation. -/
namespace LocalOwnerTrace

structure Slot where
  owner : Nat
  declaration : Nat
  tuple : Nat
  type : Nat
  deriving DecidableEq

def flatten (groups : List (List Slot)) : List Slot := groups.flatten

theorem ordered_group_transport (f : Slot → Slot) (groups : List (List Slot)) :
    flatten (groups.map (List.map f)) = (flatten groups).map f := by
  induction groups with
  | nil => rfl
  | cons g gs ih => simp [flatten, List.map_append, flatten] at ih ⊢

theorem wrong_owner (a b : Slot) (h : a.owner ≠ b.owner) : a ≠ b := by
  intro eq; exact h (congrArg Slot.owner eq)

theorem wrong_declaration (a b : Slot) (h : a.declaration ≠ b.declaration) : a ≠ b := by
  intro eq; exact h (congrArg Slot.declaration eq)

theorem wrong_tuple (a b : Slot) (h : a.tuple ≠ b.tuple) : a ≠ b := by
  intro eq; exact h (congrArg Slot.tuple eq)

abbrev Store := Slot → Option Nat
structure Action where
  address : Slot
  before : Option Nat
  after : Option Nat
  cost : Nat

def apply (s : Store) (a : Action) : Option Store :=
  if s a.address = a.before then
    some (fun p => if p = a.address then a.after else s p)
  else none

def transport (f : Slot → Slot) (a : Action) : Action := {a with address := f a.address}

theorem fixed_premise_transport (f g : Slot → Slot) (inverse : ∀ x, g (f x) = x)
    (s : Store) (a : Action) :
    (s ∘ g) (transport f a).address = a.before ↔ s a.address = a.before := by
  simp [transport, inverse]

theorem execute_transport (f g : Slot → Slot)
    (left : ∀ x, g (f x) = x) (right : ∀ x, f (g x) = x)
    (s : Store) (a : Action) :
    apply (s ∘ g) (transport f a) = (apply s a).map (fun t => t ∘ g) := by
  have eq (p : Slot) : p = f a.address ↔ g p = a.address := by
    constructor
    · intro h; rw [h, left]
    · intro h; rw [← right p, h]
  simp only [apply, transport, Function.comp_apply, left]
  split
  · congr 1; funext p; simp only [Function.comp_apply, eq]
  · rfl

theorem action_charge (f : Slot → Slot) (a : Action) : (transport f a).cost = a.cost := rfl
theorem sequence_charges (f : Slot → Slot) (as : List Action) :
    ((as.map (transport f)).map Action.cost).sum = (as.map Action.cost).sum := by
  induction as with
  | nil => rfl
  | cons a as ih => simpa only [List.map_cons, List.sum_cons, action_charge] using congrArg (fun n => a.cost + n) ih

#print axioms ordered_group_transport
#print axioms execute_transport
#print axioms sequence_charges
#print axioms wrong_owner
#print axioms wrong_declaration
#print axioms wrong_tuple
end LocalOwnerTrace
