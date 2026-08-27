import Std

namespace PrenexAciScheduling

open Classical

/- An existential prefix over a carrier is the safe outer prefix for moving a
universal sibling through conjunction, including when the carrier is empty. -/
theorem some_before_all_and
    {α : Type} (p q : α → Prop) :
    ((∃ y, q y) ∧ (∀ x, p x)) ↔
      ∃ y, ∀ x, q y ∧ p x := by
  constructor
  · rintro ⟨⟨y, hy⟩, hp⟩
    exact ⟨y, fun x => ⟨hy, hp x⟩⟩
  · rintro ⟨y, h⟩
    exact ⟨⟨y, (h y).1⟩, fun x => (h x).2⟩

/- Dually, a universal prefix over the same carrier is the safe outer prefix
for moving an existential sibling through disjunction. -/
theorem all_before_some_or
    {α : Type} (p q : α → Prop) :
    ((∀ y, q y) ∨ (∃ x, p x)) ↔
      ∀ y, ∃ x, q y ∨ p x := by
  constructor
  · intro h y
    cases h with
    | inl hq => exact ⟨y, Or.inl (hq y)⟩
    | inr hp =>
        obtain ⟨x, hx⟩ := hp
        exact ⟨x, Or.inr hx⟩
  · intro h
    by_cases hp : ∃ x, p x
    · exact Or.inr hp
    · apply Or.inl
      intro y
      obtain ⟨x, hqx⟩ := h y
      cases hqx with
      | inl hq => exact hq
      | inr hpx => exact False.elim (hp ⟨x, hpx⟩)

def schedule (preferred : Nat → Bool) (indices : List Nat) : List Nat :=
  indices.filter (fun index => preferred index) ++
    indices.filter (fun index => !(preferred index))

theorem schedule_preserves_membership
    (preferred : Nat → Bool) (indices : List Nat) (index : Nat) :
    index ∈ schedule preferred indices ↔ index ∈ indices := by
  cases h : preferred index <;> simp [schedule, h]

theorem schedule_preserves_length
    (preferred : Nat → Bool) (indices : List Nat) :
    (schedule preferred indices).length = indices.length := by
  induction indices with
  | nil => simp [schedule]
  | cons index rest inductionHypothesis =>
      have filteredLength :
          (rest.filter (fun item => preferred item)).length +
              (rest.filter (fun item => !(preferred item))).length =
            rest.length := by
        simpa [schedule] using inductionHypothesis
      cases h : preferred index <;> simp [schedule, h]
      all_goals omega

/- The source-rule layer represents an `exactly none` declaration by one
admissible candidate: the empty relation itself. This models the binding
ledger, not inhabitance of the declared carrier. -/
def exactlyNoneBindings : List (List Nat) := [[]]

theorem exactly_none_retains_one_empty_binding :
    exactlyNoneBindings = [[]] := rfl

theorem exactly_none_binding_count :
    exactlyNoneBindings.length = 1 := rfl

/- A source spelling is presentation metadata. Certified binding identity is
the scope path plus the slot owned by that scope, so a nested declaration may
shadow an outer parameter without merging their types or occurrences. -/
structure ScopedBinding where
  scopePath : List Nat
  slot : Nat
  sourceSpelling : String
  deriving DecidableEq

def bindingIdentity (binding : ScopedBinding) : List Nat × Nat :=
  (binding.scopePath, binding.slot)

theorem different_scope_paths_separate_shadowed_bindings
    (outer inner : ScopedBinding)
    (differentScope : outer.scopePath ≠ inner.scopePath) :
    bindingIdentity outer ≠ bindingIdentity inner := by
  intro sameIdentity
  exact differentScope (Prod.mk.inj sameIdentity).1

theorem different_slots_separate_bindings
    (left right : ScopedBinding)
    (differentSlot : left.slot ≠ right.slot) :
    bindingIdentity left ≠ bindingIdentity right := by
  intro sameIdentity
  exact differentSlot (Prod.mk.inj sameIdentity).2

theorem same_scope_distinct_slots_ignore_presentation
    (leftSpelling rightSpelling : String) :
    bindingIdentity ⟨[0], 0, leftSpelling⟩ ≠
      bindingIdentity ⟨[0], 1, rightSpelling⟩ := by
  apply different_slots_separate_bindings
  simp

def allocateBindingSlot (nextSlot : Nat) : Nat × Nat :=
  (nextSlot, nextSlot + 1)

theorem allocation_returns_current_slot_and_advances
    (nextSlot : Nat) :
    allocateBindingSlot nextSlot = (nextSlot, nextSlot + 1) := by
  rfl

theorem consecutive_allocations_are_distinct
    (nextSlot : Nat) :
    (allocateBindingSlot nextSlot).1 ≠
      (allocateBindingSlot (allocateBindingSlot nextSlot).2).1 := by
  simp [allocateBindingSlot]

