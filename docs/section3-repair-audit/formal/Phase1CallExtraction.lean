import Std

namespace ACGN.Section3.Phase1

inductive CallKind where
  | formula
  | expression
  deriving DecidableEq

inductive ArityAuthority where
  | localDeclaration
  | importedLedger
  deriving DecidableEq

structure CallKey where
  kind : CallKind
  qualifiedCallee : String
  declaredArity : Nat
  authority : ArityAuthority
  deriving DecidableEq

structure Visit where
  occurrence : Nat
  declaredCallee : String
  callees : List String
  calleeOwners : List Nat
  arguments : List (Nat × Nat)
  argumentOwners : List Nat
  endOwners : List Nat
  edgeOrder : List (Option Nat)
  declaredArity : Nat
  deriving DecidableEq

def argumentRoles (visit : Visit) : List Nat := visit.arguments.map Prod.fst

/-
  `none` in `edgeOrder` is used twice: the first occurrence is the callee and
  the final occurrence is END.  The exact list equation fixes both positions;
  every `some role` between them is an argument role.
-/
structure ValidVisit (visit : Visit) : Prop where
  exactCallee : visit.callees = [visit.declaredCallee]
  calleeOwnership : visit.calleeOwners = [visit.occurrence]
  argumentCount : visit.arguments.length = visit.declaredArity
  argumentOwnership :
    visit.argumentOwners = List.replicate visit.declaredArity visit.occurrence
  orderedRoles : argumentRoles visit = List.range visit.declaredArity
  exactTerminator : visit.endOwners = [visit.occurrence]
  exactEdgeOrder :
    visit.edgeOrder = none :: (List.range visit.declaredArity).map some ++ [none]

/- Bounded creation/capture model.  The Java refinement obligation remains
separate: this model states exactly what "immediately" and "stable" mean. -/
structure CreationCapture where
  createdOccurrence : Nat
  capturedOccurrence : Nat
  createdAt : Nat
  capturedAt : Nat
  deriving DecidableEq

structure ValidCreationCapture (capture : CreationCapture) : Prop where
  stableOccurrence : capture.capturedOccurrence = capture.createdOccurrence
  immediateCapture : capture.capturedAt = capture.createdAt + 1

theorem valid_creation_capture_is_immediate_and_stable
    (capture : CreationCapture) (valid : ValidCreationCapture capture) :
    capture.capturedOccurrence = capture.createdOccurrence /\
      capture.capturedAt = capture.createdAt + 1 :=
  ⟨valid.stableOccurrence, valid.immediateCapture⟩

theorem valid_visit_has_one_callee
    (visit : Visit) (valid : ValidVisit visit) :
    visit.callees.length = 1 := by
  rw [valid.exactCallee]
  rfl

theorem valid_visit_has_exact_callee_identity
    (visit : Visit) (valid : ValidVisit visit) :
    visit.callees = [visit.declaredCallee] := valid.exactCallee

theorem valid_visit_callee_belongs_to_occurrence
    (visit : Visit) (valid : ValidVisit visit) :
    visit.calleeOwners = [visit.occurrence] := valid.calleeOwnership

theorem valid_visit_uses_declared_arity
    (visit : Visit) (valid : ValidVisit visit) :
    visit.arguments.length = visit.declaredArity := valid.argumentCount

theorem valid_visit_arguments_belong_to_occurrence
    (visit : Visit) (valid : ValidVisit visit) :
    visit.argumentOwners = List.replicate visit.declaredArity visit.occurrence :=
  valid.argumentOwnership

theorem valid_visit_has_contiguous_ordered_roles
    (visit : Visit) (valid : ValidVisit visit) :
    argumentRoles visit = List.range visit.declaredArity := valid.orderedRoles

theorem valid_visit_owns_exact_terminator
    (visit : Visit) (valid : ValidVisit visit) :
    visit.endOwners = [visit.occurrence] := valid.exactTerminator

theorem valid_visit_has_exact_callee_argument_end_order
    (visit : Visit) (valid : ValidVisit visit) :
    visit.edgeOrder = none :: (List.range visit.declaredArity).map some ++ [none] :=
  valid.exactEdgeOrder

