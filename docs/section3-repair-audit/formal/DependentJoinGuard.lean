import Std

namespace ACGN.BoundedFive.DependentJoinGuard

/- A2-06: the arity scan shared by DependentChainTheory.requireSoundFlattening
   and SemanticEvidenceVerifier.requireSoundDependentFlattening, after their
   respective operand-validation boundaries. A Nat is the retained arity of
   one exact source relation family, including a typed-empty family. This is
   not a model of GraphType, ExactType, parser replay, or JOIN type folding.
   Java/compiler extraction and bounded execution are separate evidence.
   Named external preconditions (not assertions proved in this file):
   ProducerExactRelationFamilyArities: all operands pass the producer's
   null/isRelationFamily checks, and AlloyTypeBridge.relationArity supplies
   their exact retained arities in source order.
   VerifierExactRelationFamilyArities: replay validates the ExactType operands,
   and SemanticReplay.relationArity is non-null and supplies their exact
   retained arities in source order. No generic Boolean "typed" flag establishes
   either precondition, nor does this arity theorem prove helper decoding.

   Zero-based loop coordinates: start 1; index + 1 < length; increment 1;
   reject arity < 2. Nat arithmetic models these coordinates; the bounds below
   justify index + 1 for supported Java list sizes, not whole-JVM refinement.
   No missing source type is assigned a default carrier or arity. -/

inductive ChainKind where
  | JOIN
  | ARROW
  deriving DecidableEq, Repr

/- The invariant also covers the final failed condition test. A successful
   iteration computes the same index + 1 for index++, preserving the bound. -/
theorem java_index_add_one_fits_int (arities : List Nat) (index : Nat)
    (lengthBound : arities.length <= 2147483647)
    (indexBound : index <= arities.length - 1) :
    index + 1 <= 2147483647 := by omega

theorem loop_start_in_bounds (arities : List Nat) (admitted : 2 <= arities.length) :
    1 <= arities.length - 1 := by omega

theorem loop_step_preserves_bound (arities : List Nat) (index : Nat)
    (active : index + 1 < arities.length) :
    index + 1 <= arities.length - 1 := by omega

