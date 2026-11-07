import Std

/- Finite admitted-space contract, not global Alloy-equivalence minimization. -/
namespace SoundRepresentationUnion

def minimum (first : Nat) : List Nat → Nat
  | [] => first
  | next :: rest => minimum (min first next) rest

theorem minimum_le_first (first : Nat) (rest : List Nat) :
    minimum first rest ≤ first := by
  induction rest generalizing first with
  | nil => simp [minimum]
  | cons next rest ih =>
    exact Nat.le_trans (ih (min first next)) (Nat.min_le_left first next)

theorem minimum_le_member (first : Nat) (rest : List Nat) (cost : Nat)
    (member : cost ∈ rest) : minimum first rest ≤ cost := by
  induction rest generalizing first with
  | nil => simp at member
  | cons next rest ih =>
    rcases List.mem_cons.mp member with rfl | tail
    · change minimum (min first cost) rest ≤ cost
      exact Nat.le_trans (minimum_le_first _ _) (Nat.min_le_right _ _)
    · exact ih (min first next) tail

theorem minimum_attained (first : Nat) (rest : List Nat) :
    minimum first rest = first ∨ minimum first rest ∈ rest := by
  induction rest generalizing first with
  | nil => exact Or.inl rfl
  | cons next rest ih =>
    rcases ih (min first next) with eq | member
    · by_cases h : first ≤ next
      · exact Or.inl (eq.trans (Nat.min_eq_left h))
      · exact Or.inr (List.mem_cons.mpr (Or.inl (eq.trans (Nat.min_eq_right (by omega)))))
    · exact Or.inr (List.mem_cons.mpr (Or.inr member))

-- Admission requires evidence about each representation, not a scalar score.
structure Admitted (meaning : Rep → Meaning) (source : Rep) where
  representation : Rep
  sound : meaning representation = meaning source

theorem admitted_zero_sound {meaning : Rep → Meaning} {left right : Rep}
    (l : Admitted meaning left) (r : Admitted meaning right)
    (cost : Rep → Rep → Nat)
    (kernel : ∀ a b, cost a b = 0 → meaning a = meaning b)
    (zero : cost l.representation r.representation = 0) :
    meaning left = meaning right := by
  exact l.sound.symm.trans ((kernel _ _ zero).trans r.sound)

theorem union_minimum_le_fast (base : Nat) (fast certified : List Nat)
    (cost : Nat) (member : cost ∈ fast) : minimum base (fast ++ certified) ≤ cost := by
  exact minimum_le_member _ _ _ (List.mem_append.mpr (Or.inl member))

theorem union_minimum_le_certified (base : Nat) (fast certified : List Nat)
    (cost : Nat) (member : cost ∈ certified) : minimum base (fast ++ certified) ≤ cost := by
  exact minimum_le_member _ _ _ (List.mem_append.mpr (Or.inr member))

#print axioms minimum_le_first
#print axioms minimum_le_member
#print axioms minimum_attained
#print axioms admitted_zero_sound
#print axioms union_minimum_le_fast
#print axioms union_minimum_le_certified
end SoundRepresentationUnion
