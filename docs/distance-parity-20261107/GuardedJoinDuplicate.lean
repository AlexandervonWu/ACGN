import Std

/- Duplicate JOIN construction obligations are not Boolean tautology erasures.
   An occurrence can disappear when its enclosing Boolean atom is duplicated
   under the SAME AND/OR owner. Its original certificate must be retained;
   neither a new JOIN rotation nor a cross-owner identification is licensed.
   The Java correspondence must check the two actual original atoms, their
   common Boolean owner, and the surviving atom's original/live source link. -/
namespace GuardedJoinDuplicate

structure Coordinate where
  opcode : String
  exactType : String
  binder : String
  dependencies : List String
  owner : List Nat
  phase : Nat
  orderedPorts : List String
  deriving DecidableEq

def conjunction (meaning : Coordinate → Prop) (xs : List Coordinate) : Prop :=
  ∀ x ∈ xs, meaning x

def disjunction (meaning : Coordinate → Prop) (xs : List Coordinate) : Prop :=
  ∃ x ∈ xs, meaning x

def sameSupport (xs ys : List Coordinate) : Prop :=
  ∀ x, x ∈ xs ↔ x ∈ ys

theorem and_support (meaning : Coordinate → Prop) (xs ys : List Coordinate)
    (checked : sameSupport xs ys) : conjunction meaning xs ↔ conjunction meaning ys := by
  constructor
  · intro h x hx; exact h x ((checked x).mpr hx)
  · intro h x hx; exact h x ((checked x).mp hx)

theorem or_support (meaning : Coordinate → Prop) (xs ys : List Coordinate)
    (checked : sameSupport xs ys) : disjunction meaning xs ↔ disjunction meaning ys := by
  constructor
  · rintro ⟨x, hx, hm⟩; exact ⟨x, (checked x).mp hx, hm⟩
  · rintro ⟨x, hx, hm⟩; exact ⟨x, (checked x).mpr hx, hm⟩

theorem duplicate_support (pre mid post : List Coordinate) (a : Coordinate) :
    sameSupport (pre ++ a :: mid ++ a :: post) (pre ++ a :: mid ++ post) := by
  intro x
  simp only [List.mem_append, List.mem_cons]
  simp only [or_assoc, or_left_comm]
  constructor
  · rintro (h | h | h)
    · exact Or.inl h
    · exact Or.inl h
    · exact Or.inr h
  · rintro (h | h)
    · exact Or.inl h
    · exact Or.inr (Or.inr h)

theorem duplicate_and (meaning : Coordinate → Prop)
    (pre mid post : List Coordinate) (a : Coordinate) :
    conjunction meaning (pre ++ a :: mid ++ a :: post) ↔
      conjunction meaning (pre ++ a :: mid ++ post) :=
  and_support meaning _ _ (duplicate_support pre mid post a)

theorem duplicate_or (meaning : Coordinate → Prop)
    (pre mid post : List Coordinate) (a : Coordinate) :
    disjunction meaning (pre ++ a :: mid ++ a :: post) ↔
      disjunction meaning (pre ++ a :: mid ++ post) :=
  or_support meaning _ _ (duplicate_support pre mid post a)

-- Pointwise equality transports through arbitrary pure surrounding binders.
-- It does not assert that two different binder coordinates mean the same thing.
theorem scoped_duplicate (context : (Env → Prop) → Prop)
    (meaning : Env → Coordinate → Prop)
    (pre mid post : List Coordinate) (a : Coordinate) :
    context (fun env => conjunction (meaning env) (pre ++ a :: mid ++ a :: post)) ↔
      context (fun env => conjunction (meaning env) (pre ++ a :: mid ++ post)) := by
  have eq : (fun env => conjunction (meaning env) (pre ++ a :: mid ++ a :: post)) =
      (fun env => conjunction (meaning env) (pre ++ a :: mid ++ post)) :=
    funext fun env => propext (duplicate_and (meaning env) pre mid post a)
  rw [eq]

structure OldScope where
  frozen : Bool
  sourcePresent : Bool
  repairPresent : Bool
  temporalNone : Bool
  temporalChildren : Nat
  locals : Nat
  params : Nat
  inherited : Nat
  imports : Nat

-- Exact conjuncts of GuardedJoinErasureEvidence.requireScope, not a weakened gate.
def oldErasureGate (s : OldScope) : Bool :=
  s.frozen && s.sourcePresent && s.repairPresent && s.temporalNone &&
    decide (s.temporalChildren = 0) && decide (s.locals = 0) &&
    decide (s.params = 0) && decide (s.inherited = 0) && decide (s.imports = 0)

def eventScope : OldScope := ⟨true, true, true, true, 0, 2, 0, 0, 0⟩
theorem event102_old_gate_rejects : oldErasureGate eventScope = false := by decide

theorem old_gate_rejects_observed_locals (s : OldScope) (observed : s.locals = 2) :
    oldErasureGate s = false := by simp [oldErasureGate, observed]

-- Finite membership interpretation for the extracted domain ((grades.Grade).c).
-- Slot identity includes the original binding owner; two names are never
-- identified merely because their display names or relation types coincide.
structure Slot where
  alpha : String
  bindingPath : String
  sourceIdentity : String
  exactType : String
  deriving DecidableEq

structure DomainAtom where
  coordinate : Coordinate
  e : Slot
  c : Slot
  gradesType : String
  gradeType : String
  intermediateType : String
  outputType : String
  profile : String
  deriving DecidableEq

structure DomainEnvironment (A : Type) where
  slot : Slot → A
  grades : A → A → A → Prop
  grade : A → Prop

