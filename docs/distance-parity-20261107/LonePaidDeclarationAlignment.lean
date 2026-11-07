import Std

/- LONE remains a fixed prefix barrier. Charged declaration updates may carry
   occurrence links across unlike tuples; that is not a free source equality.
   No Java extraction or public-wire correspondence is asserted here. -/
namespace LonePaidDeclarationAlignment

def AtMostOne {A : Type} (p : A → Prop) : Prop := ∀ x y, p x → p y → x = y

theorem guarded_lone_subtype {A : Type} (d p : A → Prop) :
    AtMostOne (fun x : {x // d x} => p x.val) ↔ AtMostOne (fun x => d x ∧ p x) := by
  constructor
  · intro h x y hx hy
    exact congrArg Subtype.val (h ⟨x, hx.1⟩ ⟨y, hy.1⟩ hx.2 hy.2)
  · intro h x y hx hy
    exact Subtype.ext (h x.val y.val ⟨x.property, hx⟩ ⟨y.property, hy⟩)

theorem lone_congr {A : Type} (p q : A → Prop) (h : ∀ x, p x ↔ q x) :
    AtMostOne p ↔ AtMostOne q := by
  constructor
  · intro hp x y hx hy; exact hp x y ((h x).mpr hx) ((h y).mpr hy)
  · intro hq x y hx hy; exact hq x y ((h x).mp hx) ((h y).mp hy)

theorem lone_keeps_inner_exists_exchange {A B C : Type} (p : A → B → C → Prop) :
    AtMostOne (fun a => ∃ b, ∃ c, p a b c) ↔ AtMostOne (fun a => ∃ c, ∃ b, p a b c) := by
  apply lone_congr
  intro a
  constructor
  · rintro ⟨b, c, h⟩; exact ⟨c, b, h⟩
  · rintro ⟨c, b, h⟩; exact ⟨b, c, h⟩

theorem empty_domain_forbids_hoisting :
    AtMostOne (fun _ : Bool => ∃ _ : Empty, True) ∧
    ¬ (∃ _ : Empty, AtMostOne (fun _ : Bool => True)) := by
  constructor
  · intro x y hx _; obtain ⟨e, _⟩ := hx; exact nomatch e
  · rintro ⟨e, _⟩; exact nomatch e

structure Declaration where
  occurrence : Nat
  kind : Nat
  carrier : Nat
  deriving DecidableEq

def charged (actual expected target : Declaration) : Option (Nat × (Nat × Nat)) :=
  if actual = expected then some (1, (actual.occurrence, target.occurrence)) else none

theorem paid_link_retains_exact_endpoints (a b : Declaration) :
    charged a a b = some (1, (a.occurrence, b.occurrence)) := by simp [charged]

theorem changed_source_rejected (a e b : Declaration) (h : a ≠ e) :
    charged a e b = none := by simp [charged, h]

#print axioms guarded_lone_subtype
#print axioms lone_keeps_inner_exists_exchange
#print axioms empty_domain_forbids_hoisting
#print axioms paid_link_retains_exact_endpoints
#print axioms changed_source_rejected
end LonePaidDeclarationAlignment
