import PhaseOwnedJointRoutes

/- Declaration programs and matrix programs are both indexed by comparison
   phase. A matrix read is a reference to a binder slot of its owning comparison
   phase, and the paid declaration edit of that slot is charged in the same
   coordinates. The selected temporal alignment edits operator labels only: it
   is not an input of slot identity. This module replaces agreement with one
   selected minimum temporal alignment by lexical enclosure on each endpoint.
   It does not relax declaration payment, exact binding identity, typed frame
   or dependency checks, and it never equates the two formulas. Java
   correspondence and corpus parity are separate obligations. -/
namespace SelectedSlotTransport
open PhaseOwnedJointRoutes Focused225SharedContracts Focused225Concrete
open ACGN.FifthFive.SharedActionBoundary (DKind)

/- CanonicalDistance.TemporalOwnerStep: temporal node, owner role (or the
   incoming role of the descended child) and the descended child index. -/
structure Step where
  tree : Nat
  role : Nat
  branch : Int
  deriving DecidableEq

abbrev Route := List Step

/- Exact conjuncts of CanonicalDistance.sameSelectedTemporalRoute. `selected`
   is the selected temporal match from source nodes to target nodes and the
   arities are TemporalTree.owners.size(). -/
def oldStep (selected : Nat → Option Nat) (sourceArity targetArity : Nat → Nat)
    (x y : Step) : Bool :=
  decide (selected x.tree = some y.tree ∧ x.role = y.role ∧ x.branch = y.branch ∧
    sourceArity x.tree = targetArity y.tree)

def oldRoute (selected : Nat → Option Nat) (sourceArity targetArity : Nat → Nat) :
    Route → Route → Bool
  | [], [] => true
  | x :: xs, y :: ys =>
    oldStep selected sourceArity targetArity x y &&
      oldRoute selected sourceArity targetArity xs ys
  | _, _ => false

theorem old_route_needs_selected_match (selected : Nat → Option Nat)
    (sourceArity targetArity : Nat → Nat) (x y : Step) (xs ys : Route)
    (unselected : selected x.tree ≠ some y.tree) :
    oldRoute selected sourceArity targetArity (x :: xs) (y :: ys) = false := by
  simp [oldRoute, oldStep, unselected]

theorem old_route_needs_equal_owner_count (selected : Nat → Option Nat)
    (sourceArity targetArity : Nat → Nat) (x y : Step) (xs ys : Route)
    (different : sourceArity x.tree ≠ targetArity y.tree) :
    oldRoute selected sourceArity targetArity (x :: xs) (y :: ys) = false := by
  simp [oldRoute, oldStep, different]

theorem old_route_tail (selected : Nat → Option Nat)
    (sourceArity targetArity : Nat → Nat) (x y : Step) (xs ys : Route)
    (tail : oldRoute selected sourceArity targetArity xs ys = false) :
    oldRoute selected sourceArity targetArity (x :: xs) (y :: ys) = false := by
  simp [oldRoute, tail]

/- Exact conjunct of the two frame checks: original phase paths as strings. -/
def oldFrameOwner (sourcePath targetPath : String) : Bool := decide (sourcePath = targetPath)

/- Replacement: the frame owners are the comparison phases that carry the paid
   declaration program. An owner without a unique comparison phase is absent. -/
def frameOwner (sourcePhase targetPhase : Option Nat) : Bool :=
  match sourcePhase, targetPhase with
  | some i, some j => decide (i = j)
  | _, _ => false

theorem frame_owner_same_phase (i j : Nat) (checked : frameOwner (some i) (some j) = true) :
    i = j := by simpa [frameOwner] using checked

theorem frame_owner_absent_rejected (j : Option Nat) : frameOwner none j = false := by
  cases j <;> rfl

/- Exact route loop of CanonicalDistance.completionVisible. The owner step
   compares its node and role; earlier steps also compare the descended child. -/
def stepAgrees (last : Bool) (a b : Step) : Bool :=
  decide (a.tree = b.tree ∧ a.role = b.role ∧ (last = true ∨ a.branch = b.branch))