def interpretDomainAtom (env : DomainEnvironment A) (atom : DomainAtom) : Prop :=
  ∃ g, env.grades (env.slot atom.e) (env.slot atom.c) g ∧ env.grade g

-- The two JOIN existential steps are exposed independently of the
-- duplicate theorem, with the unary Grade operand kept in the middle.
def originalDomainMembership (env : DomainEnvironment A) (atom : DomainAtom) : Prop :=
  ∃ c, (∃ g, env.grades (env.slot atom.e) c g ∧ env.grade g) ∧ c = env.slot atom.c

theorem unchanged_left_join_interpretation (env : DomainEnvironment A) (atom : DomainAtom) :
    originalDomainMembership env atom ↔ interpretDomainAtom env atom := by
  constructor
  · rintro ⟨c, ⟨g, hg, ht⟩, hc⟩; subst c; exact ⟨g, hg, ht⟩
  · rintro ⟨g, hg, ht⟩; exact ⟨env.slot atom.c, ⟨g, hg, ht⟩, rfl⟩

theorem scoped_or_duplicate (context : (Env → Prop) → Prop)
    (meaning : Env → Coordinate → Prop)
    (pre mid post : List Coordinate) (a : Coordinate) :
    context (fun env => disjunction (meaning env) (pre ++ a :: mid ++ a :: post)) ↔
      context (fun env => disjunction (meaning env) (pre ++ a :: mid ++ post)) := by
  have eq : (fun env => disjunction (meaning env) (pre ++ a :: mid ++ a :: post)) =
      (fun env => disjunction (meaning env) (pre ++ a :: mid ++ post)) :=
    funext fun env => propext (duplicate_or (meaning env) pre mid post a)
  rw [eq]

-- Extracted original source paths: common AND /0/2/1; duplicate atoms
-- /0/2/1/0/1 and /0/2/1/1. JOINs are their right child. The local e binder is
-- unchanged; c is the same outer Course slot in both copies. Grade is unary,
-- so grades.Grade.c is NOT reassociated across that middle operand.
def membershipCoordinate : Coordinate :=
  ⟨"IN", "BOOL", "root/predicate[0]/or[2]/local-decl[0]",
   ["root/predicate[0]/decl[0]@pos"], [0, 2, 1], 0,
   ["e:EMPTY_RELATION[arity=1]", "((grades:Course->Person->Grade).Grade).c:EMPTY_RELATION[arity=1]"]⟩

def sourceAtomPath : List Nat := [0, 2, 1, 1]
def retainedAtomPath : List Nat := [0, 2, 1, 0, 1]
theorem event102_owner_paths :
    sourceAtomPath = membershipCoordinate.owner ++ [1] ∧
    retainedAtomPath = membershipCoordinate.owner ++ [0, 1] ∧
    sourceAtomPath ≠ retainedAtomPath := by decide

def domain (grades : A → A → A → Prop) (grade : A → Prop) (c e : A) : Prop :=
  ∃ g, grades e c g ∧ grade g

-- Relational JOIN brackets deliberately unchanged on both sides.
theorem event102_context (course : A → Prop) (enrolled : A → A → Prop)
    (grades : A → A → A → Prop) (grade : A → Prop)
    (body : A → A → A → Prop) (project : A → A → Prop) :
    (∀ c, course c → ∀ s, ¬ enrolled c s ∨ project c s ∨
      ∃ e, domain grades grade c e ∧ ((body c s e ∧ domain grades grade c e) ∧ domain grades grade c e)) ↔
    (∀ c, course c → ∀ s, ¬ enrolled c s ∨ project c s ∨
      ∃ e, domain grades grade c e ∧ (domain grades grade c e ∧ body c s e)) := by
  have law (c s e : A) :
      (domain grades grade c e ∧ ((body c s e ∧ domain grades grade c e) ∧ domain grades grade c e)) ↔
      (domain grades grade c e ∧ (domain grades grade c e ∧ body c s e)) := by
    constructor
    · intro h; exact ⟨h.1, h.1, h.2.1.1⟩
    · intro h; exact ⟨h.1, ⟨h.2.2, h.1⟩, h.1⟩
  simp only [law]

theorem wrong_owner_not_duplicate :
    membershipCoordinate ≠ {membershipCoordinate with owner := [0, 1]} := by decide
theorem wrong_phase_not_duplicate :
    membershipCoordinate ≠ {membershipCoordinate with phase := 1} := by decide
theorem wrong_binding_not_duplicate :
    membershipCoordinate ≠ {membershipCoordinate with binder := "another-local-owner"} := by decide
theorem wrong_type_not_duplicate :
    membershipCoordinate ≠ {membershipCoordinate with exactType := "RELATION"} := by decide
theorem ordered_ports_not_interchangeable :
    membershipCoordinate ≠ {membershipCoordinate with orderedPorts := membershipCoordinate.orderedPorts.reverse} := by decide
theorem absence_insufficient : ¬ (∀ P Q : Prop, (P ∧ Q) ↔ P) := by
  intro h
  exact ((h True False).mpr True.intro).2

#print axioms and_support
#print axioms or_support
#print axioms duplicate_and
#print axioms duplicate_or
#print axioms scoped_duplicate
#print axioms event102_old_gate_rejects
#print axioms event102_owner_paths
#print axioms event102_context
#print axioms absence_insufficient
#print axioms old_gate_rejects_observed_locals
#print axioms unchanged_left_join_interpretation
#print axioms scoped_or_duplicate
end GuardedJoinDuplicate
