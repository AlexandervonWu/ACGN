import GuardedJoinChain
import FastChainGeometry
import EndpointCanonicalContracts

/- Ordered flexible-arity JOIN ports, not an unguarded associative operator.
   Actual parser types, source/owner/phase correspondence and Java realization
   are checked obligations in the implementation handoff, not assumed results. -/
namespace JoinSeqContract
open ACGN.Section3.DependentChainSequence
open ACGN.ThirdFive.GuardedJoinChain
open ACGN.BoundedFive.DependentJoinGuard (guard)

-- Exact source port identities are carried through the existing sequence
-- constructor; typed-empty operands still have a positive retained arity.
structure PortIdentity where
  occurrence : Nat
  owner : Nat
  phase : Nat
  exactType : Nat
  relationArity : Nat
  slotMap : List (Nat × Nat)
  dependencies : List Nat
  path : List Nat
  deriving DecidableEq

theorem seq_preserves_complete_ports (t : SourceTree PortIdentity .join) :
    (construct t).carrier = .seq ∧ (construct t).elements = sourceLeaves t :=
  ⟨rfl, construction_preserves_source_sequence t⟩

theorem guarded_seq_semantics (s t : Tree Atom)
    (same : sourceLeaves s = sourceLeaves t)
    (accepted : guard .JOIN ((sourceLeaves s).map Operand.arity) = true) :
    eval s = eval t ∧ (construct s).elements = (construct t).elements := by
  exact ⟨accepted_chain_relational_equality s t same accepted,
    by simpa only [construction_preserves_source_sequence] using same⟩

theorem flexible_port_count (t : Tree Atom)
    (accepted : guard .JOIN ((sourceLeaves t).map Operand.arity) = true) :
    2 ≤ (construct t).elements.length := by
  have h := (ACGN.BoundedFive.DependentJoinGuard.join_guard_iff _).mp accepted
  simpa [construction_preserves_source_sequence] using h.1

theorem port_deletion_charge (weight : PortIdentity → Nat)
    (pre post : List PortIdentity) (p : PortIdentity) :
    ((pre ++ p :: post).map weight).sum =
      ((pre ++ post).map weight).sum + weight p :=
  FastChainGeometry.sequence_deletion_charge weight pre post p

-- Exact old Java predicate: alternatives().size() == 1. It rejects a
-- semantically legitimate typed-empty binary operand. New admission must
-- still check arities, every intermediate type, and the source context.
def oldSingleProductGate (products : Nat) : Bool := decide (products = 1)
theorem old_gate_rejects_empty : oldSingleProductGate 0 = false := by decide
theorem typed_empty_binary_is_associative (R T : Relation Atom) (row : List Atom) :
    join (join R (emptyOperand 2 (by decide)).relation) T row ↔
      join R (join (emptyOperand 2 (by decide)).relation T) row :=
  join_rotation R _ T (fun _ h => False.elim h) row
theorem empty_arity_is_not_erased :
    (emptyOperand (Atom := Nat) 1 (by decide)).arity ≠
      (emptyOperand (Atom := Nat) 2 (by decide)).arity := by decide

-- Reference segmentation after guarded left-association. Each inner Seq is
-- an opaque typed port at its enclosing unary-interior barrier.
theorem event82_segment_arities :
    guard .JOIN [1, 3, 1] = true ∧ guard .JOIN [1, 2] = true ∧
      guard .JOIN [1, 3, 1, 2] = false := by
  simp [ACGN.BoundedFive.DependentJoinGuard.guard, ACGN.BoundedFive.DependentJoinGuard.guardWithMinimum,
    ACGN.BoundedFive.DependentJoinGuard.scan]
theorem event109_115_segment_arities :
    guard .JOIN [2, 1] = true ∧ guard .JOIN [1, 3, 2, 1] = true ∧
      guard .JOIN [2, 1, 3, 2, 1] = false := by
  simp [ACGN.BoundedFive.DependentJoinGuard.guard, ACGN.BoundedFive.DependentJoinGuard.guardWithMinimum,
    ACGN.BoundedFive.DependentJoinGuard.scan]
