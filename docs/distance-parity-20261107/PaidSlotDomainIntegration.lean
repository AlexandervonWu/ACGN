import PaidSlotDomainTransport

/- The Java guard matcher commutes only INTERSECT children, after replacing
   dependency traversal positions by authenticated owner-local slot identities.
   The environment and time are fixed; neither binders nor phases are moved. -/
namespace PaidSlotDomainIntegration

def intersection (meaning : Atom → Env → Value → Prop) (parts : List Atom)
    (env : Env) (value : Value) : Prop :=
  ∀ part ∈ parts, meaning part env value

theorem intersection_permutation (meaning : Atom → Env → Value → Prop)
    (before after : List Atom) (same : before.Perm after) (env : Env) (value : Value) :
    intersection meaning before env value ↔ intersection meaning after env value := by
  exact ⟨fun h part member => h part (same.mem_iff.mpr member),
    fun h part member => h part (same.mem_iff.mp member)⟩

theorem negative_guard_permutation (meaning : Atom → Env → Value → Prop)
    (before after : List Atom) (same : before.Perm after) (env : Env) (value : Value) :
    (¬ intersection meaning before env value) ↔ (¬ intersection meaning after env value) :=
  not_congr (intersection_permutation meaning before after same env value)

theorem all_lowered_guard_permutation (meaning : Atom → Env → Value → Prop)
    (before after : List Atom) (same : before.Perm after) (env : Env) (body : Value → Prop) :
    (∀ value, ¬ intersection meaning before env value ∨ body value) ↔
      (∀ value, ¬ intersection meaning after env value ∨ body value) := by
  simp only [negative_guard_permutation meaning before after same env]

theorem old_order_rejects_commuted_intersection : ([0, 1] : List Nat) ≠ [1, 0] := by decide

theorem commuted_intersection_is_sound (meaning : Nat → Env → Value → Prop)
    (env : Env) (value : Value) :
    intersection meaning [0, 1] env value ↔ intersection meaning [1, 0] env value :=
  intersection_permutation meaning _ _ (List.Perm.swap 1 0 []) env value

theorem dropping_guard_is_not_permutation :
    intersection (fun (_ : Nat) (_ : Unit) (_ : Unit) => False) [] () () ∧
      ¬ intersection (fun (_ : Nat) (_ : Unit) (_ : Unit) => False) [0] () () := by
  simp [intersection]

end PaidSlotDomainIntegration

namespace PaidSlotGuardAuthentication

/- An issued occurrence is not a syntactic membership test found in a body.
   Its context includes the entire owner-local Boolean expression; dependency
   coordinates, polarity and exact types cannot be erased by the comparison. -/
structure Occurrence where
  issuer : Nat
  owner : String
  binding : String
  exactType : String
  domain : String
  dependencies : List String
  negative : Bool
  context : String
  deriving DecidableEq, Repr

def authentic (issued : List Occurrence) (actual : Occurrence) : Bool :=
  decide (actual ∈ issued)

theorem authentic_is_issued (issued : List Occurrence) (actual : Occurrence)
    (h : authentic issued actual = true) : actual ∈ issued := by
  simpa [authentic] using h

theorem unissued_decoy_rejected (issued : List Occurrence) (actual : Occurrence)
    (h : actual ∉ issued) : authentic issued actual = false := by
  simp [authentic, h]

theorem changed_context_rejected (origin : Occurrence) (context : String)
    (h : context ≠ origin.context) :
    authentic [origin] { origin with context := context } = false := by
  simp only [authentic, List.mem_cons, List.not_mem_nil, or_false, decide_eq_false_iff_not]
  intro equal
  exact h (congrArg Occurrence.context equal)

inductive Context where
  | hole
  | andLeft (body : Prop) (inner : Context)
  | orLeft (body : Prop) (inner : Context)
  | not (inner : Context)

def Context.eval : Context → Prop → Prop
  | .hole, guard => guard
  | .andLeft body inner, guard => inner.eval guard ∧ body
  | .orLeft body inner, guard => inner.eval guard ∨ body
  | .not inner, guard => ¬ inner.eval guard

theorem context_transport (context : Context) (before after : Prop)
    (same : before ↔ after) : context.eval before ↔ context.eval after := by
  induction context with
  | hole => exact same
  | andLeft body inner ih => exact and_congr ih Iff.rfl
  | orLeft body inner ih => exact or_congr ih Iff.rfl
  | not inner ih => exact not_congr ih

