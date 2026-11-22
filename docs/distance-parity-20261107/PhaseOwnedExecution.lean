import PhaseOwnedGuardPayments

/- The extractor supplies source-issued inventories and an actual native replay
   receipt. This composition binds them to one selected execution; it does not
   prove the Java observer or convert paid edits into formula equivalence. -/
namespace PhaseOwnedExecution
open PhaseOwnedGuardPayments PhaseOwnedJointRoutes Focused225SharedContracts
open Focused225Concrete Focused225SelectedConsumers

theorem authorize_selected_matrix (ctx : Context) (request : Borrow) (op : MatrixPair)
    (route : TypedRoute) (charge : ChargeEntry)
    (issued : chargeAt ctx.charges request.chargeKey = some charge)
    (selected : pairAt ctx.matrixPairs request.consumer = some op)
    (notReference : referenceAt ctx.references request.consumer = none)
    (paid : pairedRoute ctx.tuple ctx.env ctx.candidate ctx.matrixPairs request.consumer
      op.before op.after = some route)
    (payment : charge.payment = routePayment route) : authorize ctx request = some charge := by
  simp [authorize, issued, selected, notReference, paid, payment]

theorem ownership_of_exact_census (ctx : Context) (borrows : List Borrow)
    (keys : (ctx.charges.map ChargeEntry.key).Nodup)
    (uses : (consumers ctx).Nodup)
    (requests : (borrows.map Borrow.consumer).Perm (consumers ctx))
    (temporal : ctx.temporalEdits.all (fun edit => decide
      (edit.key = edit.charge.nativeOperation ∧ edit.charge ∈ ctx.charges)) = true)
    (authorized : borrows.all (fun b => (authorize ctx b).isSome) = true) :
    ownershipCheck ctx ctx.charges borrows = true := by
  simp only [ownershipCheck, Bool.and_eq_true, decide_eq_true_eq]
  exact ⟨⟨keys, List.Perm.refl _, uses, requests⟩, temporal, authorized⟩

structure Identity where
  candidate : String
  capture : String
  programPointer : String
  deriving DecidableEq

structure GuardClause (Atom : Type) where
  identity : Identity
  sourcePointer : String
  endpointPointer : String
  registry : String
  sourceSide : Bool
  phase : Nat
  bindings : List Binding
  guards : List Atom
  body : List (Literal Atom)
  actual : List (Literal Atom)

/- `program` identifies the complete selected native trace, not just its cost.
   A content digest uses the explicitly trusted hash binding in the extractor.
   ReplayReceipt issuance is the existing native replay's trusted boundary. -/
structure ReplayReceipt where
  identity : Identity
  program : String
  cost : Nat
  deriving DecidableEq

structure Selection (Atom : Type) where
  identity : Identity
  program : String
  tuple : Binding → List String
  sourceScopes : List Scope
  targetScopes : List Scope
  owner : OwnerProgram
  matrixPairs : List MatrixPair
  sourceUses : List MatrixUse
  targetUses : List MatrixUse
  guards : List (GuardClause Atom)
  charges : List ChargeEntry
  borrows : List Borrow

def Selection.context (s : Selection Atom) : Context :=
  { tuple := s.tuple, env := s.owner.env, candidate := s.owner.candidate,
    matrixPairs := s.matrixPairs, temporalEdits := [], references := [], charges := s.charges }

def Selection.route (s : Selection Atom) (op : MatrixPair) : Option TypedRoute :=
  selectedOwnedPair s.tuple s.sourceScopes s.targetScopes s.owner s.matrixPairs
    op.key s.sourceUses s.targetUses op.before op.after

def pointerBelow (root pointer : String) : Bool :=
  decide (pointer.toList.take (root.toList.length + 1) = root.toList ++ ['/'])

def keyBound (identity : Identity) (key : OperationKey) : Bool :=
  decide (key.receipt = identity.capture) && pointerBelow identity.programPointer key.pointer

def guardCheck [DecidableEq Atom] (s : Selection Atom) (g : GuardClause Atom) : Bool :=
  decide (g.identity = s.identity) &&
    pointerBelow s.identity.programPointer g.endpointPointer &&
    clauseCheck g.guards g.body g.actual &&
    g.bindings.all (fun b => decide
      (resolveBinding (if g.sourceSide then s.sourceScopes else s.targetScopes) g.phase b = some b))

def check [DecidableEq Atom] (s : Selection Atom) (replay : ReplayReceipt)
    (claimed : List ChargeEntry) : Bool :=
  decide (replay.identity = s.identity ∧ replay.program = s.program ∧
    replay.cost = (s.charges.map (fun c => c.payment.amount)).sum) &&
  ownerProgramCheck s.tuple s.sourceScopes s.targetScopes s.owner &&
  s.guards.all (guardCheck s) &&
  s.matrixPairs.all (fun op => keyBound s.identity op.key && (s.route op).isSome) &&
  s.charges.all (fun charge => keyBound s.identity charge.key) &&
  ownershipCheck s.context claimed s.borrows

theorem checks_exact [DecidableEq Atom] (s : Selection Atom) (replay : ReplayReceipt)
    (claimed : List ChargeEntry) (accepted : check s replay claimed = true) :
    (replay.identity = s.identity ∧ replay.program = s.program ∧
      replay.cost = (s.charges.map (fun c => c.payment.amount)).sum) ∧
    ownerProgramCheck s.tuple s.sourceScopes s.targetScopes s.owner = true ∧
    s.guards.all (guardCheck s) = true ∧
    s.matrixPairs.all (fun op => keyBound s.identity op.key && (s.route op).isSome) = true ∧
    s.charges.all (fun charge => keyBound s.identity charge.key) = true ∧
    ownershipCheck s.context claimed s.borrows = true := by
  simpa only [check, Bool.and_eq_true, decide_eq_true_eq, and_assoc] using accepted

