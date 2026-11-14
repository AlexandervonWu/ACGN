import SharedActionBoundary
import SelectedDeclarationCompletion
import AuthenticatedPhaseTransport
import HeterogeneousPrefixPresentation
import ScopedCallCorrespondence
import JoinSegmentation
import ReceiptDagRank
import UnionMinimum
import EndpointCanonicalContracts

/-!
One shared environment for P01-P10 of the frozen v28 focused225 inventory.
These are executable contract repairs and compositional laws, not a claim that
Java implements them or that independently selected native paths are equal.
No census, replay or source-authentication refusal is converted into a pass.
-/
namespace Focused225SharedContracts

namespace Native
export ACGN.FifthFive.SharedActionBoundary
  (NativeAction Origin Op check nativeActions consumed produced expected programCost
   check_coverage StepOk nextLeft nextRight emit)
end Native
namespace Phase
export AuthenticatedPhaseTransport
  (Reindex moveStore moveOperation run_transport selected_cost_preserved)
end Phase
namespace Trace
export DistanceDerivedTrace (Store Operation run cost run_append cost_append)
end Trace
namespace Reach
export TemporalReferenceReachability
  (Expr Reference support construct relocatedResolver restrict
   checked_relocation_preserves_construction restriction_preserves_construction)
end Reach
namespace Calls
export ScopedCallCorrespondence (Slot Head Term Call eval evalCall)
end Calls

abbrev Binding := SelectedDeclarationCompletion.Binding
abbrev Origin := SelectedDeclarationCompletion.Origin

structure Environment where
  source : List Binding
  target : List Binding

def Environment.authentic (e : Environment) (left : Bool) (index : Nat)
    (claimed : Binding) : Bool :=
  SelectedDeclarationCompletion.associated (if left then e.source else e.target) index claimed

theorem authentic_binding (e : Environment) (left : Bool) (i : Nat) (b : Binding)
    (checked : e.authentic left i b = true) :
    (if left then e.source else e.target)[i]? = some b ∧ b.vectorIndex = i :=
  SelectedDeclarationCompletion.associated_exact _ _ _ checked

/- The lookup index and the source ordinal remain distinct. A view transports
   whole records, including source hash, type, owner, phase and dependencies. -/
def lookupView (source : List Binding) (indices : List Nat) : List (Option Binding) :=
  indices.map (fun i => source[i]?)

theorem view_preserves_record (source : List Binding) (indices : List Nat)
    (position index : Nat) (selected : indices[position]? = some index) :
    (lookupView source indices)[position]? = some (source[index]?) := by
  simp [lookupView, List.getElem?_map, selected]

/- P01/P02: derive matrix links from the actual replayed declaration actions,
   instead of independently inventing an absent-map completion. -/
def links {Tuple : Type} (actions : List (Native.NativeAction Tuple)) : List (Nat × Nat) :=
  actions.filterMap fun a => do
    let s ← a.source
    let t ← a.target
    pure (s, t)

def matrixCharge (pairs : List (Nat × Nat)) (s t : Nat) : Nat :=
  if (s, t) ∈ pairs then 0 else 1

theorem zero_has_selected_declaration {Tuple : Type}
    (actions : List (Native.NativeAction Tuple)) (s t : Nat)
    (zero : matrixCharge (links actions) s t = 0) :
    ∃ a ∈ actions, a.source = some s ∧ a.target = some t := by
  have member : (s, t) ∈ links actions := by
    by_cases h : (s, t) ∈ links actions
    · exact h
    · simp [matrixCharge, h] at zero
  obtain ⟨a, ha, hit⟩ := List.mem_filterMap.mp member
  refine ⟨a, ha, ?_⟩
  cases hs : a.source <;> cases ht : a.target <;> simp_all

theorem no_selected_pair_no_free_transport {Tuple : Type}
    (actions : List (Native.NativeAction Tuple)) (s t : Nat)
    (absent : ∀ a ∈ actions, a.source ≠ some s ∨ a.target ≠ some t) :
    matrixCharge (links actions) s t = 1 := by
  by_cases member : (s, t) ∈ links actions
  · have zero : matrixCharge (links actions) s t = 0 := by simp [matrixCharge, member]
    obtain ⟨a, ha, hs, ht⟩ := zero_has_selected_declaration actions s t zero
    cases absent a ha with
    | inl bad => exact False.elim (bad hs)
    | inr bad => exact False.elim (bad ht)
  · simp [matrixCharge, member]

structure JointCandidate (Tuple : Type) where
  source : List (Native.Origin Tuple)
  target : List (Native.Origin Tuple)
  declarations : List Native.Op
  variableReads : List (Nat × Nat)
  otherMatrixCharges : List Nat
  temporalCharges : List Nat

def JointCandidate.accepts [DecidableEq Tuple] (c : JointCandidate Tuple) : Bool :=
  Native.check c.source c.target 0 0 c.declarations

def JointCandidate.actions [DecidableEq Tuple] (c : JointCandidate Tuple) :=
  Native.nativeActions c.source c.target c.declarations

