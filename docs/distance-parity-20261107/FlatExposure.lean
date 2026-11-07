import Std

/- Contract for source-linked exposure. A normalization certificate alone is
   insufficient: its target must be linked to the exact sealed leaf by the
   insertion/find proof. Java checks those endpoints and metadata before
   replacing a leaf. This model is not a proof of the JVM or wire decoder. -/
namespace FlatExposure

inductive Term where
  | leaf : Nat → Term
  | app : Nat → List Term → Term

def meaning (leaf : Nat → V) (op : Nat → List V → V) : Term → V
  | .leaf n => leaf n
  | .app n xs => op n (go xs)
where
  go : List Term → List V
    | [] => []
    | x :: xs => meaning leaf op x :: go xs

theorem meaning_append (leaf : Nat → V) (op : Nat → List V → V)
    (xs ys : List Term) :
    meaning.go leaf op (xs ++ ys) = meaning.go leaf op xs ++ meaning.go leaf op ys := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [meaning.go, ih]

structure Frame where
  operator : Nat
  before : List Term
  after : List Term

def plug (t : Term) : List Frame → Term
  | [] => t
  | f :: fs => plug (.app f.operator (f.before ++ t :: f.after)) fs

theorem contextual_exposure (leaf : Nat → V) (op : Nat → List V → V)
    (sealed expanded : Term) (frames : List Frame)
    (linked : meaning leaf op sealed = meaning leaf op expanded) :
    meaning leaf op (plug sealed frames) = meaning leaf op (plug expanded frames) := by
  induction frames generalizing sealed expanded with
  | nil => exact linked
  | cons f fs ih =>
    apply ih
    simp only [meaning, meaning_append, meaning.go, linked]

theorem insertion_link (application node sealed : V)
    (construction : application = node) (insertion : node = sealed) :
    sealed = application := (construction.trans insertion).symm

theorem composed_normalization (source expanded target : V)
    (exposure : source = expanded) (normalization : expanded = target) :
    source = target := exposure.trans normalization

-- Context, exact result type, semantic profile, and operator are part of the
-- admission key. Equal values alone do not authorize a cross-key exposure.
structure Key where
  context : Nat
  resultType : Nat
  profile : Nat
  operator : Nat
  deriving DecidableEq

def admit (expected actual : Key) (endpointMatches : Bool) : Bool :=
  decide (expected = actual) && endpointMatches

theorem admission_exact (expected actual : Key) (endpointMatches : Bool)
    (h : admit expected actual endpointMatches = true) :
    expected = actual ∧ endpointMatches = true := by
  simpa [admit] using h

theorem reject_wrong_key (expected actual : Key) (h : expected ≠ actual)
    (endpointMatches : Bool) : admit expected actual endpointMatches = false := by
  simp [admit, h]

#print axioms contextual_exposure
#print axioms insertion_link
#print axioms composed_normalization
#print axioms admission_exact
#print axioms reject_wrong_key
end FlatExposure