theorem lowered_all (guard body : Prop) : (guard → body) ↔ (¬ guard ∨ body) := by
  classical
  constructor
  · intro h
    by_cases g : guard
    · exact Or.inr (h g)
    · exact Or.inl g
  · intro h g
    exact h.elim (fun absent => False.elim (absent g)) id

theorem intersection_inside_same_context (context : Context)
    (meaning : Atom → Env → Value → Prop) (before after : List Atom)
    (same : before.Perm after) (env : Env) (value : Value) :
    context.eval (PaidSlotDomainIntegration.intersection meaning before env value) ↔
      context.eval (PaidSlotDomainIntegration.intersection meaning after env value) :=
  context_transport context _ _
    (PaidSlotDomainIntegration.intersection_permutation meaning before after same env value)

structure Operation where
  source : Occurrence
  target : Occurrence
  sourcePath : String
  targetPath : String
  headCost : Nat
  subtreeCost : Nat
  deriving DecidableEq, Repr

/- The selected decision and emitted replay entry must be the very same pair
   and charge. Merely appearing somewhere in either endpoint is insufficient. -/
def selectedGuardCheck (sourceIssued targetIssued : List Occurrence)
    (selected emitted : List Operation) (decisionIndex replayIndex : Nat)
    (op : Operation) : Bool :=
  authentic sourceIssued op.source && authentic targetIssued op.target &&
  decide (selected[decisionIndex]? = some op ∧ emitted[replayIndex]? = some op)

theorem selected_guard_exact (sourceIssued targetIssued : List Occurrence)
    (selected emitted : List Operation) (decisionIndex replayIndex : Nat) (op : Operation)
    (h : selectedGuardCheck sourceIssued targetIssued selected emitted decisionIndex replayIndex op = true) :
    op.source ∈ sourceIssued ∧ op.target ∈ targetIssued ∧
    selected[decisionIndex]? = some op ∧ emitted[replayIndex]? = some op := by
  simpa [selectedGuardCheck, authentic, and_assoc] using h

theorem missing_selected_guard_rejected (sourceIssued targetIssued : List Occurrence)
    (selected emitted : List Operation) (decisionIndex replayIndex : Nat) (op : Operation)
    (missing : selected[decisionIndex]? ≠ some op) :
    selectedGuardCheck sourceIssued targetIssued selected emitted decisionIndex replayIndex op = false := by
  simp [selectedGuardCheck, missing]

theorem unpaid_emission_rejected (sourceIssued targetIssued : List Occurrence)
    (op : Operation) (paid : op.headCost ≠ 0) :
    selectedGuardCheck sourceIssued targetIssued [op] [{ op with headCost := 0 }] 0 0 op = false := by
  have different : { op with headCost := 0 } ≠ op := by
    intro equal
    exact paid (congrArg Operation.headCost equal).symm
  simp [selectedGuardCheck, different]

def source : Occurrence := ⟨1, "root", "slot/1", "RELATION[1:A]", "x.next", ["root/slot/0"], true, "OR(guard,REF)"⟩
def target : Occurrence := ⟨2, "root", "slot/1", "RELATION[1:A]", "x.prev", ["root/slot/0"], false, "AND(guard,REF)"⟩
def selected : Operation := ⟨source, target, "root/child/0/child/0", "root/child/0/child/0", 1, 2⟩

theorem concrete_selected_guard : selectedGuardCheck [source] [target] [selected] [selected] 0 0 selected = true := by decide
theorem concrete_reverse_guard :
    let reverse := { selected with source := target, target := source }
    selectedGuardCheck [target] [source] [reverse] [reverse] 0 0 reverse = true := by decide
theorem same_shape_not_same_issuance : authentic [source] { source with issuer := 7 } = false := by decide
theorem wrong_boolean_context : authentic [source] { source with context := "AND(guard,REF)" } = false := by decide
theorem wrong_owner : authentic [source] { source with owner := "root/phase/1" } = false := by decide
theorem missing_guard_operation : selectedGuardCheck [source] [target] [] [selected] 0 0 selected = false := by decide
theorem wrong_charge : selectedGuardCheck [source] [target] [selected] [{ selected with headCost := 0 }] 0 0 selected = false := by decide

end PaidSlotGuardAuthentication
