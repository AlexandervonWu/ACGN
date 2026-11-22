import DeclarationKeepTransport
import SeparatePrefixExchange

namespace SamePhasePrefixGrouping
open SelectedDeclarationCompletion

-- A source coordinate is retained as provenance, not used as the semantic
-- identity of a slot after an independent prefix has been regrouped.
structure Slot where
  binding : Binding
  block : Nat
  tuple : List Nat
  tupleSlot : Nat
  authentic : Bool
  deriving DecidableEq

def rigid (s : Slot) : Bool :=
  (s.binding.origin.quantifier != "ALL" && s.binding.origin.quantifier != "SOME") ||
    s.binding.origin.disjointness != 0

def checked (a b : Slot) : Bool :=
  a.authentic && b.authentic &&
  DeclarationKeepTransport.samePayload a.binding.origin b.binding.origin &&
  a.binding.origin.dependencies.isEmpty && b.binding.origin.dependencies.isEmpty &&
  a.block == b.block &&
  (!rigid a || (a.tuple == b.tuple && a.tupleSlot == b.tupleSlot))

def oldPathGate (a b : Slot) : Bool :=
  a.binding.origin.occurrence == b.binding.origin.occurrence

theorem checked_payload (a b : Slot) (h : checked a b = true) :
    DeclarationKeepTransport.samePayload a.binding.origin b.binding.origin = true := by
  simp_all only [checked, Bool.and_eq_true]

theorem checked_type_phase_owner (a b : Slot) (h : checked a b = true) :
    a.binding.origin.exactType = b.binding.origin.exactType ∧
    a.binding.origin.phase = b.binding.origin.phase ∧
    a.binding.origin.owner = b.binding.origin.owner := by
  have hp := checked_payload a b h
  simp_all only [DeclarationKeepTransport.samePayload, Bool.and_eq_true, beq_iff_eq]
  trivial

theorem checked_rigid_tuple (a b : Slot) (h : checked a b = true)
    (hr : rigid a = true) : a.tuple = b.tuple ∧ a.tupleSlot = b.tupleSlot := by
  simp_all [checked]

theorem independent_all_group {A B : Type} (d : A → Prop) (e : B → Prop)
    (body : A → B → Prop) :
    (∀ a, d a → ∀ b, e b → body a b) ↔
      ∀ ab : A × B, d ab.1 ∧ e ab.2 → body ab.1 ab.2 := by
  constructor
  · intro h ab hd; exact h ab.1 hd.1 ab.2 hd.2
  · intro h a ha b hb; exact h (a,b) ⟨ha,hb⟩

theorem independent_some_group {A B : Type} (d : A → Prop) (e : B → Prop)
    (body : A → B → Prop) :
    (∃ a, d a ∧ ∃ b, e b ∧ body a b) ↔
      ∃ ab : A × B, (d ab.1 ∧ e ab.2) ∧ body ab.1 ab.2 := by
  constructor
  · rintro ⟨a,ha,b,hb,h⟩; exact ⟨(a,b),⟨ha,hb⟩,h⟩
  · rintro ⟨⟨a,b⟩,⟨ha,hb⟩,h⟩; exact ⟨a,ha,b,hb,h⟩

-- Applying these equations recursively does not cross a surrounding phase or
-- another quantifier. A surrounding context consumes the same proposition.
theorem context_congruence (context : Prop → Prop) (a b : Prop) (h : a ↔ b) :
    context a ↔ context b := by rw [propext h]

theorem phase_congruence {Time : Type} (temporal : (Time → Prop) → Prop)
    (a b : Time → Prop) (h : ∀ t, a t ↔ b t) : temporal a ↔ temporal b := by
  have eq : a = b := funext (fun t => propext (h t))
  rw [eq]

-- Presentation exchanges carry values with their types; they never exchange
-- a Course value with a Person value in a fixed slot.
theorem typed_exchange {A B : Type} (d : A → Prop) (e : B → Prop)
    (body : A → B → Prop) :
    (∀ a, d a → ∀ b, e b → body a b) ↔
      ∀ b, e b → ∀ a, d a → body a b :=
  SeparatePrefixExchange.independent_all_exchange d e body