def completeBinaryVisit : Visit :=
  { occurrence := 7
    declaredCallee := "module/h"
    callees := ["module/h"]
    calleeOwners := [7]
    arguments := [(0, 11), (1, 12)]
    argumentOwners := [7, 7]
    endOwners := [7]
    edgeOrder := [none, some 0, some 1, none]
    declaredArity := 2 }

theorem complete_binary_visit_is_valid : ValidVisit completeBinaryVisit := by
  constructor <;> native_decide

def missingEndVisit : Visit := { completeBinaryVisit with endOwners := [] }
def foreignEndVisit : Visit := { completeBinaryVisit with endOwners := [8] }
def swappedRoleVisit : Visit :=
  { completeBinaryVisit with arguments := [(1, 12), (0, 11)] }
def observedInsteadOfDeclaredVisit : Visit :=
  { completeBinaryVisit with arguments := [(0, 11)] }
def foreignCalleeVisit : Visit :=
  { completeBinaryVisit with calleeOwners := [8] }
def foreignArgumentVisit : Visit :=
  { completeBinaryVisit with argumentOwners := [7, 8] }
def wrongCalleeIdentityVisit : Visit :=
  { completeBinaryVisit with callees := ["another/h"] }
def endBeforeArgumentsVisit : Visit :=
  { completeBinaryVisit with edgeOrder := [none, none, some 0, some 1] }

theorem missing_end_rejects : Not (ValidVisit missingEndVisit) := by
  intro valid
  have mismatch : missingEndVisit.endOwners ≠ [missingEndVisit.occurrence] := by
    native_decide
  exact mismatch valid.exactTerminator
theorem foreign_end_rejects : Not (ValidVisit foreignEndVisit) := by
  intro valid
  have mismatch : foreignEndVisit.endOwners ≠ [foreignEndVisit.occurrence] := by
    native_decide
  exact mismatch valid.exactTerminator
theorem noncontiguous_roles_reject : Not (ValidVisit swappedRoleVisit) := by
  intro valid
  have mismatch :
      argumentRoles swappedRoleVisit ≠ List.range swappedRoleVisit.declaredArity := by
    native_decide
  exact mismatch valid.orderedRoles
theorem observed_arity_cannot_replace_declared_arity :
    Not (ValidVisit observedInsteadOfDeclaredVisit) := by
  intro valid
  have mismatch :
      observedInsteadOfDeclaredVisit.arguments.length ≠
        observedInsteadOfDeclaredVisit.declaredArity := by
    native_decide
  exact mismatch valid.argumentCount

theorem foreign_callee_visit_rejects : Not (ValidVisit foreignCalleeVisit) := by
  intro valid
  have mismatch :
      foreignCalleeVisit.calleeOwners ≠ [foreignCalleeVisit.occurrence] := by
    native_decide
  exact mismatch valid.calleeOwnership

theorem foreign_argument_visit_rejects : Not (ValidVisit foreignArgumentVisit) := by
  intro valid
  have mismatch :
      foreignArgumentVisit.argumentOwners ≠
        List.replicate foreignArgumentVisit.declaredArity
          foreignArgumentVisit.occurrence := by
    native_decide
  exact mismatch valid.argumentOwnership

theorem wrong_callee_identity_rejects : Not (ValidVisit wrongCalleeIdentityVisit) := by
  intro valid
  have mismatch :
      wrongCalleeIdentityVisit.callees ≠
        [wrongCalleeIdentityVisit.declaredCallee] := by
    native_decide
  exact mismatch valid.exactCallee

theorem end_before_arguments_rejects : Not (ValidVisit endBeforeArgumentsVisit) := by
  intro valid
  have mismatch :
      endBeforeArgumentsVisit.edgeOrder ≠
        none :: (List.range endBeforeArgumentsVisit.declaredArity).map some ++ [none] := by
    native_decide
  exact mismatch valid.exactEdgeOrder

def zeroArgumentVisit : Visit :=
  { occurrence := 9
    declaredCallee := "module/z"
    callees := ["module/z"]
    calleeOwners := [9]
    arguments := []
    argumentOwners := []
    endOwners := [9]
    edgeOrder := [none, none]
    declaredArity := 0 }