def JointCandidate.total [DecidableEq Tuple] (c : JointCandidate Tuple) : Nat :=
  Native.programCost c.declarations +
    (c.variableReads.map fun (s,t) => matrixCharge (links c.actions) s t).sum +
    c.otherMatrixCharges.sum + c.temporalCharges.sum

theorem joint_exact_coverage [DecidableEq Tuple] (c : JointCandidate Tuple)
    (accepted : c.accepts = true) :
    Native.consumed c.actions = c.source ∧ Native.produced c.actions = c.target :=
  Native.check_coverage c.source c.target c.declarations accepted

theorem joint_zero_read_has_authority [DecidableEq Tuple] (c : JointCandidate Tuple)
    (s t : Nat) (zero : matrixCharge (links c.actions) s t = 0) :
    ∃ action ∈ c.actions, action.source = some s ∧ action.target = some t :=
  zero_has_selected_declaration c.actions s t zero

/- Bind both original records before ordinal lookup. `tuple` is the retained
   declaration-cost projection, not the complete source key. -/
def boundCandidate [DecidableEq Tuple] (tuple : Binding → Tuple)
    (e : Environment) (c : JointCandidate Tuple) : Bool :=
  c.accepts && decide
    (c.source = e.source.map (fun b => (⟨b.ordinal,tuple b⟩ : Native.Origin Tuple)) ∧
     c.target = e.target.map (fun b => (⟨b.ordinal,tuple b⟩ : Native.Origin Tuple)) ∧
     (e.source.map (fun b => b.ordinal)).Nodup ∧ (e.target.map (fun b => b.ordinal)).Nodup)

def checkedReadCharge [DecidableEq Tuple] (tuple : Binding → Tuple)
    (e : Environment) (c : JointCandidate Tuple) (left right : Binding) : Option Nat :=
  if boundCandidate tuple e c && e.authentic true left.vectorIndex left &&
      e.authentic false right.vectorIndex right then
    some (matrixCharge (links c.actions) left.ordinal right.ordinal)
  else none

theorem checked_read_originals [DecidableEq Tuple] (tuple : Binding → Tuple)
    (e : Environment) (c : JointCandidate Tuple) (left right : Binding) (charge : Nat)
    (accepted : checkedReadCharge tuple e c left right = some charge) :
    c.accepts = true ∧ e.source[left.vectorIndex]? = some left ∧
      e.target[right.vectorIndex]? = some right ∧
      charge = matrixCharge (links c.actions) left.ordinal right.ordinal := by
  unfold checkedReadCharge at accepted
  split at accepted
  next checks =>
    have hs : boundCandidate tuple e c = true ∧
        e.authentic true left.vectorIndex left = true ∧
        e.authentic false right.vectorIndex right = true := by simpa [and_assoc] using checks
    have bound : c.accepts = true := by
      cases h : c.accepts with
      | false => simp [boundCandidate, h] at hs
      | true => rfl
    exact ⟨bound, (authentic_binding e true _ left hs.2.1).1,
      (authentic_binding e false _ right hs.2.2).1, (Option.some.inj accepted).symm⟩
  next => cases accepted

theorem checked_zero_has_original_paid_or_keep_link [DecidableEq Tuple]
    (tuple : Binding → Tuple) (e : Environment) (c : JointCandidate Tuple)
    (left right : Binding) (accepted : checkedReadCharge tuple e c left right = some 0) :
    e.source[left.vectorIndex]? = some left ∧ e.target[right.vectorIndex]? = some right ∧
      ∃ action ∈ c.actions, action.source = some left.ordinal ∧ action.target = some right.ordinal := by
  obtain ⟨_, hl, hr, charge⟩ := checked_read_originals tuple e c left right 0 accepted
  exact ⟨hl,hr,zero_has_selected_declaration c.actions _ _ charge.symm⟩

theorem foreign_read_rejected [DecidableEq Tuple] (tuple : Binding → Tuple)
    (e : Environment) (c : JointCandidate Tuple) (left right : Binding)
    (foreign : e.source[left.vectorIndex]? ≠ some left) :
    checkedReadCharge tuple e c left right = none := by
  have bad : e.authentic true left.vectorIndex left = false := by
    apply Bool.eq_false_iff.mpr
    intro h
    exact foreign (authentic_binding e true _ left h).1
  simp [checkedReadCharge, bad]

/- A paid tuple replacement is an edit, not source-formula equivalence. The
   declaration charge remains present even when its matrix use costs zero. -/
theorem changed_tuple_is_paid [DecidableEq Tuple] (a b : Native.Origin Tuple)
    (changed : a.tuple ≠ b.tuple) :
    Native.expected [a] [b] (some 0) (some 0) = some (.update, 1) := by
  simp [Native.expected, changed]

def onePaid (a b : Tuple) : JointCandidate Tuple :=
  ⟨[⟨0,a⟩], [⟨0,b⟩], [⟨.update,1,some 0,some 0⟩], [(0,0)], [], []⟩

