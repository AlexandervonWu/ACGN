import DisjointGroupPermutation

namespace DisjointPrefixSelection
open DisjointGroupPermutation

-- Exact early return in FastGroupedDeclarationOrbit.orders; source issuance
-- and certified transposition membership are checked after this old filter.
def oldEarlyReturn (size : Nat) (source comparison : List Nat)
    (sourceSupported comparisonSupported : Bool) : Bool :=
  size > 6 || source.any (fun n => n != 0) || comparison.any (fun n => n != 0) ||
    !sourceSupported || !comparisonSupported

theorem disjoint_is_old_rejection (source comparison : List Nat) (size : Nat)
    (a b : Bool) (h : source.any (fun n => n != 0) = true) :
    oldEarlyReturn size source comparison a b = true := by
  simp [oldEarlyReturn, h]

-- The Java delta only widens selection to already source-certified moves.
-- It leaves the fixed outer environment and every original disjoint guard.
theorem all_selection_sound (p : Permutation I) (domain : E → A → Prop)
    (body : E → (I → A) → Prop) (env : E) :
    (∀ v, valid (domain env) v → body env v) ↔
      ∀ v, valid (domain env) v → body env (reindex p v) :=
  all_group_permutation p (domain env) (body env)

theorem some_selection_sound (p : Permutation I) (domain : E → A → Prop)
    (body : E → (I → A) → Prop) (env : E) :
    (∃ v, valid (domain env) v ∧ body env v) ↔
      ∃ v, valid (domain env) v ∧ body env (reindex p v) :=
  some_group_permutation p (domain env) (body env)

def noSharedOther (projects : Person → Project → Prop) (p : Person)
    (v : Bool → Project) : Prop :=
  ¬ ∃ other, projects other (v false) ∧ projects other (v true) ∧ other ≠ p

-- The actual target predicate's two Project reads and relational difference;
-- the outer Person is fixed, not exchanged with either Project coordinate.
theorem target_project_group_sound (projects : Person → Project → Prop) :
    (∀ p v, valid (projects p) v → noSharedOther projects p v) ↔
      ∀ p v, valid (projects p) v → noSharedOther projects p (reindex swap v) := by
  constructor
  · intro h p
    exact (all_selection_sound swap projects (noSharedOther projects) p).mp (h p)
  · intro h p
    exact (all_selection_sound swap projects (noSharedOther projects) p).mpr (h p)

-- Lowering p.projects to the Project carrier keeps its original domain tests
-- inside the body. This is not an assumption that the domain is inhabited.
theorem lifted_domain_guard (domain : A → Prop) (body : (I → A) → Prop) :
    (∀ v, valid domain v → body v) ↔
      ∀ v, valid (fun _ => True) v → (∀ i, domain (v i)) → body v := by
  constructor
  · intro h v hv domains
    exact h v ⟨domains, hv.2⟩
  · intro h v hv
    exact h v ⟨fun _ => True.intro, hv.2⟩ hv.1

def targetSwap (n : Nat) : Nat := if n = 1 then 2 else if n = 2 then 1 else n

theorem target_swap_involution (n : Nat) : targetSwap (targetSwap n) = n := by
  by_cases h1 : n = 1
  · subst n; decide
  by_cases h2 : n = 2
  · subst n; decide
  simp [targetSwap, h1, h2]

theorem target_swap_injective : Function.Injective targetSwap := by
  intro a b h
  have := congrArg targetSwap h
  simpa only [target_swap_involution] using this

def sourcePayload (n : Nat) : Nat := if n < 2 then 0 else 1
def targetPayload (n : Nat) : Nat := if n = 0 then 2 else 3

theorem target_payload_preserved (n : Nat) : targetPayload (targetSwap n) = targetPayload n := by
  by_cases h1 : n = 1
  · subst n; decide
  by_cases h2 : n = 2
  · subst n; decide
  simp [targetSwap, h1, h2]

def originalPath : List GroupedPaidOrbit.Edit :=
  [.delete 0, .diagonal 1 0, .diagonal 2 1, .diagonal 3 2]
def transportedPath : List GroupedPaidOrbit.Edit :=
  originalPath.map (GroupedPaidOrbit.move id targetSwap)
def pathCost (path : List GroupedPaidOrbit.Edit) : Nat :=
  (path.map (GroupedPaidOrbit.charge sourcePayload targetPayload)).sum

theorem every_paid_action_retained (action : GroupedPaidOrbit.Edit) :
    GroupedPaidOrbit.charge sourcePayload targetPayload
      (GroupedPaidOrbit.move id targetSwap action) =
    GroupedPaidOrbit.charge sourcePayload targetPayload action :=
  declaration_payment_retained sourcePayload targetPayload id targetSwap
    (fun _ => rfl) target_payload_preserved action

theorem original_charge_four : pathCost originalPath = 4 := by decide
theorem transported_charge_four : pathCost transportedPath = 4 := by decide
theorem original_one_group_unchanged (n : Nat) : id n = n := rfl
theorem outer_person_fixed : targetSwap 0 = 0 := by decide

#print axioms all_selection_sound
#print axioms some_selection_sound
#print axioms target_project_group_sound
#print axioms lifted_domain_guard
#print axioms every_paid_action_retained
end DisjointPrefixSelection
