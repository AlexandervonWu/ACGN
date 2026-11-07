import Std

/- An ambient-dependent declaration domain is a semantic argument, not a
   generated-name annotation. This model justifies congruence only when BOTH
   the actual domain argument and body are preserved. It is not a proof of the
   Java source bridge, certificate decoder, or unrestricted Alloy semantics. -/
namespace LocalDomainOperand

inductive Domain where
  | variable : Nat → Domain
  | global : Nat → Domain
  | minus : Domain → Domain → Domain

def meaning (env globals : Nat → α → Prop) : Domain → α → Prop
  | .variable n => env n
  | .global n => globals n
  | .minus a b => fun x => meaning env globals a x ∧ ¬ meaning env globals b x

def rename (f : Nat → Nat) : Domain → Domain
  | .variable n => .variable (f n)
  | .global n => .global n
  | .minus a b => .minus (rename f a) (rename f b)

theorem transport_domain (env globals : Nat → α → Prop) (f : Nat → Nat)
    (d : Domain) : meaning env globals (rename f d) = meaning (env ∘ f) globals d := by
  induction d with
  | «variable» => rfl
  | «global» => rfl
  | minus a b ha hb => simp [rename, meaning, ha, hb]

def oneIn (domain body : α → Prop) : Prop :=
  ∃ x, domain x ∧ body x ∧ ∀ y, domain y ∧ body y → y = x

theorem binder_congruence (d e p q : α → Prop)
    (domainEq : ∀ x, d x ↔ e x) (bodyEq : ∀ x, p x ↔ q x) :
    oneIn d p ↔ oneIn e q := by
  have hd : d = e := funext fun x => propext (domainEq x)
  have hp : p = q := funext fun x => propext (bodyEq x)
  rw [hd, hp]

theorem domain_cannot_be_dropped :
    oneIn (fun x : Bool => x = true) (fun _ => True) ∧
      ¬ oneIn (fun _ : Bool => False) (fun _ => True) := by
  constructor
  · exact ⟨true, rfl, trivial, fun _ h => h.1⟩
  · rintro ⟨_, h, _⟩
    exact h

theorem certified_duplicate_singleton (p q : Prop) (operandEq : p ↔ q) :
    (p ∧ q) ↔ p := by
  constructor
  · exact And.left
  · intro h
    exact ⟨h, operandEq.mp h⟩

-- Equal projected displays are deliberately not a premise of this theorem.
theorem composed_singleton (d e p q : α → Prop)
    (domainEq : ∀ x, d x ↔ e x) (bodyEq : ∀ x, p x ↔ q x) :
    (oneIn d p ∧ oneIn e q) ↔ oneIn d p :=
  certified_duplicate_singleton _ _ (binder_congruence d e p q domainEq bodyEq)

#print axioms transport_domain
#print axioms binder_congruence
#print axioms domain_cannot_be_dropped
#print axioms certified_duplicate_singleton
#print axioms composed_singleton
end LocalDomainOperand
