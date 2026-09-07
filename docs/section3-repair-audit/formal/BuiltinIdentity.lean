import Std

namespace ACGN.BoundedFive.BuiltinIdentity

/- P5-15, standalone semantic specification. Java parsing, lowering, nominal
   field decoding, solver execution and correspondence to these definitions
   are tested/trusted boundaries, not theorems of Java refinement. The node
   predicate describes EGraphNode.isSetConstant after requireLiveNode succeeds;
   it does not model arena lifetime or authorize construction from metadata.
   SourceKind and the other tags below are nominal, not Boolean authority flags.
   No claim of an inhabited Alloy universe is made. -/

inductive Builtin where
  | noneSet
  | univSet
  deriving DecidableEq, Repr

def Builtin.spelling : Builtin -> String
  | .noneSet => "none"
  | .univSet => "univ"

def Builtin.identity : Builtin -> String
  | .noneSet => "alloy/builtin/none"
  | .univSet => "alloy/builtin/univ"

def classifyReserved (name : String) : Option Builtin :=
  if name = "none" then some .noneSet
  else if name = "univ" then some .univSet
  else none

theorem classifier_exact (name : String) (builtin : Builtin) :
    classifyReserved name = some builtin <-> name = builtin.spelling := by
  cases builtin <;> unfold classifyReserved Builtin.spelling <;>
    split <;> simp_all

theorem classifier_nonreserved (name : String) :
    classifyReserved name = none <-> name ≠ "none" /\ name ≠ "univ" := by
  unfold classifyReserved
  split <;> simp_all

inductive SignatureKind where
  | user
  | builtin (value : Builtin)
  | int
  | sequenceIndex
  deriving DecidableEq, Repr

def signatureIdentity (kind : SignatureKind) (name : String) : String :=
  match kind with
  | .user => "alloy/signature/" ++ name
  | .builtin builtin => builtin.identity
  | .int => "alloy/builtin/Int"
  | .sequenceIndex => "alloy/builtin/seq/Int"

theorem builtin_identity_ignores_display_name (builtin : Builtin) (name : String) :
    signatureIdentity (.builtin builtin) name = builtin.identity := rfl

theorem user_identity_is_not_builtin (name : String) (builtin : Builtin) :
    signatureIdentity .user name ≠ builtin.identity := by
  intro equal
  have firstChars := congrArg (fun text : String => text.toList.take 7) equal
  cases builtin <;>
    simp [signatureIdentity, Builtin.identity, String.toList_append, List.take] at firstChars

inductive Opcode where
  | globalBinding
  | constant
  | other (tag : String)
  deriving DecidableEq, Repr

inductive SourceKind where
  | signature
  | field
  | variable
  | literal
  | other (tag : String)
  deriving DecidableEq, Repr

inductive Metatype where
  | atomic
  | set
  | boolean
  | control
  deriving DecidableEq, Repr

inductive ConstantKind where
  | set (builtin : Builtin)
  | iden
  deriving DecidableEq, Repr

structure NodeIdentity where
  opcode : Opcode
  constantKind : Option ConstantKind
  semanticIdentity : String
  sourceName : String
  sourceKind : SourceKind
  metatype : Metatype
  childCount : Nat
  deriving DecidableEq, Repr

def Permitted (node : NodeIdentity) (builtin : Builtin) : Prop :=
  (node.opcode = .globalBinding \/ node.opcode = .constant) /\
  node.constantKind = some (.set builtin) /\
  node.semanticIdentity = builtin.identity /\
  node.sourceName = builtin.spelling /\
  node.sourceKind = .signature /\ node.metatype = .set /\ node.childCount = 0

def isSetConstant (node : NodeIdentity) (query : String) : Bool :=
  match classifyReserved query with
  | none => false
  | some builtin =>
      (node.opcode == .globalBinding || node.opcode == .constant) &&
      node.constantKind == some (.set builtin) &&
      node.semanticIdentity == builtin.identity && node.sourceName == query &&
      node.sourceKind == .signature && node.metatype == .set && node.childCount == 0

