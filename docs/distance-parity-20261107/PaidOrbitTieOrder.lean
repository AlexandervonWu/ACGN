import GroupedPaidOrbit
import SelectedDeclarationPathTransport

/- A final priority between actual, already admitted repair candidates. It
   never normalizes a receipt or grants a permutation. Fast's current orbit
   slice contains only identity and one authenticated transposition. -/
namespace PaidOrbitTieOrder

def supported (paid : Nat → Bool) (order : Nat → Nat) : Prop :=
  ∀ i, order i ≠ i → paid i = true ∨ paid (order i) = true

def swap (a b i : Nat) : Nat := if i = a then b else if i = b then a else i

theorem identity_supported (paid : Nat → Bool) : supported paid id := by
  intro i changed
  exact False.elim (changed rfl)

theorem transposition_supported (paid : Nat → Bool) (a b : Nat) (different : a ≠ b) :
    supported paid (swap a b) ↔ paid a = true ∨ paid b = true := by
  constructor
  · intro h
    simpa [swap] using h a (by simp [swap, Ne.symm different])
  · intro h i changed
    by_cases ha : i = a
    · subst i; simpa [swap] using h
    by_cases hb : i = b
    · subst i; simpa [swap, Ne.symm different, or_comm] using h
    · exact False.elim (changed (by simp [swap, ha, hb]))

-- A swap of two unpaid slots leaves all paid endpoints fixed. This explains
-- why paid links alone cannot choose an ordered native declaration program.
theorem unpaid_swap_fixes_paid (paid : Nat → Bool) (a b i : Nat)
    (ha : paid a = false) (hb : paid b = false) (hi : paid i = true) : swap a b i = i := by
  have ia : i ≠ a := by intro h; subst i; simp_all
  have ib : i ≠ b := by intro h; subst i; simp_all
  simp [swap, ia, ib]

structure Key where
  cost : Nat
  canonical : Bool
  linked : Bool
  existing : Bool
  paidSupported : Bool
  paid : List (Nat × Nat)
  full : List (Nat × Nat)
  deriving DecidableEq, BEq

def oldPrefer (best next : Key) : Bool :=
  next.cost < best.cost || next.cost == best.cost &&
    (next.canonical && !best.canonical || next.canonical == best.canonical &&
      next.linked && (!best.linked || next.existing && !best.existing))

def extraTie (best next : Key) : Bool :=
  next.cost == best.cost && next.canonical == best.canonical &&
  next.linked && best.linked && next.existing == best.existing &&
  next.paidSupported && !best.paidSupported && next.paid == best.paid && next.full == best.full

def prefer (best next : Key) : Bool := oldPrefer best next || extraTie best next

def choose {A : Type} (key : A → Key) (best next : A) : A :=
  if prefer (key best) (key next) then next else best

theorem old_preference_retained (best next : Key) (h : oldPrefer best next = true) :
    prefer best next = true := by simp [prefer, h]

theorem extra_tie_same_obligations (best next : Key) (h : extraTie best next = true) :
    next.cost = best.cost ∧ next.canonical = best.canonical ∧
    next.linked = true ∧ best.linked = true ∧ next.existing = best.existing ∧
    next.paid = best.paid ∧ next.full = best.full := by
  simp only [extraTie, Bool.and_eq_true, beq_iff_eq] at h
  rcases h with ⟨⟨⟨⟨⟨⟨⟨⟨hc, hcanonical⟩, hn⟩, hb⟩, he⟩, _⟩, _⟩, hp⟩, hf⟩
  exact ⟨hc, hcanonical, hn, hb, he, hp, hf⟩

theorem chosen_is_actual {A : Type} (key : A → Key) (best next : A) :
    choose key best next = best ∨ choose key best next = next := by
  unfold choose
  split <;> simp

theorem retained_admission_and_replay {A : Type} (key : A → Key) (valid : A → Prop)
    (best next : A) (hb : valid best) (hn : valid next) : valid (choose key best next) := by
  rcases chosen_is_actual key best next with h | h <;> simp_all

theorem lower_cost_wins {A : Type} (key : A → Key) (best next : A)
    (lower : (key next).cost < (key best).cost) : choose key best next = next := by
  simp [choose, prefer, oldPrefer, lower]

theorem higher_cost_loses {A : Type} (key : A → Key) (best next : A)
    (higher : (key best).cost < (key next).cost) : choose key best next = best := by
  have notLower : ¬ (key next).cost < (key best).cost := by omega
  have notEqual : (key next).cost ≠ (key best).cost := by omega
  simp [choose, prefer, oldPrefer, extraTie, notLower, notEqual]

theorem cost_is_minimum {A : Type} (key : A → Key) (best next : A) :
    (key (choose key best next)).cost = min (key best).cost (key next).cost := by
  by_cases lower : (key next).cost < (key best).cost
  · rw [lower_cost_wins key best next lower, Nat.min_eq_right (Nat.le_of_lt lower)]
  by_cases higher : (key best).cost < (key next).cost
  · rw [higher_cost_loses key best next higher, Nat.min_eq_left (Nat.le_of_lt higher)]
  have same : (key next).cost = (key best).cost := by omega
  rcases chosen_is_actual key best next with h | h <;> simp [h, same]

-- The existing typed native path model supplies replay and cost, not a scalar
-- assertion that two arbitrarily reordered operation lists are interchangeable.
theorem selected_path_replays (path : List SelectedDeclarationPathTransport.Step) :
    SelectedDeclarationPathTransport.replay (SelectedDeclarationPathTransport.sources path) path =
      some (SelectedDeclarationPathTransport.targets path, SelectedDeclarationPathTransport.cost path) :=
  SelectedDeclarationPathTransport.extracted_path_replays path

end PaidOrbitTieOrder
