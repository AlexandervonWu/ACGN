import DeclaredSlotAdmission
import GroupedOnePaidAdmission
import LonePaidDeclarationAlignment

/- Paid links retain a rigid declaration's original joint tuple. This is an
   admission contract for edit programs, not a free quantifier exchange or an
   equivalence between the two predicates being compared. -/
namespace RigidGroupedPaidAdmission
open SelectedDeclarationCompletion DeclaredSlotAdmission

-- The two old Java conjuncts: disjoint kind admission and grouped kind admission.
def oldKindDisjoint (b : Binding) : Bool :=
  b.origin.disjointness == 0 || b.origin.quantifier == "ALL" || b.origin.quantifier == "SOME"

def oldGroupedKind (kind : String) (originalOne : Bool) : Bool :=
  kind == "ALL" || kind == "SOME" || (kind == "ONE" && originalOne)

def oldGroup (bindings : List Binding) (originalOne : Bool) : Bool :=
  bindings.all oldKindDisjoint &&
    match bindings with
    | [] => false
    | first :: _ => oldGroupedKind first.origin.quantifier originalOne

def groupSlots (bindings : List Binding) (indices : List Nat) : List Binding :=
  indices.filterMap (fun i => bindings[i]?)

def checkedGroup (issued current reads : List Binding) (indices : List Nat) : Bool :=
  checkedSlots issued current reads &&
    match indices with
    | [] => false
    | start :: _ =>
      decide (2 ≤ indices.length ∧ indices = (List.range indices.length).map (start + ·)) &&
      indices.all (fun i => (current[i]?).isSome)

theorem exact_group (issued current reads : List Binding) (indices : List Nat)
    (checked : checkedGroup issued current reads indices = true) :
    groupSlots issued indices = groupSlots current indices := by
  simp only [checkedGroup, Bool.and_eq_true] at checked
  have h : checkedSlots issued current reads = true := checked.1
  rw [checked_vector_exact issued current reads h]

-- Interpret the whole source tuple at once. In particular, do not fold ONE
-- or LONE independently over its slots.
theorem whole_tuple_context_retained {Value : Sort u}
    (interpret : List Binding → Value) (issued current reads : List Binding)
    (indices : List Nat) (checked : checkedGroup issued current reads indices = true) :
    interpret (groupSlots issued indices) = interpret (groupSlots current indices) := by
  rw [exact_group issued current reads indices checked]

theorem one_tuple_guard {Tuple : Type} (domain body : Tuple → Prop) :
    GroupedOnePaidAdmission.Unique (fun x : {x // domain x} => body x.val) ↔
      GroupedOnePaidAdmission.Unique (fun x => domain x ∧ body x) :=
  GroupedOnePaidAdmission.guarded_tuple domain body

theorem lone_tuple_guard {Tuple : Type} (domain body : Tuple → Prop) :
    LonePaidDeclarationAlignment.AtMostOne (fun x : {x // domain x} => body x.val) ↔
      LonePaidDeclarationAlignment.AtMostOne (fun x => domain x ∧ body x) :=
  LonePaidDeclarationAlignment.guarded_lone_subtype domain body

-- Domain may contain dependent fields and pairwise disjointness. Nothing in
-- either theorem assumes that the domain is inhabited or drops its guard.
theorem one_disjoint_tuple_guard {A : Type} (domain body : A × A → Prop) :
    GroupedOnePaidAdmission.Unique
      (fun x : {x : A × A // domain x ∧ x.1 ≠ x.2} => body x.val) ↔
    GroupedOnePaidAdmission.Unique (fun x => (domain x ∧ x.1 ≠ x.2) ∧ body x) :=
  one_tuple_guard (fun x => domain x ∧ x.1 ≠ x.2) body

theorem paid_diagonal_not_free (a b : PaidDeclarationAlignment.Atom)
    (different : a.tuple ≠ b.tuple) :
    PaidDeclarationAlignment.replay [a] [.pair a b] =
      some ([b], 1, [(a.occurrence, b.occurrence)]) := by
  simpa [PaidDeclarationAlignment.replay] using
    PaidDeclarationAlignment.paid_diagonal_carries_exact_link a b [] [] [] 0 [] different rfl

theorem changed_source_group_rejected (issued current reads : List Binding) (indices : List Nat)
    (changed : issued ≠ current) : checkedGroup issued current reads indices = false := by
  simp [checkedGroup, altered_declaration_rejected issued current reads changed]

structure Witness where
  issued : List Binding
  current : List Binding
  reads : List Binding
  indices : List Nat
  originalOne : Bool

def witnessChecked (w : Witness) : Bool :=
  !oldGroup (groupSlots w.issued w.indices) w.originalOne &&
    checkedGroup w.issued w.current w.reads w.indices

#print axioms exact_group
#print axioms whole_tuple_context_retained
#print axioms one_tuple_guard
#print axioms lone_tuple_guard
#print axioms one_disjoint_tuple_guard
#print axioms paid_diagonal_not_free
#print axioms changed_source_group_rejected
end RigidGroupedPaidAdmission
