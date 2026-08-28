import Std

/-
Independent Phase 5 model.  It imports no producer definitions, certificates,
or fixtures.  Relations are predicates, Alloy `in` is relational subset, and
declaration multiplicities constrain relation-valued bindings.
-/

universe u

abbrev Rel (α : Type u) := α → Prop

def noneRel : Rel α := fun _ => False
def univRel : Rel α := fun _ => True
def subset (left right : Rel α) : Prop :=
  ∀ atom, left atom → right atom
def relNonempty (relation : Rel α) : Prop :=
  ∃ atom, relation atom

theorem relation_subset_reflexive (relation : Rel α) :
    subset relation relation := by
  intro atom member
  exact member

theorem relation_equality_reflexive (relation : Rel α) :
    relation = relation := rfl

theorem relation_not_subset_self_is_false (relation : Rel α) :
    ¬ (¬ subset relation relation) := by
  exact not_not_intro (relation_subset_reflexive relation)

theorem relation_inequality_self_is_false (relation : Rel α) :
    ¬ relation ≠ relation := by
  exact not_not_intro rfl

theorem certified_equal_relations_subset
    (left right : Rel α)
    (equal : left = right) :
    subset left right := by
  cases equal
  exact relation_subset_reflexive left

theorem certified_equal_relations_compare_equal
    (left right : Rel α)
    (equal : left = right) :
    left = right := by
  exact equal

theorem certified_equal_relations_not_subset_is_false
    (left right : Rel α)
    (equal : left = right) :
    ¬ (¬ subset left right) := by
  exact not_not_intro (certified_equal_relations_subset left right equal)

theorem certified_equal_relations_inequality_is_false
    (left right : Rel α)
    (equal : left = right) :
    ¬ left ≠ right := by
  exact not_not_intro equal

theorem univ_requires_an_inhabitant_for_nonemptiness
    {α : Type u}
    (nonempty : relNonempty (@univRel α)) : Nonempty α := by
  rcases nonempty with ⟨atom, _⟩
  exact ⟨atom⟩

theorem empty_universe_is_not_nonempty :
    ¬ relNonempty (@univRel Empty) := by
  rintro ⟨atom, _⟩
  exact nomatch atom
def atMostOne (relation : Rel α) : Prop :=
  ∀ left right, relation left → relation right → left = right
def exactlyOne (relation : Rel α) : Prop :=
  relNonempty relation ∧ atMostOne relation

def letValue (bound : β) (body : β -> γ) : γ := body bound

theorem let_identity (value : β) : letValue value (fun bound => bound) = value := rfl

/- Core R0 formula rewrites.  These declarations deliberately state each
source-level equation independently of the Java representation. -/

def operatorAlias (value : α) : α := value
def noop (value : α) : α := value

theorem operator_alias_preserves_denotation (value : α) :
    operatorAlias value = value := rfl

theorem noop_elimination (value : α) : noop value = value := rfl

theorem let_beta_reduction (value : β) (body : β → γ) :
    letValue value body = body value := rfl

theorem implication_elimination (left right : Prop) :
    (left → right) ↔ (¬ left ∨ right) := by
  classical
  constructor
  · intro implication
    by_cases member : left
    · exact Or.inr (implication member)
    · exact Or.inl member
  · intro disjunction member
    cases disjunction with
    | inl absent => exact False.elim (absent member)
    | inr present => exact present

theorem iff_elimination (left right : Prop) :
    (left ↔ right) ↔
      ((¬ left ∨ right) ∧ (¬ right ∨ left)) := by
  constructor
  · intro equivalent
    exact ⟨(implication_elimination left right).mp equivalent.mp,
      (implication_elimination right left).mp equivalent.mpr⟩
  · intro branches
    exact ⟨(implication_elimination left right).mpr branches.1,
      (implication_elimination right left).mpr branches.2⟩

theorem formula_ite_elimination (condition thenBranch elseBranch : Prop)
    [Decidable condition] :
    (if condition then thenBranch else elseBranch) ↔
      ((condition ∧ thenBranch) ∨ (¬ condition ∧ elseBranch)) := by
  classical
  by_cases active : condition <;> simp [active]

theorem double_negation_elimination (proposition : Prop) :
    (¬ ¬ proposition) ↔ proposition := by
  classical
  simp

theorem de_morgan_conjunction (left right : Prop) :
    (¬ (left ∧ right)) ↔ (¬ left ∨ ¬ right) := by
  classical
  by_cases leftMember : left <;> by_cases rightMember : right <;>
    simp [leftMember, rightMember]

theorem de_morgan_disjunction (left right : Prop) :
    (¬ (left ∨ right)) ↔ (¬ left ∧ ¬ right) := by
  classical
  by_cases leftMember : left <;> by_cases rightMember : right <;>
    simp [leftMember, rightMember]

theorem negated_true_is_false : (¬ True) ↔ False := by simp
theorem negated_false_is_true : (¬ False) ↔ True := by simp

theorem negated_equality_is_inequality (left right : α) :
    (¬ left = right) ↔ left ≠ right := Iff.rfl

theorem negated_inequality_is_equality (left right : α) :
    (¬ left ≠ right) ↔ left = right := by
  classical
  simp

theorem negated_int_gt_is_lte (left right : Int) :
    (¬ left > right) ↔ left ≤ right := by omega

theorem negated_int_gte_is_lt (left right : Int) :
    (¬ left ≥ right) ↔ left < right := by omega

theorem negated_int_lt_is_gte (left right : Int) :
    (¬ left < right) ↔ left ≥ right := by omega

theorem negated_int_lte_is_gt (left right : Int) :
    (¬ left ≤ right) ↔ left > right := by omega

theorem negated_subset_is_not_subset (left right : Rel α) :
    (¬ subset left right) ↔ (¬ subset left right) := Iff.rfl

theorem negated_not_subset_is_subset (left right : Rel α) :
    (¬ (¬ subset left right)) ↔ subset left right := by
  classical
  simp

def someOf (predicate : α → Prop) : Prop := ∃ value, predicate value
def noOf (predicate : α → Prop) : Prop := ¬ someOf predicate
def oneOf (predicate : α → Prop) : Prop := exactlyOne predicate
def loneOf (predicate : α → Prop) : Prop := atMostOne predicate
def notOneOf (predicate : α → Prop) : Prop := ¬ oneOf predicate
def notLoneOf (predicate : α → Prop) : Prop := ¬ loneOf predicate

theorem negated_some_is_no (predicate : α → Prop) :
    (¬ someOf predicate) ↔ noOf predicate := Iff.rfl

theorem negated_no_is_some (predicate : α → Prop) :
    (¬ noOf predicate) ↔ someOf predicate := by
  classical
  simp [noOf]

theorem negated_one_is_notone (predicate : α → Prop) :
    (¬ oneOf predicate) ↔ notOneOf predicate := Iff.rfl

theorem negated_lone_is_notlone (predicate : α → Prop) :
    (¬ loneOf predicate) ↔ notLoneOf predicate := Iff.rfl

theorem negated_notone_is_one (predicate : α → Prop) :
    (¬ notOneOf predicate) ↔ oneOf predicate := by
  classical
  simp [notOneOf]

theorem negated_notlone_is_lone (predicate : α → Prop) :
    (¬ notLoneOf predicate) ↔ loneOf predicate := by
  classical
  simp [notLoneOf]

theorem all_true_body : (∀ _value : α, True) := by
  intro
  trivial

theorem some_false_body_is_false : ¬ (∃ _value : α, False) := by
  rintro ⟨_, impossible⟩
  exact impossible

theorem no_false_body_is_true : noOf (fun _value : α => False) := by
  exact some_false_body_is_false

theorem one_false_body_is_false :
    ¬ oneOf (fun _value : α => False) := by
  rintro ⟨⟨_, impossible⟩, _⟩
  exact impossible

theorem lone_false_body_is_true :
    loneOf (fun _value : α => False) := by
  intro left right leftMember
  exact False.elim leftMember

theorem notone_false_body_is_true :
    notOneOf (fun _value : α => False) := by
  exact one_false_body_is_false

theorem notlone_false_body_is_false :
    ¬ notLoneOf (fun _value : α => False) := by
  intro notLone
  exact notLone lone_false_body_is_true

/- Temporal operators are interpreted directly over discrete traces.  Release
and triggered use their universal witness semantics rather than being aliases
for the duality being proved. -/

def futureAlways (predicate : Nat → Prop) (now : Nat) : Prop :=
  ∀ instant, now ≤ instant → predicate instant

def futureEventually (predicate : Nat → Prop) (now : Nat) : Prop :=
  ∃ instant, now ≤ instant ∧ predicate instant

def pastHistorically (predicate : Nat → Prop) (now : Nat) : Prop :=
  ∀ instant, instant ≤ now → predicate instant

def pastOnce (predicate : Nat → Prop) (now : Nat) : Prop :=
  ∃ instant, instant ≤ now ∧ predicate instant

def futureUntil
    (left right : Nat → Prop) (now : Nat) : Prop :=
  ∃ stop, now ≤ stop ∧ right stop ∧
    ∀ instant, now ≤ instant → instant < stop → left instant

def futureRelease
    (left right : Nat → Prop) (now : Nat) : Prop :=
  ∀ stop, now ≤ stop →
    right stop ∨
      ∃ instant, now ≤ instant ∧ instant < stop ∧ left instant

def pastSince
    (left right : Nat → Prop) (now : Nat) : Prop :=
  ∃ start, start ≤ now ∧ right start ∧
    ∀ instant, start < instant → instant ≤ now → left instant

def pastTriggered
    (left right : Nat → Prop) (now : Nat) : Prop :=
  ∀ start, start ≤ now →
    right start ∨
      ∃ instant, start < instant ∧ instant ≤ now ∧ left instant

theorem negated_always_is_eventually_not
    (predicate : Nat → Prop) (now : Nat) :
    (¬ futureAlways predicate now) ↔
      futureEventually (fun instant => ¬ predicate instant) now := by
  classical
  simp [futureAlways, futureEventually]

theorem negated_eventually_is_always_not
    (predicate : Nat → Prop) (now : Nat) :
    (¬ futureEventually predicate now) ↔
      futureAlways (fun instant => ¬ predicate instant) now := by
  classical
  simp [futureAlways, futureEventually]

theorem negated_historically_is_once_not
    (predicate : Nat → Prop) (now : Nat) :
    (¬ pastHistorically predicate now) ↔
      pastOnce (fun instant => ¬ predicate instant) now := by
  classical
  simp [pastHistorically, pastOnce]

theorem negated_once_is_historically_not
    (predicate : Nat → Prop) (now : Nat) :
    (¬ pastOnce predicate now) ↔
      pastHistorically (fun instant => ¬ predicate instant) now := by
  classical
  simp [pastHistorically, pastOnce]

theorem negated_until_is_release_not
    (left right : Nat → Prop) (now : Nat) :
    (¬ futureUntil left right now) ↔
      futureRelease (fun instant => ¬ left instant)
        (fun instant => ¬ right instant) now := by
  classical
  constructor
  · intro absent stop afterNow
    by_cases rightAbsent : ¬ right stop
    · exact Or.inl rightAbsent
    · right
      have rightPresent : right stop := Classical.not_not.mp rightAbsent
      apply Classical.byContradiction
      intro noCounterexample
      have allLeft : ∀ instant, now ≤ instant → instant < stop →
          left instant := by
        intro instant lower upper
        apply Classical.byContradiction
        intro leftAbsent
        exact noCounterexample ⟨instant, lower, upper, leftAbsent⟩
      exact absent ⟨stop, afterNow, rightPresent, allLeft⟩
  · intro released untilWitness
    rcases untilWitness with ⟨stop, afterNow, rightPresent, allLeft⟩
    rcases released stop afterNow with rightAbsent | counterexample
    · exact rightAbsent rightPresent
    · rcases counterexample with ⟨instant, lower, upper, leftAbsent⟩
      exact leftAbsent (allLeft instant lower upper)

theorem negated_release_is_until_not
    (left right : Nat → Prop) (now : Nat) :
    (¬ futureRelease left right now) ↔
      futureUntil (fun instant => ¬ left instant)
        (fun instant => ¬ right instant) now := by
  classical
  constructor
  · intro absent
    obtain ⟨stop, rejected⟩ := Classical.not_forall.mp absent
    have afterNow : now ≤ stop := Classical.byContradiction (fun beforeNow =>
      rejected (fun impossible => False.elim (beforeNow impossible)))
    have rejectedClause : ¬ (right stop ∨
        ∃ instant, now ≤ instant ∧ instant < stop ∧ left instant) := by
      intro clause
      exact rejected (fun _ => clause)
    have rightAbsent : ¬ right stop := by
      intro present
      exact rejectedClause (Or.inl present)
    have allLeftAbsent : ∀ instant, now ≤ instant → instant < stop →
        ¬ left instant := by
      intro instant lower upper present
      exact rejectedClause (Or.inr ⟨instant, lower, upper, present⟩)
    exact ⟨stop, afterNow, rightAbsent, allLeftAbsent⟩
  · rintro ⟨stop, afterNow, rightAbsent, allLeftAbsent⟩ released
    rcases released stop afterNow with rightPresent | witness
    · exact rightAbsent rightPresent
    · rcases witness with ⟨instant, lower, upper, leftPresent⟩
      exact allLeftAbsent instant lower upper leftPresent

theorem negated_since_is_triggered_not
    (left right : Nat → Prop) (now : Nat) :
    (¬ pastSince left right now) ↔
      pastTriggered (fun instant => ¬ left instant)
        (fun instant => ¬ right instant) now := by
  classical
  constructor
  · intro absent start beforeNow
    by_cases rightAbsent : ¬ right start
    · exact Or.inl rightAbsent
    · right
      have rightPresent : right start := Classical.not_not.mp rightAbsent
      apply Classical.byContradiction
      intro noCounterexample
      have allLeft : ∀ instant, start < instant → instant ≤ now →
          left instant := by
        intro instant lower upper
        apply Classical.byContradiction
        intro leftAbsent
        exact noCounterexample ⟨instant, lower, upper, leftAbsent⟩
      exact absent ⟨start, beforeNow, rightPresent, allLeft⟩
  · intro triggered sinceWitness
    rcases sinceWitness with ⟨start, beforeNow, rightPresent, allLeft⟩
    rcases triggered start beforeNow with rightAbsent | counterexample
    · exact rightAbsent rightPresent
    · rcases counterexample with ⟨instant, lower, upper, leftAbsent⟩
      exact leftAbsent (allLeft instant lower upper)

theorem negated_triggered_is_since_not
    (left right : Nat → Prop) (now : Nat) :
    (¬ pastTriggered left right now) ↔
      pastSince (fun instant => ¬ left instant)
        (fun instant => ¬ right instant) now := by
  classical
  constructor
  · intro absent
    obtain ⟨start, rejected⟩ := Classical.not_forall.mp absent
    have beforeNow : start ≤ now := Classical.byContradiction (fun afterNow =>
      rejected (fun impossible => False.elim (afterNow impossible)))
    have rejectedClause : ¬ (right start ∨
        ∃ instant, start < instant ∧ instant ≤ now ∧ left instant) := by
      intro clause
      exact rejected (fun _ => clause)
    have rightAbsent : ¬ right start := by
      intro present
      exact rejectedClause (Or.inl present)
    have allLeftAbsent : ∀ instant, start < instant → instant ≤ now →
        ¬ left instant := by
      intro instant lower upper present
      exact rejectedClause (Or.inr ⟨instant, lower, upper, present⟩)
    exact ⟨start, beforeNow, rightAbsent, allLeftAbsent⟩
  · rintro ⟨start, beforeNow, rightAbsent, allLeftAbsent⟩ triggered
    rcases triggered start beforeNow with rightPresent | witness
    · exact rightAbsent rightPresent
    · rcases witness with ⟨instant, lower, upper, leftPresent⟩
      exact allLeftAbsent instant lower upper leftPresent

theorem negated_forall_is_exists_not (predicate : α → Prop) :
    (¬ ∀ value, predicate value) ↔ ∃ value, ¬ predicate value := by
  classical
  simp

theorem negated_exists_is_forall_not (predicate : α → Prop) :
    (¬ ∃ value, predicate value) ↔ ∀ value, ¬ predicate value := by
  classical
  simp

theorem no_quantifier_is_all_not (predicate : α → Prop) :
    noOf predicate ↔ ∀ value, ¬ predicate value := by
  classical
  simp [noOf, someOf]

theorem negated_no_quantifier_is_some (predicate : α → Prop) :
    (¬ noOf predicate) ↔ ∃ value, predicate value := by
  classical
  simp [noOf, someOf]

theorem safe_exists_conjunction_prenex
    (predicate : α → Prop) (outside : Prop) :
    ((∃ value, predicate value) ∧ outside) ↔
      ∃ value, predicate value ∧ outside := by
  constructor
  · rintro ⟨⟨value, member⟩, external⟩
    exact ⟨value, member, external⟩
  · rintro ⟨value, member, external⟩
    exact ⟨⟨value, member⟩, external⟩

theorem safe_forall_disjunction_prenex
    (predicate : α → Prop) (outside : Prop) :
    ((∀ value, predicate value) ∨ outside) ↔
      ∀ value, predicate value ∨ outside := by
  classical
  constructor
  · intro source value
    cases source with
    | inl universal => exact Or.inl (universal value)
    | inr external => exact Or.inr external
  · intro pointwise
    by_cases external : outside
    · exact Or.inr external
    · left
      intro value
      rcases pointwise value with member | impossible
      · exact member
      · exact False.elim (external impossible)

theorem boolean_and_associative (left middle right : Prop) :
    ((left ∧ middle) ∧ right) ↔ (left ∧ (middle ∧ right)) := by
  constructor
  · rintro ⟨⟨leftMember, middleMember⟩, rightMember⟩
    exact ⟨leftMember, middleMember, rightMember⟩
  · rintro ⟨leftMember, middleMember, rightMember⟩
    exact ⟨⟨leftMember, middleMember⟩, rightMember⟩

theorem boolean_and_commutative (left right : Prop) :
    (left ∧ right) ↔ (right ∧ left) := by simp [and_comm]

theorem boolean_and_idempotent (proposition : Prop) :
    (proposition ∧ proposition) ↔ proposition := by simp

theorem boolean_or_associative (left middle right : Prop) :
    ((left ∨ middle) ∨ right) ↔ (left ∨ (middle ∨ right)) := by
  constructor
  · intro source
    rcases source with (leftMember | middleMember) | rightMember
    · exact Or.inl leftMember
    · exact Or.inr (Or.inl middleMember)
    · exact Or.inr (Or.inr rightMember)
  · intro source
    rcases source with leftMember | middleMember | rightMember
    · exact Or.inl (Or.inl leftMember)
    · exact Or.inl (Or.inr middleMember)
    · exact Or.inr rightMember

theorem boolean_or_commutative (left right : Prop) :
    (left ∨ right) ↔ (right ∨ left) := by simp [or_comm]

theorem boolean_or_idempotent (proposition : Prop) :
    (proposition ∨ proposition) ↔ proposition := by simp

theorem integer_addition_associative (left middle right : Int) :
    (left + middle) + right = left + (middle + right) := by omega

theorem integer_addition_commutative (left right : Int) :
    left + right = right + left := by omega

theorem integer_multiplication_associative (left middle right : Int) :
    (left * middle) * right = left * (middle * right) := by
  exact Int.mul_assoc left middle right

theorem integer_multiplication_commutative (left right : Int) :
    left * right = right * left := by
  exact Int.mul_comm left right

theorem equality_commutative (left right : α) :
    (left = right) ↔ (right = left) := by
  constructor <;> intro equal <;> exact equal.symm

theorem inequality_commutative (left right : α) :
    (left ≠ right) ↔ (right ≠ left) := by
  constructor
  · intro different equal
    exact different equal.symm
  · intro different equal
    exact different equal.symm

theorem iff_commutative (left right : Prop) :
    (left ↔ right) ↔ (right ↔ left) := by
  constructor <;> intro equivalent <;> exact equivalent.symm

theorem implication_false_antecedent (proposition : Prop) :
    (False → proposition) ↔ True := by simp

theorem implication_true_antecedent (proposition : Prop) :
    (True → proposition) ↔ proposition := by simp

theorem implication_true_consequent (proposition : Prop) :
    (proposition → True) ↔ True := by simp

theorem implication_false_consequent (proposition : Prop) :
    (proposition → False) ↔ ¬ proposition := Iff.rfl