theorem selected_read {Value : String → Type} (types : Nat → String)
    (env : (i : Nat) → Value (types i)) (forward back : Nat → Nat)
    (i : Nat) (h : back (forward i) = i) :
    HEq (DeclarationKeepTransport.transported types env back (forward i)) (env i) :=
  DeclarationKeepTransport.typed_read_roundtrip types env forward back i h

theorem retained_minimum (old added : Nat) : min old added ≤ old :=
  DeclarationKeepTransport.retained_candidate_minimum old added

def lone (p : G → Prop) : Prop := ∀ x y, p x → p y → x = y

-- Exact natural inv12 body, over arbitrary, possibly empty, typed carriers.
theorem courses_group {Course Person Grade : Type} (grades : Course → Person → Grade → Prop) :
    (∀ c : Course, ∀ p : Person, lone (grades c p)) ↔
      ∀ cp : Course × Person, lone (grades cp.1 cp.2) := by
  constructor
  · intro h cp; exact h cp.1 cp.2
  · intro h c p; exact h (c,p)

theorem courses_exchange {Course Person Grade : Type} (grades : Course → Person → Grade → Prop) :
    (∀ c : Course, ∀ p : Person, lone (grades c p)) ↔
      ∀ p : Person, ∀ c : Course, lone (grades c p) := by
  constructor <;> intro h a b <;> exact h b a

-- LONE must NOT be flattened like ALL: one witness per row can coexist with
-- several witnesses in the product. This is the preserved rigid-tuple barrier.
theorem nested_lone_is_not_grouped :
    (∀ x : Bool, lone (fun y : Bool => x = y)) ∧
    ¬ lone (fun xy : Bool × Bool => xy.1 = xy.2) := by
  constructor
  · intro x y z hy hz; exact hy.symm.trans hz
  · intro h
    have bad := h (false,false) (true,true) rfl rfl
    cases bad

def gradeOrigin : Origin :=
  ⟨"f51fcb064dd266c72557e26339e3d10e0f01d9f74226291c6aa2180a168fcb3e",
   "inv12", "root/predicate[0]/body[1]/body[1]/decl[0]@pos", "", 0,
   "MATRIX", [], [], "AlloyCarrier(Grade)",
   "19:alloy-binder-domain[1:5:Grade]{0:}", "LONE", "ONE", 0⟩
def nested : Slot := ⟨⟨gradeOrigin,2,2,2⟩,1,[2],0,true⟩
def grouped : Slot := { nested with binding.origin := { gradeOrigin with
  sourceHash := "3e9bcfbf8472dc93d0300bd5c49ce3c43cf1b0e1baf265bf1b9aeb7b3efd1676"
  occurrence := "root/predicate[0]/body[2]/decl[0]@pos" } }

theorem actual_old_rejection : oldPathGate nested grouped = false := by decide
theorem actual_new_acceptance : checked nested grouped = true := by decide
theorem actual_reverse_acceptance : checked grouped nested = true := by decide
theorem foreign_phase : checked nested { grouped with binding.origin.phase := 1 } = false := by decide
theorem foreign_owner : checked nested { grouped with binding.origin.owner := "foreign" } = false := by decide
theorem foreign_type : checked nested { grouped with binding.origin.exactType := "AlloyCarrier(Person)" } = false := by decide
theorem dependency_barrier : checked nested { grouped with binding.origin.dependencies := [0] } = false := by decide
theorem quantifier_barrier : checked nested { grouped with binding.origin.quantifier := "ONE" } = false := by decide
theorem tuple_barrier : checked nested { grouped with tuple := [1,2], tupleSlot := 1 } = false := by decide
theorem unauthenticated : checked nested { grouped with authentic := false } = false := by decide
theorem block_barrier : checked nested { grouped with block := 0 } = false := by decide

end SamePhasePrefixGrouping