def encloses : Route → Route → Bool
  | [], _ => true
  | _ :: _, [] => false
  | [a], b :: _ => stepAgrees true a b
  | a :: a' :: rest, b :: bs => stepAgrees false a b && encloses (a' :: rest) bs

/- Node and role of every step. The child index is determined by the next node. -/
def pathOf : Route → List Nat
  | [] => []
  | s :: rest => s.tree :: s.role :: pathOf rest

theorem encloses_prefix (owner use : Route) (checked : encloses owner use = true) :
    (pathOf use).take (pathOf owner).length = pathOf owner := by
  induction owner generalizing use with
  | nil => simp [pathOf]
  | cons a rest ih =>
    cases use with
    | nil => simp [encloses] at checked
    | cons b bs =>
      cases rest with
      | nil =>
        have h : a.tree = b.tree ∧ a.role = b.role := by
          have := checked
          simp [encloses, stepAgrees] at this
          exact ⟨this.1, this.2⟩
        simp [pathOf, h.1, h.2]
      | cons a' rest' =>
        have both : stepAgrees false a b = true ∧ encloses (a' :: rest') bs = true := by
          simpa [encloses] using checked
        have h : a.tree = b.tree ∧ a.role = b.role := by
          have := both.1
          simp [stepAgrees] at this
          exact ⟨this.1, this.2.1⟩
        have tail := ih bs both.2
        simp only [pathOf, List.length_cons, List.take_succ_cons] at tail ⊢
        rw [h.1, h.2]
        exact congrArg (fun rest => b.tree :: b.role :: rest) tail

theorem sibling_role_not_enclosed (a b : Step) (bs : Route) (different : a.role ≠ b.role) :
    encloses [a] (b :: bs) = false := by
  simp [encloses, stepAgrees, different]

theorem foreign_node_not_enclosed (a b : Step) (rest bs : Route) (different : a.tree ≠ b.tree) :
    encloses (a :: rest) (b :: bs) = false := by
  cases rest <;> simp [encloses, stepAgrees, different]

/- One endpoint: source-issued scopes and the temporal route of every
   comparison phase in that endpoint's own temporal tree. -/
structure Endpoint where
  scopes : List Scope
  routes : List Route

def routed (e : Endpoint) : Bool :=
  e.scopes.all fun s =>
    match e.routes[s.phase]? with
    | some r => decide (s.path = pathOf r)
    | none => false

def visible (e : Endpoint) (owner use : Nat) : Bool :=
  match e.routes[owner]?, e.routes[use]? with
  | some o, some u => encloses o u
  | _, _ => false

/- The Java scope check supplies the path premise of `resolveBinding`. -/
theorem visible_gives_scope_path (e : Endpoint) (owner use : Nat) (so su : Scope)
    (r : routed e = true) (v : visible e owner use = true)
    (ho : so ∈ e.scopes) (hu : su ∈ e.scopes)
    (po : so.phase = owner) (pu : su.phase = use) :
    su.path.take so.path.length = so.path := by
  have all := List.all_eq_true.mp r
  have ro := all so ho
  have ru := all su hu
  rw [po] at ro
  rw [pu] at ru
  unfold visible at v
  cases o : e.routes[owner]? with
  | none => simp [o] at ro
  | some oRoute =>
    cases u : e.routes[use]? with
    | none => simp [u] at ru
    | some uRoute =>
      simp only [o] at ro
      simp only [u] at ru
      simp only [o, u] at v
      have eo : so.path = pathOf oRoute := of_decide_eq_true ro
      have eu : su.path = pathOf uRoute := of_decide_eq_true ru
      rw [eo, eu]
      exact encloses_prefix oRoute uRoute v

/- A paid slot link. Both the owner and the use are paired by comparison
   phase, the coordinates in which the declaration edit was charged. -/
def slotTransport (tuple : Binding → List String) (left right : Endpoint)
    (p : OwnerProgram) (action : Nat) (sourceUses targetUses : List MatrixUse)
    (before after : MatrixUse) : Option TypedRoute :=
  if routed left && routed right &&
      visible left p.sourcePhase before.phase && visible right p.targetPhase after.phase &&
      decide (p.sourcePhase = p.targetPhase ∧ before.phase = after.phase ∧
        before.binding.origin.phase = p.sourcePhase ∧
        after.binding.origin.phase = p.targetPhase) then
    match selectedOwnedRoute tuple left.scopes right.scopes p action
        sourceUses targetUses before after with
    | some route =>
      if route.action.kind = DKind.update ∧ route.action.cost = 1 then some route else none
    | none => none
  else none

