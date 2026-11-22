import GroupedPaidOrbit
import DisjointPaidDeclarationAlignment

/- A permutation of ONE-valued members of one common-domain disjoint group.
   The outer environment is fixed; no dependent, mixed-kind, cross-owner or
   cross-group exchange follows. Source issuance and Java correspondence are
   checked separately. Pairwise disjoint singleton values are injective reads. -/
namespace DisjointGroupPermutation

structure Permutation (I : Type) where
  forward : I → I
  backward : I → I
  leftInverse : ∀ i, backward (forward i) = i
  rightInverse : ∀ i, forward (backward i) = i

def Permutation.inverse (p : Permutation I) : Permutation I :=
  ⟨p.backward, p.forward, p.rightInverse, p.leftInverse⟩

def reindex (p : Permutation I) (v : I → A) : I → A := v ∘ p.forward

theorem reindex_roundtrip (p : Permutation I) (v : I → A) :
    reindex p.inverse (reindex p v) = v := by
  funext i
  exact congrArg v (p.rightInverse i)

def valid (domain : A → Prop) (v : I → A) : Prop :=
  (∀ i, domain (v i)) ∧ Function.Injective v

theorem reindex_valid (p : Permutation I) (domain : A → Prop) (v : I → A)
    (h : valid domain v) : valid domain (reindex p v) := by
  refine ⟨fun i => h.1 (p.forward i), ?_⟩
  intro i j eq
  have ij := congrArg p.backward (h.2 eq)
  simpa only [p.leftInverse] using ij

theorem all_group_permutation (p : Permutation I) (domain : A → Prop)
    (body : (I → A) → Prop) :
    (∀ v, valid domain v → body v) ↔
      ∀ v, valid domain v → body (reindex p v) := by
  constructor
  · intro h v hv
    exact h _ (reindex_valid p domain v hv)
  · intro h v hv
    have result := h (reindex p.inverse v) (reindex_valid p.inverse domain v hv)
    have roundtrip : reindex p (reindex p.inverse v) = v := by
      funext i
      exact congrArg v (p.leftInverse i)
    rwa [roundtrip] at result

theorem some_group_permutation (p : Permutation I) (domain : A → Prop)
    (body : (I → A) → Prop) :
    (∃ v, valid domain v ∧ body v) ↔
      ∃ v, valid domain v ∧ body (reindex p v) := by
  constructor
  · rintro ⟨v, hv, hb⟩
    refine ⟨reindex p.inverse v, reindex_valid p.inverse domain v hv, ?_⟩
    have roundtrip : reindex p (reindex p.inverse v) = v := by
      funext i
      exact congrArg v (p.leftInverse i)
    simpa only [roundtrip] using hb
  · rintro ⟨v, hv, hb⟩
    exact ⟨reindex p v, reindex_valid p domain v hv, hb⟩

theorem empty_domain_some_false (i : I) (body : (I → A) → Prop) :
    ¬ ∃ v, valid (fun _ => False) v ∧ body v := by
  rintro ⟨v, hv, _⟩
  exact hv.1 i

structure Group where
  role : String
  phase : Nat
  owner : String
  path : String
  kind : String
  cardinality : String
  carrier : String
  domain : String
  dependencies : List Nat
  disjoint : Nat
  exchangeClass : Nat
  deriving DecidableEq

structure Binding where
  group : Group
  coordinate : Nat
  orbit : List Nat
  prenex : Bool
  deriving DecidableEq

-- This is the retained certified gate, with the disjoint-zero conjunct removed.
-- Equality here strengthens sameCertifiedPayload by retaining the lexical path.
def retained (a b : Binding) : Prop :=
  a.group = b.group ∧ a.group.role = "MATRIX" ∧
  a.prenex = true ∧ b.prenex = true ∧
  b.coordinate ∈ a.orbit ∧ a.coordinate ∈ b.orbit ∧
  (a.group.kind = "ALL" ∨ a.group.kind = "SOME") ∧
  a.group.cardinality = "ONE" ∧ a.group.dependencies = []

def oldGate (a b : Binding) : Prop := retained a b ∧ a.group.disjoint = 0
def newGate (a b : Binding) : Prop := retained a b

theorem original_owner_phase_type_and_group (a b : Binding) (h : newGate a b) :
    a.group.phase = b.group.phase ∧ a.group.owner = b.group.owner ∧
    a.group.path = b.group.path ∧ a.group.carrier = b.group.carrier ∧
    a.group.domain = b.group.domain ∧ a.group.disjoint = b.group.disjoint := by
  have hg := h.1
  simp only [hg, and_self]

-- Actual projected event136 Work slots, source hash bound to the Java fixture.
def sourceHash : String := "c5fcffc79ce9e4102a44aa3a5be31c3e3c92031fa0c4bb7b6f3c1a81a1b8804f"
def workGroup : Group := ⟨"MATRIX", 0, "", "root/predicate[0]/decl[1]@pos",
  "ALL", "ONE", "AlloyCarrier(Work)", "19:alloy-binder-domain[1:4:Work]{0:}", [], 1, 0⟩
def w1 : Binding := ⟨workGroup, 1, [1, 2], true⟩
def w2 : Binding := ⟨workGroup, 2, [1, 2], true⟩

theorem concrete_old_rejection : ¬ oldGate w1 w2 := by
  intro h
  have bad : (1 : Nat) = 0 := h.2
  contradiction

theorem concrete_new_admission : newGate w1 w2 := by
  simp [newGate, retained, w1, w2, workGroup]

def swap : Permutation Bool := ⟨not, not, Bool.not_not, Bool.not_not⟩

-- The witness body is arbitrary, including the source-visible guard and JOIN
-- tests. Domain may depend on the fixed outer User, but never on another slot
-- in this group. Transport renames every body read; it does not erase a guard.
theorem concrete_work_group_sound (outer : User) (domain : User → Work → Prop)
    (body : User → (Bool → Work) → Prop) :
    (∀ v, valid (domain outer) v → body outer v) ↔
      ∀ v, valid (domain outer) v → body outer (reindex swap v) :=
  all_group_permutation swap (domain outer) (body outer)

theorem foreign_group_rejected (a b : Binding) (h : a.group ≠ b.group) :
    ¬ newGate a b := fun admitted => h admitted.1

example : ¬ newGate w1 {w2 with group := {workGroup with phase := 1}} := by
  simp [newGate, retained, w1, w2, workGroup]
example : ¬ newGate w1 {w2 with group := {workGroup with disjoint := 2}} := by
  simp [newGate, retained, w1, w2, workGroup]
example : ¬ newGate w1 {w2 with orbit := [2]} := by
  simp [newGate, retained, w1, w2, workGroup]

-- Reuse the existing paid-path transport theorem: no new payment is created.
theorem declaration_payment_retained (left right p q : Nat → Nat)
    (hl : ∀ x, left (p x) = left x) (hr : ∀ y, right (q y) = right y)
    (a : GroupedPaidOrbit.Edit) :
    GroupedPaidOrbit.charge left right (GroupedPaidOrbit.move p q a) =
      GroupedPaidOrbit.charge left right a :=
  GroupedPaidOrbit.actual_declaration_action_cost_retained left right p q hl hr a

#print axioms all_group_permutation
#print axioms some_group_permutation
#print axioms concrete_work_group_sound
#print axioms declaration_payment_retained
end DisjointGroupPermutation