theorem paid_transport_not_free [DecidableEq Tuple] (a b : Tuple) (different : a ≠ b) :
    (onePaid a b).accepts = true ∧ (onePaid a b).total = 1 := by
  simp [onePaid, JointCandidate.accepts, Native.check, Native.StepOk, Native.expected,
    Native.nextLeft, Native.nextRight, JointCandidate.total, Native.programCost,
    JointCandidate.actions, Native.nativeActions, Native.emit,
    ACGN.FifthFive.SharedActionBoundary.sourceOrigin,
    ACGN.FifthFive.SharedActionBoundary.targetOrigin, links, matrixCharge, different]

/- P01/P04/P05/P06 use one attaining selector on complete candidate objects.
   A chosen scalar is never reattached to an independently selected path. -/
def prefer (cost : C → Nat) (a b : C) : C := if cost a ≤ cost b then a else b

def select (cost : C → Nat) (first : C) : List C → C
  | [] => first
  | next :: rest => select cost (prefer cost first next) rest

theorem prefer_member (cost : C → Nat) (a b : C) : prefer cost a b = a ∨ prefer cost a b = b := by
  unfold prefer; split <;> simp

theorem prefer_cost (cost : C → Nat) (a b : C) :
    cost (prefer cost a b) = min (cost a) (cost b) := by
  unfold prefer; split
  next h => exact (Nat.min_eq_left h).symm
  next h => exact (Nat.min_eq_right (by omega)).symm

theorem selected_member (cost : C → Nat) (first : C) (rest : List C) :
    select cost first rest ∈ first :: rest := by
  induction rest generalizing first with
  | nil => simp [select]
  | cons next rest ih =>
    change select cost (prefer cost first next) rest ∈ first :: next :: rest
    have h := ih (prefer cost first next)
    rcases List.mem_cons.mp h with chosen | tail
    · rw [chosen]
      rcases prefer_member cost first next with left | right
      · exact List.mem_cons.mpr (Or.inl left)
      · exact List.mem_cons_of_mem _ (List.mem_cons.mpr (Or.inl right))
    · exact List.mem_cons_of_mem _ (List.mem_cons_of_mem _ tail)

theorem selected_minimum (cost : C → Nat) (first : C) (rest : List C) :
    cost (select cost first rest) =
      SoundRepresentationUnion.minimum (cost first) (rest.map cost) := by
  induction rest generalizing first with
  | nil => rfl
  | cons next rest ih => simp [select, ih, prefer_cost, SoundRepresentationUnion.minimum]

theorem selected_le_every (cost : C → Nat) (first : C) (rest : List C)
    (other : C) (member : other ∈ first :: rest) :
    cost (select cost first rest) ≤ cost other := by
  rw [selected_minimum cost first rest]
  rcases List.mem_cons.mp member with same | member
  · subst other; exact SoundRepresentationUnion.minimum_le_first _ _
  · exact SoundRepresentationUnion.minimum_le_member _ _ _ (List.mem_map.mpr ⟨other,member,rfl⟩)

theorem selected_retains_checks (cost : C → Nat) (first : C) (rest : List C)
    (valid : C → Prop) (checked : ∀ c ∈ first :: rest, valid c) :
    valid (select cost first rest) := checked _ (selected_member cost first rest)

theorem permuted_candidates_same_minimum (cost : C → Nat)
    (a b : C) (as bs : List C) (same : (a :: as).Perm (b :: bs)) :
    cost (select cost a as) = cost (select cost b bs) := by
  apply Nat.le_antisymm
  · exact selected_le_every cost a as _ (same.mem_iff.mpr (selected_member cost b bs))
  · exact selected_le_every cost b bs _ (same.mem_iff.mp (selected_member cost a as))

/- An injective canonical rank gives order-independent path selection on the
   equal-cost pool. Equal scalar costs alone never imply equal selected paths. -/
theorem canonical_rank_selects_same_path (rank : C → Nat)
    (a b : C) (as bs : List C) (same : (a :: as).Perm (b :: bs))
    (uniqueRank : ∀ x ∈ a :: as, ∀ y ∈ a :: as, rank x = rank y → x = y) :
    select rank a as = select rank b bs := by
  exact uniqueRank _ (selected_member rank a as) _
    (same.mem_iff.mpr (selected_member rank b bs))
    (permuted_candidates_same_minimum rank a b as bs same)

def tiePool (cost : C → Nat) (first : C) (rest : List C) : List C :=
  (first :: rest).filter (fun c => cost c == cost (select cost first rest))

theorem tie_pool_exact (cost : C → Nat) (first : C) (rest : List C) (c : C) :
    c ∈ tiePool cost first rest ↔ c ∈ first :: rest ∧ cost c = cost (select cost first rest) := by
  simp [tiePool]

theorem ranked_tie_does_not_change_minimum (cost rank : C → Nat) (first : C) (rest : List C) :
    cost (select rank (select cost first rest) (tiePool cost first rest)) =
      cost (select cost first rest) := by
  have member := selected_member rank (select cost first rest) (tiePool cost first rest)
  rcases List.mem_cons.mp member with same | pool
  · exact congrArg cost same
  · exact ((tie_pool_exact cost first rest _).mp pool).2

