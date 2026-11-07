import Lean
set_option autoImplicit false

namespace PartitionedPermutation

-- One fiber is a single admissible scope/declaration block and exact type.
def Fiber (key : Nat → Nat) (k : Nat) := {i : Nat // key i = k}

def lift (key : Nat → Nat)
    (within : (k : Nat) → Fiber key k → Fiber key k) (i : Nat) : Nat :=
  (within (key i) ⟨i, rfl⟩).val

theorem generated_preserves_key (key : Nat → Nat)
    (within : (k : Nat) → Fiber key k → Fiber key k) (i : Nat) :
    key (lift key within i) = key i :=
  (within (key i) ⟨i, rfl⟩).property

theorem generated_rejects_cross_partition (key : Nat → Nat)
    (within : (k : Nat) → Fiber key k → Fiber key k) (i j : Nat)
    (different : key i ≠ key j) : lift key within i ≠ j := by
  intro equal
  have preserved := generated_preserves_key key within i
  rw [equal] at preserved
  exact different preserved.symm

def restrict (key f : Nat → Nat) (preserves : ∀ i, key (f i) = key i)
    (k : Nat) (i : Fiber key k) : Fiber key k :=
  ⟨f i.val, (preserves i.val).trans i.property⟩

theorem every_preserving_mapping_is_represented (key f : Nat → Nat)
    (preserves : ∀ i, key (f i) = key i) (i : Nat) :
    lift key (restrict key f preserves) i = f i := rfl

theorem preserves_scope_and_type (scope types f : Nat → Nat)
    (scopePreserved : ∀ i, scope (f i) = scope i)
    (typePreserved : ∀ i, types (f i) = types i) (i : Nat) :
    scope (f i) = scope i ∧ types (f i) = types i :=
  ⟨scopePreserved i, typePreserved i⟩

#print axioms generated_preserves_key
#print axioms generated_rejects_cross_partition
#print axioms every_preserving_mapping_is_represented
#print axioms preserves_scope_and_type

end PartitionedPermutation