def scan (minimum : Nat) (arities : List Nat) (index : Nat) : Bool :=
  if h : index + 1 < arities.length then
    decide (minimum <= arities[index]'(by omega)) && scan minimum arities (index + 1)
  else true
termination_by arities.length - index
decreasing_by omega

def AllFrom (minimum : Nat) (arities : List Nat) (start : Nat) : Prop :=
  forall index, start <= index -> forall h : index + 1 < arities.length,
    minimum <= arities[index]'(by omega)

theorem scan_iff_all_from (minimum : Nat) (arities : List Nat) (start : Nat) :
    scan minimum arities start = true <-> AllFrom minimum arities start := by
  rw [scan]
  split
  next h =>
    rw [Bool.and_eq_true, decide_eq_true_eq, scan_iff_all_from minimum arities (start + 1)]
    constructor
    · rintro ⟨head, tail⟩ index lower upper
      by_cases equal : index = start
      · subst index
        exact head
      · exact tail index (by omega) upper
    · intro all
      exact ⟨all start (by omega) h, fun index lower upper =>
        all index (by omega) upper⟩
  next h =>
    constructor
    · intro _ index lower upper
      omega
    · intro _
      rfl
termination_by arities.length - start
decreasing_by omega

def guardWithMinimum (minimum : Nat) (kind : ChainKind) (arities : List Nat) : Bool :=
  if arities.length < 2 then false
  else if kind = .JOIN && arities.length > 2 then scan minimum arities 1
  else true

def guard (kind : ChainKind) (arities : List Nat) : Bool :=
  guardWithMinimum 2 kind arities

theorem short_chain_rejected (kind : ChainKind) (arities : List Nat)
    (short : arities.length < 2) : guard kind arities = false := by
  simp [guard, guardWithMinimum, short]

theorem join_guard_with_minimum_iff (minimum : Nat) (arities : List Nat) :
    guardWithMinimum minimum .JOIN arities = true <->
      2 <= arities.length ∧ AllFrom minimum arities 1 := by
  by_cases short : arities.length < 2
  · simp [guardWithMinimum, short, show ¬ 2 <= arities.length by omega]
  · by_cases long : 2 < arities.length
    · simp [guardWithMinimum, short, long, scan_iff_all_from,
        show 2 <= arities.length by omega]
    · have all : AllFrom minimum arities 1 := by
        intro index lower upper
        omega
      simp [guardWithMinimum, short, long, all, show 2 <= arities.length by omega]

theorem guard_with_minimum_iff (minimum : Nat) (kind : ChainKind) (arities : List Nat) :
    guardWithMinimum minimum kind arities = true <->
      2 <= arities.length ∧ (kind = .JOIN -> AllFrom minimum arities 1) := by
  cases kind
  · simpa using join_guard_with_minimum_iff minimum arities
  · simp [guardWithMinimum, Nat.not_lt]

theorem join_guard_iff (arities : List Nat) :
    guard .JOIN arities = true <->
      2 <= arities.length ∧ AllFrom 2 arities 1 :=
  join_guard_with_minimum_iff 2 arities

theorem arrow_guard_iff (arities : List Nat) :
    guard .ARROW arities = true <-> 2 <= arities.length := by
  simp [guard, guardWithMinimum, Nat.not_lt]

theorem guard_iff (kind : ChainKind) (arities : List Nat) :
    guard kind arities = true <->
      2 <= arities.length ∧ (kind = .JOIN -> AllFrom 2 arities 1) :=
  guard_with_minimum_iff 2 kind arities

/- Generated source checks must prove extractedMinimum = 2 from the actual
   extraction, separately for each guard. A threshold of 3 still has the
   general scan theorem, but cannot discharge this equality. -/
theorem extracted_guard_iff (extractedMinimum : Nat) (threshold : extractedMinimum = 2)
    (kind : ChainKind) (arities : List Nat) :
    guardWithMinimum extractedMinimum kind arities = true <->
      2 <= arities.length ∧ (kind = .JOIN -> AllFrom 2 arities 1) := by
  subst extractedMinimum
  exact guard_iff kind arities

/- An independent slice specification, like Java subList(1, size - 1).
   The length precondition remains separate from this vacuous all-match. -/
theorem interiors_iff_slice (minimum : Nat) (arities : List Nat) :
    AllFrom minimum arities 1 <->
      ((arities.drop 1).dropLast.all fun arity => decide (minimum <= arity)) = true := by
  rw [List.all_eq_true]
  constructor
  · intro all arity member
    obtain ⟨index, bound, equal⟩ := List.mem_iff_getElem.mp member
    have upper : 1 + index + 1 < arities.length := by
      simp only [List.length_dropLast, List.length_drop] at bound
      omega
    have checked := all (1 + index) (by omega) upper
    simp only [List.getElem_dropLast, List.getElem_drop] at equal
    simpa [equal] using checked
  · intro all index lower upper
    have bound : index - 1 < (arities.drop 1).dropLast.length := by
      simp only [List.length_dropLast, List.length_drop]
      omega
    have checked := all _ (List.getElem_mem bound)
    simpa only [List.getElem_dropLast, List.getElem_drop,
      show 1 + (index - 1) = index by omega, decide_eq_true_eq] using checked

theorem join_guard_iff_slice (arities : List Nat) :
    guard .JOIN arities = true <-> 2 <= arities.length ∧
      ((arities.drop 1).dropLast.all fun arity => decide (2 <= arity)) = true := by
  rw [join_guard_iff, interiors_iff_slice]

theorem endpoints_exempt (first last : Nat) (middle : List Nat) :
    guard .JOIN (first :: (middle ++ [last])) = true <->
      forall arity, arity ∈ middle -> 2 <= arity := by
  rw [join_guard_iff_slice]
  simp

theorem two_operands_accepted (kind : ChainKind) (first last : Nat) :
    guard kind [first, last] = true := by
  cases kind <;> simp [guard, guardWithMinimum]

theorem small_interior_rejected (arities : List Nat) (index : Nat)
    (lower : 1 <= index) (upper : index + 1 < arities.length)
    (small : arities[index]'(by omega) < 2) : guard .JOIN arities = false := by
  cases value : guard .JOIN arities
  · rfl
  · have checked := (join_guard_iff arities).mp value
    have large := checked.2 index lower upper
    omega

end ACGN.BoundedFive.DependentJoinGuard

#print axioms ACGN.BoundedFive.DependentJoinGuard.java_index_add_one_fits_int
#print axioms ACGN.BoundedFive.DependentJoinGuard.loop_start_in_bounds
#print axioms ACGN.BoundedFive.DependentJoinGuard.loop_step_preserves_bound
#print axioms ACGN.BoundedFive.DependentJoinGuard.scan_iff_all_from
#print axioms ACGN.BoundedFive.DependentJoinGuard.short_chain_rejected
#print axioms ACGN.BoundedFive.DependentJoinGuard.join_guard_with_minimum_iff
#print axioms ACGN.BoundedFive.DependentJoinGuard.guard_with_minimum_iff
#print axioms ACGN.BoundedFive.DependentJoinGuard.join_guard_iff
#print axioms ACGN.BoundedFive.DependentJoinGuard.arrow_guard_iff
#print axioms ACGN.BoundedFive.DependentJoinGuard.guard_iff
#print axioms ACGN.BoundedFive.DependentJoinGuard.extracted_guard_iff
#print axioms ACGN.BoundedFive.DependentJoinGuard.interiors_iff_slice
#print axioms ACGN.BoundedFive.DependentJoinGuard.join_guard_iff_slice
#print axioms ACGN.BoundedFive.DependentJoinGuard.endpoints_exempt
#print axioms ACGN.BoundedFive.DependentJoinGuard.two_operands_accepted
#print axioms ACGN.BoundedFive.DependentJoinGuard.small_interior_rejected
