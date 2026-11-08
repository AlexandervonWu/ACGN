import Std

/- A paid outer path is an edit correspondence, not an equality of endpoints.
   Local quantifiers retain their domain and ordered owner stack. This contract
   models admission; it does not extract Java or certify the public wire plan. -/
namespace ScopedPaidAdmission

inductive Kind where
  | all | some | one | lone
  deriving DecidableEq

def atMostOne {A : Type} (p : A → Prop) : Prop := ∀ x y, p x → p y → x = y

def quantify {A : Type} (k : Kind) (d p : A → Prop) : Prop :=
  match k with
  | .all => ∀ x, d x → p x
  | .some => ∃ x, d x ∧ p x
  | .one => (∃ x, d x ∧ p x) ∧ atMostOne (fun x => d x ∧ p x)
  | .lone => atMostOne (fun x => d x ∧ p x)

theorem retained_quantifier_congruence {A : Type} (k : Kind) (d p q : A → Prop)
    (h : ∀ x, p x ↔ q x) : quantify k d p ↔ quantify k d q := by
  have he : (∃ x, d x ∧ p x) ↔ (∃ x, d x ∧ q x) := by
    constructor
    · rintro ⟨x, hd, hp⟩; exact ⟨x, hd, (h x).mp hp⟩
    · rintro ⟨x, hd, hq⟩; exact ⟨x, hd, (h x).mpr hq⟩
  have hl : atMostOne (fun x => d x ∧ p x) ↔ atMostOne (fun x => d x ∧ q x) := by
    constructor
    · intro hp x y hx hy; exact hp x y ⟨hx.1, (h x).mpr hx.2⟩ ⟨hy.1, (h y).mpr hy.2⟩
    · intro hq x y hx hy; exact hq x y ⟨hx.1, (h x).mp hx.2⟩ ⟨hy.1, (h y).mp hy.2⟩
  cases k with
  | all =>
    constructor
    · intro hp x hd; exact (h x).mp (hp x hd)
    · intro hq x hd; exact (h x).mpr (hq x hd)
  | some => exact he
  | one => exact and_congr he hl
  | lone => exact hl

structure Frame where
  owner : Nat
  declaration : Nat
  variableOccurrence : Nat
  domainOccurrence : Nat
  domainIdentity : Nat
  parserTypeAuthority : Nat
  kind : Kind
  deriving DecidableEq

inductive Coordinate where
  | outer : Nat → Coordinate
  | local : List Frame → Nat → Coordinate
  deriving DecidableEq

def link (paid : Nat → Option Nat) : Coordinate → Option Coordinate
  | .outer x => (paid x).map Coordinate.outer
  | .local owners slot => some (.local owners slot)

theorem local_domain_type_order_unchanged (paid : Nat → Option Nat)
    (owners : List Frame) (slot : Nat) :
    link paid (.local owners slot) = some (.local owners slot) := rfl

def admit (source current : List Frame) (paid : Nat → Option Nat) (x : Coordinate) :=
  if source = current then link paid x else none

theorem substituted_scope_rejected (source current : List Frame)
    (h : source ≠ current) (paid : Nat → Option Nat) (x : Coordinate) :
    admit source current paid x = none := by simp [admit, h]

theorem outer_link_requires_paid_path (source current : List Frame)
    (paid : Nat → Option Nat) (x y : Nat)
    (h : admit source current paid (.outer x) = some (.outer y)) :
    source = current ∧ paid x = some y := by
  by_cases hs : source = current
  · refine ⟨hs, ?_⟩
    cases hp : paid x with
    | none => simp [admit, hs, link, hp] at h
    | some z => simpa [admit, hs, link, hp] using h
  · simp [admit, hs] at h

theorem no_local_capture (source current : List Frame) (paid : Nat → Option Nat)
    (owners : List Frame) (slot target : Nat) :
    admit source current paid (.local owners slot) ≠ some (.outer target) := by
  by_cases h : source = current <;> simp [admit, link, h]

-- Congruence above needs no inhabited-domain premise and licenses no hoist.
theorem empty_domain_distinguishes_kind :
    quantify Kind.lone (fun _ : Unit => False) (fun _ => True) ∧
    ¬ quantify Kind.one (fun _ : Unit => False) (fun _ => True) := by
  simp [quantify, atMostOne]

#print axioms retained_quantifier_congruence
#print axioms local_domain_type_order_unchanged
#print axioms substituted_scope_rejected
#print axioms outer_link_requires_paid_path
#print axioms no_local_capture
#print axioms empty_domain_distinguishes_kind
end ScopedPaidAdmission
