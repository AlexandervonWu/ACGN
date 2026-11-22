import Std

namespace ACGN.Seventh.A217

/-- Same-head binary syntax. Each leaf is one maximal operand, regardless of its
type, spelling, or whether a second position has the same value. -/
inductive Chain (α : Type)
  | leaf (value : α)
  | branch (left right : Chain α)

abbrev Entry (α : Type) := List Bool × α

def enter (side : Bool) (e : Entry α) : Entry α := (side :: e.1, e.2)

/-- Projection order uses left-to-right traversal; false is child 0, true child 1. -/
def flatten : Chain α → List (Entry α)
  | .leaf v => [([], v)]
  | .branch l r => (flatten l).map (enter false) ++ (flatten r).map (enter true)

def width : Chain α → Nat
  | .leaf _ => 1
  | .branch l r => width l + width r

/-- Independent random access uses the left subtree's cardinality. -/
def select : Chain α → Nat → Option (Entry α)
  | .leaf v, 0 => some ([], v)
  | .leaf _, _ + 1 => none
  | .branch l r, i =>
    if i < width l then (select l i).map (enter false)
    else (select r (i - width l)).map (enter true)

def ordinalAt : Chain α → List Bool → Option Nat
  | .leaf _, [] => some 0
  | .branch l _, false :: tail => ordinalAt l tail
  | .branch l r, true :: tail => (ordinalAt r tail).map (width l + ·)
  | _, _ => none

theorem flatten_length (t : Chain α) : (flatten t).length = width t := by
  induction t with
  | leaf => rfl
  | branch l r hl hr => simp [flatten, width, hl, hr]

theorem select_agrees (t : Chain α) (i : Nat) :
    (flatten t)[i]? = select t i := by
  induction t generalizing i with
  | leaf v => cases i <;> rfl
  | branch l r hl hr =>
    simp [flatten, select, List.getElem?_append, List.getElem?_map, flatten_length, hl, hr]

theorem select_recovers_ordinal (t : Chain α) (i : Nat) (e : Entry α)
    (hit : select t i = some e) : ordinalAt t e.1 = some i := by
  induction t generalizing i e with
  | leaf v =>
    cases i with
    | zero =>
      simp [select] at hit
      subst e
      rfl
    | succ i => simp [select] at hit
  | branch l r hl hr =>
    by_cases left : i < width l
    · simp only [select, left, ↓reduceIte] at hit
      obtain ⟨child, found, rfl⟩ := Option.map_eq_some_iff.mp hit
      exact hl _ _ found
    · simp only [select, left, ↓reduceIte] at hit
      obtain ⟨child, found, rfl⟩ := Option.map_eq_some_iff.mp hit
      simp [enter, ordinalAt, hr _ _ found]
      omega

theorem repeated_values_keep_distinct_addresses (t : Chain α) (a b : Nat)
    (left right : Entry α) (ha : (flatten t)[a]? = some left)
    (hb : (flatten t)[b]? = some right) (different : a ≠ b) : left.1 ≠ right.1 := by
  rw [select_agrees] at ha hb
  have first := select_recovers_ordinal t a left ha
  have second := select_recovers_ordinal t b right hb
  intro same
  rw [same, second] at first
  exact different (Option.some.inj first.symm)

/-- An owner supplies a source tree; the observed projection claims the full
ordered sequence of addressed values for that owner. -/
def accepts [DecidableEq α] (owner : String) (t : Chain α)
    (presentedOwner : String) (observed : List (Entry α)) : Bool :=
  decide (owner = presentedOwner ∧ flatten t = observed)

theorem accepted_index (t : Chain α) [DecidableEq α] (owner presentedOwner : String)
    (observed : List (Entry α)) (i : Nat)
    (h : accepts owner t presentedOwner observed = true) :
    owner = presentedOwner ∧ observed[i]? = select t i := by
  obtain ⟨rfl, rfl⟩ : owner = presentedOwner ∧ flatten t = observed := by
    simpa [accepts] using h
  exact ⟨rfl, select_agrees _ _⟩

theorem mismatched_index_rejected (t : Chain α) [DecidableEq α] (owner presentedOwner : String)
    (observed : List (Entry α)) (i : Nat) (mismatch : observed[i]? ≠ select t i) :
    accepts owner t presentedOwner observed = false := by
  cases result : accepts owner t presentedOwner observed
  · rfl
  · exact False.elim (mismatch (accepted_index _ _ _ _ i result).2)

#print axioms flatten_length
#print axioms select_agrees
#print axioms select_recovers_ordinal
#print axioms repeated_values_keep_distinct_addresses
#print axioms accepted_index
#print axioms mismatched_index_rejected

end ACGN.Seventh.A217
