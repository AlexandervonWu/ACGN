import DeclarationReplay

namespace TemporalDeclarationTie
open DeclarationReplay

/-- In the temporal station witness, both programs transform the original
    declarations into ALL Track, ALL Train. Their charged edits and their
    uncharged kept occurrences differ. -/
theorem both_station_programs_replay
    (allTrain someTrack allTrack allTrain' : Atom)
    (keepTrain : allTrain.tuple = allTrain'.tuple)
    (firstUpdate : allTrain.tuple ≠ allTrack.tuple)
    (secondUpdate : someTrack.tuple ≠ allTrain'.tuple) :
    let coherent := [Edit.insert allTrack, .pair allTrain allTrain', .delete someTrack]
    let paid := [Edit.pair allTrain allTrack, .pair someTrack allTrain']
    replay [allTrain, someTrack] coherent = some ([allTrack, allTrain'], 2) ∧
    replay [allTrain, someTrack] paid = some ([allTrack, allTrain'], 2) ∧
    coherent.length = 3 ∧ paid.length = 2 ∧ coherent ≠ paid := by
  have remaining : allTrain'.tuple ≠ allTrack.tuple := keepTrain ▸ firstUpdate
  simp [replay, keepTrain, remaining, secondUpdate]

/-- A fixed coherent witness may break a cost tie only if it is eligible.
    Witness values are opaque here; each carries its own native replay. -/
def choose {α : Type} (cost : α → Nat) (coherent paid : α) (eligible : Bool) : α :=
  if cost coherent < cost paid ∨ (cost coherent = cost paid ∧ eligible = true)
    then coherent else paid

theorem cost_is_minimum {α : Type} (cost : α → Nat) (coherent paid : α) (eligible : Bool) :
    cost (choose cost coherent paid eligible) = min (cost coherent) (cost paid) := by
  by_cases less : cost coherent < cost paid
  · simp [choose, less, Nat.min_eq_left (Nat.le_of_lt less)]
  · by_cases equal : cost coherent = cost paid
    · cases eligible <;> simp [choose, equal]
    · have betterPaid : cost paid < cost coherent := by omega
      simp [choose, less, equal, Nat.min_eq_right (Nat.le_of_lt betterPaid)]

theorem chooses_eligible_coherent_on_tie {α : Type} (cost : α → Nat) (coherent paid : α)
    (equal : cost coherent = cost paid) : choose cost coherent paid true = coherent := by
  simp [choose, equal]

theorem preserves_strictly_cheaper_paid {α : Type} (cost : α → Nat) (coherent paid : α)
    (cheaper : cost paid < cost coherent) (eligible : Bool) :
    choose cost coherent paid eligible = paid := by
  have notLess : ¬ cost coherent < cost paid := by omega
  have distinct : cost coherent ≠ cost paid := by omega
  simp [choose, notLess, distinct]

#print axioms both_station_programs_replay
#print axioms cost_is_minimum
#print axioms chooses_eligible_coherent_on_tie
#print axioms preserves_strictly_cheaper_paid
end TemporalDeclarationTie