theorem permitted_identity_iff (node : NodeIdentity) (query : String) :
    isSetConstant node query = true <->
      exists builtin, query = builtin.spelling /\ Permitted node builtin := by
  cases classified : classifyReserved query with
  | none =>
      simp only [isSetConstant, classified, Bool.false_eq_true, false_iff, not_exists]
      intro builtin matched
      have reserved := (classifier_exact query builtin).mpr matched.1
      simp [classified] at reserved
  | some builtin =>
      have spelling := (classifier_exact query builtin).mp classified
      have unique (other : Builtin) (same : query = other.spelling) : other = builtin := by
        have reserved := (classifier_exact query other).mpr same
        rw [classified] at reserved
        exact (Option.some.inj reserved).symm
      simp only [isSetConstant, classified, Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq]
      constructor
      · intro fields
        exact ⟨builtin, spelling, fields.1.1.1.1.1.1, fields.1.1.1.1.1.2,
          fields.1.1.1.1.2, fields.1.1.1.2.trans spelling, fields.1.1.2,
          fields.1.2, fields.2⟩
      · rintro ⟨other, same, permitted⟩
        have equal := unique other same
        subst other
        rcases permitted with ⟨opcode, kind, identity, name, source, metatypeEq, children⟩
        exact ⟨⟨⟨⟨⟨⟨opcode, kind⟩, identity⟩, name.trans spelling.symm⟩, source⟩, metatypeEq⟩, children⟩

theorem nonreserved_query_rejected (node : NodeIdentity) (query : String)
    (notNone : query ≠ "none") (notUniv : query ≠ "univ") :
    isSetConstant node query = false := by
  simp [isSetConstant, (classifier_nonreserved query).mpr ⟨notNone, notUniv⟩]

theorem nominal_kind_required (node : NodeIdentity) (query : String)
    (accepted : isSetConstant node query = true) :
    exists builtin, node.constantKind = some (.set builtin) := by
  obtain ⟨builtin, _, permitted⟩ := (permitted_identity_iff node query).mp accepted
  exact ⟨builtin, permitted.2.1⟩

theorem source_kind_required (node : NodeIdentity) (query : String)
    (accepted : isSetConstant node query = true) : node.sourceKind = .signature := by
  obtain ⟨_, _, permitted⟩ := (permitted_identity_iff node query).mp accepted
  exact permitted.2.2.2.2.1

theorem user_identity_rejected (node : NodeIdentity) (name query : String)
    (user : node.semanticIdentity = signatureIdentity .user name) :
    isSetConstant node query = false := by
  cases result : isSetConstant node query with
  | false => rfl
  | true =>
      obtain ⟨builtin, _, permitted⟩ := (permitted_identity_iff node query).mp result
      exact False.elim (user_identity_is_not_builtin name builtin (user.symm.trans permitted.2.2.1))

/- Predicates on arbitrary tuple types model relations of any arity. In
   particular, the empty-cardinality results do not require a finite or
   inhabited carrier and are not quantifier-binding multiplicity claims. -/
universe u
abbrev Rel (Tuple : Type u) := Tuple -> Prop

def noneRel : Rel Tuple := fun _ => False
def univRel : Rel Tuple := fun _ => True
def someRel (relation : Rel Tuple) : Prop := exists tuple, relation tuple
def noRel (relation : Rel Tuple) : Prop := forall tuple, Not (relation tuple)
def loneRel (relation : Rel Tuple) : Prop :=
  forall left right, relation left -> relation right -> left = right
def oneRel (relation : Rel Tuple) : Prop := someRel relation /\ loneRel relation

inductive Cardinality where
  | some
  | no
  | one
  | lone
  deriving DecidableEq, Repr

def Cardinality.denote (op : Cardinality) (relation : Rel Tuple) : Prop :=
  match op with
  | .some => someRel relation
  | .no => noRel relation
  | .one => oneRel relation
  | .lone => loneRel relation

def emptyCardinality : Cardinality -> Bool
  | .some => false
  | .no => true
  | .one => false
  | .lone => true

theorem some_none : Not (someRel (noneRel : Rel Tuple)) := by
  rintro ⟨_, impossible⟩
  exact impossible

theorem no_none : noRel (noneRel : Rel Tuple) := fun _ impossible => impossible

theorem lone_none : loneRel (noneRel : Rel Tuple) := by
  intro _ _ impossible
  exact False.elim impossible

