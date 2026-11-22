import Category72Contracts
import RetainedOwnerAdmission

/- Owner registration is not evaluation or graph deduplication. Every visit
   still checks its body, lexical reads, and invocation maps. Only the demand
   that an issued binding appear once in the traversal is replaced. -/
namespace RetainedOwnerRevisits
open SelectedDeclarationCompletion

structure SlotOrigin where
  owner : Nat
  parent : Option Nat
  declaration : Nat
  variableId : Nat
  ordinal : Nat
  source : Origin
  deriving DecidableEq

abbrev Registry := Nat → Option SlotOrigin

def register (issued : Registry) (slot : Nat) (actual : SlotOrigin) : Option Registry :=
  match issued slot with
  | none => some (fun i => if i = slot then some actual else issued i)
  | some prior => if prior = actual then some issued else none

-- Exact old !usedOwners.add(q.getName()) refusal after the first visit.
def oldRegister (used : List Nat) (slot : Nat) : Bool := decide (slot ∉ used)

theorem repeated_registration (issued : Registry) (slot : Nat) (actual : SlotOrigin)
    (found : issued slot = some actual) : register issued slot actual = some issued := by
  simp [register, found]

theorem foreign_registration_rejected (issued : Registry) (slot : Nat)
    (prior actual : SlotOrigin) (found : issued slot = some prior) (different : prior ≠ actual) :
    register issued slot actual = none := by simp [register, found, different]

theorem successful_revisit_is_exact (issued next : Registry) (slot : Nat)
    (prior actual : SlotOrigin) (found : issued slot = some prior)
    (accepted : register issued slot actual = some next) : actual = prior ∧ next = issued := by
  unfold register at accepted
  by_cases same : prior = actual
  · simp [found, same] at accepted
    exact ⟨same.symm, accepted.symm⟩
  · simp [found, same] at accepted

theorem typed_read_unchanged (issued next : Registry) (slot : Nat)
    (prior actual : SlotOrigin) (found : issued slot = some prior)
    (accepted : register issued slot actual = some next)
    (values : SlotOrigin → Value) : values actual = values prior := by
  rw [(successful_revisit_is_exact issued next slot prior actual found accepted).1]

-- The emitted ordered visit list is untouched, including duplicate charges.
def checkVisits (validate : SlotOrigin → Bool) (visits : List SlotOrigin) : Bool := visits.all validate

theorem every_visit_checked (validate : SlotOrigin → Bool) (visits : List SlotOrigin)
    (accepted : checkVisits validate visits = true) :
    ∀ visit ∈ visits, validate visit = true := List.all_eq_true.mp accepted

theorem repeated_visits_preserve_validation (validate : SlotOrigin → Bool)
    (visits : List SlotOrigin) :
    checkVisits validate (visits ++ visits) = checkVisits validate visits := by
  simp [checkVisits, List.all_append]

/- Extracted owner/declaration/variable coordinates from owner-c/owners.json.
   These are source occurrence coordinates, never a production case switch.
   Module-local lineage values are bound to that exact hashed probe run. -/
def stateSlot : SlotOrigin := ⟨2085, none, 2088, 2091, 0,
  ⟨"f4718370b6661156be755ecab3317b7d7d6f04d465a13d21566f9d679a6599fd", "inv4",
    "2091", "2085", 0, "local", [], [], "RELATION[5:State]", "State",
    "COMPREHENSION", "ONE", 0⟩⟩

def eventSlot : SlotOrigin := ⟨2089, some 2085, 2093, 2097, 0,
  ⟨stateSlot.source.sourceHash, "inv4", "2097", "2089", 0, "local", [], [],
    "RELATION[5:Event]", "Event", "SOME", "ONE", 0⟩⟩

def sourceRegistry : Registry := fun i => if i = 5 then some stateSlot else if i = 7 then some eventSlot else none

theorem measured_old_rejections : oldRegister [5,6,7] 5 = false ∧ oldRegister [5,6,7] 7 = false := by decide
theorem measured_state_revisit : register sourceRegistry 5 stateSlot = some sourceRegistry := by
  apply repeated_registration; rfl
theorem measured_event_revisit : register sourceRegistry 7 eventSlot = some sourceRegistry := by
  apply repeated_registration; rfl
theorem foreign_parent_rejected : register sourceRegistry 5 {stateSlot with parent := some 2089} = none := by
  apply foreign_registration_rejected sourceRegistry 5 stateSlot _ rfl
  decide
theorem foreign_ordinal_rejected : register sourceRegistry 5 {stateSlot with ordinal := 1} = none := by
  apply foreign_registration_rejected sourceRegistry 5 stateSlot _ rfl
  decide
theorem foreign_type_rejected : register sourceRegistry 5
    {stateSlot with source := {stateSlot.source with exactType := "RELATION[5:Event]"}} = none := by
  apply foreign_registration_rejected sourceRegistry 5 stateSlot _ rfl
  decide

-- The repeated comprehension in the source contains two State columns and
-- an existential Event. Registration changes neither relation nor its uses.
theorem measured_typed_relation (states : S → Prop) (events : E → Prop)
    (trans : S → E → S → Prop) (context : (S → S → Prop) → Result) :
    context (fun x y => states x ∧ states y ∧ ∃ e, events e ∧ trans x e y) =
      context (RetainedOwnerAdmission.naturalRelation states events trans) := rfl

end RetainedOwnerRevisits
