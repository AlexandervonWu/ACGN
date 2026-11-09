import Std

namespace SelectedReferenceProvenance

-- Tokens denote identities registered from actual objects in one capture.
-- They are not structural hashes and have no authority across captures.
structure Origin where
  matrixObject : Nat
  authority : Nat
  parserOccurrence : Nat
  sourceOccurrence : Nat
  ownerObject : Nat
  branchObjects : List Nat
  deriving DecidableEq, Repr

structure Endpoint where
  ownerObject : Nat
  branchObjects : List Nat
  ownerPhase : Nat
  ownerRole : Nat
  sourceSlot : Nat
  temporalOccurrence : Nat
  deriving DecidableEq, Repr

structure Binding where
  origin : Origin
  endpoint : Endpoint
  paymentObject : Nat
  deriving DecidableEq, Repr

def capture (members : List Nat) (actualPayment requestedPayment : Nat)
    (origin : Origin) (endpoint : Endpoint) : Option Binding :=
  if origin.matrixObject ∈ members ∧ actualPayment = requestedPayment ∧
      origin.ownerObject = endpoint.ownerObject ∧
      origin.branchObjects = endpoint.branchObjects then
    some ⟨origin, endpoint, actualPayment⟩
  else none

theorem capture_exact (members : List Nat) (actual requested : Nat)
    (origin : Origin) (endpoint : Endpoint) (result : Binding)
    (h : capture members actual requested origin endpoint = some result) :
    origin.matrixObject ∈ members ∧ actual = requested ∧
    origin.ownerObject = endpoint.ownerObject ∧
    origin.branchObjects = endpoint.branchObjects ∧
    result = ⟨origin, endpoint, actual⟩ := by
  unfold capture at h
  split at h
  · rename_i checks
    exact ⟨checks.1, checks.2.1, checks.2.2.1, checks.2.2.2,
      (Option.some.inj h).symm⟩
  · cases h

theorem foreign_object_rejected (members : List Nat) (actual requested : Nat)
    (origin : Origin) (endpoint : Endpoint) (h : origin.matrixObject ∉ members) :
    capture members actual requested origin endpoint = none := by simp [capture, h]

theorem wrong_owner_rejected (members : List Nat) (actual requested : Nat)
    (origin : Origin) (endpoint : Endpoint) (h : origin.ownerObject ≠ endpoint.ownerObject) :
    capture members actual requested origin endpoint = none := by simp [capture, h]

theorem wrong_branches_rejected (members : List Nat) (actual requested : Nat)
    (origin : Origin) (endpoint : Endpoint) (h : origin.branchObjects ≠ endpoint.branchObjects) :
    capture members actual requested origin endpoint = none := by simp [capture, h]

theorem wrong_payment_rejected (members : List Nat) (actual requested : Nat)
    (origin : Origin) (endpoint : Endpoint) (h : actual ≠ requested) :
    capture members actual requested origin endpoint = none := by simp [capture, h]

theorem capture_retains_coordinates (members : List Nat) (actual requested : Nat)
    (origin : Origin) (endpoint : Endpoint) (result : Binding)
    (h : capture members actual requested origin endpoint = some result) :
    result.endpoint = endpoint ∧ result.origin = origin := by
  obtain ⟨_, _, _, _, rfl⟩ := capture_exact members actual requested origin endpoint result h
  exact ⟨rfl, rfl⟩

-- The contract retains evidence; it neither changes edit costs nor proves
-- Java extraction faithful. Fresh source-linked runtime bindings discharge
-- that separate finite correspondence obligation.
#print axioms capture_exact
#print axioms foreign_object_rejected
#print axioms wrong_owner_rejected
#print axioms wrong_branches_rejected
#print axioms wrong_payment_rejected
#print axioms capture_retains_coordinates
end SelectedReferenceProvenance
