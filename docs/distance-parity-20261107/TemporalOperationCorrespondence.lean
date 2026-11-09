import Std

/- Transport keeps typed original phase identity and every selected action.
   This model does not prove the Java resolver or source normalization. -/
namespace TemporalOperationCorrespondence
structure Phase where
  sourcePath : String
  typedRole : String
  deriving DecidableEq
structure Action (α : Type) where
  phase : α
  occurrence : String
  kind : String
  charge : Nat
  deriving DecidableEq
def transport (f : α → β) (a : Action α) : Action β :=
  ⟨f a.phase, a.occurrence, a.kind, a.charge⟩

theorem retains_charge (f : α → β) (a : Action α) :
    (transport f a).charge = a.charge := rfl
theorem retains_all_actions (f : α → β) (xs : List (Action α)) :
    (xs.map (transport f)).length = xs.length := by simp
theorem retains_order_and_payload (f : α → β) (xs : List (Action α)) :
    (xs.map (transport f)).map (fun a => (a.occurrence,a.kind,a.charge)) =
    xs.map (fun a => (a.occurrence,a.kind,a.charge)) := by simp [transport]
theorem retains_total (f : α → β) (xs : List (Action α)) :
    ((xs.map (transport f)).map Action.charge).sum = (xs.map Action.charge).sum := by
  simp [Function.comp_def, transport]

theorem checked_endpoint_transport (f : α → Phase) (g : β → Phase)
    (a : Action α) (b : Action β) (phase : f a.phase = g b.phase)
    (occurrence : a.occurrence = b.occurrence) (kind : a.kind = b.kind)
    (charge : a.charge = b.charge) : transport f a = transport g b := by
  simp [transport, phase, occurrence, kind, charge]

theorem typed_role_not_ordinal (a b : Phase) (different : a.typedRole ≠ b.typedRole) :
    a ≠ b := by intro h; exact different (congrArg Phase.typedRole h)

/- Zero steps remain in the list. Block comparison may coalesce equal-component
   bookkeeping only with a checked effect, never by deleting its native record. -/
theorem zero_step_retained (f : α → β) (a : Action α) (xs : List (Action α)) :
    (a :: xs).map (transport f) = transport f a :: xs.map (transport f) := rfl

#print axioms retains_order_and_payload
#print axioms retains_total
#print axioms checked_endpoint_transport
#print axioms typed_role_not_ordinal
#print axioms zero_step_retained
end TemporalOperationCorrespondence
