import Phase5SourceRules
import TemporalPhaseLocalBinding

/- A reference is a whole owner-issued occurrence, including ordered branches.
   Projection removes unused occurrences, not individual branches or predicates.
   Java correspondence and source captures are separate checked obligations. -/
namespace TemporalReferenceReachability

structure Binding where
  ownerPhase : List Nat
  sourceOccurrence : Nat
  sourceSlot : Nat
  exactType : String
  dependencies : List Nat
  deriving DecidableEq, Repr

structure Branch where
  sourcePhase : List Nat
  role : Nat
  bindings : List Binding
  deriving DecidableEq, Repr

structure Reference where
  ownerPhase : List Nat
  occurrence : Nat
  parserOccurrence : Nat
  sourceSlot : Nat
  branches : List Branch
  deriving DecidableEq, Repr

/- The algebra is deliberately arbitrary: support preservation does not rely
   on a list of accepted Boolean or temporal operators. -/
inductive Expr (Value : Type) where
  | literal (value : Value)
  | reference (source : Reference)
  | unary (operator : Value → Value) (body : Expr Value)
  | binary (operator : Value → Value → Value) (left right : Expr Value)

def support : Expr Value → List Reference
  | .literal _ => []
  | .reference source => [source]
  | .unary _ body => support body
  | .binary _ left right => support left ++ support right

def construct (resolve : Reference → Option Value) : Expr Value → Option Value
  | .literal value => some value
  | .reference source => resolve source
  | .unary operator body => (construct resolve body).map operator
  | .binary operator left right => do
      let a ← construct resolve left
      let b ← construct resolve right
      pure (operator a b)

theorem construction_depends_only_on_referenced_occurrences
    (expression : Expr Value) (before after : Reference → Option Value)
    (agree : ∀ source ∈ support expression, before source = after source) :
    construct before expression = construct after expression := by
  induction expression with
  | literal value => rfl
  | reference source => exact agree source (by simp [support])
  | unary operator body ih =>
      simp only [construct, ih (by simpa [support] using agree)]
  | binary operator left right ihl ihr =>
      have hl := ihl (fun source member => agree source (by simp [support, member]))
      have hr := ihr (fun source member => agree source (by simp [support, member]))
      simp only [construct, hl, hr]

def restrict (live : List Reference) (resolve : Reference → Option Value)
    (source : Reference) : Option Value :=
  if source ∈ live then resolve source else none

theorem restriction_preserves_construction
    (expression : Expr Value) (resolve : Reference → Option Value) :
    construct (restrict (support expression) resolve) expression =
      construct resolve expression := by
  apply construction_depends_only_on_referenced_occurrences
  intro source member
  simp [restrict, member]

theorem restriction_cannot_change_live_failure
    (expression : Expr Value) (resolve : Reference → Option Value)
    (failed : construct resolve expression = none) :
    construct (restrict (support expression) resolve) expression = none := by
  rw [restriction_preserves_construction, failed]

def retainedGroups (issued live : List Reference) : List Reference :=
  issued.filter (fun source => source ∈ live)

theorem retained_group_is_exact_original (issued live : List Reference)
    (source : Reference) :
    source ∈ retainedGroups issued live ↔ source ∈ issued ∧ source ∈ live := by
  simp [retainedGroups]

theorem branch_order_and_binding_preserved (issued live : List Reference)
    (source : Reference) (present : source ∈ retainedGroups issued live) :
    ∃ original ∈ issued, original = source ∧ original.branches = source.branches := by
  exact ⟨source, (retained_group_is_exact_original issued live source).mp present |>.1,
    rfl, rfl⟩

def relocatedResolver (address : Reference → Nat) (lookup : Nat → Option Reference)
    (resolve : Reference → Option Value) (source : Reference) : Option Value := do
  let retained ← lookup (address source)
  if retained = source then resolve retained else none

theorem checked_relocation_preserves_construction (expression : Expr Value)
    (address : Reference → Nat) (lookup : Nat → Option Reference)
    (resolve : Reference → Option Value)
    (roundtrip : ∀ source ∈ support expression, lookup (address source) = some source) :
    construct (relocatedResolver address lookup resolve) expression =
      construct resolve expression := by
  apply construction_depends_only_on_referenced_occurrences
  intro source member
  simp [relocatedResolver, roundtrip source member]

