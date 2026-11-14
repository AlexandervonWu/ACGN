import PhaseOwnedJointRoutes
import Focused225SelectedConsumers

namespace PhaseOwnedGuardPayments
open PhaseOwnedJointRoutes Focused225SharedContracts Focused225Concrete
open Focused225SelectedConsumers

abbrev Literal (A : Type) := A × Bool

def literalEval (meaning : A → Prop) (literal : Literal A) : Prop :=
  if literal.2 then meaning literal.1 else ¬ meaning literal.1

def clauseEval (meaning : A → Prop) (clause : List (Literal A)) : Prop :=
  ∃ literal ∈ clause, literalEval meaning literal

def loweredClause (guards : List A) (body : List (Literal A)) : List (Literal A) :=
  guards.map (fun atom => (atom, false)) ++ body

def clauseCheck [DecidableEq A] (guards : List A) (body actual : List (Literal A)) : Bool :=
  decide (actual.Perm (loweredClause guards body))

theorem clause_permutation (meaning : A → Prop) (left right : List (Literal A))
    (order : left.Perm right) : clauseEval meaning left ↔ clauseEval meaning right := by
  constructor
  · rintro ⟨atom, member, holds⟩
    exact ⟨atom, order.mem_iff.mp member, holds⟩
  · rintro ⟨atom, member, holds⟩
    exact ⟨atom, order.mem_iff.mpr member, holds⟩

theorem guarded_clause_lowering (meaning : A → Prop) (guards : List A)
    (body : List (Literal A)) :
    ((∀ atom ∈ guards, meaning atom) → clauseEval meaning body) ↔
      clauseEval meaning (loweredClause guards body) := by
  classical
  have negative : clauseEval meaning (guards.map (fun atom => (atom, false))) ↔
      ¬ (∀ atom ∈ guards, meaning atom) := by
    simp [clauseEval, literalEval]
  have append : clauseEval meaning (loweredClause guards body) ↔
      clauseEval meaning (guards.map (fun atom => (atom, false))) ∨ clauseEval meaning body := by
    simp [clauseEval, loweredClause, or_and_right, exists_or]
  rw [append, negative]
  by_cases allHold : ∀ atom ∈ guards, meaning atom
  · constructor
    · intro holds
      exact Or.inr (holds allHold)
    · rintro (notAll | bodyHolds) _
      · exact False.elim (notAll allHold)
      · exact bodyHolds
  · exact ⟨fun _ => Or.inl allHold, fun _ holds => False.elim (allHold holds)⟩

theorem checked_clause_preserves_guard [DecidableEq A] (meaning : A → Prop)
    (guards : List A) (body actual : List (Literal A))
    (checked : clauseCheck guards body actual = true) :
    ((∀ atom ∈ guards, meaning atom) → clauseEval meaning body) ↔ clauseEval meaning actual := by
  have order : actual.Perm (loweredClause guards body) := of_decide_eq_true checked
  exact (guarded_clause_lowering meaning guards body).trans (clause_permutation meaning actual _ order).symm

/- Exact selected operation pairing and source-owned resolution are independent
   checks; membership of two endpoints alone cannot authorize their pairing. -/
def selectedOwnedPair (tuple : Binding → List String) (left right : List Scope)
    (program : OwnerProgram) (pairs : List MatrixPair) (key : OperationKey)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) : Option TypedRoute := do
  let pair ← pairAt pairs key
  let selected ← pairedRoute tuple program.env program.candidate pairs key before after
  let owned ← selectedOwnedRoute tuple left right program pair.declarationIndex sourceUses targetUses before after
  if selected = owned then some selected else none

theorem owned_route_extend_census (tuple : Binding → List String) (left right : List Scope)
    (p : OwnerProgram) (action : Nat) (sourceUses targetUses moreSource moreTarget : List MatrixUse)
    (before after : MatrixUse) (route : TypedRoute)
    (prior : selectedOwnedRoute tuple left right p action sourceUses targetUses before after = some route)
    (sourceMember : before ∈ moreSource) (targetMember : after ∈ moreTarget) :
    selectedOwnedRoute tuple left right p action moreSource moreTarget before after = some route := by
  obtain ⟨owner, selected, _, _, sourceResolved, targetResolved⟩ :=
    owned_route_exact tuple left right p action sourceUses targetUses before after route prior
  simp [selectedOwnedRoute, owner, selected, sourceMember, targetMember, sourceResolved, targetResolved]

