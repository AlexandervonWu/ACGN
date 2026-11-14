import ClosedTemporalPhase
import Focused225CallViews

/- The temporal operator is applied to bodies in ONE unchanged inherited
   valuation. Owned declarations, local imports and ordered temporal roles are
   not identified. Java must authenticate each resolved Slot against the common
   original owner; equal display names do not establish this premise. -/
namespace InheritedTemporalPhase
open ScopedCallCorrespondence Focused225CallViews

structure Gate where
  params : Nat
  declarations : Nat
  inherited : Nat
  localImports : Nat
  localSeeds : Nat
  children : Nat
  operator : String
  deriving DecidableEq

def unary (operator : String) : Bool :=
  ["ALWAYS", "EVENTUALLY", "AFTER", "BEFORE", "HISTORICALLY", "ONCE"].contains operator

-- Exact pre-change closedComparisonPhase predicate, including unused imports.
def oldGate (g : Gate) : Bool :=
  decide (g.params = 0 ∧ g.declarations = 0 ∧ g.inherited = 0 ∧
    g.localImports = 0 ∧ g.localSeeds = 0 ∧ g.children = 0) && unary g.operator

def leafGate (g : Gate) : Bool :=
  decide (g.params = 0 ∧ g.declarations = 0 ∧
    g.localImports = 0 ∧ g.localSeeds = 0 ∧ g.children = 0) && unary g.operator

def body {V : Type} (environment : Slot → V)
    (operation : Head → List V → V) (shape : Shape) : Option V :=
  (decode shape).map (eval environment operation)

theorem same_owned_body {V : Type} (environment : Slot → V)
    (operation : Head → List V → V) (left right : Shape)
    (checkedKey : left = right) :
    body environment operation left = body environment operation right := by
  rw [checkedKey]

-- Global symbols may vary with time; inherited variables retain the original
-- valuation. This does not commute a quantifier through a temporal operator.
theorem same_inherited_phase {V W : Type} (environment : Slot → V)
    (operation : W → Head → List V → V) (holds : Option V → Prop)
    (temporal : (W → Prop) → W → Prop) (left right : Shape)
    (checkedKey : left = right) :
    ∀ w, temporal (fun t => holds (body environment (operation t) left)) w ↔
      temporal (fun t => holds (body environment (operation t) right)) w := by
  apply ClosedTemporalPhase.same_operator
  intro t
  rw [same_owned_body environment (operation t) left right checkedKey]

theorem inherited_and_duplicate {V W : Type} (environment : Slot → V)
    (operation : W → Head → List V → V) (holds : Option V → Prop)
    (temporal : (W → Prop) → W → Prop) (left right : Shape)
    (checkedKey : left = right) (rest : W → Prop) (w : W) :
    (temporal (fun t => holds (body environment (operation t) left)) w ∧
      temporal (fun t => holds (body environment (operation t) right)) w ∧ rest w) ↔
    (temporal (fun t => holds (body environment (operation t) left)) w ∧ rest w) :=
  ClosedTemporalPhase.and_drop_duplicate _ _ _
    (same_inherited_phase environment operation holds temporal left right checkedKey w)

theorem inherited_or_duplicate {V W : Type} (environment : Slot → V)
    (operation : W → Head → List V → V) (holds : Option V → Prop)
    (temporal : (W → Prop) → W → Prop) (left right : Shape)
    (checkedKey : left = right) (rest : W → Prop) (w : W) :
    (temporal (fun t => holds (body environment (operation t) left)) w ∨
      temporal (fun t => holds (body environment (operation t) right)) w ∨ rest w) ↔
    (temporal (fun t => holds (body environment (operation t) left)) w ∨ rest w) :=
  ClosedTemporalPhase.or_drop_duplicate _ _ _
    (same_inherited_phase environment operation holds temporal left right checkedKey w)

theorem different_owner_not_equal (a b : Slot) (different : a.owner ≠ b.owner) :
    Shape.variable a ≠ Shape.variable b := by
  intro same
  have slots : a = b := Shape.variable.inj same
  exact different (congrArg Slot.owner slots)

theorem inherited_metadata_old_rejection (g : Gate) (usedOrUnused : g.inherited ≠ 0) :
    oldGate g = false := by simp [oldGate, usedOrUnused]

end InheritedTemporalPhase
