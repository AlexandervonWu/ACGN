import Category72Contracts
import PaidDeclarationAlignment

/- A selected declaration edit may retain slots from distinct old blocks in
   one target block. This is correspondence after an edit, NOT an exchange of
   source quantifiers. The old candidates and all declaration charges remain.
   A newly selected map requires freshly captured matrix decisions and replay. -/
namespace DeclarationKeepTransport
open SelectedDeclarationCompletion

def samePayload (a b : Origin) : Bool :=
  a.phase == b.phase && a.owner == b.owner && a.role == b.role &&
  a.branch == b.branch && a.dependencies == b.dependencies &&
  a.exactType == b.exactType && a.domain == b.domain &&
  a.quantifier == b.quantifier && a.cardinality == b.cardinality &&
  a.disjointness == b.disjointness

def checkedKeep (source target : List Binding) (a b : Binding) : Bool :=
  associated source a.vectorIndex a && associated target b.vectorIndex b &&
  samePayload a.origin b.origin

theorem keep_has_original_endpoints (source target : List Binding) (a b : Binding)
    (checked : checkedKeep source target a b = true) :
    source[a.vectorIndex]? = some a ∧ target[b.vectorIndex]? = some b := by
  simp only [checkedKeep, Bool.and_eq_true] at checked
  exact ⟨(associated_exact _ _ _ checked.1.1).1,
    (associated_exact _ _ _ checked.1.2).1⟩

theorem keep_has_same_type_and_owner (source target : List Binding) (a b : Binding)
    (checked : checkedKeep source target a b = true) :
    a.origin.exactType = b.origin.exactType ∧ a.origin.phase = b.origin.phase ∧
    a.origin.owner = b.origin.owner ∧ a.origin.dependencies = b.origin.dependencies := by
  simp_all only [checkedKeep, samePayload, Bool.and_eq_true, beq_iff_eq]
  trivial

-- Typed read transport uses the inverse of an injective occurrence map. It
-- neither changes the predicate body nor asserts equivalence of edited binders.
def transported {Value : String → Type} (types : Nat → String)
    (environment : (i : Nat) → Value (types i)) (back : Nat → Nat) :
    (j : Nat) → Value (types (back j)) := fun j => environment (back j)

theorem typed_read_roundtrip {Value : String → Type} (types : Nat → String)
    (environment : (i : Nat) → Value (types i)) (forward back : Nat → Nat)
    (source : Nat) (inverse : back (forward source) = source) :
    HEq (transported types environment back (forward source)) (environment source) := by
  have readCongruence : ∀ i j, i = j → HEq (environment i) (environment j) := by
    intro i j equal
    cases equal
    rfl
  exact readCongruence _ _ inverse

theorem read_list_roundtrip {Value : Type} (environment : Nat → Value)
    (forward back : Nat → Nat) (reads : List Nat)
    (inverse : ∀ source ∈ reads, back (forward source) = source) :
    reads.map (fun source => environment (back (forward source))) = reads.map environment := by
  apply List.map_congr_left
  intro source member
  rw [inverse source member]

-- Capturing all diagonals does not change the existing declaration replay.
-- PaidDeclarationAlignment still emits paid links only on changed tuples.
theorem zero_keep_is_not_a_new_payment (a b : PaidDeclarationAlignment.Atom)
    (same : a.tuple = b.tuple) :
    PaidDeclarationAlignment.replay [a] [.pair a b] = some ([b], 0, []) :=
  PaidDeclarationAlignment.zero_diagonal_not_paid a b same

theorem retained_candidate_minimum (old added : Nat) : min old added ≤ old := Nat.min_le_left _ _

-- The exact all-blocks-injective constraint cannot express this selected
-- deletion: source blocks 0 and 2 both retain a slot in target block 0.
def oldBlockGate (edges : List (Nat × Nat)) : Bool :=
  edges.all fun a => edges.all fun b => decide (a.2 = b.2 → a.1 = b.1)

theorem old_gate_rejects_merged_survivors : oldBlockGate [(0, 0), (2, 0)] = false := by decide