theorem checked_joint_selection [DecidableEq Tuple]
    (first : JointCandidate Tuple) (rest : List (JointCandidate Tuple))
    (checked : ∀ c ∈ first :: rest, c.accepts = true) :
    let chosen := select JointCandidate.total first rest
    chosen.accepts = true ∧ Native.consumed chosen.actions = chosen.source ∧
      Native.produced chosen.actions = chosen.target ∧
      ∀ c ∈ first :: rest, chosen.total ≤ c.total := by
  dsimp
  have h := selected_retains_checks JointCandidate.total first rest (fun c => c.accepts = true) checked
  exact ⟨h, (joint_exact_coverage _ h).1, (joint_exact_coverage _ h).2,
    fun c hc => selected_le_every JointCandidate.total first rest c hc⟩

/- P03: whole dependent/disjoint groups are blocks. Independent block exchange
   permits different carriers, not changing values in fixed typed slots. -/
theorem all_block_exchange {A B : Type} (domainA : A → Prop) (domainB : B → Prop)
    (body : A → B → Prop) :
    (∀ a, domainA a → ∀ b, domainB b → body a b) ↔
      (∀ b, domainB b → ∀ a, domainA a → body a b) :=
  HeterogeneousPrefixPresentation.typed_all_presentation domainA domainB body

theorem disjoint_group_exchange {A B : Type} (domainA : A → Prop) (domainB : B → Prop)
    (body : A → B → B → Prop) :
    (∀ a, domainA a → ∀ x y, domainB x → domainB y → x ≠ y → body a x y) ↔
      (∀ x y, domainB x → domainB y → x ≠ y → ∀ a, domainA a → body a x y) := by
  constructor
  · intro h x y hx hy hxy a ha; exact h a ha x y hx hy hxy
  · intro h a ha x y hx hy hxy; exact h x y hx hy hxy a ha

/- P05/P06: authenticate a whole typed coordinate map before transporting
   any SET-child, phase, owner or REF action. Failed replays remain failures. -/
theorem selected_transport_preserves_replay [DecidableEq A] [DecidableEq B] [DecidableEq P]
    (e : Phase.Reindex A B) (source : Trace.Store A P) (ops : List (Trace.Operation A P)) :
    Trace.run (Phase.moveStore e source) (ops.map (Phase.moveOperation e)) =
      (Trace.run source ops).map (Phase.moveStore e) ∧
      Trace.cost (ops.map (Phase.moveOperation e)) = Trace.cost ops :=
  ⟨Phase.run_transport e source ops, Phase.selected_cost_preserved e ops⟩

theorem composition_uses_one_environment [DecidableEq A] [DecidableEq P]
    (first second : List (Trace.Operation A P)) (source : Trace.Store A P) :
    Trace.run source (first ++ second) =
      (Trace.run source first).bind (fun next => Trace.run next second) ∧
      Trace.cost (first ++ second) = Trace.cost first + Trace.cost second :=
  ⟨Trace.run_append first second source, Trace.cost_append first second⟩

/- A finite-store executable check supplies the replay premise used by the
   transport/composition laws, instead of assuming successful execution. -/
def replayCheck [DecidableEq P] (source target : Trace.Store (Fin n) P)
    (ops : List (Trace.Operation (Fin n) P)) (claimedCost : Nat) : Bool :=
  match Trace.run source ops with
  | none => false
  | some actual => decide (∀ i, actual i = target i) && decide (Trace.cost ops = claimedCost)

theorem replay_check_sound [DecidableEq P] (source target : Trace.Store (Fin n) P)
    (ops : List (Trace.Operation (Fin n) P)) (claimedCost : Nat)
    (checked : replayCheck source target ops claimedCost = true) :
    Trace.run source ops = some target ∧ Trace.cost ops = claimedCost := by
  unfold replayCheck at checked
  cases result : Trace.run source ops with
  | none => simp [result] at checked
  | some actual =>
    have h : (∀ i, actual i = target i) ∧ Trace.cost ops = claimedCost := by
      simpa [result] using checked
    have same : actual = target := funext h.1
    exact ⟨by simp [same], h.2⟩

theorem checked_replay_transport [DecidableEq P]
    (e : Phase.Reindex (Fin n) (Fin n)) (source target : Trace.Store (Fin n) P)
    (ops : List (Trace.Operation (Fin n) P)) (claimedCost : Nat)
    (checked : replayCheck source target ops claimedCost = true) :
    Trace.run (Phase.moveStore e source) (ops.map (Phase.moveOperation e)) =
      some (Phase.moveStore e target) ∧
      Trace.cost (ops.map (Phase.moveOperation e)) = claimedCost := by
  obtain ⟨ran,cost⟩ := replay_check_sound source target ops claimedCost checked
  rw [Phase.run_transport, ran, Phase.selected_cost_preserved, cost]
  exact ⟨rfl,rfl⟩

/- A whole candidate must carry the selected component programs, not just
   their totals. `SelectedPrograms` is the immutable producer receipt supplied
   independently of the candidate; exact equality prevents a same-cost path
   from being substituted after selection. -/
structure SelectedPrograms (n : Nat) (P : Type) where
  declarations : List Native.Op
  matrix : List (Trace.Operation (Fin n) P)
  temporal : List (Trace.Operation (Fin n) P)

deriving instance DecidableEq for DistanceDerivedTrace.Operation