theorem one_none : Not (oneRel (noneRel : Rel Tuple)) := fun one => some_none one.1

theorem empty_cardinality_semantics (op : Cardinality) :
    op.denote (noneRel : Rel Tuple) <-> emptyCardinality op = true := by
  cases op <;> simp [Cardinality.denote, emptyCardinality, some_none, no_none, one_none, lone_none]

theorem semantically_empty_cardinality (op : Cardinality) (relation : Rel Tuple)
    (empty : forall tuple, Not (relation tuple)) :
    op.denote relation <-> emptyCardinality op = true := by
  have equal : relation = noneRel := by
    funext tuple
    exact propext ⟨empty tuple, False.elim⟩
  rw [equal]
  exact empty_cardinality_semantics op

theorem union_none_identity (relation : Rel Tuple) (tuple : Tuple) :
    (noneRel tuple \/ relation tuple) <-> relation tuple := by
  exact or_iff_right False.elim

theorem subset_univ (relation : Rel Tuple) :
    forall tuple, relation tuple -> univRel tuple := by
  intro _ _
  exact True.intro

theorem univ_nonempty_iff_carrier :
    someRel (univRel : Rel Tuple) <-> Nonempty Tuple := by
  exact ⟨fun ⟨tuple, _⟩ => ⟨tuple⟩, fun ⟨tuple⟩ => ⟨tuple, True.intro⟩⟩

theorem empty_univ_not_inhabited : Not (someRel (univRel : Rel Empty)) := by
  rintro ⟨tuple, _⟩
  exact nomatch tuple

theorem empty_univ_has_no_members : noRel (univRel : Rel Empty) := by
  intro tuple
  exact nomatch tuple

theorem empty_univ_equals_none : (univRel : Rel Empty) = noneRel := by
  funext tuple
  exact nomatch tuple

theorem inhabited_univ_differs_from_none (tuple : Tuple) :
    (univRel : Rel Tuple) ≠ noneRel := by
  intro equal
  have member : (noneRel : Rel Tuple) tuple := equal ▸ True.intro
  exact member

end ACGN.BoundedFive.BuiltinIdentity

#print axioms ACGN.BoundedFive.BuiltinIdentity.classifier_exact
#print axioms ACGN.BoundedFive.BuiltinIdentity.classifier_nonreserved
#print axioms ACGN.BoundedFive.BuiltinIdentity.builtin_identity_ignores_display_name
#print axioms ACGN.BoundedFive.BuiltinIdentity.user_identity_is_not_builtin
#print axioms ACGN.BoundedFive.BuiltinIdentity.permitted_identity_iff
#print axioms ACGN.BoundedFive.BuiltinIdentity.nonreserved_query_rejected
#print axioms ACGN.BoundedFive.BuiltinIdentity.nominal_kind_required
#print axioms ACGN.BoundedFive.BuiltinIdentity.source_kind_required
#print axioms ACGN.BoundedFive.BuiltinIdentity.user_identity_rejected
#print axioms ACGN.BoundedFive.BuiltinIdentity.some_none
#print axioms ACGN.BoundedFive.BuiltinIdentity.no_none
#print axioms ACGN.BoundedFive.BuiltinIdentity.lone_none
#print axioms ACGN.BoundedFive.BuiltinIdentity.one_none
#print axioms ACGN.BoundedFive.BuiltinIdentity.empty_cardinality_semantics
#print axioms ACGN.BoundedFive.BuiltinIdentity.semantically_empty_cardinality
#print axioms ACGN.BoundedFive.BuiltinIdentity.union_none_identity
#print axioms ACGN.BoundedFive.BuiltinIdentity.subset_univ
#print axioms ACGN.BoundedFive.BuiltinIdentity.univ_nonempty_iff_carrier
#print axioms ACGN.BoundedFive.BuiltinIdentity.empty_univ_not_inhabited
#print axioms ACGN.BoundedFive.BuiltinIdentity.empty_univ_has_no_members
#print axioms ACGN.BoundedFive.BuiltinIdentity.empty_univ_equals_none
#print axioms ACGN.BoundedFive.BuiltinIdentity.inhabited_univ_differs_from_none
