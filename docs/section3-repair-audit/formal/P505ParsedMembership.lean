import MembershipStream
namespace ACGN.Tenth.P505
open ACGN.Tenth.Membership P506SourceNonempty

/-- At the two-child membership guard, a Boolean false for a unary variable in
    none requires its actual visible declaration slot and a nonempty admitted value. -/
theorem observed_false_requires_source {α : Type} (rows : List String) (ok : checkStream rows = true)
    (e : Engine) (i : Nat) (root : Root) (scope : List Frame) (name : Nat) (read : Option Slot)
    (saved : List Projection) (now : Nat → Option Projection) (w x : Bool)
    (domain value : Rel α) (binding : ∀ s d, read = some s → Issued root s d → admits (effective d) domain value)
    (key : decisions[i]? = some ⟨e,.positive,.ordinary,.empty,w,consistent saved now && authorize root scope name read,x⟩)
    (result : rows[i]? = some (printRow ⟨e,.positive,.ordinary,.empty,w,consistent saved now && authorize root scope name read,x⟩ (.literal false))) :
    relNonempty value ∧ ¬ subset value noneRel ∧
      ∃ slot d, read = some slot ∧ Visible name slot scope ∧ Issued root slot d ∧
        (effective d = .one ∨ effective d = .some) := by
  have actual := (exact_observed_answer rows ok _ i key (.literal false) result).symm
  obtain ⟨slot,d,same,visible,issued,positive⟩ := positive_in_none_has_issuing_slot e root scope name read saved now w x actual
  have admitted := binding slot d same issued
  have nonempty : relNonempty value := by
    rcases positive with one | some__
    · rw [one] at admitted
      exact admitted.2.1
    · rw [some__] at admitted
      exact admitted.2
  exact ⟨nonempty, nonempty_in_none_is_false nonempty, slot,d,same,visible,issued,positive⟩

theorem nullable_false_has_empty_countermodel {α : Type} :
    subset (noneRel : Rel α) noneRel ∧ ¬ relNonempty (noneRel : Rel α) := by
  exact ⟨none_in_none, fun ⟨_,impossible⟩ => impossible⟩

end ACGN.Tenth.P505
#print axioms ACGN.Tenth.P505.observed_false_requires_source
#print axioms ACGN.Tenth.P505.nullable_false_has_empty_countermodel
