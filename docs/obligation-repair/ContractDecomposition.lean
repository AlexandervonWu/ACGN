import Std

namespace ACGN.ContractDecomposition

/- Atom and scope payloads stay abstract here. Their primitive authority and
   correspondence with the English requirements are separate obligations. -/
inductive BinaryKind where
  | and | or | implies | iff
  deriving DecidableEq

inductive Quantifier where
  | all | some
  deriving DecidableEq

inductive Formula (Atom Scope : Type) where
  | atom (payload : Atom)
  | not (body : Formula Atom Scope)
  | binary (kind : BinaryKind) (left right : Formula Atom Scope)
  | quantified (kind : Quantifier) (scope : Scope) (body : Formula Atom Scope)
  deriving DecidableEq

inductive Skeleton (Scope : Type) where
  | hole
  | not (body : Skeleton Scope)
  | binary (kind : BinaryKind) (left right : Skeleton Scope)
  | quantified (kind : Quantifier) (scope : Scope) (body : Skeleton Scope)
  deriving DecidableEq

def skeleton : Formula Atom Scope → Skeleton Scope
  | .atom _ => .hole
  | .not body => .not (skeleton body)
  | .binary kind left right => .binary kind (skeleton left) (skeleton right)
  | .quantified kind scope body => .quantified kind scope (skeleton body)

def atoms : Formula Atom Scope → List Atom
  | .atom payload => [payload]
  | .not body => atoms body
  | .binary _ left right => atoms left ++ atoms right
  | .quantified _ _ body => atoms body

def refill : Skeleton Scope → List Atom → Option (Formula Atom Scope × List Atom)
  | .hole, [] => none
  | .hole, payload :: rest => some (.atom payload, rest)
  | .not body, values => do
      let (body, rest) ← refill body values
      pure (.not body, rest)
  | .binary kind left right, values => do
      let (left, rest) ← refill left values
      let (right, rest) ← refill right rest
      pure (.binary kind left right, rest)
  | .quantified kind scope body, values => do
      let (body, rest) ← refill body values
      pure (.quantified kind scope body, rest)

def reconstruct (shape : Skeleton Scope) (values : List Atom) : Option (Formula Atom Scope) := do
  let (formula, rest) ← refill shape values
  if rest.isEmpty then some formula else none

theorem refill_original_preserves_tail (formula : Formula Atom Scope) (rest : List Atom) :
    refill (skeleton formula) (atoms formula ++ rest) = some (formula, rest) := by
  induction formula generalizing rest with
  | atom payload => rfl
  | not body ih => simp [skeleton, atoms, refill, ih]
  | binary kind left right hl hr =>
      simp [skeleton, atoms, refill, List.append_assoc, hl, hr]
  | quantified kind scope body ih => simp [skeleton, atoms, refill, ih]

theorem reconstruct_original (formula : Formula Atom Scope) :
    reconstruct (skeleton formula) (atoms formula) = some formula := by
  have filled := refill_original_preserves_tail formula []
  simp only [List.append_nil] at filled
  simp [reconstruct, filled]

theorem every_formula_has_an_atom (formula : Formula Atom Scope) : atoms formula ≠ [] := by
  induction formula with
  | atom payload => simp [atoms]
  | not body ih => exact ih
  | binary kind left right hl hr => simp [atoms, hl]
  | quantified kind scope body ih => exact ih

theorem original_with_extra_atoms_rejects (formula : Formula Atom Scope)
    (extra : List Atom) (nonempty : extra ≠ []) :
    reconstruct (skeleton formula) (atoms formula ++ extra) = none := by
  simp [reconstruct, refill_original_preserves_tail, List.isEmpty_iff, nonempty]

def matchesSource [DecidableEq Atom] [DecidableEq Scope]
    (source : Formula Atom Scope) (shape : Skeleton Scope) (values : List Atom) : Bool :=
  reconstruct shape values == some source

theorem accepted_reconstruction_is_exact [DecidableEq Atom] [DecidableEq Scope]
    (source : Formula Atom Scope) (shape : Skeleton Scope) (values : List Atom)
    (accepted : matchesSource source shape values = true) :
    reconstruct shape values = some source := by
  simpa [matchesSource] using accepted

/- Exact reconstruction preserves any semantics, including predicates whose
   arguments refer to surrounding binders. No connective is prenexed here. -/
theorem accepted_reconstruction_preserves_interpretation
    [DecidableEq Atom] [DecidableEq Scope]
    (source rebuilt : Formula Atom Scope) (shape : Skeleton Scope) (values : List Atom)
    (interpret : Formula Atom Scope → Meaning)
    (accepted : matchesSource source shape values = true)
    (returned : reconstruct shape values = some rebuilt) :
    interpret source = interpret rebuilt := by
  have exactSource := accepted_reconstruction_is_exact source shape values accepted
  have same : source = rebuilt := Option.some.inj (exactSource.symm.trans returned)
  rw [same]

theorem splitting_a_shared_witness_rejects :
    matchesSource
      (Formula.quantified .some 0 (.binary .and (.atom 0) (.atom 1)))
      (.binary .and (.quantified .some 0 .hole) (.quantified .some 0 .hole))
      [0, 1] = false := by decide

theorem dropping_an_implication_branch_rejects :
    matchesSource (Formula.binary .implies (.atom 0) (.atom 1) : Formula Nat Nat)
      .hole [1] = false := by decide

theorem changing_quantifier_alternation_rejects :
    matchesSource
      (Formula.quantified .all 0 (.quantified .some 0 (.atom 0)))
      (.quantified .some 0 (.quantified .all 0 .hole)) [0] = false := by decide

theorem shared_witness_split_changes_semantics :
    [false, true].any (fun x => x && !x) = false ∧
      ([false, true].any id && [false, true].any (fun x => !x)) = true := by decide

theorem swapping_quantifiers_changes_semantics :
    [false, true].all (fun x => [false, true].any (fun y => x == y)) = true ∧
      [false, true].any (fun y => [false, true].all (fun x => x == y)) = false := by decide

end ACGN.ContractDecomposition

#print axioms ACGN.ContractDecomposition.refill_original_preserves_tail
#print axioms ACGN.ContractDecomposition.reconstruct_original
#print axioms ACGN.ContractDecomposition.every_formula_has_an_atom
#print axioms ACGN.ContractDecomposition.original_with_extra_atoms_rejects
#print axioms ACGN.ContractDecomposition.accepted_reconstruction_is_exact
#print axioms ACGN.ContractDecomposition.accepted_reconstruction_preserves_interpretation
#print axioms ACGN.ContractDecomposition.splitting_a_shared_witness_rejects
#print axioms ACGN.ContractDecomposition.dropping_an_implication_branch_rejects
#print axioms ACGN.ContractDecomposition.changing_quantifier_alternation_rejects
#print axioms ACGN.ContractDecomposition.shared_witness_split_changes_semantics
#print axioms ACGN.ContractDecomposition.swapping_quantifiers_changes_semantics