def boundedForall (domain body : α → Prop) : Prop :=
  ∀ value, domain value → body value

def boundedExists (domain body : α → Prop) : Prop :=
  ∃ value, domain value ∧ body value

def boundedNo (domain body : α → Prop) : Prop :=
  ¬ boundedExists domain body

theorem universal_complex_domain_guard
    (domain body : α → Prop) :
    boundedForall domain body ↔
      ∀ value, domain value → body value := Iff.rfl

theorem existential_complex_domain_guard
    (domain body : α → Prop) :
    boundedExists domain body ↔
      ∃ value, domain value ∧ body value := Iff.rfl

theorem no_complex_domain_guard
    (domain body : α → Prop) :
    boundedNo domain body ↔
      ¬ ∃ value, domain value ∧ body value := Iff.rfl

inductive SkeletonPart (α : Type) where
  | payload (value : α)
  | endMarker
  deriving DecidableEq

def eraseEndMarkers : List (SkeletonPart α) → List α
  | [] => []
  | .payload value :: rest => value :: eraseEndMarkers rest
  | .endMarker :: rest => eraseEndMarkers rest

theorem end_marker_elimination_preserves_payload
    (before after : List (SkeletonPart α)) :
    eraseEndMarkers (before ++ .endMarker :: after) =
      eraseEndMarkers before ++ eraseEndMarkers after := by
  induction before with
  | nil => rfl
  | cons head tail inductionHypothesis =>
      cases head <;> simp [eraseEndMarkers, inductionHypothesis]

abbrev LexicalBinderId := Nat

def shadowBinder
    (environment : LexicalBinderId → β)
    (binder : LexicalBinderId)
    (value : β) : LexicalBinderId → β :=
  fun queried => if queried = binder then value else environment queried

theorem distinct_lexical_binder_survives_shadow
    (environment : LexicalBinderId → β)
    (outer inner : LexicalBinderId)
    (innerValue : β)
    (distinct : outer ≠ inner) :
    shadowBinder environment inner innerValue outer = environment outer := by
  simp [shadowBinder, distinct]

theorem let_substitution_uses_lexical_identity
    (environment : LexicalBinderId → β)
    (outer inner : LexicalBinderId)
    (innerValue : β)
    (distinct : outer ≠ inner) :
    letValue (environment outer)
      (fun bound => (bound, shadowBinder environment inner innerValue outer)) =
      (environment outer, environment outer) := by
  simp [letValue, shadowBinder, distinct]

theorem boolean_and_true_identity (proposition : Prop) :
    (proposition ∧ True) ↔ proposition := by
  simp

theorem boolean_or_false_identity (proposition : Prop) :
    (proposition ∨ False) ↔ proposition := by
  simp

theorem boolean_and_false_absorbs (proposition : Prop) :
    (proposition ∧ False) ↔ False := by
  simp

theorem boolean_or_true_absorbs (proposition : Prop) :
    (proposition ∨ True) ↔ True := by
  simp

inductive LiteralMetatype where
  | boolean
  | relation
  deriving DecidableEq, Repr

inductive LiteralExactType where
  | boolean
  | relation
  deriving DecidableEq, Repr

inductive LiteralSpelling where
  | trueName
  | falseName
  deriving DecidableEq, Repr

inductive LiteralSourceType where
  | boolName
  | booleanName
  | validatedOperator
  | relationName
  deriving DecidableEq, Repr

structure LiteralEvidence where
  metatype : LiteralMetatype
  exactType : LiteralExactType
  spelling : LiteralSpelling
  sourceType : LiteralSourceType
  deriving DecidableEq, Repr

def recognizesBooleanLiteral
    (literal : LiteralEvidence)
    (value : Bool) : Bool :=
  literal.metatype == .boolean &&
    literal.exactType == .boolean &&
    literal.spelling == (if value then .trueName else .falseName) &&
    (literal.sourceType == .boolName ||
      literal.sourceType == .booleanName)

theorem relation_metatype_named_true_is_not_boolean :
    recognizesBooleanLiteral
      ⟨.relation, .boolean, .trueName, .boolName⟩ true = false := by
  decide

theorem relation_exact_type_named_false_is_not_boolean :
    recognizesBooleanLiteral
      ⟨.boolean, .relation, .falseName, .boolName⟩ false = false := by
  decide

theorem relation_source_type_named_true_is_not_boolean :
    recognizesBooleanLiteral
      ⟨.boolean, .boolean, .trueName, .relationName⟩ true = false := by
  decide

theorem exact_boolean_true_is_recognized :
    recognizesBooleanLiteral
      ⟨.boolean, .boolean, .trueName, .boolName⟩ true = true := by
  decide

theorem exact_boolean_false_is_recognized :
    recognizesBooleanLiteral
      ⟨.boolean, .boolean, .falseName, .booleanName⟩ false = true := by
  decide

inductive BooleanOperatorAuthority where
  | absent
  | genericTypeOnly
  | parserConcordant
  | internalDerived
  deriving DecidableEq, Repr

structure BooleanContainerEvidence where
  metatype : LiteralMetatype
  exactType : LiteralExactType
  sourceType : LiteralSourceType
  authority : BooleanOperatorAuthority
  deriving DecidableEq, Repr

def isBooleanFormulaSourceType (sourceType : LiteralSourceType) : Bool :=
  sourceType == .boolName ||
    sourceType == .booleanName ||
    sourceType == .validatedOperator

def hasBooleanOperatorAuthority
    (authority : BooleanOperatorAuthority) : Bool :=
  authority == .parserConcordant || authority == .internalDerived

def permitsBooleanContainerRewrite
    (container : BooleanContainerEvidence) : Bool :=
  container.metatype == .boolean &&
    container.exactType == .boolean &&
    isBooleanFormulaSourceType container.sourceType &&
    hasBooleanOperatorAuthority container.authority

theorem relation_container_cannot_apply_boolean_identity :
    permitsBooleanContainerRewrite
      ⟨.relation, .relation, .relationName, .absent⟩ = false := by
  decide

theorem contradictory_container_source_type_blocks_boolean_identity :
    permitsBooleanContainerRewrite
      ⟨.boolean, .boolean, .relationName, .parserConcordant⟩ = false := by
  decide

theorem validated_operator_container_can_apply_boolean_identity :
    permitsBooleanContainerRewrite
      ⟨.boolean, .boolean, .validatedOperator, .parserConcordant⟩ = true := by
  decide

theorem generic_boolean_type_does_not_authorize_an_operator :
    permitsBooleanContainerRewrite
      ⟨.boolean, .boolean, .boolName, .genericTypeOnly⟩ = false := by
  decide

theorem internally_derived_boolean_operator_is_authorized :
    permitsBooleanContainerRewrite
      ⟨.boolean, .boolean, .boolName, .internalDerived⟩ = true := by
  decide

inductive BooleanMutationPath where
  | publicSemanticMutation
  | trustedNormalizedChildConstruction
  deriving DecidableEq, Repr

def authorityAfterMutation
    (authority : BooleanOperatorAuthority)
    (path : BooleanMutationPath) : BooleanOperatorAuthority :=
  match path with
  | .publicSemanticMutation => .absent
  | .trustedNormalizedChildConstruction => authority

theorem public_mutation_revokes_internal_boolean_authority :
    authorityAfterMutation .internalDerived .publicSemanticMutation = .absent := rfl

theorem trusted_normalized_construction_retains_internal_boolean_authority :
    authorityAfterMutation .internalDerived .trustedNormalizedChildConstruction =
      .internalDerived := rfl

theorem generic_bool_after_public_mutation_cannot_reuse_derived_authority :
    permitsBooleanContainerRewrite
      ⟨.boolean, .boolean, .boolName,
        authorityAfterMutation .internalDerived .publicSemanticMutation⟩ = false := by
  decide

inductive BooleanOperandShape where
  | call
  | connective
  | formulaAtom
  | quantifier
  | temporal
  | formulaWrapper
  | relationJoin
  | relationBinding
  deriving DecidableEq, Repr

structure BooleanOperandEvidence where
  exactType : LiteralExactType
  shape : BooleanOperandShape
  deriving DecidableEq, Repr

def isFormulaOperandShape (shape : BooleanOperandShape) : Bool :=
  match shape with
  | .call | .connective | .formulaAtom | .quantifier
  | .temporal | .formulaWrapper => true
  | .relationJoin | .relationBinding => false

def permitsBooleanOperand (operand : BooleanOperandEvidence) : Bool :=
  operand.exactType == .boolean && isFormulaOperandShape operand.shape

def permitsBooleanTreeRewrite
    (container : BooleanContainerEvidence)
    (operands : List BooleanOperandEvidence) : Bool :=
  permitsBooleanContainerRewrite container &&
    operands.all permitsBooleanOperand

theorem relation_operand_blocks_boolean_rewrite :
    permitsBooleanTreeRewrite
      ⟨.boolean, .boolean, .validatedOperator, .parserConcordant⟩
      [⟨.boolean, .formulaAtom⟩, ⟨.relation, .formulaAtom⟩] = false := by
  decide

theorem all_boolean_operands_admit_boolean_rewrite :
    permitsBooleanTreeRewrite
      ⟨.boolean, .boolean, .validatedOperator, .parserConcordant⟩
      [⟨.boolean, .formulaAtom⟩, ⟨.boolean, .call⟩] = true := by
  decide

theorem forged_boolean_join_is_not_a_formula_operand :
    permitsBooleanOperand ⟨.boolean, .relationJoin⟩ = false := by
  decide

theorem forged_boolean_binding_is_not_a_formula_operand :
    permitsBooleanOperand ⟨.boolean, .relationBinding⟩ = false := by
  decide

inductive IteNormalizationAction where
  | expandBooleanBranches
  | retainAndTraverseChildren
  deriving DecidableEq, Repr

def iteNormalizationAction
    (result : BooleanContainerEvidence) : IteNormalizationAction :=
  if permitsBooleanContainerRewrite result then
    .expandBooleanBranches
  else
    .retainAndTraverseChildren

theorem relation_ite_is_retained_but_its_children_are_traversed :
    iteNormalizationAction
      ⟨.relation, .relation, .validatedOperator, .parserConcordant⟩ =
      .retainAndTraverseChildren := by
  decide

theorem exact_boolean_ite_may_expand :
    iteNormalizationAction
      ⟨.boolean, .boolean, .validatedOperator, .parserConcordant⟩ =
      .expandBooleanBranches := by
  decide

structure CallAdmissionEvidence where
  isCall : Bool
  admittedArity : Bool
  qualifiedSemanticIdentity : Bool
  deriving DecidableEq, Repr

def admitsNodeBeforeRewrite (node : CallAdmissionEvidence) : Bool :=
  node.admittedArity && (!node.isCall || node.qualifiedSemanticIdentity)

theorem incomplete_call_is_rejected_before_parent_rewrite :
    admitsNodeBeforeRewrite ⟨true, true, false⟩ = false := by
  decide

theorem complete_call_reaches_rewrite_traversal :
    admitsNodeBeforeRewrite ⟨true, true, true⟩ = true := by
  decide

inductive SourceAdmissionTree where
  | node (evidence : CallAdmissionEvidence) (children : List SourceAdmissionTree)

mutual
  def admitsTreeBeforeRewrite : SourceAdmissionTree → Bool
    | .node evidence children =>
        admitsNodeBeforeRewrite evidence && admitsForestBeforeRewrite children

  def admitsForestBeforeRewrite : List SourceAdmissionTree → Bool
    | [] => true
    | head :: tail =>
        admitsTreeBeforeRewrite head && admitsForestBeforeRewrite tail
end

inductive RewriteGate where
  | rejected
  | admitted
  deriving DecidableEq, Repr

def graphRewriteGate (tree : SourceAdmissionTree) : RewriteGate :=
  if admitsTreeBeforeRewrite tree then .admitted else .rejected

def malformedDescendantCall : SourceAdmissionTree :=
  .node ⟨true, true, false⟩ []

def wrapperContainingMalformedCall : SourceAdmissionTree :=
  .node ⟨false, true, false⟩ [malformedDescendantCall]

def absorbingParentContainingMalformedCall : SourceAdmissionTree :=
  .node ⟨false, true, false⟩ [wrapperContainingMalformedCall]

theorem malformed_descendant_call_blocks_the_whole_rewrite_graph :
    graphRewriteGate absorbingParentContainingMalformedCall = .rejected := by
  native_decide

theorem every_descendant_is_checked_before_rewrite
    (parentEvidence childEvidence : CallAdmissionEvidence)
    (childRejected : admitsNodeBeforeRewrite childEvidence = false) :
    admitsTreeBeforeRewrite
      (.node parentEvidence [.node childEvidence []]) = false := by
  simp [admitsTreeBeforeRewrite, admitsForestBeforeRewrite, childRejected]

abbrev SourceEClass := List SourceAdmissionTree
abbrev SourceUnionComponent := List SourceEClass

def admitsEClassBeforeRewrite (alternatives : SourceEClass) : Bool :=
  alternatives.all admitsTreeBeforeRewrite

def admitsUnionComponentBeforeRewrite
    (classes : SourceUnionComponent) : Bool :=
  classes.all admitsEClassBeforeRewrite

def unionComponentRewriteGate
    (classes : SourceUnionComponent) : RewriteGate :=
  if admitsUnionComponentBeforeRewrite classes then .admitted else .rejected

def validFormulaLeaf : SourceAdmissionTree :=
  .node ⟨false, true, false⟩ []

def componentWithHiddenMalformedAlternative : SourceUnionComponent :=
  [[validFormulaLeaf], [validFormulaLeaf, malformedDescendantCall]]

theorem malformed_union_alternative_blocks_component_admission :
    unionComponentRewriteGate componentWithHiddenMalformedAlternative =
      .rejected := by
  native_decide

inductive TemporalAdmissionTree where
  | phase
      (matrix : SourceAdmissionTree)
      (children : List TemporalAdmissionTree)

mutual
  def admitsTemporalTreeBeforeRewrite : TemporalAdmissionTree → Bool
    | .phase matrix children =>
        admitsTreeBeforeRewrite matrix &&
          admitsTemporalForestBeforeRewrite children

  def admitsTemporalForestBeforeRewrite : List TemporalAdmissionTree → Bool
    | [] => true
    | head :: tail =>
        admitsTemporalTreeBeforeRewrite head &&
          admitsTemporalForestBeforeRewrite tail
end

def temporalRewriteGate (tree : TemporalAdmissionTree) : RewriteGate :=
  if admitsTemporalTreeBeforeRewrite tree then .admitted else .rejected

def temporalParentWithMalformedDescendant : TemporalAdmissionTree :=
  .phase validFormulaLeaf [
    .phase wrapperContainingMalformedCall []]

theorem malformed_temporal_descendant_blocks_parent_rewrite :
    temporalRewriteGate temporalParentWithMalformedDescendant = .rejected := by
  native_decide

structure TemporalReferenceEvidence where
  isReference : Bool
  exactBoolean : Bool
  parserIssued : Bool
  sourceOccurrenceBound : Bool
  sourceVisitMatches : Bool
  edgeBucketExact : Bool
  edgePositionsExact : Bool
  childTargetsLive : Bool
  graphRootLive : Bool
  sourceGraphLive : Bool
  sourceArityMatches : Bool
  targetMatchesOwner : Bool
  authorityId : Nat
  referenceAuthorityId : Nat
  deriving DecidableEq, Repr

def admitsTemporalReference (reference : TemporalReferenceEvidence) : Bool :=
  reference.isReference && reference.exactBoolean &&
    reference.parserIssued && reference.sourceOccurrenceBound &&
    reference.sourceVisitMatches && reference.edgeBucketExact &&
    reference.edgePositionsExact && reference.childTargetsLive &&
    reference.graphRootLive && reference.sourceGraphLive &&
    reference.sourceArityMatches && reference.targetMatchesOwner &&
    reference.authorityId != 0 &&
    reference.referenceAuthorityId == reference.authorityId

def validTemporalReferenceEvidence : TemporalReferenceEvidence :=
  { isReference := true
    exactBoolean := true
    parserIssued := true
    sourceOccurrenceBound := true
    sourceVisitMatches := true
    edgeBucketExact := true
    edgePositionsExact := true
    childTargetsLive := true
    graphRootLive := true
    sourceGraphLive := true
    sourceArityMatches := true
    targetMatchesOwner := true
    authorityId := 1
    referenceAuthorityId := 1 }

theorem forged_temporal_reference_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with parserIssued := false } = false := by
  decide

theorem wrong_owner_temporal_reference_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with targetMatchesOwner := false } = false := by
  decide

theorem unbound_temporal_source_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with sourceOccurrenceBound := false } = false := by
  decide

theorem wrong_temporal_source_arity_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with sourceArityMatches := false } = false := by
  decide

theorem wrong_temporal_source_visit_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with sourceVisitMatches := false } = false := by
  decide

theorem incomplete_temporal_edge_bucket_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with edgeBucketExact := false } = false := by
  decide

theorem duplicate_temporal_edge_position_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with edgePositionsExact := false } = false := by
  decide

theorem removed_temporal_child_vertex_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with childTargetsLive := false } = false := by
  decide

theorem removed_temporal_graph_root_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with graphRootLive := false } = false := by
  decide

theorem mutated_temporal_source_graph_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with sourceGraphLive := false } = false := by
  decide

theorem transplanted_temporal_authority_is_rejected :
    admitsTemporalReference
      { validTemporalReferenceEvidence with authorityId := 2 } = false := by
  decide

theorem owner_bound_temporal_reference_is_admitted :
    admitsTemporalReference validTemporalReferenceEvidence = true := by
  decide

structure TemporalChildCoverage where
  childCount : Nat
  referencedCount : Nat
  overlappingRange : Bool
  deriving DecidableEq, Repr

def admitsTemporalChildCoverage (coverage : TemporalChildCoverage) : Bool :=
  coverage.childCount == coverage.referencedCount &&
    !coverage.overlappingRange

theorem unreferenced_temporal_child_is_rejected :
    admitsTemporalChildCoverage ⟨1, 0, false⟩ = false := by
  decide

theorem exact_temporal_child_partition_is_admitted :
    admitsTemporalChildCoverage ⟨2, 2, false⟩ = true := by
  decide

theorem overlapping_temporal_child_ranges_are_rejected :
    admitsTemporalChildCoverage ⟨2, 2, true⟩ = false := by
  decide

structure SealedTemporalReference where
  authorityId : Nat
  ownerId : Nat
  deriving DecidableEq, Repr

def sealTemporalReference
    (reference : TemporalReferenceEvidence)
    (ownerId : Nat) : Option SealedTemporalReference :=
  if admitsTemporalReference reference then
    some ⟨reference.authorityId, ownerId⟩
  else
    none

def admitsSealedTemporalReference
    (reference : SealedTemporalReference)
    (requestedOwnerId : Nat) : Bool :=
  reference.authorityId != 0 && reference.ownerId == requestedOwnerId

theorem invalid_live_temporal_reference_cannot_be_sealed :
    sealTemporalReference
      { validTemporalReferenceEvidence with sourceGraphLive := false } 7 = none := by
  decide

theorem valid_live_temporal_reference_can_be_sealed :
    sealTemporalReference validTemporalReferenceEvidence 7 = some ⟨1, 7⟩ := by
  decide

theorem sealed_temporal_reference_does_not_require_retained_parser_graph :
    admitsSealedTemporalReference ⟨1, 7⟩ 7 = true := by
  decide

theorem sealed_temporal_reference_rejects_another_owner :
    admitsSealedTemporalReference ⟨1, 7⟩ 8 = false := by
  decide

def temporalEvidenceConsumable (issued consumed : Bool) : Bool :=
  issued && !consumed

theorem temporal_evidence_is_not_reusable :
    temporalEvidenceConsumable true true = false := by
  decide

def globallyDistinctTemporalAuthorities (left right : Nat) : Bool :=
  left != 0 && right != 0 && left != right

theorem successive_temporal_authorities_are_globally_distinct (authority : Nat) :
    globallyDistinctTemporalAuthorities (authority + 1) (authority + 2) = true := by
  simp [globallyDistinctTemporalAuthorities]

structure GraphOwnership where
  arena : Nat
  semanticProfile : Nat
  deriving DecidableEq, Repr

def permitsChildAttachment
    (parent child : GraphOwnership) : Bool :=
  parent.arena == child.arena &&
    parent.semanticProfile == child.semanticProfile

