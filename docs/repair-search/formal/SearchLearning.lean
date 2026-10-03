import Lean

namespace RepairSearch

def Equivalent {W : Type} (context candidate oracle : W → Prop) : Prop :=
  ∀ w, context w → (candidate w ↔ oracle w)

theorem two_direction_check {W : Type} (c p q : W → Prop)
    (noExtra : ∀ w, ¬ (c w ∧ p w ∧ ¬ q w))
    (noMissing : ∀ w, ¬ (c w ∧ q w ∧ ¬ p w)) : Equivalent c p q := by
  intro w hc
  constructor
  · intro hp
    exact Classical.byContradiction (fun hq => noExtra w ⟨hc, hp, hq⟩)
  · intro hq
    exact Classical.byContradiction (fun hp => noMissing w ⟨hc, hq, hp⟩)

theorem counterexample_refutes {W : Type} (c p q : W → Prop) (w : W)
    (hc : c w) (different : ¬ (p w ↔ q w)) : ¬ Equivalent c p q := by
  intro h
  exact different (h w hc)

def Passes {W : Type} (p q : W → Prop) (bank : List W) :=
  ∀ w ∈ bank, p w ↔ q w

theorem bank_extension {W : Type} (p q : W → Prop) (bank : List W) (w : W)
    (h : Passes p q (w :: bank)) : Passes p q bank := by
  intro x hx
  exact h x (List.mem_cons_of_mem w hx)

theorem true_solution_survives_bank {W : Type} (c p q : W → Prop) (bank : List W)
    (valid : ∀ w ∈ bank, c w) (solution : Equivalent c p q) : Passes p q bank := by
  intro w hw
  exact solution w (valid w hw)

-- Exhausting a search budget is not evidence that a repair does not exist.
def spend (fuel : Nat) : Nat := fuel - 1
theorem budget_decreases (fuel : Nat) (h : 0 < fuel) : spend fuel < fuel := by
  unfold spend
  omega

structure Admission where
  kind : String
  split : String
  sourceHash : String
  profileHash : String
  identityBound : Bool
  contextSat : Bool
  extraUnsat : Bool
  missingUnsat : Bool
  used : Nat
  budget : Nat
  deriving Lean.FromJson, Lean.ToJson

def accepted (r : Admission) : Bool :=
  r.identityBound && !r.sourceHash.isEmpty && !r.profileHash.isEmpty &&
  (r.used ≤ r.budget) && r.contextSat && r.extraUnsat && r.missingUnsat &&
  (r.kind == "repair" || (r.kind == "training" && r.split == "train"))

theorem accepted_has_checks (r : Admission) (h : accepted r = true) :
    r.contextSat = true ∧ r.extraUnsat = true ∧ r.missingUnsat = true := by
  simp [accepted, Bool.and_eq_true] at h
  exact ⟨h.1.1.1.2, h.1.1.2, h.1.2⟩

theorem accepted_training_is_train (r : Admission)
    (h : accepted r = true) (kind : r.kind = "training") : r.split = "train" := by
  simp [accepted, kind, Bool.and_eq_true] at h
  exact h.2

theorem accepted_bound (r : Admission) (h : accepted r = true) : r.used ≤ r.budget := by
  simp [accepted, Bool.and_eq_true] at h
  exact h.1.1.1.1.2

end RepairSearch

def main : IO Unit := do
  let line ← (← IO.getStdin).getLine
  let parsed := (Lean.Json.parse line).bind (fun j => (Lean.fromJson? j : Except String RepairSearch.Admission))
  let request ← match parsed with
    | .ok r => pure r
    | .error error => throw (IO.userError error)
  let reply := Lean.Json.mkObj [("accepted", Lean.toJson (RepairSearch.accepted request)),
    ("request", Lean.toJson request)]
  (← IO.getStdout).putStrLn reply.compress
