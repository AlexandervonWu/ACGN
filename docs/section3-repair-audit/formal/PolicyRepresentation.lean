import Std

namespace ACGN.BoundedFive.PolicyRepresentation

/- P2-02 representation only, read against
   src/is/fivefivefive/CanDis/core/AlloyOperatorPolicy.java.
   Payloads denote arbitrary non-null nominal values, not license booleans.
   Equality here is equality of the four-field representation, not Java object
   identity or Object.equals. Factory reachability and payload behavior are
   outside this model; no Java/compiler correspondence is established here. -/

universe uA uS uF uU

structure ArityPolicy (Payload : Type uA) where
  payload : Payload

structure SiblingQuotient (Payload : Type uS) where
  payload : Payload

structure FlatLicense (Payload : Type uF) where
  payload : Payload

structure UnitLicense (Payload : Type uU) where
  payload : Payload

structure Policy (A : Type uA) (S : Type uS) (F : Type uF) (U : Type uU) where
  arityPolicy : ArityPolicy A
  siblingQuotient : SiblingQuotient S
  flatLicense : FlatLicense F
  unitLicense : UnitLicense U

variable {A : Type uA} {S : Type uS} {F : Type uF} {U : Type uU}

abbrev PolicyProduct (A : Type uA) (S : Type uS) (F : Type uF) (U : Type uU) :=
  ArityPolicy A × SiblingQuotient S × FlatLicense F × UnitLicense U

def construct (a : ArityPolicy A) (s : SiblingQuotient S)
    (f : FlatLicense F) (u : UnitLicense U) : Policy A S F U :=
  ⟨a, s, f, u⟩

/- The four Policy projections model the four direct Java getters. -/
def toProduct (p : Policy A S F U) : PolicyProduct A S F U :=
  (p.arityPolicy, p.siblingQuotient, p.flatLicense, p.unitLicense)

def fromProduct (p : PolicyProduct A S F U) : Policy A S F U :=
  construct p.1 p.2.1 p.2.2.1 p.2.2.2

theorem getter_constructor_roundtrip (p : PolicyProduct A S F U) :
    toProduct (fromProduct p) = p := rfl

theorem constructor_getter_roundtrip (p : Policy A S F U) :
    fromProduct (toProduct p) = p := rfl

theorem policy_extensionality (p q : Policy A S F U)
    (ha : p.arityPolicy = q.arityPolicy)
    (hs : p.siblingQuotient = q.siblingQuotient)
    (hf : p.flatLicense = q.flatLicense)
    (hu : p.unitLicense = q.unitLicense) : p = q := by
  cases p
  cases q
  cases ha
  cases hs
  cases hf
  cases hu
  rfl

theorem policy_fields_jointly_determine_policy (p q : Policy A S F U) :
    p = q ↔ toProduct p = toProduct q := by
  constructor
  · intro h
    cases h
    rfl
  · intro h
    exact congrArg fromProduct h

/- Each statement quantifies independently over all four nominal coordinates.
   No coordinate is computed from, or constrained by, any other coordinate. -/
theorem arity_policy_preserved (a : ArityPolicy A) (s : SiblingQuotient S)
    (f : FlatLicense F) (u : UnitLicense U) :
    (construct a s f u).arityPolicy = a := rfl

theorem sibling_quotient_preserved (a : ArityPolicy A) (s : SiblingQuotient S)
    (f : FlatLicense F) (u : UnitLicense U) :
    (construct a s f u).siblingQuotient = s := rfl

theorem flat_license_preserved (a : ArityPolicy A) (s : SiblingQuotient S)
    (f : FlatLicense F) (u : UnitLicense U) :
    (construct a s f u).flatLicense = f := rfl

theorem unit_license_preserved (a : ArityPolicy A) (s : SiblingQuotient S)
    (f : FlatLicense F) (u : UnitLicense U) :
    (construct a s f u).unitLicense = u := rfl

/- Outer none denotes a null reference; even a disabled FlatLicense is some
   nominal payload. Failure abstracts requireNonNull rejection, not exception
   messages, allocation, or the order of partially executed assignments. -/
def constructNullable (a : Option (ArityPolicy A)) (s : Option (SiblingQuotient S))
    (f : Option (FlatLicense F)) (u : Option (UnitLicense U)) : Option (Policy A S F U) :=
  match a, s, f, u with
  | some a, some s, some f, some u => some (construct a s f u)
  | _, _, _, _ => none

theorem nonnull_constructor_preserves_product
    (a : ArityPolicy A) (s : SiblingQuotient S) (f : FlatLicense F) (u : UnitLicense U) :
    (constructNullable (some a) (some s) (some f) (some u)).map toProduct =
      some (a, s, f, u) := rfl

