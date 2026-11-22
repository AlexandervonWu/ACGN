/- The boundary starts at an adapter result and already frozen NormalForm objects.
   Object references are represented by tokens. The Java regression checks the
   ownership test, snapshot consumption and digest at the production entry point. -/
namespace Sixth.FrozenProjectionSnapshot

abbrev Ref := Nat

structure Phase where
  payload : String
  frozen : Bool
deriving DecidableEq

abbrev Heap := Ref → Phase

structure AdapterResult where
  orderedSources : List Ref
  canonicalKey : String

structure View where
  /-- Phase reads at the projection input, before canonical output reordering. -/
  observedPhases : List Phase
  digest : String
deriving DecidableEq

def validSnapshot (heap : Heap) (result : AdapterResult) (snapshot : List Ref) : Bool :=
  snapshot == result.orderedSources && snapshot.all (fun r => (heap r).frozen)

def project (digestOf : String → String) (heap : Heap) (result : AdapterResult)
    (snapshot : List Ref) : Option View :=
  if validSnapshot heap result snapshot then
    some ⟨snapshot.map heap, digestOf result.canonicalKey⟩
  else none

theorem admission_iff (heap : Heap) (result : AdapterResult) (snapshot : List Ref) :
    validSnapshot heap result snapshot = true ↔
      snapshot = result.orderedSources ∧ ∀ r ∈ snapshot, (heap r).frozen = true := by
  simp [validSnapshot, List.all_eq_true]

theorem successful_projection (digestOf : String → String) (heap : Heap)
    (result : AdapterResult) (snapshot : List Ref) (view : View)
    (accepted : project digestOf heap result snapshot = some view) :
    snapshot = result.orderedSources ∧
      (∀ r ∈ snapshot, (heap r).frozen = true) ∧
      view.observedPhases = result.orderedSources.map heap ∧
      view.digest = digestOf result.canonicalKey := by
  unfold project at accepted
  split at accepted
  next ok =>
    obtain ⟨owned, frozen⟩ := (admission_iff heap result snapshot).mp ok
    cases accepted
    exact ⟨owned, frozen, by rw [owned], rfl⟩
  next _ => contradiction

theorem foreign_phase_order_rejects (digestOf : String → String) (heap : Heap)
    (result : AdapterResult) (snapshot : List Ref) (changed : snapshot ≠ result.orderedSources) :
    project digestOf heap result snapshot = none := by
  simp [project, validSnapshot, beq_eq_false_iff_ne.mpr changed]

theorem no_foreign_digest (digestOf : String → String) (heap : Heap)
    (result : AdapterResult) (snapshot : List Ref) (view : View)
    (changed : view.digest ≠ digestOf result.canonicalKey) :
    project digestOf heap result snapshot ≠ some view := by
  intro accepted
  exact changed (successful_projection digestOf heap result snapshot view accepted).2.2.2

/-- The modeled NormalForm mutator reads the target's frozen bit before updating. -/
def writePhase (heap : Heap) (write : Ref × String) : Heap :=
  fun r => if r = write.1 ∧ (heap r).frozen = false then
    { heap r with payload := write.2 }
  else heap r

theorem writes_preserve_frozen (heap : Heap) (r : Ref) (frozen : (heap r).frozen = true)
    (writes : List (Ref × String)) : writes.foldl writePhase heap r = heap r := by
  induction writes generalizing heap with
  | nil => rfl
  | cons w ws ih =>
    have step : writePhase heap w r = heap r := by simp [writePhase, frozen]
    simpa only [List.foldl_cons, step] using
      (ih (writePhase heap w) (by simpa only [step] using frozen))

theorem owned_observations_stable (heap : Heap) (result : AdapterResult)
    (snapshot : List Ref) (ok : validSnapshot heap result snapshot = true)
    (writes : List (Ref × String)) :
    snapshot.map (writes.foldl writePhase heap) = result.orderedSources.map heap := by
  obtain ⟨owned, frozen⟩ := (admission_iff heap result snapshot).mp ok
  rw [← owned]
  exact List.map_congr_left fun r hr => writes_preserve_frozen heap r (frozen r hr) writes

end Sixth.FrozenProjectionSnapshot

#print axioms Sixth.FrozenProjectionSnapshot.admission_iff
#print axioms Sixth.FrozenProjectionSnapshot.successful_projection
#print axioms Sixth.FrozenProjectionSnapshot.foreign_phase_order_rejects
#print axioms Sixth.FrozenProjectionSnapshot.no_foreign_digest
#print axioms Sixth.FrozenProjectionSnapshot.writes_preserve_frozen
#print axioms Sixth.FrozenProjectionSnapshot.owned_observations_stable
