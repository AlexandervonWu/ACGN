import Std

namespace RepairTuning

structure Result where
  index : Nat
  solved : Nat
  deriving Repr, DecidableEq, BEq

def choose (a b : Result) : Result := if b.solved > a.solved then b else a
def select (first : Result) (rest : List Result) : Result := rest.foldl choose first

theorem choose_member (a b : Result) : choose a b = a ∨ choose a b = b := by
  unfold choose
  split <;> simp

theorem choose_ge_left (a b : Result) : a.solved ≤ (choose a b).solved := by
  unfold choose
  split <;> omega

theorem choose_ge_right (a b : Result) : b.solved ≤ (choose a b).solved := by
  unfold choose
  split <;> omega

theorem choose_tie_left (a b : Result) (h : a.solved = b.solved) : choose a b = a := by
  simp [choose, h]

theorem select_member (a : Result) (rest : List Result) : select a rest ∈ a :: rest := by
  induction rest generalizing a with
  | nil => simp [select]
  | cons b tail ih =>
    have h := ih (choose a b)
    simp only [List.mem_cons] at h ⊢
    change select (choose a b) tail = a ∨ select (choose a b) tail = b ∨
      select (choose a b) tail ∈ tail
    rcases h with h | h
    · rcases choose_member a b with ha | hb
      · exact Or.inl (h.trans ha)
      · exact Or.inr (Or.inl (h.trans hb))
    · exact Or.inr (Or.inr h)

theorem select_ge_first (a : Result) (rest : List Result) : a.solved ≤ (select a rest).solved := by
  induction rest generalizing a with
  | nil => exact Nat.le_refl _
  | cons b tail ih => exact Nat.le_trans (choose_ge_left a b) (ih (choose a b))

theorem select_maximal (a r : Result) (rest : List Result) (h : r ∈ a :: rest) :
    r.solved ≤ (select a rest).solved := by
  induction rest generalizing a with
  | nil =>
    have eq : r = a := by simpa using h
    subst r
    exact Nat.le_refl _
  | cons b tail ih =>
    simp only [List.mem_cons] at h
    rcases h with h | h | h
    · subst r; exact select_ge_first a (b :: tail)
    · subst r; exact Nat.le_trans (choose_ge_right a b) (select_ge_first (choose a b) tail)
    · exact ih (choose a b) (List.mem_cons_of_mem _ h)

def runLayers (layer : α → α) : Nat → α → α
  | 0, x => x
  | n + 1, x => runLayers layer n (layer x)

theorem layers_preserve (property : α → Prop) (layer : α → α)
    (closed : ∀ x, property x → property (layer x)) (n : Nat) (x : α) (h : property x) :
    property (runLayers layer n x) := by
  induction n generalizing x with
  | zero => exact h
  | succ n ih => exact ih (layer x) (closed x h)

end RepairTuning

open RepairTuning

def selectedIndex (scores : List Nat) : Option Nat :=
  match scores.zipIdx |>.map (fun (score, index) => Result.mk index score) with
  | [] => none
  | first :: rest => some (select first rest).index

def main (args : List String) : IO Unit := do
  if args.isEmpty then
    for n in [1, 2, 3] do
      let vectors := (List.range n).foldl (fun acc _ =>
        acc.flatMap (fun xs => (List.range 4).map (fun score => xs ++ [score]))) [[]]
      for scores in vectors do
        IO.println s!"TUNE,{String.intercalate ":" (scores.map toString)},{(selectedIndex scores).getD 0}"
  else
    let scores ← args.mapM fun value => match value.toNat? with
      | some n => pure n
      | none => throw (IO.userError "Expected nonnegative integer validation counts")
    match selectedIndex scores with
    | some index => IO.println index
    | none => throw (IO.userError "No candidates")