theorem foreign_arena_child_is_rejected (arena profile : Nat) :
    permitsChildAttachment
      ⟨arena, profile⟩ ⟨arena + 1, profile⟩ = false := by
  simp [permitsChildAttachment]

theorem foreign_profile_child_is_rejected (arena profile : Nat) :
    permitsChildAttachment
      ⟨arena, profile⟩ ⟨arena, profile + 1⟩ = false := by
  simp [permitsChildAttachment]

structure SnapshotState where
  ownership : GraphOwnership
  frozen : Bool
  deriving DecidableEq, Repr

def preserveSnapshot (source : SnapshotState) : SnapshotState := source

def snapshotMutable (snapshot : SnapshotState) : Bool := !snapshot.frozen

theorem snapshot_preserves_owning_arena_and_profile
    (source : SnapshotState) :
    (preserveSnapshot source).ownership = source.ownership := rfl

theorem frozen_snapshot_is_immutable (ownership : GraphOwnership) :
    snapshotMutable ⟨ownership, true⟩ = false := by
  rfl

inductive CertificationArenaState where
  | mutable
  | frozen
  deriving DecidableEq, Repr

def arenaMutationAllowed (state : CertificationArenaState) : Bool :=
  state == .mutable

def atomicAdmitAndFreeze
    (admitted : Bool)
    (state : CertificationArenaState) : Option CertificationArenaState :=
  if admitted && state == .mutable then some .frozen else none

structure CertificationPublication where
  normalFormFrozen : Bool
  arenaState : CertificationArenaState
  deriving DecidableEq, Repr

def validCertificationPublication
    (publication : CertificationPublication) : Bool :=
  !publication.normalFormFrozen || publication.arenaState == .frozen

theorem atomic_admission_and_freeze_has_no_mutable_success_state :
    atomicAdmitAndFreeze true .mutable = some .frozen := by
  decide

theorem mutation_rejects_after_atomic_certification_freeze :
    arenaMutationAllowed .frozen = false := by
  decide

theorem publishing_normal_form_before_arena_freeze_is_invalid :
    validCertificationPublication ⟨true, .mutable⟩ = false := by
  decide

theorem publishing_after_arena_freeze_is_valid :
    validCertificationPublication ⟨true, .frozen⟩ = true := by
  decide

def wholeGraphRewriteAdmitted
    (reachable : List CertificationArenaState) : Bool :=
  reachable.all (fun state => state == .mutable)

def atomicWholeGraphRewrite
    (reachable : List CertificationArenaState) :
    Option (List CertificationArenaState) :=
  if wholeGraphRewriteAdmitted reachable then some reachable else none

theorem shared_frozen_descendant_blocks_other_parent_rewrite :
    atomicWholeGraphRewrite [.mutable, .frozen] = none := by
  decide

theorem all_mutable_reachable_nodes_admit_rewrite :
    atomicWholeGraphRewrite [.mutable, .mutable] =
      some [.mutable, .mutable] := by
  decide

theorem failed_whole_graph_preflight_has_no_partial_result :
    atomicWholeGraphRewrite [.mutable, .frozen, .mutable] = none := by
  decide

def generatedRewriteArena
    (sourceArena executingThreadArena : Nat)
    (inheritsOwner : Bool) : Nat :=
  if inheritsOwner then sourceArena else executingThreadArena

def generatedRewriteNodeCompatible
    (sourceArena executingThreadArena : Nat)
    (inheritsOwner : Bool) : Bool :=
  generatedRewriteArena sourceArena executingThreadArena inheritsOwner ==
    sourceArena

theorem generated_rewrite_node_inherits_source_arena
    (sourceArena executingThreadArena : Nat) :
    generatedRewriteNodeCompatible sourceArena executingThreadArena true = true := by
  simp [generatedRewriteNodeCompatible, generatedRewriteArena]

theorem thread_local_rewrite_node_is_rejected_when_threads_differ
    (sourceArena : Nat) :
    generatedRewriteNodeCompatible sourceArena (sourceArena + 1) false = false := by
  simp [generatedRewriteNodeCompatible, generatedRewriteArena]

inductive AdmissionDispatch where
  | sealedBaseImplementation
  | overridableProducerHook
  deriving DecidableEq, Repr

def trustedAdmissionDispatch (dispatch : AdmissionDispatch) : Bool :=
  dispatch == .sealedBaseImplementation

theorem sealed_egraph_node_admission_is_trusted :
    trustedAdmissionDispatch .sealedBaseImplementation = true := by
  decide

theorem overridable_egraph_node_admission_is_rejected :
    trustedAdmissionDispatch .overridableProducerHook = false := by
  decide

structure RegisteredEClass where
  id : Nat
  childReachable : Bool
  unionReachable : Bool
  deriving DecidableEq, Repr

def retainedByRootClosure (eclass : RegisteredEClass) : Bool :=
  eclass.childReachable || eclass.unionReachable

def retainRegisteredClosure
    (classes : List RegisteredEClass) : List RegisteredEClass :=
  classes.filter retainedByRootClosure

def reachabilityPruningFixture : List RegisteredEClass :=
  [⟨0, true, false⟩, ⟨1, false, true⟩,
   ⟨2, false, false⟩, ⟨3, false, false⟩]

theorem disconnected_registered_union_component_is_pruned :
    (retainRegisteredClosure reachabilityPruningFixture).map
      RegisteredEClass.id = [0, 1] := by
  decide

theorem reachable_union_component_member_is_retained :
    retainedByRootClosure ⟨1, false, true⟩ = true := by
  decide

theorem registration_alone_does_not_imply_reachability :
    retainedByRootClosure ⟨2, false, false⟩ = false := by
  decide

def emptyRootReachabilityFixture : List RegisteredEClass :=
  [⟨0, false, false⟩, ⟨1, false, false⟩]

theorem empty_root_closure_prunes_every_registered_class :
    retainRegisteredClosure emptyRootReachabilityFixture = [] := by
  decide

def concreteRetainedRoots (roots : List (Option Nat)) : List Nat :=
  roots.filterMap id

theorem all_null_root_list_has_empty_closure :
    concreteRetainedRoots [none, none, none] = [] := by
  decide

def transactionalMutation
    (before proposed : Nat)
    (preflightAccepts : Bool) : Nat :=
  if preflightAccepts then proposed else before

theorem rejected_child_replacement_preserves_prior_state
    (before proposed : Nat) :
    transactionalMutation before proposed false = before := by
  simp [transactionalMutation]

theorem admitted_child_replacement_commits_once
    (before proposed : Nat) :
    transactionalMutation before proposed true = proposed := by
  simp [transactionalMutation]

inductive RetainedEClassState where
  | live
  | retired
  deriving DecidableEq, Repr

def mayReuseEClass (state : RetainedEClassState) : Bool :=
  state == .live

theorem a_pruned_eclass_handle_cannot_be_reused :
    mayReuseEClass .retired = false := by
  decide

theorem a_retained_eclass_handle_remains_live :
    mayReuseEClass .live = true := by
  decide

def mayAdmitEClass (state : RetainedEClassState) : Bool :=
  state == .live

theorem a_retired_eclass_fails_admission_before_traversal :
    mayAdmitEClass .retired = false := by
  decide

structure RetiredPayload where
  nodes : Nat
  shapes : Nat
  symmetries : Nat
  slots : Nat
  deriving DecidableEq, Repr

def releaseRetiredPayload (_before : RetiredPayload) : RetiredPayload :=
  ⟨0, 0, 0, 0⟩

theorem retirement_releases_all_eclass_payload :
    releaseRetiredPayload ⟨3, 2, 1, 4⟩ = ⟨0, 0, 0, 0⟩ := by
  rfl

structure TemporalRewriteState where
  operation : Nat
  matrixVersion : Nat
  deriving DecidableEq, Repr

def commitStagedTemporalRewrite
    (before staged : TemporalRewriteState)
    (stagingSucceeded : Bool) : TemporalRewriteState :=
  if stagingSucceeded then staged else before

theorem failed_temporal_rewrite_preserves_operation_and_matrix
    (before staged : TemporalRewriteState) :
    commitStagedTemporalRewrite before staged false = before := by
  simp [commitStagedTemporalRewrite]

theorem successful_temporal_rewrite_commits_operation_and_matrix_together
    (before staged : TemporalRewriteState) :
    commitStagedTemporalRewrite before staged true = staged := by
  simp [commitStagedTemporalRewrite]

inductive TemporalLifecycleWinner where
  | rewrite
  | freeze
  deriving DecidableEq, Repr

structure TemporalLifecycleResult where
  state : TemporalRewriteState
  frozen : Bool
  rewriteAccepted : Bool
  deriving DecidableEq, Repr

def serializeTemporalRewriteAndFreeze
    (winner : TemporalLifecycleWinner)
    (before staged : TemporalRewriteState) : TemporalLifecycleResult :=
  match winner with
  | .rewrite => ⟨staged, true, true⟩
  | .freeze => ⟨before, true, false⟩

theorem serialized_temporal_rewrite_and_freeze_has_only_atomic_outcomes
    (winner : TemporalLifecycleWinner)
    (before staged : TemporalRewriteState) :
    let result := serializeTemporalRewriteAndFreeze winner before staged
    result.frozen = true ∧
      (if result.rewriteAccepted
       then result.state = staged
       else result.state = before) := by
  cases winner <;> simp [serializeTemporalRewriteAndFreeze]

def permitsSemanticComparison
    (left right : GraphOwnership) : Bool :=
  left == right

theorem cross_arena_semantic_comparison_is_rejected
    (arena profile : Nat) :
    permitsSemanticComparison
      ⟨arena, profile⟩ ⟨arena + 1, profile⟩ = false := by
  simp [permitsSemanticComparison]

theorem let_none_identity :
    letValue (noneRel : Rel α) (fun bound => bound) = noneRel := rfl

theorem none_and_univ_are_distinct_on_bool :
    Not ((noneRel : Rel Bool) = univRel) := by
  intro alleged
  have member : (noneRel : Rel Bool) true := by
    rw [alleged]
    trivial
  exact member

inductive ParsedSetIdentity where
  | builtinNone
  | builtinUniv
  | userSignature (sourceName : String)
  deriving DecidableEq, Repr

def parserSetIdentity (sourceName : String) : ParsedSetIdentity :=
  if sourceName = "none" then .builtinNone
  else if sourceName = "univ" then .builtinUniv
  else .userSignature sourceName

theorem exact_none_spelling_is_builtin :
    parserSetIdentity "none" = .builtinNone := by
  native_decide

theorem exact_univ_spelling_is_builtin :
    parserSetIdentity "univ" = .builtinUniv := by
  native_decide

theorem capitalized_none_is_a_user_signature :
    parserSetIdentity "None" = .userSignature "None" := by
  native_decide

theorem capitalized_univ_is_a_user_signature :
    parserSetIdentity "Univ" = .userSignature "Univ" := by
  native_decide

theorem every_nonreserved_name_is_a_user_signature
    (sourceName : String)
    (notNone : sourceName ≠ "none")
    (notUniv : sourceName ≠ "univ") :
    parserSetIdentity sourceName = .userSignature sourceName := by
  simp [parserSetIdentity, notNone, notUniv]

inductive Multiplicity where
  | set
  | lone
  | some
  | one
  | exactly
  deriving DecidableEq, Repr

def multiplicityCondition (multiplicity : Multiplicity) (relation : Rel α) : Prop :=
  match multiplicity with
  | .set => True
  | .lone => atMostOne relation
  | .some => relNonempty relation
  | .one => exactlyOne relation
  | .exactly => True

def admits (multiplicity : Multiplicity) (domain candidate : Rel α) : Prop :=
  match multiplicity with
  | .exactly => candidate = domain
  | other => subset candidate domain ∧ multiplicityCondition other candidate

theorem none_subset (relation : Rel α) : subset noneRel relation := by
  intro atom impossible
  exact False.elim impossible

theorem none_in_every_same_arity_relation (relation : Rel α) :
    subset noneRel relation :=
  none_subset relation

theorem none_not_in_same_arity_relation_is_false (relation : Rel α) :
    (¬ subset noneRel relation) ↔ False := by
  constructor
  · intro denied
    exact denied (none_subset relation)
  · intro impossible
    exact False.elim impossible

theorem subset_none_forces_none {relation : Rel α}
    (proof : subset relation noneRel) : relation = noneRel := by
  funext atom
  apply propext
  constructor
  · intro member
    exact proof atom member
  · intro impossible
    exact False.elim impossible

theorem empty_at_most_one : atMostOne (noneRel : Rel α) := by
  intro left right leftMember
  exact False.elim leftMember

theorem set_none_exactly_one_binding (candidate : Rel α) :
    admits .set noneRel candidate ↔ candidate = noneRel := by
  constructor
  · intro proof
    exact subset_none_forces_none proof.1
  · intro equality
    subst equality
    exact ⟨none_subset noneRel, True.intro⟩

theorem lone_none_exactly_one_binding (candidate : Rel α) :
    admits .lone noneRel candidate ↔ candidate = noneRel := by
  constructor
  · intro proof
    exact subset_none_forces_none proof.1
  · intro equality
    subst equality
    exact ⟨none_subset noneRel, empty_at_most_one⟩

theorem some_none_has_no_binding (candidate : Rel α) :
    ¬ admits .some noneRel candidate := by
  intro proof
  obtain ⟨atom, member⟩ := proof.2
  exact proof.1 atom member

theorem one_none_has_no_binding (candidate : Rel α) :
    ¬ admits .one noneRel candidate := by
  intro proof
  obtain ⟨atom, member⟩ := proof.2.1
  exact proof.1 atom member

theorem exactly_none_has_the_none_binding (candidate : Rel α) :
    admits .exactly noneRel candidate ↔ candidate = noneRel := by
  rfl

def declarationMultiplicity (written : Option Multiplicity) : Multiplicity :=
  match written with
  | none => .one
  | some explicit => explicit

theorem bare_declaration_defaults_to_one :
    declarationMultiplicity none = .one := rfl

theorem explicit_declaration_overrides_default (multiplicity : Multiplicity) :
    declarationMultiplicity (some multiplicity) = multiplicity := rfl

def qAll (domain : β → Prop) (body : β → Prop) : Prop :=
  ∀ value, domain value → body value
def qSome (domain : β → Prop) (body : β → Prop) : Prop :=
  ∃ value, domain value ∧ body value
def qNo (domain : β → Prop) (body : β → Prop) : Prop :=
  ¬ qSome domain body
def qOne (domain : β → Prop) (body : β → Prop) : Prop :=
  ∃ value, domain value ∧ body value ∧
    ∀ other, domain other → body other → other = value
def qLone (domain : β → Prop) (body : β → Prop) : Prop :=
  ∀ left right,
    domain left → body left → domain right → body right → left = right
def emptyBindingSet (domain : β → Prop) : Prop :=
  ∀ value, ¬ domain value

theorem empty_domain_all (domain : β → Prop) (body : β → Prop)
    (empty : emptyBindingSet domain) : qAll domain body := by
  intro value member
  exact False.elim (empty value member)

theorem empty_domain_not_some (domain : β → Prop) (body : β → Prop)
    (empty : emptyBindingSet domain) : ¬ qSome domain body := by
  intro proof
  obtain ⟨value, member, _⟩ := proof
  exact empty value member

theorem empty_domain_no (domain : β → Prop) (body : β → Prop)
    (empty : emptyBindingSet domain) : qNo domain body :=
  empty_domain_not_some domain body empty

theorem empty_domain_not_one (domain : β → Prop) (body : β → Prop)
    (empty : emptyBindingSet domain) : ¬ qOne domain body := by
  intro proof
  obtain ⟨value, member, _, _⟩ := proof
  exact empty value member

theorem empty_domain_lone (domain : β → Prop) (body : β → Prop)
    (empty : emptyBindingSet domain) : qLone domain body := by
  intro left right leftMember
  exact False.elim (empty left leftMember)

theorem empty_domain_not_not_lone (domain : β → Prop) (body : β → Prop)
    (empty : emptyBindingSet domain) : ¬ (¬ qLone domain body) := by
  intro notLone
  exact notLone (empty_domain_lone domain body empty)

theorem pulling_all_across_and_has_an_empty_domain_counterexample :
    ¬ ((False ∧ qAll (fun _ : Empty => True) (fun _ => True)) ↔
      qAll (fun _ : Empty => True) (fun _ => False ∧ True)) := by
  intro alleged
  have right : qAll (fun _ : Empty => True) (fun _ => False ∧ True) := by
    intro value
    exact nomatch value
  exact alleged.mpr right |>.1

theorem pulling_some_across_or_has_an_empty_domain_counterexample :
    ¬ ((True ∨ qSome (fun _ : Empty => True) (fun _ => True)) ↔
      qSome (fun _ : Empty => True) (fun _ => True ∨ True)) := by
  intro alleged
  have left : True ∨ qSome (fun _ : Empty => True) (fun _ => True) :=
    Or.inl True.intro
  rcases alleged.mp left with ⟨value, _⟩
  exact nomatch value

theorem pulling_lone_across_and_is_not_valid :
    ¬ ((False ∧ qLone (fun _ : Empty => True) (fun _ => True)) ↔
      qLone (fun _ : Empty => True) (fun _ => False ∧ True)) := by
  intro alleged
  have right : qLone (fun _ : Empty => True) (fun _ => False ∧ True) := by
    intro left
    exact nomatch left
  exact alleged.mpr right |>.1

theorem some_set_none_equal_none :
    qSome (admits .set noneRel) (fun candidate : Rel α => candidate = noneRel) := by
  refine ⟨noneRel, ?_, rfl⟩
  exact (set_none_exactly_one_binding noneRel).2 rfl

theorem some_lone_none_equal_none :
    qSome (admits .lone noneRel) (fun candidate : Rel α => candidate = noneRel) := by
  refine ⟨noneRel, ?_, rfl⟩
  exact (lone_none_exactly_one_binding noneRel).2 rfl

theorem all_set_none_false_is_false :
    ¬ qAll (admits .set noneRel) (fun _ : Rel α => False) := by
  intro alleged
  exact alleged noneRel ((set_none_exactly_one_binding noneRel).2 rfl)

theorem all_lone_none_false_is_false :
    ¬ qAll (admits .lone noneRel) (fun _ : Rel α => False) := by
  intro alleged
  exact alleged noneRel ((lone_none_exactly_one_binding noneRel).2 rfl)

theorem none_in_none : subset (noneRel : Rel α) noneRel :=
  none_subset noneRel

theorem arbitrary_in_none_is_not_false_without_evidence :
    ¬ (∀ relation : Rel α, ¬ subset relation noneRel) := by
  intro alleged
  exact alleged noneRel none_in_none

theorem nonempty_in_none_is_false {relation : Rel α}
    (nonempty : relNonempty relation) : ¬ subset relation noneRel := by
  intro alleged
  obtain ⟨atom, member⟩ := nonempty
  exact alleged atom member

theorem every_relation_in_univ (relation : Rel α) : subset relation univRel := by
  intro atom member
  exact True.intro

theorem none_not_in_none_is_false : ¬ (¬ subset (noneRel : Rel α) noneRel) := by
  intro alleged
  exact alleged none_in_none

theorem nonempty_not_in_none_is_true {relation : Rel α}
    (nonempty : relNonempty relation) : ¬ subset relation noneRel :=
  nonempty_in_none_is_false nonempty

theorem no_relation_not_in_univ (relation : Rel α) :
    ¬ (¬ subset relation univRel) := by
  intro alleged
  exact alleged (every_relation_in_univ relation)

def intersection (left right : Rel α) : Rel α :=
  fun atom => left atom ∧ right atom

def union (left right : Rel α) : Rel α :=
  fun atom => left atom ∨ right atom

theorem boolean_and_absorbs_or
    (proposition alternative : Prop) :
    (proposition ∧ (proposition ∨ alternative)) ↔ proposition := by
  constructor
  · exact fun member => member.1
  · exact fun member => ⟨member, Or.inl member⟩

theorem boolean_or_absorbs_and
    (proposition alternative : Prop) :
    (proposition ∨ (proposition ∧ alternative)) ↔ proposition := by
  constructor
  · exact fun member => member.elim id (fun nested => nested.1)
  · exact Or.inl

