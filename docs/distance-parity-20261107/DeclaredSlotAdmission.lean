import SelectedProgramCompletion
import PaidDeclarationAlignment
import DisjointPaidDeclarationAlignment

/- Declaration authority comes from the issued typed binding vector, not from
   requiring a read of every slot. This admits no declaration erasure or free
   permutation. Java must independently bind the issued vector to source frames. -/
namespace DeclaredSlotAdmission
open SelectedDeclarationCompletion

def checkedSlots (issued current : List Binding) (reads : List Binding) : Bool :=
  (decide (issued = current) &&
    current.zipIdx.all (fun (binding, index) => associated issued index binding)) &&
    reads.all (fun binding => associated issued binding.vectorIndex binding)

-- Exact extra census conjunct at the end of groupedSlotsMatchSource. All
-- earlier structural/type/group checks remain independent obligations.
def oldReadGate (grouped observed : List Nat) : Bool :=
  grouped.all (fun slot => observed.contains slot)

theorem unread_slot_rejected (grouped observed : List Nat) (slot : Nat)
    (member : slot ∈ grouped) (absent : slot ∉ observed) :
    oldReadGate grouped observed = false := by
  cases h : oldReadGate grouped observed with
  | false => rfl
  | true =>
    have seen := (List.all_eq_true.mp h) slot member
    exact False.elim (absent (List.contains_iff_mem.mp seen))

theorem checked_vector_exact (issued current : List Binding) (reads : List Binding)
    (checked : checkedSlots issued current reads = true) : issued = current := by
  simp only [checkedSlots, Bool.and_eq_true] at checked
  exact of_decide_eq_true checked.1.1

theorem checked_read_exact (issued current : List Binding) (reads : List Binding)
    (checked : checkedSlots issued current reads = true)
    (binding : Binding) (member : binding ∈ reads) :
    issued[binding.vectorIndex]? = some binding := by
  simp only [checkedSlots, Bool.and_eq_true] at checked
  exact (associated_exact issued binding.vectorIndex binding
    ((List.all_eq_true.mp checked.2) binding member)).1

theorem altered_declaration_rejected (issued current : List Binding) (reads : List Binding)
    (changed : issued ≠ current) : checkedSlots issued current reads = false := by
  simp [checkedSlots, changed]

theorem foreign_read_rejected (issued current reads : List Binding) (binding : Binding)
    (member : binding ∈ reads) (foreign : issued[binding.vectorIndex]? ≠ some binding) :
    checkedSlots issued current reads = false := by
  cases h : checkedSlots issued current reads with
  | false => rfl
  | true => exact False.elim (foreign (checked_read_exact issued current reads h binding member))

-- Includes empty domains, dependent domains, multiplicity and disjoint guards:
-- the interpretation is arbitrary because the exact declarations are unchanged.
theorem declaration_context_unchanged {Env : Type}
    (interpret : Binding → (Env → Prop) → Env → Prop) (body : Env → Prop)
    (issued current : List Binding) (reads : List Binding)
    (checked : checkedSlots issued current reads = true) :
    issued.foldr interpret body = current.foldr interpret body := by
  rw [checked_vector_exact issued current reads checked]

theorem disjoint_guard_not_erased (body : A → A → Prop) :
    DisjointPaidDeclarationAlignment.allDisjoint body ↔
      (∀ x y, x ≠ y → body x y) := Iff.rfl

theorem unused_disjoint_is_not_free_erasure :
    DisjointPaidDeclarationAlignment.allDisjoint (fun (_ _ : Unit) => False) ∧
      ¬ (∀ _x : Unit, False) := by
  constructor
  · intro x y different
    exact False.elim (different (Subsingleton.elim x y))
  · intro h
    exact h ()

-- Reuse the existing exact-action completion theorem. This does not assume
-- equality of aggregate costs, erase zero-cost operations, or change endpoints.
theorem completed_matrix_program_unchanged (actions : List Action) (before after : Mapping)
    (checked : SelectedProgramCompletion.unchangedCharges actions before after = true) :
    annotated actions before = annotated actions after :=
  SelectedProgramCompletion.checked_program_unchanged actions before after checked

structure GateWitness where
  issued : List Binding
  current : List Binding
  reads : List Binding
  grouped : List Nat
  observed : List Nat

def witnessChecked (w : GateWitness) : Bool :=
  !oldReadGate w.grouped w.observed && checkedSlots w.issued w.current w.reads

structure CapturedProgram where
  source : List PaidDeclarationAlignment.Atom
  target : List PaidDeclarationAlignment.Atom
  edits : List PaidDeclarationAlignment.Edit
  cost : Nat
  paidLinks : List (Nat × Nat)

def programChecked (p : CapturedProgram) : Bool :=
  decide (PaidDeclarationAlignment.replay p.source p.edits = some (p.target, p.cost, p.paidLinks))

#print axioms unread_slot_rejected
#print axioms checked_vector_exact
#print axioms checked_read_exact
#print axioms altered_declaration_rejected
#print axioms foreign_read_rejected
#print axioms declaration_context_unchanged
#print axioms disjoint_guard_not_erased
#print axioms unused_disjoint_is_not_free_erasure
#print axioms completed_matrix_program_unchanged
end DeclaredSlotAdmission
