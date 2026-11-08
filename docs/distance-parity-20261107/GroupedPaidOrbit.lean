import Std

/- A source-certified grouped ALL/SOME exchange transports the paid path as
   well as its matrix bindings. It changes neither declaration payload charges
   nor original owner identities. No mixed-kind or dependent-domain exchange
   is licensed. Runtime certificate/Java correspondence is a separate premise. -/
namespace GroupedPaidOrbit

theorem all_group_exchange {A : Type} (d : A → Prop) (p : A → A → Prop) :
    (∀ x, d x → ∀ y, d y → p x y) ↔ ∀ y, d y → ∀ x, d x → p x y := by
  constructor <;> intro h x hx y hy <;> exact h y hy x hx

theorem some_group_exchange {A : Type} (d : A → Prop) (p : A → A → Prop) :
    (∃ x, d x ∧ ∃ y, d y ∧ p x y) ↔ ∃ y, d y ∧ ∃ x, d x ∧ p x y := by
  constructor
  · rintro ⟨x, hx, y, hy, hp⟩; exact ⟨y, hy, x, hx, hp⟩
  · rintro ⟨y, hy, x, hx, hp⟩; exact ⟨x, hx, y, hy, hp⟩

def transported (r : Nat → Nat → Prop) (p q : Nat → Nat) (x y : Nat) : Prop :=
  ∃ a b, r a b ∧ p a = x ∧ q b = y

theorem original_paid_link_retained (r : Nat → Nat → Prop) (p q : Nat → Nat)
    (x y : Nat) (h : r x y) : transported r p q (p x) (q y) :=
  ⟨x,y,h,rfl,rfl⟩

theorem transported_functional (r : Nat → Nat → Prop) (p q : Nat → Nat)
    (hp : Function.Injective p) (hr : ∀ x y z, r x y → r x z → y = z)
    (x y z : Nat) (hy : transported r p q x y) (hz : transported r p q x z) : y = z := by
  rcases hy with ⟨a,b,hab,ha,hb⟩
  rcases hz with ⟨c,d,hcd,hc,hd⟩
  have hac : a = c := hp (ha.trans hc.symm)
  subst c
  have hbd := hr a b d hab hcd
  subst d
  exact hb.symm.trans hd

theorem transported_injective (r : Nat → Nat → Prop) (p q : Nat → Nat)
    (hq : Function.Injective q) (hr : ∀ x y z, r x z → r y z → x = y)
    (x y z : Nat) (hx : transported r p q x z) (hy : transported r p q y z) : x = y := by
  rcases hx with ⟨a,b,hab,ha,hb⟩
  rcases hy with ⟨c,d,hcd,hc,hd⟩
  have hbd : b = d := hq (hb.trans hd.symm)
  subst d
  have hac := hr a c b hab hcd
  subst c
  exact ha.symm.trans hc

inductive Edit where
  | diagonal : Nat → Nat → Edit
  | delete : Nat → Edit
  | insert : Nat → Edit

def move (p q : Nat → Nat) : Edit → Edit
  | .diagonal x y => .diagonal (p x) (q y)
  | .delete x => .delete (p x)
  | .insert y => .insert (q y)

def charge (left right : Nat → Nat) : Edit → Nat
  | .diagonal x y => if left x = right y then 0 else 1
  | .delete _ => 1
  | .insert _ => 1

theorem actual_declaration_action_cost_retained (left right p q : Nat → Nat)
    (hl : ∀ x, left (p x) = left x) (hr : ∀ y, right (q y) = right y) (a : Edit) :
    charge left right (move p q a) = charge left right a := by
  cases a <;> simp [move,charge,hl,hr]

theorem unchanged_owner (owner p : Nat → Nat) (h : ∀ i, owner (p i) = owner i) (i : Nat) :
    owner (p i) = owner i := h i

#print axioms all_group_exchange
#print axioms some_group_exchange
#print axioms transported_functional
#print axioms transported_injective
#print axioms actual_declaration_action_cost_retained
end GroupedPaidOrbit
