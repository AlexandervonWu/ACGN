import DisjointPaidDeclarationAlignment
import DistanceDerivedTrace

/- A declaration wrapper has structural authority, not an expression result
   type. This contract preserves the original group; it authorizes no binder
   exchange, domain simplification, disjointness erasure or free repair step.
   Java must authenticate these records against the actual source objects. -/
namespace StructuralDeclarationTyping

structure Slot where
  occurrence : Nat
  ordinal : Nat
  exactType : String
  dependencies : List Nat
  deriving DecidableEq

structure Group where
  opcode : String
  sourceHash : String
  occurrence : Nat
  owner : Nat
  phase : Nat
  branch : List Nat
  role : String
  domainOccurrence : Nat
  domainType : String
  disjoint : Bool
  slots : List Slot
  deriving DecidableEq

structure Head where
  opcode : String
  booleanMetatype : Bool
  expressionType : Option String
  deriving DecidableEq

def oldGate (head : Head) : Bool :=
  head.opcode == "GENERICRELDECL" || head.booleanMetatype || head.expressionType.isSome

def structural (head : Head) : Bool :=
  ["GENERICRELDECL", "DISJ", "VAR", "DISJVAR"].contains head.opcode

def checkedGroup (original selected : Group) : Bool := decide (selected = original)

def structuralAdmission (head : Head) (original selected : Group) : Bool :=
  structural head && decide (head.opcode = original.opcode) && checkedGroup original selected

theorem exact_group_retained (head : Head) (original selected : Group)
    (checked : structuralAdmission head original selected = true) : selected = original := by
  by_cases same : selected = original
  · exact same
  · simp [structuralAdmission, checkedGroup, same] at checked

theorem foreign_group_rejected (head : Head) (original selected : Group)
    (different : selected ≠ original) :
    structuralAdmission head original selected = false := by
  simp [structuralAdmission, checkedGroup, different]

/- Domain and distinctness are interpreted at the same owner environment.
   Keeping the group retains ordered dependencies, slots, phases and branches.
   The interpretation is arbitrary, so this is not a finite-carrier argument. -/
def permits (domain : Group → (Slot → A) → A → Prop)
    (env : Slot → A) (group : Group) : Prop :=
  (∀ slot ∈ group.slots, domain group env (env slot)) ∧
    (group.disjoint = true → group.slots.Pairwise (fun a b => env a ≠ env b))

theorem admitted_group_sound (head : Head) (original selected : Group)
    (checked : structuralAdmission head original selected = true)
    (domain : Group → (Slot → A) → A → Prop) (env : Slot → A) :
    permits domain env selected ↔ permits domain env original := by
  rw [exact_group_retained head original selected checked]

theorem ordered_slots_retained (head : Head) (original selected : Group)
    (checked : structuralAdmission head original selected = true) :
    selected.slots = original.slots ∧ selected.owner = original.owner ∧
    selected.phase = original.phase ∧ selected.branch = original.branch ∧
    selected.domainOccurrence = original.domainOccurrence := by
  rw [exact_group_retained head original selected checked]
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

def sourceAllDisjoint (domain : A → Prop) (body : A → A → Prop) : Prop :=
  ∀ x y, domain x → domain y → x ≠ y → body x y

def loweredAllDisjoint (domain : A → Prop) (body : A → A → Prop) : Prop :=
  ∀ x y, x ≠ y → (domain x ∧ domain y → body x y)

theorem source_guard_lowering (domain : A → Prop) (body : A → A → Prop) :
    sourceAllDisjoint domain body ↔ loweredAllDisjoint domain body := by
  constructor
  · intro h x y different members
    exact h x y members.1 members.2 different
  · intro h x y hx hy different
    exact h x y different ⟨hx, hy⟩

/- Representative natural source: all disj p1,p2:Professor | ... . The
   parameterized theorem above is the contract; this is one hashed instance,
   not a generated theorem or Lean execution per corpus predicate. -/
