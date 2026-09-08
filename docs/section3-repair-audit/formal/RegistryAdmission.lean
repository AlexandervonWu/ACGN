/- P2-19: fixed registry admission, exact indices and reconstruction.
   TypeView preserves exact carrier identity; the relation classification and
   profile-construction boundary are separately bound by Java observations.
   No spelling in an observation is interpreted as source authority. -/
namespace ACGN.ThirdFive.RegistryAdmission

inductive TypeView where
  | bool | int | relation (identity : Nat) | other (identity : Nat)
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

inductive Op where
  | and | or | plus | intersect | iplus | mul | equals | notEquals | iff | disjoint | other
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

inductive Carrier where
  | seq | bag | set
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

inductive Law where
  | assoc | comm | idem | unit
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

inductive ProfileAuthority where
  | custom | compatibility | source
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

structure ProfileKey where
  bitwidth : Nat
  modular : Bool
  temporal : String
  rewrite : String
  signature : String
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

structure Profile where
  key : ProfileKey
  authority : ProfileAuthority
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def profileAdmitted (p : Profile) : Bool :=
  match p.authority with
  | .custom => false
  | .compatibility => true
  | .source => p.key.rewrite == "repaired-normal-form-v3;typed-alloy-normal-form-adapter-v13" &&
      p.key.signature == "canonical-alloy-signature-v8"

inductive Arity where
  | atLeast (minimum : Nat)
  | finite (counts : List Nat)
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def positive : Arity := .atLeast 1
def binary : Arity := .finite [2]

structure Schema where
  carrier : Carrier
  element : Option TypeView
  arity : Arity
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def opName : Op -> String
  | .and => "ALLOY/AND" | .or => "ALLOY/OR" | .plus => "ALLOY/PLUS"
  | .intersect => "ALLOY/INTERSECT" | .iplus => "ALLOY/IPLUS" | .mul => "ALLOY/MUL"
  | .equals => "ALLOY/EQUALS" | .notEquals => "ALLOY/NOT_EQUALS"
  | .iff => "ALLOY/IFF" | .disjoint => "ALLOY/DISJOINT" | .other => "ALLOY/CALL"

def isRelation : TypeView -> Bool
  | .relation _ => true | _ => false

structure Request where
  profile : Profile
  op : Op
  identity : String
  result : TypeView
  path : List Nat
  schema : Schema
  law : Law
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def familyAdmitted (r : Request) (element : TypeView) : Bool :=
  match r.op with
  | .and | .or | .plus | .intersect =>
      (if r.op == .and || r.op == .or then r.result == .bool && element == .bool
       else (isRelation r.result || r.result == .int) && element == r.result) &&
      r.schema.carrier == .set && r.schema.arity == positive &&
      (r.law == .assoc || r.law == .comm || r.law == .idem)
  | .iplus | .mul =>
      r.result == .int && element == .int && r.schema.carrier == .bag &&
      (if r.profile.key.modular then r.schema.arity == positive &&
         (r.law == .assoc || r.law == .comm)
       else r.schema.arity == binary && r.law == .comm)
  | .equals | .notEquals | .iff =>
      (r.op != .iff || element == .bool) && r.result == .bool &&
      r.schema.carrier == .bag && r.schema.arity == binary && r.law == .comm
  | .disjoint =>
      r.result == .bool && isRelation element && r.schema.carrier == .bag &&
      r.schema.arity == positive && r.law == .comm
  | .other => false

def admitted (r : Request) : Bool :=
  profileAdmitted r.profile && r.identity == opName r.op && r.path == [0] &&
  match r.schema.element with
  | none => false
  | some element => familyAdmitted r element

-- The complete structural parameter is retained. A digest is never its substitute.
structure Index where
  profile : ProfileKey
  op : Op
  identity : String
  result : TypeView
  path : List Nat
  schema : Schema
  law : Law
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def index (r : Request) : Index :=
  ⟨r.profile.key, r.op, r.identity, r.result, r.path, r.schema, r.law⟩

structure Origin where
  containerLaw : Bool
  theory : String
  declarationDigest : String
  ordinal : Nat
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def lawOrdinal : Law -> Nat
  | .assoc => 0 | .comm => 1 | .idem => 2 | .unit => 3

structure Certificate where
  request : Request
  fixedAuthority : Bool
  theory : String
  parameter : Index
  origin : Origin
  left : Bool × Index
  right : Bool × Index
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

-- The origin digest is an arbitrary deterministic function, not an assumed
-- injection. Exact parameter and profile comparisons remain independent of it.
variable (originDigest : Index -> String)

def expectedOrigin (theory : String) (r : Request) : Origin :=
  ⟨true, "alloy-container-law-theory-v3/" ++ theory, originDigest (index r), lawOrdinal r.law⟩

def expected (theory : String) (r : Request) : Certificate :=
  ⟨r, true, theory, index r, expectedOrigin originDigest theory r, (false, index r), (true, index r)⟩

def issue (theory : String) (r : Request) : Option Certificate :=
  if admitted r then some (expected originDigest theory r) else none

def accepts (theory : String) (c : Certificate) : Bool :=
  admitted c.request && c.fixedAuthority && c.theory == theory &&
  c.parameter == index c.request && c.origin == expectedOrigin originDigest theory c.request &&
  c.left == (false, index c.request) && c.right == (true, index c.request)

