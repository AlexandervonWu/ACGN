import DeclarationReplay

namespace CrossedDeclarationReplay
open DeclarationReplay

/-- In the first ranking divergence, the source binds User then Photo, and the target
    binds Photo then User. The two keep choices preserve different binder identities.
    Both programs consume the original source, build the full target, and charge two
    declaration edits. The matrix charge is checked separately in the native run. -/
theorem distinct_replays_with_equal_length_and_cost
    (user photo user' photo' : Atom)
    (sameUser : user.tuple = user'.tuple) (samePhoto : photo.tuple = photo'.tuple) :
    let keepPhoto := [Edit.delete user, .pair photo photo', .insert user']
    let keepUser := [Edit.insert photo', .pair user user', .delete photo]
    replay [user, photo] keepPhoto = some ([photo', user'], 2) ∧
    replay [user, photo] keepUser = some ([photo', user'], 2) ∧
    keepPhoto.length = keepUser.length ∧ keepPhoto ≠ keepUser := by
  simp [replay, sameUser, samePhoto]

/-- Reclassifying an existing attained path changes its preference only on a tie. -/
def choose {α : Type} (cost : α → Nat) (ordinary retained : α) (preferRetained : Bool) : α :=
  if cost retained < cost ordinary then retained
  else if cost ordinary < cost retained then ordinary
  else if preferRetained then retained else ordinary

theorem charge_of_choice {α : Type} (cost : α → Nat) (ordinary retained : α) (preferRetained : Bool) :
    cost (choose cost ordinary retained preferRetained) = min (cost ordinary) (cost retained) := by
  unfold choose
  split
  next h => exact (Nat.min_eq_right (Nat.le_of_lt h)).symm
  next hr =>
    split
    next h => exact (Nat.min_eq_left (Nat.le_of_lt h)).symm
    next ho =>
      have he : cost ordinary = cost retained := by omega
      cases preferRetained <;> simp [he]

theorem preference_preserves_charge {α : Type} (cost : α → Nat) (ordinary retained : α) (a b : Bool) :
    cost (choose cost ordinary retained a) = cost (choose cost ordinary retained b) :=
  (charge_of_choice cost ordinary retained a).trans (charge_of_choice cost ordinary retained b).symm

theorem strictly_better_retained_path_survives {α : Type} (cost : α → Nat) (ordinary retained : α)
    (better : cost retained < cost ordinary) (prefers : Bool) : choose cost ordinary retained prefers = retained := by
  simp [choose, better]

#print axioms charge_of_choice
#print axioms preference_preserves_charge
#print axioms strictly_better_retained_path_survives

#print axioms distinct_replays_with_equal_length_and_cost
end CrossedDeclarationReplay
