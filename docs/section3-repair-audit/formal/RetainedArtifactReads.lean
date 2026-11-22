import Std

namespace ACGN.SixthFive.RetainedArtifactReads

/-- A row in the finite compiler census. The ordinal distinguishes different source
occurrences even when their consumer, target and endpoint spellings coincide. -/
structure Site where
  origin : String
  owner : String
  method : String
  occurrence : Nat
  target : String
  endpoint : String
  deriving DecidableEq, Repr

/-- Observe every requested occurrence against its own full key, in request order. -/
def observe (lookup : Site → Option α) : List Site → Option (List α)
  | [] => some []
  | request :: rest =>
    match lookup request, observe lookup rest with
    | some value, some values => some (value :: values)
    | _, _ => none

theorem complete_observation (value : Site → α) (requests : List Site) :
    observe (fun s => some (value s)) requests = some (requests.map value) := by
  induction requests with
  | nil => rfl
  | cons x xs ih => simp [observe, ih]

/-- An arbitrary missing read invalidates the *whole* observation. -/
theorem missing_observation (lookup : Site → Option α) (wanted : Site) (requests : List Site)
    (required : wanted ∈ requests) (missing : lookup wanted = none) :
    observe lookup requests = none := by
  induction requests with
  | nil => simp at required
  | cons x xs ih =>
    rcases List.mem_cons.mp required with equal | later
    · subst x
      simp [observe, missing]
    · cases lookup x <;> simp [observe, *, ih later]

/-- Move the entry at source to a new address, retaining other entries verbatim. -/
def moveEntry (lookup : Site → Option α) (source destination request : Site) : Option α :=
  if request = destination then lookup source
  else if request = source then none
  else lookup request

theorem detached_entry_rejected (lookup : Site → Option α) (source destination : Site)
    (requests : List Site) (required : source ∈ requests) (different : source ≠ destination) :
    observe (moveEntry lookup source destination) requests = none := by
  apply missing_observation _ source _ required
  simp [moveEntry, different]

theorem wrong_owner_rejected (lookup : Site → Option α) (source destination : Site)
    (requests : List Site) (required : source ∈ requests)
    (differentOwner : source.owner ≠ destination.owner) :
    observe (moveEntry lookup source destination) requests = none := by
  apply detached_entry_rejected _ _ _ _ required
  intro h
  exact differentOwner (congrArg Site.owner h)

theorem wrong_endpoint_rejected (lookup : Site → Option α) (source destination : Site)
    (requests : List Site) (required : source ∈ requests)
    (differentEndpoint : source.endpoint ≠ destination.endpoint) :
    observe (moveEntry lookup source destination) requests = none := by
  apply detached_entry_rejected _ _ _ _ required
  intro h
  exact differentEndpoint (congrArg Site.endpoint h)

theorem wrong_occurrence_rejected (lookup : Site → Option α) (source destination : Site)
    (requests : List Site) (required : source ∈ requests)
    (differentOccurrence : source.occurrence ≠ destination.occurrence) :
    observe (moveEntry lookup source destination) requests = none := by
  apply detached_entry_rejected _ _ _ _ required
  intro h
  exact differentOccurrence (congrArg Site.occurrence h)

#print axioms complete_observation
#print axioms missing_observation
#print axioms detached_entry_rejected
#print axioms wrong_owner_rejected
#print axioms wrong_endpoint_rejected
#print axioms wrong_occurrence_rejected

end ACGN.SixthFive.RetainedArtifactReads