theorem slot_transport_exact (tuple : Binding → List String) (left right : Endpoint)
    (p : OwnerProgram) (action : Nat) (sourceUses targetUses : List MatrixUse)
    (before after : MatrixUse) (route : TypedRoute)
    (checked : slotTransport tuple left right p action sourceUses targetUses before after =
      some route) :
    routed left = true ∧ routed right = true ∧
    visible left p.sourcePhase before.phase = true ∧
    visible right p.targetPhase after.phase = true ∧
    p.sourcePhase = p.targetPhase ∧ before.phase = after.phase ∧
    before.binding.origin.phase = p.sourcePhase ∧
    after.binding.origin.phase = p.targetPhase ∧
    selectedOwnedRoute tuple left.scopes right.scopes p action
      sourceUses targetUses before after = some route ∧
    route.action.kind = DKind.update ∧ route.action.cost = 1 := by
  unfold slotTransport at checked
  split at checked
  next guard =>
    simp only [Bool.and_eq_true, decide_eq_true_eq] at guard
    obtain ⟨⟨⟨⟨rl, rr⟩, vl⟩, vr⟩, phases⟩ := guard
    cases owned : selectedOwnedRoute tuple left.scopes right.scopes p action
        sourceUses targetUses before after with
    | none => simp [owned] at checked
    | some selected =>
      simp only [owned] at checked
      split at checked
      next paid =>
        cases checked
        exact ⟨rl, rr, vl, vr, phases.1, phases.2.1, phases.2.2.1, phases.2.2.2, rfl, paid.1, paid.2⟩
      next => cases checked
  next => cases checked

/- General replacement soundness. An accepted link is the selected, charged
   declaration update of the exact source binding; both reads resolve
   lexically in their own endpoint; and the read through the link is the
   typed target binding. Nothing here depends on a temporal alignment. -/
