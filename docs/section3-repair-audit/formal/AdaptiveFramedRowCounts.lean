import AdaptiveMixedRowCounting
import AdaptiveFutureFrames

namespace AdaptiveFramedRowCounts
open AdaptivePhaseAlgebra AdaptiveMixedRowCounting

theorem same_frames (frames : List TimeFrame) (p q : Nat → Prop)
    (each : ∀ i, p i ↔ q i) (t : Nat) : inFrames frames p t ↔ inFrames frames q t := by
  rw [show p = q from funext fun i => propext (each i)]

-- The Analyzer cap is for the varying target carrier, not for the owners
-- or just the tuples seen in the first state of a particular solution.
theorem scoped_rows (form : GuardedForm) (frames : List TimeFrame) (b : Nat)
    (owners : Nat → Rel α) (edge : Nat → BinaryRel α β) (selected : Nat → β → Bool)
    (targets : Nat → List β) (typed : ∀ i u p, edge i u p → owners i u ∧ p ∈ targets i)
    (rows : ∀ i u, Reads (edge i u) (selected i))
    (cap : ∀ i, (targets i).length ≤ form.maxTotal b) (t : Nat) :
    inFrames frames (fun i => qAll (owners i) (fun u => form.source (rows i u) (b+1))) t ↔
    inFrames frames (fun i => AdaptiveHomogeneousRows.uniform (edge i) (fun p => selected i p = true)) t := by
  apply same_frames
  intro i
  rw [every_row]
  have point (u : α) := guarded_source form (rows i u) b
    (Nat.le_trans ((rows i u).fullUnique.length_le_of_subset
      (fun p hp => (typed i u p (((rows i u).fullRead p).mp hp)).2)) (cap i))
  constructor
  · intro h u witness
    obtain ⟨p,hp⟩ := witness
    exact (point u).mp (h u (typed i u p hp.1).1) ⟨p,hp⟩
  · exact fun h u _ => (point u).mpr (h u)

theorem equivalent_frames (form : GuardedForm) (left right : List TimeFrame)
    (same : AdaptiveFutureFrames.key left = AdaptiveFutureFrames.key right) (b : Nat)
    (owners : Nat → Rel α) (edge : Nat → BinaryRel α β) (selected : Nat → β → Bool)
    (targets : Nat → List β) (typed : ∀ i u p, edge i u p → owners i u ∧ p ∈ targets i)
    (rows : ∀ i u, Reads (edge i u) (selected i))
    (cap : ∀ i, (targets i).length ≤ form.maxTotal b) (t : Nat) :
    inFrames left (fun i => qAll (owners i) (fun u => form.source (rows i u) (b+1))) t ↔
    inFrames right (fun i => AdaptiveHomogeneousRows.uniform (edge i) (fun p => selected i p = true)) t :=
  AdaptiveFutureFrames.compare _ _ _ _ same (scoped_rows form [] b owners edge selected targets typed rows cap) t

private def demoTargets (t : Nat) : List Bool := if t = 0 then [true] else [true,false]
private def demoRead (t : Nat) : Reads (fun p => p ∈ demoTargets t) id where
  full := demoTargets t
  yes := (demoTargets t).filter id
  no := (demoTargets t).filter (!·)
  fullUnique := by unfold demoTargets; split <;> decide
  yesUnique := (by unfold demoTargets; split <;> decide : (demoTargets t).Nodup).filter _
  noUnique := (by unfold demoTargets; split <;> decide : (demoTargets t).Nodup).filter _
  fullRead := fun _ => Iff.rfl
  yesRead := by simp
  noRead := by simp

-- A changing posts row has one ad initially, then an ad and a non-ad.
-- Instantiate the same outer ALWAYS, selected-nonzero form and four-bit
-- command as the old-reader rejection probe, with distinct owner/target sorts.
theorem always_instance :
    inFrames [.always] (fun i => qAll (fun _ : Unit => True)
      (fun _ => GuardedForm.selectedNonzero.source (demoRead i) 4)) 0 ↔
    inFrames [.always] (fun i => AdaptiveHomogeneousRows.uniform
      (fun (_ : Unit) p => p ∈ demoTargets i) (fun p => p = true)) 0 :=
  scoped_rows .selectedNonzero [.always] 3 (fun _ _ => True)
    (fun i (_ : Unit) p => p ∈ demoTargets i) (fun _ => id) (fun _ => [true,false])
    (fun _ _ p _ => ⟨trivial,by cases p <;> decide⟩) (fun i _ => demoRead i) (fun _ => by decide) 0

-- Old structural equality rejects these two wrappers even on the same typed row.
theorem reordered_row_instance :
    ([TimeFrame.always,.after] ≠ [.after,.always]) ∧
    (inFrames [.always,.after] (fun i => qAll (fun _ : Unit => True)
      (fun _ => GuardedForm.selectedNonzero.source (demoRead i) 4)) 0 ↔
     inFrames [.after,.always] (fun i => AdaptiveHomogeneousRows.uniform
       (fun (_ : Unit) p => p ∈ demoTargets i) (fun p => p = true)) 0) := by
  constructor
  · intro h; cases h
  · exact equivalent_frames .selectedNonzero [.always,.after] [.after,.always] rfl 3
      (fun _ _ => True) (fun i (_ : Unit) p => p ∈ demoTargets i) (fun _ => id) (fun _ => [true,false])
      (fun _ _ p _ => ⟨trivial,by cases p <;> decide⟩) (fun i _ => demoRead i) (fun _ => by decide) 0

-- One selected and sixteen other tuples at the next state: four-bit zero
-- aliases sixteen, even when no target was present at the initial state.
theorem initial_cap_is_not_global :
    let y : Nat → Nat := fun t => if t = 0 then 0 else 1
    let n : Nat → Nat := fun t => if t = 0 then 0 else 16
    y 0 + n 0 ≤ GuardedForm.differenceZero.maxTotal 3 ∧
      inFrames [.after] (fun t => GuardedForm.differenceZero.holds 4 (y t) (n t)) 0 ∧
      ¬inFrames [.after] (fun t => y t = 0 ∨ n t = 0) 0 := by
  change 0 ≤ 16 ∧ (1 ≠ 0 → BitVec.ofNat 4 16 = BitVec.ofNat 4 0) ∧ ¬(1 = 0 ∨ 16 = 0)
  decide

end AdaptiveFramedRowCounts
