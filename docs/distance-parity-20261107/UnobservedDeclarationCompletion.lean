import Std

/- A declaration KEEP may complete a partial matrix correspondence when its
   source or target has no matrix occurrence. These are original owner-qualified
   coordinates, not names shared by distinct phases. No scope inference or
   source equivalence follows from this model theorem. -/
namespace UnobservedDeclarationCompletion

def extend (m : Nat → Option Nat) (a b x : Nat) : Option Nat :=
  if x = a then some b else m x

theorem completed_keep (m : Nat → Option Nat) (a b : Nat) :
    extend m a b a = some b := by simp [extend]

theorem old_link_preserved (m : Nat → Option Nat) (a b x y : Nat)
    (fresh : m a = none) (old : m x = some y) : extend m a b x = some y := by
  have h : x ≠ a := by intro e; subst x; simp [fresh] at old
  simp [extend, h, old]

theorem observed_link_unchanged (m : Nat → Option Nat) (a b x y : Nat)
    (leftSeen rightSeen : Nat → Prop) (fresh : m a = none)
    (absent : ¬ leftSeen a ∨ ¬ rightSeen b)
    (lx : leftSeen x) (ry : rightSeen y) :
    (extend m a b x = some y) ↔ m x = some y := by
  by_cases h : x = a
  · subst x
    have different : b ≠ y := by
      intro e
      rcases absent with noLeft | noRight
      · exact noLeft lx
      · exact noRight (e.symm ▸ ry)
    simp [extend, fresh, different]
  · simp [extend, h]

def variableCost (m : Nat → Option Nat) (x y : Nat) : Nat :=
  if m x = some y then 0 else 1

theorem observed_cost_unchanged (m : Nat → Option Nat) (a b x y : Nat)
    (leftSeen rightSeen : Nat → Prop) (fresh : m a = none)
    (absent : ¬ leftSeen a ∨ ¬ rightSeen b)
    (lx : leftSeen x) (ry : rightSeen y) :
    variableCost (extend m a b) x y = variableCost m x y := by
  simp only [variableCost, observed_link_unchanged m a b x y leftSeen rightSeen fresh absent lx ry]

theorem injective_extension (m : Nat → Option Nat) (a b : Nat)
    (injective : ∀ x z y, m x = some y → m z = some y → x = z)
    (freshTarget : ∀ x, m x ≠ some b) :
    ∀ x z y, extend m a b x = some y → extend m a b z = some y → x = z := by
  intro x z y hx hz
  by_cases xa : x = a <;> by_cases za : z = a
  · exact xa.trans za.symm
  · simp [extend, xa] at hx
    simp [extend, za] at hz
    exact False.elim (freshTarget z (hz.trans (congrArg some hx).symm))
  · simp [extend, za] at hz
    simp [extend, xa] at hx
    exact False.elim (freshTarget x (hx.trans (congrArg some hz).symm))
  · exact injective x z y (by simpa [extend, xa] using hx) (by simpa [extend, za] using hz)

#print axioms completed_keep
#print axioms old_link_preserved
#print axioms observed_link_unchanged
#print axioms observed_cost_unchanged
#print axioms injective_extension
end UnobservedDeclarationCompletion
