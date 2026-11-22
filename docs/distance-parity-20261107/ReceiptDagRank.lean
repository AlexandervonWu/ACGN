import Std
import ReceiptStructuralSharing

namespace ReceiptDagRank
open ReceiptStructuralSharing

-- A flat row may only reference previously decoded rows. Its logical height
-- is not JSON nesting or recursive call-stack depth.
structure FiniteRow (n : Nat) where
  tag : String
  scalars : List String
  children : List (Fin n)

def tableOf (keys : Fin n → Key) : Table :=
  fun i => if h : i < n then some (keys ⟨i, h⟩) else none

theorem finite_links (keys : Fin n → Key) (refs : List (Fin n)) :
    Links (tableOf keys) (refs.map Fin.val) (refs.map keys) := by
  induction refs with
  | nil => exact .nil
  | cons i refs ih =>
    apply Links.cons _ ih
    simp [tableOf, i.isLt]

theorem finite_row_roundtrip (keys : Fin n → Key) (row : FiniteRow n) :
    decode (tableOf keys) ⟨row.tag, row.scalars, row.children.map Fin.val⟩ =
      some (.node row.tag row.scalars (row.children.map keys)) :=
  row_roundtrip (finite_links keys row.children)

theorem out_of_range_rejected (keys : Fin n → Key) (i : Nat) (h : n ≤ i) :
    tableOf keys i = none := by simp [tableOf, show ¬ i < n by omega]

def Postorder (children : Nat → List Nat) : Prop :=
  ∀ parent child, child ∈ children parent → child < parent

inductive Walk (children : Nat → List Nat) : Nat → Nat → Nat → Prop
  | done : Walk children i i 0
  | step : child ∈ children parent → Walk children child last steps →
      Walk children parent last (steps + 1)

theorem path_rank_bound (ordered : Postorder children)
    (walk : Walk children first last steps) : last + steps ≤ first := by
  induction walk with
  | done => omega
  | step edge _ ih => have := ordered _ _ edge; omega

theorem no_cycle (ordered : Postorder children)
    (walk : Walk children start start steps) : steps = 0 := by
  have := path_rank_bound ordered walk
  omega

theorem height_bounded_by_rows (ordered : Postorder children)
    (walk : Walk children root last steps) (rootInTable : root < rows) :
    steps + 1 ≤ rows := by
  have := path_rank_bound ordered walk
  omega

-- Full logical DAG height is distinct from first-visit recursion depth in an
-- identity-memoized traversal. These numbers do not evaluate the old Java gate;
-- the retained old run hit its visit limit, not its depth limit.
theorem measured_height_fits_rank : (1332 : Nat) ≤ 3654 := by decide
theorem logical_path_exceeds_hypothetical_height_cap : decide (1331 ≤ 128) = false := by decide

theorem self_reference_invalid : ¬ Postorder (fun i => [i]) := by
  intro h
  have impossible := h 0 0 (by simp)
  omega

theorem forward_reference_invalid : ¬ Postorder (fun i => [i + 1]) := by
  intro h
  have impossible := h 0 1 (by simp)
  omega

def resourceAdmission (references equalityWork rows units characters : Nat) : Bool :=
  decide (references ≤ 120000 ∧ equalityWork ≤ 8000000 ∧
    rows ≤ units ∧ units ≤ 120000 ∧ characters ≤ 4000000)

theorem over_work_rejected : resourceAdmission 120001 1 1 1 1 = false := by decide
theorem over_equality_rejected : resourceAdmission 1 8000001 1 1 1 = false := by decide
theorem over_units_rejected : resourceAdmission 1 1 1 120001 1 = false := by decide
theorem over_characters_rejected : resourceAdmission 1 1 1 1 4000001 = false := by decide

-- These contracts do not waive service memory, live frontier/work, timeout,
-- complete-output, cycle-detection or source/certificate-premise checks.
end ReceiptDagRank