theorem boolean_and_absorption_preserves_context
    (left proposition alternative right : Prop) :
    (((left ∧ proposition) ∧ (proposition ∨ alternative)) ∧ right) ↔
      ((left ∧ proposition) ∧ right) := by
  constructor
  · rintro ⟨⟨⟨leftMember, propositionMember⟩, _⟩, rightMember⟩
    exact ⟨⟨leftMember, propositionMember⟩, rightMember⟩
  · rintro ⟨⟨leftMember, propositionMember⟩, rightMember⟩
    exact ⟨⟨⟨leftMember, propositionMember⟩,
      Or.inl propositionMember⟩, rightMember⟩

theorem boolean_or_absorption_preserves_context
    (left proposition alternative right : Prop) :
    (((left ∨ proposition) ∨ (proposition ∧ alternative)) ∨ right) ↔
      ((left ∨ proposition) ∨ right) := by
  constructor
  · intro member
    rcases member with prior | rightMember
    · rcases prior with prior | nested
      · exact Or.inl prior
      · exact Or.inl (Or.inr nested.1)
    · exact Or.inr rightMember
  · intro member
    rcases member with prior | rightMember
    · exact Or.inl (Or.inl prior)
    · exact Or.inr rightMember

theorem boolean_and_distributes_over_or
    (proposition left right : Prop) :
    (proposition ∧ (left ∨ right)) ↔
      ((proposition ∧ left) ∨ (proposition ∧ right)) := by
  constructor
  · rintro ⟨member, branch⟩
    exact branch.elim
      (fun leftMember => Or.inl ⟨member, leftMember⟩)
      (fun rightMember => Or.inr ⟨member, rightMember⟩)
  · rintro (branch | branch)
    · exact ⟨branch.1, Or.inl branch.2⟩
    · exact ⟨branch.1, Or.inr branch.2⟩

theorem boolean_or_distributes_over_and
    (proposition left right : Prop) :
    (proposition ∨ (left ∧ right)) ↔
      ((proposition ∨ left) ∧ (proposition ∨ right)) := by
  constructor
  · intro member
    exact member.elim
      (fun propositionMember =>
        ⟨Or.inl propositionMember, Or.inl propositionMember⟩)
      (fun branch => ⟨Or.inr branch.1, Or.inr branch.2⟩)
  · rintro ⟨leftBranch, rightBranch⟩
    rcases leftBranch with propositionMember | leftMember
    · exact Or.inl propositionMember
    · rcases rightBranch with propositionMember | rightMember
      · exact Or.inl propositionMember
      · exact Or.inr ⟨leftMember, rightMember⟩

theorem relation_intersection_absorbs_union
    (relation alternative : Rel α) :
    intersection relation (union relation alternative) = relation := by
  funext atom
  exact propext (boolean_and_absorbs_or
    (relation atom) (alternative atom))

theorem relation_union_absorbs_intersection
    (relation alternative : Rel α) :
    union relation (intersection relation alternative) = relation := by
  funext atom
  exact propext (boolean_or_absorbs_and
    (relation atom) (alternative atom))

theorem relation_intersection_absorption_preserves_context
    (left relation alternative right : Rel α) :
    intersection
        (intersection (intersection left relation) (union relation alternative))
        right =
      intersection (intersection left relation) right := by
  funext atom
  exact propext (boolean_and_absorption_preserves_context
    (left atom) (relation atom) (alternative atom) (right atom))

theorem relation_union_absorption_preserves_context
    (left relation alternative right : Rel α) :
    union
        (union (union left relation) (intersection relation alternative))
        right =
      union (union left relation) right := by
  funext atom
  exact propext (boolean_or_absorption_preserves_context
    (left atom) (relation atom) (alternative atom) (right atom))

theorem relation_intersection_distributes_over_union
    (relation left right : Rel α) :
    intersection relation (union left right) =
      union (intersection relation left) (intersection relation right) := by
  funext atom
  exact propext (boolean_and_distributes_over_or
    (relation atom) (left atom) (right atom))

theorem relation_union_distributes_over_intersection
    (relation left right : Rel α) :
    union relation (intersection left right) =
      intersection (union relation left) (union relation right) := by
  funext atom
  exact propext (boolean_or_distributes_over_and
    (relation atom) (left atom) (right atom))

structure ExactTypeProofOperand where
  isEmpty : Bool
  parserModule : Option Nat

def allOperandsFromParserModule
    (moduleId : Nat)
    (operands : List ExactTypeProofOperand) : Prop :=
  ∀ operand, operand ∈ operands → operand.parserModule = some moduleId

theorem empty_intersection_prefix_does_not_skip_foreign_authority
    (ownerModule foreignModule : Nat)
    (different : foreignModule ≠ ownerModule) :
    ¬ allOperandsFromParserModule ownerModule
      [⟨true, some ownerModule⟩, ⟨false, some foreignModule⟩] := by
  intro admitted
  have foreignAccepted : (some foreignModule : Option Nat) =
      some ownerModule := admitted
        ⟨false, some foreignModule⟩ (by simp)
  exact different (Option.some.inj foreignAccepted)

def converse (relation : Rel (α × β)) : Rel (β × α) :=
  fun tuple => relation (tuple.2, tuple.1)

theorem converse_involutive (relation : Rel (α × β)) :
    converse (converse relation) = relation := by
  funext tuple
  rfl

theorem converse_distributes_over_union
    (left right : Rel (α × β)) :
    converse (union left right) =
      union (converse left) (converse right) := by
  funext tuple
  rfl

theorem converse_distributes_over_intersection
    (left right : Rel (α × β)) :
    converse (intersection left right) =
      intersection (converse left) (converse right) := by
  funext tuple
  rfl

theorem relation_union_none_is_relation (relation : Rel α) :
    union relation noneRel = relation := by
  funext atom
  apply propext
  constructor
  · intro member
    exact member.elim id False.elim
  · intro member
    exact Or.inl member

theorem relation_union_univ_is_univ (relation : Rel α) :
    union relation univRel = univRel := by
  funext atom
  simp [union, univRel]

theorem relation_union_idempotent (relation : Rel α) :
    union relation relation = relation := by
  funext atom
  simp [union]

theorem relation_union_commutative (left right : Rel α) :
    union left right = union right left := by
  funext atom
  simp [union, or_comm]

theorem relation_union_associative (left middle right : Rel α) :
    union (union left middle) right = union left (union middle right) := by
  funext atom
  simp [union, or_assoc]

/- Alloy's abstract-signature fact equates an abstract carrier with the
   union of all of its direct `extends` children. The Java guard derives this
   premise only from the live parser declaration graph. -/
theorem abstract_direct_extension_cover
    {parent left right : Rel α}
    (cover : ∀ atom, parent atom ↔ left atom ∨ right atom) :
    union left right = parent := by
  funext atom
  apply propext
  exact (cover atom).symm

theorem abstract_single_extension_cover
    {parent child : Rel α}
    (cover : ∀ atom, parent atom ↔ child atom) :
    child = parent := by
  funext atom
  apply propext
  exact (cover atom).symm

theorem nested_abstract_extension_cover
    {outer inner left right : Rel α}
    (outerCover : ∀ atom, outer atom ↔ inner atom)
    (innerCover : ∀ atom, inner atom ↔ left atom ∨ right atom) :
    union left right = outer := by
  rw [abstract_direct_extension_cover innerCover]
  exact abstract_single_extension_cover outerCover

theorem complete_abstract_cover_absorbs_subrelation
    {parent left right extra : Rel α}
    (cover : ∀ atom, parent atom ↔ left atom ∨ right atom)
    (extraParent : subset extra parent) :
    union (union left right) extra = parent := by
  rw [abstract_direct_extension_cover cover]
  funext atom
  apply propext
  constructor
  · intro member
    exact member.elim id (extraParent atom)
  · exact Or.inl

/- No union can equal a carrier when one operand has even one member outside
   that carrier. The abstract-cover guard applies this stronger schema after
   the parser declaration graph proposes a candidate carrier. -/
theorem union_with_outside_member_is_not_carrier
    {parent base extra : Rel α}
    {witness : α}
    (extraWitness : extra witness)
    (outsideParent : ¬ parent witness) :
    union base extra ≠ parent := by
  intro alleged
  have unionMember : union base extra witness :=
    Or.inr extraWitness
  have parentMember : parent witness := by
    rw [← alleged]
    exact unionMember
  exact outsideParent parentMember

theorem subset_transitive
    {child parent ancestor : Rel α}
    (childParent : subset child parent)
    (parentAncestor : subset parent ancestor) :
    subset child ancestor := by
  intro atom member
  exact parentAncestor atom (childParent atom member)

theorem subset_of_union_reaches_common_carrier
    {candidate left right carrier : Rel α}
    (candidateParents : subset candidate (union left right))
    (leftCarrier : subset left carrier)
    (rightCarrier : subset right carrier) :
    subset candidate carrier := by
  intro atom member
  exact (candidateParents atom member).elim
    (leftCarrier atom) (rightCarrier atom)

def onlyTrue : Rel Bool := fun atom => atom = true
def onlyFalse : Rel Bool := fun atom => atom = false

theorem subset_of_union_does_not_prove_one_parent :
    subset onlyFalse (union onlyTrue onlyFalse) ∧
      ¬ subset onlyFalse onlyTrue := by
  constructor
  · intro atom member
    exact Or.inr member
  · intro claimed
    have impossible : onlyTrue false := claimed false rfl
    simp [onlyTrue] at impossible

theorem missing_abstract_branch_does_not_cover_parent :
    union onlyTrue (noneRel : Rel Bool) ≠ union onlyTrue onlyFalse := by
  intro claimed
  have parentMember : union onlyTrue onlyFalse false := Or.inr rfl
  have impossible : union onlyTrue (noneRel : Rel Bool) false := by
    rw [claimed]
    exact parentMember
  simp [union, onlyTrue, noneRel] at impossible

def restrictToCarrier (relation carrier : Rel α) : Rel α :=
  fun atom => relation atom ∧ carrier atom

theorem authenticated_relational_widening_preserves_a_subrelation
    {relation carrier : Rel α}
    (admitted : subset relation carrier) :
    restrictToCarrier relation carrier = relation := by
  funext atom
  apply propext
  constructor
  · exact fun member => member.1
  · exact fun member => ⟨member, admitted atom member⟩

theorem subrelation_union_full_carrier_is_carrier
    {relation carrier : Rel α}
    (admitted : subset relation carrier) :
    union relation carrier = carrier := by
  funext atom
  apply propext
  constructor
  · intro member
    exact member.elim (admitted atom) id
  · intro member
    exact Or.inr member

theorem subrelation_intersection_full_carrier_is_subrelation
    {relation carrier : Rel α}
    (admitted : subset relation carrier) :
    intersection relation carrier = relation := by
  funext atom
  apply propext
  constructor
  · exact fun member => member.1
  · exact fun member => ⟨member, admitted atom member⟩

theorem common_static_carrier_does_not_make_a_subrelation_full :
    subset onlyTrue (univRel : Rel Bool) ∧
      subset onlyFalse (univRel : Rel Bool) ∧
      intersection onlyTrue onlyFalse ≠ onlyTrue := by
  constructor
  · exact every_relation_in_univ onlyTrue
  constructor
  · exact every_relation_in_univ onlyFalse
  · intro alleged
    have member : intersection onlyTrue onlyFalse true := by
      rw [alleged]
      rfl
    exact Bool.noConfusion member.2

theorem nested_subsignature_union_carrier_is_carrier
    {leaf carrier ancestor : Rel α}
    (leafCarrier : subset leaf carrier)
    (carrierAncestor : subset carrier ancestor) :
    union leaf carrier = carrier ∧ subset leaf ancestor := by
  exact ⟨subrelation_union_full_carrier_is_carrier leafCarrier,
    subset_transitive leafCarrier carrierAncestor⟩

def relationProduct (left : Rel α) (right : Rel β) : Rel (α × β) :=
  fun tuple => left tuple.1 ∧ right tuple.2

theorem subrelation_intersection_full_product_is_subrelation
    {relation : Rel (α × β)}
    {leftCarrier : Rel α}
    {rightCarrier : Rel β}
    (admitted : subset relation
      (relationProduct leftCarrier rightCarrier)) :
    intersection relation
        (relationProduct leftCarrier rightCarrier) = relation :=
  subrelation_intersection_full_carrier_is_subrelation admitted

theorem relation_product_distributes_over_union_right
    (fixed : Rel α) (left right : Rel β) :
    union (relationProduct fixed left) (relationProduct fixed right) =
      relationProduct fixed (union left right) := by
  funext tuple
  simp [union, relationProduct, and_or_left]

theorem relation_product_distributes_over_union_left
    (left right : Rel α) (fixed : Rel β) :
    union (relationProduct left fixed) (relationProduct right fixed) =
      relationProduct (union left right) fixed := by
  funext tuple
  simp [union, relationProduct, or_and_right]

/- Bound relation slots denote arbitrary relation values at this semantic
   layer; the distribution proof is therefore parametric in every slot. -/
theorem bound_relation_slot_product_distributes_right
    (fixedSlot : Rel α) (leftSlot rightSlot : Rel β) :
    union
        (relationProduct fixedSlot leftSlot)
        (relationProduct fixedSlot rightSlot) =
      relationProduct fixedSlot (union leftSlot rightSlot) := by
  exact relation_product_distributes_over_union_right
    fixedSlot leftSlot rightSlot

theorem bound_relation_slot_product_distributes_left
    (leftSlot rightSlot : Rel α) (fixedSlot : Rel β) :
    union
        (relationProduct leftSlot fixedSlot)
        (relationProduct rightSlot fixedSlot) =
      relationProduct (union leftSlot rightSlot) fixedSlot := by
  exact relation_product_distributes_over_union_left
    leftSlot rightSlot fixedSlot

theorem abstract_cover_lifts_through_product_right
    {parent left right : Rel β}
    (fixed : Rel α)
    (cover : ∀ atom, parent atom ↔ left atom ∨ right atom) :
    union (relationProduct fixed left) (relationProduct fixed right) =
      relationProduct fixed parent := by
  rw [relation_product_distributes_over_union_right]
  rw [abstract_direct_extension_cover cover]

theorem abstract_cover_lifts_through_product_left
    {parent left right : Rel α}
    (fixed : Rel β)
    (cover : ∀ atom, parent atom ↔ left atom ∨ right atom) :
    union (relationProduct left fixed) (relationProduct right fixed) =
      relationProduct parent fixed := by
  rw [relation_product_distributes_over_union_left]
  rw [abstract_direct_extension_cover cover]

theorem abstract_cover_lifts_through_integer_set_coordinate
    {parent left right : Rel α}
    (integers : Rel Int)
    (cover : ∀ atom, parent atom ↔ left atom ∨ right atom) :
    union
        (relationProduct left integers)
        (relationProduct right integers) =
      relationProduct parent integers := by
  exact abstract_cover_lifts_through_product_left integers cover

theorem abstract_cover_lifts_with_integer_first_coordinate
    {parent left right : Rel β}
    (integers : Rel Int)
    (cover : ∀ atom, parent atom ↔ left atom ∨ right atom) :
    union
        (relationProduct integers left)
        (relationProduct integers right) =
      relationProduct integers parent := by
  exact abstract_cover_lifts_through_product_right integers cover

def relationProduct3
    (first : Rel α) (second : Rel β) (third : Rel γ) :
    Rel (α × β × γ) :=
  fun tuple => first tuple.1 ∧ second tuple.2.1 ∧ third tuple.2.2

theorem relation_product3_distributes_over_union_third
    (first : Rel α) (second : Rel β) (left right : Rel γ) :
    union
        (relationProduct3 first second left)
        (relationProduct3 first second right) =
      relationProduct3 first second (union left right) := by
  funext tuple
  simp [union, relationProduct3, and_or_left]

theorem abstract_cover_lifts_through_variadic_product
    {parent left right : Rel γ}
    (first : Rel α)
    (second : Rel β)
    (cover : ∀ atom, parent atom ↔ left atom ∨ right atom) :
    union
        (relationProduct3 first second left)
        (relationProduct3 first second right) =
      relationProduct3 first second parent := by
  rw [relation_product3_distributes_over_union_third]
  rw [abstract_direct_extension_cover cover]

theorem complete_two_coordinate_grid_is_product_of_unions
    (leftA rightA : Rel α) (leftB rightB : Rel β) :
    union
        (union
          (relationProduct leftA leftB)
          (relationProduct leftA rightB))
        (union
          (relationProduct rightA leftB)
          (relationProduct rightA rightB)) =
      relationProduct
        (union leftA rightA)
        (union leftB rightB) := by
  funext tuple
  apply propext
  constructor
  · intro member
    rcases member with (member | member)
    · rcases member with (member | member)
      · exact ⟨Or.inl member.1, Or.inl member.2⟩
      · exact ⟨Or.inl member.1, Or.inr member.2⟩
    · rcases member with (member | member)
      · exact ⟨Or.inr member.1, Or.inl member.2⟩
      · exact ⟨Or.inr member.1, Or.inr member.2⟩
  · intro member
    rcases member with ⟨first, second⟩
    rcases first with (first | first)
    · rcases second with (second | second)
      · exact Or.inl (Or.inl ⟨first, second⟩)
      · exact Or.inl (Or.inr ⟨first, second⟩)
    · rcases second with (second | second)
      · exact Or.inr (Or.inl ⟨first, second⟩)
      · exact Or.inr (Or.inr ⟨first, second⟩)

theorem abstract_covers_lift_through_complete_product_grid
    {parentA leftA rightA : Rel α}
    {parentB leftB rightB : Rel β}
    (coverA : ∀ atom, parentA atom ↔ leftA atom ∨ rightA atom)
    (coverB : ∀ atom, parentB atom ↔ leftB atom ∨ rightB atom) :
    union
        (union
          (relationProduct leftA leftB)
          (relationProduct leftA rightB))
        (union
          (relationProduct rightA leftB)
          (relationProduct rightA rightB)) =
      relationProduct parentA parentB := by
  rw [complete_two_coordinate_grid_is_product_of_unions]
  rw [abstract_direct_extension_cover coverA]
  rw [abstract_direct_extension_cover coverB]

theorem partial_product_grid_does_not_cover_full_product :
    union
        (union
          (relationProduct onlyTrue onlyTrue)
          (relationProduct onlyTrue onlyFalse))
        (relationProduct onlyFalse onlyTrue) ≠
      relationProduct
        (union onlyTrue onlyFalse)
        (union onlyTrue onlyFalse) := by
  intro alleged
  have missingMember :
      union
          (union
            (relationProduct onlyTrue onlyTrue)
            (relationProduct onlyTrue onlyFalse))
          (relationProduct onlyFalse onlyTrue)
          (false, false) := by
    rw [alleged]
    exact ⟨Or.inr rfl, Or.inr rfl⟩
  simp [union, relationProduct, onlyTrue, onlyFalse] at missingMember

theorem diagonal_products_do_not_cover_full_product :
    union
        (relationProduct onlyTrue onlyTrue)
        (relationProduct onlyFalse onlyFalse) ≠
      relationProduct
        (union onlyTrue onlyFalse)
        (union onlyTrue onlyFalse) := by
  intro alleged
  have diagonalMember :
      union
          (relationProduct onlyTrue onlyTrue)
          (relationProduct onlyFalse onlyFalse)
          (true, false) := by
    rw [alleged]
    exact ⟨Or.inl rfl, Or.inr rfl⟩
  simp [union, relationProduct, onlyTrue, onlyFalse] at diagonalMember

theorem empty_relation_product_left (right : Rel β) :
    relationProduct (noneRel : Rel α) right = noneRel := by
  funext tuple
  simp [relationProduct, noneRel]

theorem empty_relation_product_right (left : Rel α) :
    relationProduct left (noneRel : Rel β) = noneRel := by
  funext tuple
  simp [relationProduct, noneRel]

abbrev BinaryRel (α : Type u) (β : Type u) := α → β → Prop

def relationJoin
    (left : BinaryRel α β)
    (right : BinaryRel β γ) : BinaryRel α γ :=
  fun first last => ∃ middle, left first middle ∧ right middle last

def noneBinaryRel : BinaryRel α β := fun _ _ => False

theorem empty_relation_join_left (right : BinaryRel β γ) :
    relationJoin (noneBinaryRel : BinaryRel α β) right = noneBinaryRel := by
  funext first last
  apply propext
  constructor
  · rintro ⟨middle, impossible, _⟩
    exact False.elim impossible
  · intro impossible
    exact False.elim impossible

theorem empty_relation_join_right (left : BinaryRel α β) :
    relationJoin left (noneBinaryRel : BinaryRel β γ) = noneBinaryRel := by
  funext first last
  apply propext
  constructor
  · rintro ⟨middle, _, impossible⟩
    exact False.elim impossible
  · intro impossible
    exact False.elim impossible

