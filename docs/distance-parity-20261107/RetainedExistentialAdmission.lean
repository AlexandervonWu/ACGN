import Std

/- Admission of paid outer links beneath unchanged existential owners.
   This asserts no equivalence between edited endpoints and no quantifier
   hoisting. Java must check actual source frame/type/domain occurrences. -/
namespace RetainedExistentialAdmission

abbrev Domain (A : Type) := List A → A → Prop

def retained {A : Type} : List (Domain A) → List A → (List A → Prop) → Prop
  | [], env, body => body env
  | domain :: rest, env, body => ∃ x, domain env x ∧ retained rest (x :: env) body

theorem retained_congruence {A : Type} (domains : List (Domain A))
    (p q : List A → Prop) (same : ∀ env, p env ↔ q env) (env : List A) :
    retained domains env p ↔ retained domains env q := by
  induction domains generalizing env with
  | nil => exact same env
  | cons domain rest ih =>
    constructor
    · rintro ⟨x, hd, hp⟩; exact ⟨x, hd, (ih (x :: env)).mp hp⟩
    · rintro ⟨x, hd, hq⟩; exact ⟨x, hd, (ih (x :: env)).mpr hq⟩

theorem branches_congruent (p p' q q' : Prop) (hp : p ↔ p') (hq : q ↔ q') :
    (p ∧ q ↔ p' ∧ q') ∧ (p ∨ q ↔ p' ∨ q') := ⟨and_congr hp hq, or_congr hp hq⟩

theorem empty_domain_stays_empty {A : Type} (rest : List (Domain A))
    (env : List A) (body : List A → Prop) :
    ¬ retained ((fun _ _ => False) :: rest) env body := by
  simp [retained]

structure Frame where
  owner : Nat
  parent : Option Nat
  declaration : Nat
  variableOccurrence : Nat
  domainOccurrence : Nat
  domainIdentity : Nat
  parserTypeAuthority : Nat
  deriving DecidableEq

inductive Coordinate where
  | outer : Nat → Coordinate
  | local : List Frame → Nat → Coordinate
  deriving DecidableEq

def link (paid : Nat → Option Nat) : Coordinate → Option Coordinate
  | .outer x => (paid x).map Coordinate.outer
  | .local owners slot => some (.local owners slot)

def admit (original current : List Frame) (paid : Nat → Option Nat) (x : Coordinate) :=
  if original = current then link paid x else none

theorem local_ancestry_domain_type_retained (frames : List Frame)
    (paid : Nat → Option Nat) (slot : Nat) :
    admit frames frames paid (.local frames slot) = some (.local frames slot) := by
  simp [admit, link]

theorem changed_frame_rejected (original current : List Frame)
    (different : original ≠ current) (paid : Nat → Option Nat) (x : Coordinate) :
    admit original current paid x = none := by simp [admit, different]

theorem paid_outer_required (frames : List Frame) (paid : Nat → Option Nat) (x y : Nat)
    (h : admit frames frames paid (.outer x) = some (.outer y)) : paid x = some y := by
  cases hm : paid x with
  | none => simp [admit, link, hm] at h
  | some z => simpa [admit, link, hm] using h

theorem no_local_capture (original current frames : List Frame)
    (paid : Nat → Option Nat) (slot target : Nat) :
    admit original current paid (.local frames slot) ≠ some (.outer target) := by
  by_cases h : original = current <;> simp [admit, link, h]

#print axioms retained_congruence
#print axioms branches_congruent
#print axioms empty_domain_stays_empty
#print axioms local_ancestry_domain_type_retained
#print axioms changed_frame_rejected
#print axioms paid_outer_required
#print axioms no_local_capture
end RetainedExistentialAdmission