structure ExecutableJoint (n : Nat) (Tuple P : Type) where
  declaration : JointCandidate Tuple
  source : Trace.Store (Fin n) P
  middle : Trace.Store (Fin n) P
  target : Trace.Store (Fin n) P
  matrix : List (Trace.Operation (Fin n) P)
  temporal : List (Trace.Operation (Fin n) P)
  matrixTotal : Nat
  temporalTotal : Nat

def ExecutableJoint.total (c : ExecutableJoint n Tuple P) : Nat :=
  Native.programCost c.declaration.declarations + c.matrixTotal + c.temporalTotal

/- The route checker is a separate, retained obligation. This composition
   proves neither its semantics nor Java refinement from an arbitrary Bool. -/
def ExecutableJoint.check [DecidableEq Tuple] [DecidableEq P]
    (tuple : Binding → Tuple) (env : Environment)
    (selected : SelectedPrograms n P)
    (routeCheck : List (Native.NativeAction Tuple) → Trace.Operation (Fin n) P → Bool)
    (temporalCheck : Trace.Operation (Fin n) P → Bool)
    (c : ExecutableJoint n Tuple P) : Bool :=
  boundCandidate tuple env c.declaration &&
    decide (c.declaration.declarations = selected.declarations ∧
      c.matrix = selected.matrix ∧ c.temporal = selected.temporal) &&
    c.matrix.all (routeCheck c.declaration.actions) && c.temporal.all temporalCheck &&
    replayCheck c.source c.middle c.matrix c.matrixTotal &&
    replayCheck c.middle c.target c.temporal c.temporalTotal

theorem complete_joint_replay [DecidableEq Tuple] [DecidableEq P]
    (tuple : Binding → Tuple) (env : Environment)
    (selected : SelectedPrograms n P)
    (routes : List (Native.NativeAction Tuple) → Trace.Operation (Fin n) P → Bool)
    (phases : Trace.Operation (Fin n) P → Bool) (c : ExecutableJoint n Tuple P)
    (checked : c.check tuple env selected routes phases = true) :
    boundCandidate tuple env c.declaration = true ∧
    c.declaration.declarations = selected.declarations ∧
    c.matrix = selected.matrix ∧ c.temporal = selected.temporal ∧
    (∀ op ∈ c.matrix, routes c.declaration.actions op = true) ∧
    (∀ op ∈ c.temporal, phases op = true) ∧
    Trace.run c.source (c.matrix ++ c.temporal) = some c.target ∧
    c.total = Native.programCost c.declaration.declarations +
      Trace.cost (c.matrix ++ c.temporal) := by
  have h : boundCandidate tuple env c.declaration = true ∧
      (c.declaration.declarations = selected.declarations ∧
        c.matrix = selected.matrix ∧ c.temporal = selected.temporal) ∧
      c.matrix.all (routes c.declaration.actions) = true ∧
      c.temporal.all phases = true ∧
      replayCheck c.source c.middle c.matrix c.matrixTotal = true ∧
      replayCheck c.middle c.target c.temporal c.temporalTotal = true := by
    simpa [ExecutableJoint.check, and_assoc] using checked
  obtain ⟨matrixRan, matrixCost⟩ := replay_check_sound _ _ _ _ h.2.2.2.2.1
  obtain ⟨temporalRan, temporalCost⟩ := replay_check_sound _ _ _ _ h.2.2.2.2.2
  refine ⟨h.1, h.2.1.1, h.2.1.2.1, h.2.1.2.2,
    List.all_eq_true.mp h.2.2.1, List.all_eq_true.mp h.2.2.2.1, ?_, ?_⟩
  · rw [Trace.run_append, matrixRan]; exact temporalRan
  · simp [ExecutableJoint.total, Trace.cost_append, matrixCost, temporalCost, Nat.add_assoc]

theorem selected_complete_joint [DecidableEq Tuple] [DecidableEq P]
    (tuple : Binding → Tuple) (env : Environment)
    (receipt : ExecutableJoint n Tuple P → SelectedPrograms n P)
    (routes : List (Native.NativeAction Tuple) → Trace.Operation (Fin n) P → Bool)
    (phases : Trace.Operation (Fin n) P → Bool)
    (first : ExecutableJoint n Tuple P) (rest : List (ExecutableJoint n Tuple P))
    (checks : ∀ c ∈ first :: rest, c.check tuple env (receipt c) routes phases = true) :
    let chosen := select ExecutableJoint.total first rest
    chosen.check tuple env (receipt chosen) routes phases = true ∧
    Trace.run chosen.source (chosen.matrix ++ chosen.temporal) = some chosen.target ∧
    chosen.total = Native.programCost chosen.declaration.declarations +
      Trace.cost (chosen.matrix ++ chosen.temporal) ∧
    ∀ c ∈ first :: rest, chosen.total ≤ c.total := by
  dsimp
  have h := selected_retains_checks ExecutableJoint.total first rest
    (fun c => c.check tuple env (receipt c) routes phases = true) checks
  have sound := complete_joint_replay tuple env _ routes phases _ h
  exact ⟨h, sound.2.2.2.2.2.2.1, sound.2.2.2.2.2.2.2,
    fun c hc => selected_le_every ExecutableJoint.total first rest c hc⟩