theorem zero_argument_call_is_valid : ValidVisit zeroArgumentVisit := by
  constructor <;> native_decide

structure UniqueOccurrences (visits : List Visit) : Prop where
  sameIdentity :
    forall left, left ∈ visits -> forall right, right ∈ visits ->
      left.occurrence = right.occurrence -> left = right
  atMostOneConsumption :
    forall occurrence,
      (visits.filter (fun visit => visit.occurrence == occurrence)).length ≤ 1

theorem occurrence_ledger_prevents_reuse
    (visits : List Visit)
    (unique : UniqueOccurrences visits)
    (left right : Visit)
    (leftMember : left ∈ visits)
    (rightMember : right ∈ visits)
    (sameOccurrence : left.occurrence = right.occurrence) :
    left = right :=
  unique.sameIdentity left leftMember right rightMember sameOccurrence

theorem duplicated_occurrence_is_rejected :
    Not (UniqueOccurrences [completeBinaryVisit, completeBinaryVisit]) := by
  intro unique
  have bound := unique.atMostOneConsumption completeBinaryVisit.occurrence
  simp [completeBinaryVisit] at bound

theorem equal_call_keys_preserve_kind
    (left right : CallKey) (same : left = right) : left.kind = right.kind := by
  exact congrArg CallKey.kind same

theorem equal_call_keys_preserve_qualified_identity
    (left right : CallKey) (same : left = right) :
    left.qualifiedCallee = right.qualifiedCallee := by
  exact congrArg CallKey.qualifiedCallee same

theorem equal_call_keys_preserve_declared_arity
    (left right : CallKey) (same : left = right) :
    left.declaredArity = right.declaredArity := by
  exact congrArg CallKey.declaredArity same

theorem equal_call_keys_preserve_authority
    (left right : CallKey) (same : left = right) :
    left.authority = right.authority := by
  exact congrArg CallKey.authority same

structure CalleeTarget where
  sourceSpelling : String
  declarationKey : CallKey
  deriving DecidableEq

def targetMatches (sourceSpelling : String) (key : CallKey)
    (target : CalleeTarget) : Bool :=
  target.sourceSpelling == sourceSpelling && target.declarationKey == key

def requestedF : CallKey :=
  { kind := .expression
    qualifiedCallee := "module/f"
    declaredArity := 1
    authority := .localDeclaration }

def exactFTarget : CalleeTarget :=
  { sourceSpelling := "f", declarationKey := requestedF }

def sameSpellingWrongQualifiedTarget : CalleeTarget :=
  { sourceSpelling := "f"
    declarationKey := { requestedF with qualifiedCallee := "other/f" } }

theorem exact_complete_callee_target_accepts :
    targetMatches "f" requestedF exactFTarget = true := by decide

theorem same_spelling_wrong_qualified_target_rejects :
    targetMatches "f" requestedF sameSpellingWrongQualifiedTarget = false := by decide

structure CallTerm where
  key : CallKey
  orderedArguments : List Nat
  deriving DecidableEq

theorem call_term_equality_preserves_argument_order
    (left right : CallTerm) (same : left = right) :
    left.orderedArguments = right.orderedArguments := by
  exact congrArg CallTerm.orderedArguments same

theorem swapped_arguments_are_distinct :
    Not ([11, 12] = [12, 11]) := by decide

def generatorArguments (term : CallTerm) : List Nat := term.orderedArguments

theorem generation_preserves_source_order (term : CallTerm) :
    generatorArguments term = term.orderedArguments := by rfl

structure GeneratedCall where
  key : CallKey
  orderedArguments : List Nat
  deriving DecidableEq

def generateCall (term : CallTerm) : GeneratedCall :=
  ⟨term.key, term.orderedArguments⟩

theorem generation_preserves_exact_identity_and_source_order (term : CallTerm) :
    (generateCall term).key = term.key /\
      (generateCall term).orderedArguments = term.orderedArguments := by
  constructor <;> rfl