theorem check_of_components [DecidableEq Atom] (s : Selection Atom) (replay : ReplayReceipt)
    (claimed : List ChargeEntry)
    (identity : replay.identity = s.identity ∧ replay.program = s.program ∧
      replay.cost = (s.charges.map (fun c => c.payment.amount)).sum)
    (owner : ownerProgramCheck s.tuple s.sourceScopes s.targetScopes s.owner = true)
    (guards : s.guards.all (guardCheck s) = true)
    (pairs : s.matrixPairs.all (fun op => keyBound s.identity op.key && (s.route op).isSome) = true)
    (charges : s.charges.all (fun charge => keyBound s.identity charge.key) = true)
    (payments : ownershipCheck s.context claimed s.borrows = true) :
    check s replay claimed = true := by
  simpa only [check, Bool.and_eq_true, decide_eq_true_eq, and_assoc] using
    And.intro identity ⟨owner, guards, pairs, charges, payments⟩

theorem checked_guard [DecidableEq Atom] (s : Selection Atom) (replay : ReplayReceipt)
    (claimed : List ChargeEntry) (accepted : check s replay claimed = true)
    (g : GuardClause Atom) (member : g ∈ s.guards) (meaning : Atom → Prop) :
    g.identity = s.identity ∧
    (((∀ atom ∈ g.guards, meaning atom) → clauseEval meaning g.body) ↔ clauseEval meaning g.actual) ∧
    (∀ b ∈ g.bindings,
      resolveBinding (if g.sourceSide then s.sourceScopes else s.targetScopes) g.phase b = some b) := by
  have valid := List.all_eq_true.mp (checks_exact s replay claimed accepted).2.2.1 g member
  have h : g.identity = s.identity ∧
      pointerBelow s.identity.programPointer g.endpointPointer = true ∧
      clauseCheck g.guards g.body g.actual = true ∧
      g.bindings.all (fun b => decide
        (resolveBinding (if g.sourceSide then s.sourceScopes else s.targetScopes) g.phase b = some b)) = true := by
    simpa only [guardCheck, Bool.and_eq_true, decide_eq_true_eq, and_assoc] using valid
  exact ⟨h.1, checked_clause_preserves_guard meaning _ _ _ h.2.2.1,
    fun b hb => of_decide_eq_true (List.all_eq_true.mp h.2.2.2 b hb)⟩

theorem checked_route [DecidableEq Atom] (s : Selection Atom) (replay : ReplayReceipt)
    (claimed : List ChargeEntry) (accepted : check s replay claimed = true)
    (op : MatrixPair) (member : op ∈ s.matrixPairs) :
    keyBound s.identity op.key = true ∧ ∃ route, s.route op = some route := by
  have valid := List.all_eq_true.mp (checks_exact s replay claimed accepted).2.2.2.1 op member
  have h := Bool.and_eq_true_iff.mp valid
  refine ⟨h.1, ?_⟩
  cases found : s.route op with
  | none => simp [found] at h
  | some route => exact ⟨route, rfl⟩

theorem checked_paid_target [DecidableEq Atom] (s : Selection Atom) (replay : ReplayReceipt)
    (claimed : List ChargeEntry) (accepted : check s replay claimed = true)
    (op : MatrixPair) (member : op ∈ s.matrixPairs)
    (Value : String → Type) (valuation : (b : Binding) → Value b.origin.exactType) :
    ∃ route, s.route op = some route ∧
      (routeRead route op.before.binding).map (typedRead Value valuation) =
        some ⟨op.after.binding.origin.exactType, valuation op.after.binding⟩ := by
  obtain ⟨_, route, selected⟩ := checked_route s replay claimed accepted op member
  obtain ⟨pair, _, _, owned⟩ := selected_owned_pair_exact s.tuple s.sourceScopes
    s.targetScopes s.owner s.matrixPairs op.key s.sourceUses s.targetUses
      op.before op.after route selected
  exact ⟨route, selected, owned_route_reads_typed_target s.tuple s.sourceScopes s.targetScopes
    s.owner pair.declarationIndex s.sourceUses s.targetUses op.before op.after route owned Value valuation⟩

theorem checked_total_and_replay [DecidableEq Atom] (s : Selection Atom) (replay : ReplayReceipt)
    (claimed : List ChargeEntry) (accepted : check s replay claimed = true) :
    replay.identity = s.identity ∧ replay.program = s.program ∧
    claimed.Perm s.charges ∧ (claimed.map ChargeEntry.key).Nodup ∧
    (claimed.map (fun c => c.payment.amount)).sum = replay.cost := by
  have h := checks_exact s replay claimed accepted
  have ledger := checked_ownership_complete s.context claimed s.borrows h.2.2.2.2.2
  exact ⟨h.1.1, h.1.2.1, ledger.2.1, ledger.1, ledger.2.2.2.trans h.1.2.2.symm⟩

theorem foreign_replay_rejected [DecidableEq Atom] (s : Selection Atom) (replay : ReplayReceipt)
    (claimed : List ChargeEntry) (foreign : replay.identity ≠ s.identity) :
    check s replay claimed = false := by simp [check, foreign]

theorem substituted_program_rejected [DecidableEq Atom] (s : Selection Atom) (replay : ReplayReceipt)
    (claimed : List ChargeEntry) (foreign : replay.program ≠ s.program) :
    check s replay claimed = false := by simp [check, foreign]

theorem foreign_guard_rejected [DecidableEq Atom] (s : Selection Atom) (g : GuardClause Atom)
    (foreign : g.identity ≠ s.identity) : guardCheck s g = false := by simp [guardCheck, foreign]

end PhaseOwnedExecution
