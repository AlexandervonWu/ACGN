import PaidDeclarationAlignment
import DistanceDerivedTrace

/- Eligibility for unchanged retained owners, not an exchange or hoisting law.
   A paid declaration replacement may change its carrier. Its dependent read
   must use the new typed endpoint; it is not equality of differently typed
   values. Authentic Java source/payment association is a separate obligation. -/
namespace RetainedOwnerAdmission

universe u

inductive Kind where
  | all | some | one | lone | comprehension
  deriving DecidableEq

structure Owner where
  identity : Nat
  parent : Option Nat
  phase : Nat
  kind : Kind
  declaration : Nat
  domainOccurrence : Nat
  domainType : String
  orderedVariables : List Nat
  orderedTypes : List String
  dependencies : List Nat
  deriving DecidableEq

def oldKindGate (owners : List Owner) : Bool :=
  owners.length <= 1 || owners.all (fun o => o.kind == .all || o.kind == .some)

def checkedPlan (original current : List Owner) : Bool :=
  decide (original = current ∧ (original.map Owner.identity).Nodup)

def context {E : Type u} (semantics : Owner → (E → Prop) → E → Prop)
    (owners : List Owner) (body : E → Prop) : E → Prop :=
  owners.foldr semantics body

theorem checked_context_preserved {E : Type u} (original current : List Owner)
    (checked : checkedPlan original current = true)
    (semantics : Owner → (E → Prop) → E → Prop) (body : E → Prop) (env : E) :
    context semantics original body env ↔ context semantics current body env := by
  have frames : original = current ∧ (original.map Owner.identity).Nodup :=
    of_decide_eq_true checked
  rw [frames.1]

theorem altered_owner_rejected (original current : List Owner)
    (different : original ≠ current) : checkedPlan original current = false := by
  simp [checkedPlan, different]

inductive Coordinate where
  | outer : Nat → Coordinate
  | local : Nat → Nat → Coordinate
  deriving DecidableEq

def route (paid : Nat → Option Nat) : Coordinate → Option Coordinate
  | .outer n => (paid n).map Coordinate.outer
  | .local owner slot => some (.local owner slot)

theorem local_owners_not_paid (paid : Nat → Option Nat) (owner slot : Nat) :
    route paid (.local owner slot) = some (.local owner slot) := rfl

theorem local_never_captured (paid : Nat → Option Nat) (owner slot target : Nat) :
    route paid (.local owner slot) ≠ some (.outer target) := by simp [route]

/- This is a charged endpoint substitution, not a semantic equivalence of the
   source and target predicates. The exact selected declaration atoms and
   their typed read endpoints must already be authenticated by the producer. -/
structure Binding where
  atom : PaidDeclarationAlignment.Atom
  owner : String
  phase : Nat
  role : String
  carrier : String
  domain : String
  dependencies : List Nat
  deriving DecidableEq

structure ReadOccurrence where
  binding : Binding
  sourceOccurrence : Nat
  branch : List Nat
  observedCarrier : String
  deriving DecidableEq

def licensedReplacement (before after : Binding) (actual target : ReadOccurrence) : Bool :=
  match PaidDeclarationAlignment.replay [before.atom] [.pair before.atom after.atom] with
  | none => false
  | some (output, cost, links) => decide (
      output = [after.atom] ∧ cost = 1 ∧
      links = [(before.atom.occurrence, after.atom.occurrence)] ∧
      actual.binding = before ∧ target.binding = after ∧
      actual.observedCarrier = before.carrier ∧ target.observedCarrier = after.carrier)

theorem paid_typed_endpoints (before after : Binding) (actual target : ReadOccurrence)
    (checked : licensedReplacement before after actual target = true) :
    PaidDeclarationAlignment.replay [before.atom] [.pair before.atom after.atom] =
      some ([after.atom],1,[(before.atom.occurrence,after.atom.occurrence)]) ∧
    actual.binding = before ∧ target.binding = after ∧
    actual.observedCarrier = before.carrier ∧ target.observedCarrier = after.carrier := by
  cases h : PaidDeclarationAlignment.replay [before.atom] [.pair before.atom after.atom] with
  | none => simp [licensedReplacement,h] at checked
  | some result =>
    rcases result with ⟨output,cost,links⟩
    have facts : output = [after.atom] ∧ cost = 1 ∧
        links = [(before.atom.occurrence,after.atom.occurrence)] ∧
        actual.binding = before ∧ target.binding = after ∧
        actual.observedCarrier = before.carrier ∧ target.observedCarrier = after.carrier := by
      simpa only [licensedReplacement,h,decide_eq_true_eq] using checked
    exact ⟨by simp [facts.1,facts.2.1,facts.2.2.1],facts.2.2.2⟩

