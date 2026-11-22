import UnobservedDeclarationCompletion
import RetainedScopePaidCompletion

/- A fixed-path extension, not a new scalar search or a source equivalence
   between different predicates. Java must recover each endpoint from its
   actual source-owned binding vector and replay the original selected program.
   Observed variables may be completed only if the selected action read
   footprint does not acquire a new zero-charge comparison. -/
namespace SelectedDeclarationCompletion

abbrev Mapping := Nat → Option Nat

structure Origin where
  sourceHash : String
  predicate : String
  occurrence : String
  owner : String
  phase : Nat
  role : String
  branch : List Nat
  dependencies : List Nat
  exactType : String
  domain : String
  quantifier : String
  cardinality : String
  disjointness : Nat
  deriving DecidableEq, BEq

structure Binding where
  origin : Origin
  vectorIndex : Nat
  coordinate : Nat
  ordinal : Nat
  deriving DecidableEq, BEq

-- The binding vector is authoritative. Coordinate and source ordinal are
-- checked fields, never aliases for its index.
def associated (census : List Binding) (index : Nat) (claimed : Binding) : Bool :=
  decide (census[index]? = some claimed ∧ claimed.vectorIndex = index)

theorem associated_exact (census : List Binding) (index : Nat) (claimed : Binding)
    (h : associated census index claimed = true) :
    census[index]? = some claimed ∧ claimed.vectorIndex = index := by
  simpa [associated] using h

theorem foreign_binding_rejected (census : List Binding) (index : Nat)
    (issued claimed : Binding) (known : census[index]? = some issued)
    (foreign : claimed ≠ issued) : associated census index claimed = false := by
  simp [associated, known, Ne.symm foreign]

theorem association_commutes (census : List Binding) (index : Nat) (claimed : Binding)
    (h : associated census index claimed = true) :
    (census[index]?).map Binding.origin = some claimed.origin := by
  rw [(associated_exact census index claimed h).1]
  rfl

structure Endpoint where
  sourceOccurrence : String
  owner : String
  phase : Nat
  role : String
  branch : List Nat
  exactType : String
  operator : String
  binding : Option Nat
  payload : String
  deriving DecidableEq, BEq

structure Action where
  selectedIdentity : String
  before : Option Endpoint
  after : Option Endpoint
  kind : String
  fixedCharge : Nat
  deriving DecidableEq, BEq

-- Mirrors the only map-dependent branch of MatrixDistanceContext.updateCost.
-- A delete/insert and a non-VARIABLE update never query the binder map.
def readPair (a : Action) : Option (Nat × Nat) :=
  match a.before, a.after with
  | some x, some y =>
    if x.operator = "VARIABLE" ∧ y.operator = "VARIABLE" then
      match x.binding, y.binding with
      | some i, some j => some (i, j)
      | _, _ => none
    else none
  | _, _ => none

def charge (m : Mapping) (a : Action) : Nat :=
  match readPair a with
  | some (x, y) => UnobservedDeclarationCompletion.variableCost m x y
  | none => a.fixedCharge

def avoids (actions : List Action) (a b : Nat) : Prop :=
  ∀ action ∈ actions, readPair action ≠ some (a, b)

theorem query_unchanged (m : Mapping) (a b x y : Nat)
    (fresh : m a = none) (notRead : (x, y) ≠ (a, b)) :
    UnobservedDeclarationCompletion.variableCost
      (UnobservedDeclarationCompletion.extend m a b) x y =
    UnobservedDeclarationCompletion.variableCost m x y := by
  by_cases same : x = a
  · subst x
    have different : y ≠ b := by intro h; exact notRead (by simp [h])
    simp [UnobservedDeclarationCompletion.variableCost,
      UnobservedDeclarationCompletion.extend, fresh, Ne.symm different]
  · simp [UnobservedDeclarationCompletion.variableCost,
      UnobservedDeclarationCompletion.extend, same]

theorem action_charge_unchanged (m : Mapping) (a b : Nat) (action : Action)
    (fresh : m a = none) (notRead : readPair action ≠ some (a, b)) :
    charge (UnobservedDeclarationCompletion.extend m a b) action = charge m action := by
  unfold charge
  cases h : readPair action with
  | none => rfl
  | some pair =>
    rcases pair with ⟨x, y⟩
    exact query_unchanged m a b x y fresh (fun eq =>
      notRead (h.trans (congrArg some eq)))

