import RetainedLexicalAliasInvariant
import PaidDeclarationAlignment
import ScopedPaidAdmission
import RetainedPaidCandidateUnion

/- Charge isolation for an actual paid outer declaration path beneath retained
   binders on both endpoints. This is an edit path, not predicate equivalence.
   Original lexical/type/owner checks and executable replay remain required. -/
namespace RetainedBothLocalPaid

abbrev Mapping := List (String × String)

structure Variable where
  name : String
  registered : Bool
  isLocal : Bool
  deriving DecidableEq, BEq

def lookup (mapping : Mapping) (name : String) : Option String :=
  (mapping.find? (fun entry => entry.1 == name)).map Prod.snd

def nameCost (mapping : Mapping) (source target : String) : Nat :=
  match lookup mapping source with
  | some name => if name = target then 0 else 1
  | none => if source = target ∧ target ∉ mapping.map Prod.snd then 0 else 1

-- The registered-variable branch and target-occupancy fallback mirror Java.
def variableCost (mapping : Mapping) (source target : Variable) : Nat :=
  if (source.registered = true ∨ target.registered = true) ∧
      ¬ (source.isLocal = true ∧ target.isLocal = true) ∧
      lookup mapping source.name = none then 1
  else nameCost mapping source.name target.name

theorem paid_outer_diagonal (mapping : Mapping) (source target : Variable)
    (paid : lookup mapping source.name = some target.name) :
    variableCost mapping source target = 0 := by
  simp [variableCost, nameCost, paid]

theorem unlinked_registered_outer (source target : Variable)
    (registered : source.registered = true ∨ target.registered = true)
    (outer : ¬ (source.isLocal = true ∧ target.isLocal = true)) :
    variableCost [] source target = 1 := by
  simp [variableCost, lookup, registered, outer]

theorem local_pair_unchanged (mapping : Mapping) (source target : Variable)
    (sourceLocal : source.isLocal = true) (targetLocal : target.isLocal = true)
    (noSourceKey : lookup mapping source.name = none)
    (noTargetImage : target.name ∉ mapping.map Prod.snd) :
    variableCost mapping source target = variableCost [] source target := by
  simp only [variableCost, sourceLocal, targetLocal, and_self, not_true_eq_false,
    false_and, and_false, ite_false, nameCost, noSourceKey]
  simp [lookup, noTargetImage]

theorem local_cannot_be_captured (mapping : Mapping) (source target : Variable)
    (sourceLocal : source.isLocal = true) (targetOuter : target.isLocal = false)
    (registered : source.registered = true)
    (noSourceKey : lookup mapping source.name = none) :
    variableCost mapping source target = 1 := by
  simp [variableCost, sourceLocal, targetOuter, registered, noSourceKey]

def localSeparation (mapping : Mapping) (pair : Variable × Variable) : Bool :=
  decide (pair.1.isLocal = true ∧ pair.2.isLocal = true ∧
    lookup mapping pair.1.name = none ∧ pair.2.name ∉ mapping.map Prod.snd)

theorem all_local_charges_unchanged (mapping : Mapping)
    (pairs : List (Variable × Variable))
    (checked : pairs.all (localSeparation mapping) = true) :
    pairs.map (fun pair => variableCost mapping pair.1 pair.2) =
      pairs.map (fun pair => variableCost [] pair.1 pair.2) := by
  apply List.map_congr_left
  intro pair member
  have facts := of_decide_eq_true ((List.all_eq_true.mp checked) pair member)
  exact local_pair_unchanged mapping pair.1 pair.2 facts.1 facts.2.1 facts.2.2.1 facts.2.2.2

-- Exact early branch of supportsSupplementalPair. The remaining owner/rigid
-- test is an explicit argument; no value of it bypasses the old rejection.
def oldSupplemental (supportedA supportedB localA localB remaining : Bool) : Bool :=
  if !supportedA || !supportedB then false
  else if localA == localB then false
  else remaining

theorem both_local_old_rejection (supportedA supportedB remaining : Bool) :
    oldSupplemental supportedA supportedB true true remaining = false := by
  simp [oldSupplemental]

theorem no_local_owner_transport (paid : Nat → Option Nat)
    (owners : List ScopedPaidAdmission.Frame) (slot : Nat) :
    ScopedPaidAdmission.link paid (.local owners slot) = some (.local owners slot) :=
  ScopedPaidAdmission.local_domain_type_order_unchanged paid owners slot

end RetainedBothLocalPaid
