import Std

/- A paid outer correspondence may be evaluated beneath an unchanged ordered
   ALL/SOME chain. This is not exchange/hoisting, equality of edited endpoints,
   or a proof of the Java checker. Domain, kind, ancestry and type are premises. -/
namespace MixedRetainedAdmission

inductive Kind where
  | all | some
  deriving DecidableEq

abbrev Domain (A : Type) := List A → A → Prop

def retained {A : Type} : List (Kind × Domain A) → List A → (List A → Prop) → Prop
  | [], env, body => body env
  | (.all, domain) :: rest, env, body => ∀ x, domain env x → retained rest (x :: env) body
  | (.some, domain) :: rest, env, body => ∃ x, domain env x ∧ retained rest (x :: env) body

theorem ordered_congruence {A : Type} (chain : List (Kind × Domain A))
    (p q : List A → Prop) (same : ∀ env, p env ↔ q env) (env : List A) :
    retained chain env p ↔ retained chain env q := by
  induction chain generalizing env with
  | nil => exact same env
  | cons frame rest ih =>
    rcases frame with ⟨kind, domain⟩
    cases kind with
    | all =>
      constructor
      · intro h x hx; exact (ih (x :: env)).mp (h x hx)
      · intro h x hx; exact (ih (x :: env)).mpr (h x hx)
    | some =>
      constructor
      · rintro ⟨x, hx, hp⟩; exact ⟨x, hx, (ih (x :: env)).mp hp⟩
      · rintro ⟨x, hx, hq⟩; exact ⟨x, hx, (ih (x :: env)).mpr hq⟩

theorem empty_all {A : Type} (rest : List (Kind × Domain A))
    (env : List A) (body : List A → Prop) :
    retained ((.all, fun _ _ => False) :: rest) env body := by simp [retained]

theorem empty_some {A : Type} (rest : List (Kind × Domain A))
    (env : List A) (body : List A → Prop) :
    ¬ retained ((.some, fun _ _ => False) :: rest) env body := by simp [retained]

theorem mixed_order_not_exchangeable :
    (∀ x : Bool, ∃ y : Bool, x = y) ∧ ¬ (∃ y : Bool, ∀ x : Bool, x = y) := by
  constructor
  · intro x; exact ⟨x, rfl⟩
  · rintro ⟨y, h⟩
    have bad : false = true := (h false).trans (h true).symm
    cases bad

structure Frame where
  kind : Kind
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

def admit (original current : List Frame) (paid : Nat → Option Nat) :
    Coordinate → Option Coordinate
  | .outer x => if original = current then (paid x).map Coordinate.outer else none
  | .local owners slot => if original = current then some (.local owners slot) else none

theorem retained_owner_order (frames : List Frame) (paid : Nat → Option Nat) (slot : Nat) :
    admit frames frames paid (.local frames slot) = some (.local frames slot) := by simp [admit]

theorem changed_frame_rejected (original current : List Frame) (different : original ≠ current)
    (paid : Nat → Option Nat) (x : Coordinate) : admit original current paid x = none := by
  cases x <;> simp [admit, different]

theorem paid_outer_required (frames : List Frame) (paid : Nat → Option Nat) (x y : Nat)
    (h : admit frames frames paid (.outer x) = some (.outer y)) : paid x = some y := by
  cases hm : paid x with
  | none => simp [admit, hm] at h
  | some z => simpa [admit, hm] using h

theorem no_local_capture (original current frames : List Frame) (paid : Nat → Option Nat)
    (slot target : Nat) : admit original current paid (.local frames slot) ≠ some (.outer target) := by
  by_cases h : original = current <;> simp [admit, h]

#print axioms ordered_congruence
#print axioms empty_all
#print axioms empty_some
#print axioms mixed_order_not_exchangeable
#print axioms retained_owner_order
#print axioms changed_frame_rejected
#print axioms paid_outer_required
#print axioms no_local_capture
end MixedRetainedAdmission
