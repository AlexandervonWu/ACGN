import DistanceDerivedTrace
import TemporalReferenceReachability

/- A presentation ordinal is not a source identity. The adapter must obtain the
   identities below from live frozen objects, not reconstruct them from labels.
   This contract changes coordinates of one selected path; it does not equate
   independently selected paths, certify Java, or discard alternative branches. -/
namespace AuthenticatedPhaseTransport

structure Reindex (A B : Type) where
  forward : A → B
  backward : B → A
  left : ∀ a, backward (forward a) = a
  right : ∀ b, forward (backward b) = b

def Reindex.symm (e : Reindex A B) : Reindex B A :=
  ⟨e.backward, e.forward, e.right, e.left⟩

def Reindex.trans (e : Reindex A B) (f : Reindex B C) : Reindex A C where
  forward a := f.forward (e.forward a)
  backward c := e.backward (f.backward c)
  left a := by simp [f.left, e.left]
  right c := by simp [e.right, f.right]

theorem inverse_eq (e : Reindex A B) (b : B) (a : A) :
    e.backward b = a ↔ b = e.forward a := by
  constructor
  · intro h; rw [← e.right b, h]
  · intro h; rw [h, e.left]

def checkedReindex (to back : Fin n → Fin n) : Option (Reindex (Fin n) (Fin n)) :=
  if h : (∀ i, back (to i) = i) ∧ (∀ i, to (back i) = i) then
    some ⟨to, back, h.1, h.2⟩
  else none

/- Authentic includes object identity AND the entire original typed record.
   In Java, Identity must be reference identity; a matching serialized path,
   owner label or type string cannot implement this premise. -/
structure Original (Identity Data : Type) where
  object : Identity
  data : Data
  deriving DecidableEq

def authentic [DecidableEq I] [DecidableEq D]
    (source view : Fin n → Original I D) (e : Reindex (Fin n) (Fin n)) : Bool :=
  decide (∀ i, view i = source (e.forward i))

theorem authentic_record [DecidableEq I] [DecidableEq D]
    (source view : Fin n → Original I D) (e : Reindex (Fin n) (Fin n))
    (checked : authentic source view e = true) (i : Fin n) :
    view i = source (e.forward i) := by
  exact (of_decide_eq_true checked) i

def between (fast certified : Reindex V O) : Reindex V V :=
  fast.trans certified.symm

theorem cross_original (fast certified : Reindex V O) (i : V) :
    certified.forward ((between fast certified).forward i) = fast.forward i := by
  exact certified.right (fast.forward i)

theorem authentic_join [DecidableEq I] [DecidableEq D]
    (source fastView certView : Fin n → Original I D)
    (fast cert : Reindex (Fin n) (Fin n))
    (hf : authentic source fastView fast = true)
    (hc : authentic source certView cert = true) (i : Fin n) :
    fastView i = certView ((between fast cert).forward i) := by
  rw [authentic_record source fastView fast hf,
    authentic_record source certView cert hc, cross_original]

theorem foreign_object_rejected [DecidableEq I] [DecidableEq D]
    (source view : Fin n → Original I D) (e : Reindex (Fin n) (Fin n))
    (i : Fin n) (foreign : (view i).object ≠ (source (e.forward i)).object) :
    authentic source view e = false := by
  apply Bool.eq_false_iff.mpr
  intro h
  exact foreign (congrArg Original.object (authentic_record source view e h i))

/- Source payloads are indexed through the checked identity map. This retains
   arbitrary typed data, ordered dependency/branch lists, and selected payment;
   it never sorts those lists or supplies a payment for an unrelated REF. -/
def present (source : O → D) (e : Reindex V O) : V → D := source ∘ e.forward

theorem ordered_lookup (source : O → D) (fast cert : Reindex V O) (xs : List V) :
    (xs.map (between fast cert).forward).map (present source cert) =
      xs.map (present source fast) := by
  simp only [List.map_map]
  apply List.map_congr_left
  intro i _
  exact congrArg source (cross_original fast cert i)

def phaseAddress (e : Reindex A B) : Reindex (A × P) (B × P) where
  forward p := (e.forward p.1, p.2)
  backward p := (e.backward p.1, p.2)
  left p := by simp [e.left]
  right p := by simp [e.right]

open DistanceDerivedTrace

def moveStore (e : Reindex A B) (s : Store A P) : Store B P :=
  fun b => s (e.backward b)

