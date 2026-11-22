import SeparatePrefixExchange
import GroupedPaidOrbit
import JointDeclarationMatrixReplay

/- Retaining an already-admitted attaining orbit does not require equal source
   declaration paths. Original native programs and supplemental transport stay
   distinct. Certificate issuance and Java extraction are checked externally. -/
namespace RetainedPrefixCandidate

structure Slot where
  sourceHash : String
  predicate : String
  occurrence : String
  owner : String
  phase : Nat
  quantifier : String
  multiplicity : String
  carrier : String
  exactType : String
  domain : String
  dependencies : List Nat
  disjoint : Nat
  exchangeClass : Nat
  deriving DecidableEq

-- Literal conjunction of FastDeclarationPermutation.admission, with its
-- caller-owned support/ownership/type-evidence predicates kept explicit.
def oldAdmission (a b : Slot) (supported ownedA ownedB sameEvidence : Bool) : Prop :=
  supported = true ∧ ownedA = true ∧ ownedB = true ∧ a.disjoint = b.disjoint ∧
  (a.quantifier = "ALL" ∨ a.quantifier = "SOME") ∧ a.quantifier = b.quantifier ∧
  a.occurrence = b.occurrence ∧ a.carrier = b.carrier ∧ sameEvidence = true

def sameFrame (a b : Slot) : Prop :=
  a.sourceHash = b.sourceHash ∧ a.predicate = b.predicate ∧ a.owner = b.owner ∧
  a.phase = b.phase ∧ a.quantifier = b.quantifier ∧ a.multiplicity = b.multiplicity ∧
  a.exactType = b.exactType ∧ a.domain = b.domain ∧ a.dependencies = [] ∧
  b.dependencies = [] ∧ a.disjoint = b.disjoint ∧ a.exchangeClass = b.exchangeClass

theorem separate_path_rejected (a b : Slot) (h : a.occurrence ≠ b.occurrence)
    (support ownedA ownedB sameEvidence : Bool) :
    ¬ oldAdmission a b support ownedA ownedB sameEvidence := by
  intro accepted
  exact h accepted.2.2.2.2.2.2.1

theorem independent_all_sound {A B : Type} (d : A → Prop) (e : B → Prop)
    (body : A → B → Prop) :
    (∀ a, d a → ∀ b, e b → body a b) ↔ ∀ b, e b → ∀ a, d a → body a b :=
  SeparatePrefixExchange.independent_all_exchange d e body

theorem independent_some_sound {A B : Type} (d : A → Prop) (e : B → Prop)
    (body : A → B → Prop) :
    (∃ a, d a ∧ ∃ b, e b ∧ body a b) ↔ ∃ b, e b ∧ ∃ a, d a ∧ body a b :=
  SeparatePrefixExchange.independent_some_exchange d e body

-- All declaration operations, including one-sided payments, retain their
-- charges when the existing source-certified equal-tuple order is used.
theorem path_charge_retained (left right p q : Nat → Nat)
    (hl : ∀ x, left (p x) = left x) (hr : ∀ y, right (q y) = right y)
    (path : List GroupedPaidOrbit.Edit) :
    ((path.map (GroupedPaidOrbit.move p q)).map (GroupedPaidOrbit.charge left right)).sum =
      (path.map (GroupedPaidOrbit.charge left right)).sum := by
  induction path with
  | nil => rfl
  | cons a rest ih =>
    simp only [List.map_cons, List.sum_cons]
    rw [GroupedPaidOrbit.actual_declaration_action_cost_retained left right p q hl hr a, ih]

-- The proposed retained score must equal an actual re-scored full-map
-- candidate. Adding its native-program representative cannot change a minimum.
theorem duplicate_attaining_candidate (prior fixed incumbent : Nat) (h : prior = fixed) :
    min prior (min fixed incumbent) = min fixed incumbent := by
  subst prior
  omega

-- Retaining the original program, rather than emitting the permutation as its
-- native choice, must keep each deleted original occurrence in place.
theorem fixed_delete_is_original (p q : Nat → Nat) (i : Nat) (h : p i = i) :
    GroupedPaidOrbit.move p q (.delete i) = .delete i := by
  simp [GroupedPaidOrbit.move, h]

theorem moved_delete_is_different (p q : Nat → Nat) (i : Nat) (h : p i ≠ i) :
    GroupedPaidOrbit.move p q (.delete i) ≠ .delete i := by
  intro same
  change GroupedPaidOrbit.Edit.delete (p i) = .delete i at same
  injection same with equal
  exact h equal

theorem fixed_one_sided_payment (p : Nat → Nat) (path : List GroupedPaidOrbit.Edit)
    (fixed : ∀ i, GroupedPaidOrbit.Edit.delete i ∈ path → p i = i)
    (i : Nat) (member : GroupedPaidOrbit.Edit.delete i ∈ path) :
    GroupedPaidOrbit.move p id (.delete i) = .delete i :=
  fixed_delete_is_original p id i (fixed i member)

-- Literal relational readings of inv10 and inv10c. Guarded Junction and
-- Semaphore membership, dependent succs.j, and both signal uses are retained.
-- No carrier inhabitation or domain equality premise is required.
theorem inv10_exchange {Track Signal : Type} (junction : Track → Prop)
    (semaphore : Signal → Prop) (signals : Track → Signal → Prop) :
    (∀ t : Track, ∀ j : Track, junction j → ∀ s : Signal, semaphore s →
      signals t s ∧ ¬ ∃ z, signals j z) ↔
    (∀ j : Track, junction j → ∀ t : Track, ∀ s : Signal, semaphore s →
      signals t s ∧ ¬ ∃ z, signals j z) := by
  constructor
  · intro h j hj t; exact h t j hj
  · intro h t j hj; exact h j hj t

theorem inv10c_exchange {Track Signal : Type} (junction : Track → Prop)
    (semaphore : Signal → Prop) (succs : Track → Track → Prop)
    (signals : Track → Signal → Prop) :
    (∀ j t : Track, junction j → succs t j → ∃ s, signals t s ∧ semaphore s) ↔
    (∀ t j : Track, junction j → succs t j → ∃ s, signals t s ∧ semaphore s) :=
  JointDeclarationMatrixReplay.all_exchange _

#print axioms separate_path_rejected
#print axioms independent_all_sound
#print axioms independent_some_sound
#print axioms path_charge_retained
#print axioms duplicate_attaining_candidate
#print axioms fixed_delete_is_original
#print axioms moved_delete_is_different
#print axioms fixed_one_sided_payment
#print axioms inv10_exchange
#print axioms inv10c_exchange
end RetainedPrefixCandidate