theorem event328_segment_arities :
    guard .JOIN [1, 3, 1] = true ∧ guard .JOIN [1, 3, 1] = true ∧
      guard .JOIN [1, 3, 1, 3, 1] = false := by
  simp [ACGN.BoundedFive.DependentJoinGuard.guard, ACGN.BoundedFive.DependentJoinGuard.guardWithMinimum,
    ACGN.BoundedFive.DependentJoinGuard.scan]

theorem event82_full_context (course student grade : A → Prop)
    (grades : A → A → A → Prop) (enrolled : A → A → Prop) :
    (∀ c, course c → ∀ s, student s → EndpointCanonicalContracts.one
      (fun q => enrolled s q ∧ EndpointCanonicalContracts.courseRight grades grade enrolled c q)) ↔
    (∀ c, course c → ∀ s, student s → EndpointCanonicalContracts.one
      (fun q => enrolled s q ∧ EndpointCanonicalContracts.courseLeft grades grade enrolled c q)) :=
  EndpointCanonicalContracts.event82_full_inv12 course student grade grades enrolled

-- Events109/115 differ in the final qualified projects field, not the first
-- Course.projects field. The two g/h domain occurrences use this same rule.
def gradeRows (courseProjects : A → A → Prop) (grades : A → A → A → Prop)
    (p x g : A) : Prop := ∃ c, courseProjects c p ∧ grades c x g
def projectSource (cp : A → A → Prop) (gr : A → A → A → Prop)
    (tail : A → A → Prop) (p x : A) : Prop :=
  ∃ g, gradeRows cp gr p x g ∧ ∃ q, tail g q ∧ q = p
def projectSeq (cp : A → A → Prop) (gr : A → A → A → Prop)
    (tail : A → A → Prop) (p x : A) : Prop :=
  ∃ q, (∃ g, gradeRows cp gr p x g ∧ tail g q) ∧ q = p

theorem project_tail_rotation (cp : A → A → Prop) (gr : A → A → A → Prop)
    (tail : A → A → Prop) (p x : A) :
    projectSource cp gr tail p x ↔ projectSeq cp gr tail p x :=
  GuardedJoinRotation.local_rotation (gradeRows cp gr p)
    (fun g (_ : Unit) q => tail g q) (fun q (_ : Unit) => q = p) x () ()

def inv15 (project : A → Prop) (domain : A → A → Prop)
    (prev next : A → A → Prop) : Prop :=
  ∀ p, project p → ∀ g, domain p g → ∀ h, domain p h →
    g = h ∨ prev h g ∨ next h g

theorem event109_115_full_context (project : A → Prop)
    (cp : A → A → Prop) (gr : A → A → A → Prop)
    (tail prev next : A → A → Prop) :
    inv15 project (projectSource cp gr tail) prev next ↔
      inv15 project (projectSeq cp gr tail) prev next := by
  have eq : projectSource cp gr tail = projectSeq cp gr tail :=
    funext fun p => funext fun x => propext (project_tail_rotation cp gr tail p x)
  rw [eq]

structure ProjectTyping (grade domain : A → Prop)
    (gr : A → A → A → Prop) (tail : A → A → Prop) : Prop where
  gradesTyped : ∀ c x g, gr c x g → grade g
  tailTyped : ∀ d p, tail d p → domain d
  disjoint : ∀ a, grade a → domain a → False

theorem project_empty_intermediate (grade domain : A → Prop)
    (gr : A → A → A → Prop) (tail : A → A → Prop)
    (typing : ProjectTyping grade domain gr tail)
    (cp : A → A → Prop) (p x q : A) :
    ¬ (∃ g, gradeRows cp gr p x g ∧ tail g q) := by
  rintro ⟨g, ⟨c, _, hg⟩, ht⟩
  exact typing.disjoint g (typing.gradesTyped c x g hg) (typing.tailTyped g q ht)

def courseProjects (c p : Fin 4) : Prop := c = 0 ∧ p = 3
def personProjects (x p : Fin 4) : Prop := x = 1 ∧ p = 3
def gradesInstance (c x g : Fin 4) : Prop := c = 0 ∧ x = 1 ∧ g = 2
theorem event109_typed_instance :
    ProjectTyping (fun a : Fin 4 => a = 2) (fun a => a = 0)
      gradesInstance courseProjects := by
  constructor
  · intro c x g h; exact h.2.2
  · intro d p h; exact h.1
  · intro a hg hd; have h : (2 : Fin 4) = 0 := hg.symm.trans hd; contradiction
