import DeclarationReplay
import CoursesPaidData

/- A finite, receipt-bound model of the inv5 declaration and matrix witnesses. -/
namespace CoursesPaidAlignmentTie
open DeclarationReplay CoursesPaidData

inductive Path where
  | gapProject | gapSome | keepPerson | twoUpdates | keepProject
  deriving DecidableEq

def allPaths : List Path := [.gapProject, .gapSome, .keepPerson, .twoUpdates, .keepProject]
def index : Path → Nat
  | .gapProject => 0 | .gapSome => 1 | .keepPerson => 2 | .twoUpdates => 3 | .keepProject => 4

/-- Occurrences are zero-based within an endpoint. Tuple codes 0, 1, 2 denote
    ALL Person, ALL Project, and SOME Person respectively. -/
def person : Atom := ⟨0, 0⟩
def project : Atom := ⟨1, 1⟩
def targetProject : Atom := ⟨0, 1⟩
def somePerson : Atom := ⟨1, 2⟩
def targetPerson : Atom := ⟨2, 0⟩
def source : List Atom := [person, project]
def target : List Atom := [targetProject, somePerson, targetPerson]

def prefixProgram : Path → List Edit
  | .gapProject => [.insert targetProject, .pair person somePerson, .pair project targetPerson]
  | .gapSome => [.pair person targetProject, .insert somePerson, .pair project targetPerson]
  | .keepPerson => [.insert targetProject, .insert somePerson, .pair person targetPerson, .delete project]
  | .twoUpdates => [.pair person targetProject, .pair project somePerson, .insert targetPerson]
  | .keepProject => [.delete person, .pair project targetProject, .insert somePerson, .insert targetPerson]

theorem every_prefix_replays_at_three (p : Path) :
    replay source (prefixProgram p) = some (target, 3) := by
  cases p <;> decide

/-- With the same linkedness and permutation, the native candidates can replace
    an equal-cost incumbent if the new path carries the prior alignment. The
    first visited candidate among otherwise equal choices stays selected. -/
def prefer {α : Type} (charge : α → Nat) (existing : α → Bool) (best next : α) : α :=
  if charge next < charge best ∨
      (charge next = charge best ∧ existing next = true ∧ existing best = false)
  then next else best

theorem charge_prefer {α : Type} (score : α → Nat) (ex : α → Bool) (a b : α) :
    score (prefer score ex a b) = min (score a) (score b) := by
  unfold prefer
  split
  next h =>
    apply (Nat.min_eq_right _).symm
    rcases h with h | ⟨h, _, _⟩
    · exact Nat.le_of_lt h
    · exact Nat.le_of_eq h
  next h =>
    apply (Nat.min_eq_left _).symm
    exact Nat.le_of_not_gt (fun lt => h (Or.inl lt))

theorem fold_keeps_minimum_charge {α : Type} (score : α → Nat) (ex : α → Bool)
    (a : α) (tail : List α) :
    score (tail.foldl (prefer score ex) a) =
      tail.foldl (fun n q => min n (score q)) (score a) := by
  induction tail generalizing a with
  | nil => rfl
  | cons h t ih => simp only [List.foldl_cons, ih, charge_prefer]

theorem changing_only_prior_preserves_charge {α : Type} (score : α → Nat)
    (left right : α → Bool) (a : α) (tail : List α) :
    score (tail.foldl (prefer score left) a) = score (tail.foldl (prefer score right) a) := by
  simp only [fold_keeps_minimum_charge]

def winner (matrixCost : List Nat) (existing : List Bool) : Path :=
  allPaths.tail.foldl
    (prefer (fun p => 3 + matrixCost.getD (index p) 0)
            (fun p => existing.getD (index p) false))
    .gapProject

/-- Both receipts have the same five feasible prefix witnesses. The two arms
    agree on every matrix score at each reference. They disagree on the prior
    empty-paid mapping. In row 826 a third candidate also attains the minimum. -/
theorem exact_attained_tables_and_winners :
    p783Costs = [23,23,22,23,22] ∧ p826Costs = [22,22,21,21,21] ∧
    p783FastExisting = [true,true,true,false,false] ∧
    p783CertifiedExisting = [true,true,false,true,true] ∧
    p826FastExisting = [true,true,true,true,false] ∧ p826CertifiedExisting = p783CertifiedExisting ∧
    winner p783Costs p783FastExisting = .keepPerson ∧
    winner p783Costs p783CertifiedExisting = .keepProject ∧
    winner p826Costs p826FastExisting = .keepPerson ∧
    winner p826Costs p826CertifiedExisting = .twoUpdates := by decide

/-- The empty-paid source has one ALL exchange class. It can be carried
    to target class 0 (Project) or 2 (Person), but not to both distinct
    classes at once. The unassigned branch preserves zero occurrences. -/
inductive ScopeChoice where
  | project | person | unassigned
  deriving DecidableEq

def kept : ScopeChoice → Nat
  | .project | .person => 1
  | .unassigned => 0

def alphaPrefer (cost : ScopeChoice → Nat) (a b : ScopeChoice) : ScopeChoice :=
  if kept a < kept b ∨ (kept a = kept b ∧ cost b < cost a) then b else a

theorem empty_paid_prior_respects_visited_scope (matrixCharge skipCharge : Nat) :
    let charge : ScopeChoice → Nat := fun p =>
      if p = .unassigned then skipCharge else matrixCharge
    [ScopeChoice.person,.unassigned].foldl (alphaPrefer charge) .project = .project ∧
    [ScopeChoice.project,.unassigned].foldl (alphaPrefer charge) .person = .person := by
  simp [List.foldl_cons, alphaPrefer, kept]

theorem reference_body_changes_the_certified_witness
    (choosePrefix : List Atom → List Atom → Path) :
    ¬ (choosePrefix source target = winner p783Costs p783CertifiedExisting ∧
       choosePrefix source target = winner p826Costs p826CertifiedExisting) := by
  rintro ⟨l, r⟩
  have distinct : winner p783Costs p783CertifiedExisting ≠
                  winner p826Costs p826CertifiedExisting := by decide
  exact distinct (l.symm.trans r)

def charge (xs : List MatrixStep) : Nat := (xs.map MatrixStep.cost).sum

/-- These are all ordered matrix actions retained in the two exact native
    failures. Each entry records kind, both paths, and charge. -/
theorem matrix_programs_in_the_actual_receipts :
    p783FastMatrix.length = 18 ∧ p783CertifiedMatrix.length = 18 ∧
    p783FastMatrix ≠ p783CertifiedMatrix ∧
    p783FastMatrix.take 6 = p783CertifiedMatrix.take 6 ∧
    p783FastMatrix[6]? ≠ p783CertifiedMatrix[6]? ∧
    3 + charge p783FastMatrix = 25 ∧ 3 + charge p783CertifiedMatrix = 25 ∧
    p826FastMatrix.length = 12 ∧ p826CertifiedMatrix.length = 17 ∧
    p826FastMatrix.take 2 = p826CertifiedMatrix.take 2 ∧
    p826FastMatrix[2]? ≠ p826CertifiedMatrix[2]? ∧
    3 + charge p826FastMatrix = 24 ∧ 3 + charge p826CertifiedMatrix = 24 := by decide

#print axioms every_prefix_replays_at_three
#print axioms charge_prefer
#print axioms changing_only_prior_preserves_charge
#print axioms exact_attained_tables_and_winners
#print axioms empty_paid_prior_respects_visited_scope
#print axioms reference_body_changes_the_certified_witness
#print axioms matrix_programs_in_the_actual_receipts

end CoursesPaidAlignmentTie
