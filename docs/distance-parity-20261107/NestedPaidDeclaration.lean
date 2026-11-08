import Std

/- Paid outer declaration links do not rename retained local binders, move their
   domains, or assert any equality of the two repair endpoints. -/
namespace NestedPaidDeclaration

inductive Coordinate where
  | outer : Nat → Coordinate
  | local : Nat → Nat → Coordinate
deriving DecidableEq

def link (m : Nat → Option Nat) : Coordinate → Option Coordinate
  | .outer x => (m x).map Coordinate.outer
  | .local owner slot => some (.local owner slot)

theorem outer_requires_selected (m : Nat → Option Nat) (x y : Nat)
    (h : link m (.outer x) = some (.outer y)) : m x = some y := by
  cases hx : m x with
  | none => simp [link, hx] at h
  | some z => simpa [link, hx] using h

theorem local_owner_unchanged (m : Nat → Option Nat) (owner slot : Nat) :
    link m (.local owner slot) = some (.local owner slot) := rfl

theorem no_outer_capture (m : Nat → Option Nat) (x owner slot : Nat) :
    link m (.outer x) ≠ some (.local owner slot) := by
  cases hx : m x <;> simp [link, hx]

theorem source_admission_retained (m : Nat → Option Nat) (admitted : Nat → Nat → Prop)
    (checked : ∀ x y, m x = some y → admitted x y) (x y : Nat)
    (h : link m (.outer x) = some (.outer y)) : admitted x y :=
  checked x y (outer_requires_selected m x y h)

-- A concrete attaining declaration path: keep Person, update Person to
-- disjoint Project, insert disjoint Project. Disjointness is not erased.
abbrev Decl := Nat × Nat × Nat × Nat
def updateCost (a b : Decl) : Nat := if a = b then 0 else 1
def person : Decl := (0, 0, 1, 0)
def projectDisjoint : Decl := (0, 1, 1, 1)
theorem incident_declaration_charge :
    updateCost person person + updateCost person projectDisjoint + 1 = 2 := by decide

#print axioms outer_requires_selected
#print axioms no_outer_capture
#print axioms source_admission_retained
#print axioms incident_declaration_charge
end NestedPaidDeclaration