theorem two_subrelations_union_full_carrier_is_carrier
    {left right carrier : Rel α}
    (leftAdmitted : subset left carrier)
    (rightAdmitted : subset right carrier) :
    union (union left right) carrier = carrier := by
  apply subrelation_union_full_carrier_is_carrier
  intro atom member
  exact member.elim (leftAdmitted atom) (rightAdmitted atom)

theorem subrelation_absorbs_through_left_association
    {context relation carrier : Rel α}
    (admitted : subset relation carrier) :
    union (union context relation) carrier = union context carrier := by
  calc
    union (union context relation) carrier =
        union context (union relation carrier) :=
      relation_union_associative context relation carrier
    _ = union context carrier := by
      rw [subrelation_union_full_carrier_is_carrier admitted]

theorem subrelation_absorbs_through_right_association
    {context relation carrier : Rel α}
    (admitted : subset relation carrier) :
    union context (union relation carrier) = union context carrier := by
  rw [subrelation_union_full_carrier_is_carrier admitted]

theorem widened_relational_union_flattening
    (left middle right : Rel α) :
    union (union left middle) right = union left (union middle right) :=
  relation_union_associative left middle right

/- A relation-family widening is checked per correlated product alternative.
   Every candidate column carries its parser-authenticated path from the exact
   signature to its ancestors; one carrier product covers the candidate only
   when all columns occur on their corresponding paths. -/
abbrev ProductAncestry := List (List Nat)
abbrev ProductColumns := List Nat

def productCoveredByAncestry
    (candidate : ProductAncestry)
    (carrier : ProductColumns) : Bool :=
  candidate.length == carrier.length &&
    (candidate.zip carrier).all fun pair => pair.1.contains pair.2

def relationFamilyCoveredByAncestry
    (candidates : List ProductAncestry)
    (carriers : List ProductColumns) : Bool :=
  candidates.all fun candidate =>
    carriers.any fun carrier => productCoveredByAncestry candidate carrier

theorem subtype_and_exact_int_alternatives_are_covered :
    relationFamilyCoveredByAncestry
      [[[3]], [[1, 2, 0]]]
      [[3], [2]] = true := by decide

theorem reverse_subtype_widening_is_rejected :
    relationFamilyCoveredByAncestry
      [[[2, 0]]]
      [[1]] = false := by decide

theorem sibling_subtype_widening_is_rejected :
    relationFamilyCoveredByAncestry
      [[[1, 2, 0]]]
      [[4]] = false := by decide

theorem relation_arity_change_is_not_a_widening :
    relationFamilyCoveredByAncestry
      [[[1, 2, 0], [3]]]
      [[2]] = false := by decide

theorem none_intersection_is_none (relation : Rel α) :
    intersection noneRel relation = noneRel := by
  funext atom
  apply propext
  constructor
  · intro member
    exact member.1
  · intro impossible
    exact False.elim impossible

theorem relation_intersection_none_is_none (relation : Rel α) :
    intersection relation noneRel = noneRel := by
  funext atom
  apply propext
  constructor
  · intro member
    exact member.2
  · intro impossible
    exact False.elim impossible

theorem relation_intersection_univ_is_relation (relation : Rel α) :
    intersection relation univRel = relation := by
  funext atom
  simp [intersection, univRel]

theorem relation_intersection_idempotent (relation : Rel α) :
    intersection relation relation = relation := by
  funext atom
  simp [intersection]

theorem relation_intersection_commutative (left right : Rel α) :
    intersection left right = intersection right left := by
  funext atom
  simp [intersection, and_comm]

theorem relation_intersection_associative (left middle right : Rel α) :
    intersection (intersection left middle) right =
      intersection left (intersection middle right) := by
  funext atom
  simp [intersection, and_assoc]

theorem positive_one_over_none_intersection_has_no_binding
    (relation candidate : Rel α) :
    ¬ admits .one (intersection noneRel relation) candidate := by
  rw [none_intersection_is_none]
  exact one_none_has_no_binding candidate

def difference (left right : Rel α) : Rel α :=
  fun atom => left atom ∧ ¬ right atom

theorem subset_none_iff_no_members
    (relation : Rel α) :
    subset relation noneRel ↔ ¬ relNonempty relation := by
  constructor
  · intro contained ⟨atom, member⟩
    exact contained atom member
  · intro empty atom member
    exact empty ⟨atom, member⟩

theorem not_subset_none_iff_some_member
    (relation : Rel α) :
    (¬ subset relation noneRel) ↔ relNonempty relation := by
  classical
  constructor
  · intro notContained
    by_cases nonempty : relNonempty relation
    · exact nonempty
    · exact False.elim (notContained ((subset_none_iff_no_members relation).2 nonempty))
  · rintro ⟨atom, member⟩ contained
    exact contained atom member

theorem subset_union_absorption
    (smaller larger : Rel α)
    (contained : subset smaller larger) :
    union smaller larger = larger := by
  funext atom
  apply propext
  constructor
  · intro member
    exact member.elim (contained atom) id
  · exact Or.inr

theorem subset_intersection_absorption
    (smaller larger : Rel α)
    (contained : subset smaller larger) :
    intersection smaller larger = smaller := by
  funext atom
  apply propext
  constructor
  · exact fun member => member.1
  · intro member
    exact ⟨member, contained atom member⟩

theorem difference_disjoint_from_removed_subrelation
    (kept removed subrelation : Rel α)
    (contained : subset subrelation removed) :
    intersection (difference kept removed) subrelation = noneRel := by
  funext atom
  apply propext
  constructor
  · rintro ⟨⟨_, notRemoved⟩, subMember⟩
    exact notRemoved (contained atom subMember)
  · intro impossible
    exact False.elim impossible

theorem difference_partition_recombines
    (kept removed : Rel α) :
    union (difference kept removed) (intersection kept removed) = kept := by
  funext atom
  apply propext
  by_cases keptMember : kept atom <;>
    by_cases removedMember : removed atom <;>
    simp [difference, union, intersection, keptMember, removedMember]

theorem difference_subrelation_partition_recombines
    (kept removed : Rel α)
    (contained : subset removed kept) :
    union (difference kept removed) removed = kept := by
  funext atom
  apply propext
  constructor
  · intro member
    rcases member with differenceMember | removedMember
    · exact differenceMember.1
    · exact contained atom removedMember
  · intro keptMember
    by_cases removedMember : removed atom
    · exact Or.inr removedMember
    · exact Or.inl ⟨keptMember, removedMember⟩

theorem difference_of_superrelation_is_none
    (kept removed : Rel α)
    (contained : subset kept removed) :
    difference kept removed = noneRel := by
  funext atom
  apply propext
  constructor
  · intro member
    exact member.2 (contained atom member.1)
  · intro impossible
    exact False.elim impossible

theorem difference_intersection_removal
    (kept removed : Rel α) :
    difference kept (intersection kept removed) = difference kept removed := by
  funext atom
  apply propext
  by_cases keptMember : kept atom <;>
    by_cases removedMember : removed atom <;>
    simp [difference, intersection, keptMember, removedMember]

theorem difference_of_difference_restores_intersection
    (kept removed : Rel α) :
    difference kept (difference kept removed) = intersection kept removed := by
  funext atom
  apply propext
  by_cases keptMember : kept atom <;>
    by_cases removedMember : removed atom <;>
    simp [difference, intersection, keptMember, removedMember]

theorem no_difference_iff_subset
    (kept removed : Rel α) :
    (¬ relNonempty (difference kept removed)) ↔ subset kept removed := by
  classical
  constructor
  · intro noDifference atom keptMember
    apply Classical.byContradiction
    intro removedAbsent
    exact noDifference ⟨atom, keptMember, removedAbsent⟩
  · intro contained witness
    rcases witness with ⟨atom, keptMember, removedAbsent⟩
    exact removedAbsent (contained atom keptMember)

theorem some_difference_iff_not_subset
    (kept removed : Rel α) :
    relNonempty (difference kept removed) ↔ ¬ subset kept removed := by
  classical
  constructor
  · rintro ⟨atom, keptMember, removedAbsent⟩ contained
    exact removedAbsent (contained atom keptMember)
  · intro notContained
    by_cases nonempty : relNonempty (difference kept removed)
    · exact nonempty
    · exact False.elim (notContained ((no_difference_iff_subset kept removed).1 nonempty))

/- Exact semantics of the single-membership quantified-formula eliminator. -/

def singletonRel (value : α) : Rel α := fun candidate => candidate = value

theorem singleton_subset
    (domain : Rel α) (value : α) (member : domain value) :
    subset (singletonRel value) domain := by
  intro candidate equal
  rw [show candidate = value from equal]
  exact member

theorem singleton_at_most_one (value : α) :
    atMostOne (singletonRel value) := by
  intro left right leftEqual rightEqual
  simpa [singletonRel] using leftEqual.trans rightEqual.symm

theorem singleton_exactly_one (value : α) :
    exactlyOne (singletonRel value) := by
  exact ⟨⟨value, rfl⟩, singleton_at_most_one value⟩

theorem singleton_admitted_for_every_nonexact_multiplicity
    (multiplicity : Multiplicity)
    (domain : Rel α)
    (value : α)
    (member : domain value)
    (nonexact : multiplicity ≠ .exactly) :
    admits multiplicity domain (singletonRel value) := by
  cases multiplicity with
  | set => exact ⟨singleton_subset domain value member, True.intro⟩
  | lone => exact ⟨singleton_subset domain value member,
      singleton_at_most_one value⟩
  | some => exact ⟨singleton_subset domain value member, ⟨value, rfl⟩⟩
  | one => exact ⟨singleton_subset domain value member,
      singleton_exactly_one value⟩
  | exactly => exact False.elim (nonexact rfl)

theorem admitted_nonexact_implies_subset
    (multiplicity : Multiplicity)
    (domain candidate : Rel α)
    (admitted : admits multiplicity domain candidate)
    (nonexact : multiplicity ≠ .exactly) :
    subset candidate domain := by
  cases multiplicity with
  | set => exact admitted.1
  | lone => exact admitted.1
  | some => exact admitted.1
  | one => exact admitted.1
  | exactly => exact False.elim (nonexact rfl)

theorem empty_relation_admitted_by_set (domain : Rel α) :
    admits .set domain noneRel := by
  exact ⟨none_subset domain, True.intro⟩

theorem empty_relation_admitted_by_lone (domain : Rel α) :
    admits .lone domain noneRel := by
  exact ⟨none_subset domain, empty_at_most_one⟩

theorem all_admitted_positive_membership_iff_domain_subset
    (multiplicity : Multiplicity)
    (domain target : Rel α)
    (nonexact : multiplicity ≠ .exactly) :
    (∀ candidate, admits multiplicity domain candidate →
      subset candidate target) ↔ subset domain target := by
  constructor
  · intro allCandidates atom domainMember
    have admitted := singleton_admitted_for_every_nonexact_multiplicity
      multiplicity domain atom domainMember nonexact
    exact allCandidates (singletonRel atom) admitted atom rfl
  · intro domainSubset candidate admitted atom candidateMember
    exact domainSubset atom ((admitted_nonexact_implies_subset
      multiplicity domain candidate admitted nonexact) atom candidateMember)

theorem some_set_positive_membership_is_true
    (domain target : Rel α) :
    ∃ candidate, admits .set domain candidate ∧ subset candidate target := by
  exact ⟨noneRel, empty_relation_admitted_by_set domain, none_subset target⟩

theorem some_lone_positive_membership_is_true
    (domain target : Rel α) :
    ∃ candidate, admits .lone domain candidate ∧ subset candidate target := by
  exact ⟨noneRel, empty_relation_admitted_by_lone domain, none_subset target⟩

theorem some_some_positive_membership_iff_intersection_nonempty
    (domain target : Rel α) :
    (∃ candidate, admits .some domain candidate ∧ subset candidate target) ↔
      relNonempty (intersection domain target) := by
  constructor
  · rintro ⟨candidate, admitted, contained⟩
    rcases admitted.2 with ⟨atom, member⟩
    exact ⟨atom, admitted.1 atom member, contained atom member⟩
  · rintro ⟨atom, domainMember, targetMember⟩
    exact ⟨singletonRel atom,
      singleton_admitted_for_every_nonexact_multiplicity
        .some domain atom domainMember (by decide),
      singleton_subset target atom targetMember⟩

theorem some_one_positive_membership_iff_intersection_nonempty
    (domain target : Rel α) :
    (∃ candidate, admits .one domain candidate ∧ subset candidate target) ↔
      relNonempty (intersection domain target) := by
  constructor
  · rintro ⟨candidate, admitted, contained⟩
    rcases admitted.2.1 with ⟨atom, member⟩
    exact ⟨atom, admitted.1 atom member, contained atom member⟩
  · rintro ⟨atom, domainMember, targetMember⟩
    exact ⟨singletonRel atom,
      singleton_admitted_for_every_nonexact_multiplicity
        .one domain atom domainMember (by decide),
      singleton_subset target atom targetMember⟩

theorem no_set_positive_membership_is_false
    (domain target : Rel α) :
    ¬ (¬ ∃ candidate,
      admits .set domain candidate ∧ subset candidate target) := by
  intro absent
  exact absent (some_set_positive_membership_is_true domain target)

theorem no_lone_positive_membership_is_false
    (domain target : Rel α) :
    ¬ (¬ ∃ candidate,
      admits .lone domain candidate ∧ subset candidate target) := by
  intro absent
  exact absent (some_lone_positive_membership_is_true domain target)

theorem no_some_positive_membership_iff_intersection_empty
    (domain target : Rel α) :
    (¬ ∃ candidate, admits .some domain candidate ∧
      subset candidate target) ↔
      ¬ relNonempty (intersection domain target) := by
  rw [some_some_positive_membership_iff_intersection_nonempty]

theorem no_one_positive_membership_iff_intersection_empty
    (domain target : Rel α) :
    (¬ ∃ candidate, admits .one domain candidate ∧
      subset candidate target) ↔
      ¬ relNonempty (intersection domain target) := by
  rw [some_one_positive_membership_iff_intersection_nonempty]

theorem no_negative_membership_iff_domain_subset
    (multiplicity : Multiplicity)
    (domain target : Rel α)
    (nonexact : multiplicity ≠ .exactly) :
    (¬ ∃ candidate, admits multiplicity domain candidate ∧
      ¬ subset candidate target) ↔ subset domain target := by
  classical
  constructor
  · intro noCounterexample atom domainMember
    apply Classical.byContradiction
    intro targetAbsent
    have admitted := singleton_admitted_for_every_nonexact_multiplicity
      multiplicity domain atom domainMember nonexact
    have notContained : ¬ subset (singletonRel atom) target := by
      intro contained
      exact targetAbsent (contained atom rfl)
    exact noCounterexample ⟨singletonRel atom, admitted, notContained⟩
  · intro domainSubset ⟨candidate, admitted, notContained⟩
    exact notContained (fun atom member =>
      domainSubset atom ((admitted_nonexact_implies_subset
        multiplicity domain candidate admitted nonexact) atom member))

theorem some_negative_membership_iff_difference_nonempty
    (multiplicity : Multiplicity)
    (domain target : Rel α)
    (nonexact : multiplicity ≠ .exactly) :
    (∃ candidate, admits multiplicity domain candidate ∧
      ¬ subset candidate target) ↔
      relNonempty (difference domain target) := by
  classical
  constructor
  · rintro ⟨candidate, admitted, notContained⟩
    by_cases witness : relNonempty (difference domain target)
    · exact witness
    · have domainSubset : subset domain target :=
        (no_difference_iff_subset domain target).1 witness
      exact False.elim (notContained (fun atom member =>
        domainSubset atom ((admitted_nonexact_implies_subset
          multiplicity domain candidate admitted nonexact) atom member)))
  · rintro ⟨atom, domainMember, targetAbsent⟩
    have admitted := singleton_admitted_for_every_nonexact_multiplicity
      multiplicity domain atom domainMember nonexact
    have notContained : ¬ subset (singletonRel atom) target := by
      intro contained
      exact targetAbsent (contained atom rfl)
    exact ⟨singletonRel atom, admitted, notContained⟩

theorem all_set_negative_membership_is_false
    (domain target : Rel α) :
    ¬ (∀ candidate, admits .set domain candidate →
      ¬ subset candidate target) := by
  intro allCandidates
  exact allCandidates noneRel (empty_relation_admitted_by_set domain)
    (none_subset target)

theorem all_lone_negative_membership_is_false
    (domain target : Rel α) :
    ¬ (∀ candidate, admits .lone domain candidate →
      ¬ subset candidate target) := by
  intro allCandidates
  exact allCandidates noneRel (empty_relation_admitted_by_lone domain)
    (none_subset target)

theorem all_some_negative_membership_iff_intersection_empty
    (domain target : Rel α) :
    (∀ candidate, admits .some domain candidate →
      ¬ subset candidate target) ↔
      ¬ relNonempty (intersection domain target) := by
  classical
  constructor
  · intro allCandidates ⟨atom, domainMember, targetMember⟩
    have admitted := singleton_admitted_for_every_nonexact_multiplicity
      .some domain atom domainMember (by decide)
    exact allCandidates (singletonRel atom) admitted
      (singleton_subset target atom targetMember)
  · intro emptyIntersection candidate admitted contained
    rcases admitted.2 with ⟨atom, member⟩
    exact emptyIntersection ⟨atom, admitted.1 atom member, contained atom member⟩

theorem all_one_negative_membership_iff_intersection_empty
    (domain target : Rel α) :
    (∀ candidate, admits .one domain candidate →
      ¬ subset candidate target) ↔
      ¬ relNonempty (intersection domain target) := by
  classical
  constructor
  · intro allCandidates ⟨atom, domainMember, targetMember⟩
    have admitted := singleton_admitted_for_every_nonexact_multiplicity
      .one domain atom domainMember (by decide)
    exact allCandidates (singletonRel atom) admitted
      (singleton_subset target atom targetMember)
  · intro emptyIntersection candidate admitted contained
    rcases admitted.2.1 with ⟨atom, member⟩
    exact emptyIntersection ⟨atom, admitted.1 atom member, contained atom member⟩

theorem subset_union_left (left right : Rel α) :
    subset left (union left right) := by
  intro atom member
  exact Or.inl member

theorem intersection_subset_left (left right : Rel α) :
    subset (intersection left right) left := by
  intro atom member
  exact member.1

theorem difference_subset_left (left right : Rel α) :
    subset (difference left right) left := by
  intro atom member
  exact member.1

theorem union_subset_iff
    (left right target : Rel α) :
    subset (union left right) target ↔
      subset left target ∧ subset right target := by
  constructor
  · intro contained
    constructor
    · intro atom member
      exact contained atom (Or.inl member)
    · intro atom member
      exact contained atom (Or.inr member)
  · rintro ⟨leftContained, rightContained⟩ atom (member | member)
    · exact leftContained atom member
    · exact rightContained atom member

theorem subset_intersection_iff
    (source left right : Rel α) :
    subset source (intersection left right) ↔
      subset source left ∧ subset source right := by
  constructor
  · intro contained
    constructor
    · intro atom member
      exact (contained atom member).1
    · intro atom member
      exact (contained atom member).2
  · rintro ⟨leftContained, rightContained⟩ atom member
    exact ⟨leftContained atom member, rightContained atom member⟩

theorem union_not_subset_iff
    (left right target : Rel α) :
    (¬ subset (union left right) target) ↔
      (¬ subset left target) ∨ (¬ subset right target) := by
  constructor
  · intro notContained
    by_cases leftContained : subset left target
    · right
      intro rightContained
      exact notContained ((union_subset_iff left right target).2
        ⟨leftContained, rightContained⟩)
    · exact Or.inl leftContained
  · intro branch contained
    have components := (union_subset_iff left right target).1 contained
    exact branch.elim (· components.1) (· components.2)

theorem not_subset_intersection_iff
    (source left right : Rel α) :
    (¬ subset source (intersection left right)) ↔
      (¬ subset source left) ∨ (¬ subset source right) := by
  constructor
  · intro notContained
    by_cases leftContained : subset source left
    · right
      intro rightContained
      exact notContained ((subset_intersection_iff source left right).2
        ⟨leftContained, rightContained⟩)
    · exact Or.inl leftContained
  · intro branch contained
    have components := (subset_intersection_iff source left right).1 contained
    exact branch.elim (· components.1) (· components.2)

