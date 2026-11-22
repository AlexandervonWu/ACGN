import P506SourceNonempty

/- Empty relation values and an empty set of admissible assignments are different.
   The values may be relations on tuples of any fixed width. A slot records its
   resolved coordinate; the environment changes only when a binding is entered. -/
namespace P508EmptyBinding

abbrev Domain := P506SourceNonempty.Domain
abbrev effective := P506SourceNonempty.effective
abbrev Env (α : Type) := Nat → Rel α

inductive Expr where
  | zero
  | read (coordinate : Nat)
  | inter (left right : Expr)
  | minus (left right : Expr)
  deriving DecidableEq, Repr

def eval (env : Env α) : Expr → Rel α
  | .zero => noneRel
  | .read k => env k
  | .inter l r => fun x => eval env l x ∧ eval env r x
  | .minus l r => fun x => eval env l x ∧ ¬ eval env r x

def knownEmpty : Expr → Bool
  | .zero => true
  | .read _ => false
  | .inter l r => knownEmpty l || knownEmpty r
  | .minus l r => knownEmpty l || decide (l = r)

theorem derived_empty (env : Env α) (e : Expr) (h : knownEmpty e = true) :
    eval env e = noneRel := by
  induction e with
  | zero => rfl
  | read n => simp [knownEmpty] at h
  | inter l r il ir =>
    simp only [knownEmpty, Bool.or_eq_true] at h
    funext x
    apply propext
    rcases h with hl | hr
    · simp [eval, il hl, noneRel]
    · simp [eval, ir hr, noneRel]
  | minus l r il ir =>
    simp only [knownEmpty, Bool.or_eq_true, decide_eq_true_eq] at h
    funext x
    apply propext
    rcases h with hl | eq
    · simp [eval, il hl, noneRel]
    · subst r
      simp [eval, noneRel]

def positive : Multiplicity → Bool
  | .one | .some => true
  | _ => false

theorem no_value_iff_positive (m : Multiplicity) :
    (∀ v : Rel α, ¬ admits m noneRel v) ↔ positive m = true := by
  cases m <;> simp only [positive, Bool.false_eq_true, iff_false,
    iff_true]
  · intro h
    exact h noneRel ((set_none_exactly_one_binding noneRel).2 rfl)
  · intro h
    exact h noneRel ((lone_none_exactly_one_binding noneRel).2 rfl)
  · exact some_none_has_no_binding
  · exact one_none_has_no_binding
  · intro h
    exact h noneRel ((exactly_none_has_the_none_binding noneRel).2 rfl)

theorem bare_width_decides (n : Nat) :
    positive (effective ⟨.bare, n⟩) = true ↔ n = 1 := by
  by_cases h : n = 1 <;> simp [effective, P506SourceNonempty.effective, positive, h]

def bind (env : Env α) (k : Nat) (value : Rel α) : Env α :=
  fun key => if key = k then value else env key

theorem shadow_reads_nearest (env : Env α) (k : Nat) (v w : Rel α) :
    eval (bind (bind env k v) k w) (.read k) = w := by simp [eval, bind]

theorem unrelated_coordinate_retains_domain (env : Env α) (k j : Nat)
    (v : Rel α) (distinct : j ≠ k) :
    eval (bind env k v) (.read j) = env j := by simp [eval, bind, distinct]

structure Slot where
  key : Nat
  descriptor : Domain
  source : Expr

def accepts (env : Env α) (s : Slot) (v : Rel α) : Prop :=
  admits (effective s.descriptor) (eval env s.source) v

def admissible (env : Env α) : List Slot → List (Rel α) → Prop
  | [], [] => True
  | s :: ss, v :: vs => accepts env s v ∧ admissible (bind env s.key v) ss vs
  | _, _ => False

def blocks (s : Slot) : Bool := positive (effective s.descriptor) && knownEmpty s.source

