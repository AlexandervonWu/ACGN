import Category72Contracts

/- An alternative inventory is not one simultaneous endpoint. Bound each
   selectable endpoint without skipping any inventory-node validation. Work
   accounting is separate and still charges every stored occurrence. -/
namespace ProjectedAlternativeCensus

inductive Inventory where
  | node (valid : Bool)
  | together (left right : Inventory)
  | choice (primary alternative : Inventory)
  deriving DecidableEq

def stored : Inventory → Nat
  | .node _ => 1
  | .together a b => stored a + stored b
  | .choice a b => stored a + stored b

def maximum : Inventory → Nat
  | .node _ => 1
  | .together a b => maximum a + maximum b
  | .choice a b => max (maximum a) (maximum b)

def validate : Inventory → Bool
  | .node valid => valid
  | .together a b => validate a && validate b
  | .choice a b => validate a && validate b

inductive Selected : Inventory → Nat → Prop
  | node (valid : Bool) : Selected (.node valid) 1
  | together : Selected a n → Selected b m → Selected (.together a b) (n+m)
  | primary : Selected a n → Selected (.choice a b) n
  | alternative : Selected b n → Selected (.choice a b) n

theorem selected_size_bounded (selection : Selected inventory size) : size ≤ maximum inventory := by
  induction selection with
  | node => exact Nat.le_refl _
  | together _ _ a b => exact Nat.add_le_add a b
  | primary _ ih => exact Nat.le_trans ih (Nat.le_max_left _ _)
  | alternative _ ih => exact Nat.le_trans ih (Nat.le_max_right _ _)

def oldGate (limit : Nat) (inventory : Inventory) := decide (stored inventory ≤ limit) && validate inventory
def admits (limit : Nat) (inventory : Inventory) := decide (maximum inventory ≤ limit) && validate inventory

theorem accepted_endpoint_bounded (inventory : Inventory) (limit size : Nat)
    (accepted : admits limit inventory = true) (selection : Selected inventory size) :
    size ≤ limit ∧ validate inventory = true := by
  simp only [admits, Bool.and_eq_true, decide_eq_true_eq] at accepted
  exact ⟨Nat.le_trans (selected_size_bounded selection) accepted.1,accepted.2⟩

theorem maximum_le_stored (inventory : Inventory) : maximum inventory ≤ stored inventory := by
  induction inventory with
  | node => exact Nat.le_refl _
  | together _ _ a b => exact Nat.add_le_add a b
  | choice _ _ a b =>
      simp only [maximum, stored]
      exact Nat.max_le.mpr ⟨by omega,by omega⟩

theorem prior_path_retained (inventory : Inventory) (limit : Nat)
    (accepted : oldGate limit inventory = true) : admits limit inventory = true := by
  simp only [oldGate, Bool.and_eq_true, decide_eq_true_eq] at accepted
  obtain ⟨bound,checks⟩ := accepted
  have le : maximum inventory ≤ limit := Nat.le_trans (maximum_le_stored inventory) bound
  simp [admits,le,checks]

theorem invalid_unselected_alternative_rejected (good bad : Inventory) (limit : Nat)
    (failed : validate bad = false) : admits limit (.choice good bad) = false := by
  simp [admits,validate,failed]

theorem stored_work_not_discounted (a b : Inventory) :
    stored (.choice a b) = stored a + stored b := rfl

/- Exact measured counts, not a claim that the whole inventory is an endpoint.
   Executable correspondence must instantiate the inventory from the Java tree. -/
theorem measured_old_limit_rejects : decide (712 ≤ 512) = false := by decide
theorem measured_selected_limit_accepts : decide (122 ≤ 512) = true := by decide
theorem measured_depth_unchanged : decide (14 ≤ 48) = true := by decide

end ProjectedAlternativeCensus
