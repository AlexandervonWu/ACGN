import Std

/- A temporal edit carries branch-routing payload, not just labels. This finite
   model exposes the runtime obligations; it is not Java/Alloy correspondence. -/
namespace TypedTemporalSplice
inductive Role where | root | unary | left | right deriving DecidableEq
structure Edge where
  origin : Nat
  role : Role
  deriving DecidableEq

def promote (deleted : Edge) (children : List Edge) : List Edge :=
  children.map (fun child => { child with role := deleted.role })

def wrap (incoming : Role) (roles : List Role) (children : List Edge) : Option (List Edge) :=
  if children.length = roles.length ∧ children.all (fun child => child.role == incoming) then
    some ((children.zip roles).map (fun (child, role) => { child with role := role }))
  else none

theorem promotion_preserves_origin (deleted : Edge) (children : List Edge) :
    (promote deleted children).map Edge.origin = children.map Edge.origin := by
  simp [promote, List.map_map]

theorem promotion_routes_to_deleted_role (deleted : Edge) (child : Edge) :
    promote deleted [child] = [{ child with role := deleted.role }] := rfl

theorem wrapping_rejects_cross_branch (incoming : Role) (roles : List Role)
    (children : List Edge) (bad : children.all (fun child => child.role == incoming) = false) :
    wrap incoming roles children = none := by
  simp [wrap, bad]

/- Independent replay returns both actual roles and retained origin identities.
   A final endpoint comparison is required, not an assumption about an ordinal. -/
def check (executed claimed : List Edge) : Bool := executed == claimed
theorem checked_roles_and_origins (executed claimed : List Edge)
    (h : check executed claimed = true) : executed = claimed := by
  simpa [check] using h

theorem forged_derivation_rejected (executed forged : List Edge)
    (h : executed ≠ forged) : check executed forged = false := by
  simp [check, h]

#print axioms promotion_preserves_origin
#print axioms wrapping_rejects_cross_branch
#print axioms checked_roles_and_origins
#print axioms forged_derivation_rejected
end TypedTemporalSplice
