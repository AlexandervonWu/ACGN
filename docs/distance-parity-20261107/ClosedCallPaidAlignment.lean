import Std

/- Only closed, ordered literal-argument calls are modeled here. Calls are not
   unfolded or equated by meaning. Source/module/type/occurrence checks are
   admission premises; these laws are not a Java or parser refinement proof. -/
namespace ClosedCallPaidAlignment
structure Literal where
  moduleId : Nat
  identity : Nat
  resultType : Nat
  deriving DecidableEq
structure Call where
  moduleId : Nat
  identity : Nat
  resultType : Nat
  arguments : List Literal
  deriving DecidableEq
inductive Term where
  | variable : Nat → Term
  | closedCall : Call → Term
  deriving DecidableEq
def rename (f : Nat → Nat) : Term → Term
  | .variable x => .variable (f x)
  | .closedCall c => .closedCall c

theorem closed_call_unchanged (f : Nat → Nat) (c : Call) :
    rename f (.closedCall c) = .closedCall c := rfl
theorem closed_call_composition (f g : Nat → Nat) (c : Call) :
    rename g (rename f (.closedCall c)) = .closedCall c := rfl
theorem bound_argument_not_closed (x : Nat) (c : Call) :
    Term.variable x ≠ Term.closedCall c := by intro h; cases h

structure Occurrence where
  call : Call
  lineage : Nat
  parserId : Nat
  deriving DecidableEq
def admit (actual original : Occurrence) : Bool := decide (actual = original)
theorem admitted_preserves_source (a b : Occurrence) (h : admit a b = true) :
    a = b := by simpa [admit] using h
theorem foreign_occurrence_rejected (a b : Occurrence) (h : a ≠ b) :
    admit a b = false := by simp [admit,h]

def headCost (a b : Call) : Nat :=
  if a.identity = b.identity ∧ a.resultType = b.resultType ∧
    a.arguments.length = b.arguments.length then 0 else 1
theorem changed_result_type_charged (a b : Call) (h : a.resultType ≠ b.resultType) :
    headCost a b = 1 := by simp [headCost,h]
theorem source_match_retains_argument_order (a b : Occurrence) (h : admit a b = true) :
    a.call.arguments = b.call.arguments := by rw [admitted_preserves_source a b h]

#print axioms closed_call_unchanged
#print axioms closed_call_composition
#print axioms bound_argument_not_closed
#print axioms admitted_preserves_source
#print axioms foreign_occurrence_rejected
#print axioms changed_result_type_charged
#print axioms source_match_retains_argument_order
end ClosedCallPaidAlignment
