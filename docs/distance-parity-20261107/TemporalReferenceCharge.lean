import Std

/- The temporal operator and the matrix edge referring to its phase are
   separate metric coordinates. Keeping an edge is not semantic equality of
   the referenced formulas: their operator edit remains in the temporal trace.
   This accounting model is not a proof of the Java replay implementation. -/
namespace TemporalReferenceCharge

structure Reference (Ty : Type) where
  type : Ty
  branches : List Nat
  operator : String

def edgeKey (r : Reference Ty) := (r.type, r.branches)

def edgeCharge [DecidableEq Ty] (a b : Reference Ty) : Nat :=
  if edgeKey a = edgeKey b then 0 else 1

def operatorCharge (a b : Reference Ty) : Nat :=
  if a.operator = b.operator then 0 else 1

def total [DecidableEq Ty] (a b : Reference Ty) : Nat :=
  operatorCharge a b + edgeCharge a b

theorem same_edge_operator_once [DecidableEq Ty] (a b : Reference Ty)
    (sameType : a.type = b.type) (sameBranches : a.branches = b.branches) :
    total a b = operatorCharge a b := by
  simp [total, edgeCharge, edgeKey, sameType, sameBranches]

theorem changed_edge_is_not_erased [DecidableEq Ty] (a b : Reference Ty)
    (different : edgeKey a ≠ edgeKey b) : edgeCharge a b = 1 := by
  simp [edgeCharge, different]

theorem changed_operator_is_not_erased [DecidableEq Ty] (a b : Reference Ty)
    (different : a.operator ≠ b.operator) : 1 ≤ total a b := by
  simp [total, operatorCharge, different]

-- A zero matrix charge does not discard the before/after reference payloads.
def execute (source expected target : Reference Ty) [DecidableEq Ty]
    [DecidableEq (Reference Ty)] : Option (Reference Ty) :=
  if source = expected then some target else none

theorem exact_payload [DecidableEq Ty] [DecidableEq (Reference Ty)]
    (a b : Reference Ty) : execute a a b = some b := by simp [execute]

#print axioms same_edge_operator_once
#print axioms changed_edge_is_not_erased
#print axioms changed_operator_is_not_erased
#print axioms exact_payload
end TemporalReferenceCharge
