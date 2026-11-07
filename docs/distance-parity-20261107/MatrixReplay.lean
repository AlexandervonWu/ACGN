import Std

/- Narrow replay contract, not a proof of Java, optimal search, alpha admission,
   or certificate export. A matrix plan is a costed derivation at fixed native
   representatives/bindings. Child occurrences must be consumed exactly once;
   unordered matching does not license multiplicity loss. -/
namespace MatrixReplay

inductive Replay (step : S → S → Nat → Prop) : S → S → Nat → Prop where
  | done (s : S) : Replay step s s 0
  | next : step a b n → Replay step b c m → Replay step a c (n + m)

theorem append (step : S → S → Nat → Prop)
    (ab : Replay step a b n) (bc : Replay step b c m) :
    Replay step a c (n + m) := by
  induction ab with
  | done => simpa using bc
  | next h _ ih => simpa [Nat.add_assoc] using Replay.next h (ih bc)

-- Index permutations retain repeated children as distinct occurrences.
theorem occurrence_count (source consumed : List Nat)
    (coverage : source.Perm consumed) : source.length = consumed.length :=
  coverage.length_eq

theorem no_duplicate_consumption (source consumed : List Nat)
    (unique : source.Nodup) (coverage : source.Perm consumed) :
    consumed.Nodup := coverage.nodup_iff.mp unique

-- Expected endpoints are immutable inputs, not aliases of a mutable receipt.
-- Java must maintain this separation; this model does not prove its heap behavior.
def EndpointsMatch (source target reportedSource reportedTarget : S) : Prop :=
  source = reportedSource ∧ target = reportedTarget

theorem changed_source_rejected (source target reportedSource reportedTarget : S)
    (changed : source ≠ reportedSource) :
    ¬ EndpointsMatch source target reportedSource reportedTarget :=
  fun matched => changed matched.1

-- A whole-phase edit may choose a representative only through admitted evidence.
-- This law does not permit minimizing raw child-deletion charges instead.
theorem admitted_phase_selection (meaning : S → V) (source selected : S)
    (admitted : meaning source = meaning selected) (target : V)
    (replayed : meaning selected = target) : meaning source = target :=
  admitted.trans replayed

-- Backtracing any attaining assignment preserves the native minimum. The
-- Java solver's refinement is tested against bounded exhaustive permutations.
theorem attaining_assignment_cost (native selected replayed : Nat)
    (attains : selected = native) (checked : replayed = selected) :
    replayed = native := checked.trans attains

structure Receipt where
  temporal : Nat
  quantifier : Nat
  matrix : Nat
  replayedMatrix : Nat
  matrixChecked : Bool
  temporalChecked : Bool
  quantifierChecked : Bool
  choicesChecked : Bool
  provenanceChecked : Bool

def complete (r : Receipt) : Bool :=
  r.matrixChecked && decide (r.matrix = r.replayedMatrix) &&
  r.temporalChecked && r.quantifierChecked && r.choicesChecked && r.provenanceChecked

theorem matrix_only_not_complete (r : Receipt) (h : r.quantifierChecked = false) :
    complete r = false := by simp [complete, h]

theorem complete_cost (r : Receipt) (h : complete r = true) :
    r.temporal + r.quantifier + r.matrix =
      r.temporal + r.quantifier + r.replayedMatrix := by
  simp only [complete, Bool.and_eq_true, decide_eq_true_eq] at h
  have hm : r.matrix = r.replayedMatrix := h.1.1.1.1.2
  rw [hm]

#print axioms append
#print axioms occurrence_count
#print axioms no_duplicate_consumption
#print axioms changed_source_rejected
#print axioms admitted_phase_selection
#print axioms attaining_assignment_cost
#print axioms matrix_only_not_complete
#print axioms complete_cost
end MatrixReplay
