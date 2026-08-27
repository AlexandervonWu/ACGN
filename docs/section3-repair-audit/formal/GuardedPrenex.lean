/-
Bounded formal model for the guarded-prenex side condition exercised by
MASGVisitorTypeRegressionTest. This proves the abstract logical step only;
the Java/SAT regression supplies the source-to-model refinement evidence.
-/

def GuardedOriginal (α : Type) (c : Prop) (d p : α → Prop) : Prop :=
  c ∧ ∀ x, d x → p x

def GuardedLifted (α : Type) (c : Prop) (d p : α → Prop) : Prop :=
  ∀ x, c ∧ (d x → p x)

theorem guarded_lift_requires_inhabited_carrier
    {α : Type} [Nonempty α] (c : Prop) (d p : α → Prop) :
    GuardedOriginal α c d p ↔ GuardedLifted α c d p := by
  constructor
  · intro source x
    exact ⟨source.1, source.2 x⟩
  · intro lifted
    let ⟨witness⟩ := ‹Nonempty α›
    exact ⟨(lifted witness).1, fun x => (lifted x).2⟩

theorem empty_carrier_blocks_unconditional_guarded_lift :
    ¬ (GuardedOriginal Empty False (fun x => nomatch x) (fun x => nomatch x) ↔
       GuardedLifted Empty False (fun x => nomatch x) (fun x => nomatch x)) := by
  intro alleged
  have lifted :
      GuardedLifted Empty False (fun x => nomatch x) (fun x => nomatch x) := by
    intro x
    exact nomatch x
  exact (alleged.mpr lifted).1

def GuardedExistsOriginal
    (α β : Type) (domain : α → Prop) (body : α → β → Prop) : Prop :=
  ∀ x, domain x → ∃ y, body x y

def GuardedExistsLifted
    (α β : Type) (domain : α → Prop) (body : α → β → Prop) : Prop :=
  ∀ x, ∃ y, domain x → body x y

theorem guarded_exists_lift_requires_inhabited_inner_carrier
    {α β : Type} [Nonempty β]
    (domain : α → Prop) (body : α → β → Prop) :
    GuardedExistsOriginal α β domain body ↔
      GuardedExistsLifted α β domain body := by
  constructor
  · intro source x
    by_cases active : domain x
    · let ⟨y, proof⟩ := source x active
      exact ⟨y, fun _ => proof⟩
    · let ⟨y⟩ := ‹Nonempty β›
      exact ⟨y, fun impossible => False.elim (active impossible)⟩
  · intro lifted x active
    let ⟨y, proof⟩ := lifted x
    exact ⟨y, proof active⟩

theorem empty_inner_carrier_blocks_guarded_exists_lift :
    ¬ (GuardedExistsOriginal Unit Empty (fun _ => False)
          (fun _ y => nomatch y) ↔
       GuardedExistsLifted Unit Empty (fun _ => False)
          (fun _ y => nomatch y)) := by
  intro alleged
  have source :
      GuardedExistsOriginal Unit Empty (fun _ => False)
        (fun _ y => nomatch y) := by
    intro _ impossible
    exact False.elim impossible
  have lifted := alleged.mp source
  let ⟨witness, _⟩ := lifted ()
  exact nomatch witness

def main : IO Unit := do
  IO.println "guarded-prenex-model-v1"