theorem same_spelling_does_not_override_scope_identity
    (spelling : String) :
    bindingIdentity ⟨[0], 0, spelling⟩ ≠
      bindingIdentity ⟨[0, 1], 0, spelling⟩ := by
  apply different_scope_paths_separate_shadowed_bindings
  simp

theorem same_spelling_nested_let_bindings_separate
    (spelling : String) :
    bindingIdentity ⟨[1], 0, spelling⟩ ≠
      bindingIdentity ⟨[1, 2], 0, spelling⟩ := by
  apply different_scope_paths_separate_shadowed_bindings
  simp

/- A local signature declaration has one child per field-declaration group
plus its explicit terminator. Preindexing a signature as a leaf must not
remain the declaration node's arity once declaration structure is attached. -/
def signatureDeclarationArity (fieldDeclarationCount : Nat) : Nat :=
  fieldDeclarationCount + 1

theorem signature_declaration_arity_includes_field_declarations_and_end
    (fieldDeclarationCount : Nat) :
    signatureDeclarationArity fieldDeclarationCount =
      fieldDeclarationCount + 1 := by
  rfl

theorem one_field_signature_has_two_declaration_children :
    signatureDeclarationArity 1 = 2 := by
  rfl

/- The resolved parser leaf class is authority: variable leaves use the
lexical environment, while signature and field leaves use the global
environment. Display spelling alone cannot choose between them. -/
inductive LeafAuthority where
  | lexical
  | signature
  | field

def resolveName {Identity : Type}
    (authority : LeafAuthority)
    (lexical signature field : Option Identity) : Option Identity :=
  match authority with
  | .lexical => lexical
  | .signature => signature
  | .field => field

theorem lexical_binding_precedes_global
    {Identity : Type} (localIdentity globalIdentity : Identity) :
    resolveName .lexical (some localIdentity) (some globalIdentity) none =
      some localIdentity := by
  rfl

theorem signature_leaf_ignores_other_namespaces
    {Identity : Type}
    (localIdentity signatureIdentity fieldIdentity : Identity) :
    resolveName .signature
      (some localIdentity) (some signatureIdentity) (some fieldIdentity) =
        some signatureIdentity := by
  rfl

theorem field_leaf_ignores_other_namespaces
    {Identity : Type}
    (localIdentity signatureIdentity fieldIdentity : Identity) :
    resolveName .field
      (some localIdentity) (some signatureIdentity) (some fieldIdentity) =
        some fieldIdentity := by
  rfl

theorem missing_lexical_binding_rejects
    {Identity : Type} (globalIdentity : Identity) :
    resolveName .lexical none (some globalIdentity) none = none := by
  rfl

def indexReachable {Identity : Type} [DecidableEq Identity]
    (reachable : List Identity) : List Identity :=
  reachable.eraseDups

theorem reachable_signature_is_indexed
    {Identity : Type} [DecidableEq Identity]
    (reachable : List Identity) (identity : Identity) :
    identity ∈ indexReachable reachable ↔ identity ∈ reachable := by
  simp [indexReachable]

def fieldIdentity (name exactType : String) : String × String :=
  (name, exactType)

theorem same_named_fields_with_distinct_exact_types_separate
    (name leftType rightType : String)
    (differentType : leftType ≠ rightType) :
    fieldIdentity name leftType ≠ fieldIdentity name rightType := by
  intro sameIdentity
  exact differentType (Prod.mk.inj sameIdentity).2

/- Imported module instances are named by their declared client aliases. The
raw module path is provenance inside the instance, not a second alias when an
explicit alias exists. This permits two parameterizations of one module while
still rejecting two different instances assigned the same alias. -/
structure ImportedModuleInstance where
  fileName : String
  arguments : List String
  deriving DecidableEq

def admissibleAliasInsert
    (entries : List (String × ImportedModuleInstance))
    (alias : String)
    (targetInstance : ImportedModuleInstance) : Prop :=
  ∀ entry ∈ entries, entry.1 = alias → entry.2 = targetInstance

theorem distinct_declared_aliases_separate_module_instances
    (leftAlias rightAlias : String)
    (left right : ImportedModuleInstance)
    (differentAlias : leftAlias ≠ rightAlias) :
    admissibleAliasInsert [(leftAlias, left)] rightAlias right := by
  intro entry member sameAlias
  have entryIdentity : entry = (leftAlias, left) := by
    simpa using member
  subst entry
  exact False.elim (differentAlias sameAlias)

theorem same_alias_distinct_module_instances_reject
    (alias : String)
    (left right : ImportedModuleInstance)
    (differentInstance : left ≠ right) :
    ¬ admissibleAliasInsert [(alias, left)] alias right := by
  intro admissible
  have sameInstance := admissible (alias, left) (by simp) rfl
  exact differentInstance sameInstance

end PrenexAciScheduling
