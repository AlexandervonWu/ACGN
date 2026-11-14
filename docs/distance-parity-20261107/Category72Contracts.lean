import Focused225CallViews
import SelectedProgramCompletion
import TemporalReferenceReachability
import PaidSlotGuardReplay
import ReceiptDagRank
import UnionMinimum

/- Shared contracts for the six remaining observed classes. These are not a
   proof of the Java producers or a claim that any retained pair now matches.
   In particular, candidate completeness and source-issued authentication are
   obligations at the boundary, never consequences of equal scalar costs. -/
namespace Category72

open SelectedDeclarationCompletion

namespace Owners

abbrev Registry := Nat → Option Origin

def register (owners : Registry) (key : Nat) (actual : Origin) : Option Registry :=
  match owners key with
  | none => some (fun index => if index = key then some actual else owners index)
  | some issued => if issued = actual then some owners else none

theorem repeated_exact_owner (owners : Registry) (key : Nat) (actual : Origin)
    (issued : owners key = some actual) : register owners key actual = some owners := by
  simp [register, issued]

theorem conflicting_owner (owners : Registry) (key : Nat) (issued actual : Origin)
    (found : owners key = some issued) (different : issued ≠ actual) :
    register owners key actual = none := by
  simp [register, found, different]

theorem registration_retains_other (owners next : Registry) (key index : Nat)
    (actual : Origin) (checked : register owners key actual = some next)
    (other : index ≠ key) : next index = owners index := by
  unfold register at checked
  cases h : owners key with
  | none => simp [h] at checked; subst next; simp [other]
  | some issued =>
    by_cases same : issued = actual
    · simp [h, same] at checked; subst next; rfl
    · simp [h, same] at checked

theorem registration_authenticates (owners next : Registry) (key : Nat)
    (actual : Origin) (checked : register owners key actual = some next) :
    next key = some actual := by
  unfold register at checked
  cases h : owners key with
  | none => simp [h] at checked; subst next; simp
  | some issued =>
    by_cases same : issued = actual
    · simp [h, same] at checked; subst next; simpa [same] using h
    · simp [h, same] at checked

theorem registration_idempotent (owners next : Registry) (key : Nat)
    (actual : Origin) (checked : register owners key actual = some next) :
    register next key actual = some next :=
  repeated_exact_owner next key actual (registration_authenticates owners next key actual checked)

theorem changed_phase_rejected (owners : Registry) (key phase : Nat) (issued : Origin)
    (found : owners key = some issued) (different : issued.phase ≠ phase) :
    register owners key { issued with phase := phase } = none := by
  apply conflicting_owner owners key issued _ found
  intro equal
  exact different (congrArg Origin.phase equal)

end Owners

namespace Completion

/- Every step uses both original binding vectors. The type, owner, phase,
   dependencies and source hash are fields of the associated bindings.
   This completes a repair map; it does not equate differently typed values. -/
inductive Steps (left right : List Binding) (actions : List Action) : Mapping → Mapping → Prop
  | done (mapping) : Steps left right actions mapping mapping
  | add {before middle after : Mapping} (source target : Binding)
      (prior : Steps left right actions before middle)
      (sourceIssued : associated left source.vectorIndex source = true)
      (targetIssued : associated right target.vectorIndex target = true)
      (freshSource : middle source.vectorIndex = none)
      (freshTarget : ∀ i, middle i ≠ some target.vectorIndex)
      (noNewRead : avoids actions source.vectorIndex target.vectorIndex)
      (extended : after = UnobservedDeclarationCompletion.extend middle
        source.vectorIndex target.vectorIndex) : Steps left right actions before after

theorem complete_program_unchanged {left right actions before after}
    (steps : Steps left right actions before after) :
    annotated actions after = annotated actions before := by
  induction steps with
  | done => rfl
  | add source target _ _ _ fresh _ noRead extended ih =>
    rw [extended, fixed_program_extension actions _ _ _ fresh noRead, ih]

theorem complete_execution_unchanged {State : Type} {left right actions before after}
    (steps : Steps left right actions before after)
    (step : State → (Action × Nat) → State) (initial : State) :
    (annotated actions after).foldl step initial =
      (annotated actions before).foldl step initial := by
  rw [complete_program_unchanged steps]

theorem complete_injective {left right actions before after}
    (steps : Steps left right actions before after)
    (initial : ∀ a b c, before a = some c → before b = some c → a = b) :
    ∀ a b c, after a = some c → after b = some c → a = b := by
  induction steps with
  | done => exact initial
  | add source target _ _ _ _ freshTarget _ extended ih =>
    rw [extended]
    exact completion_injective _ _ _ ih freshTarget

end Completion

namespace Selection

/- `order` is an injective ordinal of the complete authenticated program in a
   common finite inventory, NOT a hash, cost, array index, or event identifier.
   Producing that shared inventory/ranking is an explicit Java obligation. -/
structure Key where
  cost : Nat
  order : Nat
  deriving DecidableEq, Repr

