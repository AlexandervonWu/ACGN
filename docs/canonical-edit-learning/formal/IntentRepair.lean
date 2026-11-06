import Lean

namespace IntentRepair

-- Public views are restricted by the exporter contract to the faulty
-- predicate, its derived candidates and the feedback already returned.
structure Observation (View Decision Witness : Type) where
  initialView : View
  currentView : View
  history : List Decision
  witnesses : List Witness

def initialObservation {V A W : Type} (view : V) : Observation V A W :=
  ⟨view, view, [], []⟩

theorem initial_has_no_feedback {V A W : Type} (view : V) :
    (initialObservation (A := A) (W := W) view).witnesses = [] := rfl

theorem initial_uses_only_faulty_view {V A W : Type} (view : V) :
    (initialObservation (A := A) (W := W) view).currentView = view := rfl

structure TrainingRow (View Decision Witness Teacher : Type) where
  observation : Observation View Decision Witness
  teacher : Teacher

def policyInput {V A W T : Type} (r : TrainingRow V A W T) := r.observation

theorem teacher_change_preserves_input {V A W T : Type}
    (obs : Observation V A W) (a b : T) :
    policyInput (TrainingRow.mk obs a) = policyInput (TrainingRow.mk obs b) := rfl

structure Session (View Decision Witness Private : Type) where
  observation : Observation View Decision Witness
  privateContract : Private

def inferenceInput {V A W P : Type} (s : Session V A W P) := s.observation

theorem private_contract_change_preserves_input {V A W P : Type}
    (obs : Observation V A W) (a b : P) :
    inferenceInput (Session.mk obs a) = inferenceInput (Session.mk obs b) := rfl

theorem fixed_policy_cannot_read_private_contract {V A W P Output : Type}
    (policy : Observation V A W → Output) (obs : Observation V A W) (a b : P) :
    policy (inferenceInput (Session.mk obs a)) =
      policy (inferenceInput (Session.mk obs b)) := rfl

theorem different_feedback_is_retained {V A W : Type}
    (a b : Observation V A W) (h : a.witnesses ≠ b.witnesses) : a ≠ b := by
  intro equal
  exact h (congrArg Observation.witnesses equal)

theorem unseen_future_feedback_hidden {W : Type} (seen futureA futureB : List W) :
    (seen ++ futureA).take seen.length = (seen ++ futureB).take seen.length := by
  simp

-- Fixed-width scalar tables stand for predicate/edge/type/feedback rows.
-- This counts scalar cells, not GPU memory, attention cost or bit storage.
abbrev Row := Fin 16 → Int

structure Packet where
  rows : List Row

structure Envelope (Metadata : Type) where
  packet : Packet
  sidecar : Metadata

def scalarCells (p : Packet) : Nat := 16 * p.rows.length

theorem scalar_budget (p : Packet) (budget : Nat)
    (h : p.rows.length ≤ budget) : scalarCells p ≤ 16 * budget := by
  exact Nat.mul_le_mul_left 16 h

theorem sidecar_does_not_expand_packet {M : Type} (p : Packet) (a b : M) :
    scalarCells (Envelope.mk p a).packet =
      scalarCells (Envelope.mk p b).packet := rfl

structure BinderSite where
  phase : Nat
  context : List Nat
  coordinate : Nat
  deriving DecidableEq, Repr

theorem phase_sites_distinct (a b : BinderSite) (h : a.phase ≠ b.phase) : a ≠ b := by
  intro equal
  exact h (congrArg BinderSite.phase equal)

theorem context_sites_distinct (a b : BinderSite)
    (h : a.context ≠ b.context) : a ≠ b := by
  intro equal
  exact h (congrArg BinderSite.context equal)

-- Every pointer selects an existing row in its own namespace. Actual type,
-- scope, source-occurrence and revision checks are separate executor duties.
inductive Operand (nodes binders types constants : Nat) where
  | node : Fin nodes → Operand nodes binders types constants
  | binder : Fin binders → Operand nodes binders types constants
  | typeRef : Fin types → Operand nodes binders types constants
  | constant : Fin constants → Operand nodes binders types constants

theorem node_pointer_in_range (n b t c : Nat) (i : Fin n) :
    i.val < n ∧ ∃ a : Operand n b t c, a = .node i := ⟨i.isLt, .node i, rfl⟩

structure Frame (sites nodes binders types constants : Nat) where
  family : Fin 9
  site : Fin sites
  operator : Option (Fin 128)
  operands : List (Operand nodes binders types constants)

def frameFields {s n b t c : Nat} (f : Frame s n b t c) : Nat :=
  3 + f.operands.length

def pathFields {s n b t c : Nat} : List (Frame s n b t c) → Nat
  | [] => 0
  | f :: rest => frameFields f + pathFields rest

theorem frame_field_bound {s n b t c : Nat} (f : Frame s n b t c)
    (arity : Nat) (h : f.operands.length ≤ arity) :
    frameFields f ≤ 3 + arity := by
  unfold frameFields
  omega

theorem path_field_bound {s n b t c : Nat} (path : List (Frame s n b t c))
    (arity : Nat) (h : ∀ f ∈ path, f.operands.length ≤ arity) :
    pathFields path ≤ path.length * (3 + arity) := by
  induction path with
  | nil => simp [pathFields]
  | cons f rest ih =>
      have hf := frame_field_bound f arity (h f (by simp))
      have hr := ih (fun g hg => h g (by simp [hg]))
      simp only [pathFields, List.length_cons, Nat.add_mul, Nat.one_mul]
      omega