theorem substituted_selected_matrix_rejected [DecidableEq Tuple] [DecidableEq P]
    (tuple : Binding → Tuple) (env : Environment) (selected : SelectedPrograms n P)
    (routes : List (Native.NativeAction Tuple) → Trace.Operation (Fin n) P → Bool)
    (phases : Trace.Operation (Fin n) P → Bool) (c : ExecutableJoint n Tuple P)
    (different : c.matrix ≠ selected.matrix) :
    c.check tuple env selected routes phases = false := by
  classical
  simp [ExecutableJoint.check, different]

theorem wrong_joint_matrix_charge_rejected [DecidableEq Tuple] [DecidableEq P]
    (tuple : Binding → Tuple) (env : Environment) (selected : SelectedPrograms n P)
    (routes : List (Native.NativeAction Tuple) → Trace.Operation (Fin n) P → Bool)
    (phases : Trace.Operation (Fin n) P → Bool) (c : ExecutableJoint n Tuple P)
    (different : Trace.cost c.matrix ≠ c.matrixTotal) :
    c.check tuple env selected routes phases = false := by
  apply Bool.eq_false_iff.mpr
  intro h
  unfold ExecutableJoint.check at h
  simp only [Bool.and_eq_true] at h
  exact different (replay_check_sound _ _ _ _ h.1.2).2

/- P07 selected local alternatives use the existing owner-local expression
   action. Domains and guards must be transported with the body; this does
   not license a foreign-owner exchange or ONE/LONE cardinality erasure. -/
theorem selected_local_alternative (owner : Nat) (p : EndpointCanonicalContracts.Permutation)
    (env : EndpointCanonicalContracts.Ref → V) (body : EndpointCanonicalContracts.Expr V) :
    EndpointCanonicalContracts.eval
      (EndpointCanonicalContracts.transport owner p.backward env)
      (EndpointCanonicalContracts.rename owner p.forward body) =
      EndpointCanonicalContracts.eval env body :=
  EndpointCanonicalContracts.eval_rename owner p env body

/- P07: phase removal is support restriction, not an equality of phase counts.
   The second step authenticates every surviving whole reference record. -/
theorem retained_phase_transport (expression : Reach.Expr V)
    (resolve : Reach.Reference → Option V) (address : Reach.Reference → Nat)
    (lookup : Nat → Option Reach.Reference)
    (roundtrip : ∀ r ∈ Reach.support expression, lookup (address r) = some r) :
    Reach.construct (Reach.relocatedResolver address lookup
      (Reach.restrict (Reach.support expression) resolve)) expression =
      Reach.construct resolve expression := by
  rw [Reach.checked_relocation_preserves_construction expression address lookup _ roundtrip,
    Reach.restriction_preserves_construction]

theorem retained_phase_invalid_stays_invalid (expression : Reach.Expr V)
    (resolve : Reach.Reference → Option V) (address : Reach.Reference → Nat)
    (lookup : Nat → Option Reach.Reference)
    (roundtrip : ∀ r ∈ Reach.support expression, lookup (address r) = some r)
    (failed : Reach.construct resolve expression = none) :
    Reach.construct (Reach.relocatedResolver address lookup
      (Reach.restrict (Reach.support expression) resolve)) expression = none := by
  rw [retained_phase_transport expression resolve address lookup roundtrip, failed]

/- P08/P09: equality on used slots suffices for arbitrary recursive arguments.
   The head and argument order remain literal source authority. There is no
   whitelist of permissible argument constructors here. -/
def support : Calls.Term → List Calls.Slot
  | .variable slot => [slot]
  | .node _ arguments => arguments.flatMap support

theorem argument_depends_only_on_support (term : Calls.Term)
    (left right : Calls.Slot → V) (operation : Calls.Head → List V → V)
    (agree : ∀ slot ∈ support term, left slot = right slot) :
    Calls.eval left operation term = Calls.eval right operation term := by
  revert agree
  induction term using ScopedCallCorrespondence.Term.rec
      (motive_2 := fun args => ∀ argument ∈ args,
        (∀ slot ∈ support argument, left slot = right slot) →
        Calls.eval left operation argument = Calls.eval right operation argument) with
  | «variable» slot =>
    intro agree
    simpa only [Calls.eval] using agree slot (by simp [support])
  | node head arguments ih =>
    intro agree
    simp only [Calls.eval]
    congr 1
    apply List.map_congr_left
    intro argument member
    exact ih argument member (fun slot hs => agree slot (by
      simp only [support, List.mem_flatMap]
      exact ⟨argument,member,hs⟩))
  | nil argument member agree => cases member
  | cons argument arguments ih ihs term member agree =>
    rcases List.mem_cons.mp member with rfl | tail
    · exact ih agree
    · exact ihs term tail agree

def callSupport (call : Calls.Call) := call.arguments.flatMap support

theorem call_environment_transport (call : Calls.Call) (left right : Calls.Slot → V)
    (operation : Calls.Head → List V → V)
    (agree : ∀ slot ∈ callSupport call, left slot = right slot) :
    Calls.evalCall left operation call = Calls.evalCall right operation call := by
  unfold Calls.evalCall
  congr 1
  apply List.map_congr_left
  intro argument member
  apply argument_depends_only_on_support argument left right operation
  intro slot hs
  exact agree slot (List.mem_flatMap.mpr ⟨argument,member,hs⟩)

