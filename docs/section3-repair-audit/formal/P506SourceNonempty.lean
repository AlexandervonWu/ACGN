import Phase5SourceRules

/- The root, declaration, and variable identifiers denote identities from one
   sealed parser model. Display names serve only as lookup keys. -/
namespace P506SourceNonempty

inductive Syntax where
  | bare | set | lone | one | some | exactly
  deriving DecidableEq

structure Domain where
  syntaxKind : Syntax
  arity : Nat
  deriving DecidableEq

def effective (d : Domain) : Multiplicity :=
  match d.syntaxKind with
  | .bare => if d.arity = 1 then .one else .set
  | .set => .set
  | .lone => .lone
  | .one => .one
  | .some => .some
  | .exactly => .exactly

structure Declaration where
  vars : List Nat
  domain : Domain

structure Root where
  identity : Nat
  decls : List Declaration

structure Slot where
  model : Nat
  declaration : Nat
  position : Nat
  variableId : Nat
  deriving DecidableEq

/-- Resolve the supplied coordinate against the immutable root and retrieve the
    declaration there. Each field is checked against data outside the read. -/
def issue (root : Root) (slot : Slot) : Option Domain :=
  if slot.model = root.identity then
    match root.decls[slot.declaration]? with
    | none => none
    | some decl => if decl.vars[slot.position]? = some slot.variableId then some decl.domain else none
  else none

def Issued (root : Root) (slot : Slot) (domain : Domain) : Prop :=
  slot.model = root.identity ∧ ∃ decl, root.decls[slot.declaration]? = some decl ∧
    decl.vars[slot.position]? = some slot.variableId ∧ decl.domain = domain

theorem issue_exact (r : Root) (slot : Slot) (d : Domain) :
    issue r slot = some d ↔ Issued r slot d := by
  unfold issue Issued
  by_cases hm : slot.model = r.identity
  · cases hd : r.decls[slot.declaration]? with
    | none => simp [hm]
    | some decl =>
      by_cases hv : decl.vars[slot.position]? = some slot.variableId <;> simp [hm, hv]
  · simp [hm]

structure Frame where
  name : Nat
  slot : Option Slot

/-- Non-authoritative declarations shadow outer names just as valid ones do. -/
def lookup : List Frame → Nat → Option Slot
  | [], _ => none
  | f :: tail, name => if f.name = name then f.slot else lookup tail name

inductive Visible (name : Nat) (slot : Slot) : List Frame → Prop where
  | here (tail : List Frame) : Visible name slot (⟨name, some slot⟩ :: tail)
  | there {f : Frame} {tail : List Frame} (miss : f.name ≠ name)
      (previous : Visible name slot tail) : Visible name slot (f :: tail)

theorem lookup_visible {scope : List Frame} {name : Nat} {slot : Slot} :
    lookup scope name = some slot → Visible name slot scope := by
  induction scope with
  | nil => simp [lookup]
  | cons f tail ih =>
    rcases f with ⟨label, value⟩
    by_cases h : label = name
    · subst label
      intro hit
      have hv : value = some slot := by simpa [lookup] using hit
      subst value
      exact .here tail
    · intro hit
      exact .there h (ih (by simpa [lookup, h] using hit))

def authorize (root : Root) (scope : List Frame) (name : Nat) (read : Option Slot) : Bool :=
  match lookup scope name, read with
  | some bound, some current =>
    if bound = current then
      match issue root bound with
      | some d => evidenceProvesNonempty (.authenticatedBinding (effective d))
      | none => false
    else false
  | _, _ => false

theorem decision_exact (m : Multiplicity) :
    evidenceProvesNonempty (.authenticatedBinding m) = true ↔ m = .one ∨ m = .some := by
  cases m <;> decide

theorem authorized_has_original (root : Root) (scope : List Frame) (name : Nat)
    (read : Option Slot) (accepted : authorize root scope name read = true) :
    ∃ slot d, read = some slot ∧ Visible name slot scope ∧ Issued root slot d ∧
      (effective d = .one ∨ effective d = .some) := by
  cases h : lookup scope name with
  | none => simp [authorize, h] at accepted
  | some bound =>
    cases hr : read with
    | none => simp [authorize, h, hr] at accepted
    | some current =>
      by_cases he : bound = current
      · subst current
        cases hi : issue root bound with
        | none => simp [authorize, h, hr, hi] at accepted
        | some d =>
          refine ⟨bound, d, rfl, lookup_visible h, (issue_exact ..).mp hi, ?_⟩
          exact (decision_exact _).mp (by simpa [authorize, h, hr, hi] using accepted)
      · simp [authorize, h, hr, he] at accepted

