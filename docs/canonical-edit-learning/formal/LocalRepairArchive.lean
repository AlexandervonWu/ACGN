import Lean
set_option autoImplicit false
namespace LocalRepairArchive

structure Ref where
  revision : Nat
  row : Nat
  deriving DecidableEq

def resolve {A : Type} (currentRevision : Nat) (current : Nat → Option A)
    (archive : Ref → Option A) (ref : Ref) : Option A :=
  if ref.revision = currentRevision then current ref.row else archive ref

theorem current_lookup {A : Type} (rev row : Nat) (current : Nat → Option A)
    (archive : Ref → Option A) : resolve rev current archive ⟨rev, row⟩ = current row := by
  simp [resolve]

theorem historical_lookup {A : Type} (rev : Nat) (current : Nat → Option A)
    (archive : Ref → Option A) (ref : Ref) (h : ref.revision ≠ rev) :
    resolve rev current archive ref = archive ref := by simp [resolve, h]

theorem missing_history_is_not_current {A : Type} (rev : Nat) (current : Nat → Option A)
    (archive : Ref → Option A) (ref : Ref) (h : ref.revision ≠ rev)
    (missing : archive ref = none) : resolve rev current archive ref = none := by
  simp [resolve, h, missing]

theorem revision_separates_addresses (a b row : Nat) (h : a ≠ b) :
    (Ref.mk a row) ≠ Ref.mk b row := by intro same; exact h (congrArg Ref.revision same)

theorem public_archive_projection {A Private : Type} (publicArchive : Ref → Option A)
    (secretA secretB : Private) :
    (publicArchive, secretA).1 = (publicArchive, secretB).1 := rfl

theorem combined_budget (current archived cap : Nat) (h : current + archived ≤ cap) :
    current ≤ cap ∧ archived ≤ cap := by omega

#print axioms current_lookup
#print axioms historical_lookup
#print axioms missing_history_is_not_current
#print axioms revision_separates_addresses
#print axioms public_archive_projection
#print axioms combined_budget
end LocalRepairArchive