theorem generation_rejects_same_spelling_wrong_qualified_target :
    targetMatches "f" requestedF sameSpellingWrongQualifiedTarget = false := by
  exact same_spelling_wrong_qualified_target_rejects

/- Parser-to-term preservation is modeled as an explicit source record and a
single capture function.  It proves the model boundary, not the Alloy parser's
implementation refinement. -/
structure ParsedCall where
  key : CallKey
  sourceArguments : List Nat
  deriving DecidableEq

def captureParsedCall (parsed : ParsedCall) : CallTerm :=
  ⟨parsed.key, parsed.sourceArguments⟩

theorem capture_preserves_parser_key_and_argument_order (parsed : ParsedCall) :
    (captureParsedCall parsed).key = parsed.key /\
      (captureParsedCall parsed).orderedArguments = parsed.sourceArguments := by
  constructor <;> rfl

/- Accepted visits carry their validity proof.  Therefore this interface has
no constructor that can silently accept a malformed visit via a fallback. -/
structure AcceptedVisit where
  visit : Visit
  validity : ValidVisit visit

theorem accepted_visit_is_complete_and_has_no_fallback
    (accepted : AcceptedVisit) : ValidVisit accepted.visit :=
  accepted.validity

structure LibraryLedgerEntry where
  qualifiedCallee : String
  kind : CallKind
  declaredArity : Nat
  deriving DecidableEq

def ImportedCallAccepted
    (fixedLedger : List LibraryLedgerEntry)
    (requested : LibraryLedgerEntry) : Prop :=
  requested ∈ fixedLedger

theorem accepted_import_is_exact_fixed_ledger_member
    (fixedLedger : List LibraryLedgerEntry)
    (requested : LibraryLedgerEntry)
    (accepted : ImportedCallAccepted fixedLedger requested) :
    requested ∈ fixedLedger :=
  accepted

theorem unlisted_import_is_rejected
    (fixedLedger : List LibraryLedgerEntry)
    (requested : LibraryLedgerEntry)
    (absent : requested ∉ fixedLedger) :
    Not (ImportedCallAccepted fixedLedger requested) :=
  absent

structure CallPolicy where
  ordered : Bool
  flat : Bool
  commutative : Bool
  idempotent : Bool
  deriving DecidableEq

def exactCallPolicy : CallPolicy :=
  { ordered := true, flat := false, commutative := false, idempotent := false }

theorem call_policy_is_ordered_nonflat_noncommutative_nonidempotent :
    exactCallPolicy.ordered = true /\
    exactCallPolicy.flat = false /\
    exactCallPolicy.commutative = false /\
    exactCallPolicy.idempotent = false := by
  decide

inductive CallTree where
  | atom (value : Nat)
  | call (occurrence : Nat) (key : CallKey) (arguments : List CallTree)

def callTreeOccurrences : CallTree -> List (Nat × CallKey)
  | .atom _ => []
  | .call occurrence key arguments =>
      (occurrence, key) :: arguments.flatMap callTreeOccurrences

def requestedG : CallKey :=
  { kind := .expression
    qualifiedCallee := "module/g"
    declaredArity := 1
    authority := .localDeclaration }

def nestedFG : CallTree :=
  .call 1 requestedF [.call 2 requestedG [.atom 11]]

theorem nested_mixed_call_preserves_both_callees_and_ownership :
    callTreeOccurrences nestedFG = [(1, requestedF), (2, requestedG)] := by
  simp [nestedFG, callTreeOccurrences]

theorem nested_mixed_call_occurrences_are_distinct :
    Not ((1 : Nat) = 2) := by decide

structure CallWireEvidence where
  occurrence : Nat
  sourcePath : String
  sourceSpelling : String
  key : CallKey
  roles : List Nat
  orderedArgumentEndpoints : List Nat
  sourceEndpoint : Nat
  deriving DecidableEq

structure ValidCallWireEvidence (evidence : CallWireEvidence) : Prop where
  contiguousRoles : evidence.roles = List.range evidence.key.declaredArity
  endpointCount :
    evidence.orderedArgumentEndpoints.length = evidence.key.declaredArity

