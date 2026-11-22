import LocalDeclarationProjection

namespace UniversalDeclarationProjection
open LocalDeclarationProjection LocalDeclarationProjection.Regrouping

-- The old capture branch omitted FORALL even though the comparison copy
-- already regrouped it. The exact tuple/owner checker itself is retained.
def oldCaptureGate (opcode : String) : Bool := opcode == "COMPREHENSION"

def universal (meaning : Term → (Slot → A) → A → Prop)
    (body : (Slot → A) → Prop) (ds : List (Declaration Term)) : Prop :=
  ∀ env, (∀ d ∈ ds, accepts meaning env d) → body env

theorem regroup_universal [DecidableEq Term] (a b : Declaration Term)
    (checked : compatible a b = true)
    (meaning : Term → (Slot → A) → A → Prop) (body : (Slot → A) → Prop)
    (pre post : List (Declaration Term)) :
    universal meaning body (pre ++ merge a b :: post) ↔
      universal meaning body (pre ++ a :: b :: post) := by
  have pointwise (env : Slot → A) :
      (∀ d ∈ pre ++ merge a b :: post, accepts meaning env d) ↔
      (∀ d ∈ pre ++ a :: b :: post, accepts meaning env d) := by
    constructor
    · intro h d hd
      rcases List.mem_append.mp hd with hp | ht
      · exact h d (List.mem_append_left _ hp)
      · have hm := (merge_sound a b checked meaning env).mp
          (h (merge a b) (List.mem_append_right _ (by simp)))
        rcases List.mem_cons.mp ht with ha | ht
        · subst d; exact hm.1
        · rcases List.mem_cons.mp ht with hb | hs
          · subst d; exact hm.2
          · exact h d (List.mem_append_right _ (List.mem_cons_of_mem _ hs))
    · intro h d hd
      rcases List.mem_append.mp hd with hp | ht
      · exact h d (List.mem_append_left _ hp)
      · rcases List.mem_cons.mp ht with hm | hs
        · subst d
          apply (merge_sound a b checked meaning env).mpr
          constructor
          · exact h a (List.mem_append_right _ (by simp))
          · exact h b (List.mem_append_right _ (by simp))
        · exact h d (List.mem_append_right _ (List.mem_cons_of_mem _ (List.mem_cons_of_mem _ hs)))
  constructor
  · intro h env hs; exact h env ((pointwise env).mpr hs)
  · intro h env hs; exact h env ((pointwise env).mp hs)

theorem recovered_universal [DecidableEq Term] (captured supplied : Capture Term)
    (checked : sameCapture captured supplied = true)
    (meaning : Term → (Slot → A) → A → Prop) (body : (Slot → A) → Prop) :
    universal meaning body captured.declarations ↔
      universal meaning body supplied.declarations := by
  rw [capture_recovers_originals captured supplied checked]

theorem recovered_coordinates [DecidableEq Term] (captured supplied : Capture Term)
    (checked : sameCapture captured supplied = true) :
    captured.declarations.map (fun d => d.view.group) =
      supplied.declarations.map (fun d => d.view.group) := by
  rw [capture_recovers_originals captured supplied checked]

-- The natural social-media instance retains the full typed body. Neither a
-- nonempty User carrier nor truth of the compared predicates is assumed.
def socialBody (sees posts : U → P → Prop) (ad : P → Prop)
    (follows : U → U → Prop) (x y : U) (p : P) : Prop :=
  (sees x p ∧ ¬ ad p ∧ posts y p) → follows x y

theorem social_universal_grouping (users : U → Prop) (photos : P → Prop)
    (sees posts : U → P → Prop) (ad : P → Prop) (follows : U → U → Prop) :
    (∀ x, users x → ∀ y, users y → ∀ p, photos p → socialBody sees posts ad follows x y p) ↔
    (∀ pair : U × U, (users pair.1 ∧ users pair.2) →
      ∀ p, photos p → socialBody sees posts ad follows pair.1 pair.2 p) := by
  constructor
  · intro h pair hp; exact h pair.1 hp.1 pair.2 hp.2
  · intro h x hx y hy; exact h (x,y) ⟨hx,hy⟩

theorem production_universal_grouping (products components : A → Prop)
    (parts : A → A → Prop) :
    (∀ a, products a → ∀ b, products b → (parts a b → components a)) ↔
    (∀ pair : A × A, (products pair.1 ∧ products pair.2) →
      (parts pair.1 pair.2 → components pair.1)) := by
  constructor
  · intro h pair hp; exact h pair.1 hp.1 pair.2 hp.2
  · intro h a ha b hb; exact h (a,b) ⟨ha,hb⟩

theorem no_native_action_change (s : LocalOwnerTrace.Store) (as : List LocalOwnerTrace.Action) :
    LocalDeclarationProjection.execute s (as.map (LocalOwnerTrace.transport id)) =
      LocalDeclarationProjection.execute s as := retained_selected_path s as

end UniversalDeclarationProjection
