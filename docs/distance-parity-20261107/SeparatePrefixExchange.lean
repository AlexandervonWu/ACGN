import Std

/- Distinct source declaration occurrences need not be one grouped declaration.
   A homogeneous independent prefix may exchange them, but spelling/type names
   alone never replace a source-linked permutation certificate. -/
namespace SeparatePrefixExchange

theorem independent_all_exchange {A B : Type} (d : A → Prop) (e : B → Prop)
    (p : A → B → Prop) :
    (∀ x, d x → ∀ y, e y → p x y) ↔ ∀ y, e y → ∀ x, d x → p x y := by
  constructor <;> intro h x hx y hy <;> exact h y hy x hx

theorem independent_some_exchange {A B : Type} (d : A → Prop) (e : B → Prop)
    (p : A → B → Prop) :
    (∃ x, d x ∧ ∃ y, e y ∧ p x y) ↔ ∃ y, e y ∧ ∃ x, d x ∧ p x y := by
  constructor
  · rintro ⟨x,hx,y,hy,hp⟩; exact ⟨y,hy,x,hx,hp⟩
  · rintro ⟨y,hy,x,hx,hp⟩; exact ⟨x,hx,y,hy,hp⟩

structure Declaration where
  sourceOccurrence : Nat
  parserAuthority : Nat
  domainAuthority : Nat
  typeAuthority : Nat
  payload : Nat
  deriving DecidableEq

def admit (a b : Declaration) (sourceCertificate sameBlock : Prop) : Prop :=
  sourceCertificate ∧ sameBlock ∧ a.parserAuthority = b.parserAuthority ∧
  a.domainAuthority = b.domainAuthority ∧ a.typeAuthority = b.typeAuthority ∧ a.payload = b.payload

theorem separate_occurrences_allowed (a b : Declaration) (cert block : Prop)
    (_distinct : a.sourceOccurrence ≠ b.sourceOccurrence)
    (hc : cert) (hb : block) (hp : a.parserAuthority = b.parserAuthority)
    (hd : a.domainAuthority = b.domainAuthority) (ht : a.typeAuthority = b.typeAuthority)
    (hpay : a.payload = b.payload) : admit a b cert block :=
  ⟨hc,hb,hp,hd,ht,hpay⟩

theorem missing_certificate_rejected (a b : Declaration) (cert block : Prop)
    (h : ¬ cert) : ¬ admit a b cert block := fun ha => h ha.1

theorem intervening_barrier_rejected (a b : Declaration) (cert block : Prop)
    (h : ¬ block) : ¬ admit a b cert block := fun ha => h ha.2.1

theorem different_domain_rejected (a b : Declaration) (cert block : Prop)
    (h : a.domainAuthority ≠ b.domainAuthority) : ¬ admit a b cert block :=
  fun ha => h ha.2.2.2.1

def exchanged (a b : Declaration) := (b,a)

theorem occurrence_identity_not_rewritten (a b : Declaration) :
    (exchanged a b).1 = b ∧ (exchanged a b).2 = a := ⟨rfl,rfl⟩

theorem admitted_update_charge_retained (a b : Declaration) (cert block : Prop)
    (h : admit a b cert block) (target : Nat) :
    (if a.payload = target then 0 else 1 : Nat) = (if b.payload = target then 0 else 1) := by
  rw [h.2.2.2.2.2]

#print axioms independent_all_exchange
#print axioms independent_some_exchange
#print axioms separate_occurrences_allowed
#print axioms missing_certificate_rejected
#print axioms intervening_barrier_rejected
#print axioms different_domain_rejected
#print axioms occurrence_identity_not_rewritten
#print axioms admitted_update_charge_retained
end SeparatePrefixExchange