-- Frames are revision-scoped in the implementation; refresh the tables after
-- each transaction. Intent/profile here belong to the private controller.
structure State (Graph Intent Profile : Type) where
  graph : Graph
  intent : Intent
  profile : Profile
  revision : Nat
  fuel : Nat

def attempt {G I P A : Type} (checked : G → A → Option G)
    (s : State G I P) (a : A) : State G I P :=
  match s.fuel with
  | 0 => s
  | k + 1 => match checked s.graph a with
    | none => { s with fuel := k }
    | some g => { s with graph := g, fuel := k, revision := s.revision + 1 }

theorem attempt_keeps_intent {G I P A : Type} (checked : G → A → Option G)
    (s : State G I P) (a : A) : (attempt checked s a).intent = s.intent := by
  unfold attempt
  cases s.fuel <;> simp
  split <;> rfl

theorem attempt_keeps_profile {G I P A : Type} (checked : G → A → Option G)
    (s : State G I P) (a : A) : (attempt checked s a).profile = s.profile := by
  unfold attempt
  cases s.fuel <;> simp
  split <;> rfl

theorem every_attempt_consumes_fuel {G I P A : Type} (checked : G → A → Option G)
    (s : State G I P) (a : A) (h : 0 < s.fuel) :
    (attempt checked s a).fuel + 1 = s.fuel := by
  cases hf : s.fuel with
  | zero => omega
  | succ k => cases hc : checked s.graph a <;> simp [attempt, hf, hc]

theorem rejected_attempt_keeps_graph {G I P A : Type} (checked : G → A → Option G)
    (s : State G I P) (a : A) (h : checked s.graph a = none) :
    (attempt checked s a).graph = s.graph := by
  unfold attempt
  cases s.fuel <;> simp [h]

def replay {G A : Type} (checked : G → A → Option G) (g : G) : List A → Option G
  | [] => some g
  | a :: rest => do
      let next ← checked g a
      replay checked next rest

theorem replay_first_transition {G A : Type} (checked : G → A → Option G)
    (g target : G) (a : A) (rest : List A)
    (h : replay checked g (a :: rest) = some target) :
    ∃ next, checked g a = some next ∧ replay checked next rest = some target := by
  cases hs : checked g a with
  | none => simp [replay, hs] at h
  | some next => exact ⟨next, rfl, by simpa [replay, hs] using h⟩

theorem replay_deterministic {G A : Type} (checked : G → A → Option G)
    (g : G) (path : List A) (a b : G)
    (ha : replay checked g path = some a) (hb : replay checked g path = some b) :
    a = b := Option.some.inj (ha.symm.trans hb)

-- The intent denotes desired behavior, not the source of a particular answer.
def Satisfies {W : Type} (context desired candidate : W → Bool) : Prop :=
  ∀ w, context w = true → candidate w = desired w

def BankAgrees {W : Type} (desired candidate : W → Bool) (bank : List W) : Prop :=
  ∀ w ∈ bank, candidate w = desired w

theorem same_intent_allows_alternative_targets {W : Type}
    (context desired a b : W → Bool)
    (ha : Satisfies context desired a) (hb : Satisfies context desired b) :
    ∀ w, context w = true → a w = b w := by
  intro w hw
  exact (ha w hw).trans (hb w hw).symm

theorem finite_bank_is_not_success :
    BankAgrees (fun w : Bool => w) (fun _ => true) [true] ∧
    ¬ Satisfies (fun _ => true) (fun w : Bool => w) (fun _ => true) := by
  constructor
  · intro w hw
    have : w = true := by simpa using hw
    simp [this]
  · intro h
    have := h false rfl
    contradiction

theorem incompatible_intents_need_distinguishing_evidence {W : Type}
    (context desiredA desiredB candidate : W → Bool) (w : W)
    (hc : context w = true) (hd : desiredA w ≠ desiredB w) :
    ¬ (Satisfies context desiredA candidate ∧ Satisfies context desiredB candidate) := by
  intro h
  exact hd ((h.1 w hc).symm.trans (h.2 w hc))

def FeedbackConsistent {W : Type} (hypothesis : W → Bool)
    (feedback : List (W × Bool)) : Prop :=
  ∀ entry ∈ feedback, hypothesis entry.1 = entry.2

theorem returned_counterexample_excludes_hypothesis {W : Type}
    (hypothesis : W → Bool) (feedback : List (W × Bool)) (w : W) (label : Bool)
    (present : (w, label) ∈ feedback) (disagrees : hypothesis w ≠ label) :
    ¬ FeedbackConsistent hypothesis feedback := by
  intro consistent
  exact disagrees (consistent (w, label) present)

theorem two_direction_obligations_establish_intent {W : Type}
    (context desired candidate : W → Bool)
    (noExtra : ∀ w, ¬ (context w = true ∧ candidate w = true ∧ desired w = false))
    (noMissing : ∀ w, ¬ (context w = true ∧ desired w = true ∧ candidate w = false)) :
    Satisfies context desired candidate := by
  intro w hw
  cases hd : desired w <;> cases hp : candidate w
  · rfl
  · exact False.elim (noExtra w ⟨hw, hp, hd⟩)
  · exact False.elim (noMissing w ⟨hw, hd, hp⟩)
  · rfl

def successGate (reparsed profileSame feasible noExtra noMissing : Bool) : Bool :=
  reparsed && profileSame && feasible && noExtra && noMissing

theorem success_requires_every_check (p s f e m : Bool)
    (h : successGate p s f e m = true) :
    p = true ∧ s = true ∧ f = true ∧ e = true ∧ m = true := by
  simpa [successGate, Bool.and_eq_true, and_assoc] using h

theorem infeasible_never_success (p s e m : Bool) :
    successGate p s false e m = false := by simp [successGate]

end IntentRepair
