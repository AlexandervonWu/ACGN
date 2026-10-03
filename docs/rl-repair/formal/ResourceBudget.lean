import Std

namespace RepairResource

def estimate (parameters reserve : Nat) := 24 * parameters + reserve
def admitted (parameters reserve budget : Nat) : Bool := decide (estimate parameters reserve ≤ budget)

theorem admission_bound (p r b : Nat) (h : admitted p r b = true) : estimate p r ≤ b := by
  simpa [admitted] using h
theorem admission_nominal_bound (p r b : Nat) (h : admitted p r b = true) : 16 * p ≤ b := by
  have hb := admission_bound p r b h
  unfold estimate at hb
  omega
theorem over_budget_rejected (p r b : Nat) (h : b < estimate p r) : admitted p r b = false := by
  simp [admitted]; omega

structure Candidate where
  index : Nat
  solved : Nat
  parameters : Nat
  deriving Repr, BEq, DecidableEq

def Preferred (a b : Candidate) : Prop :=
  b.solved ≤ a.solved ∧ (a.solved = b.solved → a.parameters ≤ b.parameters)
def choose (a b : Candidate) : Candidate :=
  if a.solved < b.solved ∨ (a.solved = b.solved ∧ b.parameters < a.parameters) then b else a
def select (first : Candidate) (rest : List Candidate) := rest.foldl choose first

theorem choose_member (a b : Candidate) : choose a b = a ∨ choose a b = b := by
  unfold choose; split <;> simp
theorem choose_prefers_left (a b : Candidate) : Preferred (choose a b) a := by
  unfold choose Preferred; split <;> omega
theorem choose_prefers_right (a b : Candidate) : Preferred (choose a b) b := by
  unfold choose Preferred; split <;> omega
theorem preference_transitive (a b c : Candidate) (ab : Preferred a b) (bc : Preferred b c) :
    Preferred a c := by unfold Preferred at *; omega
theorem select_prefers_first (a : Candidate) (rest : List Candidate) : Preferred (select a rest) a := by
  induction rest generalizing a with
  | nil => exact ⟨Nat.le_refl _, fun _ => Nat.le_refl _⟩
  | cons b rest ih => exact preference_transitive _ _ _ (ih (choose a b)) (choose_prefers_left a b)
theorem select_optimal (a r : Candidate) (rest : List Candidate) (h : r ∈ a :: rest) :
    Preferred (select a rest) r := by
  induction rest generalizing a with
  | nil =>
    have eq : r = a := by simpa using h
    subst r
    exact select_prefers_first a []
  | cons b tail ih =>
    simp only [List.mem_cons] at h
    rcases h with h | h | h
    · subst r; exact select_prefers_first a (b :: tail)
    · subst r; exact preference_transitive _ _ _ (select_prefers_first (choose a b) tail) (choose_prefers_right a b)
    · exact ih (choose a b) (List.mem_cons_of_mem _ h)

end RepairResource

open RepairResource

def main (args : List String) : IO Unit := do
  if args.isEmpty then
    for p in [0, 1, 10, 100] do
      for r in [0, 32] do
        for b in [0, 16, 24, 32, 240, 2432] do
          IO.println s!"RESOURCE,{p},{r},{b},{admitted p r b}"
    for a in List.range 3 do
      for b in List.range 3 do
        for pa in [10, 20, 30] do
          for pb in [10, 20, 30] do
            let result := select ⟨0, a, pa⟩ [⟨1, b, pb⟩]
            IO.println s!"SELECT,{a},{pa},{b},{pb},{result.index}"
  else
    let candidates ← args.zipIdx |>.mapM fun (arg, index) => do
      match arg.splitOn ":" with
      | [s, p] => match s.toNat?, p.toNat? with
        | some solved, some parameters => pure (Candidate.mk index solved parameters)
        | _, _ => throw (IO.userError "Expected integer score:parameters")
      | _ => throw (IO.userError "Expected score:parameters")
    match candidates with
    | [] => throw (IO.userError "No candidates")
    | first :: rest => IO.println (select first rest).index