theorem nullary_context_independent (head : Calls.Head) (owner phase : Nat)
    (left right : Calls.Slot → V) (operation : Calls.Head → List V → V) :
    Calls.evalCall left operation ⟨head,owner,phase,[]⟩ =
      Calls.evalCall right operation ⟨head,owner,phase,[]⟩ := rfl

inductive ArgumentProofs (env : Calls.Slot → V) (operation : Calls.Head → List V → V) :
    List Calls.Term → List Calls.Term → Prop where
  | nil : ArgumentProofs env operation [] []
  | cons : Calls.eval env operation l = Calls.eval env operation r →
      ArgumentProofs env operation ls rs → ArgumentProofs env operation (l :: ls) (r :: rs)

theorem recursive_arguments_in_call (head : Calls.Head) (owner phase : Nat)
    (leftArgs rightArgs : List Calls.Term) (env : Calls.Slot → V)
    (operation : Calls.Head → List V → V)
    (arguments : ArgumentProofs env operation leftArgs rightArgs) :
    Calls.evalCall env operation ⟨head,owner,phase,leftArgs⟩ =
      Calls.evalCall env operation ⟨head,owner,phase,rightArgs⟩ := by
  have eq : leftArgs.map (Calls.eval env operation) = rightArgs.map (Calls.eval env operation) := by
    induction arguments with
    | nil => rfl
    | cons same _ ih => simp only [List.map_cons, same, ih]
  simp only [Calls.evalCall, eq]

/- The argument equality needed above can be supplied by the existing typed
   JOIN segmentation theorem, including unary barriers and empty arities. -/
theorem join_argument_context {Atom Result : Type}
    (arity : ACGN.ThirdFive.GuardedJoinChain.Tree Atom → Nat)
    (source target : ACGN.ThirdFive.GuardedJoinChain.Tree Atom)
    (positive : ∀ s, s ∈ ACGN.Section3.DependentChainSequence.sourceLeaves
      (JoinSegmentation.plan arity source).cut → 0 < arity s)
    (width : ∀ s, s ∈ ACGN.Section3.DependentChainSequence.sourceLeaves
      (JoinSegmentation.plan arity source).cut →
      ∀ row, ACGN.ThirdFive.GuardedJoinChain.eval s row → row.length = arity s)
    (ports : ACGN.Section3.DependentChainSequence.sourceLeaves
      (JoinSegmentation.pack (JoinSegmentation.portModel arity
        (JoinSegmentation.plan arity source).cut positive width)
        (JoinSegmentation.plan arity source).cut) =
      ACGN.Section3.DependentChainSequence.sourceLeaves target)
    (guarded : ACGN.BoundedFive.DependentJoinGuard.guard .JOIN
      ((ACGN.Section3.DependentChainSequence.sourceLeaves
        (JoinSegmentation.pack (JoinSegmentation.portModel arity
          (JoinSegmentation.plan arity source).cut positive width)
          (JoinSegmentation.plan arity source).cut)).map
          ACGN.ThirdFive.GuardedJoinChain.Operand.arity) = true)
    (context : (List Atom → Prop) → Result) :
    context (ACGN.ThirdFive.GuardedJoinChain.eval source) =
      context (ACGN.ThirdFive.GuardedJoinChain.eval target) :=
  congrArg context (JoinSegmentation.typed_frontier_presentation arity source target
    positive width ports guarded)

/- P10: checked cache entries share the entire immutable obligation key. All
   occurrence references remain in the work list, even when checks are reused.
   This contract imposes no fixed census size, depth or binder-count limit. -/
def checkOnce [DecidableEq Key] (check : Key → Bool) : List Key → List Key → Bool
  | _, [] => true
  | seen, key :: rest =>
    if key ∈ seen then checkOnce check seen rest
    else check key && checkOnce check (key :: seen) rest

theorem memoized_check_exact [DecidableEq Key] (check : Key → Bool)
    (work seen : List Key) (soundCache : ∀ k ∈ seen, check k = true) :
    checkOnce check seen work = work.all check := by
  induction work generalizing seen with
  | nil => rfl
  | cons key rest ih =>
    by_cases cached : key ∈ seen
    · simp [checkOnce, cached, soundCache key cached, ih seen soundCache]
    · cases hk : check key with
      | false => simp [checkOnce, cached, hk]
      | true =>
        have hs : ∀ k ∈ key :: seen, check k = true := by
          intro k member
          rcases List.mem_cons.mp member with rfl | tail
          · exact hk
          · exact soundCache k tail
        simp [checkOnce, cached, hk, ih (key :: seen) hs]

theorem memoized_no_exclusion [DecidableEq Key] (check : Key → Bool)
    (work seen : List Key) (soundCache : ∀ k ∈ seen, check k = true)
    (accepted : checkOnce check seen work = true) :
    ∀ k ∈ work, check k = true := by
  rw [memoized_check_exact check work seen soundCache] at accepted
  exact List.all_eq_true.mp accepted

