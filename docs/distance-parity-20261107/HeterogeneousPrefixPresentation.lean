import DeclarationReplay
import SeparatePrefixExchange

namespace HeterogeneousPrefixPresentation

/- Presentation exchange retains each typed binder, unlike an automorphism
   that exchanges values in fixed typed slots. -/
structure Binder where
  occurrence : String
  carrier : String
  domain : String
  phase : Nat
  owner : String
  quantifier : String
  multiplicity : String
  dependencies : List Nat
  disjoint : Nat
  deriving DecidableEq

def independent (a b : Binder) : Bool :=
  a.phase == b.phase && a.owner == b.owner && a.quantifier == b.quantifier &&
  (a.quantifier == "ALL" || a.quantifier == "SOME") &&
  a.multiplicity == "ONE" && b.multiplicity == "ONE" &&
  a.dependencies.isEmpty && b.dependencies.isEmpty && a.disjoint == 0 && b.disjoint == 0

def classBinder : Binder :=
  { occurrence := "root/predicate[0]/decl[0]@pos", carrier := "AlloyCarrier(Class)",
    domain := "19:alloy-binder-domain[1:5:Class]{0:}", phase := 0, owner := "",
    quantifier := "ALL", multiplicity := "ONE", dependencies := [], disjoint := 0 }

def personBinder : Binder :=
  { occurrence := "root/predicate[0]/decl[1]@pos", carrier := "AlloyCarrier(Person)",
    domain := "19:alloy-binder-domain[1:6:Person]{0:}", phase := 0, owner := "",
    quantifier := "ALL", multiplicity := "ONE", dependencies := [], disjoint := 0 }

-- Necessary conjunct of the exact old same-payload orbit gate, not its entirety.
def oldSameCarrierGate (a b : Binder) : Bool := a.carrier == b.carrier

theorem old_gate_rejects_actual_target : oldSameCarrierGate classBinder personBinder = false := by decide
theorem target_independent : independent classBinder personBinder = true := by decide
theorem mixed_quantifier_rejected :
    independent classBinder { personBinder with quantifier := "SOME" } = false := by decide
theorem dependent_rejected :
    independent classBinder { personBinder with dependencies := [0] } = false := by decide
theorem foreign_phase_rejected :
    independent classBinder { personBinder with phase := 1 } = false := by decide
theorem foreign_owner_rejected :
    independent classBinder { personBinder with owner := "foreign" } = false := by decide

theorem typed_all_presentation {A B : Type} (d : A → Prop) (e : B → Prop)
    (body : A → B → Prop) :
    (∀ a, d a → ∀ b, e b → body a b) ↔ ∀ b, e b → ∀ a, d a → body a b :=
  SeparatePrefixExchange.independent_all_exchange d e body

theorem typed_some_presentation {A B : Type} (d : A → Prop) (e : B → Prop)
    (body : A → B → Prop) :
    (∃ a, d a ∧ ∃ b, e b ∧ body a b) ↔ ∃ b, e b ∧ ∃ a, d a ∧ body a b :=
  SeparatePrefixExchange.independent_some_exchange d e body

/- Exact inv14c body over arbitrary carrier interpretations; no nonemptiness
   or disputed semantic equivalence is assumed. The domains do not depend on
   the other binder. Both variables retain their original carrier and use. -/
theorem z4_target_presentation {Class Person Group : Type}
    (Groups : Class → Person → Group → Prop)
    (Teaches : Person → Class → Prop) (Tutors : Person → Person → Prop) :
    (∀ c p, (∃ g, Groups c p g) → ∀ t, Teaches t c → Tutors t p) ↔
    (∀ p c, (∃ g, Groups c p g) → ∀ t, Teaches t c → Tutors t p) := by
  constructor <;> intro h x y <;> exact h y x

-- Tuple codes are injective over this concrete six-atom source/target suite:
-- ALL Person ONE 0 = 0, SOME Class ONE 0 = 1,
-- ALL Group ONE 0 = 2, ALL Class ONE 0 = 3.
def s : DeclarationReplay.Atom := ⟨0, 0⟩
def c : DeclarationReplay.Atom := ⟨1, 1⟩
def g : DeclarationReplay.Atom := ⟨2, 2⟩
def t : DeclarationReplay.Atom := ⟨3, 0⟩
def targetC : DeclarationReplay.Atom := ⟨4, 3⟩
def targetP : DeclarationReplay.Atom := ⟨5, 0⟩

def forward : List DeclarationReplay.Edit :=
  [.pair s targetP, .pair c targetC, .delete g, .delete t]
def reverse : List DeclarationReplay.Edit :=
  [.pair targetP s, .pair targetC c, .insert g, .insert t]

theorem actual_forward_declarations :
    DeclarationReplay.replay [s,c,g,t] forward = some ([targetP,targetC],3) := by decide
theorem actual_reverse_declarations :
    DeclarationReplay.replay [targetP,targetC] reverse = some ([s,c,g,t],3) := by decide
theorem same_tuple_foreign_occurrence_rejected :
    DeclarationReplay.replay [t,c,g,s] forward = none := by decide
theorem wrong_paid_target_rejected :
    DeclarationReplay.replay [s,c,g,t] [.pair s targetP,.pair t targetC,.delete g,.delete t] = none := by decide
theorem presentation_retains_typed_binders :
    ([personBinder,classBinder] : List Binder).Perm [classBinder,personBinder] := by
  exact List.Perm.swap _ _ []

#print axioms old_gate_rejects_actual_target
#print axioms target_independent
#print axioms mixed_quantifier_rejected
#print axioms dependent_rejected
#print axioms foreign_phase_rejected
#print axioms foreign_owner_rejected
#print axioms typed_all_presentation
#print axioms typed_some_presentation
#print axioms z4_target_presentation
#print axioms actual_forward_declarations
#print axioms actual_reverse_declarations
#print axioms same_tuple_foreign_occurrence_rejected
#print axioms wrong_paid_target_rejected
#print axioms presentation_retains_typed_binders
end HeterogeneousPrefixPresentation