theorem checked_relocation_is_injective_on_live (live : List Reference)
    (address : Reference → Nat) (lookup : Nat → Option Reference)
    (roundtrip : ∀ source ∈ live, lookup (address source) = some source)
    (a b : Reference) (ha : a ∈ live) (hb : b ∈ live)
    (sameAddress : address a = address b) : a = b := by
  have same : some a = some b := by
    rw [← roundtrip a ha, ← roundtrip b hb, sameAddress]
  exact Option.some.inj same

theorem relocation_rejects_same_address_foreign_occurrence
    (address : Reference → Nat) (lookup : Nat → Option Reference)
    (resolve : Reference → Option Value) (source foreign : Reference)
    (different : foreign ≠ source) (wrong : lookup (address source) = some foreign) :
    relocatedResolver address lookup resolve source = none := by
  simp [relocatedResolver, wrong, different]

/- The old adapter resolves every issued child before constructing the matrix.
   This models that ordering without changing what a failed child means. -/
def eagerGate (issued : List Reference) (resolve : Reference → Option Value) : Bool :=
  issued.all (fun source => (resolve source).isSome)

def oldConstruct (issued : List Reference) (resolve : Reference → Option Value)
    (expression : Expr Value) : Option Value :=
  if eagerGate issued resolve then construct resolve expression else none

theorem unused_failed_child_rejects_old (source : Reference) (value : Value) :
    oldConstruct [source] (fun _ => none) (.literal value) = none := by
  simp [oldConstruct, eagerGate]

theorem unused_failed_child_does_not_affect_literal (source : Reference) (value : Value) :
    oldConstruct [source] (fun _ => none) (.literal value) = none ∧
    construct (fun _ => none) (.literal value) = some value := by
  exact ⟨unused_failed_child_rejects_old source value, rfl⟩

theorem live_failed_child_rejected (source : Reference) :
    construct (fun _ => none : Reference → Option Bool) (.reference source) = none := rfl

theorem foreign_reference_rejected (source foreign : Reference) (different : source ≠ foreign)
    (value : Value) :
    restrict [source] (fun _ => some value) foreign = none := by
  simp [restrict, Ne.symm different]

/- Exact natural source shapes. No inhabitance or temporal-body truth is
   assumed: the relation-valued domains may be empty and traces arbitrary. -/
def trainSource (Train Track : Type) (position : Nat → Train → Track → Prop)
    (now : Nat) : Prop :=
  futureAlways (fun instant => ∀ train : Train, ∀ track : Track,
    (position instant train track ∧ ¬ position instant train track) →
      futureAlways (fun next => position next train track) instant) now

theorem train_source_reduces_to_true (Train Track : Type)
    (position : Nat → Train → Track → Prop) (now : Nat) :
    trainSource Train Track position now ↔ True := by
  constructor
  · intro _; trivial
  · intro _ instant _ train track impossible
    exact False.elim (impossible.2 impossible.1)

def trashSource (File : Type) (existsAt trash : Nat → File → Prop) (now : Nat) : Prop :=
  futureEventually (fun instant => ∃ file, existsAt instant file ∧
    ((trash instant file → futureEventually (fun next => ¬ trash next file) (instant + 1))
      ∨ trash instant file)) now

theorem trash_source_reduces_to_nonempty (File : Type)
    (existsAt trash : Nat → File → Prop) (now : Nat) :
    trashSource File existsAt trash now ↔
      futureEventually (fun instant => ∃ file, existsAt instant file) now := by
  classical
  constructor
  · rintro ⟨instant, afterNow, file, existsNow, _⟩
    exact ⟨instant, afterNow, file, existsNow⟩
  · rintro ⟨instant, afterNow, file, existsNow⟩
    refine ⟨instant, afterNow, file, existsNow, ?_⟩
    by_cases present : trash instant file
    · exact Or.inr present
    · exact Or.inl (fun impossible => False.elim (present impossible))

theorem empty_file_domain_not_promoted_to_true
    (trash : Nat → Empty → Prop) (now : Nat) :
    ¬ trashSource Empty (fun _ _ => False) trash now := by
  rintro ⟨_, _, file, _, _⟩
  exact nomatch file

theorem erased_binder_is_not_a_valid_live_import :
    TemporalPhaseLocalBinding.wellScoped 0
      (.unaryTemporal .always (.var 0)) = false := by decide

#print axioms construction_depends_only_on_referenced_occurrences
#print axioms restriction_preserves_construction
#print axioms branch_order_and_binding_preserved
#print axioms train_source_reduces_to_true
#print axioms trash_source_reduces_to_nonempty
end TemporalReferenceReachability