theorem late_invalid_obligation_rejected [DecidableEq Key] (check : Key → Bool)
    (work seen : List Key) (soundCache : ∀ k ∈ seen, check k = true)
    (key : Key) (member : key ∈ work) (invalid : check key = false) :
    checkOnce check seen work = false := by
  apply Bool.eq_false_iff.mpr
  intro accepted
  have h := memoized_no_exclusion check work seen soundCache accepted key member
  rw [invalid] at h
  contradiction

/- Executable controls for the shared infrastructure. Natural-source binding
   and exact old Java gate witnesses are separate frozen evidence inputs. -/
theorem changed_type_remains_paid :
    (onePaid "Work" "User").accepts = true ∧ (onePaid "Work" "User").total = 1 :=
  paid_transport_not_free _ _ (by decide)

theorem changed_charge_rejected :
    Native.check ([⟨0,"Work"⟩] : List (Native.Origin String)) [⟨0,"User"⟩] 0 0
      [⟨.update,0,some 0,some 0⟩] = false := by decide

theorem missing_declaration_pair_not_free : matrixCharge [] 0 0 = 1 := by decide

theorem no_512_obligation_cutoff :
    checkOnce (fun _ : Nat => true) [] (List.replicate 712 0) = true := by
  rw [memoized_check_exact _ _ _ (by simp)]
  exact List.all_eq_true.mpr (fun _ _ => rfl)

theorem invalid_after_512_rejected :
    checkOnce (fun n : Nat => n == 0) [] (List.replicate 712 0 ++ [1]) = false := by
  exact late_invalid_obligation_rejected _ _ _ (by simp) 1
    (List.mem_append.mpr (Or.inr (by simp))) (by decide)

def retainedTypedSource : Trace.Store (Fin 1) String := fun _ => some "Work/owner0/slot2"
def retainedTypedTarget : Trace.Store (Fin 1) String := fun _ => some "User/owner0/slot0"
def retainedTypedEdit : List (Trace.Operation (Fin 1) String) :=
  [⟨0,some "Work/owner0/slot2",some "User/owner0/slot0",1⟩]

theorem typed_paid_replay_executes :
    replayCheck retainedTypedSource retainedTypedTarget retainedTypedEdit 1 = true := by decide

theorem substituted_typed_source_rejected :
    replayCheck (fun _ => some "Work/foreignOwner/slot2")
      retainedTypedTarget retainedTypedEdit 1 = false := by decide

theorem incorrect_selected_total_rejected :
    replayCheck retainedTypedSource retainedTypedTarget retainedTypedEdit 0 = false := by decide

def completeExample : ExecutableJoint 1 String String :=
  ⟨⟨[],[],[],[],[],[]⟩, (fun _ => some "source"), (fun _ => some "middle"),
    (fun _ => some "target"), [⟨0,some "source",some "middle",1⟩],
    [⟨0,some "middle",some "target",1⟩], 1, 1⟩

def exampleSelected : SelectedPrograms 1 String :=
  ⟨[], completeExample.matrix, completeExample.temporal⟩

def unitEdit (op : Trace.Operation (Fin 1) String) : Bool :=
  decide (op.charge = if op.before = op.after then 0 else 1)

theorem complete_example_checked :
    completeExample.check (fun b => b.origin.exactType) ⟨[],[]⟩
      exampleSelected (fun _ => unitEdit) unitEdit = true ∧ completeExample.total = 2 := by decide

def reverseExample : ExecutableJoint 1 String String :=
  ⟨⟨[],[],[],[],[],[]⟩, (fun _ => some "target"), (fun _ => some "middle"),
    (fun _ => some "source"), [⟨0,some "target",some "middle",1⟩],
    [⟨0,some "middle",some "source",1⟩], 1, 1⟩

theorem complete_reverse_checked :
    reverseExample.check (fun b => b.origin.exactType) ⟨[],[]⟩
      ⟨[],reverseExample.matrix,reverseExample.temporal⟩
      (fun _ => unitEdit) unitEdit = true ∧ reverseExample.total = 2 := by decide

theorem omitted_component_rejected :
    ({completeExample with matrix := [], matrixTotal := 0}).check
      (fun b => b.origin.exactType) ⟨[],[]⟩ exampleSelected
      (fun _ => unitEdit) unitEdit = false := by decide

theorem double_charged_component_rejected :
    ({completeExample with matrixTotal := 2}).check
      (fun b => b.origin.exactType) ⟨[],[]⟩ exampleSelected
      (fun _ => unitEdit) unitEdit = false := by decide

theorem wrong_intermediate_owner_rejected :
    ({completeExample with middle := fun _ => some "foreignOwner"}).check
      (fun b => b.origin.exactType) ⟨[],[]⟩ exampleSelected
      (fun _ => unitEdit) unitEdit = false := by decide

theorem substituted_same_cost_path_rejected :
    ({completeExample with matrix := [⟨0,some "source",some "otherTarget",1⟩]}).check
      (fun b => b.origin.exactType) ⟨[],[]⟩ exampleSelected
      (fun _ => unitEdit) unitEdit = false := by decide

end Focused225SharedContracts
