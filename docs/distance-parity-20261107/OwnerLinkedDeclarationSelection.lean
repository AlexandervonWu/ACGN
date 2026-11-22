import JointDeclarationPathSelection
import NativeDeclarationTraceCoherence
import PaidOrbitTieOrder

namespace OwnerLinkedDeclarationSelection
open SelectedDeclarationCompletion SelectedDeclarationPathTransport

-- Components retain their owner-qualified bindings; inherited read sites are
-- references into these vectors, not additional declarations or payments.
def collected (components : List (List Step)) : List Step := components.flatten

theorem cost_append (a b : List Step) : cost (a ++ b) = cost a + cost b := by
  simp [cost, List.map_append, List.sum_append]

theorem component_costs (components : List (List Step)) :
    cost (collected components) = (components.map cost).sum := by
  induction components with
  | nil => rfl
  | cons head tail ih => simpa [collected, cost_append] using congrArg (cost head + ·) ih

theorem collected_replay (components : List (List Step)) :
    replay (sources (collected components)) (collected components) =
      some (targets (collected components), (components.map cost).sum) := by
  rw [extracted_path_replays, component_costs]

def moveAgrees (selected : List (Option Nat)) : Step → Bool
  | .pair a b => selected[a.vectorIndex]? == some (some b.vectorIndex)
  | .delete a => selected[a.vectorIndex]? == some none
  | .insert b => selected.all (fun value => value != some b.vectorIndex)

def recognized (source target : List Binding) (sp tp : Binding → Bool)
    (selected : List (Option Nat)) (components : List (List Step)) : Bool :=
  admissible source target sp tp (collected components) &&
    (collected components).all (moveAgrees selected)

def oldPhaseGate (leftPhases rightPhases : Nat) : Bool :=
  leftPhases == 1 && rightPhases == 1

def oldRecognized (leftPhases rightPhases : Nat) (source target : List Binding)
    (sp tp : Binding → Bool) (selected : List (Option Nat)) (components : List (List Step)) : Bool :=
  oldPhaseGate leftPhases rightPhases && recognized source target sp tp selected components

theorem old_guard_rejects_multiple (a b : Nat) (multiple : a ≠ 1 ∨ b ≠ 1) :
    oldPhaseGate a b = false := by
  rcases multiple with h | h <;> simp [oldPhaseGate, h]

theorem recognition_preserves_admission (source target : List Binding) (sp tp : Binding → Bool)
    (selected : List (Option Nat)) (components : List (List Step))
    (accepted : recognized source target sp tp selected components = true) :
    admissible source target sp tp (collected components) = true := by
  simp only [recognized, Bool.and_eq_true] at accepted
  exact accepted.1

theorem recognition_checks_every_move (source target : List Binding) (sp tp : Binding → Bool)
    (selected : List (Option Nat)) (components : List (List Step)) (step : Step)
    (accepted : recognized source target sp tp selected components = true)
    (member : step ∈ collected components) : moveAgrees selected step = true := by
  simp only [recognized, Bool.and_eq_true] at accepted
  exact List.all_eq_true.mp accepted.2 step member

theorem paired_coordinate (selected : List (Option Nat)) (a b : Binding)
    (checked : moveAgrees selected (.pair a b) = true) :
    selected[a.vectorIndex]? = some (some b.vectorIndex) := by
  simpa [moveAgrees] using checked

theorem deleted_coordinate (selected : List (Option Nat)) (a : Binding)
    (checked : moveAgrees selected (.delete a) = true) :
    selected[a.vectorIndex]? = some none := by
  simpa [moveAgrees] using checked

theorem inserted_coordinate (selected : List (Option Nat)) (b : Binding)
    (checked : moveAgrees selected (.insert b) = true) (value : Option Nat)
    (member : value ∈ selected) : value ≠ some b.vectorIndex := by
  have h := List.all_eq_true.mp checked value member
  simpa using h

