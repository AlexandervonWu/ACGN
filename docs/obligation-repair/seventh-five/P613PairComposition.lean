import Std

namespace ACGN.Seventh.P613

/-- The mathematical subject uses exact bytes. The executable identifies those
bytes by SHA-256 and the caller-selected declaration. -/
structure Subject where
  decl : String
  bytes : List UInt8
  deriving DecidableEq

structure Shape (Tree : Type) where
  context : List String
  sort : String
  tree : Tree
  deriving DecidableEq

/-- Local term identifiers are interpreted only in their own bundle. -/
structure Endpoint where
  owner : Subject
  term : Nat
  deriving DecidableEq

structure Judgment where
  first : Endpoint
  last : Endpoint

/-- A replay and an independently supplied orbit compose by exact endpoints.
Both proofs and the representative stay in the chosen source owner's scope. -/
def Joins (s : Subject) (source : Endpoint) (replay orbit : Judgment) : Prop :=
  source.owner = s ∧ replay.first = source ∧ replay.last.owner = s ∧
  replay.last = orbit.first ∧ orbit.last.owner = s

theorem wrong_middle_refused {s source replay orbit} (h : replay.last ≠ orbit.first) :
    ¬ Joins s source replay orbit := fun joined => h joined.2.2.2.1

theorem foreign_subject_refused {s source replay orbit} (h : orbit.last.owner ≠ s) :
    ¬ Joins s source replay orbit := fun joined => h joined.2.2.2.2

theorem same_declaration_separate_bytes (name : String) (a b : List UInt8) (h : a ≠ b)
    (i : Nat) : Endpoint.mk ⟨name, a⟩ i ≠ Endpoint.mk ⟨name, b⟩ i :=
  fun he => h (congrArg (fun e : Endpoint => e.owner.bytes) he)

def Least (le : α → α → Prop) (orbit : List α) (rep : α) : Prop :=
  rep ∈ orbit ∧ ∀ t ∈ orbit, le rep t

/-- This suffices even when the two orbit enumerations use different orders
and repeat different members. The order is over the whole typed shape. -/
theorem minima_of_same_orbit {le : α → α → Prop} {a b : List α} {l r : α}
    (antisym : ∀ x y, le x y → le y x → x = y)
    (left : Least le a l) (right : Least le b r) (members : ∀ x, x ∈ a ↔ x ∈ b) :
    l = r :=
  antisym l r (left.2 r ((members r).mpr right.1)) (right.2 l ((members l).mp left.1))

/-- The public PAIR boundary compares shapes and reachable declarations only
after both local evidence chains have been checked. -/
structure Side (Tree : Type) (owner : Subject) (bind : Subject → Endpoint → Prop)
    (step : Judgment → Prop) (shape : Endpoint → Shape Tree)
    (le : Shape Tree → Shape Tree → Prop) where
  source : Endpoint
  replay : Judgment
  orbit : Judgment
  candidates : List (Shape Tree)
  bound : bind owner source
  replayOK : step replay
  orbitOK : step orbit
  joined : Joins owner source replay orbit
  least : Least le candidates (shape orbit.last)

def Common (shape : Endpoint → Shape Tree) (compatible : Endpoint → Endpoint → Prop)
    (l r : Endpoint) : Prop := shape l = shape r ∧ compatible l r

theorem sort_mismatch_refused {shape : Endpoint → Shape Tree} {compatible l r}
    (h : (shape l).sort ≠ (shape r).sort) : ¬ Common shape compatible l r :=
  fun accepted => h (congrArg Shape.sort accepted.1)

theorem unshared_vocabulary_refused {shape : Endpoint → Shape Tree} {compatible l r}
    (h : ¬ compatible l r) : ¬ Common shape compatible l r :=
  fun accepted => h accepted.2

variable {Tree Value : Type} {owner other : Subject} {bind : Subject → Endpoint → Prop}
         {step : Judgment → Prop} {shape : Endpoint → Shape Tree}
         {le : Shape Tree → Shape Tree → Prop}

/-- A conditional interpretation of the local byte bindings and proof judgments.
No interpretation of Alloy function implementations is assumed in the fixtures. -/
theorem side_preserves (s : Side Tree owner bind step shape le)
    (value : Endpoint → Value) (raw : Subject → Value)
    (binding : ∀ o t, bind o t → raw o = value t)
    (sound : ∀ j, step j → value j.first = value j.last) :
    raw owner = value s.orbit.last := by
  calc
    raw owner = value s.source := binding _ _ s.bound
    _ = value s.replay.first := congrArg value s.joined.2.1.symm
    _ = value s.replay.last := sound _ s.replayOK
    _ = value s.orbit.first := congrArg value s.joined.2.2.2.1
    _ = value s.orbit.last := sound _ s.orbitOK

/-- Composes both independent raw-to-representative derivations and transports
minimality from both finite orbits to the common typed shape. -/
theorem pair_composition (l : Side Tree owner bind step shape le)
    (r : Side Tree other bind step shape le)
    (compatible : Endpoint → Endpoint → Prop)
    (common : Common shape compatible l.orbit.last r.orbit.last)
    (value : Endpoint → Value) (raw : Subject → Value)
    (binding : ∀ o t, bind o t → raw o = value t)
    (sound : ∀ j, step j → value j.first = value j.last)
    (agreement : ∀ a b, shape a = shape b → compatible a b → value a = value b) :
    raw owner = raw other ∧ Least le l.candidates (shape l.orbit.last) ∧
    Least le r.candidates (shape l.orbit.last) := by
  refine ⟨?_, l.least, common.1.symm ▸ r.least⟩
  calc
    raw owner = value l.orbit.last := side_preserves l value raw binding sound
    _ = value r.orbit.last := agreement _ _ common.1 common.2
    _ = raw other := (side_preserves r value raw binding sound).symm

#print axioms wrong_middle_refused
#print axioms foreign_subject_refused
#print axioms same_declaration_separate_bytes
#print axioms minima_of_same_orbit
#print axioms sort_mismatch_refused
#print axioms unshared_vocabulary_refused
#print axioms side_preserves
#print axioms pair_composition

end ACGN.Seventh.P613