theorem slot_transport_sound (tuple : Binding → List String) (left right : Endpoint)
    (p : OwnerProgram) (action : Nat) (sourceUses targetUses : List MatrixUse)
    (before after : MatrixUse) (route : TypedRoute)
    (checked : slotTransport tuple left right p action sourceUses targetUses before after =
      some route)
    (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    (routeRead route before.binding).map (typedRead Value valuation) =
      some ⟨after.binding.origin.exactType, valuation after.binding⟩ ∧
    p.candidate.actions[action]? = some route.action ∧
    route.action.kind = DKind.update ∧ route.action.cost = 1 ∧
    route.before = some before.binding ∧ route.after = some after.binding ∧
    resolveBinding left.scopes before.phase before.binding = some before.binding ∧
    resolveBinding right.scopes after.phase after.binding = some after.binding ∧
    before ∈ sourceUses ∧ after ∈ targetUses := by
  have exact := slot_transport_exact tuple left right p action sourceUses targetUses
    before after route checked
  have owned := exact.2.2.2.2.2.2.2.2.1
  have parts := owned_route_exact tuple left.scopes right.scopes p action sourceUses
    targetUses before after route owned
  have act := owned_route_has_paid_or_keep_action tuple left.scopes right.scopes p action
    sourceUses targetUses before after route owned
  exact ⟨owned_route_reads_typed_target tuple left.scopes right.scopes p action sourceUses
      targetUses before after route owned Value valuation,
    act.2.1, exact.2.2.2.2.2.2.2.2.2.1, exact.2.2.2.2.2.2.2.2.2.2, act.2.2.1, act.2.2.2,
    parts.2.2.2.2.1, parts.2.2.2.2.2, parts.2.2.1, parts.2.2.2.1⟩

/- The scope premise used by `resolveBinding` is exactly the Java enclosure. -/
theorem slot_transport_enclosed (tuple : Binding → List String) (left right : Endpoint)
    (p : OwnerProgram) (action : Nat) (sourceUses targetUses : List MatrixUse)
    (before after : MatrixUse) (route : TypedRoute)
    (checked : slotTransport tuple left right p action sourceUses targetUses before after =
      some route)
    (so su : Scope) (ho : so ∈ left.scopes) (hu : su ∈ left.scopes)
    (po : so.phase = p.sourcePhase) (pu : su.phase = before.phase) :
    su.path.take so.path.length = so.path := by
  have exact := slot_transport_exact tuple left right p action sourceUses targetUses
    before after route checked
  exact visible_gives_scope_path left p.sourcePhase before.phase so su exact.1 exact.2.2.1
    ho hu po pu

/- Retained rejections. Each is a premise of every accepted link. -/
theorem source_use_outside_owner_rejected (tuple : Binding → List String)
    (left right : Endpoint) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (outside : visible left p.sourcePhase before.phase = false) :
    slotTransport tuple left right p action sourceUses targetUses before after = none := by
  cases h : slotTransport tuple left right p action sourceUses targetUses before after with
  | none => rfl
  | some route =>
    have := (slot_transport_exact tuple left right p action sourceUses targetUses before
      after route h).2.2.1
    rw [outside] at this
    cases this

theorem target_use_outside_owner_rejected (tuple : Binding → List String)
    (left right : Endpoint) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (outside : visible right p.targetPhase after.phase = false) :
    slotTransport tuple left right p action sourceUses targetUses before after = none := by
  cases h : slotTransport tuple left right p action sourceUses targetUses before after with
  | none => rfl
  | some route =>
    have := (slot_transport_exact tuple left right p action sourceUses targetUses before
      after route h).2.2.2.1
    rw [outside] at this
    cases this

theorem cross_phase_use_rejected (tuple : Binding → List String)
    (left right : Endpoint) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (different : before.phase ≠ after.phase) :
    slotTransport tuple left right p action sourceUses targetUses before after = none := by
  cases h : slotTransport tuple left right p action sourceUses targetUses before after with
  | none => rfl
  | some route =>
    exact False.elim (different (slot_transport_exact tuple left right p action sourceUses
      targetUses before after route h).2.2.2.2.2.1)

theorem cross_phase_owner_rejected (tuple : Binding → List String)
    (left right : Endpoint) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (different : p.sourcePhase ≠ p.targetPhase) :
    slotTransport tuple left right p action sourceUses targetUses before after = none := by
  cases h : slotTransport tuple left right p action sourceUses targetUses before after with
  | none => rfl
  | some route =>
    exact False.elim (different (slot_transport_exact tuple left right p action sourceUses
      targetUses before after route h).2.2.2.2.1)

theorem absent_payment_rejected (tuple : Binding → List String)
    (left right : Endpoint) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (absent : p.candidate.actions[action]? = none) :
    slotTransport tuple left right p action sourceUses targetUses before after = none := by
  cases h : slotTransport tuple left right p action sourceUses targetUses before after with
  | none => rfl
  | some route =>
    have sound := slot_transport_exact tuple left right p action sourceUses targetUses
      before after route h
    have act := owned_route_has_paid_or_keep_action tuple left.scopes right.scopes p action
      sourceUses targetUses before after route sound.2.2.2.2.2.2.2.2.1
    rw [absent] at act
    cases act.2.1

/- A retained (zero-cost) diagonal or an insertion/deletion is not a payment. -/
theorem unpaid_action_rejected (tuple : Binding → List String)
    (left right : Endpoint) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (selected : Native.NativeAction (List String))
    (actual : p.candidate.actions[action]? = some selected)
    (unpaid : selected.kind ≠ DKind.update ∨ selected.cost ≠ 1) :
    slotTransport tuple left right p action sourceUses targetUses before after = none := by
  cases h : slotTransport tuple left right p action sourceUses targetUses before after with
  | none => rfl
  | some route =>
    have sound := slot_transport_exact tuple left right p action sourceUses targetUses
      before after route h
    have act := owned_route_has_paid_or_keep_action tuple left.scopes right.scopes p action
      sourceUses targetUses before after route sound.2.2.2.2.2.2.2.2.1
    have same : selected = route.action := by
      have := act.2.1
      rw [actual] at this
      exact Option.some.inj this
    subst same
    cases unpaid with
    | inl kind => exact False.elim (kind sound.2.2.2.2.2.2.2.2.2.1)
    | inr cost => exact False.elim (cost sound.2.2.2.2.2.2.2.2.2.2)

theorem dropped_target_use_rejected (tuple : Binding → List String)
    (left right : Endpoint) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (dropped : after ∉ targetUses) :
    slotTransport tuple left right p action sourceUses targetUses before after = none := by
  cases h : slotTransport tuple left right p action sourceUses targetUses before after with
  | none => rfl
  | some route =>
    have sound := slot_transport_exact tuple left right p action sourceUses targetUses
      before after route h
    have parts := owned_route_exact tuple left.scopes right.scopes p action sourceUses
      targetUses before after route sound.2.2.2.2.2.2.2.2.1
    exact False.elim (dropped parts.2.2.2.1)

/- Covers a changed owner, type, domain or dependency list: any changed field
   yields a record that the owning scope did not issue. -/
theorem unissued_source_binding_rejected (tuple : Binding → List String)
    (left right : Endpoint) (p : OwnerProgram) (action : Nat)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (unissued : ∀ owner, scopeAt left.scopes before.binding.origin.phase = some owner →
      before.binding ∉ owner.owned) :
    slotTransport tuple left right p action sourceUses targetUses before after = none := by
  cases h : slotTransport tuple left right p action sourceUses targetUses before after with
  | none => rfl
  | some route =>
    have sound := slot_transport_exact tuple left right p action sourceUses targetUses
      before after route h
    have parts := owned_route_exact tuple left.scopes right.scopes p action sourceUses
      targetUses before after route sound.2.2.2.2.2.2.2.2.1
    have none := foreign_owner_rejected left.scopes before.phase before.binding unissued
    rw [none] at parts
    cases parts.2.2.2.2.1

/- Finite ordered-tree alignments, used only to state that two alignments of
   the same pair of trees have equal cost. Nodes are postorder positions from
   one; `parents` holds the parent position, zero for the root. -/
structure Tree where
  labels : List String
  parents : List Nat

def Tree.size (t : Tree) : Nat := t.labels.length

def Tree.parent (t : Tree) (node : Nat) : Nat := (t.parents[node - 1]?).getD 0

def Tree.ancestorWithin (t : Tree) : Nat → Nat → Nat → Bool
  | 0, _, _ => false
  | fuel + 1, ancestor, node =>
    let up := t.parent node
    up != 0 && (up == ancestor || t.ancestorWithin fuel ancestor up)

def Tree.ancestor (t : Tree) (ancestor node : Nat) : Bool :=
  t.ancestorWithin t.size ancestor node

/- Injective, postorder-monotone and ancestor-preserving in both directions. -/
def alignment (a b : Tree) (pairs : List (Nat × Nat)) : Bool :=
  decide ((pairs.map Prod.fst).Nodup ∧ (pairs.map Prod.snd).Nodup) &&
  pairs.all (fun p => decide (1 ≤ p.1 ∧ p.1 ≤ a.size ∧ 1 ≤ p.2 ∧ p.2 ≤ b.size)) &&
  pairs.all (fun p => pairs.all (fun q =>
    decide ((p.1 < q.1 ↔ p.2 < q.2)) && (a.ancestor p.1 q.1 == b.ancestor p.2 q.2)))

def alignmentCost (a b : Tree) (pairs : List (Nat × Nat)) : Nat :=
  (a.size - pairs.length) + (b.size - pairs.length) +
    (pairs.filter (fun p => a.labels[p.1 - 1]? != b.labels[p.2 - 1]?)).length

def selectedBy (pairs : List (Nat × Nat)) (node : Nat) : Option Nat :=
  (pairs.find? (fun p => p.1 == node)).map Prod.snd

def countOf (counts : List (Nat × Nat)) (node : Nat) : Nat :=
  ((counts.find? (fun p => p.1 == node)).map Prod.snd).getD 0

#print axioms encloses_prefix
#print axioms visible_gives_scope_path
#print axioms slot_transport_sound
#print axioms unpaid_action_rejected
end SelectedSlotTransport
