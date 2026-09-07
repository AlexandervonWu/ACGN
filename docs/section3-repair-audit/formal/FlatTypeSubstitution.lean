/- P2-06: the flat-type guard, followed by one shared substitution.
   Type substitution is an arbitrary function on the admitted exact type carrier.
   This proves preservation independently of the implementation of GraphType;
   the source extractor and finite Java observations bind the Java boundary. -/
namespace ACGN.NextFive.FlatTypeSubstitution

inductive Schema (T : Type) where
  | one : T -> Schema T
  | seq : Schema T -> Schema T
  | bag : Schema T -> Schema T
  | set : Schema T -> Schema T
  | other : Schema T
  deriving DecidableEq

def element? : Schema T -> Option (Schema T)
  | .seq s | .bag s | .set s => some s
  | _ => none

def validate [DecidableEq T] (schema : Schema T) (result : T) : Bool :=
  match element? schema with
  | some (.one t) => decide (t = result)
  | _ => false

def substitute (f : T -> U) : Schema T -> Schema U
  | .one t => .one (f t)
  | .seq s => .seq (substitute f s)
  | .bag s => .bag (substitute f s)
  | .set s => .set (substitute f s)
  | .other => .other

theorem validation_iff [DecidableEq T] (s : Schema T) (r : T) :
    validate s r = true <-> element? s = some (.one r) := by
  cases s with
  | one t => simp [validate, element?]
  | other => simp [validate, element?]
  | seq s | bag s | set s => cases s <;> simp [validate, element?]

theorem admission_is_homogeneous [DecidableEq T] (s : Schema T) (r : T)
    (h : validate s r = true) : element? s = some (.one r) :=
  (validation_iff s r).mp h

theorem exact_element_is_admitted [DecidableEq T] (s : Schema T) (r : T)
    (h : element? s = some (.one r)) : validate s r = true :=
  (validation_iff s r).mpr h

theorem substitution_commutes_with_element (f : T -> U) (s : Schema T) :
    element? (substitute f s) = (element? s).map (substitute f) := by
  cases s <;> rfl

theorem exact_type_preserved_by_instantiation (f : T -> U) (s : Schema T) (r : T)
    (h : element? s = some (.one r)) :
    element? (substitute f s) = some (.one (f r)) := by
  rw [substitution_commutes_with_element, h]
  rfl

theorem admitted_instantiation [DecidableEq T] [DecidableEq U]
    (f : T -> U) (s : Schema T) (r : T) (h : validate s r = true) :
    validate (substitute f s) (f r) = true :=
  exact_element_is_admitted _ _ (exact_type_preserved_by_instantiation f s r
    (admission_is_homogeneous s r h))

theorem mismatched_type_rejected [DecidableEq T] (s : Schema T) (a b : T)
    (h : element? s = some (.one a)) (different : Not (a = b)) : validate s b = false := by
  simp [validate, h, different]

theorem nested_element_rejected [DecidableEq T] (s child : Schema T) (r : T)
    (h : element? s = some (.seq child)) : validate s r = false := by
  simp [validate, h]

theorem substitution_composition (f : T -> U) (g : U -> V) (s : Schema T) :
    substitute g (substitute f s) = substitute (g ∘ f) s := by
  induction s <;> simp_all [substitute, Function.comp_def]

theorem substitution_identity (s : Schema T) : substitute id s = s := by
  induction s <;> simp_all [substitute]

-- Separate instantiations are not licensed to share types merely by operator name.
theorem separate_instantiations_can_disagree :
    validate (substitute (fun _ : Unit => (0 : Nat)) (.seq (.one ()))) 1 = false := by
  decide

structure SubstitutionSites where
  elementField : String
  resultField : String

theorem extracted_shared_substitution (sites : SubstitutionSites)
    (same : sites.elementField = sites.resultField) (environment : String -> T -> U)
    (s : Schema T) (r : T) (h : element? s = some (.one r)) :
    element? (substitute (environment sites.elementField) s) =
      some (.one (environment sites.resultField r)) := by
  rw [same]
  exact exact_type_preserved_by_instantiation _ s r h

structure Observation where
  element : String
  output : String
  expected : String
  deriving DecidableEq

def replay (o : Observation) : Bool :=
  o.element == o.expected && o.output == o.expected

theorem replay_preserves_exact_types (o : Observation) (h : replay o = true) :
    o.element = o.output := by
  simp [replay] at h
  exact h.1.trans h.2.symm

#print axioms validation_iff
#print axioms admission_is_homogeneous
#print axioms exact_element_is_admitted
#print axioms substitution_commutes_with_element
#print axioms exact_type_preserved_by_instantiation
#print axioms admitted_instantiation
#print axioms mismatched_type_rejected
#print axioms nested_element_rejected
#print axioms substitution_composition
#print axioms substitution_identity
#print axioms separate_instantiations_can_disagree
#print axioms extracted_shared_substitution
#print axioms replay_preserves_exact_types
end ACGN.NextFive.FlatTypeSubstitution