theorem blocked_slot (env : Env α) (s : Slot) (h : blocks s = true) (v : Rel α) :
    ¬ accepts env s v := by
  simp only [blocks, Bool.and_eq_true] at h
  obtain ⟨hp, he⟩ := h
  unfold accepts
  rw [derived_empty env s.source he]
  exact (no_value_iff_positive (effective s.descriptor)).2 hp v

/- Every earlier legal choice extends the environment, so the same proof covers
   later dependent declarations, as well as separate slots of a shared domain. -/
theorem any_blocked_excludes_assignments (ss : List Slot) (h : ss.any blocks = true)
    (env : Env α) (values : List (Rel α)) : ¬ admissible env ss values := by
  induction ss generalizing env values with
  | nil => simp at h
  | cons s ss ih =>
    cases values with
    | nil => simp [admissible]
    | cons v vs =>
      intro valid
      simp only [List.any_cons, Bool.or_eq_true] at h
      rcases h with here | later
      · exact blocked_slot env s here v valid.1
      · exact ih later (bind env s.key v) vs valid.2

theorem nullable_value (m : Multiplicity) (h : positive m = false) :
    admits m (@noneRel α) noneRel := by
  cases m <;> simp [positive] at h
  · exact (set_none_exactly_one_binding noneRel).2 rfl
  · exact (lone_none_exactly_one_binding noneRel).2 rfl
  · exact (exactly_none_has_the_none_binding noneRel).2 rfl

theorem all_nullable_zero_admit_empty_choices (ss : List Slot) (env : Env α)
    (h : ∀ s ∈ ss, positive (effective s.descriptor) = false ∧ knownEmpty s.source = true) :
    admissible env ss (ss.map fun _ => noneRel) := by
  induction ss generalizing env with
  | nil => trivial
  | cons s ss ih =>
    constructor
    · obtain ⟨hp, he⟩ := h s (by simp)
      unfold accepts
      rw [derived_empty env s.source he]
      exact nullable_value _ hp
    · apply ih
      intro i hi
      exact h i (by simp [hi])

/- Grouped Alloy declarations evaluate a shared domain in the incoming scope,
   then assign independently to the group's slots. Later groups see all assignments. -/
structure Group where
  keys : List Nat
  descriptor : Domain
  source : Expr

def groupAdmits (env : Env α) (g : Group) (values : List (Rel α)) : Prop :=
  values.length = g.keys.length ∧ ∀ v ∈ values, admits (effective g.descriptor) (eval env g.source) v

theorem nonempty_group_blocked (env : Env α) (g : Group) (hs : g.keys ≠ [])
    (hp : positive (effective g.descriptor) = true) (he : knownEmpty g.source = true)
    (values : List (Rel α)) : ¬ groupAdmits env g values := by
  rintro ⟨n, all⟩
  cases values with
  | nil => apply hs; symm at n; exact List.eq_nil_of_length_eq_zero n
  | cons v vs =>
    have hv := all v (by simp)
    rw [derived_empty env g.source he] at hv
    exact (no_value_iff_positive _).2 hp v hv

theorem group_nullable_keeps_empty_tuple (env : Env α) (g : Group)
    (hp : positive (effective g.descriptor) = false) (he : knownEmpty g.source = true) :
    groupAdmits env g (g.keys.map fun _ => noneRel) := by
  constructor
  · simp
  · intro v hv
    simp at hv
    rcases hv with ⟨_, _, rfl⟩
    rw [derived_empty env g.source he]
    exact nullable_value _ hp

theorem quantifier_truth_at_blocked (ss : List Slot) (env : Env α)
    (h : ss.any blocks = true) (body : List (Rel α) → Prop) :
    qAll (admissible env ss) body ∧ ¬ qSome (admissible env ss) body ∧
    qNo (admissible env ss) body ∧ ¬ qOne (admissible env ss) body ∧
    qLone (admissible env ss) body ∧ ¬ (¬ qLone (admissible env ss) body) := by
  have empty := any_blocked_excludes_assignments ss h env
  exact ⟨empty_domain_all _ _ empty, empty_domain_not_some _ _ empty,
    empty_domain_no _ _ empty, empty_domain_not_one _ _ empty,
    empty_domain_lone _ _ empty, empty_domain_not_not_lone _ _ empty⟩