/-- The semantic assumption is precisely the original Alloy premise: the
    binding value satisfies its actual declaration. Nonemptiness is derived. -/
theorem authorized_admitted_value_is_nonempty {α : Type} (root : Root) (scope : List Frame)
    (name : Nat) (slot : Slot) (domain value : Rel α)
    (accepted : authorize root scope name (some slot) = true)
    (bound : ∀ d, Issued root slot d → admits (effective d) domain value) :
    relNonempty value := by
  obtain ⟨s,d,hs,_,issued,pos⟩ := authorized_has_original _ _ _ _ accepted
  have eq : slot = s := Option.some.inj hs
  subst s
  have h := bound d issued
  rcases pos with hp | hp
  · rw [hp] at h
    exact h.2.1
  · rw [hp] at h
    exact h.2

theorem missing_read_never_authorizes (root : Root) (scope : List Frame) (name : Nat) :
    authorize root scope name none = false := by cases h : lookup scope name <;> simp [authorize, h]

theorem shadow_blocks_outer (root : Root) (scope : List Frame) (name : Nat) (read : Option Slot) :
    authorize root (⟨name, none⟩ :: scope) name read = false := by simp [authorize, lookup]

theorem bare_nonunary_not_positive (arity : Nat) (h : arity ≠ 1) :
    evidenceProvesNonempty (.authenticatedBinding (effective ⟨.bare, arity⟩)) = false := by
  simp [effective, h, evidenceProvesNonempty]

/-- Tokens stand for object identity within one model. The two ordered edge lists
    represent the generic adapter children and the typed getters, respectively. -/
structure Projection where
  node : Nat
  parent : Option Nat
  typeId : Option Nat
  operation : Option Nat
  flags : Nat
  children : List (Option Nat)
  operands : List (Option Nat)
  deriving DecidableEq

def consistent (saved : List Projection) (current : Nat → Option Projection) : Bool :=
  saved.all fun v => decide (current v.node = some v)

theorem every_observation_matches (saved : List Projection) (current : Nat → Option Projection)
    (h : consistent saved current = true) {v : Projection} (member : v ∈ saved) :
    current v.node = some v := by
  exact of_decide_eq_true ((List.all_eq_true.mp h) v member)

theorem changed_observation_blocks (saved : List Projection) (current : Nat → Option Projection)
    {v : Projection} (member : v ∈ saved) (changed : current v.node ≠ some v) :
    consistent saved current = false := by
  cases h : consistent saved current with
  | false => rfl
  | true => exact False.elim (changed (every_observation_matches saved current h member))

theorem current_authorized_value_is_nonempty {α : Type} (root : Root) (scope : List Frame)
    (name : Nat) (slot : Slot) (domain value : Rel α) (saved : List Projection)
    (current : Nat → Option Projection)
    (accepted : (consistent saved current && authorize root scope name (some slot)) = true)
    (bound : ∀ d, Issued root slot d → admits (effective d) domain value) :
    (∀ v ∈ saved, current v.node = some v) ∧ relNonempty value := by
  have both : consistent saved current = true ∧ authorize root scope name (some slot) = true := by
    simpa using accepted
  obtain ⟨intact, owned⟩ := both
  exact ⟨fun _ member => every_observation_matches saved current intact member,
    authorized_admitted_value_is_nonempty root scope name slot domain value owned bound⟩

end P506SourceNonempty

#print axioms P506SourceNonempty.issue_exact
#print axioms P506SourceNonempty.lookup_visible
#print axioms P506SourceNonempty.decision_exact
#print axioms P506SourceNonempty.authorized_has_original
#print axioms P506SourceNonempty.authorized_admitted_value_is_nonempty
#print axioms P506SourceNonempty.missing_read_never_authorizes
#print axioms P506SourceNonempty.shadow_blocks_outer
#print axioms P506SourceNonempty.bare_nonunary_not_positive
#print axioms P506SourceNonempty.every_observation_matches
#print axioms P506SourceNonempty.changed_observation_blocks
#print axioms P506SourceNonempty.current_authorized_value_is_nonempty
