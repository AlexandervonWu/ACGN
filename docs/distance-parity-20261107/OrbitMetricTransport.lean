import Std
import UnionMinimum
import EndpointCanonicalContracts

namespace OrbitMetricTransport

structure Coordinate where
  owner : Nat
  phase : Nat
  exactType : Nat
  slot : Nat
  deriving DecidableEq

def transportCoordinate (owner : Nat) (p : EndpointCanonicalContracts.Permutation)
    (c : Coordinate) : Coordinate :=
  if c.owner = owner then { c with slot := p.forward c.slot } else c

structure Action where
  kind : Nat
  component : Nat
  charge : Nat
  before : Coordinate
  after : Coordinate
  deriving DecidableEq

def transportAction (owner : Nat) (p : EndpointCanonicalContracts.Permutation)
    (a : Action) : Action :=
  { a with before := transportCoordinate owner p a.before, after := transportCoordinate owner p a.after }

def componentCost (component : Nat) (actions : List Action) : Nat :=
  ((actions.filter (fun a => a.component == component)).map Action.charge).sum

theorem component_cost_transport (component owner : Nat)
    (p : EndpointCanonicalContracts.Permutation) (actions : List Action) :
    componentCost component (actions.map (transportAction owner p)) =
      componentCost component actions := by
  induction actions with
  | nil => rfl
  | cons a rest ih =>
    simp only [componentCost, List.map_cons, List.filter_cons] at *
    by_cases h : (a.component == component) = true <;>
      simp [transportAction, h, ih]

theorem transport_keeps_owner_phase_type (owner : Nat)
    (p : EndpointCanonicalContracts.Permutation) (c : Coordinate) :
    (transportCoordinate owner p c).owner = c.owner ∧
    (transportCoordinate owner p c).phase = c.phase ∧
    (transportCoordinate owner p c).exactType = c.exactType := by
  unfold transportCoordinate; split <;> simp

-- A candidate is a path, never an independently reported scalar minimum.
structure Path where
  source : Nat
  target : Nat
  actions : List Action
  representative : Nat

def cost (p : Path) : Nat := (p.actions.map Action.charge).sum

def transportPath (owner : Nat) (p : EndpointCanonicalContracts.Permutation)
    (path : Path) : Path :=
  { path with actions := path.actions.map (transportAction owner p) }

theorem path_cost_transport (owner : Nat) (p : EndpointCanonicalContracts.Permutation)
    (path : Path) : cost (transportPath owner p path) = cost path := by
  simp [cost, transportPath, List.map_map, Function.comp_def, transportAction]

def choose (a b : Path) : Path := if cost b < cost a then b else a
def select (first : Path) : List Path → Path
  | [] => first
  | p :: ps => select (choose first p) ps

theorem select_is_member (first : Path) (rest : List Path) :
    select first rest ∈ first :: rest := by
  induction rest generalizing first with
  | nil => simp [select]
  | cons p ps ih =>
    have member := ih (choose first p)
    rcases List.mem_cons.mp member with h | h
    · simp only [select]
      rw [h]
      unfold choose
      split <;> simp
    · exact List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inr h)))

theorem choose_cost (a b : Path) : cost (choose a b) = min (cost a) (cost b) := by
  unfold choose; split <;> omega

theorem select_cost (first : Path) (rest : List Path) :
    cost (select first rest) = SoundRepresentationUnion.minimum (cost first) (rest.map cost) := by
  induction rest generalizing first with
  | nil => rfl
  | cons p ps ih => simp [select, SoundRepresentationUnion.minimum, ih, choose_cost]

theorem selected_valid (valid : Path → Prop) (first : Path) (rest : List Path)
    (all : ∀ p ∈ first :: rest, valid p) : valid (select first rest) :=
  all _ (select_is_member first rest)

theorem select_transport (f : Path → Path) (preserves : ∀ p, cost (f p) = cost p)
    (first : Path) (rest : List Path) :
    select (f first) (rest.map f) = f (select first rest) := by
  induction rest generalizing first with
  | nil => rfl
  | cons p ps ih =>
    have hc : choose (f first) (f p) = f (choose first p) := by
      simp only [choose, preserves]; split <;> rfl
    simp only [List.map_cons, select, hc, ih]

def covered (owner : Nat) (permutation : EndpointCanonicalContracts.Permutation)
    (left right : List Path) : Prop :=
  ∀ p ∈ left, ∃ q ∈ right, q = transportPath owner permutation p

theorem minimum_le_selected (first : Path) (rest : List Path) (p : Path)
    (member : p ∈ first :: rest) : cost (select first rest) ≤ cost p := by
  rw [select_cost]
  rcases List.mem_cons.mp member with rfl | tail
  · exact SoundRepresentationUnion.minimum_le_first _ _
  · exact SoundRepresentationUnion.minimum_le_member _ _ _ (List.mem_map.mpr ⟨p, tail, rfl⟩)

-- Coverage must be established by actual admitted/replayed path transport.
-- This theorem does not manufacture that Java correspondence from equal costs.
theorem common_space_minimum (owner : Nat)
    (forward backward : EndpointCanonicalContracts.Permutation)
    (a b : Path) (as bs : List Path)
    (ab : covered owner forward (a :: as) (b :: bs))
    (ba : covered owner backward (b :: bs) (a :: as)) :
    cost (select a as) = cost (select b bs) := by
  obtain ⟨q, hq, eq⟩ := ab _ (select_is_member a as)
  obtain ⟨p, hp, ep⟩ := ba _ (select_is_member b bs)
  have h1 := minimum_le_selected b bs q hq
  have h2 := minimum_le_selected a as p hp
  rw [eq, path_cost_transport] at h1
  rw [ep, path_cost_transport] at h2
  omega

-- Same ordered orbit and tie rule are additionally needed for component and
-- literal selected-path equality; total-cost equality alone is insufficient.
theorem selected_component_transport (owner : Nat)
    (p : EndpointCanonicalContracts.Permutation) (first : Path) (rest : List Path)
    (component : Nat) :
    componentCost component (select (transportPath owner p first)
      (rest.map (transportPath owner p))).actions =
        componentCost component (select first rest).actions := by
  rw [select_transport _ (path_cost_transport owner p)]
  exact component_cost_transport component owner p _

theorem same_total_does_not_fix_components :
    (27 + 1 : Nat) = 28 + 0 ∧ (27 : Nat) ≠ 28 := by decide

theorem singleton_orbit_can_lose_minimum :
    SoundRepresentationUnion.minimum 28 [] ≠
      SoundRepresentationUnion.minimum 28 [27] := by decide

-- Concrete semantic transport is already instantiated for Workstation and
-- nested User/Photo in EndpointCanonicalContracts, not assumed here as a new axiom.
theorem workstation_orbit_sound (succ : W → W → Prop) :
    EndpointCanonicalContracts.workstationSource succ ↔
      EndpointCanonicalContracts.workstationSelected succ :=
  EndpointCanonicalContracts.event1495_reverse succ

end OrbitMetricTransport
