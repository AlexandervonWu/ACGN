import PhaseA2DependentChains

/- Fast comparison normalization reuses the existing guarded JOIN theorem.
   Presentation metadata is not part of unary relational emptiness semantics.
   Java/parser refinement remains an explicitly tested obligation. -/
namespace FastRewriteParity

structure UnaryPresentation where
  label : String
  variadic : Bool

-- Covers NO/SOME/ONE/LONE without changing the chosen cardinality predicate.
def unaryMeaning {A B : Type} (_ : UnaryPresentation) (meaning : A → B) (arg : A) : B :=
  meaning arg

theorem unary_meaning_preserved {A B : Type} (a b : UnaryPresentation)
    (meaning : A → B) (arg : A) :
    unaryMeaning a meaning arg = unaryMeaning b meaning arg := rfl

def emptyRelation {A : Type} (_ : UnaryPresentation) (r : A → Prop) : Prop :=
  ¬ ∃ a, r a

theorem unary_presentation_irrelevant {A : Type}
    (a b : UnaryPresentation) (r : A → Prop) :
    emptyRelation a r ↔ emptyRelation b r := Iff.rfl

theorem duplicate_conjunction (p : Prop) : (p ∧ p) ↔ p := by
  exact ⟨fun h => h.1, fun h => ⟨h, h⟩⟩

theorem duplicate_disjunction (p : Prop) : (p ∨ p) ↔ p := by
  exact ⟨fun h => h.elim id id, Or.inl⟩

theorem conjunction_flatten (p q r : Prop) : ((p ∧ q) ∧ r) ↔ (p ∧ (q ∧ r)) :=
  and_assoc

theorem disjunction_flatten (p q r : Prop) : ((p ∨ q) ∨ r) ↔ (p ∨ (q ∨ r)) :=
  or_assoc

-- Grouping does not change an ordered, non-disjoint coordinate ledger.
theorem declaration_grouping {A : Type} (xs ys : List A) :
    [xs, ys].flatten = [xs ++ ys].flatten := by simp

def comprehension {A B : Type} (da : A → Prop) (db : B → Prop)
    (body : A → B → Prop) (pair : A × B) : Prop :=
  da pair.1 ∧ db pair.2 ∧ body pair.1 pair.2

theorem comprehension_alpha {A B : Type} (da : A → Prop) (db : B → Prop)
    (body : A → B → Prop) (pair : A × B) :
    comprehension da db (fun x y => body x y) pair ↔
      comprehension da db (fun s1 s2 => body s1 s2) pair := Iff.rfl

theorem shadowed_lookup {A : Type} (inner outer : A) (rest : List A) :
    (inner :: outer :: rest)[0]? = some inner := rfl

theorem second_coordinate_retained {A : Type} (first second : A) :
    [first, second][1]? = some second := rfl

-- This is the existing relation-level law, not unrestricted list flattening.
open ACGN.Section3.PhaseA2 in
theorem guarded_join {A : Type} (r : LeftTuple A → Prop)
    (s : MiddleTuple A → Prop) (t : RightTuple A → Prop) (out : List A) :
    JoinLR (JoinLM r s) t out ↔ JoinLR r (JoinMR s t) out :=
  guarded_join_relation_reassociation r s t out

open ACGN.Section3.PhaseA2 in
theorem unary_middle_counterexample :
    relationJoin (relationJoin counterR counterS) counterT ≠
      relationJoin counterR (relationJoin counterS counterT) :=
  unguarded_join_is_not_associative

#print axioms unary_presentation_irrelevant
#print axioms unary_meaning_preserved
#print axioms duplicate_conjunction
#print axioms duplicate_disjunction
#print axioms conjunction_flatten
#print axioms disjunction_flatten
#print axioms declaration_grouping
#print axioms comprehension_alpha
#print axioms shadowed_lookup
#print axioms second_coordinate_retained
#print axioms guarded_join
#print axioms unary_middle_counterexample
end FastRewriteParity