theorem event115_typed_instance :
    ProjectTyping (fun a : Fin 4 => a = 2) (fun a => a = 1)
      gradesInstance personProjects := by
  constructor
  · intro c x g h; exact h.2.2
  · intro d p h; exact h.1
  · intro a hg hd; have h : (2 : Fin 4) = 1 := hg.symm.trans hd; contradiction
theorem event109_115_nonvacuous_fields :
    gradeRows courseProjects gradesInstance 3 1 2 ∧
      courseProjects 0 3 ∧ personProjects 1 3 := by
  exact ⟨⟨0, ⟨rfl, rfl⟩, ⟨rfl, rfl, rfl⟩⟩, ⟨rfl, rfl⟩, ⟨rfl, rfl⟩⟩
theorem qualified_project_fields_not_interchangeable :
    courseProjects 0 3 ∧ ¬ personProjects 0 3 := by
  simp [courseProjects, personProjects]

-- Event328: ((i.trans).Event) is an explicit unary (typed-empty) segment.
-- trans is ternary; the outer rotation retains its Event column.
def stateHead (trans : A → A → A → Prop) (event : A → Prop) (i e : A) : Prop :=
  ∃ s, trans i e s ∧ event s
def stateSource (trans : A → A → A → Prop) (event : A → Prop) (i s e : A) : Prop :=
  ∃ b, stateHead trans event i b ∧ ∃ c, trans b e c ∧ c = s
def stateSeq (trans : A → A → A → Prop) (event : A → Prop) (i s e : A) : Prop :=
  ∃ c, (∃ b, stateHead trans event i b ∧ trans b e c) ∧ c = s
theorem event328_rotation (trans : A → A → A → Prop)
    (event : A → Prop) (i s e : A) :
    stateSource trans event i s e ↔ stateSeq trans event i s e :=
  GuardedJoinRotation.local_rotation (fun (_ : Unit) b => stateHead trans event i b)
    trans (fun c (_ : Unit) => c = s) () e ()
theorem event328_full_context (state init event : A → Prop) (trans : A → A → A → Prop) :
    (∀ s, state s → ∀ i, init i → ∃ e, stateSource trans event i s e) ↔
    (∀ s, state s → ∀ i, init i → ∃ e, stateSeq trans event i s e) := by
  have eq : stateSource trans event = stateSeq trans event :=
    funext fun i => funext fun s => funext fun e => propext (event328_rotation trans event i s e)
  rw [eq]
structure StateTyping (state event : A → Prop) (trans : A → A → A → Prop) : Prop where
  typed : ∀ i e s, trans i e s → state i ∧ event e ∧ state s
  disjoint : ∀ a, state a → event a → False
theorem event328_empty_head (state event : A → Prop) (trans : A → A → A → Prop)
    (typing : StateTyping state event trans) (i e : A) :
    ¬ stateHead trans event i e := by
  rintro ⟨s, ht, he⟩
  exact typing.disjoint s (typing.typed i e s ht).2.2 he
def transition (i e s : Fin 3) : Prop := i = 0 ∧ e = 2 ∧ s = 1
theorem event328_typed_instance :
    StateTyping (fun a : Fin 3 => a = 0 ∨ a = 1) (fun a => a = 2) transition := by
  constructor
  · intro i e s h; exact ⟨Or.inl h.1, h.2.1, Or.inr h.2.2⟩
  · intro a hs he; rcases hs with h | h
    · have bad : (0 : Fin 3) = 2 := h.symm.trans he; contradiction
    · have bad : (1 : Fin 3) = 2 := h.symm.trans he; contradiction
theorem event328_nonvacuous_transition : transition 0 2 1 := ⟨rfl, rfl, rfl⟩

-- Numeric old-gate instances below are linked to the real parser/Java gate by
-- the hashed handoff evidence. They do not alone discharge Java correspondence.
theorem all_four_old_empty_gates_reject :
    [82, 109, 115, 328].map (fun _ => oldSingleProductGate 0) =
      [false, false, false, false] := by decide

end JoinSeqContract
