import Std

/- ONE is a fixed declaration barrier, not an exchangeable ALL/SOME block.
   Its guarded carrier translation preserves uniqueness even for empty domains.
   Charged edit links are not semantic equality or Java/wire correspondence. -/
namespace OnePaidDeclarationAlignment

def ExactlyOne {A : Type} (p : A → Prop) : Prop := ∃ x, p x ∧ ∀ y, p y → y = x

theorem guarded_one_subtype {A : Type} (domain p : A → Prop) :
    ExactlyOne (fun x : {x // domain x} => p x.val) ↔
    ExactlyOne (fun x => domain x ∧ p x) := by
  constructor
  · rintro ⟨⟨x, dx⟩, px, unique⟩
    refine ⟨x, ⟨dx, px⟩, ?_⟩
    intro y hy
    exact congrArg Subtype.val (unique ⟨y, hy.1⟩ hy.2)
  · rintro ⟨x, ⟨dx, px⟩, unique⟩
    refine ⟨⟨x, dx⟩, px, ?_⟩
    intro y py
    exact Subtype.ext (unique y.val ⟨y.property, py⟩)

theorem guarded_one_under_all {A C : Type} (domain : A → Prop) (p : C → A → Prop) :
    (∀ c, ExactlyOne (fun x : {x // domain x} => p c x.val)) ↔
    (∀ c, ExactlyOne (fun x => domain x ∧ p c x)) := by
  constructor
  · intro h c; exact (guarded_one_subtype domain (p c)).mp (h c)
  · intro h c; exact (guarded_one_subtype domain (p c)).mpr (h c)

theorem empty_one_false : ¬ ExactlyOne (fun _ : Empty => True) := by
  rintro ⟨x, _⟩; exact nomatch x

theorem empty_all_forbids_one_hoisting :
    (∀ _ : Empty, ExactlyOne (fun _ : Empty => True)) ∧
    ¬ ExactlyOne (fun _ : Empty => ∀ _ : Empty, True) := by
  constructor
  · intro x; exact nomatch x
  · rintro ⟨x, _⟩; exact nomatch x

structure Declaration where
  owner : Nat
  slot : Nat
  kind : Nat
  carrier : Nat
  deriving DecidableEq

def charged (actual expected target : Declaration) : Option (Nat × Declaration × Declaration) :=
  if actual = expected then some (1, actual, target) else none

theorem paid_one_link (a b : Declaration) : charged a a b = some (1, a, b) := by simp [charged]

theorem foreign_premise_rejected (a expected b : Declaration) (h : a ≠ expected) :
    charged a expected b = none := by simp [charged, h]

#print axioms guarded_one_subtype
#print axioms guarded_one_under_all
#print axioms empty_one_false
#print axioms empty_all_forbids_one_hoisting
#print axioms paid_one_link
#print axioms foreign_premise_rejected
end OnePaidDeclarationAlignment