theorem null_rejection_iff (a : Option (ArityPolicy A)) (s : Option (SiblingQuotient S))
    (f : Option (FlatLicense F)) (u : Option (UnitLicense U)) :
    constructNullable a s f u = none ↔ a = none ∨ s = none ∨ f = none ∨ u = none := by
  cases a <;> cases s <;> cases f <;> cases u <;> simp [constructNullable]

/- Extractor interface, all indices zero-based:
   canonical field/getter order and constructor parameter order are
     0: arityPolicy     : is.fivefivefive.CanDis.theory.ArityPolicy
     1: siblingQuotient : is.fivefivefive.CanDis.theory.SiblingQuotient
     2: flatLicense     : is.fivefivefive.CanDis.theory.FlatLicense
     3: unitLicense     : is.fivefivefive.CanDis.theory.UnitLicense
   constructorParameterPositions[field] selects the assigned parameter after
   requireNonNull; getterFieldPositions[getter] selects the returned field.
   An extractor must separately check owner, nominal types, final fields,
   requireNonNull guards and direct assignment/return bodies. These eight
   indices alone neither encode those checks nor prove source correspondence. -/
structure SourceProgram where
  constructorParameterPositions : List Nat
  getterFieldPositions : List Nat
  deriving DecidableEq, Repr

def sourceProgram : SourceProgram :=
  ⟨[0, 1, 2, 3], [0, 1, 2, 3]⟩

def runSourceProgram {Payload : Type _} (program : SourceProgram)
    (arguments : List Payload) : List (Option Payload) :=
  program.getterFieldPositions.map fun field =>
    (program.constructorParameterPositions[field]?).bind fun parameter =>
      arguments[parameter]?

theorem source_program_index_roundtrip {Payload : Type _} (a s f u : Payload) :
    runSourceProgram sourceProgram [a, s, f, u] = [some a, some s, some f, some u] := rfl

/- The list interface retains nominal tags, including when A = S = F = U. -/
inductive CoordinateValue (A : Type uA) (S : Type uS) (F : Type uF) (U : Type uU) where
  | arityPolicy (value : ArityPolicy A)
  | siblingQuotient (value : SiblingQuotient S)
  | flatLicense (value : FlatLicense F)
  | unitLicense (value : UnitLicense U)

def nominalArguments (a : ArityPolicy A) (s : SiblingQuotient S)
    (f : FlatLicense F) (u : UnitLicense U) : List (CoordinateValue A S F U) :=
  [.arityPolicy a, .siblingQuotient s, .flatLicense f, .unitLicense u]

def nominalGetters (p : Policy A S F U) : List (CoordinateValue A S F U) :=
  nominalArguments p.arityPolicy p.siblingQuotient p.flatLicense p.unitLicense

theorem source_program_preserves_nominal_product
    (a : ArityPolicy A) (s : SiblingQuotient S) (f : FlatLicense F) (u : UnitLicense U) :
    runSourceProgram sourceProgram (nominalArguments a s f u) =
      (nominalGetters (construct a s f u)).map some := rfl

theorem extracted_program_preserves_nominal_product (program : SourceProgram)
    (constructorPositions : program.constructorParameterPositions = [0, 1, 2, 3])
    (getterPositions : program.getterFieldPositions = [0, 1, 2, 3])
    (a : ArityPolicy A) (s : SiblingQuotient S) (f : FlatLicense F) (u : UnitLicense U) :
    runSourceProgram program (nominalArguments a s f u) =
      (nominalGetters (construct a s f u)).map some := by
  cases program with
  | mk constructorParameters getterFields =>
    cases constructorPositions
    cases getterPositions
    rfl

end ACGN.BoundedFive.PolicyRepresentation

#print axioms ACGN.BoundedFive.PolicyRepresentation.getter_constructor_roundtrip
#print axioms ACGN.BoundedFive.PolicyRepresentation.constructor_getter_roundtrip
#print axioms ACGN.BoundedFive.PolicyRepresentation.policy_extensionality
#print axioms ACGN.BoundedFive.PolicyRepresentation.policy_fields_jointly_determine_policy
#print axioms ACGN.BoundedFive.PolicyRepresentation.arity_policy_preserved
#print axioms ACGN.BoundedFive.PolicyRepresentation.sibling_quotient_preserved
#print axioms ACGN.BoundedFive.PolicyRepresentation.flat_license_preserved
#print axioms ACGN.BoundedFive.PolicyRepresentation.unit_license_preserved
#print axioms ACGN.BoundedFive.PolicyRepresentation.nonnull_constructor_preserves_product
#print axioms ACGN.BoundedFive.PolicyRepresentation.null_rejection_iff
#print axioms ACGN.BoundedFive.PolicyRepresentation.source_program_index_roundtrip
#print axioms ACGN.BoundedFive.PolicyRepresentation.source_program_preserves_nominal_product
#print axioms ACGN.BoundedFive.PolicyRepresentation.extracted_program_preserves_nominal_product
