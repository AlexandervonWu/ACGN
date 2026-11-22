import RetainedLexicalWitnesses

namespace RetainedLexicalAliasInvariant
open RetainedLexicalResolution Focused225CallViews

/- Original outer names are unique. Each local insertion checks both the fresh
   lexical name and the fresh original binding (usedOwners, after the original
   locals registry lookup). Therefore a live binding has one alias per scope.
   Sibling scopes may nevertheless reuse the same alias for different objects. -/
def NoAliases (context : Context) : Prop :=
  ∀ a ∈ context, ∀ b ∈ context, a.2.object = b.2.object → a.1 = b.1

theorem empty_no_aliases : NoAliases [] := by simp [NoAliases]

theorem insert_no_aliases (context : Context) (name : String) (binding : Ref)
    (valid : NoAliases context)
    (fresh : ∀ entry ∈ context, entry.2.object ≠ binding.object) :
    NoAliases ((name, binding) :: context) := by
  intro a ha b hb same
  rcases List.mem_cons.mp ha with rfl | ha
  · rcases List.mem_cons.mp hb with rfl | hb
    · rfl
    · exact False.elim (fresh b hb same.symm)
  · rcases List.mem_cons.mp hb with rfl | hb
    · exact False.elim (fresh a ha same)
    · exact valid a ha b hb same

theorem lookup_member (context : Context) (name : String) (binding : Ref)
    (found : lookup context name = some binding) : (name, binding) ∈ context := by
  unfold lookup at found
  split at found
  next entry matched =>
    have member : entry ∈ context.filter (fun e => decide (e.1 = name)) := by
      rw [matched]; simp
    obtain ⟨inside, named⟩ := List.mem_filter.mp member
    have value : entry.2 = binding := Option.some.inj found
    have key : entry.1 = name := of_decide_eq_true named
    have same : entry = (name, binding) := Prod.ext key value
    simpa [same] using inside
  next => simp at found

theorem one_binding_one_name (context : Context) (a b : String) (binding : Ref)
    (valid : NoAliases context) (left : lookup context a = some binding)
    (right : lookup context b = some binding) : a = b :=
  valid (a, binding) (lookup_member context a binding left)
    (b, binding) (lookup_member context b binding right) rfl

/- Both lexical walks check each representative's own alpha spelling against
   sourceVariables before accepting it. Each map traversal retains that actual
   representative identity. No context chosen from a different edge can help. -/
theorem each_valid_invocation_has_lexical_name (context : Context)
    (alpha effective : String) (expected : Ref) (valid : NoAliases context)
    (lexical : lookup context alpha = some expected)
    (invocation : lookup context effective = some expected) : effective = alpha :=
  one_binding_one_name context effective alpha expected valid invocation lexical

theorem no_loss_from_all_context_check (contexts : List Context)
    (alpha effective : String) (expected : Ref) (actual : Context)
    (member : actual ∈ contexts) (valid : NoAliases actual)
    (lexical : ∀ context ∈ contexts, lookup context alpha = some expected)
    (invocation : lookup actual effective = some expected) :
    checkName contexts effective expected = true := by
  have same := each_valid_invocation_has_lexical_name actual alpha effective expected
    valid (lexical actual member) invocation
  have nonempty : contexts ≠ [] := by intro empty; simp [empty] at member
  simpa [checkName, same, List.all_eq_true] using And.intro nonempty lexical

theorem context_check_is_spelling_check (contexts : List Context)
    (alpha effective : String) (expected : Ref) (actual : Context)
    (member : actual ∈ contexts) (valid : NoAliases actual)
    (lexical : ∀ context ∈ contexts, lookup context alpha = some expected) :
    checkName contexts effective expected = decide (effective = alpha) := by
  by_cases same : effective = alpha
  · have positive := no_loss_from_all_context_check contexts alpha alpha expected
      actual member valid lexical (lexical actual member)
    simpa [same] using positive
  · have negative : checkName contexts effective expected = false := by
      apply Bool.eq_false_iff.mpr
      intro accepted
      have all : ∀ context ∈ contexts, lookup context effective = some expected := by
        have facts : contexts ≠ [] ∧
            ∀ context ∈ contexts, lookup context effective = some expected := by
          simpa [checkName, List.all_eq_true] using accepted
        exact facts.2
      exact same (one_binding_one_name actual effective alpha expected valid
        (all actual member) (lexical actual member))
    simp [negative, same]

def directUse (initial : SlotMap) (route : List Step) (alpha : String)
    (expected : Ref) : Option Ref := do
  let effective ← ancestors initial route
  let name ← lookup effective alpha
  if name = alpha then some expected else none

theorem direct_is_contextual (contexts : List Context) (initial : SlotMap)
    (route : List Step) (alpha : String) (expected : Ref) (actual : Context)
    (member : actual ∈ contexts) (valid : NoAliases actual)
    (lexical : ∀ context ∈ contexts, lookup context alpha = some expected) :
    directUse initial route alpha expected = resolveUse contexts initial route alpha expected := by
  unfold directUse resolveUse
  have same : ∀ name, checkName contexts name expected = decide (name = alpha) :=
    fun name => context_check_is_spelling_check contexts alpha name expected actual member valid lexical
  simp only [same, decide_eq_true_eq]

theorem direct_read_preserved {V : Type} (valuation : Ref → V)
    (contexts : List Context) (initial : SlotMap) (route : List Step)
    (alpha : String) (expected actual : Ref) (context : Context)
    (member : context ∈ contexts) (valid : NoAliases context)
    (lexical : ∀ c ∈ contexts, lookup c alpha = some expected)
    (accepted : directUse initial route alpha expected = some actual) :
    valuation actual = valuation expected := by
  rw [direct_is_contextual contexts initial route alpha expected context member valid lexical] at accepted
  exact accepted_read valuation contexts initial route alpha expected actual accepted

/- Direct reference comparison is the exact old Java branch. Inconsistent data
   for one token is not claimed to correspond to a mutable or decoded object. -/
def oldReferenceInsert (names : Context) (name : String) (binding : Ref) : Option Context :=
  match names.find? (fun entry => entry.1 == name) with
  | none => some ((name, binding) :: names)
  | some prior => if prior.2.object = binding.object then some names else none

theorem reference_collision_rejected (left right : Ref) (name : String)
    (different : left.object ≠ right.object) :
    oldReferenceInsert [(name, left)] name right = none := by
  simp [oldReferenceInsert, different]

open RetainedLexicalWitnesses
theorem observed_reference_collision : oldReferenceInsert first alias binding1 = none := by decide
theorem observed_first_scope : NoAliases first := by
  intro a ha b hb _
  simp only [first, List.mem_singleton] at ha hb
  rw [ha, hb]
theorem observed_second_scope : NoAliases second := by
  intro a ha b hb _
  simp only [second, List.mem_singleton] at ha hb
  rw [ha, hb]

theorem observed_direct_acceptance :
    directUse identity [] alias binding0 = some binding0 ∧
    directUse identity [] alias binding1 = some binding1 := by
  simp [directUse, ancestors, identity, lookup]

theorem ambiguous_alias_context_not_generated (a b : String) (different : a ≠ b) :
    ¬ NoAliases [(a, binding0), (b, binding0)] := by
  intro valid
  exact different (valid (a, binding0) (by simp) (b, binding0) (by simp) rfl)

end RetainedLexicalAliasInvariant