def sourceHash := "a1a764b4525102550866985ae39b7cb27c797aeb6990adb691836c4feb1033f1"
def course : Origin := ⟨sourceHash, "inv13", "root/predicate[0]/decl[0]@pos",
  "", 0, "MATRIX", [], [], "AlloyCarrier(Course)", "19:alloy-binder-domain[1:6:Course]{0:}",
  "ALL", "ONE", 0⟩
def person : Origin := { course with
  exactType := "AlloyCarrier(Person)"
  domain := "19:alloy-binder-domain[1:6:Person]{0:}" }
def a0 : Binding := ⟨course, 0, 0, 0⟩
def a1 : Binding := ⟨{ person with
  quantifier := "SOME"
  occurrence := "root/predicate[0]/body[1]/decl[0]@pos" }, 1, 1, 1⟩
def a2 : Binding := ⟨{ person with occurrence := "root/predicate[0]/body[1]/body[1]/and[0]/decl[0]@pos" }, 2, 2, 2⟩
def b0 : Binding := ⟨{ course with predicate := "inv13c" }, 0, 0, 0⟩
def b1 : Binding := ⟨{ person with predicate := "inv13c", occurrence := "root/predicate[0]/decl[1]@pos" }, 1, 1, 1⟩

theorem concrete_typed_keeps : checkedKeep [a0,a1,a2] [b0,b1] a0 b0 = true ∧
    checkedKeep [a0,a1,a2] [b0,b1] a2 b1 = true := by decide

theorem foreign_phase_rejected :
    checkedKeep [a0,a1,a2] [b0,{ b1 with origin.phase := 1 }] a2
      { b1 with origin.phase := 1 } = false := by decide

theorem foreign_type_rejected :
    checkedKeep [a0,a1,a2] [b0,{ b1 with origin.exactType := "AlloyCarrier(Course)" }] a2
      { b1 with origin.exactType := "AlloyCarrier(Course)" } = false := by decide

def d0 : DeclarationReplay.Atom := ⟨0, 0⟩
def d1 : DeclarationReplay.Atom := ⟨1, 1⟩
def d2 : DeclarationReplay.Atom := ⟨2, 2⟩
def t1 : DeclarationReplay.Atom := ⟨1, 2⟩

theorem concrete_selected_deletion_replays :
    DeclarationReplay.replay [d0,d1,d2] [.pair d0 d0, .delete d1, .pair d2 t1] =
      some ([d0,t1],1) := by decide

theorem concrete_reverse_insertion_replays :
    DeclarationReplay.replay [d0,t1] [.pair d0 d0, .insert d1, .pair t1 d2] =
      some ([d0,d1,d2],1) := by decide

def oldMap : Mapping := fun i => if i = 0 then some 0 else none
def newMap : Mapping := fun i => if i = 2 then some 1 else oldMap i

theorem new_mapping_injective : ∀ i j k, newMap i = some k → newMap j = some k → i = j := by
  intro i j k hi hj
  by_cases i2 : i = 2 <;> by_cases j2 : j = 2 <;>
    by_cases i0 : i = 0 <;> by_cases j0 : j = 0 <;>
    simp_all [newMap, oldMap] <;> omega

theorem mapped_read_must_be_recaptured :
    UnobservedDeclarationCompletion.variableCost oldMap 2 1 = 1 ∧
    UnobservedDeclarationCompletion.variableCost newMap 2 1 = 0 := by decide

-- Concrete carriers need not be inhabited. Surviving Course/Person reads are
-- interpreted in exactly the same original environments after coordinate shift.
def originalTypes (i : Nat) : String := if i = 0 then course.exactType else person.exactType
def forward (i : Nat) : Nat := if i = 2 then 1 else i
def backward (j : Nat) : Nat := if j = 1 then 2 else j

theorem concrete_surviving_reads {Value : String → Type}
    (environment : (i : Nat) → Value (originalTypes i)) (i : Nat)
    (surviving : i = 0 ∨ i = 2) :
    HEq (transported originalTypes environment backward (forward i)) (environment i) := by
  apply typed_read_roundtrip
  rcases surviving with rfl | rfl <;> decide

end DeclarationKeepTransport