theorem issue_some_iff (theory : String) (r : Request) (c : Certificate) :
    issue originDigest theory r = some c <-> admitted r = true ∧ c = expected originDigest theory r := by
  simp only [issue]
  split
  next h => simp only [Option.some.injEq, h, true_and]; exact eq_comm
  next h => simp [h]

theorem rejects_unadmitted (theory : String) (r : Request) (h : admitted r = false) :
    issue originDigest theory r = none := by simp [issue, h]

theorem accepts_iff_reconstructed (theory : String) (c : Certificate) :
    accepts originDigest theory c = true <-> admitted c.request = true ∧ c = expected originDigest theory c.request := by
  cases c with
  | mk r a t p o l h => simp [accepts, expected, Certificate.mk.injEq, Bool.and_eq_true, and_assoc]

theorem issued_is_accepted (theory : String) (r : Request) (c : Certificate)
    (h : issue originDigest theory r = some c) : accepts originDigest theory c = true := by
  obtain ⟨ha, rfl⟩ := (issue_some_iff originDigest theory r c).mp h
  exact (accepts_iff_reconstructed originDigest theory (expected originDigest theory r)).mpr ⟨ha, rfl⟩

theorem accepted_has_fixed_authority (theory : String) (c : Certificate)
    (h : accepts originDigest theory c = true) : c.fixedAuthority = true := by
  have eq := ((accepts_iff_reconstructed originDigest theory c).mp h).2
  rw [eq]; rfl

theorem accepted_exact_profile (theory : String) (c : Certificate)
    (h : accepts originDigest theory c = true) : c.parameter.profile = c.request.profile.key := by
  have eq := ((accepts_iff_reconstructed originDigest theory c).mp h).2
  rw [eq]; rfl

theorem index_preserves_every_coordinate (a b : Request) (h : index a = index b) :
    a.profile.key = b.profile.key ∧ a.op = b.op ∧ a.identity = b.identity ∧
    a.result = b.result ∧ a.path = b.path ∧ a.schema = b.schema ∧ a.law = b.law := by
  simpa [index, Index.mk.injEq] using h

theorem changed_parameter_rejects (theory : String) (c : Certificate)
    (h : c.parameter ≠ index c.request) : accepts originDigest theory c = false := by
  cases ha : accepts originDigest theory c with
  | false => rfl
  | true =>
      have eq := ((accepts_iff_reconstructed originDigest theory c).mp ha).2
      exact False.elim (h (congrArg Certificate.parameter eq))

theorem changed_theory_rejects (theory : String) (c : Certificate)
    (h : c.theory ≠ theory) : accepts originDigest theory c = false := by
  simp [accepts, h]

theorem changed_profile_rejects (theory : String) (c : Certificate)
    (h : c.parameter.profile ≠ c.request.profile.key) : accepts originDigest theory c = false := by
  apply changed_parameter_rejects
  intro eq
  exact h (congrArg Index.profile eq)

theorem identical_spelling_custom_profile_rejects (key : ProfileKey) :
    profileAdmitted ⟨key, .custom⟩ = false := rfl

theorem wrong_operator_identity_rejects (r : Request) (h : r.identity ≠ opName r.op) :
    admitted r = false := by simp [admitted, h]

theorem wrong_path_rejects (r : Request) (h : r.path ≠ [0]) : admitted r = false := by
  simp [admitted, h]

theorem nested_element_rejects (r : Request) (h : r.schema.element = none) :
    admitted r = false := by simp [admitted, h]

theorem no_registry_unit (r : Request) (h : r.law = .unit) : admitted r = false := by
  cases he : r.schema.element <;> simp [admitted, he]
  case some element => cases hop : r.op <;> simp [familyAdmitted, hop, h]

theorem no_unknown_operator (r : Request) (h : r.op = .other) : admitted r = false := by
  cases he : r.schema.element <;> simp [admitted, he, familyAdmitted, h]

-- A custom profile can have the same key; key equality alone does not authorize it.
theorem authority_not_encoded_by_profile_spelling (key : ProfileKey) :
    index ⟨⟨key, .custom⟩, .and, "ALLOY/AND", .bool, [0], ⟨.set, some .bool, positive⟩, .assoc⟩ =
    index ⟨⟨key, .compatibility⟩, .and, "ALLOY/AND", .bool, [0], ⟨.set, some .bool, positive⟩, .assoc⟩ := rfl

#print axioms issue_some_iff
#print axioms rejects_unadmitted
#print axioms accepts_iff_reconstructed
#print axioms issued_is_accepted
#print axioms accepted_has_fixed_authority
#print axioms accepted_exact_profile
#print axioms index_preserves_every_coordinate
#print axioms changed_parameter_rejects
#print axioms changed_theory_rejects
#print axioms changed_profile_rejects
#print axioms identical_spelling_custom_profile_rejects
#print axioms wrong_operator_identity_rejects
#print axioms wrong_path_rejects
#print axioms nested_element_rejects
#print axioms no_registry_unit
#print axioms no_unknown_operator
#print axioms authority_not_encoded_by_profile_spelling
end ACGN.ThirdFive.RegistryAdmission
