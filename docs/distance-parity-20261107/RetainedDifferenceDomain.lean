import Std

/- Model contract for eligibility, not a Java extraction or an edit equivalence.
   A retained local domain is evaluated in the OUTER environment before its
   owner is introduced. Paid outer edits do not hoist or erase this domain. -/
namespace RetainedDifferenceDomain

inductive Slot where
  | outer : Nat → Slot
  | local : Nat → Nat → Slot
  deriving DecidableEq

def difference {A : Type} (carrier : A → Prop) (env : Nat → A → Prop)
    (dependency : Nat) (x : A) : Prop := carrier x ∧ ¬ env dependency x

theorem domain_transport {A : Type} (carrier : A → Prop)
    (old new : Nat → A → Prop) (a b : Nat)
    (link : ∀ x, old a x ↔ new b x) :
    ∀ x, difference carrier old a x ↔ difference carrier new b x := by
  intro x
  simp only [difference, link x]

inductive Kind where | all | some | one | lone

def quantify {A : Type} : Kind → (A → Prop) → (A → Prop) → Prop
  | .all, d, p => ∀ x, d x → p x
  | .some, d, p => ∃ x, d x ∧ p x
  | .one, d, p => ∃ x, (d x ∧ p x) ∧ ∀ y, d y ∧ p y → y = x
  | .lone, d, p => ∀ x y, d x ∧ p x → d y ∧ p y → x = y

theorem retained_domain_congruence {A : Type} (kind : Kind)
    (d e p q : A → Prop) (domain : ∀ x, d x ↔ e x)
    (body : ∀ x, p x ↔ q x) : quantify kind d p ↔ quantify kind e q := by
  have de : d = e := funext fun x => propext (domain x)
  have pq : p = q := funext fun x => propext (body x)
  rw [de, pq]

def enter {A : Type} (env : Slot → A) (owner slot : Nat) (value : A) : Slot → A
  | .outer n => env (.outer n)
  | .local o s => if o = owner ∧ s = slot then value else env (.local o s)

theorem no_capture {A : Type} (env : Slot → A) (owner slot dependency : Nat)
    (value : A) : enter env owner slot value (.outer dependency) = env (.outer dependency) := rfl

theorem foreign_owner_preserved {A : Type} (env : Slot → A) (owner other slot : Nat)
    (value : A) (h : other ≠ owner) :
    enter env owner slot value (.local other slot) = env (.local other slot) := by
  simp [enter, h]

theorem empty_difference_no_one {A : Type} (carrier : A → Prop)
    (env : Nat → A → Prop) (dependency : Nat) (body : A → Prop)
    (covers : ∀ x, carrier x → env dependency x) :
    ¬ quantify .one (difference carrier env dependency) body := by
  rintro ⟨x, ⟨⟨cx, nx⟩, _⟩, _⟩
  exact nx (covers x cx)

#print axioms domain_transport
#print axioms retained_domain_congruence
#print axioms no_capture
#print axioms foreign_owner_preserved
#print axioms empty_difference_no_one
end RetainedDifferenceDomain