theorem union3_subset_iff
    (first second third target : Rel α) :
    subset (union (union first second) third) target ↔
      subset first target ∧ subset second target ∧ subset third target := by
  rw [union_subset_iff, union_subset_iff]
  exact and_assoc

theorem subset_intersection3_iff
    (source first second third : Rel α) :
    subset source (intersection (intersection first second) third) ↔
      subset source first ∧ subset source second ∧ subset source third := by
  rw [subset_intersection_iff, subset_intersection_iff]
  exact and_assoc

theorem subset_union_does_not_split_disjunctively :
    subset (@univRel Bool) (union onlyTrue onlyFalse) ∧
      ¬ (subset (@univRel Bool) onlyTrue ∨
        subset (@univRel Bool) onlyFalse) := by
  constructor
  · intro atom _
    cases atom <;> simp [union, onlyTrue, onlyFalse]
  · rintro (allTrue | allFalse)
    · have impossible := allTrue false True.intro
      simp [onlyTrue] at impossible
    · have impossible := allFalse true True.intro
      simp [onlyFalse] at impossible

/- Repeated subtraction accumulates every removed relation by union. Applying
   this binary schema from the innermost left branch normalizes a finite
   left-nested chain without granting the unsound right-nested reassociation. -/
theorem left_nested_difference_accumulates_union
    (kept firstRemoved secondRemoved : Rel α) :
    difference (difference kept firstRemoved) secondRemoved =
      difference kept (union firstRemoved secondRemoved) := by
  funext atom
  apply propext
  by_cases keptMember : kept atom <;>
    by_cases firstMember : firstRemoved atom <;>
    by_cases secondMember : secondRemoved atom <;>
    simp [difference, union, keptMember, firstMember, secondMember]

theorem right_nested_difference_is_not_left_nested :
    difference (difference (@univRel Bool) univRel) univRel ≠
      difference univRel (difference univRel univRel) := by
  intro equality
  have witness := congrFun equality true
  simp [difference, univRel] at witness

theorem right_nested_difference_expands
    (kept removed restored : Rel α) :
    difference kept (difference removed restored) =
      union (difference kept removed) (intersection kept restored) := by
  funext atom
  apply propext
  by_cases keptMember : kept atom <;>
    by_cases removedMember : removed atom <;>
    by_cases restoredMember : restored atom <;>
    simp [difference, union, intersection,
      keptMember, removedMember, restoredMember]

theorem intersection_extracts_difference
    (kept removed other : Rel α) :
    intersection (difference kept removed) other =
      difference (intersection kept other) removed := by
  funext atom
  apply propext
  by_cases keptMember : kept atom <;>
    by_cases removedMember : removed atom <;>
    by_cases otherMember : other atom <;>
    simp [difference, intersection,
      keptMember, removedMember, otherMember]

theorem intersection_of_differences_accumulates_removed
    (leftKept leftRemoved rightKept rightRemoved : Rel α) :
    intersection (difference leftKept leftRemoved)
        (difference rightKept rightRemoved) =
      difference (intersection leftKept rightKept)
        (union leftRemoved rightRemoved) := by
  funext atom
  apply propext
  by_cases leftKeptMember : leftKept atom <;>
    by_cases leftRemovedMember : leftRemoved atom <;>
    by_cases rightKeptMember : rightKept atom <;>
    by_cases rightRemovedMember : rightRemoved atom <;>
    simp [difference, intersection, union,
      leftKeptMember, leftRemovedMember,
      rightKeptMember, rightRemovedMember]

theorem intersection_of_three_differences_accumulates_removed
    (firstKept firstRemoved secondKept secondRemoved
      thirdKept thirdRemoved : Rel α) :
    intersection
        (intersection
          (difference firstKept firstRemoved)
          (difference secondKept secondRemoved))
        (difference thirdKept thirdRemoved) =
      difference
        (intersection (intersection firstKept secondKept) thirdKept)
        (union (union firstRemoved secondRemoved) thirdRemoved) := by
  funext atom
  apply propext
  by_cases firstKeptMember : firstKept atom <;>
    by_cases firstRemovedMember : firstRemoved atom <;>
    by_cases secondKeptMember : secondKept atom <;>
    by_cases secondRemovedMember : secondRemoved atom <;>
    by_cases thirdKeptMember : thirdKept atom <;>
    by_cases thirdRemovedMember : thirdRemoved atom <;>
    simp [difference, intersection, union,
      firstKeptMember, firstRemovedMember,
      secondKeptMember, secondRemovedMember,
      thirdKeptMember, thirdRemovedMember]

theorem relation_product_difference_left_coordinate
    (left right : Rel α) (fixed : Rel β) :
    difference
        (relationProduct left fixed)
        (relationProduct right fixed) =
      relationProduct (difference left right) fixed := by
  funext tuple
  apply propext
  by_cases leftMember : left tuple.1 <;>
    by_cases rightMember : right tuple.1 <;>
    by_cases fixedMember : fixed tuple.2 <;>
    simp [difference, relationProduct,
      leftMember, rightMember, fixedMember]

theorem relation_product_difference_right_coordinate
    (fixed : Rel α) (left right : Rel β) :
    difference
        (relationProduct fixed left)
        (relationProduct fixed right) =
      relationProduct fixed (difference left right) := by
  funext tuple
  apply propext
  by_cases fixedMember : fixed tuple.1 <;>
    by_cases leftMember : left tuple.2 <;>
    by_cases rightMember : right tuple.2 <;>
    simp [difference, relationProduct,
      fixedMember, leftMember, rightMember]

theorem relation_product3_difference_middle_coordinate
    (first : Rel α) (left right : Rel β) (third : Rel γ) :
    difference
        (relationProduct3 first left third)
        (relationProduct3 first right third) =
      relationProduct3 first (difference left right) third := by
  funext tuple
  apply propext
  by_cases firstMember : first tuple.1 <;>
    by_cases leftMember : left tuple.2.1 <;>
    by_cases rightMember : right tuple.2.1 <;>
    by_cases thirdMember : third tuple.2.2 <;>
    simp [difference, relationProduct3,
      firstMember, leftMember, rightMember, thirdMember]

/- Cartesian-product intersection is coordinatewise. Every source product
   contributes one conjunct to every output coordinate; unlike union, no
   complete cross-product grid premise is needed. -/
theorem relation_product_intersection_coordinatewise
    (leftFirst rightFirst : Rel α)
    (leftSecond rightSecond : Rel β) :
    intersection
        (relationProduct leftFirst leftSecond)
        (relationProduct rightFirst rightSecond) =
      relationProduct
        (intersection leftFirst rightFirst)
        (intersection leftSecond rightSecond) := by
  funext tuple
  simp [intersection, relationProduct, and_left_comm, and_comm]

theorem three_relation_products_intersect_coordinatewise
    (firstA secondA thirdA : Rel α)
    (firstB secondB thirdB : Rel β) :
    intersection
        (intersection
          (relationProduct firstA firstB)
          (relationProduct secondA secondB))
        (relationProduct thirdA thirdB) =
      relationProduct
        (intersection (intersection firstA secondA) thirdA)
        (intersection (intersection firstB secondB) thirdB) := by
  funext tuple
  simp [intersection, relationProduct, and_left_comm, and_comm]

theorem relation_product3_intersection_coordinatewise
    (leftFirst rightFirst : Rel α)
    (leftSecond rightSecond : Rel β)
    (leftThird rightThird : Rel γ) :
    intersection
        (relationProduct3 leftFirst leftSecond leftThird)
        (relationProduct3 rightFirst rightSecond rightThird) =
      relationProduct3
        (intersection leftFirst rightFirst)
        (intersection leftSecond rightSecond)
        (intersection leftThird rightThird) := by
  funext tuple
  simp [intersection, relationProduct3, and_left_comm, and_comm]

theorem relation_product_respects_certified_operand_equalities
    {left normalizedLeft : Rel α}
    {right normalizedRight : Rel β}
    (leftProof : left = normalizedLeft)
    (rightProof : right = normalizedRight) :
    relationProduct left right =
      relationProduct normalizedLeft normalizedRight := by
  rw [leftProof, rightProof]

theorem relation_join_respects_certified_operand_equalities
    {left normalizedLeft : BinaryRel α β}
    {right normalizedRight : BinaryRel β γ}
    (leftProof : left = normalizedLeft)
    (rightProof : right = normalizedRight) :
    relationJoin left right =
      relationJoin normalizedLeft normalizedRight := by
  rw [leftProof, rightProof]

theorem two_coordinate_product_difference_does_not_factor :
    difference
        (relationProduct (@univRel Bool) univRel)
        (relationProduct onlyTrue onlyTrue) ≠
      relationProduct
        (difference univRel onlyTrue)
        (difference univRel onlyTrue) := by
  intro alleged
  have witness := congrFun alleged (true, false)
  simp [difference, relationProduct, univRel, onlyTrue] at witness

/- The source normalizer orients these four pointwise Boolean identities
   toward one occurrence of the common relation.  They are independent of
   finiteness and therefore apply to every Alloy relation of one fixed arity. -/
theorem difference_union_common_right
    (left right removed : Rel α) :
    union (difference left removed) (difference right removed) =
      difference (union left right) removed := by
  funext atom
  apply propext
  by_cases leftMember : left atom <;>
    by_cases rightMember : right atom <;>
    by_cases removedMember : removed atom <;>
    simp [union, difference, leftMember, rightMember, removedMember]

theorem difference_intersection_common_right
    (left right removed : Rel α) :
    intersection (difference left removed) (difference right removed) =
      difference (intersection left right) removed := by
  funext atom
  apply propext
  by_cases leftMember : left atom <;>
    by_cases rightMember : right atom <;>
    by_cases removedMember : removed atom <;>
    simp [intersection, difference, leftMember, rightMember, removedMember]

theorem difference_intersection_common_left
    (kept leftRemoved rightRemoved : Rel α) :
    intersection (difference kept leftRemoved)
        (difference kept rightRemoved) =
      difference kept (union leftRemoved rightRemoved) := by
  funext atom
  apply propext
  by_cases keptMember : kept atom <;>
    by_cases leftMember : leftRemoved atom <;>
    by_cases rightMember : rightRemoved atom <;>
    simp [intersection, union, difference,
      keptMember, leftMember, rightMember]

theorem difference_union_common_left
    (kept leftRemoved rightRemoved : Rel α) :
    union (difference kept leftRemoved)
        (difference kept rightRemoved) =
      difference kept (intersection leftRemoved rightRemoved) := by
  funext atom
  apply propext
  by_cases keptMember : kept atom <;>
    by_cases leftMember : leftRemoved atom <;>
    by_cases rightMember : rightRemoved atom <;>
    simp [intersection, union, difference,
      keptMember, leftMember, rightMember]

def binaryUnion
    (left right : BinaryRel α β) : BinaryRel α β :=
  fun first last => left first last ∨ right first last

theorem relation_join_distributes_over_union_right
    (left : BinaryRel α β)
    (rightFirst rightSecond : BinaryRel β γ) :
    relationJoin left (binaryUnion rightFirst rightSecond) =
      binaryUnion (relationJoin left rightFirst)
        (relationJoin left rightSecond) := by
  funext first last
  apply propext
  constructor
  · rintro ⟨middle, leftMember, rightMember | rightMember⟩
    · exact Or.inl ⟨middle, leftMember, rightMember⟩
    · exact Or.inr ⟨middle, leftMember, rightMember⟩
  · rintro (⟨middle, leftMember, rightMember⟩ |
      ⟨middle, leftMember, rightMember⟩)
    · exact ⟨middle, leftMember, Or.inl rightMember⟩
    · exact ⟨middle, leftMember, Or.inr rightMember⟩

theorem relation_join_distributes_over_union_left
    (leftFirst leftSecond : BinaryRel α β)
    (right : BinaryRel β γ) :
    relationJoin (binaryUnion leftFirst leftSecond) right =
      binaryUnion (relationJoin leftFirst right)
        (relationJoin leftSecond right) := by
  funext first last
  apply propext
  constructor
  · rintro ⟨middle, leftMember | leftMember, rightMember⟩
    · exact Or.inl ⟨middle, leftMember, rightMember⟩
    · exact Or.inr ⟨middle, leftMember, rightMember⟩
  · rintro (⟨middle, leftMember, rightMember⟩ |
      ⟨middle, leftMember, rightMember⟩)
    · exact ⟨middle, Or.inl leftMember, rightMember⟩
    · exact ⟨middle, Or.inr leftMember, rightMember⟩

theorem nonempty_union_iff
    (left right : Rel α) :
    relNonempty (union left right) ↔
      relNonempty left ∨ relNonempty right := by
  constructor
  · rintro ⟨atom, leftMember | rightMember⟩
    · exact Or.inl ⟨atom, leftMember⟩
    · exact Or.inr ⟨atom, rightMember⟩
  · rintro (⟨atom, member⟩ | ⟨atom, member⟩)
    · exact ⟨atom, Or.inl member⟩
    · exact ⟨atom, Or.inr member⟩

theorem no_union_iff
    (left right : Rel α) :
    (¬ relNonempty (union left right)) ↔
      (¬ relNonempty left ∧ ¬ relNonempty right) := by
  constructor
  · intro noUnion
    exact ⟨
      fun ⟨atom, member⟩ => noUnion ⟨atom, Or.inl member⟩,
      fun ⟨atom, member⟩ => noUnion ⟨atom, Or.inr member⟩⟩
  · rintro ⟨noLeft, noRight⟩ ⟨atom, leftMember | rightMember⟩
    · exact noLeft ⟨atom, leftMember⟩
    · exact noRight ⟨atom, rightMember⟩

/- A covered dual branch may have arbitrary finite arity.  Extra operands in
   the outer disjunction/conjunction cannot invalidate the absorbing result. -/
def anyProposition : List Prop → Prop
  | [] => False
  | proposition :: rest => proposition ∨ anyProposition rest

def allPropositions : List Prop → Prop
  | [] => True
  | proposition :: rest => proposition ∧ allPropositions rest

def allNegated : List Prop → Prop
  | [] => True
  | proposition :: rest => ¬ proposition ∧ allNegated rest

def anyNegated : List Prop → Prop
  | [] => False
  | proposition :: rest => ¬ proposition ∨ anyNegated rest

theorem any_proposition_or_all_negated (propositions : List Prop) :
    anyProposition propositions ∨ allNegated propositions := by
  induction propositions with
  | nil => exact Or.inr True.intro
  | cons proposition rest inductionHypothesis =>
      by_cases member : proposition
      · exact Or.inl (Or.inl member)
      · rcases inductionHypothesis with anyRest | allRest
        · exact Or.inl (Or.inr anyRest)
        · exact Or.inr ⟨member, allRest⟩

theorem all_propositions_excludes_any_negated
    (propositions : List Prop) :
    allPropositions propositions → ¬ anyNegated propositions := by
  induction propositions with
  | nil => simp [allPropositions, anyNegated]
  | cons proposition rest inductionHypothesis =>
      rintro ⟨member, allRest⟩ (notMember | anyRest)
      · exact notMember member
      · exact (inductionHypothesis allRest) anyRest

theorem covered_dual_disjunction_with_extra_is_true
    (extra : Prop) (propositions : List Prop) :
    extra ∨ anyProposition propositions ∨ allNegated propositions := by
  rcases any_proposition_or_all_negated propositions with any | all
  · exact Or.inr (Or.inl any)
  · exact Or.inr (Or.inr all)

theorem covered_dual_conjunction_with_extra_is_false
    (extra : Prop) (propositions : List Prop) :
    ¬ (extra ∧ allPropositions propositions ∧ anyNegated propositions) := by
  rintro ⟨_, all, any⟩
  exact (all_propositions_excludes_any_negated propositions all) any

/- Quantifier-slot carrier identity includes exact relation arity.  Equal
   primitive column names cannot collapse unary and binary relation binders. -/
structure BindingRelationProfile where
  columns : List Nat
  deriving DecidableEq, Repr

def bindingRelationArity (profile : BindingRelationProfile) : Nat :=
  profile.columns.length

theorem unary_and_binary_binding_profiles_are_distinct
    (unaryColumn binaryLeft binaryRight : Nat) :
    BindingRelationProfile.mk [unaryColumn] ≠
      BindingRelationProfile.mk [binaryLeft, binaryRight] := by
  intro alleged
  have sameArity := congrArg bindingRelationArity alleged
  simp [bindingRelationArity] at sameArity

theorem converse_distributes_over_difference
    (left right : Rel (α × β)) :
    converse (difference left right) =
      difference (converse left) (converse right) := by
  funext tuple
  rfl

theorem relation_difference_itself_is_none (relation : Rel α) :
    difference relation relation = noneRel := by
  funext atom
  apply propext
  constructor
  · intro member
    exact False.elim (member.2 member.1)
  · intro impossible
    exact False.elim impossible

theorem equivalent_relations_difference_is_none
    {left right : Rel α}
    (equivalent : left = right) :
    difference left right = noneRel := by
  rw [equivalent]
  exact relation_difference_itself_is_none right

theorem none_difference_is_none (relation : Rel α) :
    difference noneRel relation = noneRel := by
  funext atom
  apply propext
  constructor
  · intro member
    exact member.1
  · intro impossible
    exact False.elim impossible

theorem relation_difference_none_is_relation (relation : Rel α) :
    difference relation noneRel = relation := by
  funext atom
  simp [difference, noneRel]

theorem relation_difference_univ_is_none (relation : Rel α) :
    difference relation univRel = noneRel := by
  funext atom
  simp [difference, univRel, noneRel]

theorem positive_one_over_self_difference_has_no_binding
    (relation candidate : Rel α) :
    ¬ admits .one (difference relation relation) candidate := by
  rw [relation_difference_itself_is_none]
  exact one_none_has_no_binding candidate

theorem positive_one_over_none_difference_has_no_binding
    (relation candidate : Rel α) :
    ¬ admits .one (difference noneRel relation) candidate := by
  rw [none_difference_is_none]
  exact one_none_has_no_binding candidate

theorem boolean_complement_or_is_true (proposition : Prop) :
    proposition ∨ ¬ proposition := Classical.em proposition

theorem boolean_complement_and_is_false (proposition : Prop) :
    ¬ (proposition ∧ ¬ proposition) := by
  intro contradiction
  exact contradiction.2 contradiction.1

theorem equivalent_boolean_complement_or_is_true
    (left right : Prop)
    (equivalent : left ↔ right) :
    left ∨ ¬ right := by
  rw [equivalent]
  exact Classical.em right

theorem equivalent_boolean_complement_and_is_false
    (left right : Prop)
    (equivalent : left ↔ right) :
    ¬ (left ∧ ¬ right) := by
  rw [equivalent]
  exact boolean_complement_and_is_false right

structure SourceRewriteSnapshot (α : Type) where
  certified : α
  fast : α
  deriving DecidableEq, Repr

def snapshotAfterSourceRewrite (value : α) : SourceRewriteSnapshot α :=
  { certified := value, fast := value }

theorem source_rewrite_before_snapshot_agrees (value : α) :
    (snapshotAfterSourceRewrite value).certified =
      (snapshotAfterSourceRewrite value).fast := rfl

inductive Evidence where
  | authenticatedBinding (multiplicity : Multiplicity)
  | univWithoutInhabitantWitness
  | syntheticOpcodeLabel (label : String)
  | absent
  deriving Repr

def evidenceProvesNonempty : Evidence → Bool
  | .authenticatedBinding .some => true
  | .authenticatedBinding .one => true
  | _ => false

theorem set_binding_does_not_prove_nonempty :
    evidenceProvesNonempty (.authenticatedBinding .set) = false := rfl
theorem lone_binding_does_not_prove_nonempty :
    evidenceProvesNonempty (.authenticatedBinding .lone) = false := rfl
theorem some_binding_proves_nonempty :
    evidenceProvesNonempty (.authenticatedBinding .some) = true := rfl
theorem one_binding_proves_nonempty :
    evidenceProvesNonempty (.authenticatedBinding .one) = true := rfl
theorem exactly_binding_does_not_prove_nonempty :
    evidenceProvesNonempty (.authenticatedBinding .exactly) = false := rfl
theorem univ_without_inhabitant_witness_does_not_prove_nonempty :
    evidenceProvesNonempty .univWithoutInhabitantWitness = false := rfl
theorem synthetic_label_never_proves_nonempty (label : String) :
    evidenceProvesNonempty (.syntheticOpcodeLabel label) = false := rfl

