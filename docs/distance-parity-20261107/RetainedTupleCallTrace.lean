import Std

/- Retained grouped declarations remain a single ordered tuple owner. This
   models source/comparison congruence, not equality of paid repair endpoints.
   No splitting of ONE/LONE, hoisting, or free disjointness edit is licensed. -/
namespace RetainedTupleCallTrace

structure Slot where
  owner : Nat
  index : Nat
  deriving DecidableEq

def extend {V : Type} (outer : Slot → V) (owner : Nat) (values : Nat → V)
    (slot : Slot) : V := if slot.owner = owner then values slot.index else outer slot

theorem retained_slot {V : Type} (outer : Slot → V) (owner index : Nat)
    (values : Nat → V) : extend outer owner values ⟨owner,index⟩ = values index := by
  simp [extend]

theorem no_capture {V : Type} (outer : Slot → V) (owner : Nat)
    (values : Nat → V) (slot : Slot) (h : slot.owner ≠ owner) :
    extend outer owner values slot = outer slot := by simp [extend,h]

def someTuple {V : Type} (domain : V → Prop) (arity : Nat) (body : List V → Prop) : Prop :=
  ∃ values, values.length = arity ∧ (∀ v ∈ values, domain v) ∧ body values

theorem grouped_source_congruence {V : Type} (domain : V → Prop) (arity : Nat)
    (original comparison : List V → Prop)
    (sameBody : ∀ values, values.length = arity → original values = comparison values) :
    someTuple domain arity original ↔ someTuple domain arity comparison := by
  constructor
  · rintro ⟨vs, size, members, body⟩
    exact ⟨vs, size, members, (sameBody vs size) ▸ body⟩
  · rintro ⟨vs, size, members, body⟩
    exact ⟨vs, size, members, (sameBody vs size).symm ▸ body⟩

structure CallHead where
  module : Nat
  callee : Nat
  authority : Nat
  occurrence : Nat
  resultType : Nat
  argumentTypes : List Nat
  deriving DecidableEq

theorem scoped_call_congruence {V : Type} (invoke : CallHead → List V → V)
    (head other : CallHead) (source : other = head) (args actual : List V)
    (ordered : actual = args) : invoke other actual = invoke head args := by
  cases source; cases ordered; rfl

theorem wrong_slot_rejected (owner a b : Nat) (h : a ≠ b) :
    Slot.mk owner a ≠ Slot.mk owner b := by
  intro eq; exact h (congrArg Slot.index eq)

/- Construction and repair remain distinct. Retaining a construction endpoint
   link does not alter any independently replayed action or cost. -/
structure Edit (Endpoint : Type) where
  before : Endpoint
  after : Endpoint
  cost : Nat

theorem construction_edit_link {E : Type} (constructed : E) (edit : Edit E)
    (link : constructed = edit.before) : constructed = edit.before ∧ edit.cost = edit.cost :=
  ⟨link, rfl⟩

/- A repair vector index and a canonical certificate slot are separate
   coordinates. Use the checked bijection, not an identity-layout assumption. -/
theorem coordinate_roundtrip {Index Slot : Type} (toSlot : Index → Slot)
    (toIndex : Slot → Index) (checked : ∀ i, toIndex (toSlot i) = i)
    (i : Index) : toIndex (toSlot i) = i := checked i

theorem coordinate_cost_transport {Index Slot : Type} (toSlot : Index → Slot)
    (toIndex : Slot → Index) (checked : ∀ i, toIndex (toSlot i) = i)
    (cost : Index → Index → Nat) (a b : Index) :
    cost (toIndex (toSlot a)) (toIndex (toSlot b)) = cost a b := by
  rw [checked a, checked b]

theorem coordinate_link_transport {Index Slot : Type} (toSlot : Index → Slot)
    (toIndex : Slot → Index) (checked : ∀ i, toIndex (toSlot i) = i)
    (selected : Index → Index) (a : Index) :
    toIndex (toSlot (selected (toIndex (toSlot a)))) = selected a := by
  rw [checked a, checked (selected a)]

#print axioms retained_slot
#print axioms no_capture
#print axioms grouped_source_congruence
#print axioms scoped_call_congruence
#print axioms wrong_slot_rejected
#print axioms construction_edit_link
#print axioms coordinate_roundtrip
#print axioms coordinate_cost_transport
#print axioms coordinate_link_transport

/- A selected certified representative is a construction step, not a charged
   between-endpoint edit. Its endpoint must still equal the replay's before. -/
theorem selected_construction_link {E : Type} (meaning : E → Prop)
    (source selected fast : E) (premise : meaning source ↔ meaning selected)
    (correspondence : selected = fast) (edit : Edit E) (link : edit.before = selected) :
    (meaning source ↔ meaning fast) ∧ edit.before = fast := by
  cases correspondence
  exact ⟨premise, link⟩
#print axioms selected_construction_link

theorem source_atom_label {A L : Type} (original fast certified : A)
    (fastSource : fast = original) (certifiedSource : certified = original)
    (label : A → L) : label fast = label certified := by
  rw [fastSource, certifiedSource]
#print axioms source_atom_label
end RetainedTupleCallTrace
