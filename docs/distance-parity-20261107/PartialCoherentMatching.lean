import PaidAlignmentExtension

/- Matrix-read descriptors form a partial table, unlike declaration locks.
   A missing descriptor has no free coherent-matching edge. Its declaration,
   selected payment and lock remain in the enclosing alignment unchanged. -/
namespace PartialCoherentMatching

variable {Descriptor : Type}

def candidate (compatible : Descriptor → Descriptor → Bool)
    (left right : Option Descriptor) : Bool :=
  match left, right with
  | some a, some b => compatible a b
  | _, _ => false

def oldCall (compatible : Descriptor → Descriptor → Bool)
    (left right : Option Descriptor) : Option Bool :=
  left.map fun a => candidate compatible (some a) right

theorem missing_left_has_no_edge (compatible : Descriptor → Descriptor → Bool)
    (right : Option Descriptor) : candidate compatible none right = false := by
  cases right <;> rfl

theorem missing_right_has_no_edge (compatible : Descriptor → Descriptor → Bool)
    (left : Option Descriptor) : candidate compatible left none = false := by
  cases left <;> rfl

theorem present_call_unchanged (compatible : Descriptor → Descriptor → Bool)
    (a : Descriptor) (right : Option Descriptor) :
    oldCall compatible (some a) right = some (candidate compatible (some a) right) := rfl

theorem edge_has_descriptors (compatible : Descriptor → Descriptor → Bool)
    (left right : Option Descriptor) (edge : candidate compatible left right = true) :
    left.isSome = true ∧ right.isSome = true := by
  cases left <;> cases right <;> simp_all [candidate]

def Matching (compatible : Descriptor → Descriptor → Bool)
    (left right : Nat → Option Descriptor) (leftNames rightNames : List Nat)
    (links : List (Nat × Nat)) : Prop :=
  (links.map Prod.fst).Nodup ∧ (links.map Prod.snd).Nodup ∧
    ∀ x y, (x, y) ∈ links → x ∈ leftNames ∧ y ∈ rightNames ∧
      candidate compatible (left x) (right y) = true

/- Removing descriptor-less vertices from the search leaves every admissible
   matching, its size, and therefore maximum matching cardinality unchanged.
   This concerns only search vertices, not the retained declaration ledger. -/
theorem matching_domain_restriction (compatible : Descriptor → Descriptor → Bool)
    (left right : Nat → Option Descriptor) (leftNames rightNames : List Nat)
    (links : List (Nat × Nat)) :
    Matching compatible left right leftNames rightNames links ↔
    Matching compatible left right (leftNames.filter fun x => (left x).isSome)
      (rightNames.filter fun y => (right y).isSome) links := by
  constructor
  · rintro ⟨ha, hb, edges⟩
    refine ⟨ha, hb, ?_⟩
    intro x y member
    rcases edges x y member with ⟨hx, hy, edge⟩
    have descriptors := edge_has_descriptors compatible (left x) (right y) edge
    exact ⟨List.mem_filter.mpr ⟨hx, descriptors.1⟩,
      List.mem_filter.mpr ⟨hy, descriptors.2⟩, edge⟩
  · rintro ⟨ha, hb, edges⟩
    refine ⟨ha, hb, ?_⟩
    intro x y member
    rcases edges x y member with ⟨hx, hy, edge⟩
    exact ⟨(List.mem_filter.mp hx).1, (List.mem_filter.mp hy).1, edge⟩

theorem missing_left_never_consumed (compatible : Descriptor → Descriptor → Bool)
    (left right : Nat → Option Descriptor) (leftNames rightNames : List Nat)
    (links : List (Nat × Nat)) (valid : Matching compatible left right leftNames rightNames links)
    (x y : Nat) (missing : left x = none) : (x, y) ∉ links := by
  intro member
  have edge := (valid.2.2 x y member).2.2
  simp [missing, missing_left_has_no_edge] at edge

def maximumSize (valid : List (Nat × Nat) → Prop) (n : Nat) : Prop :=
  (∃ links, valid links ∧ links.length = n) ∧ ∀ links, valid links → links.length ≤ n

theorem maximum_size_unchanged (compatible : Descriptor → Descriptor → Bool)
    (left right : Nat → Option Descriptor) (leftNames rightNames : List Nat) (n : Nat) :
    maximumSize (Matching compatible left right leftNames rightNames) n ↔
    maximumSize (Matching compatible left right (leftNames.filter fun x => (left x).isSome)
      (rightNames.filter fun y => (right y).isSome)) n := by
  simp only [maximumSize, ← matching_domain_restriction]

/- Branch generation: a missing source offers only the unchanged skip branch.
   It does not consume a target, add a free link or delete a declaration lock. -/
def branches (compatible : Descriptor → Descriptor → Bool)
    (left : Option Descriptor) (right : Nat → Option Descriptor)
    (rightNames : List Nat) : List (Option Nat) :=
  none :: (rightNames.filter fun y => candidate compatible left (right y)).map some

theorem missing_left_only_skips (compatible : Descriptor → Descriptor → Bool)
    (right : Nat → Option Descriptor) (rightNames : List Nat) :
    branches compatible none right rightNames = [none] := by
  simp [branches, missing_left_has_no_edge]

/- Reuse the existing unread-KEEP congruence. The selected KEEP can remain in
   the retained alignment even though neither search nor a matrix read uses it. -/
theorem retained_unread_keep_cost (m : Nat → Option Nat) (a b x y : Nat)
    (leftSeen rightSeen : Nat → Prop) (fresh : m a = none)
    (absent : ¬ leftSeen a ∨ ¬ rightSeen b) (lx : leftSeen x) (ry : rightSeen y) :
    UnobservedDeclarationCompletion.variableCost
      (UnobservedDeclarationCompletion.extend m a b) x y =
    UnobservedDeclarationCompletion.variableCost m x y :=
  UnobservedDeclarationCompletion.observed_cost_unchanged m a b x y
    leftSeen rightSeen fresh absent lx ry

def selectExistingOnTie (existing candidateCost : Nat) : Nat :=
  if candidateCost < existing then candidateCost else existing

theorem existing_minimum_retained (existing candidateCost : Nat) :
    selectExistingOnTie existing candidateCost ≤ existing := by
  unfold selectExistingOnTie
  split <;> omega

theorem equal_cost_keeps_existing (cost : Nat) : selectExistingOnTie cost cost = cost := by
  simp [selectExistingOnTie]

#print axioms matching_domain_restriction
#print axioms maximum_size_unchanged
#print axioms missing_left_never_consumed
#print axioms missing_left_only_skips
#print axioms retained_unread_keep_cost
#print axioms existing_minimum_retained
end PartialCoherentMatching