inductive AbstractRelation where
  | none
  | univ
  | provenNonempty
  | unknown
  deriving DecidableEq, Repr

inductive GuardResult where
  | truth
  | falsehood
  | unreduced
  deriving DecidableEq, Repr

def subsetGuard : AbstractRelation → AbstractRelation → GuardResult
  | .none, .none => .truth
  | _, .univ => .truth
  | .provenNonempty, .none => .falsehood
  | _, _ => .unreduced

def notSubsetGuard : AbstractRelation → AbstractRelation → GuardResult
  | .none, .none => .falsehood
  | _, .univ => .falsehood
  | .provenNonempty, .none => .truth
  | _, _ => .unreduced

theorem in_unknown_none_stays_guarded :
    subsetGuard .unknown .none = .unreduced := rfl
theorem in_univ_none_without_inhabitant_stays_guarded :
    subsetGuard .univ .none = .unreduced := rfl
theorem in_none_none_folds_true :
    subsetGuard .none .none = .truth := rfl
theorem in_proven_nonempty_none_folds_false :
    subsetGuard .provenNonempty .none = .falsehood := rfl
theorem not_in_unknown_none_stays_guarded :
    notSubsetGuard .unknown .none = .unreduced := rfl
theorem not_in_univ_none_without_inhabitant_stays_guarded :
    notSubsetGuard .univ .none = .unreduced := rfl
theorem not_in_none_none_folds_false :
    notSubsetGuard .none .none = .falsehood := rfl
theorem not_in_proven_nonempty_none_folds_true :
    notSubsetGuard .provenNonempty .none = .truth := rfl

structure GuardedSnapshot where
  fast : GuardResult
  certified : GuardResult
  deriving DecidableEq, Repr

def snapshotAfterGuard (result : GuardResult) : GuardedSnapshot :=
  { fast := result, certified := result }

theorem snapshot_after_guard_agrees (result : GuardResult) :
    (snapshotAfterGuard result).fast = (snapshotAfterGuard result).certified := rfl

def fastGuardFromEvidence (evidence : Evidence) : GuardResult :=
  if evidenceProvesNonempty evidence then .falsehood else .unreduced

/- The baseline rewrite model erases declaration evidence before guarding. -/
def ablationGuardWithoutBindingContext : GuardResult := .unreduced

theorem ablation_mirror_counterexample_for_one_binding :
    fastGuardFromEvidence (.authenticatedBinding .one) ≠
      ablationGuardWithoutBindingContext := by
  decide

theorem ablation_mirror_counterexample_for_some_binding :
    fastGuardFromEvidence (.authenticatedBinding .some) ≠
      ablationGuardWithoutBindingContext := by
  decide

inductive ExistingTraceKind where
  | insertFresh
  | insertCollision
  | union
  | addSymmetry
  | restrictInterface
  | pathCompression
  | rebuildRecord
  | rebuildComplete
  deriving DecidableEq, Repr

def recordsSourceRewrite : ExistingTraceKind → Bool
  | _ => false

theorem existing_trace_kind_cannot_record_source_rewrite
    (kind : ExistingTraceKind) : recordsSourceRewrite kind = false := by
  cases kind <;> rfl

inductive TranslationOutcome where
  | sat
  | unsat
  | unsupportedHigherOrder
  deriving DecidableEq, Repr

inductive CommandAuthority where
  | translatedSat
  | translatedUnsat
  | parserTypeLoweringOnly
  deriving DecidableEq, Repr

def authorityForOutcome : TranslationOutcome -> CommandAuthority
  | .sat => .translatedSat
  | .unsat => .translatedUnsat
  | .unsupportedHigherOrder => .parserTypeLoweringOnly

def commandAuthorityLedger
    (outcomes : List TranslationOutcome) : List CommandAuthority :=
  outcomes.map authorityForOutcome

theorem translated_sat_has_solver_authority :
    authorityForOutcome .sat = .translatedSat := rfl

theorem translated_unsat_has_solver_authority :
    authorityForOutcome .unsat = .translatedUnsat := rfl

theorem unsupported_has_only_parser_type_lowering_authority :
    authorityForOutcome .unsupportedHigherOrder =
      .parserTypeLoweringOnly := rfl

theorem every_command_has_exactly_one_authority_record
    (outcomes : List TranslationOutcome) :
    (commandAuthorityLedger outcomes).length = outcomes.length := by
  simp [commandAuthorityLedger]

/- A finite two-atom executable cross-check of the relational axioms. -/
abbrev BitRel := Bool × Bool

def bitSubset (left right : BitRel) : Bool :=
  (!left.1 || right.1) && (!left.2 || right.2)
def bitNonempty (relation : BitRel) : Bool := relation.1 || relation.2
def bitAtMostOne (relation : BitRel) : Bool := !(relation.1 && relation.2)
def bitCondition : Multiplicity → BitRel → Bool
  | .set, _ => true
  | .lone, relation => bitAtMostOne relation
  | .some, relation => bitNonempty relation
  | .one, relation => bitNonempty relation && bitAtMostOne relation
  | .exactly, _ => true
def bitAdmits (multiplicity : Multiplicity) (domain candidate : BitRel) : Bool :=
  match multiplicity with
  | .exactly => candidate == domain
  | other => bitSubset candidate domain && bitCondition other candidate

def bitRelations : List BitRel :=
  [(false, false), (false, true), (true, false), (true, true)]

def countBindings (multiplicity : Multiplicity) (domain : BitRel) : Nat :=
  (bitRelations.filter (bitAdmits multiplicity domain)).length

#eval countBindings .set (false, false)
#eval countBindings .lone (false, false)
#eval countBindings .some (false, false)
#eval countBindings .one (false, false)
#eval countBindings .exactly (false, false)

example : countBindings .set (false, false) = 1 := by decide
example : countBindings .lone (false, false) = 1 := by decide
example : countBindings .some (false, false) = 0 := by decide
example : countBindings .one (false, false) = 0 := by decide
example : countBindings .exactly (false, false) = 1 := by decide

/- Reserved set constants have construction authority that ordinary metadata
   mutation cannot mint. Trusted normalization may carry that authority across
   an unchanged nullary rebuild, but adding a child revokes it. -/
inductive BuiltinSetAuthority where
  | absent
  | publicMetadata
  | parserFactory
  | derivedRewrite
  deriving DecidableEq, Repr

def recognizesBuiltinSetConstant : BuiltinSetAuthority -> Bool
  | .parserFactory => true
  | .derivedRewrite => true
  | _ => false

def normalizedNullaryAuthority
    (authority : BuiltinSetAuthority)
    (replacementArity : Nat) : BuiltinSetAuthority :=
  if replacementArity == 0 then authority else .absent

theorem public_metadata_cannot_mint_builtin_set_authority :
    recognizesBuiltinSetConstant .publicMetadata = false := rfl

theorem parser_factory_authorizes_builtin_set_constant :
    recognizesBuiltinSetConstant .parserFactory = true := rfl

theorem derived_rewrite_authorizes_builtin_set_constant :
    recognizesBuiltinSetConstant .derivedRewrite = true := rfl

theorem trusted_nullary_rebuild_preserves_builtin_set_authority
    (authority : BuiltinSetAuthority) :
    normalizedNullaryAuthority authority 0 = authority := by
  simp [normalizedNullaryAuthority]

theorem adding_a_child_revokes_builtin_set_authority
    (authority : BuiltinSetAuthority) :
    normalizedNullaryAuthority authority 1 = .absent := by
  simp [normalizedNullaryAuthority]

/- A retired node keeps a tombstone identity only. No semantic payload may be
   observed through either the node or a previously escaped child-list view. -/
inductive NodeLifecycle where
  | live
  | retired
  deriving DecidableEq, Repr

def semanticPayloadReadable : NodeLifecycle -> Bool
  | .live => true
  | .retired => false

def escapedChildViewReadable := semanticPayloadReadable

theorem retired_node_semantic_payload_is_unreadable :
    semanticPayloadReadable .retired = false := rfl

theorem retired_child_view_is_unreadable :
    escapedChildViewReadable .retired = false := rfl

/- Alloy's parsed operator identity selects the relational or integer family.
   A relational PLUS/MINUS may still have the unary Int relation as its exact
   result carrier; that carrier does not turn set union/difference into
   arithmetic. -/
inductive ParsedAdditiveOperator where
  | relationPlus
  | relationMinus
  | integerPlus
  | integerMinus
  deriving DecidableEq, Repr

inductive LoweredAdditiveOperator where
  | relationalUnion
  | relationalDifference
  | integerAddition
  | integerSubtraction
  deriving DecidableEq, Repr

def lowerAdditiveOperator : ParsedAdditiveOperator -> LoweredAdditiveOperator
  | .relationPlus => .relationalUnion
  | .relationMinus => .relationalDifference
  | .integerPlus => .integerAddition
  | .integerMinus => .integerSubtraction

theorem exact_integer_plus_is_not_relational_union :
    lowerAdditiveOperator .integerPlus = .integerAddition := rfl

theorem exact_relation_plus_remains_relational_union :
    lowerAdditiveOperator .relationPlus = .relationalUnion := rfl

theorem int_typed_surface_plus_remains_relational_union :
    lowerAdditiveOperator .relationPlus = .relationalUnion := rfl

theorem int_typed_surface_minus_remains_relational_difference :
    lowerAdditiveOperator .relationMinus = .relationalDifference := rfl

theorem integer_addition_is_not_idempotent_witness :
    ((1 : Int) + 1) ≠ 1 := by decide

/- Alloy's `Type.is_int` reports participation of the built-in Int carrier,
   not exclusivity. Exact Int classification therefore requires the complete
   unary alternative family to contain only Int. -/
inductive UnaryTypeAlternative where
  | int
  | signature (identity : Nat)
  deriving DecidableEq, Repr

def isExactUnaryIntCarrier
    (alternatives : List UnaryTypeAlternative) : Bool :=
  decide (alternatives = [.int])

theorem exact_unary_int_classifier_iff
    (alternatives : List UnaryTypeAlternative) :
    isExactUnaryIntCarrier alternatives = true ↔ alternatives = [.int] := by
  simp [isExactUnaryIntCarrier]

theorem singleton_int_is_exact_unary_int :
    isExactUnaryIntCarrier [.int] = true := by
  simp [isExactUnaryIntCarrier]

theorem heterogeneous_int_signature_is_not_exact_unary_int
    (identity : Nat) :
    isExactUnaryIntCarrier [.int, .signature identity] = false := by
  simp [isExactUnaryIntCarrier]

/- Shared operator symbols retain monotonically increasing source visits. The
   parent keeps its saved visit while two nested occurrences receive distinct
   later visits, even when their source subterms are textually identical. -/
def nextSourceVisit (visit : Nat) : Nat := Nat.succ visit

theorem consecutive_nested_operator_occurrences_are_distinct (visit : Nat) :
    nextSourceVisit visit ≠ nextSourceVisit (nextSourceVisit visit) := by
  simp [nextSourceVisit]

theorem three_nested_ite_branch_occurrences_are_pairwise_distinct (visit : Nat) :
    let condition := nextSourceVisit visit
    let thenBranch := nextSourceVisit condition
    let elseBranch := nextSourceVisit thenBranch
    condition ≠ thenBranch ∧
      condition ≠ elseBranch ∧
      thenBranch ≠ elseBranch := by
  simp [nextSourceVisit]

/- Structurally equal literal values remain separate parser occurrences. A
   visit counter indexed by occurrence identity therefore starts the second
   equal-valued literal at visit one instead of borrowing the first literal's
   counter. -/
def occurrenceVisit (seen : List Nat) (identity : Nat) : Nat :=
  seen.count identity + 1

theorem distinct_equal_literal_occurrences_each_start_at_first_visit
    (leftIdentity rightIdentity : Nat)
    (different : leftIdentity ≠ rightIdentity) :
    occurrenceVisit [] leftIdentity = 1 ∧
      occurrenceVisit [leftIdentity] rightIdentity = 1 := by
  simp [occurrenceVisit, different]

/- Equality's certified commutative quotient is admissible when a surrounding
   Boolean complement compares opposite source orders. -/
theorem swapped_equality_or_its_complement (left right : α) :
    left = right ∨ ¬ (right = left) := by
  by_cases equal : left = right
  · exact Or.inl equal
  · exact Or.inr (fun reversed => equal reversed.symm)

theorem enum_two_atom_cover
    {carrier left right : Rel α}
    (enumFact : ∀ atom, carrier atom ↔ left atom ∨ right atom) :
    union left right = carrier :=
  abstract_direct_extension_cover enumFact

/- Alloy's reserved `iden`, transpose, and finite relational closures. These
   definitions are independent of the Java producer and prove exactly the
   parser-backed schemas admitted by the guarded source rewrite. -/
inductive BuiltinIdentityAuthority where
  | absent
  | publicMetadata
  | parserFactory
  | trustedExactClone
  deriving DecidableEq, Repr

def recognizesBuiltinIdentity : BuiltinIdentityAuthority → Bool
  | .parserFactory => true
  | .trustedExactClone => true
  | _ => false

theorem public_metadata_cannot_mint_builtin_identity :
    recognizesBuiltinIdentity .publicMetadata = false := rfl

theorem parser_factory_authorizes_builtin_identity :
    recognizesBuiltinIdentity .parserFactory = true := rfl

theorem trusted_exact_clone_preserves_builtin_identity :
    recognizesBuiltinIdentity .trustedExactClone = true := rfl

def identityBinaryRel : BinaryRel α α := fun left right => left = right

theorem identity_relation_join_left (relation : BinaryRel α β) :
    relationJoin identityBinaryRel relation = relation := by
  funext left right
  apply propext
  constructor
  · rintro ⟨middle, equality, member⟩
    cases equality
    exact member
  · intro member
    exact ⟨left, rfl, member⟩

theorem identity_relation_join_right (relation : BinaryRel α β) :
    relationJoin relation identityBinaryRel = relation := by
  funext left right
  apply propext
  constructor
  · rintro ⟨middle, member, equality⟩
    cases equality
    exact member
  · intro member
    exact ⟨right, member, rfl⟩

def transposeRelation (relation : Rel (α × β)) : Rel (β × α) :=
  fun tuple => relation (tuple.2, tuple.1)

def identityPairRelation : Rel (α × α) :=
  fun tuple => tuple.1 = tuple.2

theorem transpose_identity_relation :
    transposeRelation (identityPairRelation : Rel (α × α)) =
      identityPairRelation := by
  funext tuple
  simp [transposeRelation, identityPairRelation, eq_comm]

theorem transpose_relation_involutive (relation : Rel (α × β)) :
    transposeRelation (transposeRelation relation) = relation := by
  funext tuple
  rfl

theorem transpose_relation_product
    (left : Rel α) (right : Rel β) :
    transposeRelation (relationProduct left right) =
      relationProduct right left := by
  funext tuple
  simp [transposeRelation, relationProduct, and_comm]

/- Converse of binary composition and the two-coordinate algebra of Alloy
   domain/range restriction. These definitions are extensional set semantics;
   they import no Java rule or fixture. -/
def converseBinary (relation : BinaryRel α β) : BinaryRel β α :=
  fun right left => relation left right

theorem converse_reverses_relation_join
    (left : BinaryRel α β)
    (right : BinaryRel β γ) :
    converseBinary (relationJoin left right) =
      relationJoin (converseBinary right) (converseBinary left) := by
  funext last first
  apply propext
  constructor
  · rintro ⟨middle, leftMember, rightMember⟩
    exact ⟨middle, rightMember, leftMember⟩
  · rintro ⟨middle, rightMember, leftMember⟩
    exact ⟨middle, leftMember, rightMember⟩

def domainRestriction
    (restrictor : Rel α)
    (relation : Rel (α × β)) : Rel (α × β) :=
  fun tuple => restrictor tuple.1 ∧ relation tuple

def rangeRestriction
    (relation : Rel (α × β))
    (restrictor : Rel β) : Rel (α × β) :=
  fun tuple => relation tuple ∧ restrictor tuple.2

theorem domain_restriction_subset_relation
    (restrictor : Rel α)
    (relation : Rel (α × β)) :
    subset (domainRestriction restrictor relation) relation := by
  intro tuple member
  exact member.2

theorem range_restriction_subset_relation
    (relation : Rel (α × β))
    (restrictor : Rel β) :
    subset (rangeRestriction relation restrictor) relation := by
  intro tuple member
  exact member.1

theorem domain_restriction_relation_union
    (restrictor : Rel α) (left right : Rel (α × β)) :
    domainRestriction restrictor (union left right) =
      union (domainRestriction restrictor left)
        (domainRestriction restrictor right) := by
  funext tuple
  simp [domainRestriction, union, and_or_left]

theorem domain_restriction_relation_intersection
    (restrictor : Rel α) (left right : Rel (α × β)) :
    domainRestriction restrictor (intersection left right) =
      intersection (domainRestriction restrictor left)
        (domainRestriction restrictor right) := by
  funext tuple
  by_cases restricted : restrictor tuple.1 <;>
    by_cases leftMember : left tuple <;>
    by_cases rightMember : right tuple <;>
    simp [domainRestriction, intersection,
      restricted, leftMember, rightMember]

theorem domain_restriction_relation_difference
    (restrictor : Rel α) (left right : Rel (α × β)) :
    domainRestriction restrictor (difference left right) =
      difference (domainRestriction restrictor left)
        (domainRestriction restrictor right) := by
  funext tuple
  by_cases restricted : restrictor tuple.1 <;>
    simp [domainRestriction, difference, restricted]

theorem domain_restriction_restrictor_union
    (left right : Rel α) (relation : Rel (α × β)) :
    domainRestriction (union left right) relation =
      union (domainRestriction left relation)
        (domainRestriction right relation) := by
  funext tuple
  simp [domainRestriction, union, or_and_right]

theorem domain_restriction_restrictor_intersection
    (left right : Rel α) (relation : Rel (α × β)) :
    domainRestriction (intersection left right) relation =
      intersection (domainRestriction left relation)
        (domainRestriction right relation) := by
  funext tuple
  by_cases leftMember : left tuple.1 <;>
    by_cases rightMember : right tuple.1 <;>
    by_cases relationMember : relation tuple <;>
    simp [domainRestriction, intersection,
      leftMember, rightMember, relationMember]

theorem domain_restriction_restrictor_difference
    (left right : Rel α) (relation : Rel (α × β)) :
    domainRestriction (difference left right) relation =
      difference (domainRestriction left relation)
        (domainRestriction right relation) := by
  funext tuple
  by_cases member : relation tuple <;>
    simp [domainRestriction, difference, member]

theorem range_restriction_relation_union
    (left right : Rel (α × β)) (restrictor : Rel β) :
    rangeRestriction (union left right) restrictor =
      union (rangeRestriction left restrictor)
        (rangeRestriction right restrictor) := by
  funext tuple
  simp [rangeRestriction, union, or_and_right]

theorem range_restriction_relation_intersection
    (left right : Rel (α × β)) (restrictor : Rel β) :
    rangeRestriction (intersection left right) restrictor =
      intersection (rangeRestriction left restrictor)
        (rangeRestriction right restrictor) := by
  funext tuple
  by_cases leftMember : left tuple <;>
    by_cases rightMember : right tuple <;>
    by_cases restricted : restrictor tuple.2 <;>
    simp [rangeRestriction, intersection,
      leftMember, rightMember, restricted]

theorem range_restriction_relation_difference
    (left right : Rel (α × β)) (restrictor : Rel β) :
    rangeRestriction (difference left right) restrictor =
      difference (rangeRestriction left restrictor)
        (rangeRestriction right restrictor) := by
  funext tuple
  by_cases restricted : restrictor tuple.2 <;>
    simp [rangeRestriction, difference, restricted]

theorem range_restriction_restrictor_union
    (relation : Rel (α × β)) (left right : Rel β) :
    rangeRestriction relation (union left right) =
      union (rangeRestriction relation left)
        (rangeRestriction relation right) := by
  funext tuple
  simp [rangeRestriction, union, and_or_left]

theorem range_restriction_restrictor_intersection
    (relation : Rel (α × β)) (left right : Rel β) :
    rangeRestriction relation (intersection left right) =
      intersection (rangeRestriction relation left)
        (rangeRestriction relation right) := by
  funext tuple
  by_cases relationMember : relation tuple <;>
    by_cases leftMember : left tuple.2 <;>
    by_cases rightMember : right tuple.2 <;>
    simp [rangeRestriction, intersection,
      relationMember, leftMember, rightMember]

