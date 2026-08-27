/-
  Unit-cost ordered-tree edit contract for M-05.

  Forest deletion removes the first root and promotes its ordered children;
  insertion is the inverse operation.  Relabeling pairs the first roots and
  recursively edits their child forests and remaining sibling forests.
-/

namespace Section3.OrderedTreeEdit

mutual
  inductive Tree (Label : Type) where
    | node : Label -> Forest Label -> Tree Label
    deriving DecidableEq, Repr

  inductive Forest (Label : Type) where
    | nil : Forest Label
    | cons : Tree Label -> Forest Label -> Forest Label
    deriving DecidableEq, Repr
end

mutual
  def Tree.size : Tree Label -> Nat
    | .node _ children => 1 + children.size

  def Forest.size : Forest Label -> Nat
    | .nil => 0
    | .cons tree rest => tree.size + rest.size
end

def Forest.append : Forest Label -> Forest Label -> Forest Label
  | .nil, right => right
  | .cons tree rest, right => .cons tree (rest.append right)

@[simp] theorem forest_size_append :
    (left right : Forest Label) ->
    (left.append right).size = left.size + right.size
  | .nil, right => by simp [Forest.append, Forest.size]
  | .cons tree rest, right => by
      rw [Forest.append, Forest.size, Forest.size, forest_size_append rest right]
      omega

def forestDistance [DecidableEq Label] : Forest Label -> Forest Label -> Nat
  | .nil, right => right.size
  | left, .nil => left.size
  | .cons (.node leftLabel leftChildren) leftRest,
      .cons (.node rightLabel rightChildren) rightRest =>
    min
      (1 + forestDistance (leftChildren.append leftRest)
        (.cons (.node rightLabel rightChildren) rightRest))
      (min
        (1 + forestDistance
          (.cons (.node leftLabel leftChildren) leftRest)
          (rightChildren.append rightRest))
        ((if leftLabel = rightLabel then 0 else 1) +
          forestDistance leftChildren rightChildren +
          forestDistance leftRest rightRest))
termination_by left right => left.size + right.size
decreasing_by
  all_goals
    simp_wf
    simp only [Tree.size, Forest.size]
    omega

def treeDistance [DecidableEq Label] (left right : Tree Label) : Nat :=
  forestDistance (.cons left .nil) (.cons right .nil)

theorem ordered_forest_recurrence
    [DecidableEq Label]
    (leftLabel rightLabel : Label)
    (leftChildren rightChildren leftRest rightRest : Forest Label) :
    forestDistance
      (.cons (.node leftLabel leftChildren) leftRest)
      (.cons (.node rightLabel rightChildren) rightRest) =
      min
        (1 + forestDistance (leftChildren.append leftRest)
          (.cons (.node rightLabel rightChildren) rightRest))
        (min
          (1 + forestDistance
            (.cons (.node leftLabel leftChildren) leftRest)
            (rightChildren.append rightRest))
          ((if leftLabel = rightLabel then 0 else 1) +
            forestDistance leftChildren rightChildren +
            forestDistance leftRest rightRest)) := by
  rw [forestDistance]

theorem empty_forest_insert_cost_is_node_count
    [DecidableEq Label]
    (right : Forest Label) :
    forestDistance .nil right = right.size := by
  simp [forestDistance]

theorem empty_forest_delete_cost_is_node_count
    [DecidableEq Label]
    (left : Forest Label) :
    forestDistance left .nil = left.size := by
  cases left <;> simp [forestDistance]

def leaf (label : Nat) : Tree Nat := .node label .nil

def internalDeletionLeft : Tree Nat :=
  .node 0 (.cons (.node 1 (.cons (leaf 2) .nil)) .nil)

def internalDeletionRight : Tree Nat :=
  .node 0 (.cons (leaf 2) .nil)

theorem deleting_internal_unary_node_costs_one :
    treeDistance internalDeletionLeft internalDeletionRight = 1 := by
  native_decide

theorem inserting_internal_unary_node_costs_one :
    treeDistance internalDeletionRight internalDeletionLeft = 1 := by
  native_decide

end Section3.OrderedTreeEdit
