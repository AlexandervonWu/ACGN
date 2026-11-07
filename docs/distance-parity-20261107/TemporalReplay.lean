import Std

/- Unit-cost ordered-tree replay. Deletion promotes children; insertion wraps
   a contiguous forest. This contract is not a proof of the Java DP's optimality
   or of source normalization/certificate admission. -/
namespace TemporalReplay

inductive Tree where
  | node : Nat → List Tree → Tree

def eraseHead : List Tree → Option (List Tree)
  | [] => none
  | .node _ children :: rest => some (children ++ rest)

def wrapHead (label count : Nat) (forest : List Tree) : List Tree :=
  [.node label (forest.take count)] ++ forest.drop count

theorem erase_wrap (label count : Nat) (forest : List Tree) :
    eraseHead (wrapHead label count forest) = some forest := by
  simp [eraseHead, wrapHead]

theorem deletion_promotes (label : Nat) (children rest : List Tree) :
    eraseHead (.node label children :: rest) = some (children ++ rest) := rfl

def relabelHead (label : Nat) : List Tree → Option (List Tree)
  | [] => none
  | .node _ children :: rest => some (.node label children :: rest)

theorem relabel_preserves_children (old label : Nat) (children rest : List Tree) :
    relabelHead label (.node old children :: rest) = some (.node label children :: rest) := rfl

structure Receipt where
  source : List Tree
  target : List Tree
  output : List Tree
  charges : List Nat
  claimedCost : Nat

def accepts (source target : List Tree) (r : Receipt) : Prop :=
  r.source = source ∧ r.target = target ∧ r.output = target ∧
  r.charges.sum = r.claimedCost

theorem accepted_output (source target : List Tree) (r : Receipt)
    (h : accepts source target r) : r.output = target := h.2.2.1

theorem changed_endpoint_rejected (source target : List Tree) (r : Receipt)
    (h : r.source ≠ source) : ¬ accepts source target r := by
  intro accepted
  exact h accepted.1

theorem cost_conservation (source target : List Tree) (r : Receipt)
    (h : accepts source target r) : r.charges.sum = r.claimedCost := h.2.2.2

#print axioms erase_wrap
#print axioms deletion_promotes
#print axioms relabel_preserves_children
#print axioms accepted_output
#print axioms changed_endpoint_rejected
#print axioms cost_conservation
end TemporalReplay
