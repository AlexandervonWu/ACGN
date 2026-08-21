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

def main : IO Unit := do
  IO.println "guarded-prenex-model-v1"
