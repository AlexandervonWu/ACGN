import Std

/- A cost-preserving refinement of the selected ordered-tree edit, not an
   equivalence between the source and target formulas or a Java proof. Payload
   denotes an entire unchanged child subtree, not a target copied into place. -/
namespace PaidTemporalRouting
inductive Role where | unary | left | right deriving DecidableEq, Repr
inductive Head where | unary (label : Nat) | binary (label : Nat)
  deriving DecidableEq, Repr
structure Child where
  occurrence : Nat
  payload : Nat
  role : Role
  deriving DecidableEq
def erase (c : Child) := (c.occurrence, c.payload)
def rank : Role → Nat | .unary => 0 | .left => 0 | .right => 1
def valid (head : Head) (roles : List Role) : Prop :=
  roles.all (fun r => match head with
    | .unary _ => r == .unary
    | .binary _ => r == .left || r == .right) = true ∧
  (roles.zip (roles.drop 1)).all (fun (a, b) => rank a ≤ rank b) = true
instance (h : Head) (rs : List Role) : Decidable (valid h rs) := by
  unfold valid
  infer_instance

def route : List Child → List Role → Option (List Child)
  | [], [] => some []
  | c :: cs, r :: rs => (route cs rs).map (fun tail => {c with role := r} :: tail)
  | _, _ => none

theorem route_preserves_children (cs : List Child) (rs : List Role) (out : List Child)
    (h : route cs rs = some out) : out.map erase = cs.map erase := by
  induction cs generalizing rs out with
  | nil => cases rs <;> simp_all [route]
  | cons c cs ih =>
    cases rs with
    | nil => simp [route] at h
    | cons r rs =>
      cases step : route cs rs with
      | none => simp [route, step] at h
      | some tail =>
        simp [route, step] at h
        subst out
        simp [erase, ih rs tail step]

def update (old new : Head) (children : List Child) (roles : List Role) :=
  if old ≠ new ∧ valid new roles then route children roles else none

def insert (head : Head) (incoming : Role) (children : List Child) (roles : List Role) :=
  if (∀ c ∈ children, c.role = incoming) ∧ valid head roles
  then route children roles else none

theorem update_erases_to_selected_head_edit (old new : Head) (cs : List Child)
    (roles : List Role) (out : List Child) (h : update old new cs roles = some out) :
    old ≠ new ∧ valid new roles ∧ out.map erase = cs.map erase := by
  unfold update at h
  split at h
  next guard => exact ⟨guard.1, guard.2, route_preserves_children cs roles out h⟩
  next => simp at h

theorem insertion_erases_to_selected_interval (head : Head) (incoming : Role)
    (pre cs post out : List Child) (roles : List Role)
    (h : insert head incoming cs roles = some out) :
    valid head roles ∧ (∀ c ∈ cs, c.role = incoming) ∧
    (pre ++ out ++ post).map erase = (pre ++ cs ++ post).map erase := by
  unfold insert at h
  split at h
  next guard =>
    exact ⟨guard.2, guard.1, by simp [route_preserves_children cs roles out h]⟩
  next => simp at h

theorem no_free_rerouting (head : Head) (cs : List Child) (roles : List Role) :
    update head head cs roles = none := by simp [update]

theorem insertion_rejects_cross_owner (head : Head) (incoming : Role)
    (cs : List Child) (roles : List Role) (bad : ∃ c ∈ cs, c.role ≠ incoming) :
    insert head incoming cs roles = none := by
  simp [insert, show ¬ (∀ c ∈ cs, c.role = incoming) from by simpa using bad]

/- The already-selected metric charges one head update or insertion. Routing
   adds no operation: it refines that same paid edit and preserves its erasure. -/
inductive Edit where | update | insert deriving DecidableEq
def metricCharge (_ : Edit) : Nat := 1
structure RefinedEdit where
  selected : Edit
  childOrigins : List Nat
  roles : List Role
def refinedCharge (e : RefinedEdit) := metricCharge e.selected
theorem same_selected_charge (es : List RefinedEdit) :
    (es.map refinedCharge).sum = (es.map (fun e => metricCharge e.selected)).sum := rfl

#print axioms route_preserves_children
#print axioms update_erases_to_selected_head_edit
#print axioms insertion_erases_to_selected_interval
#print axioms no_free_rerouting
#print axioms insertion_rejects_cross_owner
#print axioms same_selected_charge
end PaidTemporalRouting