def annotated (actions : List Action) (m : Mapping) : List (Action × Nat) :=
  actions.map (fun op => (op, charge m op))

-- Every original action (including typed endpoints, source identity and paid
-- payload) is retained; extension affects only charge lookup, not the program.
theorem fixed_program_extension (actions : List Action) (m : Mapping) (a b : Nat)
    (fresh : m a = none) (notRead : avoids actions a b) :
    annotated actions (UnobservedDeclarationCompletion.extend m a b) =
      annotated actions m := by
  apply List.map_congr_left
  intro op member
  rw [action_charge_unchanged m a b op fresh (notRead op member)]

theorem selected_execution_unchanged {State : Type}
    (step : State → (Action × Nat) → State) (actions : List Action)
    (initial : State) (m : Mapping) (a b : Nat)
    (fresh : m a = none) (notRead : avoids actions a b) :
    (annotated actions (UnobservedDeclarationCompletion.extend m a b)).foldl step initial =
      (annotated actions m).foldl step initial := by
  rw [fixed_program_extension actions m a b fresh notRead]

theorem total_charge_unchanged (actions : List Action) (m : Mapping) (a b : Nat)
    (fresh : m a = none) (notRead : avoids actions a b) :
    (actions.map (charge (UnobservedDeclarationCompletion.extend m a b))).sum =
    (actions.map (charge m)).sum :=
  RetainedScopePaidCompletion.unchanged_derivation actions (charge m)
    (charge (UnobservedDeclarationCompletion.extend m a b))
    (fun op member => action_charge_unchanged m a b op fresh (notRead op member))

theorem completion_injective (m : Mapping) (a b : Nat)
    (injective : ∀ x z y, m x = some y → m z = some y → x = z)
    (freshTarget : ∀ x, m x ≠ some b) :
    ∀ x z y, UnobservedDeclarationCompletion.extend m a b x = some y →
      UnobservedDeclarationCompletion.extend m a b z = some y → x = z :=
  UnobservedDeclarationCompletion.injective_extension m a b injective freshTarget

theorem completion_preserves_selected (m : Mapping) (a b x y : Nat)
    (fresh : m a = none) (old : m x = some y) :
    UnobservedDeclarationCompletion.extend m a b x = some y :=
  UnobservedDeclarationCompletion.old_link_preserved m a b x y fresh old

-- Exact old absence conjunct in DeclarationMatrixLink.allows(i,j,cost).
def oldAbsentKeep (m : Mapping) (a b : Nat) (leftSeen rightSeen : List Nat) : Bool :=
  decide (m a = none ∧ (a ∉ leftSeen ∨ b ∉ rightSeen))

-- Both-side occurrence alone is not the relevant premise. A new comparison
-- at the proposed pair would change its charge and must be rejected.
theorem read_new_pair_changes_charge (m : Mapping) (a b : Nat) (action : Action)
    (fresh : m a = none) (reads : readPair action = some (a, b)) :
    charge m action = 1 ∧
    charge (UnobservedDeclarationCompletion.extend m a b) action = 0 := by
  simp [charge, reads, UnobservedDeclarationCompletion.variableCost,
    UnobservedDeclarationCompletion.extend, fresh]

-- Source-side ALL/LONE/ALL is retained, not exchanged. The target's adjacent
-- independent ALL binders may have distinct types, including empty carriers.
theorem heterogeneous_all_presentation {A B : Type} (body : A → B → Prop) :
    (∀ a b, body a b) ↔ ∀ b a, body a b := by
  constructor <;> intro h x y <;> exact h y x

#print axioms associated_exact
#print axioms association_commutes
#print axioms foreign_binding_rejected
#print axioms query_unchanged
#print axioms action_charge_unchanged
#print axioms fixed_program_extension
#print axioms selected_execution_unchanged
#print axioms total_charge_unchanged
#print axioms completion_injective
#print axioms completion_preserves_selected
#print axioms read_new_pair_changes_charge
#print axioms heterogeneous_all_presentation
end SelectedDeclarationCompletion
