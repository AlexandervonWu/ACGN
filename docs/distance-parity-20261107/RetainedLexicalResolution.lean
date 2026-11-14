import ScopedProgramCompletion

/- Each context is captured by the original lexical walk at the actual variable
   object. It is not a union of names from sibling owners. All visits to a shared
   object must agree; one convenient context cannot license another invocation.
   Java's original owner/domain/type/lineage checks remain prerequisites. -/
namespace RetainedLexicalResolution
open AuthenticatedPhaseTransport Focused225CallViews

abbrev Ref := Original Nat Focused225SharedContracts.Binding
abbrev Context := List (String × Ref)

def checkName (contexts : List Context) (name : String) (expected : Ref) : Bool :=
  !contexts.isEmpty && contexts.all (fun context =>
    decide (lookup context name = some expected))

def resolveUse (contexts : List Context) (initial : SlotMap) (route : List Step)
    (alpha : String) (expected : Ref) : Option Ref := do
  let effective ← ancestors initial route
  let name ← lookup effective alpha
  if checkName contexts name expected then some expected else none

theorem accepted_original (contexts : List Context) (initial : SlotMap)
    (route : List Step) (alpha : String) (expected actual : Ref)
    (accepted : resolveUse contexts initial route alpha expected = some actual) :
    actual = expected ∧ ∃ effective name,
      ancestors initial route = some effective ∧ lookup effective alpha = some name ∧
      contexts ≠ [] ∧ ∀ context ∈ contexts, lookup context name = some expected := by
  unfold resolveUse at accepted
  cases he : ancestors initial route with
  | none => simp [he] at accepted
  | some effective =>
    cases hn : lookup effective alpha with
    | none => simp [he, hn] at accepted
    | some name =>
      by_cases hc : checkName contexts name expected = true
      · simp [he, hn, hc] at accepted
        have facts : contexts ≠ [] ∧
            ∀ context ∈ contexts, lookup context name = some expected := by
          simpa [checkName, List.all_eq_true] using hc
        exact ⟨accepted.symm, effective, name, rfl, hn, facts⟩
      · simp [he, hn, hc] at accepted

theorem accepted_read {V : Type} (valuation : Ref → V)
    (contexts : List Context) (initial : SlotMap) (route : List Step)
    (alpha : String) (expected actual : Ref)
    (accepted : resolveUse contexts initial route alpha expected = some actual) :
    valuation actual = valuation expected := by
  rw [(accepted_original contexts initial route alpha expected actual accepted).1]

theorem accepted_record (contexts : List Context) (initial : SlotMap)
    (route : List Step) (alpha : String) (expected actual : Ref)
    (accepted : resolveUse contexts initial route alpha expected = some actual) :
    actual.object = expected.object ∧ actual.data = expected.data := by
  rw [(accepted_original contexts initial route alpha expected actual accepted).1]
  exact ⟨rfl, rfl⟩

theorem wrong_context_rejected (contexts : List Context) (initial : SlotMap)
    (route : List Step) (alpha name : String) (expected : Ref)
    (effective : SlotMap) (he : ancestors initial route = some effective)
    (hn : lookup effective alpha = some name) (context : Context)
    (member : context ∈ contexts) (wrong : lookup context name ≠ some expected) :
    resolveUse contexts initial route alpha expected = none := by
  cases h : resolveUse contexts initial route alpha expected with
  | none => rfl
  | some actual =>
    obtain ⟨_, mapped, resolved, hm, hr, _, all⟩ :=
      accepted_original contexts initial route alpha expected actual h
    have sameMap : mapped = effective := by simpa [he] using hm.symm
    subst mapped
    have sameName : resolved = name := by simpa [hn] using hr.symm
    subst resolved
    exact False.elim (wrong (all context member))

theorem no_lexical_visit_rejected (initial : SlotMap) (route : List Step)
    (alpha : String) (expected : Ref) :
    resolveUse [] initial route alpha expected = none := by
  unfold resolveUse
  cases ancestors initial route <;> simp
  next effective => cases lookup effective alpha <;> simp [checkName]

/- Exact putIfAbsent branch of the old global Java bindingNames table. -/
def oldInsert (names : Context) (name : String) (binding : Ref) : Option Context :=
  match names.find? (fun entry => entry.1 == name) with
  | none => some ((name, binding) :: names)
  | some prior => if prior.2 = binding then some names else none

theorem sibling_spelling_not_identity (left right : Ref) (name : String)
    (different : left ≠ right) : oldInsert [(name, left)] name right = none := by
  simp [oldInsert, different]

end RetainedLexicalResolution