def representativeHead : Head := ⟨"DISJ", false, none⟩
def representative : Group :=
  ⟨"DISJ", "06fa1969bd406857888f3ec79f4a2c98af683cc2054af93e3b77157d39fd8e8c",
   3093900, 3093898, 0, [], "local", 3093904, "RELATION[6:Person]", true,
   [⟨3093905, 0, "RELATION[6:Person]", []⟩,
    ⟨3093906, 1, "RELATION[6:Person]", []⟩]⟩

theorem old_rejection : oldGate representativeHead = false := by decide
theorem structural_acceptance :
    structuralAdmission representativeHead representative representative = true := by decide
theorem representative_guard_retained (domain : Group → (Slot → A) → A → Prop)
    (env : Slot → A) :
    permits domain env representative ↔ permits domain env representative :=
  admitted_group_sound _ _ _ structural_acceptance domain env

theorem professor_source_both_directions (professor : Person → Prop)
    (enrolled teaches : Person → Course → Prop) :
    sourceAllDisjoint professor (fun p q => ¬ ∃ c, enrolled p c ∧ teaches q c) ↔
      loweredAllDisjoint professor (fun p q => ¬ ∃ c, enrolled p c ∧ teaches q c) :=
  source_guard_lowering _ _

theorem wrong_owner_rejected : structuralAdmission representativeHead representative
    { representative with owner := 3093899 } = false := by decide
theorem substituted_wrapper_rejected : structuralAdmission
    ⟨"GENERICRELDECL", false, none⟩ representative representative = false := by decide
theorem wrong_phase_rejected : structuralAdmission representativeHead representative
    { representative with phase := 1 } = false := by decide
theorem missing_disjointness_rejected : structuralAdmission representativeHead representative
    { representative with disjoint := false } = false := by decide
theorem swapped_slots_rejected : structuralAdmission representativeHead representative
    { representative with slots := representative.slots.reverse } = false := by decide
theorem wrong_dependency_rejected : structuralAdmission representativeHead representative
    { representative with slots := [⟨3093905,0,"RELATION[6:Person]",[42]⟩,
       ⟨3093906,1,"RELATION[6:Person]",[]⟩] } = false := by decide
theorem wrong_slot_type_rejected : structuralAdmission representativeHead representative
    { representative with slots := [⟨3093905,0,"RELATION[6:Course]",[]⟩,
       ⟨3093906,1,"RELATION[6:Person]",[]⟩] } = false := by decide
theorem untyped_expression_not_admitted :
    structuralAdmission ⟨"JOIN", false, none⟩ representative representative = false := by decide

/- The retained selected DISJ-to-JOIN matrix update costs one, not zero.
   This is a local operation control, not a claim about the complete path. -/
def selectedUpdate : DistanceDerivedTrace.Operation Nat String :=
  ⟨3093900, some "DISJ:3093900", some "JOIN:3094318:RELATION[6:Person]", 1⟩
def selectedStore : DistanceDerivedTrace.Store Nat String :=
  fun address => if address = 3093900 then some "DISJ:3093900" else none
theorem selected_update_executes_and_pays :
    (DistanceDerivedTrace.run selectedStore [selectedUpdate]).map (fun s => s 3093900) =
      some (some "JOIN:3094318:RELATION[6:Person]") ∧
    DistanceDerivedTrace.cost [selectedUpdate] = 1 := by decide
theorem stale_selected_before_rejected :
    DistanceDerivedTrace.run selectedStore
      [{selectedUpdate with before := some "DISJ:3093901"}] = none := by decide

/- Derived held-out shape: three dependent slots and a nonzero owner phase.
   It tests structural preservation, not natural-corpus coverage. -/
def heldout : Group :=
  { representative with
    phase := 7
    branch := [1,0]
    slots := [⟨11,0,"T",[]⟩,⟨12,1,"T",[11]⟩,⟨13,2,"T",[11,12]⟩] }
theorem heldout_preserves_dependent_group :
    structuralAdmission representativeHead heldout heldout = true := by decide

theorem erasing_disjointness_changes_meaning :
    sourceAllDisjoint (fun _ : Unit => True) (fun _ _ => False) ∧
    ¬ (∀ _x _y : Unit, False) := by
  constructor
  · intro x y _ _ different
    exact False.elim (different (Subsingleton.elim _ _))
  · intro h; exact h () ()

end StructuralDeclarationTyping