def moveOperation (e : Reindex A B) (op : Operation A P) : Operation B P :=
  ⟨e.forward op.address, op.before, op.after, op.charge⟩

theorem lookup_transport (e : Reindex A B) (s : Store A P) (a : A) :
    moveStore e s (e.forward a) = s a := by simp [moveStore, e.left]

theorem apply_transport [DecidableEq A] [DecidableEq B] [DecidableEq P]
    (e : Reindex A B) (s : Store A P) (op : Operation A P) :
    apply (moveStore e s) (moveOperation e op) = (apply s op).map (moveStore e) := by
  by_cases h : s op.address = op.before
  · simp only [apply, moveStore, moveOperation, e.left, h, ↓reduceIte, Option.map_some]
    congr 1
    funext b
    change (if b = e.forward op.address then op.after else s (e.backward b)) =
      (if e.backward b = op.address then op.after else s (e.backward b))
    simp only [inverse_eq]
  · simp [apply, moveStore, moveOperation, e.left, h]

theorem run_transport [DecidableEq A] [DecidableEq B] [DecidableEq P]
    (e : Reindex A B) (s : Store A P) (ops : List (Operation A P)) :
    run (moveStore e s) (ops.map (moveOperation e)) =
      (run s ops).map (moveStore e) := by
  induction ops generalizing s with
  | nil => rfl
  | cons op ops ih =>
    simp only [List.map_cons, run, apply_transport]
    cases h : apply s op with
    | none => rfl
    | some next => exact ih next

theorem selected_cost_preserved (e : Reindex A B) (ops : List (Operation A P)) :
    cost (ops.map (moveOperation e)) = cost ops := by
  simp [cost, moveOperation, Function.comp_def]

theorem selected_path_preserved [DecidableEq A] [DecidableEq B] [DecidableEq P]
    (e : Reindex A B) (s t : Store A P) (ops : List (Operation A P))
    (replayed : run s ops = some t) :
    run (moveStore e s) (ops.map (moveOperation e)) = some (moveStore e t) ∧
      cost (ops.map (moveOperation e)) = cost ops := by
  exact ⟨by rw [run_transport, replayed]; rfl, selected_cost_preserved e ops⟩

theorem invalid_selected_path_stays_invalid
    [DecidableEq A] [DecidableEq B] [DecidableEq P]
    (e : Reindex A B) (s : Store A P) (ops : List (Operation A P))
    (failed : run s ops = none) :
    run (moveStore e s) (ops.map (moveOperation e)) = none := by
  rw [run_transport, failed]; rfl

/- Concrete coordinates from retained eWmme...inv6 source phase enumeration.
   These are natural serialized observations, NOT proof of live Java object
   capture. Token numbers model distinct original objects; Java must supply the
   checked association before this witness licenses its gate replacement. -/
def fastOrder (i : Fin 6) : Fin 6 := ([0, 1, 3, 2, 4, 5] : List (Fin 6)).get i
def certOrder (i : Fin 6) : Fin 6 := ([0, 1, 3, 2, 5, 4] : List (Fin 6)).get i
def fastIndex : Reindex (Fin 6) (Fin 6) :=
  ⟨fastOrder, fastOrder, by decide, by decide⟩
def certIndex : Reindex (Fin 6) (Fin 6) :=
  ⟨certOrder, certOrder, by decide, by decide⟩

structure TypedBinding where
  owner : Nat
  bindingPath : String
  exactType : String
  role : String
  quantifier : String
  dependencies : List Nat
  domain : String
  cardinality : String
  disjointness : Nat
  deriving DecidableEq

structure TypedPhase where
  path : String
  temporalRole : String
  bindings : List TypedBinding
  deriving DecidableEq

def naturalPhase (i : Fin 6) : Original Nat TypedPhase :=
  ⟨([4, 5, 8, 11, 14, 17] : List Nat).get i,
    ⟨(["phase[0]", "phase[0]/temporal[0]",
    "phase[0]/temporal[0]/temporal[0]", "phase[0]/temporal[0]/temporal[1]",
    "phase[0]/temporal[0]/temporal[2]", "phase[0]/temporal[0]/temporal[3]"] : List String).get i,
    if i.val = 0 then "NONE" else if i.val = 1 then "ALWAYS" else "EVENTUALLY",
    if i.val = 0 then [] else
      [⟨1, "root/temporalroot[0]/decl[0]@pos", "AlloyCarrier(Signal)",
        if i.val = 1 then "MATRIX" else "INHERITED", "ALL", [],
        "19:alloy-binder-domain[1:6:Signal]{0:}", "ONE", 0⟩]⟩⟩

