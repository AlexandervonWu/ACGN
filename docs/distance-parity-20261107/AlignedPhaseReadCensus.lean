import PartialCoherentMatching
import SelectedDeclarationPathTransport

/- A matching census contains reads in paired phases, not declarations or
   reads in wholly inserted/deleted suffix phases. No action is removed. -/
namespace AlignedPhaseReadCensus
open SelectedDeclarationCompletion

def census (phases : List (List Nat)) (aligned : Nat) : List Nat :=
  (phases.take aligned).flatten

def restrict (m : Mapping) (left right : List Nat) : Mapping := fun x =>
  match m x with
  | none => none
  | some y => if x ∈ left ∧ y ∈ right then some y else none

theorem retained_edge (m : Mapping) (left right : List Nat) (x y : Nat)
    (edge : restrict m left right x = some y) :
    m x = some y ∧ x ∈ left ∧ y ∈ right := by
  cases h : m x with
  | none => simp [restrict, h] at edge
  | some z =>
    by_cases included : x ∈ left ∧ z ∈ right
    · have equal : z = y := Option.some.inj (by simpa [restrict, h, included] using edge)
      cases equal
      exact ⟨rfl, included⟩
    · simp [restrict, h, included] at edge

theorem observed_edge_iff (m : Mapping) (left right : List Nat) (x y : Nat)
    (hx : x ∈ left) (hy : y ∈ right) :
    restrict m left right x = some y ↔ m x = some y := by
  constructor
  · intro edge; exact (retained_edge m left right x y edge).1
  · intro edge; simp [restrict, edge, hx, hy]

theorem admission_retained (m : Mapping) (left right : List Nat)
    (admitted : Nat → Nat → Prop)
    (valid : ∀ x y, m x = some y → admitted x y) :
    ∀ x y, restrict m left right x = some y → admitted x y := by
  intro x y edge
  exact valid x y (retained_edge m left right x y edge).1

theorem injection_retained (m : Mapping) (left right : List Nat)
    (valid : ∀ x z y, m x = some y → m z = some y → x = z) :
    ∀ x z y, restrict m left right x = some y →
      restrict m left right z = some y → x = z := by
  intro x z y a b
  exact valid x z y (retained_edge m left right x y a).1
    (retained_edge m left right z y b).1

theorem observed_charge (m : Mapping) (left right : List Nat) (x y : Nat)
    (hx : x ∈ left) (hy : y ∈ right) :
    UnobservedDeclarationCompletion.variableCost (restrict m left right) x y =
      UnobservedDeclarationCompletion.variableCost m x y := by
  simp only [UnobservedDeclarationCompletion.variableCost,
    observed_edge_iff m left right x y hx hy]

def footprint (actions : List Action) (left right : List Nat) : Prop :=
  ∀ a ∈ actions, ∀ x y, readPair a = some (x,y) → x ∈ left ∧ y ∈ right

theorem no_queries_footprint (actions : List Action) (left right : List Nat)
    (noQueries : actions.all (fun a => (readPair a).isNone) = true) :
    footprint actions left right := by
  intro a member x y query
  have h := List.all_eq_true.mp noQueries a member
  simp [query] at h

theorem action_charge (m : Mapping) (left right : List Nat) (a : Action)
    (covered : ∀ x y, readPair a = some (x,y) → x ∈ left ∧ y ∈ right) :
    charge (restrict m left right) a = charge m a := by
  unfold charge
  cases h : readPair a with
  | none => rfl
  | some pair =>
    rcases pair with ⟨x,y⟩
    exact observed_charge m left right x y (covered x y h).1 (covered x y h).2

theorem program_retained (m : Mapping) (left right : List Nat) (actions : List Action)
    (covered : footprint actions left right) :
    annotated actions (restrict m left right) = annotated actions m := by
  apply List.map_congr_left
  intro a member
  rw [action_charge m left right a (covered a member)]

theorem execution_retained {State : Type} (step : State → (Action × Nat) → State)
    (m : Mapping) (left right : List Nat) (actions : List Action) (initial : State)
    (covered : footprint actions left right) :
    (annotated actions (restrict m left right)).foldl step initial =
      (annotated actions m).foldl step initial := by
  rw [program_retained m left right actions covered]

theorem total_retained (m : Mapping) (left right : List Nat) (actions : List Action)
    (covered : footprint actions left right) :
    (actions.map (charge (restrict m left right))).sum = (actions.map (charge m)).sum :=
  RetainedScopePaidCompletion.unchanged_derivation actions (charge m)
    (charge (restrict m left right)) (fun a member => action_charge m left right a (covered a member))

-- This quantifies over candidate programs, not only the winning trace.
theorem candidate_costs_retained (m : Mapping) (left right : List Nat)
    (programs : List (List Action)) (covered : ∀ actions ∈ programs, footprint actions left right) :
    programs.map (fun actions => (actions.map (charge (restrict m left right))).sum) =
      programs.map (fun actions => (actions.map (charge m)).sum) := by
  apply List.map_congr_left
  intro actions member
  exact total_retained m left right actions (covered actions member)

theorem suffix_not_in_census (initial suffix : List (List Nat)) :
    census (initial ++ suffix) initial.length = initial.flatten := by
  simp [census]

theorem one_sided_has_no_query (a : Action) (oneSided : a.before = none ∨ a.after = none) :
    readPair a = none := by
  rcases oneSided with h | h
  · simp [readPair, h]
  · cases hbefore : a.before <;> simp [readPair, h, hbefore]

theorem one_sided_charge (m : Mapping) (a : Action)
    (oneSided : a.before = none ∨ a.after = none) : charge m a = a.fixedCharge := by
  simp [charge, one_sided_has_no_query a oneSided]

-- Required matching size is computed on the observed domain. This predicate
-- models the terminal matched==requiredMatches condition, not a replay waiver.
def requiredSize (left : List Nat) (m : Mapping) (required : Nat) : Bool :=
  (left.filter (fun x => (m x).isSome)).length == required

theorem actual_read_cannot_be_dropped :
    UnobservedDeclarationCompletion.variableCost (fun _ => some 0) 0 0 = 0 ∧
    UnobservedDeclarationCompletion.variableCost (restrict (fun _ => some 0) [] [0]) 0 0 = 1 := by
  decide

#print axioms observed_edge_iff
#print axioms admission_retained
#print axioms injection_retained
#print axioms execution_retained
#print axioms candidate_costs_retained
#print axioms suffix_not_in_census
#print axioms one_sided_charge
end AlignedPhaseReadCensus
