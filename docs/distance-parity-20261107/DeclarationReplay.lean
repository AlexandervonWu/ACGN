import Std

/- A fixed-order declaration replay contract. Occurrence identity and repair
   tuple are distinct: a zero-cost tuple match still has exact endpoints.
   This does not prove admission of the native ordering, Java correspondence,
   source normalization, or linkage into a complete public operation sequence. -/
namespace DeclarationReplay

structure Atom where
  occurrence : Nat
  tuple : Nat
  deriving DecidableEq

inductive Edit where
  | pair : Atom → Atom → Edit
  | delete : Atom → Edit
  | insert : Atom → Edit

def replay : List Atom → List Edit → Option (List Atom × Nat)
  | [], [] => some ([], 0)
  | _ :: _, [] => none
  | xs, .insert b :: es => do
      let (ys, cost) ← replay xs es
      pure (b :: ys, cost + 1)
  | a :: xs, .delete expected :: es =>
      if a = expected then do
        let (ys, cost) ← replay xs es
        pure (ys, cost + 1)
      else none
  | a :: xs, .pair expected b :: es =>
      if a = expected then do
        let (ys, cost) ← replay xs es
        pure (b :: ys, cost + if a.tuple = b.tuple then 0 else 1)
      else none
  | [], _ :: _ => none

theorem delete_all (xs : List Atom) :
    replay xs (xs.map Edit.delete) = some ([], xs.length) := by
  induction xs with
  | nil => rfl
  | cons a xs ih => simp [replay, ih]

theorem two_deletions (a b : Atom) :
    replay [a, b] [.delete a, .delete b] = some ([], 2) := by
  simp [replay]

theorem wrong_occurrence_rejected (a expected : Atom) (xs : List Atom)
    (es : List Edit) (h : a ≠ expected) :
    replay (a :: xs) (.delete expected :: es) = none := by
  simp [replay, h]

theorem unconsumed_source_rejected (a : Atom) (xs : List Atom) :
    replay (a :: xs) [] = none := rfl

-- Ordered receipt concatenation preserves charges, not public-source authority.
theorem ordered_cost (first second : List Nat) :
    (first ++ second).sum = first.sum + second.sum := List.sum_append

structure Coverage where
  numerical : Bool
  orderingAdmitted : Bool
  publicSequenceLinked : Bool
  certificatesReplayed : Bool
  correspondenceChecked : Bool

def complete (c : Coverage) : Bool := c.numerical && c.orderingAdmitted &&
  c.publicSequenceLinked && c.certificatesReplayed && c.correspondenceChecked

theorem numerical_coverage_not_authority (c : Coverage)
    (missing : c.publicSequenceLinked = false) : complete c = false := by
  simp [complete, missing]

#print axioms delete_all
#print axioms two_deletions
#print axioms wrong_occurrence_rejected
#print axioms unconsumed_source_rejected
#print axioms ordered_cost
#print axioms numerical_coverage_not_authority
end DeclarationReplay
