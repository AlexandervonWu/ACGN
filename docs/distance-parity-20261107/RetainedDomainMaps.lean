import RetainedDomainWitnesses

namespace RetainedDomainMaps
open Focused225CallViews RetainedDomainAdmission ScopedCallCorrespondence

/- Representative trees do not carry invocation maps. This deliberately weaker
   observation models the omitted premise, not a replacement admission rule. -/
inductive Representative where
  | variable : Head → String → Representative
  | node : Head → Representative → Representative
  | nil : Representative
  | cons : Representative → Representative → Representative
  deriving DecidableEq

def representative : Raw → Representative
  | .variable head alpha _ => .variable head alpha
  | .node head _ children => .node head (representative children)
  | .nil => .nil
  | .cons head tail => .cons (representative head) (representative tail)

theorem changed_effective_domain_rejected (a b : Frame) (registry : List View)
    (original current : View) (source target : Shape)
    (found : sourceAt registry current.key = some original)
    (hs : resolved original = some source) (ht : resolved current = some target)
    (different : source ≠ target) : check a b registry current = none :=
  untransported_domain_rejected a b registry current
    (wrong_argument_rejected registry current original source target found hs ht different)

theorem equivalent_invocations_preserve_admission (a b : Frame) (registry : List View)
    (left right : View) (key : left.key = right.key)
    (resolution : resolved left = resolved right) :
    check a b registry left = check a b registry right := by
  simp only [check, transport, key, resolution]

theorem nonidentity_maps_need_no_exception (a b : Frame) (registry : List View)
    (original current : View) (term : Shape)
    (accepted : check a b registry original = some term)
    (key : original.key = current.key)
    (resolution : resolved original = resolved current) :
    check a b registry current = some term := by
  rw [← equivalent_invocations_preserve_admission a b registry original current key resolution]
  exact accepted

end RetainedDomainMaps
