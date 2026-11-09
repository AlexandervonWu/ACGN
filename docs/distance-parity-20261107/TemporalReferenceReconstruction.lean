import Std

/- Repair operates on the product of a temporal skeleton and matrix slots.
   A zero matrix-slot edit is not an equality of temporal operators. Its full
   typed payload is reconstructed from the independently executed skeleton.
   This is a model contract, not Java/Alloy implementation correspondence. -/
namespace TemporalReferenceReconstruction

inductive Kind where
  | none | before | historically | once | always | eventually | after
  | untilL | untilR | releasesL | releasesR | sinceL | sinceR | triggeredL | triggeredR
  deriving DecidableEq

structure Phase where
  sourcePath : List Nat
  kind : Kind
  owner : Option Nat
  role : Nat
  deriving DecidableEq

structure Slot where
  owner : Nat
  localSlot : Nat
  arity : Nat
  deriving DecidableEq

structure Edge where
  owner : Phase
  branches : List Phase
  deriving DecidableEq

abbrev Skeleton := Slot → Option Edge

structure Edit where
  address : Slot
  before : Option Edge
  after : Option Edge
  charge : Nat

def applyEdit (state : Skeleton) (edit : Edit) : Option Skeleton :=
  if state edit.address = edit.before then
    some (fun address => if address = edit.address then edit.after else state address)
  else none

def execute : List Edit → Skeleton → Option (Skeleton × Nat)
  | [], state => some (state, 0)
  | edit :: rest, state => do
      let next ← applyEdit state edit
      let (target, cost) ← execute rest next
      pure (target, edit.charge + cost)

def reconstitute (program : List Edit) (source : Skeleton)
    (slot : Slot) (before : Edge) : Option (Edge × Nat) := do
  if source slot ≠ some before then none else do
    let (target, paid) ← execute program source
    let after ← target slot
    pure (after, paid)

theorem selected_skeleton_reconstructs_typed_reference
    (program : List Edit) (source target : Skeleton) (slot : Slot)
    (before after : Edge) (paid : Nat)
    (selected : execute program source = some (target, paid))
    (sourceLink : source slot = some before) (targetLink : target slot = some after) :
    reconstitute program source slot before = some (after, paid) := by
  simp [reconstitute, sourceLink, selected, targetLink]

theorem foreign_source_rejected (program : List Edit) (source : Skeleton)
    (slot : Slot) (before : Edge) (foreign : source slot ≠ some before) :
    reconstitute program source slot before = none := by
  simp [reconstitute, foreign]

theorem stale_edit_rejected (source : Skeleton) (edit : Edit)
    (stale : source edit.address ≠ edit.before) : applyEdit source edit = none := by
  simp [applyEdit, stale]

theorem complete_payload_preserved (a b : Edge) (equal : a = b) :
    a.owner = b.owner ∧ a.branches = b.branches := by
  cases equal
  exact ⟨rfl, rfl⟩

/- Canonical ACI order chooses reference groups. Each binary group's original
   ordered roles are reserved together before its descendants, as in IRAgent.
   This does not assert that arbitrary phase permutations preserve cost. -/
def reserveBinary (left right : Phase) (leftDesc rightDesc : List Phase) : List Phase :=
  [left, right] ++ leftDesc ++ rightDesc

theorem binary_roles_reserved_before_descendants (left right : Phase)
    (leftDesc rightDesc : List Phase) :
    (reserveBinary left right leftDesc rightDesc).take 2 = [left, right] := by
  simp [reserveBinary]

theorem reserved_roles_not_exchanged (left right : Phase)
    (leftDesc rightDesc : List Phase) (different : left.kind ≠ right.kind) :
    (reserveBinary left right leftDesc rightDesc).take 2 ≠ [right, left] := by
  simp only [binary_roles_reserved_before_descendants]
  intro same
  have h : left = right := (List.cons.inj same).1
  exact different (congrArg Phase.kind h)

#print axioms selected_skeleton_reconstructs_typed_reference
#print axioms foreign_source_rejected
#print axioms stale_edit_rejected
#print axioms complete_payload_preserved
#print axioms binary_roles_reserved_before_descendants
#print axioms reserved_roles_not_exchanged
end TemporalReferenceReconstruction
