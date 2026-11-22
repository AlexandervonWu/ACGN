import MembershipStream
namespace ACGN.Tenth.P507
open ACGN.Tenth.Membership P506SourceNonempty

/-- Compare both decoded responses at the same operands, authorization and type
    coordinates, including when one result is a predicate over an empty carrier. -/
theorem observed_relational_duals {α : Type} (rows : List String) (ok : checkStream rows = true)
    (e : Engine) (pi ni : Nat) (lh rh : Head) (root : Root) (scope : List Frame) (name : Nat)
    (read : Option Slot) (saved : List Projection) (now : Nat → Option Projection) (w x : Bool)
    (domain l r : Rel α) (lv : models lh l) (rv : models rh r)
    (binding : ∀ s d, read = some s → Issued root s d → admits (effective d) domain l)
    (pos neg : Result)
    (kp : decisions[pi]? = some ⟨e,.positive,lh,rh,w,consistent saved now && authorize root scope name read,x⟩)
    (kn : decisions[ni]? = some ⟨e,.negative,lh,rh,w,consistent saved now && authorize root scope name read,x⟩)
    (vp : rows[pi]? = some (printRow ⟨e,.positive,lh,rh,w,consistent saved now && authorize root scope name read,x⟩ pos))
    (vn : rows[ni]? = some (printRow ⟨e,.negative,lh,rh,w,consistent saved now && authorize root scope name read,x⟩ neg)) :
    neg = flip pos ∧ (means .positive pos l r ↔ subset l r) ∧
      (means .negative neg l r ↔ ¬ subset l r) ∧ (means .negative neg l r ↔ ¬ means .positive pos l r) := by
  have hp:=exact_observed_answer rows ok _ pi kp pos vp
  have hn:=exact_observed_answer rows ok _ ni kn neg vn
  rw [hp,hn]
  exact ⟨compiled_polarities_choose_duals ..,
    parsed_decision_sound e .positive lh rh root scope name read saved now w x domain l r lv rv binding,
    parsed_decision_sound e .negative lh rh root scope name read saved now w x domain l r lv rv binding,
    parsed_results_are_semantic_duals e lh rh root scope name read saved now w x domain l r lv rv binding⟩

/-- Empty versus potentially empty quantification domains explain why dual
    membership inside two universal quantifiers need not give dual sentences. -/
theorem shadowed_set (domain : Rel α) :
    ((∀ value, admits .set domain value → subset value noneRel) ↔ ¬ relNonempty domain) ∧
    ¬ (∀ value, admits .set domain value → ¬ subset value noneRel) := by
  constructor
  · constructor
    · intro h
      exact (subset_none_iff_no_members domain).mp (h domain ⟨relation_subset_reflexive _, trivial⟩)
    · intro empty value given
      exact fun x member => empty ⟨x,given.1 x member⟩
  · intro every
    exact every noneRel ⟨none_subset _, trivial⟩ none_in_none

theorem shadowed_some (domain : Rel α) :
    ((∀ value, admits .some domain value → subset value noneRel) ↔ ¬ relNonempty domain) ∧
    (∀ value, admits .some domain value → ¬ subset value noneRel) := by
  constructor
  · constructor
    · intro all occupied
      exact nonempty_in_none_is_false occupied (all domain ⟨relation_subset_reflexive _,occupied⟩)
    · intro empty value given
      obtain ⟨x,hx⟩ := given.2
      exact False.elim (empty ⟨x,given.1 x hx⟩)
  · intro value given
    exact nonempty_in_none_is_false given.2

end ACGN.Tenth.P507
#print axioms ACGN.Tenth.P507.observed_relational_duals
#print axioms ACGN.Tenth.P507.shadowed_set
#print axioms ACGN.Tenth.P507.shadowed_some