def before (a b : Key) : Prop := a.cost < b.cost ∨ a.cost = b.cost ∧ a.order ≤ b.order
instance (a b : Key) : Decidable (before a b) := inferInstanceAs (Decidable (_ ∨ _))

theorem reflexive (a : Key) : before a a := Or.inr ⟨rfl, Nat.le_refl _⟩

theorem transitive (a b c : Key) (ab : before a b) (bc : before b c) : before a c := by
  unfold before at *
  omega

theorem total (a b : Key) : before a b ∨ before b a := by unfold before; omega

theorem antisymmetric (a b : Key) (ab : before a b) (ba : before b a) : a = b := by
  have cost : a.cost = b.cost := by unfold before at *; omega
  have order : a.order = b.order := by unfold before at *; omega
  cases a; cases b; simp_all

def choose (a b : Key) : Key := if before a b then a else b

def select (first : Key) : List Key → Key
  | [] => first
  | next :: rest => select (choose first next) rest

theorem choose_le_left (a b : Key) : before (choose a b) a := by
  by_cases h : before a b
  · simp [choose, h, reflexive]
  · simp [choose, h]; exact (total a b).resolve_left h

theorem choose_le_right (a b : Key) : before (choose a b) b := by
  by_cases h : before a b
  · simp [choose, h]
  · simp [choose, h, reflexive]

theorem selected_le_first (first : Key) (rest : List Key) : before (select first rest) first := by
  induction rest generalizing first with
  | nil => exact reflexive first
  | cons next rest ih => exact transitive _ _ _ (ih _) (choose_le_left first next)

theorem selected_le_member (first : Key) (rest : List Key) (key : Key)
    (member : key ∈ first :: rest) : before (select first rest) key := by
  induction rest generalizing first with
  | nil =>
    have equal : key = first := by simpa using member
    subst key
    exact reflexive first
  | cons next rest ih =>
    rcases List.mem_cons.mp member with rfl | member
    · exact selected_le_first _ _
    · rcases List.mem_cons.mp member with rfl | member
      · change before (select (choose first key) rest) key
        exact transitive _ _ _ (selected_le_first (choose first key) rest) (choose_le_right first key)
      · exact ih _ (List.mem_cons_of_mem _ member)

theorem selected_is_candidate (first : Key) (rest : List Key) : select first rest ∈ first :: rest := by
  induction rest generalizing first with
  | nil => simp [select]
  | cons next rest ih =>
    have member := ih (choose first next)
    rcases List.mem_cons.mp member with equal | tail
    · rw [select, equal]; unfold choose; split <;> simp
    · exact List.mem_cons_of_mem _ (List.mem_cons_of_mem _ tail)

theorem same_candidate_set_same_selection (a b : Key) (as bs : List Key)
    (same : ∀ key, key ∈ a :: as ↔ key ∈ b :: bs) : select a as = select b bs := by
  apply antisymmetric
  · exact selected_le_member a as _ ((same _).mpr (selected_is_candidate b bs))
  · exact selected_le_member b bs _ ((same _).mp (selected_is_candidate a as))

theorem selected_cost_no_larger (a : Key) (as : List Key) (key : Key)
    (member : key ∈ a :: as) : (select a as).cost ≤ key.cost := by
  have h := selected_le_member a as key member
  unfold before at h
  omega

theorem identical_selected_programs {Program : Type} (key : Program → Key)
    (faithful : ∀ x y, key x = key y → x = y) (fast certified : Program)
    (f c : Key) (fs cs : List Key)
    (same : ∀ k, k ∈ f :: fs ↔ k ∈ c :: cs)
    (hf : key fast = select f fs) (hc : key certified = select c cs) : fast = certified := by
  apply faithful
  rw [hf, hc, same_candidate_set_same_selection f c fs cs same]

end Selection

namespace Temporal
open TemporalReferenceReachability

theorem projected_support_and_relocation (expression : Expr Value)
    (address : Reference → Nat) (lookup : Nat → Option Reference)
    (resolve : Reference → Option Value)
    (roundtrip : ∀ source ∈ support expression, lookup (address source) = some source) :
    construct (restrict (support expression) (relocatedResolver address lookup resolve)) expression =
      construct resolve expression := by
  rw [restriction_preserves_construction]
  exact checked_relocation_preserves_construction expression address lookup resolve roundtrip

/- A retained derivation is checked for each alternative, rather than rejecting
   its presence. It may use any previously proved source rule in this context.
   No theorem here manufactures a derivation or identifies two temporal ops. -/
def AllSound (meaning : Rep → Value) (source : Rep) (alternatives : List Rep) : Prop :=
  ∀ rep ∈ alternatives, meaning rep = meaning source

theorem selected_alternative_sound (meaning : Rep → Value) (source selected : Rep)
    (alternatives : List Rep) (index : Nat)
    (derivations : AllSound meaning source alternatives)
    (selection : alternatives[index]? = some selected) : meaning selected = meaning source :=
  derivations selected (List.mem_of_getElem? selection)

