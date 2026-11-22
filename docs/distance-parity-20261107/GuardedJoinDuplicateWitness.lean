import GuardedJoinDuplicateObserved

/- The two DomainAtom constants below are generated independently from the
   guarded semantic-object extraction. That executable adapter checks the
   real original invocations, binder objects, slot maps and certificate
   endpoints. Its finite source-to-model mapping is trusted Java code, not a
   universal extracted Lean verifier. -/
namespace GuardedJoinDuplicateWitness
open GuardedJoinDuplicate GuardedJoinDuplicateObserved

theorem distinct_occurrences : sourcePath ≠ retainedPath := by decide
theorem same_actual_atom : sourceAtom = retainedAtom := by decide
theorem actual_owner : sourceAtom.coordinate.owner = [0, 2, 1] ∧
    sourceAtom.coordinate.phase = 0 := by decide
theorem actual_slots :
    sourceAtom.e.alpha = "_l3" ∧ sourceAtom.c.alpha = "_q0" ∧
    sourceAtom.e.bindingPath = "root/predicate[0]/or[2]/local-decl[0]" ∧
    sourceAtom.c.bindingPath = "root/predicate[0]/decl[0]@pos" := by decide

def meaning (env : DomainEnvironment A) (residual : Coordinate → Prop) (a : Coordinate) : Prop :=
  if a = sourceAtom.coordinate then interpretDomainAtom env sourceAtom else residual a

theorem source_interpretation (env : DomainEnvironment A) (residual : Coordinate → Prop) :
    meaning env residual sourceAtom.coordinate ↔ originalDomainMembership env sourceAtom := by
  simp only [meaning]
  exact (unchanged_left_join_interpretation env sourceAtom).symm

theorem retained_interpretation (env : DomainEnvironment A) (residual : Coordinate → Prop) :
    meaning env residual retainedAtom.coordinate ↔ originalDomainMembership env retainedAtom := by
  rw [← same_actual_atom]
  exact source_interpretation env residual

-- General idempotence instantiated on the two extracted, independently
-- decoded atoms and the explicit left-associated relational interpretation.
theorem event102_instantiated (context : (DomainEnvironment A → Prop) → Prop)
    (residual : DomainEnvironment A → Coordinate → Prop)
    (pre mid post : List Coordinate) :
    context (fun env => conjunction (meaning env (residual env))
      (pre ++ sourceAtom.coordinate :: mid ++ retainedAtom.coordinate :: post)) ↔
    context (fun env => conjunction (meaning env (residual env))
      (pre ++ sourceAtom.coordinate :: mid ++ post)) := by
  rw [← same_actual_atom]
  exact scoped_duplicate context (fun env => meaning env (residual env)) pre mid post sourceAtom.coordinate

theorem observed_scope_rejected (s : OldScope) (actualLocals : s.locals = localCount) :
    oldErasureGate s = false := by
  exact old_gate_rejects_observed_locals s actualLocals

-- The typed-empty result really follows from the parser's disjoint Course
-- and Person columns, not from forgetting the unary JOIN's intermediate type.
theorem typed_empty_result (env : DomainEnvironment A) (course person : A → Prop)
    (outerCourse : course (env.slot sourceAtom.c))
    (fieldTyped : ∀ x y g, env.grades x y g → person y)
    (disjoint : ∀ a, course a → person a → False) :
    ¬ originalDomainMembership env sourceAtom := by
  intro h
  obtain ⟨g, hg, _⟩ := (unchanged_left_join_interpretation env sourceAtom).mp h
  exact disjoint _ outerCourse (fieldTyped _ _ _ hg)

#print axioms same_actual_atom
#print axioms source_interpretation
#print axioms retained_interpretation
#print axioms event102_instantiated
#print axioms observed_scope_rejected
#print axioms typed_empty_result
end GuardedJoinDuplicateWitness
