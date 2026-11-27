import Std

/- The paid declaration search orders permutations already admitted by each
   source certificate. A scalar cost is attached to a whole native witness.
   The executable comparison of certificates, bindings and edit traces is
   checked separately on the corpus. -/
namespace SurvivorWitnessOrder

structure Orders where
  source : List Nat
  target : List Nat
  deriving DecidableEq

/-- Zero fixes an original position; every move retains its target index. -/
def positionRank (original selected : Nat) : Nat :=
  if selected = original then 0 else selected + 1

structure Key where
  survivors : List (Nat × Nat)
  sourceMoves : List Bool
  sourceOrder : List Nat
  targetMoves : List Bool
  targetOrder : List Nat
  deriving DecidableEq

def moves (order : List Nat) : List Bool :=
  order.zipIdx.map (fun (selected, original) => selected != original)

def key (links : List (Nat × Nat)) (o : Orders) : Key where
  survivors := links.map fun (i,j) =>
    (positionRank i (o.source[i]?.getD i), positionRank j (o.target[j]?.getD j))
  sourceMoves := moves o.source
  sourceOrder := o.source
  targetMoves := moves o.target
  targetOrder := o.target

/-- Both full coordinate vectors participate after the surviving links.
    In particular two different endpoint permutations never tie on the full key. -/
theorem same_key_same_orders (links : List (Nat × Nat)) (a b : Orders)
    (same : key links a = key links b) : a = b := by
  have lhs := congrArg Key.sourceOrder same
  have rhs := congrArg Key.targetOrder same
  cases a
  cases b
  dsimp [key] at lhs rhs
  cases lhs
  cases rhs
  rfl

/-- In the observed 116-edit case the first kept declaration resolves the tie
    in favor of the identity at the source. Both alternatives cost the same. -/
theorem first_survivor_in_116_case :
    (key [(0,0), (1,1), (2,3)] ⟨[1,0,2], [0,1,2,3]⟩).survivors.head? = some (2,0) ∧
    (key [(0,0), (1,1), (2,3)] ⟨[0,1,2], [1,0,2,3]⟩).survivors.head? = some (0,2) := ⟨rfl, rfl⟩

/-- Cost and replay admission do not depend on enumeration order. -/
def IsMinimum {α : Type} (cost : α → Nat) (x : α) (xs : List α) : Prop :=
  x ∈ xs ∧ ∀ y ∈ xs, cost x ≤ cost y

theorem reordered_minima {α : Type} (cost : α → Nat) {xs ys : List α}
    (ordered : xs.Perm ys) (x : α) : IsMinimum cost x xs ↔ IsMinimum cost x ys := by
  constructor
  · rintro ⟨member, least⟩
    exact ⟨ordered.mem_iff.mp member, fun y hy => least y (ordered.mem_iff.mpr hy)⟩
  · rintro ⟨member, least⟩
    exact ⟨ordered.mem_iff.mpr member, fun y hy => least y (ordered.mem_iff.mp hy)⟩

/-- A completed old partial correspondence is eligible when it strictly improves
    on the ordinary admissible witness; the ordinary witness owns a tie. -/
def withCompletion {α : Type} (cost : α → Nat) (ordinary completed : α) : α :=
  if cost completed < cost ordinary then completed else ordinary

theorem completion_cost {α : Type} (cost : α → Nat) (ordinary completed : α) :
    cost (withCompletion cost ordinary completed) = min (cost ordinary) (cost completed) := by
  unfold withCompletion
  split
  next h => exact (Nat.min_eq_right (Nat.le_of_lt h)).symm
  next h => exact (Nat.min_eq_left (Nat.le_of_not_lt h)).symm

theorem ordinary_witness_owns_tie {α : Type} (cost : α → Nat) (ordinary completed : α)
    (h : cost completed = cost ordinary) : withCompletion cost ordinary completed = ordinary := by
  simp [withCompletion, h]

theorem selected_witness_replays {α : Type} (cost : α → Nat) (replays : α → Prop)
    {ordinary completed : α} (ho : replays ordinary) (hc : replays completed) :
    replays (withCompletion cost ordinary completed) := by
  unfold withCompletion
  split <;> assumption

end SurvivorWitnessOrder
