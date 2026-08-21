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

theorem none_intersection_is_none (relation : Rel α) :
    intersection noneRel relation = noneRel := by
  funext atom
  apply propext
  constructor
  · intro member
    exact member.1
  · intro impossible
    exact False.elim impossible

theorem positive_one_over_none_intersection_has_no_binding
    (relation candidate : Rel α) :
    ¬ admits .one (intersection noneRel relation) candidate := by
  rw [none_intersection_is_none]
  exact one_none_has_no_binding candidate

def difference (left right : Rel α) : Rel α :=
  fun atom => left atom ∧ ¬ right atom

theorem relation_difference_itself_is_none (relation : Rel α) :
    difference relation relation = noneRel := by
  funext atom
  apply propext
  constructor
  · intro member
    exact False.elim (member.2 member.1)
  · intro impossible
    exact False.elim impossible

theorem none_difference_is_none (relation : Rel α) :
    difference noneRel relation = noneRel := by
  funext atom
  apply propext
  constructor
  · intro member
    exact member.1
  · intro impossible
    exact False.elim impossible

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
