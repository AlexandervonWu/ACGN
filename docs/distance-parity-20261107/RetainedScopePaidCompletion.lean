import Std

/- Replay-only completion: outer exchange is source-equivalent even when the
   body retains arbitrary local binders (including empty domains). The body is
   not hoisted or rewritten. Java must separately check source certificates,
   original-coordinate incidence and every action of the existing body receipt.
   This model does not prove the Java extractor or a public wire verifier. -/
namespace RetainedScopePaidCompletion

theorem outer_exchange {A : Type} (body : A → A → Prop) :
    (∀ x y, body x y) ↔ ∀ y x, body x y := by
  constructor <;> intro h x y <;> exact h y x

theorem retained_exists {A L M : Type} (body : A → A → L → M → Prop) :
    (∀ x y, ∃ l m, body x y l m) ↔ ∀ y x, ∃ l m, body x y l m :=
  outer_exchange _

def extend (mapping : Nat → Option Nat) (a b x : Nat) :=
  if x = a then some b else mapping x

theorem preserves_selected (mapping : Nat → Option Nat) (a b x y : Nat)
    (fresh : mapping a = none) (selected : mapping x = some y) :
    extend mapping a b x = some y := by
  have h : x ≠ a := by intro e; subst x; simp [fresh] at selected
  simp [extend, h, selected]

theorem fresh_injective_extension (mapping : Nat → Option Nat) (a b : Nat)
    (inj : ∀ x z y, mapping x = some y → mapping z = some y → x = z)
    (fresh : ∀ x, mapping x ≠ some b) :
    ∀ x z y, extend mapping a b x = some y → extend mapping a b z = some y → x = z := by
  intro x z y hx hz
  by_cases xa : x = a <;> by_cases za : z = a
  · exact xa.trans za.symm
  · simp [extend, xa] at hx
    simp [extend, za] at hz
    exact False.elim (fresh z (hz.trans (congrArg some hx).symm))
  · simp [extend, za] at hz
    simp [extend, xa] at hx
    exact False.elim (fresh x (hx.trans (congrArg some hz).symm))
  · exact inj x z y (by simpa [extend, xa] using hx) (by simpa [extend, za] using hz)

-- Unlike unused-side completion, observed links can change variable cost.
-- Admission therefore requires equality at EVERY existing action, not just
-- equality of totals or a new optimal search under the completed map.
theorem unchanged_derivation {Action : Type} (actions : List Action)
    (before after : Action → Nat) (checked : ∀ a ∈ actions, after a = before a) :
    (actions.map after).sum = (actions.map before).sum := by
  induction actions with
  | nil => rfl
  | cons a rest ih =>
    simp only [List.map_cons, List.sum_cons]
    rw [checked a (by simp), ih (by intro x hx; exact checked x (by simp [hx]))]

-- Historical allocator seeds outside the live source occurrence census are
-- not declaration occurrences. Lookup agreement on every live owner suffices;
-- counting every seed instead would confuse metadata with a retained binder.
theorem live_owner_lookup {Owner Binding : Type} (live : List Owner)
    (source comparison : Owner → Binding)
    (checked : ∀ owner ∈ live, source owner = comparison owner) :
    live.map source = live.map comparison := by
  induction live with
  | nil => rfl
  | cons owner rest ih =>
    simp only [List.map_cons]
    rw [checked owner (by simp), ih (by intro x hx; exact checked x (by simp [hx]))]

#print axioms outer_exchange
#print axioms retained_exists
#print axioms preserves_selected
#print axioms fresh_injective_extension
#print axioms unchanged_derivation
#print axioms live_owner_lookup
end RetainedScopePaidCompletion
