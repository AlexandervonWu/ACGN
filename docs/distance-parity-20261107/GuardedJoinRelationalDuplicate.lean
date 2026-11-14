import GuardedJoinDuplicate

namespace GuardedJoinRelationalDuplicate
open GuardedJoinDuplicate

-- Relations are interpreted pointwise, retaining the environment and tuple.
def intersection (meaning : Env → Coordinate → Tuple → Prop)
    (xs : List Coordinate) (env : Env) (tuple : Tuple) : Prop :=
  conjunction (fun x => meaning env x tuple) xs

def union (meaning : Env → Coordinate → Tuple → Prop)
    (xs : List Coordinate) (env : Env) (tuple : Tuple) : Prop :=
  disjunction (fun x => meaning env x tuple) xs

theorem intersection_support (meaning : Env → Coordinate → Tuple → Prop)
    (xs ys : List Coordinate) (checked : sameSupport xs ys) :
    intersection meaning xs = intersection meaning ys := by
  funext env tuple
  exact propext (and_support _ xs ys checked)

theorem union_support (meaning : Env → Coordinate → Tuple → Prop)
    (xs ys : List Coordinate) (checked : sameSupport xs ys) :
    union meaning xs = union meaning ys := by
  funext env tuple
  exact propext (or_support _ xs ys checked)

theorem singleton_intersection (meaning : Env → Coordinate → Tuple → Prop)
    (xs : List Coordinate) (a : Coordinate) (checked : sameSupport xs [a]) :
    intersection meaning xs = fun env tuple => meaning env a tuple := by
  rw [intersection_support meaning xs [a] checked]
  funext env tuple
  simp [intersection, conjunction]

theorem singleton_union (meaning : Env → Coordinate → Tuple → Prop)
    (xs : List Coordinate) (a : Coordinate) (checked : sameSupport xs [a]) :
    union meaning xs = fun env tuple => meaning env a tuple := by
  rw [union_support meaning xs [a] checked]
  funext env tuple
  simp [union, disjunction]

theorem collapse_under_context (meaning : Env → Coordinate → Tuple → Prop)
    (context : (Env → Tuple → Prop) → Result) (a : Coordinate) :
    context (intersection meaning [a,a]) = context (fun env tuple => meaning env a tuple) := by
  apply congrArg context
  apply singleton_intersection
  intro x
  simp

structure Owner where
  opcode : String
  setFlexible : Bool
  metatype : String
  typeKind : String
  exactType : String
  admissibleProfile : Bool
  deriving DecidableEq

-- Exact old booleanOwner predicate, including all metadata conjuncts.
def oldOwnerGate (n : Owner) : Bool :=
  (n.opcode == "AND" || n.opcode == "OR") && n.setFlexible &&
    (n.metatype == "BOOLEAN") && (n.typeKind == "BOOL") && n.admissibleProfile

def oldStrictDescendantGate (tail : List Nat) : Bool := !tail.isEmpty

theorem direct_atom_old_gate_rejects : oldStrictDescendantGate [] = false := by decide

-- The observed brackets are y . ((x . projects) . grades). No JOIN
-- reassociation or identification of the Course and Project carriers occurs.
structure Environment (Atom : Type) where
  slot : Slot → Atom
  projects : Atom → Atom → Prop
  grades : Atom → Atom → Atom → Prop

def sourceJoin (env : Environment Atom) (x y : Slot) (grade : Atom) : Prop :=
  ∃ course, course = env.slot y ∧
    ∃ project, env.projects (env.slot x) project ∧ env.grades project course grade

theorem source_join_duplicate (x y : Slot)
    (context : (Environment Atom → Atom → Prop) → Result) :
    context (fun env grade => sourceJoin env x y grade ∧ sourceJoin env x y grade) =
    context (fun env grade => sourceJoin env x y grade) := by
  apply congrArg context
  funext env grade
  exact and_self _

theorem empty_tail_retains_join (join : A) : ([] : List Nat).foldl (fun n _ => n) join = join := rfl

theorem absence_is_not_idempotence : ¬ (∀ P Q : Prop, (P ∧ Q) ↔ P) :=
  GuardedJoinDuplicate.absence_insufficient

theorem empty_support_not_singleton (a : Coordinate) : ¬ sameSupport [] [a] := by
  intro h
  have impossible := (h a).mpr (by simp)
  simp at impossible

end GuardedJoinRelationalDuplicate
