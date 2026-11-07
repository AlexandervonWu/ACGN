import Std

/- A paid declaration diagonal carries its exact occurrence correspondence
   into matrix edits. It is not alpha equality and does not erase the tuple
   update cost. Fixed-order DP optimality, source normalization, and the
   Java/wire correspondence remain separate obligations. -/
namespace PaidDeclarationAlignment

structure Atom where
  occurrence : Nat
  tuple : Nat
  deriving DecidableEq

inductive Edit where
  | pair : Atom → Atom → Edit
  | delete : Atom → Edit
  | insert : Atom → Edit

def replay : List Atom → List Edit → Option (List Atom × Nat × List (Nat × Nat))
  | [], [] => some ([], 0, [])
  | _ :: _, [] => none
  | xs, .insert b :: es => do
      let (ys, cost, links) ← replay xs es
      pure (b :: ys, cost + 1, links)
  | a :: xs, .delete expected :: es =>
      if a = expected then do
        let (ys, cost, links) ← replay xs es
        pure (ys, cost + 1, links)
      else none
  | a :: xs, .pair expected b :: es =>
      if a = expected then do
        let (ys, cost, links) ← replay xs es
        if a.tuple = b.tuple then pure (b :: ys, cost, links)
        else pure (b :: ys, cost + 1, (a.occurrence, b.occurrence) :: links)
      else none
  | [], _ :: _ => none

theorem paid_diagonal_carries_exact_link (a b : Atom) (xs ys : List Atom)
    (es : List Edit) (cost : Nat) (links : List (Nat × Nat))
    (changed : a.tuple ≠ b.tuple) (h : replay xs es = some (ys, cost, links)) :
    replay (a :: xs) (.pair a b :: es) =
      some (b :: ys, cost + 1, (a.occurrence, b.occurrence) :: links) := by
  simp [replay, changed, h]

theorem zero_diagonal_not_paid (a b : Atom) (same : a.tuple = b.tuple) :
    replay [a] [.pair a b] = some ([b], 0, []) := by
  simp [replay, same]

theorem wrong_source_rejected (a expected b : Atom) (xs : List Atom)
    (es : List Edit) (different : a ≠ expected) :
    replay (a :: xs) (.pair expected b :: es) = none := by
  simp [replay, different]

theorem deletion_not_a_link (a : Atom) :
    replay [a] [.delete a] = some ([], 1, []) := by simp [replay]

-- A one-unit diagonal cannot silently become a free declaration rename.
theorem paid_cost_positive (cost : Nat) : 0 < cost + 1 := Nat.zero_lt_succ cost

#print axioms paid_diagonal_carries_exact_link
#print axioms zero_diagonal_not_paid
#print axioms wrong_source_rejected
#print axioms deletion_not_a_link
#print axioms paid_cost_positive
end PaidDeclarationAlignment