theorem collected_partial_injection (components : List (List Step))
    (sourceUnique : ((sources (collected components)).map Binding.vectorIndex).Nodup)
    (targetUnique : ((targets (collected components)).map Binding.vectorIndex).Nodup)
    (a b : Link) (ha : a ∈ links (collected components)) (hb : b ∈ links (collected components)) :
    (a.1.vectorIndex = b.1.vectorIndex → a = b) ∧
    (a.2.vectorIndex = b.2.vectorIndex → a = b) :=
  extracted_links_partial_injection _ sourceUnique targetUnique a b ha hb

theorem recognized_typed_read {Value : String → Type}
    (environment : (a : Binding) → Value a.origin.exactType)
    (source target : List Binding) (sp tp : Binding → Bool)
    (selected : List (Option Nat)) (components : List (List Step)) (a b : Binding)
    (accepted : recognized source target sp tp selected components = true)
    (unique : ((targets (collected components)).map Binding.vectorIndex).Nodup)
    (member : (a,b) ∈ links (collected components)) (zero : sameTuple a b = true) :
    target[b.vectorIndex]? = some b ∧ ∃ value : Value b.origin.exactType,
      targetRead environment (collected components) b = some value ∧ HEq value (environment a) :=
  selected_target_typed_read environment source target sp tp _ a b
    (recognition_preserves_admission source target sp tp selected components accepted) unique member zero

theorem inherited_read_same_owner {Value : Type} (environment : Nat → Value)
    (phaseOwner otherPhaseOwner : Nat → Nat) (i j owner : Nat)
    (first : phaseOwner i = owner) (second : otherPhaseOwner j = owner) :
    environment (phaseOwner i) = environment (otherPhaseOwner j) := by rw [first, second]

-- Recognition changes only the priority among actual evaluated witnesses.
-- No new matrix map is evaluated on the newly recognized multi-phase path.
theorem linked_tie_preferred (best next : PaidOrbitTieOrder.Key)
    (sameCost : next.cost = best.cost) (sameCanonical : next.canonical = best.canonical)
    (nextLinked : next.linked = true) (bestUnlinked : best.linked = false) :
    PaidOrbitTieOrder.oldPrefer best next = true := by
  simp [PaidOrbitTieOrder.oldPrefer, sameCost, sameCanonical, nextLinked, bestUnlinked]

def choose {A : Type} (key : A → PaidOrbitTieOrder.Key) (best next : A) : A :=
  if PaidOrbitTieOrder.oldPrefer (key best) (key next) then next else best

theorem chosen_is_actual {A : Type} (key : A → PaidOrbitTieOrder.Key) (best next : A) :
    choose key best next = best ∨ choose key best next = next := by
  unfold choose
  split <;> simp

theorem actual_candidate_and_minimum {A : Type} (key : A → PaidOrbitTieOrder.Key) (best next : A) :
    (choose key best next = best ∨ choose key best next = next) ∧
    (key (choose key best next)).cost = min (key best).cost (key next).cost := by
  refine ⟨chosen_is_actual key best next, ?_⟩
  by_cases lower : (key next).cost < (key best).cost
  · simp [choose, PaidOrbitTieOrder.oldPrefer, lower, Nat.min_eq_right (Nat.le_of_lt lower)]
  by_cases higher : (key best).cost < (key next).cost
  · have different : (key next).cost ≠ (key best).cost := by omega
    simp [choose, PaidOrbitTieOrder.oldPrefer, lower, different, Nat.min_eq_left (Nat.le_of_lt higher)]
  have same : (key next).cost = (key best).cost := by omega
  rcases chosen_is_actual key best next with h | h <;> simp [h, same]

theorem replay_validity_retained {A : Type} (key : A → PaidOrbitTieOrder.Key)
    (valid : A → Prop) (best next : A) (oldValid : valid best) (newValid : valid next) :
    valid (choose key best next) := by
  rcases chosen_is_actual key best next with h | h <;> simp_all

theorem zero_keep_unpaid (components : List (List Step)) (a b : Binding)
    (zero : sameTuple a b = true) : (a,b) ∉ paid (collected components) :=
  zero_not_charged _ a b zero

end OwnerLinkedDeclarationSelection