theorem range_restriction_restrictor_difference
    (relation : Rel (α × β)) (left right : Rel β) :
    rangeRestriction relation (difference left right) =
      difference (rangeRestriction relation left)
        (rangeRestriction relation right) := by
  funext tuple
  by_cases member : relation tuple <;>
    simp [rangeRestriction, difference, member]

theorem nested_domain_restrictions_intersect
    (outer inner : Rel α) (relation : Rel (α × β)) :
    domainRestriction outer (domainRestriction inner relation) =
      domainRestriction (intersection outer inner) relation := by
  funext tuple
  simp [domainRestriction, intersection, and_assoc]

theorem nested_range_restrictions_intersect
    (relation : Rel (α × β)) (inner outer : Rel β) :
    rangeRestriction (rangeRestriction relation inner) outer =
      rangeRestriction relation (intersection inner outer) := by
  funext tuple
  simp [rangeRestriction, intersection, and_assoc]

theorem domain_and_range_restrictions_commute
    (domain : Rel α) (relation : Rel (α × β)) (range : Rel β) :
    domainRestriction domain (rangeRestriction relation range) =
      rangeRestriction (domainRestriction domain relation) range := by
  funext tuple
  simp [domainRestriction, rangeRestriction, and_assoc]

theorem complete_restriction_union_grid_factors
    (domainLeft domainRight : Rel α)
    (relationLeft relationRight : Rel (α × β)) :
    union
        (union
          (domainRestriction domainLeft relationLeft)
          (domainRestriction domainLeft relationRight))
        (union
          (domainRestriction domainRight relationLeft)
          (domainRestriction domainRight relationRight)) =
      domainRestriction
        (union domainLeft domainRight)
        (union relationLeft relationRight) := by
  funext tuple
  by_cases domainLeftMember : domainLeft tuple.1 <;>
    by_cases domainRightMember : domainRight tuple.1 <;>
    by_cases relationLeftMember : relationLeft tuple <;>
    by_cases relationRightMember : relationRight tuple <;>
    simp [domainRestriction, union,
      domainLeftMember, domainRightMember,
      relationLeftMember, relationRightMember]

def diagonalLeftSet : Rel Bool := fun atom => atom = true
def diagonalRightSet : Rel Bool := fun atom => atom = false
def diagonalLeftRelation : Rel (Bool × Bool) :=
  fun tuple => tuple = (false, true)
def diagonalRightRelation : Rel (Bool × Bool) :=
  fun tuple => tuple = (true, false)

theorem diagonal_restriction_union_does_not_factor :
    union
        (domainRestriction diagonalLeftSet diagonalLeftRelation)
        (domainRestriction diagonalRightSet diagonalRightRelation) ≠
      domainRestriction
        (union diagonalLeftSet diagonalRightSet)
        (union diagonalLeftRelation diagonalRightRelation) := by
  intro alleged
  have witness := congrFun alleged (false, true)
  simp [domainRestriction, union, diagonalLeftSet, diagonalRightSet,
    diagonalLeftRelation, diagonalRightRelation] at witness

theorem two_coordinate_restriction_difference_does_not_factor :
    difference
        (domainRestriction (@univRel Bool) (@univRel (Bool × Bool)))
        (domainRestriction (@univRel Bool) (@noneRel (Bool × Bool))) ≠
      domainRestriction
        (difference univRel univRel)
        (difference univRel noneRel) := by
  intro alleged
  have witness := congrFun alleged (true, true)
  simp [domainRestriction, difference, univRel, noneRel] at witness

def converseOrderLeft : BinaryRel Bool Bool :=
  fun left right => left = true ∧ right = false
def converseOrderRight : BinaryRel Bool Bool :=
  fun left right => left = false ∧ right = false

theorem converse_join_same_order_is_not_general :
    converseBinary (relationJoin converseOrderLeft converseOrderRight) ≠
      relationJoin (converseBinary converseOrderLeft)
        (converseBinary converseOrderRight) := by
  intro alleged
  have witness := congrFun (congrFun alleged false) true
  simp [converseBinary, relationJoin,
    converseOrderLeft, converseOrderRight] at witness

inductive PositivePath (relation : BinaryRel α α) : α → α → Prop where
  | single {left right} : relation left right → PositivePath relation left right
  | tail {left middle right} :
      PositivePath relation left middle →
      relation middle right →
      PositivePath relation left right

def transitiveClosure (relation : BinaryRel α α) : BinaryRel α α :=
  PositivePath relation

def reflexiveTransitiveClosure
    (relation : BinaryRel α α) : BinaryRel α α :=
  fun left right => left = right ∨ PositivePath relation left right

theorem positive_identity_path_implies_equality
    {left right : α}
    (path : PositivePath identityBinaryRel left right) :
    left = right := by
  induction path with
  | single edge => exact edge
  | tail _ edge inductionHypothesis =>
      exact inductionHypothesis.trans edge

theorem transitive_closure_identity_relation :
    transitiveClosure (identityBinaryRel : BinaryRel α α) =
      identityBinaryRel := by
  funext left right
  apply propext
  constructor
  · exact positive_identity_path_implies_equality
  · exact PositivePath.single

theorem reflexive_transitive_closure_identity_relation :
    reflexiveTransitiveClosure (identityBinaryRel : BinaryRel α α) =
      identityBinaryRel := by
  funext left right
  apply propext
  constructor
  · rintro (equality | path)
    · exact equality
    · exact positive_identity_path_implies_equality path
  · exact Or.inl

theorem positive_path_transitive
    {relation : BinaryRel α α}
    {left middle right : α}
    (firstPath : PositivePath relation left middle)
    (secondPath : PositivePath relation middle right) :
    PositivePath relation left right := by
  induction secondPath with
  | single edge => exact PositivePath.tail firstPath edge
  | tail _ edge inductionHypothesis =>
      exact PositivePath.tail inductionHypothesis edge

theorem reflexive_transitive_closure_transitive
    {relation : BinaryRel α α}
    {left middle right : α}
    (firstPath : reflexiveTransitiveClosure relation left middle)
    (secondPath : reflexiveTransitiveClosure relation middle right) :
    reflexiveTransitiveClosure relation left right := by
  rcases firstPath with equality | prefixPath
  · cases equality
    exact secondPath
  · rcases secondPath with equality | suffixPath
    · cases equality
      exact Or.inr prefixPath
    · exact Or.inr (positive_path_transitive prefixPath suffixPath)

theorem path_of_reflexive_transitive_edges
    {relation : BinaryRel α α}
    {left right : α}
    (path : PositivePath (reflexiveTransitiveClosure relation) left right) :
    reflexiveTransitiveClosure relation left right := by
  induction path with
  | single edge => exact edge
  | tail _ edge inductionHypothesis =>
      exact reflexive_transitive_closure_transitive inductionHypothesis edge

theorem transitive_closure_idempotent (relation : BinaryRel α α) :
    transitiveClosure (transitiveClosure relation) =
      transitiveClosure relation := by
  funext left right
  apply propext
  constructor
  · intro path
    induction path with
    | single inner => exact inner
    | tail _ edge inductionHypothesis =>
        exact positive_path_transitive inductionHypothesis edge
  · intro path
    exact PositivePath.single path

theorem transitive_of_reflexive_transitive_is_reflexive_transitive
    (relation : BinaryRel α α) :
    transitiveClosure (reflexiveTransitiveClosure relation) =
      reflexiveTransitiveClosure relation := by
  funext left right
  apply propext
  constructor
  · exact path_of_reflexive_transitive_edges
  · intro reachable
    exact PositivePath.single reachable

theorem reflexive_transitive_closure_idempotent
    (relation : BinaryRel α α) :
    reflexiveTransitiveClosure (reflexiveTransitiveClosure relation) =
      reflexiveTransitiveClosure relation := by
  funext left right
  apply propext
  constructor
  · rintro (equality | path)
    · exact Or.inl equality
    · exact path_of_reflexive_transitive_edges path
  · intro reachable
    exact Or.inr (PositivePath.single reachable)

theorem reflexive_of_transitive_is_reflexive_transitive
    (relation : BinaryRel α α) :
    reflexiveTransitiveClosure (transitiveClosure relation) =
      reflexiveTransitiveClosure relation := by
  funext left right
  apply propext
  constructor
  · rintro (equality | path)
    · exact Or.inl equality
    · exact Or.inr (Eq.mp
        (congrFun (congrFun
          (transitive_closure_idempotent relation) left) right)
        path)
  · rintro (equality | path)
    · exact Or.inl equality
    · exact Or.inr (PositivePath.single path)

/- The JOIN normalizer may expose a union in any coordinate of an
   associative composition chain.  These theorems justify closing the
   distributive rewrite to a fixed point rather than limiting it to the two
   coordinates of one parser node. -/
theorem relation_join_associative
    (left : BinaryRel α β)
    (middle : BinaryRel β γ)
    (right : BinaryRel γ δ) :
    relationJoin (relationJoin left middle) right =
      relationJoin left (relationJoin middle right) := by
  funext first last
  apply propext
  constructor
  · rintro ⟨afterMiddle, ⟨afterLeft, leftMember, middleMember⟩,
      rightMember⟩
    exact ⟨afterLeft, leftMember, afterMiddle, middleMember, rightMember⟩
  · rintro ⟨afterLeft, leftMember, afterMiddle, middleMember, rightMember⟩
    exact ⟨afterMiddle, ⟨afterLeft, leftMember, middleMember⟩, rightMember⟩

theorem relation_join_distributes_over_union_middle_context
    (contextBefore : BinaryRel α β)
    (middleLeft middleRight : BinaryRel β γ)
    (contextAfter : BinaryRel γ δ) :
    relationJoin
        (relationJoin contextBefore
          (binaryUnion middleLeft middleRight)) contextAfter =
      binaryUnion
        (relationJoin (relationJoin contextBefore middleLeft) contextAfter)
        (relationJoin (relationJoin contextBefore middleRight) contextAfter) := by
  rw [relation_join_distributes_over_union_right,
    relation_join_distributes_over_union_left]

/- Endpoint restrictions are unary guards on the first or final coordinate of
   a binary relation.  These three local equalities, together with JOIN
   associativity above, justify the normalizer's orientation at every point in
   an ordered composition chain. -/
def domainRestrictionBinary
    (restrictor : Rel α)
    (relation : BinaryRel α β) : BinaryRel α β :=
  fun first last => restrictor first ∧ relation first last

def rangeRestrictionBinary
    (relation : BinaryRel α β)
    (restrictor : Rel β) : BinaryRel α β :=
  fun first last => relation first last ∧ restrictor last

def projectedDomainRestrictionBinary
    (endpoint : α → δ)
    (restrictor : Rel δ)
    (relation : BinaryRel α β) : BinaryRel α β :=
  fun first last => restrictor (endpoint first) ∧ relation first last

def projectedRangeRestrictionBinary
    (relation : BinaryRel α β)
    (endpoint : β → δ)
    (restrictor : Rel δ) : BinaryRel α β :=
  fun first last => relation first last ∧ restrictor (endpoint last)

theorem join_lifts_left_endpoint_domain_restriction
    (endpoint : α → δ)
    (restrictor : Rel δ)
    (left : BinaryRel α β)
    (right : BinaryRel β γ) :
    relationJoin
        (projectedDomainRestrictionBinary endpoint restrictor left) right =
      projectedDomainRestrictionBinary endpoint restrictor
        (relationJoin left right) := by
  funext first last
  apply propext
  constructor
  · rintro ⟨middle, ⟨restricted, leftMember⟩, rightMember⟩
    exact ⟨restricted, middle, leftMember, rightMember⟩
  · rintro ⟨restricted, middle, leftMember, rightMember⟩
    exact ⟨middle, ⟨restricted, leftMember⟩, rightMember⟩

theorem join_lifts_right_endpoint_range_restriction
    (left : BinaryRel α β)
    (right : BinaryRel β γ)
    (endpoint : γ → δ)
    (restrictor : Rel δ) :
    relationJoin left
        (projectedRangeRestrictionBinary right endpoint restrictor) =
      projectedRangeRestrictionBinary
        (relationJoin left right) endpoint restrictor := by
  funext first last
  apply propext
  constructor
  · rintro ⟨middle, leftMember, rightMember, restricted⟩
    exact ⟨⟨middle, leftMember, rightMember⟩, restricted⟩
  · rintro ⟨⟨middle, leftMember, rightMember⟩, restricted⟩
    exact ⟨middle, leftMember, rightMember, restricted⟩

theorem join_transfers_internal_range_to_domain_restriction
    (left : BinaryRel α β)
    (restrictor : Rel β)
    (right : BinaryRel β γ) :
    relationJoin (rangeRestrictionBinary left restrictor) right =
      relationJoin left (domainRestrictionBinary restrictor right) := by
  funext first last
  apply propext
  constructor
  · rintro ⟨middle, ⟨leftMember, restricted⟩, rightMember⟩
    exact ⟨middle, leftMember, restricted, rightMember⟩
  · rintro ⟨middle, leftMember, restricted, rightMember⟩
    exact ⟨middle, ⟨leftMember, restricted⟩, rightMember⟩

def unaryDomainRestriction
    (restrictor relation : Rel α) : Rel α :=
  fun atom => restrictor atom ∧ relation atom

def unaryRangeRestriction
    (relation restrictor : Rel α) : Rel α :=
  fun atom => relation atom ∧ restrictor atom

def unaryLeftJoin
    (left : Rel β)
    (right : BinaryRel β γ) : Rel γ :=
  fun last => ∃ middle, left middle ∧ right middle last

def unaryRightJoin
    (left : BinaryRel α β)
    (right : Rel β) : Rel α :=
  fun first => ∃ middle, left first middle ∧ right middle

theorem unary_left_restriction_stays_on_join_boundary
    (restrictor left : Rel β)
    (right : BinaryRel β γ) :
    unaryLeftJoin (unaryDomainRestriction restrictor left) right =
      unaryLeftJoin left (domainRestrictionBinary restrictor right) := by
  funext last
  apply propext
  constructor
  · rintro ⟨middle, ⟨restricted, leftMember⟩, rightMember⟩
    exact ⟨middle, leftMember, restricted, rightMember⟩
  · rintro ⟨middle, leftMember, restricted, rightMember⟩
    exact ⟨middle, ⟨restricted, leftMember⟩, rightMember⟩

theorem unary_domain_and_range_restriction_coincide
    (restrictor relation : Rel α) :
    unaryRangeRestriction relation restrictor =
      unaryDomainRestriction restrictor relation := by
  funext atom
  simp [unaryRangeRestriction, unaryDomainRestriction, and_comm]

def restrictionSideGuard : Rel Bool := fun atom => atom = true
def restrictionSideRelation : Rel (Bool × Bool) :=
  fun tuple => tuple = (true, false)

theorem binary_domain_and_range_restriction_do_not_generally_coincide :
    domainRestriction restrictionSideGuard restrictionSideRelation ≠
      rangeRestriction restrictionSideRelation restrictionSideGuard := by
  intro alleged
  have witness := congrFun alleged (true, false)
  simp [domainRestriction, rangeRestriction, restrictionSideGuard,
    restrictionSideRelation] at witness

theorem unary_right_range_or_domain_guard_has_same_join
    (left : BinaryRel α β)
    (restrictor right : Rel β) :
    unaryRightJoin left (unaryRangeRestriction right restrictor) =
      unaryRightJoin left (unaryDomainRestriction restrictor right) := by
  rw [unary_domain_and_range_restriction_coincide]

/- Converse is a coordinate permutation.  It therefore swaps restriction
   sides and commutes with both reachability closures. -/
theorem transpose_domain_restriction_is_range_restriction
    (restrictor : Rel α) (relation : Rel (α × β)) :
    transposeRelation (domainRestriction restrictor relation) =
      rangeRestriction (transposeRelation relation) restrictor := by
  funext tuple
  simp [transposeRelation, domainRestriction, rangeRestriction, and_comm]

theorem transpose_range_restriction_is_domain_restriction
    (relation : Rel (α × β)) (restrictor : Rel β) :
    transposeRelation (rangeRestriction relation restrictor) =
      domainRestriction restrictor (transposeRelation relation) := by
  funext tuple
  simp [transposeRelation, domainRestriction, rangeRestriction, and_comm]

theorem positive_path_prepend
    {relation : BinaryRel α α}
    {left middle right : α}
    (edge : relation left middle)
    (path : PositivePath relation middle right) :
    PositivePath relation left right := by
  induction path with
  | single lastEdge =>
      exact PositivePath.tail (PositivePath.single edge) lastEdge
  | tail _ lastEdge inductionHypothesis =>
      exact PositivePath.tail inductionHypothesis lastEdge

theorem converse_positive_path
    {relation : BinaryRel α α}
    {left right : α}
    (path : PositivePath relation left right) :
    PositivePath (converseBinary relation) right left := by
  induction path with
  | single edge => exact PositivePath.single edge
  | tail _ edge inductionHypothesis =>
      exact positive_path_prepend edge inductionHypothesis

theorem converse_binary_involutive (relation : BinaryRel α β) :
    converseBinary (converseBinary relation) = relation := by
  rfl

theorem converse_transitive_closure (relation : BinaryRel α α) :
    converseBinary (transitiveClosure relation) =
      transitiveClosure (converseBinary relation) := by
  funext right left
  apply propext
  constructor
  · exact converse_positive_path
  · intro path
    have reversed := converse_positive_path
      (relation := converseBinary relation) path
    rw [converse_binary_involutive] at reversed
    exact reversed

theorem converse_reflexive_transitive_closure
    (relation : BinaryRel α α) :
    converseBinary (reflexiveTransitiveClosure relation) =
      reflexiveTransitiveClosure (converseBinary relation) := by
  funext right left
  apply propext
  constructor
  · rintro (equality | path)
    · exact Or.inl equality.symm
    · exact Or.inr (converse_positive_path path)
  · rintro (equality | path)
    · exact Or.inl equality.symm
    · exact Or.inr (by
        have reversed := converse_positive_path
          (relation := converseBinary relation) path
        rw [converse_binary_involutive] at reversed
        exact reversed)

/- Restriction has the expected full-carrier identities and empty zeros in
   either coordinate.  These are extensional laws, independent of the Java
   representation used to authenticate a carrier or empty relation. -/
theorem domain_restriction_univ_identity
    (relation : Rel (α × β)) :
    domainRestriction (univRel : Rel α) relation = relation := by
  funext tuple
  simp [domainRestriction, univRel]

theorem range_restriction_univ_identity
    (relation : Rel (α × β)) :
    rangeRestriction relation (univRel : Rel β) = relation := by
  funext tuple
  simp [rangeRestriction, univRel]

theorem domain_restriction_empty_restrictor
    (relation : Rel (α × β)) :
    domainRestriction (noneRel : Rel α) relation = noneRel := by
  funext tuple
  simp [domainRestriction, noneRel]

theorem range_restriction_empty_restrictor
    (relation : Rel (α × β)) :
    rangeRestriction relation (noneRel : Rel β) = noneRel := by
  funext tuple
  simp [rangeRestriction, noneRel]

theorem domain_restriction_empty_relation (restrictor : Rel α) :
    domainRestriction restrictor (noneRel : Rel (α × β)) = noneRel := by
  funext tuple
  simp [domainRestriction, noneRel]

theorem range_restriction_empty_relation (restrictor : Rel β) :
    rangeRestriction (noneRel : Rel (α × β)) restrictor = noneRel := by
  funext tuple
  simp [rangeRestriction, noneRel]

theorem converse_empty_binary_relation :
    converseBinary (noneBinaryRel : BinaryRel α β) = noneBinaryRel := by
  rfl

theorem no_positive_empty_path
    {left right : α}
    (path : PositivePath (noneBinaryRel : BinaryRel α α) left right) :
    False := by
  induction path with
  | single impossible => exact impossible
  | tail _ impossible _ => exact impossible

theorem transitive_closure_empty_relation :
    transitiveClosure (noneBinaryRel : BinaryRel α α) = noneBinaryRel := by
  funext left right
  apply propext
  constructor
  · exact no_positive_empty_path
  · intro impossible
    exact False.elim impossible

theorem reflexive_transitive_closure_empty_relation :
    reflexiveTransitiveClosure (noneBinaryRel : BinaryRel α α) =
      identityBinaryRel := by
  funext left right
  apply propext
  constructor
  · rintro (equality | path)
    · exact equality
    · exact False.elim (no_positive_empty_path path)
  · intro equality
    exact Or.inl equality
