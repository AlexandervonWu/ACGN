import Std

/- A lineage is ancestry, not an injective occurrence identity. Each member of
   a projection fiber retains its own source-path proof. Consensus concerns the
   complete typed/owner-bearing plan, not just a printed relation or result type.
   This is a transfer contract, not a proof of the Java implementation. -/
namespace GuardedJoinSourceFiber

structure Occurrence where
  phase : Nat
  path : List Nat
  lineage : Nat
  deriving DecidableEq

structure Plan where
  source : Nat
  target : Nat
  resultType : Nat
  ownerContext : Nat
  profile : Nat
  deriving DecidableEq

structure Premise (meaning : Nat → Prop) where
  occurrence : Occurrence
  plan : Plan
  sound : meaning plan.source ↔ meaning plan.target

def CheckedFiber (meaning : Nat → Prop) (members : List (Premise meaning))
    (plan : Plan) : Prop :=
  members ≠ [] ∧
  (members.map (fun p => p.occurrence)).Nodup ∧
  ∀ p ∈ members, p.plan = plan

theorem every_original_retained (h : CheckedFiber meaning members plan)
    (p : Premise meaning) (member : p ∈ members) :
    meaning p.plan.source ↔ meaning plan.target := by
  have eq := h.2.2 p member
  simpa [eq] using p.sound

theorem repair_transfer (h : CheckedFiber meaning members plan)
    (p : Premise meaning) (member : p ∈ members)
    (repair : Nat) (sourceLink : meaning repair ↔ meaning p.plan.source) :
    meaning repair ↔ meaning plan.target :=
  sourceLink.trans (every_original_retained h p member)

theorem conflicting_owner_rejected
    (h : CheckedFiber meaning members plan)
    (p q : Premise meaning) (hp : p ∈ members) (hq : q ∈ members) :
    p.plan.ownerContext = q.plan.ownerContext := by
  rw [h.2.2 p hp, h.2.2 q hq]

theorem lineage_does_not_identify_occurrence :
    let a : Occurrence := ⟨0, [0, 0], 1⟩
    let b : Occurrence := ⟨0, [1, 0], 1⟩
    a.lineage = b.lineage ∧ a ≠ b := by decide

theorem phase_owner_preserved (members : List (Premise meaning))
    (owner repairOwner : Nat)
    (originalOwners : ∀ p ∈ members, p.occurrence.phase = owner)
    (repairOwnerChecked : repairOwner = owner)
    (p : Premise meaning) (member : p ∈ members) :
    p.occurrence.phase = repairOwner := by
  exact (originalOwners p member).trans repairOwnerChecked.symm

#print axioms every_original_retained
#print axioms repair_transfer
#print axioms conflicting_owner_rejected
#print axioms lineage_does_not_identify_occurrence
#print axioms phase_owner_preserved
end GuardedJoinSourceFiber