theorem pair_at_two_left (a b : MatrixPair) (different : a.key ≠ b.key) :
    pairAt [a,b] a.key = some a := by
  simp [pairAt, Ne.symm different]

theorem pair_at_two_right (a b : MatrixPair) (different : a.key ≠ b.key) :
    pairAt [a,b] b.key = some b := by
  simp [pairAt, different]

theorem selected_owned_pair_accepts (tuple : Binding → List String) (left right : List Scope)
    (p : OwnerProgram) (pairs : List MatrixPair) (op : MatrixPair)
    (sourceUses targetUses : List MatrixUse) (route : TypedRoute)
    (found : pairAt pairs op.key = some op) (kind : op.kind = "metric-align") (cost : op.cost = 0)
    (selected : selectedRoute tuple p.env p.candidate op.declarationIndex
      (some op.before.binding) (some op.after.binding) = some route)
    (owned : selectedOwnedRoute tuple left right p op.declarationIndex sourceUses targetUses
      op.before op.after = some route) :
    selectedOwnedPair tuple left right p pairs op.key sourceUses targetUses op.before op.after = some route := by
  simp [selectedOwnedPair, found, pairedRoute, kind, cost, selected, owned]

theorem selected_owned_cross_pair_rejected (tuple : Binding → List String) (left right : List Scope)
    (p : OwnerProgram) (pairs : List MatrixPair) (op : MatrixPair)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse)
    (found : pairAt pairs op.key = some op) (wrong : op.after ≠ after) :
    selectedOwnedPair tuple left right p pairs op.key sourceUses targetUses before after = none := by
  simp [selectedOwnedPair, found,
    genuine_cross_pair_rejected tuple p.env p.candidate pairs op.key op before after found wrong]

theorem selected_owned_pair_exact (tuple : Binding → List String) (left right : List Scope)
    (program : OwnerProgram) (pairs : List MatrixPair) (key : OperationKey)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) (route : TypedRoute)
    (checked : selectedOwnedPair tuple left right program pairs key sourceUses targetUses before after = some route) :
    ∃ pair, pairAt pairs key = some pair ∧
      pairedRoute tuple program.env program.candidate pairs key before after = some route ∧
      selectedOwnedRoute tuple left right program pair.declarationIndex sourceUses targetUses before after = some route := by
  unfold selectedOwnedPair at checked
  cases hp : pairAt pairs key with
  | none => simp [hp] at checked
  | some pair =>
    cases hs : pairedRoute tuple program.env program.candidate pairs key before after with
    | none => simp [hp, hs] at checked
    | some selected =>
      cases ho : selectedOwnedRoute tuple left right program pair.declarationIndex sourceUses targetUses before after with
      | none => simp [hp, hs, ho] at checked
      | some owned =>
        by_cases equal : selected = owned
        · simp [hp, hs, ho, equal] at checked
          cases checked
          exact ⟨pair, rfl, congrArg some equal, ho⟩
        · simp [hp, hs, ho, equal] at checked

theorem selected_owned_pair_has_actual_operation (tuple : Binding → List String)
    (left right : List Scope) (program : OwnerProgram) (pairs : List MatrixPair) (key : OperationKey)
    (sourceUses targetUses : List MatrixUse) (before after : MatrixUse) (route : TypedRoute)
    (checked : selectedOwnedPair tuple left right program pairs key sourceUses targetUses before after = some route) :
    ∃ op, pairAt pairs key = some op ∧ op.before = before ∧ op.after = after ∧
      op.kind = "metric-align" ∧ op.cost = 0 := by
  obtain ⟨_, _, selected, _⟩ := selected_owned_pair_exact tuple left right program pairs key _ _ _ _ route checked
  obtain ⟨op, found, a, b, kind, cost, _⟩ := paired_route_exact tuple program.env program.candidate pairs key _ _ route selected
  exact ⟨op, found, a, b, kind, cost⟩

end PhaseOwnedGuardPayments