def oldIndexedGate (a b : Fin 6 → Original Nat TypedPhase) : Bool :=
  decide (∀ i, (a i).data.path = (b i).data.path ∧
    (a i).data.temporalRole = (b i).data.temporalRole)

theorem natural_old_rejected :
    oldIndexedGate (present naturalPhase fastIndex) (present naturalPhase certIndex) = false := by
  decide

theorem natural_both_presentations_authenticated :
    authentic naturalPhase (present naturalPhase fastIndex) fastIndex = true ∧
    authentic naturalPhase (present naturalPhase certIndex) certIndex = true := by decide

theorem natural_both_directions :
    (∀ i, present naturalPhase fastIndex i =
      present naturalPhase certIndex ((between fastIndex certIndex).forward i)) ∧
    (∀ i, present naturalPhase certIndex i =
      present naturalPhase fastIndex ((between certIndex fastIndex).forward i)) := by decide

/- A same-metadata foreign object is not a witness for an original occurrence. -/
theorem natural_foreign_object_rejected :
    authentic naturalPhase (fun i => { present naturalPhase certIndex i with object := 99 })
      certIndex = false := by decide

theorem natural_wrong_owner_rejected :
    authentic naturalPhase (fun i => ⟨(present naturalPhase certIndex i).object,
      { (present naturalPhase certIndex i).data with bindings :=
        ((present naturalPhase certIndex i).data.bindings.map fun b => { b with owner := 99 }) }⟩)
      certIndex = false := by decide

theorem natural_wrong_dependency_rejected :
    authentic naturalPhase (fun i => ⟨(present naturalPhase certIndex i).object,
      { (present naturalPhase certIndex i).data with bindings :=
        ((present naturalPhase certIndex i).data.bindings.map fun b => { b with dependencies := [99] }) }⟩)
      certIndex = false := by decide

theorem duplicate_map_rejected :
    (checkedReindex (fun _ : Fin 6 => 0) id).isNone = true := by decide

/- Held-out structural cycle, not a natural-corpus positive. -/
def heldOut : Reindex (Fin 3) (Fin 3) :=
  ⟨fun i => ([1, 2, 0] : List (Fin 3)).get i,
    fun i => ([2, 0, 1] : List (Fin 3)).get i, by decide, by decide⟩
theorem held_out_not_involution : heldOut.forward (heldOut.forward 0) ≠ 0 := by decide
theorem held_out_ordered_branches :
    (([2, 0, 1, 0] : List (Fin 3)).map heldOut.forward).map heldOut.backward =
      [2, 0, 1, 0] := by decide

/- Selected-reference identity and payment are indivisible payload fields.
   This derived control is not a natural positive or a new payment rule. -/
structure SelectedReference where
  object : Nat
  owner : Nat
  branches : List Nat
  payment : Nat
  deriving DecidableEq

def controlPayload : SelectedReference := ⟨7, 2, [3, 4], 9⟩
def controlStore : Store (Fin 3) SelectedReference :=
  fun i => if i = 0 then some controlPayload else none
def controlEdit : Operation (Fin 3) SelectedReference :=
  ⟨0, some controlPayload, some { controlPayload with branches := [4, 3] }, 1⟩

theorem held_out_selected_edit_runs :
    (run controlStore [controlEdit]).isSome = true ∧
    (run (moveStore heldOut controlStore) [moveOperation heldOut controlEdit]).isSome = true ∧
    cost [moveOperation heldOut controlEdit] = 1 := by decide

theorem wrong_payment_rejected :
    (apply controlStore { controlEdit with before := (some { controlPayload with payment := 10 }) }).isNone = true := by decide

theorem wrong_ordered_branch_rejected :
    (apply controlStore { controlEdit with before := (some { controlPayload with branches := [4, 3] }) }).isNone = true := by decide

theorem wrong_reference_rejected :
    (apply controlStore { controlEdit with before := (some { controlPayload with object := 8 }) }).isNone = true := by decide

#print axioms authentic_join
#print axioms selected_path_preserved
#print axioms invalid_selected_path_stays_invalid
#print axioms natural_old_rejected
end AuthenticatedPhaseTransport