/- Additional declarations and disjointness filters can only remove assignments.
   All members of one group see its same incoming domain. A subsequent group
   sees all bound coordinates, in source order. -/
def extendGroup (env : Env α) (keys : List Nat) (values : List (Rel α)) : Env α :=
  (keys.zip values).foldl (fun e kv => bind e kv.1 kv.2) env

def groupChain (guard : Group → List (Rel α) → Prop) (env : Env α) :
    List Group → List (List (Rel α)) → Prop
  | [], [] => True
  | g :: gs, vs :: vss => groupAdmits env g vs ∧ guard g vs ∧
      groupChain guard (extendGroup env g.keys vs) gs vss
  | _, _ => False

def groupBlocks (g : Group) : Bool :=
  !g.keys.isEmpty && positive (effective g.descriptor) && knownEmpty g.source

theorem grouped_dependent_fold_requires_no_assignment (groups : List Group)
    (env : Env α) (guard : Group → List (Rel α) → Prop) (values : List (List (Rel α)))
    (h : groups.any groupBlocks = true) : ¬ groupChain guard env groups values := by
  induction groups generalizing values env with
  | nil => simp at h
  | cons g gs ih =>
    cases values with
    | nil => simp [groupChain]
    | cons vs vss =>
      intro valid
      simp only [List.any_cons, Bool.or_eq_true] at h
      rcases h with here | later
      · simp [groupBlocks] at here
        exact nonempty_group_blocked env g here.1.1 here.1.2 here.2 vs valid.1
      · exact ih (extendGroup env g.keys vs) vss later valid.2.2

theorem no_slot_cannot_block (s : Domain) (source : Expr) :
    groupBlocks ⟨[], s, source⟩ = false := rfl

theorem nullable_empty_semantics_in_any_width {n : Nat} (nonunary : n ≠ 1) :
    (fun v : Rel (Fin n → α) => admits (effective ⟨.bare, n⟩) noneRel v) =
      (fun v => v = noneRel) := by
  funext v
  apply propext
  simpa [effective, P506SourceNonempty.effective, nonunary] using set_none_exactly_one_binding v

theorem replacing_wide_declaration_with_unary_none_changes_some {n : Nat} (nonunary : n ≠ 1) :
    qSome (admits (effective ⟨.bare, n⟩) (@noneRel (Fin n → α))) (fun _ => True) ∧
    ¬ qSome (admits (effective ⟨.bare, 1⟩) (@noneRel (Fin n → α))) (fun _ => True) := by
  constructor
  · exact ⟨noneRel, by simp [effective, P506SourceNonempty.effective, nonunary,
                         (set_none_exactly_one_binding _).2 rfl], True.intro⟩
  · rintro ⟨v, valid, _⟩
    exact one_none_has_no_binding v valid

end P508EmptyBinding

#print axioms P508EmptyBinding.derived_empty
#print axioms P508EmptyBinding.no_value_iff_positive
#print axioms P508EmptyBinding.bare_width_decides
#print axioms P508EmptyBinding.shadow_reads_nearest
#print axioms P508EmptyBinding.unrelated_coordinate_retains_domain
#print axioms P508EmptyBinding.blocked_slot
#print axioms P508EmptyBinding.any_blocked_excludes_assignments
#print axioms P508EmptyBinding.nullable_value
#print axioms P508EmptyBinding.all_nullable_zero_admit_empty_choices
#print axioms P508EmptyBinding.nonempty_group_blocked
#print axioms P508EmptyBinding.group_nullable_keeps_empty_tuple
#print axioms P508EmptyBinding.quantifier_truth_at_blocked
#print axioms P508EmptyBinding.grouped_dependent_fold_requires_no_assignment
#print axioms P508EmptyBinding.no_slot_cannot_block
#print axioms P508EmptyBinding.nullable_empty_semantics_in_any_width
#print axioms P508EmptyBinding.replacing_wide_declaration_with_unary_none_changes_some
