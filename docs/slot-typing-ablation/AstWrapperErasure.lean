import Lean
set_option autoImplicit false

namespace AstWrapperErasure

-- Labels carry all non-wrapper metadata: operator, type, binding, scope,
-- phase and source identity. Child coordinates retain their original order.
inductive Tree (Label : Type) where
  | node (label : Label) (arity : Nat) (child : Fin arity -> Tree Label)
  | noop (child : Tree Label)
  | body (child : Tree Label)

def erase {Label : Type} : Tree Label -> Tree Label
  | .node label arity child => .node label arity (fun i => erase (child i))
  | .noop child => erase child
  | .body child => erase child

def interpret {Label Value : Type}
    (algebra : (label : Label) -> (arity : Nat) -> (Fin arity -> Value) -> Value) :
    Tree Label -> Value
  | .node label arity child => algebra label arity (fun i => interpret algebra (child i))
  | .noop child => interpret algebra child
  | .body child => interpret algebra child

theorem preserves_interpretation {Label Value : Type}
    (algebra : (label : Label) -> (arity : Nat) -> (Fin arity -> Value) -> Value)
    (tree : Tree Label) : interpret algebra (erase tree) = interpret algebra tree := by
  induction tree with
  | node label arity child ih => simp only [erase, interpret, ih]
  | noop child ih => exact ih
  | body child ih => exact ih

theorem idempotent {Label : Type} (tree : Tree Label) :
    erase (erase tree) = erase tree := by
  induction tree with
  | node label arity child ih => simp only [erase, ih]
  | noop child ih => exact ih
  | body child ih => exact ih

theorem retains_label_and_coordinates {Label : Type} (label : Label)
    (arity : Nat) (child : Fin arity -> Tree Label) :
    erase (.node label arity child) = .node label arity (fun i => erase (child i)) := rfl

-- Any tree reader/editor operating on this view cannot observe wrapper insertion.
theorem wrapper_invariant {Label Result : Type} (reader : Tree Label -> Result)
    (tree : Tree Label) : reader (erase (.noop tree)) = reader (erase tree) := rfl

theorem body_invariant {Label Result : Type} (reader : Tree Label -> Result)
    (tree : Tree Label) : reader (erase (.body tree)) = reader (erase tree) := rfl

-- Wrapper edges consume no semantic coordinate. Every other child edge does.
def lookup {Label : Type} : Tree Label -> List Nat -> Option Label
  | .noop child, path => lookup child path
  | .body child, path => lookup child path
  | .node label _ _, [] => some label
  | .node _ arity child, index :: rest =>
      if h : index < arity then lookup (child ⟨index, h⟩) rest else none

theorem occurrence_correspondence {Label : Type} (tree : Tree Label) (path : List Nat) :
    lookup (erase tree) path = lookup tree path := by
  induction tree generalizing path with
  | node label arity child ih =>
      cases path with
      | nil => rfl
      | cons index rest => simp only [erase, lookup, ih]
  | noop child ih => exact ih path
  | body child ih => exact ih path

#print axioms preserves_interpretation
#print axioms idempotent
#print axioms retains_label_and_coordinates
#print axioms wrapper_invariant
#print axioms body_invariant
#print axioms occurrence_correspondence

end AstWrapperErasure