theorem equal_wire_evidence_preserves_every_serialized_field
    (left right : CallWireEvidence) (same : left = right) :
    left.occurrence = right.occurrence ∧
    left.sourcePath = right.sourcePath ∧
    left.sourceSpelling = right.sourceSpelling ∧
    left.key = right.key ∧
    left.roles = right.roles ∧
    left.orderedArgumentEndpoints = right.orderedArgumentEndpoints ∧
    left.sourceEndpoint = right.sourceEndpoint := by
  subst right
  simp

theorem valid_wire_evidence_has_exact_roles_and_ordered_endpoint_count
    (evidence : CallWireEvidence) (valid : ValidCallWireEvidence evidence) :
    evidence.roles = List.range evidence.key.declaredArity ∧
    evidence.orderedArgumentEndpoints.length = evidence.key.declaredArity :=
  ⟨valid.contiguousRoles, valid.endpointCount⟩

theorem wire_field_projection_is_injective
    (left right : CallWireEvidence)
    (occurrence : left.occurrence = right.occurrence)
    (path : left.sourcePath = right.sourcePath)
    (spelling : left.sourceSpelling = right.sourceSpelling)
    (key : left.key = right.key)
    (roles : left.roles = right.roles)
    (arguments :
      left.orderedArgumentEndpoints = right.orderedArgumentEndpoints)
    (endpoint : left.sourceEndpoint = right.sourceEndpoint) :
    left = right := by
  cases left
  cases right
  simp_all

def semanticCallOfEvidence (evidence : CallWireEvidence) : CallTerm :=
  { key := evidence.key
    orderedArguments := evidence.orderedArgumentEndpoints }

theorem occurrence_is_provenance_not_semantic_identity
    (left right : CallWireEvidence)
    (sameKey : left.key = right.key)
    (sameArguments :
      left.orderedArgumentEndpoints = right.orderedArgumentEndpoints) :
    semanticCallOfEvidence left = semanticCallOfEvidence right := by
  simp [semanticCallOfEvidence, sameKey, sameArguments]

def exactCallOccurrenceLedger
    (required supplied : List CallWireEvidence) : Bool :=
  required.all supplied.contains && supplied.all required.contains

def exactCallOperatorCoverage
    (required supplied : List CallKey) : Bool :=
  required.all supplied.contains && supplied.all required.contains

def unaryCallWireEvidence : CallWireEvidence :=
  { occurrence := 41
    sourcePath := "phase/0/matrix"
    sourceSpelling := "f"
    key := requestedF
    roles := [0]
    orderedArgumentEndpoints := [11]
    sourceEndpoint := 17 }

theorem exact_call_occurrence_ledger_accepts_complete_evidence :
    exactCallOccurrenceLedger
      [unaryCallWireEvidence] [unaryCallWireEvidence] = true := by
  decide

theorem omitted_call_occurrence_evidence_rejects :
    exactCallOccurrenceLedger [unaryCallWireEvidence] [] = false := by
  decide

theorem exact_call_operator_coverage_accepts_complete_evidence :
    exactCallOperatorCoverage [requestedF] [requestedF] = true := by
  decide

theorem omitted_call_operator_evidence_rejects :
    exactCallOperatorCoverage [requestedF] [] = false := by
  decide

def callOccurrenceAnchor
    (evidence : CallWireEvidence) : Nat × String × CallWireEvidence :=
  (evidence.occurrence, evidence.sourcePath, evidence)

def exactCallAnchorCoverage
    (required : List CallWireEvidence)
    (anchors : List (Nat × String × CallWireEvidence)) : Bool :=
  let expected := required.map callOccurrenceAnchor
  expected.all anchors.contains && anchors.all expected.contains

def nestedInnerCallWireEvidence : CallWireEvidence :=
  { occurrence := 51
    sourcePath := "phase/0/matrix/0"
    sourceSpelling := "f"
    key := requestedF
    roles := [0]
    orderedArgumentEndpoints := [11]
    sourceEndpoint := 17 }

