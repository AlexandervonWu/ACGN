import Phase5SourceRules
import PaidSlotDomainIntegration
import RetainedDifferenceDomain

/- R0-REL-024 already establishes structural lattice absorption. This module
   transports that result through a retained, source-issued declaration guard.
   It does not erase a guard, change a payment, or move its evaluation phase. -/
namespace NormalizedDeclarationDomain

inductive Derivation {A : Type} : Rel A → Rel A → Prop
  | refl (domain : Rel A) : Derivation domain domain
  | intersect (smaller larger : Rel A) (contained : subset smaller larger) :
      Derivation (intersection smaller larger) smaller
  | union (smaller larger : Rel A) (contained : subset smaller larger) :
      Derivation (union smaller larger) larger
  | intersectLeft {before after : Rel A} (other : Rel A)
      (step : Derivation before after) :
      Derivation (intersection before other) (intersection after other)
  | unionLeft {before after : Rel A} (other : Rel A)
      (step : Derivation before after) :
      Derivation (union before other) (union after other)
  | commuteIntersect (left right : Rel A) :
      Derivation (intersection left right) (intersection right left)
  | commuteUnion (left right : Rel A) :
      Derivation (union left right) (union right left)
  | associateIntersect (left middle right : Rel A) :
      Derivation (intersection (intersection left middle) right)
        (intersection left (intersection middle right))
  | associateUnion (left middle right : Rel A) :
      Derivation (union (union left middle) right) (union left (union middle right))
  | trans {before middle after : Rel A} (first : Derivation before middle)
      (second : Derivation middle after) : Derivation before after

theorem derivation_sound {A : Type} {before after : Rel A}
    (steps : Derivation before after) : before = after := by
  induction steps with
  | refl => rfl
  | intersect smaller larger contained => exact subset_intersection_absorption smaller larger contained
  | union smaller larger contained => exact subset_union_absorption smaller larger contained
  | intersectLeft other _ ih => rw [ih]
  | unionLeft other _ ih => rw [ih]
  | commuteIntersect left right => funext x; simp [intersection, and_comm]
  | commuteUnion left right => funext x; simp [union, or_comm]
  | associateIntersect left middle right => funext x; simp [intersection, and_assoc]
  | associateUnion left middle right => funext x; simp [union, or_assoc]
  | trans _ _ first second => exact first.trans second

theorem guard_in_same_context {A : Type} {before after : Rel A}
    (steps : Derivation before after) (negative : Bool)
    (context : PaidSlotGuardAuthentication.Context) (value : A) :
    context.eval (if negative then ¬ before value else before value) ↔
      context.eval (if negative then ¬ after value else after value) := by
  rw [derivation_sound steps]

theorem declaration_same_owner {A : Type} (kind : RetainedDifferenceDomain.Kind)
    {before after : Rel A} (steps : Derivation before after) (body : A → Prop) :
    RetainedDifferenceDomain.quantify kind before body ↔
      RetainedDifferenceDomain.quantify kind after body := by
  rw [derivation_sound steps]

abbrev Occurrence := PaidSlotGuardAuthentication.Occurrence

/- `normalized` is issued privately by the existing typed R0-REL-024 check,
   not supplied by a receipt. Every other field is still compared exactly. -/
def accepts (issued actual : Occurrence) (normalized : String) : Bool :=
  decide (actual = issued ∨ actual = { issued with domain := normalized })

theorem accepted_metadata (issued actual : Occurrence) (normalized : String)
    (h : accepts issued actual normalized = true) :
    actual.issuer = issued.issuer ∧ actual.owner = issued.owner ∧
    actual.binding = issued.binding ∧ actual.exactType = issued.exactType ∧
    actual.dependencies = issued.dependencies ∧ actual.negative = issued.negative ∧
    actual.context = issued.context ∧
    (actual.domain = issued.domain ∨ actual.domain = normalized) := by
  simp only [accepts, decide_eq_true_eq] at h
  rcases h with h | h <;> subst actual <;> simp

theorem old_path_retained (issued : Occurrence) (normalized : String) :
    accepts issued issued normalized = true := by simp [accepts]

theorem normalized_path_retained (issued : Occurrence) (normalized : String) :
    accepts issued {issued with domain := normalized} normalized = true := by simp [accepts]

theorem changed_field_rejected (issued actual : Occurrence) (normalized : String)
    (field : Occurrence → T)
    (unchanged : field {issued with domain := normalized} = field issued)
    (different : field actual ≠ field issued) : accepts issued actual normalized = false := by
  simp only [accepts, decide_eq_false_iff_not]
  intro admitted
  rcases admitted with original | changed
  · exact different (congrArg field original)
  · exact different ((congrArg field changed).trans unchanged)

theorem other_domain_rejected (issued : Occurrence) (normalized other : String)
    (raw : other ≠ issued.domain) (changed : other ≠ normalized) :
    accepts issued {issued with domain := other} normalized = false := by
  simp only [accepts, decide_eq_false_iff_not, not_or]
  constructor <;> intro same
  · exact raw (congrArg PaidSlotGuardAuthentication.Occurrence.domain same)
  · exact changed (congrArg PaidSlotGuardAuthentication.Occurrence.domain same)

/- Source declarations `var sig Trash in File` mean containment at EACH time.
   This includes empty domains and arbitrary environments and future bodies. -/
def declaredSubset {A : Type} (file trash : Env → Nat → A → Prop)
    (env : Env) (time : Nat) : Rel A := fun value => file env time value ∧ trash env time value

theorem dynamic_source_derivation {A : Type} (file trash : Env → Nat → A → Prop)
    (env : Env) (time : Nat) :
    Derivation (intersection (file env time) (declaredSubset file trash env time))
      (declaredSubset file trash env time) := by
  apply Derivation.trans (Derivation.commuteIntersect _ _)
  exact Derivation.intersect _ _ (fun _ member => member.1)

theorem all_times_source_guard {A : Type} (file trash : Env → Nat → A → Prop)
    (env : Env) (body : Nat → A → Prop) (now : Nat) :
    (∀ time, now ≤ time → ∀ value,
      ¬ intersection (file env time) (declaredSubset file trash env time) value ∨ body time value) ↔
    (∀ time, now ≤ time → ∀ value,
      ¬ declaredSubset file trash env time value ∨ body time value) := by
  constructor <;> intro h time later value
  · have equal := derivation_sound (dynamic_source_derivation file trash env time)
    simpa only [equal] using h time later value
  · have equal := derivation_sound (dynamic_source_derivation file trash env time)
    simpa only [equal] using h time later value

theorem no_unproved_absorption :
    ¬ Derivation (intersection (fun _ : Unit => False) (fun _ => True)) (fun _ => True) := by
  intro step
  have bad := congrFun (derivation_sound step) ()
  simp [intersection] at bad

#print axioms derivation_sound
#print axioms guard_in_same_context
#print axioms declaration_same_owner
#print axioms accepted_metadata
#print axioms all_times_source_guard
end NormalizedDeclarationDomain