theorem changed_declaration_licenses_exact_endpoints (before after : Binding)
    (changed : before.atom.tuple ≠ after.atom.tuple) (a b : Nat) (p q : List Nat) :
    licensedReplacement before after ⟨before,a,p,before.carrier⟩
      ⟨after,b,q,after.carrier⟩ = true := by
  simp [licensedReplacement,PaidDeclarationAlignment.replay,changed]

/- The selected leaf transfer consumes the exact old typed payload and emits
   the new one. It does not cast an Event value into a State value. -/
theorem licensed_transfer_emits_target (before after : Binding)
    (actual target : ReadOccurrence)
    (checked : licensedReplacement before after actual target = true)
    (source output : DistanceDerivedTrace.Store Nat ReadOccurrence)
    (a b : Nat) (present : source a = some actual) (fresh : output b = none) :
    (DistanceDerivedTrace.transfer source output a b actual target).map
      (fun next => next.2 b) = some (some target) ∧
    target.observedCarrier = after.carrier := by
  exact ⟨DistanceDerivedTrace.transfer_produces source output a b actual target ⟨present,fresh⟩,
    (paid_typed_endpoints before after actual target checked).2.2.2.2⟩

def naturalOwners : List Owner :=
  [⟨594,none,0,.comprehension,595,597,"RELATION[5:State]",[598,599],
      ["RELATION[5:State]","RELATION[5:State]"],[]⟩,
   ⟨596,some 594,0,.some,600,603,"RELATION[5:Event]",[604],["RELATION[5:Event]"],[]⟩]

theorem natural_old_rejection : oldKindGate naturalOwners = false := by decide
theorem natural_checked_plan : checkedPlan naturalOwners naturalOwners = true := by
  simp [checkedPlan,naturalOwners]

/- Exact local relation in the natural source: the two comprehension columns
   are retained, followed by the existential Event binder. Outer variables
   are absent from this relation. This is not inv4 = inv4c. -/
def naturalRelation (states : S → Prop) (events : E → Prop)
    (trans : S → E → S → Prop) (x y : S) : Prop :=
  states x ∧ states y ∧ ∃ e, events e ∧ trans x e y

theorem natural_outer_replacement_no_capture (states : S → Prop) (events : E → Prop)
    (trans : S → E → S → Prop) (oldOuter : A) (newOuter : B) :
    (fun (_ : A) => naturalRelation states events trans) oldOuter =
      (fun (_ : B) => naturalRelation states events trans) newOuter := rfl

def beforeBinding : Binding := ⟨⟨1,0⟩,"root/predicate[0]/decl[1]@pos",0,"matrix",
  "Rel(AlloySig:Event)","Event",[]⟩
def afterBinding : Binding := ⟨⟨0,1⟩,"root/predicate[0]/decl[0]@pos",0,"matrix",
  "Rel(AlloySig:State)","State",[]⟩
def beforeRead : ReadOccurrence := ⟨beforeBinding,644405,[0,1,0],beforeBinding.carrier⟩
def afterRead : ReadOccurrence := ⟨afterBinding,644832,[0,0,0],afterBinding.carrier⟩

theorem natural_paid_forward : licensedReplacement beforeBinding afterBinding beforeRead afterRead = true := by decide
theorem natural_paid_reverse : licensedReplacement afterBinding beforeBinding afterRead beforeRead = true := by decide
theorem distinct_carriers_not_alpha : beforeBinding.carrier ≠ afterBinding.carrier := by decide
theorem wrong_read_type_rejected :
    licensedReplacement beforeBinding afterBinding beforeRead {afterRead with observedCarrier := beforeBinding.carrier} = false := by decide
theorem wrong_binding_owner_rejected :
    licensedReplacement beforeBinding afterBinding {beforeRead with binding := {beforeBinding with owner := "foreign"}} afterRead = false := by decide
theorem unpaid_declaration_rejected :
    licensedReplacement beforeBinding beforeBinding beforeRead beforeRead = false := by decide
theorem missing_local_owner_rejected : checkedPlan naturalOwners naturalOwners.tail = false := by decide
theorem duplicate_owner_rejected : checkedPlan (naturalOwners ++ naturalOwners) (naturalOwners ++ naturalOwners) = false := by
  simp [checkedPlan,naturalOwners]

def heldoutOwners : List Owner :=
  [⟨7,none,2,.one,9,11,"T",[13],["T"],[4,6,4]⟩,
   ⟨17,some 7,2,.lone,19,23,"U",[29],["U"],[]⟩]
theorem heldout_old_rejection : oldKindGate heldoutOwners = false := by decide
theorem heldout_checked_plan : checkedPlan heldoutOwners heldoutOwners = true := by
  simp [checkedPlan,heldoutOwners]

#print axioms checked_context_preserved
#print axioms paid_typed_endpoints
#print axioms licensed_transfer_emits_target
#print axioms natural_outer_replacement_no_capture
end RetainedOwnerAdmission
