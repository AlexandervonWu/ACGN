import Std

/- A complete occurrence census, not an empty metadata list, determines whether
   an outer paid link touches a local binder. Canonical construction and its
   certificates are premises; this model does not prove their Java extraction. -/
namespace AbsentLocalPaidAdmission

inductive Slot where
  | outer : Nat → Slot
  | local : Nat → Nat → Slot
  deriving DecidableEq

def transport (paid : Nat → Option Nat) : Slot → Option Slot
  | .outer n => (paid n).map Slot.outer
  | .local owner n => some (.local owner n)

def outerOnly (occurrences : List Slot) : Prop :=
  ∀ s ∈ occurrences, ∃ n, s = .outer n

theorem no_live_local (xs : List Slot) (h : outerOnly xs) (owner n : Nat) :
    Slot.local owner n ∉ xs := by
  intro mem
  obtain ⟨i, eq⟩ := h _ mem
  cases eq

theorem census_covers_both (before after : List Slot)
    (h : outerOnly (before ++ after)) : outerOnly before ∧ outerOnly after := by
  constructor
  · intro s mem; exact h s (List.mem_append_left _ mem)
  · intro s mem; exact h s (List.mem_append_right _ mem)

theorem charged_outer_unchanged_by_local_metadata
    (paid : Nat → Option Nat) (a b : Nat) (h : paid a = some b) :
    transport paid (.outer a) = some (.outer b) := by simp [transport, h]

theorem live_local_not_outer (paid : Nat → Option Nat) (owner i target : Nat) :
    transport paid (.local owner i) ≠ some (.outer target) := by simp [transport]

#print axioms no_live_local
#print axioms census_covers_both
#print axioms charged_outer_unchanged_by_local_metadata
#print axioms live_local_not_outer
end AbsentLocalPaidAdmission