theorem selected_alternative_in_context (meaning : Rep → Value) (context : Value → Result)
    (source selected : Rep) (alternatives : List Rep) (index : Nat)
    (derivations : AllSound meaning source alternatives)
    (selection : alternatives[index]? = some selected) :
    context (meaning selected) = context (meaning source) := by
  rw [selected_alternative_sound meaning source selected alternatives index derivations selection]

end Temporal

namespace Census

def validate [DecidableEq Record] (check : Record → Bool) (occurrences : List Record) : Bool :=
  occurrences.all check

theorem unique_records_preserve_every_check [DecidableEq Record]
    (check : Record → Bool) (occurrences : List Record) :
    validate check occurrences.eraseDups = validate check occurrences := by
  apply Bool.eq_iff_iff.mpr
  simp [validate, List.all_eq_true]

theorem failed_occurrence_still_fails [DecidableEq Record]
    (check : Record → Bool) (occurrences : List Record) (bad : Record)
    (present : bad ∈ occurrences) (failed : check bad = false) :
    validate check occurrences.eraseDups = false := by
  rw [unique_records_preserve_every_check]
  cases h : validate check occurrences with
  | false => rfl
  | true => have good := List.all_eq_true.mp h bad present; simp [failed] at good

/- The occurrence ledger is not the validation set. Keep all reads and charges,
   even when the pure context-keyed validation can be memoized. -/
def checkedLedger [DecidableEq Record] (check : Record → Bool) (occurrences : List Record) :
    Option (List Record) := if validate check occurrences.eraseDups then some occurrences else none

theorem accepted_ledger_retains_multiplicity [DecidableEq Record]
    (check : Record → Bool) (occurrences emitted : List Record)
    (accepted : checkedLedger check occurrences = some emitted) :
    emitted = occurrences ∧ validate check occurrences = true := by
  unfold checkedLedger at accepted
  rw [unique_records_preserve_every_check] at accepted
  split at accepted
  · simp_all
  · simp at accepted

end Census

namespace Calls

variable {Slot Atom Result : Type} {arity : Nat}

/- A union argument is relational at a fixed exact arity, including an empty
   extension. CALL slots remain ordered: only the inside of a PLUS is union. -/
inductive Argument (Slot : Type) where
  | leaf (source : Slot)
  | plus (left right : Argument Slot)

def leaves : Argument Slot → List Slot
  | .leaf source => [source]
  | .plus left right => leaves left ++ leaves right

def relation (environment : Slot → (Fin arity → Atom) → Prop) :
    Argument Slot → (Fin arity → Atom) → Prop
  | .leaf source, tuple => environment source tuple
  | .plus left right, tuple => relation environment left tuple ∨ relation environment right tuple

theorem union_denotation (environment : Slot → (Fin arity → Atom) → Prop)
    (argument : Argument Slot) (tuple : Fin arity → Atom) :
    relation environment argument tuple ↔ ∃ slot ∈ leaves argument, environment slot tuple := by
  induction argument with
  | leaf source => simp [relation, leaves]
  | plus left right ihl ihr => simp [relation, leaves, ihl, ihr, List.mem_append, or_and_right, exists_or]

theorem permuted_union_sound (environment : Slot → (Fin arity → Atom) → Prop)
    (before after : Argument Slot) (permutation : (leaves before).Perm (leaves after)) :
    relation environment before = relation environment after := by
  funext tuple
  apply propext
  rw [union_denotation, union_denotation]
  exact ⟨fun ⟨slot, member, holds⟩ => ⟨slot, permutation.mem_iff.mp member, holds⟩,
    fun ⟨slot, member, holds⟩ => ⟨slot, permutation.mem_iff.mpr member, holds⟩⟩

theorem union_association (environment : Slot → (Fin arity → Atom) → Prop)
    (a b c : Argument Slot) :
    relation environment (.plus (.plus a b) c) = relation environment (.plus a (.plus b c)) := by
  funext tuple
  exact propext or_assoc

inductive ArgumentCorrespondence : List (Argument Slot) → List (Argument Slot) → Prop
  | nil : ArgumentCorrespondence [] []
  | cons {a b as bs} (head : (leaves a).Perm (leaves b))
      (tail : ArgumentCorrespondence as bs) : ArgumentCorrespondence (a :: as) (b :: bs)

theorem opaque_call_congruence (environment : Slot → (Fin arity → Atom) → Prop)
    (callee : List ((Fin arity → Atom) → Prop) → Result)
    (original comparison : List (Argument Slot))
    (argumentProofs : ArgumentCorrespondence original comparison) :
    callee (original.map (relation environment)) = callee (comparison.map (relation environment)) := by
  congr 1
  induction argumentProofs with
  | nil => rfl
  | cons proof _ ih => simp only [List.map_cons, permuted_union_sound environment _ _ proof, ih]

end Calls

end Category72
