import Std

/- Incident laws only: these do not verify the Java source/certificate bridge. -/
namespace SingletonComposition

theorem or_after_duplicate_and (a b c d : Prop) :
    (a ∨ b ∨ ((c ∨ d) ∧ (d ∨ c))) ↔ (a ∨ b ∨ c ∨ d) := by
  rw [show d ∨ c ↔ c ∨ d from or_comm, and_self]

theorem and_after_duplicate_or (a b c d : Prop) :
    (a ∧ b ∧ ((c ∧ d) ∨ (d ∧ c))) ↔ (a ∧ b ∧ c ∧ d) := by
  rw [show d ∧ c ↔ c ∧ d from and_comm, or_self]

-- The equality of the eliminated operand is an explicit premise, not permission
-- to open an arbitrary invocation, binder, or temporal operator.
theorem certified_or_exposure (a leaf c d : Prop)
    (certificate : leaf ↔ (c ∨ d)) :
    (a ∨ leaf) ↔ ((a ∨ c) ∨ d) := by
  rw [certificate, or_assoc]

theorem certified_and_exposure (a leaf c d : Prop)
    (certificate : leaf ↔ (c ∧ d)) :
    (a ∧ leaf) ↔ ((a ∧ c) ∧ d) := by
  rw [certificate, and_assoc]

-- Permutations preserve multiplicity; equal sets of children are insufficient
-- for a commutative Bag. Seq children are not licensed to use this theorem.
theorem permuted_disjunction {A : Type} (meaning : A → Prop)
    (xs ys : List A) (matching : xs.Perm ys) :
    (∃ x ∈ xs, meaning x) ↔ (∃ y ∈ ys, meaning y) := by
  constructor
  · rintro ⟨x, hx, hp⟩
    exact ⟨x, matching.mem_iff.mp hx, hp⟩
  · rintro ⟨y, hy, hp⟩
    exact ⟨y, matching.mem_iff.mpr hy, hp⟩

theorem permuted_conjunction {A : Type} (meaning : A → Prop)
    (xs ys : List A) (matching : xs.Perm ys) :
    (∀ x ∈ xs, meaning x) ↔ (∀ y ∈ ys, meaning y) := by
  constructor
  · intro h y hy
    exact h y (matching.mem_iff.mpr hy)
  · intro h x hx
    exact h x (matching.mem_iff.mp hx)

#print axioms or_after_duplicate_and
#print axioms and_after_duplicate_or
#print axioms certified_or_exposure
#print axioms certified_and_exposure
#print axioms permuted_disjunction
#print axioms permuted_conjunction
end SingletonComposition