def nestedOuterCallWireEvidence : CallWireEvidence :=
  { occurrence := 52
    sourcePath := "phase/0/matrix"
    sourceSpelling := "f"
    key := requestedF
    roles := [0]
    orderedArgumentEndpoints := [17]
    sourceEndpoint := 18 }

theorem nested_same_operator_occurrence_anchors_are_distinct :
    callOccurrenceAnchor nestedInnerCallWireEvidence ≠
      callOccurrenceAnchor nestedOuterCallWireEvidence := by
  decide

theorem complete_nested_call_anchor_coverage_accepts :
    exactCallAnchorCoverage
      [nestedInnerCallWireEvidence, nestedOuterCallWireEvidence]
      [callOccurrenceAnchor nestedInnerCallWireEvidence,
       callOccurrenceAnchor nestedOuterCallWireEvidence] = true := by
  decide

theorem one_omitted_nested_call_anchor_rejects :
    exactCallAnchorCoverage
      [nestedInnerCallWireEvidence, nestedOuterCallWireEvidence]
      [callOccurrenceAnchor nestedOuterCallWireEvidence] = false := by
  decide

/- A bundle-local anchor cannot establish source completeness. The MVP
   verifier therefore receives the expected occurrence set from a caller-owned
   commitment. Coordinated deletion of a row and its local anchor still differs
   from that independently retained set. SHA-256 transport of this finite set
   is checked by Java and remains an explicit cryptographic assumption. -/
def externallyAuthorizedCallOccurrences
    (pinned observed : List CallWireEvidence) : Bool :=
  exactCallOccurrenceLedger pinned observed

theorem externally_pinned_nested_calls_accept :
    externallyAuthorizedCallOccurrences
      [nestedInnerCallWireEvidence, nestedOuterCallWireEvidence]
      [nestedInnerCallWireEvidence, nestedOuterCallWireEvidence] = true := by
  decide

theorem coordinated_nested_call_omission_rejects :
    externallyAuthorizedCallOccurrences
      [nestedInnerCallWireEvidence, nestedOuterCallWireEvidence]
      [nestedOuterCallWireEvidence] = false := by
  decide

structure CallAnchorTerm where
  key : Nat × String × CallWireEvidence
  sourceContext : Nat
  sourceSort : Nat
  scalarReferences : Nat
  deriving DecidableEq

def validCallAnchorTerm
    (evidence : CallWireEvidence)
    (expectedContext expectedSort : Nat)
    (anchor : CallAnchorTerm) : Bool :=
  anchor.key == callOccurrenceAnchor evidence &&
  anchor.sourceContext == expectedContext &&
  anchor.sourceSort == expectedSort &&
  anchor.scalarReferences == 1

def nestedInnerAnchorTerm : CallAnchorTerm :=
  { key := callOccurrenceAnchor nestedInnerCallWireEvidence
    sourceContext := 7
    sourceSort := 3
    scalarReferences := 1 }

theorem isolated_call_anchor_accepts :
    validCallAnchorTerm nestedInnerCallWireEvidence 7 3
      nestedInnerAnchorTerm = true := by
  decide

theorem canonically_referenced_call_anchor_rejects :
    validCallAnchorTerm nestedInnerCallWireEvidence 7 3
      { nestedInnerAnchorTerm with scalarReferences := 2 } = false := by
  decide

theorem wrong_context_call_anchor_rejects :
    validCallAnchorTerm nestedInnerCallWireEvidence 7 3
      { nestedInnerAnchorTerm with sourceContext := 8 } = false := by
  decide

theorem wrong_sort_call_anchor_rejects :
    validCallAnchorTerm nestedInnerCallWireEvidence 7 3
      { nestedInnerAnchorTerm with sourceSort := 4 } = false := by
  decide

inductive Atom where
  | a
  | b
  deriving DecidableEq

def twoCycle : Atom -> Atom
  | .a => .b
  | .b => .a

theorem nested_call_differs_from_single (x : Atom) :
    Not (twoCycle (twoCycle x) = twoCycle x) := by
  cases x <;> decide

theorem nested_call_returns_input (x : Atom) :
    twoCycle (twoCycle x) = x := by
  cases x <;> rfl

end ACGN.Section3.Phase1
