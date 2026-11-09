import Std

/- The original reference and its owner must be linked by the actual selected
   temporal correspondence. Equal ordinal lists alone do not supply payment.
   This models the additional premise; it is not a Java or source-wire proof. -/
namespace SelectedTemporalPayment

structure Reference where
  occurrence : Nat
  owner : Nat
  ownerRole : Nat
  type : Nat
  branches : List Nat
  operator : String

def PaidLink (selected : Nat → Option Nat) (a b : Reference) : Prop :=
  a.type = b.type ∧ a.branches = b.branches ∧ a.ownerRole = b.ownerRole ∧
  selected a.occurrence = some b.occurrence ∧ selected a.owner = some b.owner

def opCharge (a b : Reference) : Nat := if a.operator = b.operator then 0 else 1

theorem changed_discount_has_paid_update (selected : Nat → Option Nat)
    (a b : Reference) (link : PaidLink selected a b)
    (changed : a.operator ≠ b.operator) :
    selected a.occurrence = some b.occurrence ∧
    selected a.owner = some b.owner ∧ opCharge a b = 1 := by
  exact ⟨link.2.2.2.1, link.2.2.2.2, by simp [opCharge, changed]⟩

theorem unmatched_reference_cannot_discount (selected : Nat → Option Nat)
    (a b : Reference) (unmatched : selected a.occurrence = none) :
    ¬ PaidLink selected a b := by
  intro h
  have impossible := h.2.2.2.1
  rw [unmatched] at impossible
  cases impossible

theorem foreign_owner_cannot_discount (selected : Nat → Option Nat)
    (a b : Reference) (foreign : selected a.owner ≠ some b.owner) :
    ¬ PaidLink selected a b := fun h => foreign h.2.2.2.2

theorem identical_coordinates_are_not_a_link :
    ∃ a b : Reference, a.type = b.type ∧ a.branches = b.branches ∧
      ¬ PaidLink (fun _ => none) a b := by
  let a : Reference := ⟨2, 3, 0, 0, [1], "ALWAYS"⟩
  let b : Reference := ⟨1, 2, 0, 0, [1], "EVENTUALLY"⟩
  exact ⟨a, b, rfl, rfl, unmatched_reference_cannot_discount _ a b rfl⟩

#print axioms changed_discount_has_paid_update
#print axioms unmatched_reference_cannot_discount
#print axioms foreign_owner_cannot_discount
#print axioms identical_coordinates_are_not_a_link
end SelectedTemporalPayment

/- Typed phases mirror the skeleton's enumeration, including binary branch
   roles. A phase locator is not its type or occurrence authority. Deletion
   below is a paid repair edit (child promotion), not a formula equivalence. -/
namespace TypedTemporalPromotion
inductive PhaseKind where
  | none | before | historically | once | always | eventually | after
  | untilL | untilR | releasesL | releasesR | sinceL | sinceR | triggeredL | triggeredR
  deriving DecidableEq

structure Phase where
  occurrence : Nat
  kind : PhaseKind
  sourcePath : List Nat
  deriving DecidableEq

inductive Tree where
  | node (phase : Phase) (children : List Tree)

def wrap (path : List Phase) (forest : List Tree) : List Tree :=
  match path with
  | [] => forest
  | p :: ps => [.node p (wrap ps forest)]

def erase (expected : Phase) : List Tree → Option (List Tree)
  | [.node actual children] => if actual = expected then some children else none
  | _ => none

def replay : List Phase → List Tree → Option (List Tree × Nat)
  | [], forest => some (forest, 0)
  | p :: ps, forest => do
      let children ← erase p forest
      let (target, cost) ← replay ps children
      pure (target, cost + 1)

theorem selected_deleted_path_promotes (path : List Phase) (forest : List Tree) :
    replay path (wrap path forest) = some (forest, path.length) := by
  induction path with
  | nil => rfl
  | cons p ps ih => simp [replay, wrap, erase, ih]

theorem changed_phase_type_rejected (a b : Phase) (children : List Tree)
    (different : a.kind ≠ b.kind) : erase a [.node b children] = none := by
  have unequal : b ≠ a := by
    intro h
    exact different (congrArg Phase.kind h.symm)
  simp [erase, unequal]

theorem nonempty_path_is_paid (p : Phase) (ps : List Phase) (forest : List Tree) :
    replay (p :: ps) (wrap (p :: ps) forest) = some (forest, ps.length + 1) := by
  exact selected_deleted_path_promotes (p :: ps) forest

def eraseAt (expected : Phase) (before : List Tree) (focus : Tree) (after : List Tree) :
    Option (List Tree × Nat) := do
  let promoted ← erase expected [focus]
  pure (before ++ promoted ++ after, 1)

theorem deletion_preserves_ordered_context (p : Phase) (before children after : List Tree) :
    eraseAt p before (.node p children) after = some (before ++ children ++ after, 1) := by
  simp [eraseAt, erase]

structure LocatedPhase where
  source : Phase
  ordinal : Nat

def resolve (phases : List LocatedPhase) : List Phase := phases.map LocatedPhase.source

theorem reindex_preserves_typed_sources (phases : List LocatedPhase) (index : Nat → Nat) :
    resolve (phases.map fun p => {p with ordinal := index p.ordinal}) = resolve phases := by
  simp [resolve, List.map_map]

#print axioms selected_deleted_path_promotes
#print axioms changed_phase_type_rejected
#print axioms nonempty_path_is_paid
#print axioms deletion_preserves_ordered_context
#print axioms reindex_preserves_typed_sources
end TypedTemporalPromotion
