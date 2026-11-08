import Std

/- Fixed selected matrix correspondence, not a proof of its semantic admission.
   Occurrences below are original (owner, coordinate) pairs. A checked source
   permutation transports both the declaration endpoint and its link. -/
namespace JointDeclarationMatrixReplay

abbrev Occurrence := Nat × Nat
abbrev Mapping := Occurrence → Option Occurrence

inductive Edit where
  | keep (source target : Occurrence)
  | delete (source : Occurrence)
  | insert (target : Occurrence)

def linked (m : Mapping) : Edit → Prop
  | .keep a b => m a = some b
  | .delete a => m a = none
  | .insert b => ∀ a, m a ≠ some b

theorem keep_retains_selected_link (m : Mapping) (a b : Occurrence)
    (h : linked m (.keep a b)) : m a = some b := h

theorem mapped_source_not_deleted (m : Mapping) (a b : Occurrence)
    (h : m a = some b) : ¬ linked m (.delete a) := by
  intro bad
  simp [linked, h] at bad

theorem mapped_target_not_inserted (m : Mapping) (a b : Occurrence)
    (h : m a = some b) : ¬ linked m (.insert b) := by
  intro bad
  exact bad a h

theorem substituted_keep_rejected (m : Mapping) (a b c : Occurrence)
    (h : m a = some b) (different : b ≠ c) : ¬ linked m (.keep a c) := by
  intro bad
  exact different (Option.some.inj (h.symm.trans bad))

def update (a b : Nat) := if a = b then 0 else 1

theorem same_tuple_permutation_preserves_charge (tuple : Occurrence → Nat)
    (perm : Occurrence → Occurrence) (typed : ∀ a, tuple (perm a) = tuple a)
    (a : Occurrence) (target : Nat) :
    update (tuple (perm a)) target = update (tuple a) target := by rw [typed]

theorem transported_keep_is_original_link (m : Mapping)
    (p q : Occurrence → Occurrence) (a b : Occurrence)
    (h : linked m (.keep (p a) (q b))) : m (p a) = some (q b) := h

-- Connecting orders use only already-admitted homogeneous independent blocks.
-- These laws hold for empty carriers too; they do not permit ALL/SOME mixing,
-- ONE/LONE exchange, dependency capture, or a change of temporal owner.
theorem all_exchange {A : Type} (p : A → A → Prop) :
    (∀ x y, p x y) ↔ ∀ y x, p x y := by
  constructor <;> intro h x y <;> exact h y x

theorem some_exchange {A : Type} (p : A → A → Prop) :
    (∃ x y, p x y) ↔ ∃ y x, p x y := by
  constructor
  · rintro ⟨x, y, h⟩; exact ⟨y, x, h⟩
  · rintro ⟨y, x, h⟩; exact ⟨x, y, h⟩

-- Reordering a fixed candidate set must not change the scalar minimum. This
-- permits deterministic occurrence order on ties, not candidate restriction.
theorem candidate_reordering_preserves_minimum (xs ys : List Nat)
    (same : xs.Perm ys) (initial : Nat) :
    xs.foldl min initial = ys.foldl min initial := by
  induction same generalizing initial with
  | nil => rfl
  | cons a _ ih => exact ih (min initial a)
  | swap a b rest =>
    simp only [List.foldl_cons]
    congr 1
    omega
  | trans _ _ ih₁ ih₂ => exact (ih₁ initial).trans (ih₂ initial)

#print axioms keep_retains_selected_link
#print axioms mapped_source_not_deleted
#print axioms mapped_target_not_inserted
#print axioms substituted_keep_rejected
#print axioms same_tuple_permutation_preserves_charge
#print axioms transported_keep_is_original_link
#print axioms all_exchange
#print axioms some_exchange
#print axioms candidate_reordering_preserves_minimum
end JointDeclarationMatrixReplay
