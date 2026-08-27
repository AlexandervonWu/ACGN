import Std

namespace ACGN.Section3.PhaseA2

abbrev Col := Nat

/- ARROW is ordered concatenation, so source association disappears while
   position and multiplicity remain observable. -/
def arrowCols (left right : List Col) : List Col := left ++ right

theorem arrow_reassociation (a b c : List Col) :
    arrowCols (arrowCols a b) c = arrowCols a (arrowCols b c) := by
  simp [arrowCols, List.append_assoc]

theorem arrow_order_is_observable :
    Not (arrowCols [0] [1] = arrowCols [1] [0]) := by
  decide

theorem arrow_duplicate_is_preserved :
    arrowCols [0] [0] = [0, 0] := by
  rfl

/- Both dependent operators retain their operands in a positional sequence.
These two finite witnesses rule out observing that carrier as a Bag or Set. -/
def joinOperandSeq {Column : Type}
    (operands : List (List Column)) : List (List Column) := operands

theorem join_order_is_observable :
    Not (joinOperandSeq [[0], [1]] = joinOperandSeq [[1], [0]]) := by
  decide

theorem join_duplicate_is_preserved :
    joinOperandSeq [[0], [0]] = [[0], [0]] := by
  rfl

/- JOIN is not unconditionally associative. A sound variadic chain therefore
   gives every interior operand distinct left and right boundary positions. -/

structure LeftTuple (Atom : Type) where
  pre : List Atom
  boundary : Atom

structure MiddleTuple (Atom : Type) where
  leftBoundary : Atom
  interior : List Atom
  rightBoundary : Atom

structure RightTuple (Atom : Type) where
  boundary : Atom
  suffix : List Atom

def joinLeftMiddle {Atom : Type}
    (left : LeftTuple Atom) (middle : MiddleTuple Atom)
    (_boundaryEq : left.boundary = middle.leftBoundary) : LeftTuple Atom :=
  { pre := left.pre ++ middle.interior
    boundary := middle.rightBoundary }

def joinMiddleRight {Atom : Type}
    (middle : MiddleTuple Atom) (right : RightTuple Atom)
    (_boundaryEq : middle.rightBoundary = right.boundary) : RightTuple Atom :=
  { boundary := middle.leftBoundary
    suffix := middle.interior ++ right.suffix }

def joinLeftRight {Atom : Type}
    (left : LeftTuple Atom) (right : RightTuple Atom)
    (_matches : left.boundary = right.boundary) : List Atom :=
  left.pre ++ right.suffix

theorem guarded_join_tuple_reassociation {Atom : Type}
    (left : LeftTuple Atom)
    (middle : MiddleTuple Atom)
    (right : RightTuple Atom)
    (leftMatch : left.boundary = middle.leftBoundary)
    (rightMatch : middle.rightBoundary = right.boundary) :
    joinLeftRight
        (joinLeftMiddle left middle leftMatch)
        right rightMatch =
      joinLeftRight
        left
        (joinMiddleRight middle right rightMatch)
        leftMatch := by
  simp [joinLeftRight, joinLeftMiddle, joinMiddleRight, List.append_assoc]

def JoinLM {Atom : Type}
    (R : LeftTuple Atom -> Prop)
    (S : MiddleTuple Atom -> Prop)
    (output : LeftTuple Atom) : Prop :=
  exists left middle,
    R left /\ S middle /\
    exists boundaryEq : left.boundary = middle.leftBoundary,
      output = joinLeftMiddle left middle boundaryEq

def JoinMR {Atom : Type}
    (S : MiddleTuple Atom -> Prop)
    (T : RightTuple Atom -> Prop)
    (output : RightTuple Atom) : Prop :=
  exists middle right,
    S middle /\ T right /\
    exists boundaryEq : middle.rightBoundary = right.boundary,
      output = joinMiddleRight middle right boundaryEq

def JoinLR {Atom : Type}
    (R : LeftTuple Atom -> Prop)
    (T : RightTuple Atom -> Prop)
    (output : List Atom) : Prop :=
  exists left right,
    R left /\ T right /\
    exists boundaryEq : left.boundary = right.boundary,
      output = joinLeftRight left right boundaryEq

theorem guarded_join_relation_reassociation {Atom : Type}
    (R : LeftTuple Atom -> Prop)
    (S : MiddleTuple Atom -> Prop)
    (T : RightTuple Atom -> Prop)
    (output : List Atom) :
    JoinLR (JoinLM R S) T output <-> JoinLR R (JoinMR S T) output := by
  constructor
  · rintro ⟨joined, right, ⟨left, middle, hR, hS, leftMatch, rfl⟩,
      hT, rightMatch, rfl⟩
    exact ⟨left, joinMiddleRight middle right rightMatch, hR,
      ⟨middle, right, hS, hT, rightMatch, rfl⟩,
      leftMatch, guarded_join_tuple_reassociation
        left middle right leftMatch rightMatch⟩
  · rintro ⟨left, joined, hR,
      ⟨middle, right, hS, hT, rightMatch, rfl⟩,
      leftMatch, rfl⟩
    exact ⟨joinLeftMiddle left middle leftMatch, right,
      ⟨left, middle, hR, hS, leftMatch, rfl⟩,
      hT, rightMatch, (guarded_join_tuple_reassociation
        left middle right leftMatch rightMatch).symm⟩

def joinFlatGuard {Column : Type} (operands : List (List Column)) : Bool :=
  if operands.length <= 2 then true
  else (operands.drop 1).dropLast.all fun columns => 2 <= columns.length

theorem unary_interior_join_has_no_flat_license :
    joinFlatGuard [[0, 0], [0], [0, 0]] = false := by decide

theorem binary_interior_join_has_flat_license :
    joinFlatGuard [[0, 0], [0, 0], [0, 0]] = true := by decide

inductive CounterAtom where
  | a | b
  deriving DecidableEq, BEq

def splitLast {Atom : Type} : List Atom -> Option (List Atom × Atom)
  | [] => none
  | head :: tail =>
      match splitLast tail with
      | none => some ([], head)
      | some (pre, last) => some (head :: pre, last)

def tupleJoin [BEq Atom] (left right : List Atom) : Option (List Atom) :=
  match splitLast left, right with
  | some (pre, leftBoundary), rightBoundary :: suffix =>
      if leftBoundary == rightBoundary then some (pre ++ suffix) else none
  | _, _ => none

def relationJoin [BEq Atom]
    (left right : List (List Atom)) : List (List Atom) :=
  left.flatMap fun leftTuple => right.filterMap fun rightTuple =>
    tupleJoin leftTuple rightTuple

def counterR : List (List CounterAtom) := [[.a, .b]]
def counterS : List (List CounterAtom) := [[.b]]
def counterT : List (List CounterAtom) := [[.a, .a]]

theorem unguarded_join_left_value :
    relationJoin (relationJoin counterR counterS) counterT = [[.a]] := by
  decide

theorem unguarded_join_right_value :
    relationJoin counterR (relationJoin counterS counterT) = [] := by
  decide

theorem unguarded_join_is_not_associative :
    Not (relationJoin (relationJoin counterR counterS) counterT =
      relationJoin counterR (relationJoin counterS counterT)) := by
  decide

inductive StoredType where
  | int
  | carrier (name : Nat)
  | relation (columns : List Col)
  | unsupported (name : Nat)
  deriving DecidableEq

def primitiveRelationView : StoredType -> Option (List Col)
  | .int => some [0]
  | .carrier name => some [name + 1]
  | _ => none

def relationView : StoredType -> Option (List Col)
  | .relation columns => some columns
  | stored => primitiveRelationView stored

theorem exact_relation_leaf (columns : List Col) :
    relationView (.relation columns) = some columns := by
  rfl

theorem primitive_int_leaf : relationView .int = some [0] := by
  rfl

theorem primitive_carrier_leaf (name : Nat) :
    relationView (.carrier name) = some [name + 1] := by
  rfl

theorem parameter_spelling_has_no_independent_authority (ordinal : Nat) :
    relationView (.unsupported ordinal) = none := by
  rfl

theorem successful_relation_view_has_only_two_rule_families
    (stored : StoredType)
    (columns : List Col)
    (success : relationView stored = some columns) :
    (exists exact, stored = .relation exact /\ columns = exact) \/
    (stored = .int /\ columns = [0]) \/
    (exists name, stored = .carrier name /\ columns = [name + 1]) := by
  cases stored with
  | int =>
      simp [relationView, primitiveRelationView] at success
      exact Or.inr (Or.inl ⟨rfl, success.symm⟩)
  | carrier name =>
      simp [relationView, primitiveRelationView] at success
      exact Or.inr (Or.inr ⟨name, rfl, success.symm⟩)
  | relation exact =>
      simp [relationView] at success
      exact Or.inl ⟨exact, rfl, success.symm⟩
  | unsupported name =>
      simp [relationView, primitiveRelationView] at success

theorem unsupported_leaf_has_no_proof (name : Nat) :
    relationView (.unsupported name) = none := by
  rfl

inductive TypeProvenance where
  | exact (columns : List Col)
  | absent
  deriving DecidableEq

def exactColumns : TypeProvenance -> Option (List Col)
  | .exact columns => some columns
  | .absent => none

theorem absent_type_does_not_invent_univ :
    exactColumns .absent = none := by
  rfl

theorem explicit_univ_is_retained (univColumn : Col) :
    exactColumns (.exact [univColumn]) = some [univColumn] := by
  rfl

def chainTypingEligible (columns : List Col) : Bool :=
  !columns.isEmpty

theorem explicit_univ_has_chain_typing_authority (univColumn : Col) :
    chainTypingEligible [univColumn] = true := by
  simp [chainTypingEligible]

/- A dependent JOIN may meet at two distinct nominal static carriers only when
   one is connected to the other by the parser's direct PrimSig parent chain.
   The proof does not replace either carrier with `univ`: it records the exact
   endpoints and every direct-parent step. -/

inductive NominalSig where
  | univ | integer | sequenceIndex | product | component | position
  deriving DecidableEq, Repr

/- Parser positions are transferable metadata, so producer authority also
   binds the identity of every PrimSig object to one live CompModule.  Object
   IDs model Java identity, independently of nominal labels and parent paths. -/

inductive ParserSourceFile where
  | known (identity : Nat)
  | unknown
  | whitespace
  deriving DecidableEq, Repr

structure ParserSourcePosition where
  sourceFile : ParserSourceFile
  line : Nat
  column : Nat
  deriving DecidableEq, Repr

inductive ParserParentProvenance where
  | source (position : ParserSourcePosition)
  | alloySequenceIndex
  | alloyUniverseRoot
  deriving DecidableEq, Repr

structure ParserParentDeclaration where
  childObjectId : Nat
  parentObjectId : Nat
  provenance : ParserParentProvenance
  deriving DecidableEq, Repr

structure ParserModuleSnapshot where
  moduleIdentity : Nat
  moduleObjects : List (Nat × NominalSig)
  parentDeclarations : List ParserParentDeclaration
  deriving DecidableEq, Repr

def productionParserSnapshot : ParserModuleSnapshot :=
  { moduleIdentity := 1
    moduleObjects :=
      [(1, .product), (2, .component), (3, .position), (4, .univ),
       (5, .sequenceIndex), (6, .integer)]
    parentDeclarations :=
      [{ childObjectId := 2, parentObjectId := 1,
          provenance := .source
            { sourceFile := .known 1, line := 1, column := 1 } },
       { childObjectId := 5, parentObjectId := 6,
          provenance := .alloySequenceIndex },
       { childObjectId := 1, parentObjectId := 4,
          provenance := .alloyUniverseRoot },
       { childObjectId := 3, parentObjectId := 4,
          provenance := .alloyUniverseRoot },
       { childObjectId := 6, parentObjectId := 4,
          provenance := .alloyUniverseRoot }] }

def foreignParserSnapshot : ParserModuleSnapshot :=
  { moduleIdentity := 2
    moduleObjects :=
      [(11, .product), (12, .component), (13, .position), (14, .univ)]
    parentDeclarations :=
      [{ childObjectId := 12, parentObjectId := 11,
          provenance := .source
            { sourceFile := .known 2, line := 1, column := 1 } },
       { childObjectId := 11, parentObjectId := 14,
          provenance := .alloyUniverseRoot },
       { childObjectId := 13, parentObjectId := 14,
          provenance := .alloyUniverseRoot }] }

/- A live parser capability is indexed by the exact immutable module snapshot.
   Its private constructor admits only the closed finite snapshots above; it
   is not serialized data and is not a caller-settable Boolean. -/

structure ParserModuleCapability (snapshot : ParserModuleSnapshot) : Prop where
  private mk ::
  approved : snapshot = productionParserSnapshot \/
    snapshot = foreignParserSnapshot

private theorem productionParserCapability :
    ParserModuleCapability productionParserSnapshot := by
  constructor
  exact Or.inl rfl

private theorem foreignParserCapability :
    ParserModuleCapability foreignParserSnapshot := by
  constructor
  exact Or.inr rfl

structure ParserModuleAuthority where
  snapshot : ParserModuleSnapshot
  capability : ParserModuleCapability snapshot

def productionParserAuthority : ParserModuleAuthority :=
  { snapshot := productionParserSnapshot
    capability := productionParserCapability }

def foreignParserAuthority : ParserModuleAuthority :=
  { snapshot := foreignParserSnapshot
    capability := foreignParserCapability }

theorem live_parser_authority_has_a_closed_snapshot
    (authority : ParserModuleAuthority) :
    authority.snapshot = productionParserSnapshot \/
      authority.snapshot = foreignParserSnapshot :=
  authority.capability.approved

theorem production_and_foreign_module_identities_are_distinct :
    productionParserSnapshot.moduleIdentity !=
      foreignParserSnapshot.moduleIdentity := by
  decide

def parserPositionIsKnown (position : ParserSourcePosition) : Bool :=
  match position.sourceFile with
  | .known _ => true
  | .unknown | .whitespace => false

def parserModuleObjectIdsAreUnique
    (snapshot : ParserModuleSnapshot) : Bool :=
  decide (snapshot.moduleObjects.map Prod.fst).Nodup

def parserModuleHasObjectId
    (snapshot : ParserModuleSnapshot) (objectId : Nat) : Bool :=
  snapshot.moduleObjects.any fun entry => entry.1 == objectId

def parserModuleHasObject
    (snapshot : ParserModuleSnapshot)
    (objectId : Nat) (nominal : NominalSig) : Bool :=
  snapshot.moduleObjects.contains (objectId, nominal)

def parserParentProvenanceIsAuthorized
    (snapshot : ParserModuleSnapshot)
    (declaration : ParserParentDeclaration) : Bool :=
  match declaration.provenance with
  | .source position => parserPositionIsKnown position
  | .alloySequenceIndex =>
      parserModuleHasObject snapshot declaration.childObjectId .sequenceIndex &&
        parserModuleHasObject snapshot declaration.parentObjectId .integer
  | .alloyUniverseRoot =>
      parserModuleHasObjectId snapshot declaration.childObjectId &&
        parserModuleHasObject snapshot declaration.parentObjectId .univ &&
        !(parserModuleHasObject snapshot declaration.childObjectId .univ)

def parserParentDeclarationsAreFunctional :
    List ParserParentDeclaration -> Bool
  | [] => true
  | declaration :: rest =>
      rest.all (fun other =>
        other.childObjectId != declaration.childObjectId ||
          other.parentObjectId == declaration.parentObjectId) &&
        parserParentDeclarationsAreFunctional rest

def parserParentDeclarationsAreModuleOwned
    (snapshot : ParserModuleSnapshot) : Bool :=
  snapshot.parentDeclarations.all fun declaration =>
    parserModuleHasObjectId snapshot declaration.childObjectId &&
      parserModuleHasObjectId snapshot declaration.parentObjectId &&
      parserParentProvenanceIsAuthorized snapshot declaration

def parserDirectParentObjectId? :
    List ParserParentDeclaration -> Nat -> Option Nat
  | [], _ => none
  | declaration :: rest, childObjectId =>
      if declaration.childObjectId == childObjectId then
        some declaration.parentObjectId
      else parserDirectParentObjectId? rest childObjectId

def parserParentChainIsAcyclicFrom
    (snapshot : ParserModuleSnapshot) : Nat -> List Nat -> Nat -> Bool
  | 0, _, _ => false
  | fuel + 1, seen, current =>
      if seen.contains current then false
      else
        match parserDirectParentObjectId?
            snapshot.parentDeclarations current with
        | none => true
        | some parent =>
            parserParentChainIsAcyclicFrom snapshot fuel
              (current :: seen) parent

def parserParentLedgerIsAcyclic
    (snapshot : ParserModuleSnapshot) : Bool :=
  snapshot.moduleObjects.all fun entry =>
    parserParentChainIsAcyclicFrom snapshot
      (snapshot.moduleObjects.length + 1) [] entry.1

def parserModuleSnapshotIsWellFormed
    (snapshot : ParserModuleSnapshot) : Bool :=
  parserModuleObjectIdsAreUnique snapshot &&
    parserParentDeclarationsAreFunctional snapshot.parentDeclarations &&
    parserParentDeclarationsAreModuleOwned snapshot &&
    parserParentLedgerIsAcyclic snapshot

def parserDeclaresDirectParent
    (snapshot : ParserModuleSnapshot)
    (childObjectId parentObjectId : Nat) : Bool :=
  snapshot.parentDeclarations.any fun declaration =>
    declaration.childObjectId == childObjectId &&
      declaration.parentObjectId == parentObjectId &&
      parserParentProvenanceIsAuthorized snapshot declaration

def parserDeclaresObjectPath
    (snapshot : ParserModuleSnapshot) : List Nat -> Bool
  | [] => false
  | [_] => true
  | childObjectId :: parentObjectId :: rest =>
      parserDeclaresDirectParent snapshot childObjectId parentObjectId &&
        parserDeclaresObjectPath snapshot (parentObjectId :: rest)

def parserAuthorizesPath
    (authority : ParserModuleAuthority)
    (pathObjectIds : List Nat)
    (nominalPath : List NominalSig) : Bool :=
  let snapshot := authority.snapshot
  parserModuleSnapshotIsWellFormed snapshot &&
    pathObjectIds.length == nominalPath.length &&
    (pathObjectIds.zip nominalPath).all snapshot.moduleObjects.contains &&
    parserDeclaresObjectPath snapshot pathObjectIds

inductive ParserAuthorityState where
  | live (authority : ParserModuleAuthority)
  | serialized (snapshot : ParserModuleSnapshot)

def serializedParserAuthority
    (authority : ParserModuleAuthority) : ParserAuthorityState :=
  .serialized authority.snapshot

def parserAuthorityStateAuthorizes
    (state : ParserAuthorityState)
    (pathObjectIds : List Nat)
    (nominalPath : List NominalSig) : Bool :=
  match state with
  | .live authority =>
      parserAuthorizesPath authority pathObjectIds nominalPath
  | .serialized _ => false

theorem parser_authority_requires_a_well_formed_snapshot
    (authority : ParserModuleAuthority)
    (pathObjectIds : List Nat)
    (nominalPath : List NominalSig)
    (authorized : parserAuthorizesPath authority pathObjectIds nominalPath = true) :
    parserModuleSnapshotIsWellFormed authority.snapshot = true := by
  simp [parserAuthorizesPath] at authorized
  exact authorized.1.1.1

theorem production_module_membership_authorizes_component_path :
    parserAuthorizesPath productionParserAuthority [2, 1]
      [.component, .product] = true := by
  decide

theorem transferred_position_without_module_membership_rejects :
    parserAuthorizesPath productionParserAuthority [9, 1]
      [.component, .product] = false := by
  decide

theorem module_membership_without_identity_label_correspondence_rejects :
    parserAuthorizesPath productionParserAuthority [1, 2]
      [.component, .product] = false := by
  decide

def duplicateObjectIdParserSnapshot : ParserModuleSnapshot :=
  { productionParserSnapshot with
    moduleObjects := [(1, .component), (1, .product), (4, .univ)] }

theorem duplicate_module_object_identity_rejects :
    parserModuleSnapshotIsWellFormed duplicateObjectIdParserSnapshot = false := by
  decide

def unpositionedParserSnapshot : ParserModuleSnapshot :=
  { productionParserSnapshot with
    parentDeclarations :=
      [{ childObjectId := 2, parentObjectId := 1,
          provenance := .source
            { sourceFile := .unknown, line := 0, column := 0 } }] }

theorem unpositioned_parent_declaration_rejects :
    parserModuleSnapshotIsWellFormed unpositionedParserSnapshot = false := by
  decide

def whitespacePositionParserSnapshot : ParserModuleSnapshot :=
  { productionParserSnapshot with
    parentDeclarations :=
      [{ childObjectId := 2, parentObjectId := 1,
          provenance := .source
            { sourceFile := .whitespace, line := 1, column := 1 } }] }

theorem whitespace_only_parent_position_rejects :
    parserModuleSnapshotIsWellFormed whitespacePositionParserSnapshot = false := by
  decide

def conflictingParentParserSnapshot : ParserModuleSnapshot :=
  { productionParserSnapshot with
    parentDeclarations :=
      [{ childObjectId := 2, parentObjectId := 1,
          provenance := .source
            { sourceFile := .known 1, line := 1, column := 1 } },
       { childObjectId := 2, parentObjectId := 4,
          provenance := .source
            { sourceFile := .known 1, line := 2, column := 1 } }] }

theorem conflicting_direct_parent_declarations_reject :
    parserModuleSnapshotIsWellFormed conflictingParentParserSnapshot = false := by
  decide

def cyclicParentParserSnapshot : ParserModuleSnapshot :=
  { moduleIdentity := 3
    moduleObjects := [(1, .product), (2, .component)]
    parentDeclarations :=
      [{ childObjectId := 2, parentObjectId := 1,
          provenance := .source
            { sourceFile := .known 3, line := 1, column := 1 } },
       { childObjectId := 1, parentObjectId := 2,
          provenance := .source
            { sourceFile := .known 3, line := 2, column := 1 } }] }

theorem cyclic_parent_declaration_ledger_rejects :
    parserModuleSnapshotIsWellFormed cyclicParentParserSnapshot = false := by
  decide

theorem serialization_strips_parser_authority
    (authority : ParserModuleAuthority)
    (pathObjectIds : List Nat)
    (nominalPath : List NominalSig) :
    parserAuthorityStateAuthorizes
      (serializedParserAuthority authority) pathObjectIds nominalPath = false := by
  rfl

theorem alloy_sequence_index_builtin_parent_is_authorized :
    parserAuthorizesPath productionParserAuthority [5, 6]
      [.sequenceIndex, .integer] = true := by
  decide

theorem alloy_universe_root_parent_is_authorized :
    parserAuthorizesPath productionParserAuthority [1, 4]
      [.product, .univ] = true := by
  decide

def mislabeledBuiltinParserSnapshot : ParserModuleSnapshot :=
  { productionParserSnapshot with
    moduleObjects :=
      [(1, .product), (2, .component), (3, .position), (4, .univ),
       (5, .component), (6, .integer)] }

theorem builtin_provenance_requires_exact_sequence_index_identity :
    parserModuleSnapshotIsWellFormed mislabeledBuiltinParserSnapshot = false := by
  decide

def productionParent : NominalSig -> Option NominalSig
  | .component => some .product
  | .sequenceIndex => some .integer
  | .integer => some .univ
  | .product => some .univ
  | .position => some .univ
  | .univ => none

inductive NominalSubtype
    (parent : Sig -> Option Sig) : Sig -> Sig -> Prop
  | refl (sig : Sig) : NominalSubtype parent sig sig
  | step {child directParent ancestor : Sig} :
      parent child = some directParent ->
      NominalSubtype parent directParent ancestor ->
      NominalSubtype parent child ancestor

def HierarchySound
    (parent : Sig -> Option Sig)
    (Carrier : Sig -> Atom -> Prop) : Prop :=
  forall child directParent atom,
    parent child = some directParent ->
    Carrier child atom -> Carrier directParent atom

theorem nominal_subtype_preserves_membership
    (parent : Sig -> Option Sig)
    (Carrier : Sig -> Atom -> Prop)
    (sound : HierarchySound parent Carrier)
    {child ancestor : Sig}
    (subtype : NominalSubtype parent child ancestor)
    {atom : Atom}
    (member : Carrier child atom) : Carrier ancestor atom := by
  induction subtype with
  | refl _ => exact member
  | @step child directParent ancestor edge rest inductionHypothesis =>
      exact inductionHypothesis (sound child directParent atom edge member)

def ValidParentPath (parent : Sig -> Option Sig) : List Sig -> Prop
  | [] => False
  | [_] => True
  | child :: directParent :: rest =>
      parent child = some directParent /\
        ValidParentPath parent (directParent :: rest)

theorem component_parent_path_is_valid :
    ValidParentPath productionParent
      [.component, .product, .univ] := by
  simp [ValidParentPath, productionParent]

theorem component_is_subtype_of_product :
    NominalSubtype productionParent .component .product := by
  apply NominalSubtype.step (directParent := NominalSig.product)
  · rfl
  · exact NominalSubtype.refl NominalSig.product

inductive BoundaryCorrespondence
    (parent : Sig -> Option Sig) : Sig -> Sig -> Prop
  | exact (sig : Sig) : BoundaryCorrespondence parent sig sig
  | leftSubtype {left right : Sig} :
      NominalSubtype parent left right ->
      BoundaryCorrespondence parent left right
  | rightSubtype {left right : Sig} :
      NominalSubtype parent right left ->
      BoundaryCorrespondence parent left right

def BoundaryOverlap
    (Carrier : Sig -> Atom -> Prop) (left right : Sig) : Prop :=
  (forall atom, Carrier left atom -> Carrier right atom) \/
  (forall atom, Carrier right atom -> Carrier left atom)

theorem certified_boundary_has_semantic_overlap
    (parent : Sig -> Option Sig)
    (Carrier : Sig -> Atom -> Prop)
    (sound : HierarchySound parent Carrier)
    {left right : Sig}
    (certificate : BoundaryCorrespondence parent left right) :
    BoundaryOverlap Carrier left right := by
  cases certificate with
  | exact =>
      exact Or.inl (fun _ member => member)
  | leftSubtype subtype =>
      exact Or.inl (fun _ member =>
        nominal_subtype_preserves_membership parent Carrier sound subtype member)
  | rightSubtype subtype =>
      exact Or.inr (fun _ member =>
        nominal_subtype_preserves_membership parent Carrier sound subtype member)

theorem productComponentBoundary :
    BoundaryCorrespondence productionParent .product .component :=
  BoundaryCorrespondence.rightSubtype component_is_subtype_of_product

inductive BoundaryRule where
  | exact
  | leftSubtype
  | rightSubtype
  deriving DecidableEq, BEq

structure BoundaryWireIndex where
  rule : BoundaryRule
  left : NominalSig
  right : NominalSig
  directParentPath : List NominalSig
  deriving DecidableEq

/- The standalone wire records nominal paths, but only the live producer can
   bind those paths to parser-owned object identities and positioned parent
   declarations.  This structure is deliberately not the serialized wire. -/

structure ProducerBoundaryEvidence where
  wire : BoundaryWireIndex
  authority : ParserModuleAuthority
  pathObjectIds : List Nat

theorem equal_boundary_wire_indices_bind_all_fields
    (left right : BoundaryWireIndex) (same : left = right) :
    left.rule = right.rule /\
    left.left = right.left /\
    left.right = right.right /\
    left.directParentPath = right.directParentPath := by
  subst right
  simp

def validProductionParentPath : List NominalSig -> Bool
  | [] => false
  | [_] => true
  | child :: directParent :: rest =>
      productionParent child == some directParent &&
        validProductionParentPath (directParent :: rest)

def pathLast? : List NominalSig -> Option NominalSig
  | [] => none
  | [last] => some last
  | _ :: rest => pathLast? rest

def pathStartsAndEnds
    (path : List NominalSig) (start finish : NominalSig) : Bool :=
  path.head? == some start && pathLast? path == some finish

def nominalChainTypingEligible (columns : List NominalSig) : Bool :=
  !columns.isEmpty

def validBoundaryWire (certificate : BoundaryWireIndex) : Bool :=
  match certificate.rule with
  | .exact =>
      certificate.left == certificate.right &&
        certificate.directParentPath == [certificate.left]
  | .leftSubtype =>
      certificate.left != certificate.right &&
        pathStartsAndEnds certificate.directParentPath
          certificate.left certificate.right &&
        validProductionParentPath certificate.directParentPath
  | .rightSubtype =>
      certificate.left != certificate.right &&
        pathStartsAndEnds certificate.directParentPath
          certificate.right certificate.left &&
        validProductionParentPath certificate.directParentPath

def producerBoundaryAuthorityValid
    (evidence : ProducerBoundaryEvidence) : Bool :=
  match evidence.wire.rule with
  | .exact => true
  | .leftSubtype | .rightSubtype =>
      parserAuthorizesPath evidence.authority evidence.pathObjectIds
        evidence.wire.directParentPath &&
        evidence.pathObjectIds.length == evidence.wire.directParentPath.length

def validProducerBoundary (evidence : ProducerBoundaryEvidence) : Bool :=
  validBoundaryWire evidence.wire && producerBoundaryAuthorityValid evidence

theorem valid_parent_path_yields_subtype
    (path : List NominalSig)
    (valid : validProductionParentPath path = true)
    (start finish : NominalSig)
    (starts : path.head? = some start)
    (ends : pathLast? path = some finish) :
    NominalSubtype productionParent start finish := by
  induction path generalizing start finish with
  | nil => simp [validProductionParentPath] at valid
  | cons first rest inductionHypothesis =>
      cases rest with
      | nil =>
          simp at starts
          simp [pathLast?] at ends
          subst start
          subst finish
          exact NominalSubtype.refl first
      | cons parent tail =>
          simp [validProductionParentPath] at valid
          simp at starts
          subst start
          have tailEnds : pathLast? (parent :: tail) = some finish := by
            simpa [pathLast?] using ends
          exact NominalSubtype.step valid.1
            (inductionHypothesis valid.2 parent finish rfl tailEnds)

theorem valid_boundary_wire_yields_correspondence
    (certificate : BoundaryWireIndex)
    (valid : validBoundaryWire certificate = true) :
    BoundaryCorrespondence productionParent
      certificate.left certificate.right := by
  cases certificate with
  | mk rule left right path =>
      cases rule with
      | exact =>
          simp [validBoundaryWire] at valid
          rw [valid.1]
          exact BoundaryCorrespondence.exact right
      | leftSubtype =>
          simp [validBoundaryWire, pathStartsAndEnds] at valid
          exact BoundaryCorrespondence.leftSubtype
            (valid_parent_path_yields_subtype path valid.2
              left right valid.1.2.1 valid.1.2.2)
      | rightSubtype =>
          simp [validBoundaryWire, pathStartsAndEnds] at valid
          exact BoundaryCorrespondence.rightSubtype
            (valid_parent_path_yields_subtype path valid.2
              right left valid.1.2.1 valid.1.2.2)

def structuralSubtypeJoinTypeStep
    (left right : List NominalSig)
    (certificate : BoundaryWireIndex) : Option (List NominalSig) :=
  match splitLast left, right with
  | some (pre, leftBoundary), rightBoundary :: suffix =>
      if nominalChainTypingEligible left &&
          nominalChainTypingEligible right &&
          leftBoundary == certificate.left &&
          rightBoundary == certificate.right &&
          validBoundaryWire certificate
      then
        let result := pre ++ suffix
        if result.isEmpty then none else some result
      else none
  | _, _ => none

def subtypeJoinTypeStep
    (left right : List NominalSig)
    (evidence : ProducerBoundaryEvidence) : Option (List NominalSig) :=
  if validProducerBoundary evidence then
    structuralSubtypeJoinTypeStep left right evidence.wire
  else
    none

def productComponentWire : BoundaryWireIndex :=
  { rule := .rightSubtype
    left := .product
    right := .component
    directParentPath := [.component, .product] }

def exactProductBoundaryWire : BoundaryWireIndex :=
  { rule := .exact
    left := .product
    right := .product
    directParentPath := [.product] }

def productComponentEvidence : ProducerBoundaryEvidence :=
  { wire := productComponentWire
    authority := productionParserAuthority
    pathObjectIds := [2, 1] }

def componentProductWire : BoundaryWireIndex :=
  { rule := .leftSubtype
    left := .component
    right := .product
    directParentPath := [.component, .product] }

def componentProductEvidence : ProducerBoundaryEvidence :=
  { wire := componentProductWire
    authority := productionParserAuthority
    pathObjectIds := [2, 1] }

def foreignProductComponentEvidence : ProducerBoundaryEvidence :=
  { wire := productComponentWire
    authority := foreignParserAuthority
    pathObjectIds := [12, 11] }

theorem product_component_wire_is_valid :
    validBoundaryWire productComponentWire = true := by
  decide

theorem product_component_producer_evidence_is_valid :
    validProducerBoundary productComponentEvidence = true := by
  decide

theorem transferred_attribute_has_no_producer_boundary_authority :
    validProducerBoundary
      { productComponentEvidence with pathObjectIds := [9, 1] } = false := by
  decide

theorem serialization_removes_producer_boundary_authority :
    parserAuthorityStateAuthorizes
      (serializedParserAuthority productComponentEvidence.authority)
      productComponentEvidence.pathObjectIds
      productComponentEvidence.wire.directParentPath = false := by
  rfl

theorem missing_position_has_no_producer_boundary_authority :
    parserModuleSnapshotIsWellFormed unpositionedParserSnapshot = false := by
  decide

theorem product_component_wire_corresponds_to_subtype_proof :
    BoundaryCorrespondence productionParent
      productComponentWire.left productComponentWire.right := by
  exact valid_boundary_wire_yields_correspondence productComponentWire
    product_component_wire_is_valid

theorem product_component_join_has_exact_dependent_result :
    subtypeJoinTypeStep
      [.product] [.component, .position] productComponentEvidence =
        some [.position] := by
  decide

theorem nullary_join_result_is_not_in_the_certified_relation_slice :
    subtypeJoinTypeStep
      [.product] [.product]
      { wire := exactProductBoundaryWire
        authority := productionParserAuthority
        pathObjectIds := [] } = none := by
  decide

theorem sibling_boundary_has_no_subtype_certificate :
    subtypeJoinTypeStep
      [.product] [.position, .component]
      { wire :=
          { rule := .rightSubtype
            left := .product
            right := .position
            directParentPath := [.position, .component] }
        authority := productionParserAuthority
        pathObjectIds := [3, 2] } = none := by
  decide

theorem reversed_subtype_rule_rejects :
    subtypeJoinTypeStep
      [.product] [.component, .position]
      { wire :=
          { rule := .leftSubtype
            left := .product
            right := .component
            directParentPath := [.component, .product] }
        authority := productionParserAuthority
        pathObjectIds := [2, 1] } = none := by
  decide

theorem missing_subtype_endpoint_rejects :
    subtypeJoinTypeStep
      [.product] [.component, .position]
      { wire :=
          { rule := .rightSubtype
            left := .product
            right := .component
            directParentPath := [.component] }
        authority := productionParserAuthority
        pathObjectIds := [2] } = none := by
  decide

theorem unrelated_valid_path_rejects :
    subtypeJoinTypeStep
      [.product] [.component, .position]
      { wire :=
          { rule := .rightSubtype
            left := .product
            right := .component
            directParentPath := [.position, .univ] }
        authority := productionParserAuthority
        pathObjectIds := [3, 4] } = none := by
  decide

theorem univ_endpoint_uses_authenticated_subtype_path :
    subtypeJoinTypeStep
      [.univ] [.component, .position]
      { wire :=
          { rule := .rightSubtype
            left := .univ
            right := .component
            directParentPath := [.component, .product, .univ] }
        authority := productionParserAuthority
        pathObjectIds := [2, 1, 4] } = some [.position] := by
  decide

theorem explicit_univ_exact_wire_is_valid :
    validBoundaryWire
      { rule := .exact
        left := .univ
        right := .univ
        directParentPath := [.univ] } = true := by
  decide

def subtypeJoinSeqStep
    (left right : List NominalSig)
    (certificate : ProducerBoundaryEvidence) :
    List (List NominalSig) × Option (List NominalSig) :=
  (joinOperandSeq [left, right], subtypeJoinTypeStep left right certificate)

theorem product_component_join_retains_ordered_seq_and_exact_result :
    subtypeJoinSeqStep
      [.product] [.component, .position] productComponentEvidence =
      ([[.product], [.component, .position]], some [.position]) := by
  decide

inductive ChainKind where
  | join
  | arrow
  deriving DecidableEq

structure ChainIndex where
  kind : ChainKind
  operands : List (List NominalSig)
  operandAuthorities : List (List (Option ParserModuleAuthority))
  boundaryEvidence : List ProducerBoundaryEvidence
  result : List NominalSig

theorem exact_index_retains_kind
    (left right : ChainIndex) (h : left = right) : left.kind = right.kind := by
  exact congrArg ChainIndex.kind h

theorem exact_index_retains_operands
    (left right : ChainIndex) (h : left = right) :
    left.operands = right.operands := by
  exact congrArg ChainIndex.operands h

theorem exact_index_retains_operand_authorities
    (left right : ChainIndex) (h : left = right) :
    left.operandAuthorities = right.operandAuthorities := by
  exact congrArg ChainIndex.operandAuthorities h

theorem exact_index_retains_result
    (left right : ChainIndex) (h : left = right) : left.result = right.result := by
  exact congrArg ChainIndex.result h

theorem exact_index_retains_boundary_evidence
    (left right : ChainIndex) (h : left = right) :
    left.boundaryEvidence = right.boundaryEvidence := by
  exact congrArg ChainIndex.boundaryEvidence h

def joinTypeFoldWithEvidence :
    List NominalSig ->
    List (List NominalSig) ->
    List ProducerBoundaryEvidence ->
    Option (List NominalSig)
  | current, [], [] => some current
  | current, right :: rest, boundary :: boundaries =>
      match subtypeJoinTypeStep current right boundary with
      | some result => joinTypeFoldWithEvidence result rest boundaries
      | none => none
  | _, _, _ => none

def operandAuthorityShapeMatches
    (operands : List (List NominalSig))
    (authorities : List (List (Option ParserModuleAuthority))) : Bool :=
  operands.length == authorities.length &&
    (operands.zip authorities).all fun pair =>
      pair.1.length == pair.2.length

def operandAuthoritiesAreComplete
    (operands : List (List NominalSig))
    (authorities : List (List (Option ParserModuleAuthority))) : Bool :=
  operandAuthorityShapeMatches operands authorities &&
    authorities.all fun operand => operand.all Option.isSome

def producerAuthorityModuleIds
    (operandAuthorities : List (List (Option ParserModuleAuthority)))
    (boundaries : List ProducerBoundaryEvidence) : List Nat :=
  let operandIds := operandAuthorities.flatMap fun operand =>
    operand.filterMap fun authority =>
      authority.map fun live => live.snapshot.moduleIdentity
  operandIds ++ boundaries.map fun evidence =>
    evidence.authority.snapshot.moduleIdentity

def producerEvidenceSharesAuthority
    (operandAuthorities : List (List (Option ParserModuleAuthority)))
    (boundaries : List ProducerBoundaryEvidence) : Bool :=
  match producerAuthorityModuleIds operandAuthorities boundaries with
  | [] => true
  | first :: rest => rest.all fun identity => identity == first

/- Correlated products consume parser authority column by column.  A live
module capability alone is insufficient: every exact column is paired with
the object path and nominal path independently checked by parserAuthorizesPath.
ARROW and JOIN below operate on those paired products, so the Cartesian family
semantics and parser authority are one executable relation rather than two
unconnected models. -/

structure CorrelatedColumnProof where
  authority : ParserModuleAuthority
  objectPath : List Nat
  nominalPath : List NominalSig

def correlatedColumnProofIsValid
    (column : NominalSig) (proof : CorrelatedColumnProof) : Bool :=
  proof.nominalPath.head? == some column &&
    parserAuthorizesPath proof.authority proof.objectPath proof.nominalPath

structure CorrelatedAuthorityDag where
  arity : Nat
  alternatives : List (List NominalSig)
  alternativeProofs : List (List CorrelatedColumnProof)

def correlatedAuthorityShapeMatches
    (dag : CorrelatedAuthorityDag) : Bool :=
  dag.arity > 0 &&
    dag.alternatives.length == dag.alternativeProofs.length &&
    (dag.alternatives.zip dag.alternativeProofs).all fun pair =>
      pair.1.length == dag.arity && pair.2.length == dag.arity &&
        (pair.1.zip pair.2).all fun column =>
          correlatedColumnProofIsValid column.1 column.2

def correlatedAuthorityModuleIds
    (proofs : List (List CorrelatedColumnProof)) : List Nat :=
  proofs.flatMap fun product =>
    product.map fun proof => proof.authority.snapshot.moduleIdentity

def correlatedProofsShareAuthority
    (proofs : List (List CorrelatedColumnProof)) : Bool :=
  match correlatedAuthorityModuleIds proofs with
  | [] => true
  | first :: rest => rest.all fun identity => identity == first

def correlatedArrowAlternatives
    (left right : CorrelatedAuthorityDag) : List (List NominalSig) :=
  left.alternatives.flatMap fun leftProduct =>
    right.alternatives.map fun rightProduct => leftProduct ++ rightProduct

def correlatedArrowProofs
    (left right : CorrelatedAuthorityDag) :
    List (List CorrelatedColumnProof) :=
  left.alternativeProofs.flatMap fun leftProduct =>
    right.alternativeProofs.map fun rightProduct =>
      leftProduct ++ rightProduct

def correlatedArrowWithAuthority
    (left right : CorrelatedAuthorityDag) : Option CorrelatedAuthorityDag :=
  let inputProofs := left.alternativeProofs ++ right.alternativeProofs
  if correlatedAuthorityShapeMatches left &&
      correlatedAuthorityShapeMatches right &&
      correlatedProofsShareAuthority inputProofs then
    some
      { arity := left.arity + right.arity
        alternatives := correlatedArrowAlternatives left right
        alternativeProofs := correlatedArrowProofs left right }
  else
    none

def productionColumnProof : NominalSig -> CorrelatedColumnProof
  | .product =>
      { authority := productionParserAuthority
        objectPath := [1, 4]
        nominalPath := [.product, .univ] }
  | .component =>
      { authority := productionParserAuthority
        objectPath := [2, 1, 4]
        nominalPath := [.component, .product, .univ] }
  | .position =>
      { authority := productionParserAuthority
        objectPath := [3, 4]
        nominalPath := [.position, .univ] }
  | .univ =>
      { authority := productionParserAuthority
        objectPath := [4]
        nominalPath := [.univ] }
  | .integer =>
      { authority := productionParserAuthority
        objectPath := [6, 4]
        nominalPath := [.integer, .univ] }
  | .sequenceIndex =>
      { authority := productionParserAuthority
        objectPath := [5, 6, 4]
        nominalPath := [.sequenceIndex, .integer, .univ] }

def parserColumnProofs
    (products : List (List NominalSig)) :
    List (List CorrelatedColumnProof) :=
  products.map fun product => product.map productionColumnProof

def correlatedArrowLeft : CorrelatedAuthorityDag :=
  { arity := 1
    alternatives := [[.product], [.component]]
    alternativeProofs :=
      parserColumnProofs [[.product], [.component]] }

def correlatedArrowRight : CorrelatedAuthorityDag :=
  { arity := 1
    alternatives := [[.position], [.univ]]
    alternativeProofs :=
      parserColumnProofs [[.position], [.univ]] }

theorem correlated_arrow_enumerates_complete_authorized_matrix :
    (correlatedArrowWithAuthority
        correlatedArrowLeft correlatedArrowRight).map
          CorrelatedAuthorityDag.alternatives =
      some
        [[.product, .position], [.product, .univ],
         [.component, .position], [.component, .univ]] := by
  decide

theorem correlated_arrow_matrix_has_cartesian_size :
    (correlatedArrowAlternatives
        correlatedArrowLeft correlatedArrowRight).length =
      correlatedArrowLeft.alternatives.length *
      correlatedArrowRight.alternatives.length := by
  decide

theorem correlated_arrow_output_retains_bound_paths :
    (correlatedArrowWithAuthority
        correlatedArrowLeft correlatedArrowRight).map
          correlatedAuthorityShapeMatches = some true := by
  decide

def foreignCorrelatedArrowRight : CorrelatedAuthorityDag :=
  { arity := 1
    alternatives := [[.position]]
    alternativeProofs :=
      [[{ authority := foreignParserAuthority
          objectPath := [13, 14]
          nominalPath := [.position, .univ] }]] }

theorem correlated_arrow_rejects_mixed_parser_authority :
    correlatedArrowWithAuthority
        correlatedArrowLeft foreignCorrelatedArrowRight = none := by
  rfl

def correlatedColumnOccurrenceMatches
    (left right : CorrelatedColumnProof) : Bool :=
  left.nominalPath == right.nominalPath &&
    left.authority.snapshot.moduleIdentity ==
      right.authority.snapshot.moduleIdentity

def correlatedDagOccurrenceMatches
    (left right : CorrelatedAuthorityDag) : Bool :=
  left.arity == right.arity &&
    left.alternatives == right.alternatives &&
    left.alternativeProofs.length == right.alternativeProofs.length &&
    (left.alternativeProofs.zip right.alternativeProofs).all fun products =>
      products.1.length == products.2.length &&
        (products.1.zip products.2).all fun columns =>
          correlatedColumnOccurrenceMatches columns.1 columns.2

def productionProductOccurrenceDag : CorrelatedAuthorityDag :=
  { arity := 1
    alternatives := [[.product]]
    alternativeProofs := [[productionColumnProof .product]] }

def foreignSameProductOccurrenceDag : CorrelatedAuthorityDag :=
  { arity := 1
    alternatives := [[.product]]
    alternativeProofs :=
      [[{ authority := foreignParserAuthority
          objectPath := [11, 14]
          nominalPath := [.product, .univ] }]] }

theorem same_module_dependent_dag_occurrence_accepts :
    correlatedDagOccurrenceMatches
      productionProductOccurrenceDag productionProductOccurrenceDag = true := by
  decide

theorem equal_looking_foreign_module_dependent_dag_occurrence_rejects :
    correlatedDagOccurrenceMatches
      productionProductOccurrenceDag foreignSameProductOccurrenceDag = false := by
  decide

def forgedUnivCorrelatedRight : CorrelatedAuthorityDag :=
  { arity := 1
    alternatives := [[.univ]]
    alternativeProofs := [[productionColumnProof .product]] }

theorem correlated_arrow_rejects_unbound_column_identity :
    correlatedArrowWithAuthority
        correlatedArrowLeft forgedUnivCorrelatedRight = none := by
  rfl

def firstCommonNominal
    (left right : List NominalSig) : Option NominalSig :=
  left.find? fun candidate => right.contains candidate

def correlatedJoinPair
    (leftProduct rightProduct : List NominalSig)
    (leftProofs rightProofs : List CorrelatedColumnProof) :
    Option (Option (List NominalSig × List CorrelatedColumnProof)) :=
  match splitLast leftProduct, rightProduct,
      splitLast leftProofs, rightProofs with
  | some (leftPrefix, leftBoundary), rightBoundary :: rightSuffix,
      some (leftProofPrefix, leftBoundaryProof),
      rightBoundaryProof :: rightProofSuffix =>
      if correlatedColumnProofIsValid leftBoundary leftBoundaryProof &&
          correlatedColumnProofIsValid rightBoundary rightBoundaryProof then
        if leftBoundary == rightBoundary ||
            leftBoundaryProof.nominalPath.contains rightBoundary ||
            rightBoundaryProof.nominalPath.contains leftBoundary then
          some (some
            (leftPrefix ++ rightSuffix,
             leftProofPrefix ++ rightProofSuffix))
        else if firstCommonNominal
            leftBoundaryProof.nominalPath rightBoundaryProof.nominalPath ==
              some .univ then
          some none
        else
          none
      else
        none
  | _, _, _, _ => none

def correlatedJoinMatrix
    (left right : CorrelatedAuthorityDag) :
    List (Option (Option (List NominalSig × List CorrelatedColumnProof))) :=
  (left.alternatives.zip left.alternativeProofs).flatMap fun leftPair =>
    (right.alternatives.zip right.alternativeProofs).map fun rightPair =>
      correlatedJoinPair leftPair.1 rightPair.1 leftPair.2 rightPair.2

def retainedCorrelatedJoinProducts :
    List (Option (Option (List NominalSig × List CorrelatedColumnProof))) ->
    List (List NominalSig × List CorrelatedColumnProof)
  | [] => []
  | some (some product) :: rest =>
      product :: retainedCorrelatedJoinProducts rest
  | _ :: rest => retainedCorrelatedJoinProducts rest

def correlatedJoinWithAuthority
    (left right : CorrelatedAuthorityDag) : Option CorrelatedAuthorityDag :=
  let proofs := left.alternativeProofs ++ right.alternativeProofs
  let matrix := correlatedJoinMatrix left right
  let retained := retainedCorrelatedJoinProducts matrix
  if correlatedAuthorityShapeMatches left &&
      correlatedAuthorityShapeMatches right &&
      correlatedProofsShareAuthority proofs &&
      matrix.all Option.isSome &&
      2 < left.arity + right.arity then
    some
      { arity := left.arity + right.arity - 2
        alternatives := retained.map Prod.fst
        alternativeProofs := retained.map Prod.snd }
  else
    none

def correlatedJoinLeft : CorrelatedAuthorityDag :=
  { arity := 2
    alternatives := [[.product, .product], [.position, .position]]
    alternativeProofs := parserColumnProofs
      [[.product, .product], [.position, .position]] }

def correlatedJoinRight : CorrelatedAuthorityDag :=
  { arity := 2
    alternatives := [[.component, .component], [.product, .product]]
    alternativeProofs := parserColumnProofs
      [[.component, .component], [.product, .product]] }

theorem correlated_join_enumerates_complete_authorized_matrix :
    (correlatedJoinMatrix correlatedJoinLeft correlatedJoinRight).length = 4 := by
  decide

theorem correlated_join_retains_only_authorized_overlaps :
    (correlatedJoinWithAuthority
        correlatedJoinLeft correlatedJoinRight).map
          CorrelatedAuthorityDag.alternatives =
      some [[.product, .component], [.product, .product]] := by
  decide

theorem correlated_join_output_retains_bound_paths :
    (correlatedJoinWithAuthority
        correlatedJoinLeft correlatedJoinRight).map
          correlatedAuthorityShapeMatches = some true := by
  decide

def correlatedDisjointRight : CorrelatedAuthorityDag :=
  { arity := 2
    alternatives := [[.position, .position]]
    alternativeProofs := parserColumnProofs [[.position, .position]] }

theorem correlated_all_disjoint_join_retains_typed_empty_arity :
    (correlatedJoinWithAuthority
        { arity := 2
          alternatives := [[.product, .product]]
          alternativeProofs := parserColumnProofs [[.product, .product]] }
        correlatedDisjointRight).map (fun dag => (dag.arity, dag.alternatives)) =
      some (2, []) := by
  decide

def dependentTypeFold
    (kind : ChainKind)
    (operands : List (List NominalSig))
    (operandAuthorities : List (List (Option ParserModuleAuthority)))
    (boundaries : List ProducerBoundaryEvidence) : Option (List NominalSig) :=
  match kind, operands, boundaries with
  | .arrow, first :: second :: rest, [] =>
      if operandAuthoritiesAreComplete (first :: second :: rest)
            operandAuthorities &&
          producerEvidenceSharesAuthority operandAuthorities [] &&
          (first :: second :: rest).all fun columns =>
            !columns.isEmpty && nominalChainTypingEligible columns
      then some ((second :: rest).foldl (· ++ ·) first)
      else none
  | .arrow, _, _ => none
  | .join, first :: second :: rest, evidence =>
      if operandAuthoritiesAreComplete (first :: second :: rest)
            operandAuthorities &&
          joinFlatGuard (first :: second :: rest) &&
          producerEvidenceSharesAuthority operandAuthorities evidence then
        joinTypeFoldWithEvidence first (second :: rest) evidence
      else none
  | .join, _, _ => none

def checkDependentFold (index : ChainIndex) : Bool :=
  match dependentTypeFold index.kind index.operands index.operandAuthorities
      index.boundaryEvidence with
  | some derived => derived == index.result
  | none => false

def ValidDependentFold (index : ChainIndex) : Prop :=
  checkDependentFold index = true

theorem valid_dependent_fold_rechecks_every_step_and_exact_result
    (index : ChainIndex) (valid : ValidDependentFold index) :
    dependentTypeFold index.kind index.operands index.operandAuthorities
        index.boundaryEvidence =
      some index.result := by
  unfold ValidDependentFold at valid
  cases folded : dependentTypeFold index.kind index.operands
      index.operandAuthorities index.boundaryEvidence with
  | none => simp [checkDependentFold, folded] at valid
  | some derived =>
      have same : derived = index.result := by
        simpa [checkDependentFold, folded] using valid
      exact congrArg some same

theorem dependent_fold_result_is_unique
    (kind : ChainKind)
    (operands : List (List NominalSig))
    (operandAuthorities : List (List (Option ParserModuleAuthority)))
    (boundaries : List ProducerBoundaryEvidence)
    (leftResult rightResult : List NominalSig)
    (left : dependentTypeFold kind operands operandAuthorities boundaries =
      some leftResult)
    (right : dependentTypeFold kind operands operandAuthorities boundaries =
      some rightResult) :
    leftResult = rightResult := by
  rw [left] at right
  exact Option.some.inj right

def productComponentIndex : ChainIndex :=
  { kind := .join
    operands := [[.product], [.component, .position]]
    operandAuthorities :=
      [[some productionParserAuthority],
       [some productionParserAuthority, some productionParserAuthority]]
    boundaryEvidence := [productComponentEvidence]
    result := [.position] }

theorem product_component_index_is_a_valid_evidence_consuming_fold :
    ValidDependentFold productComponentIndex := by
  unfold ValidDependentFold
  decide

theorem unary_join_has_no_dependent_fold :
    dependentTypeFold .join [[.product]]
      [[some productionParserAuthority]] [] = none := by
  rfl

theorem unary_arrow_has_no_dependent_fold :
    dependentTypeFold .arrow [[.product]]
      [[some productionParserAuthority]] [] = none := by
  rfl

theorem absent_column_authority_has_no_dependent_fold :
    dependentTypeFold .arrow
      [[.product], [.component]] [[none], [none]] [] = none := by
  decide

theorem mixed_bound_and_unbound_authority_has_no_dependent_fold :
    dependentTypeFold .arrow
      [[.product], [.component]]
      [[some productionParserAuthority], [none]] [] = none := by
  decide

theorem unary_interior_join_has_no_dependent_fold :
    dependentTypeFold .join
      [[.product, .component], [.product], [.component, .position]]
      [[some productionParserAuthority, some productionParserAuthority],
       [some productionParserAuthority],
       [some productionParserAuthority, some productionParserAuthority]]
      [componentProductEvidence, productComponentEvidence] = none := by
  decide

theorem serialized_boundary_has_no_dependent_fold :
    parserAuthorityStateAuthorizes
      (serializedParserAuthority productComponentEvidence.authority)
      productComponentEvidence.pathObjectIds
      productComponentEvidence.wire.directParentPath = false := by
  rfl

theorem mixed_module_authorities_have_no_dependent_fold :
    dependentTypeFold .join
      [[.product, .product], [.component, .product],
        [.component, .position]]
      [[some productionParserAuthority, some productionParserAuthority],
       [some productionParserAuthority, some productionParserAuthority],
       [some productionParserAuthority, some productionParserAuthority]]
      [productComponentEvidence, foreignProductComponentEvidence] = none := by
  decide

theorem foreign_boundary_cannot_relabel_production_operands :
    checkDependentFold
      { productComponentIndex with
        boundaryEvidence := [foreignProductComponentEvidence] } = false := by
  decide

theorem arrow_rejects_mixed_original_operand_authorities :
    dependentTypeFold .arrow
      [[.product], [.component]]
      [[some productionParserAuthority], [some foreignParserAuthority]] [] =
      none := by
  decide

structure CompleteChainIndex where
  kind : ChainKind
  profile : String
  sourceAssociation : String
  operandTypes : List (List NominalSig)
  boundaryEvidence : List BoundaryWireIndex
  result : List NominalSig
  target : String
  theoryVersion : String
  theoryDigest : String
  deriving DecidableEq

def structuralJoinTypeFoldWithEvidence :
    List NominalSig ->
    List (List NominalSig) ->
    List BoundaryWireIndex ->
    Option (List NominalSig)
  | current, [], [] => some current
  | current, right :: rest, boundary :: boundaries =>
      match structuralSubtypeJoinTypeStep current right boundary with
      | some result => structuralJoinTypeFoldWithEvidence result rest boundaries
      | none => none
  | _, _, _ => none

def structuralDependentTypeFold
    (kind : ChainKind)
    (operands : List (List NominalSig))
    (boundaries : List BoundaryWireIndex) : Option (List NominalSig) :=
  match kind, operands, boundaries with
  | .arrow, first :: second :: rest, [] =>
      if (first :: second :: rest).all fun columns =>
          !columns.isEmpty && nominalChainTypingEligible columns
      then some ((second :: rest).foldl (· ++ ·) first)
      else none
  | .arrow, _, _ => none
  | .join, first :: second :: rest, evidence =>
      if joinFlatGuard (first :: second :: rest) then
        structuralJoinTypeFoldWithEvidence first (second :: rest) evidence
      else none
  | .join, _, _ => none

def checkCompleteChainStructure (index : CompleteChainIndex) : Bool :=
  match structuralDependentTypeFold index.kind index.operandTypes
      index.boundaryEvidence with
  | some derived => derived == index.result
  | none => false

def fixedDependentChainTheoryVersion : String :=
  "alloy-dependent-chain-theory-v11"

def fixedDependentChainTheoryDigest : String :=
  "3387749f582a53216caa599105386b710e9e5e748110c59e1b3bf3401ac03cf8"

def checkCompleteChainEvidence (index : CompleteChainIndex) : Bool :=
  checkCompleteChainStructure index &&
    index.theoryVersion == fixedDependentChainTheoryVersion &&
    index.theoryDigest == fixedDependentChainTheoryDigest

theorem equal_complete_chain_indices_bind_every_field
    (left right : CompleteChainIndex) (same : left = right) :
    left.kind = right.kind /\
    left.profile = right.profile /\
    left.sourceAssociation = right.sourceAssociation /\
    left.operandTypes = right.operandTypes /\
    left.boundaryEvidence = right.boundaryEvidence /\
    left.result = right.result /\
    left.target = right.target /\
    left.theoryVersion = right.theoryVersion /\
    left.theoryDigest = right.theoryDigest := by
  subst right
  simp

theorem complete_chain_index_fields_are_injective
    (left right : CompleteChainIndex)
    (kind : left.kind = right.kind)
    (profile : left.profile = right.profile)
    (source : left.sourceAssociation = right.sourceAssociation)
    (operands : left.operandTypes = right.operandTypes)
    (boundaries : left.boundaryEvidence = right.boundaryEvidence)
    (result : left.result = right.result)
    (target : left.target = right.target)
    (version : left.theoryVersion = right.theoryVersion)
    (digest : left.theoryDigest = right.theoryDigest) :
    left = right := by
  cases left
  cases right
  simp_all

structure SourcePlan where
  lineage : Nat
  certificate : Nat
  deriving DecidableEq

def UniqueLineages (plans : List SourcePlan) : Prop :=
  forall p, p ∈ plans -> forall q, q ∈ plans -> p.lineage = q.lineage -> p = q

theorem lineage_transfer_is_functional
    (plans : List SourcePlan)
    (hUnique : UniqueLineages plans)
    (p q : SourcePlan)
    (hp : p ∈ plans)
    (hq : q ∈ plans)
    (same : p.lineage = q.lineage) :
    p.certificate = q.certificate := by
  exact congrArg SourcePlan.certificate (hUnique p hp q hq same)

def ReplayInjective {Root Certificate : Type}
    (assignment : Root -> Certificate) : Prop :=
  Function.Injective assignment

theorem one_certificate_cannot_replay_over_two_roots
    {Root Certificate : Type}
    (assignment : Root -> Certificate)
    (injective : ReplayInjective assignment)
    (left right : Root)
    (different : Not (left = right)) :
    Not (assignment left = assignment right) := by
  intro same
  exact different (injective same)

structure SourceCommitment where
  path : String
  typedSource : String
  content : String
  deriving DecidableEq

structure OccurrenceCertificate where
  source : SourceCommitment
  proofId : Nat
  deriving DecidableEq

structure OccurrenceBinding where
  lineage : Nat
  source : SourceCommitment
  certificate : OccurrenceCertificate
  deriving DecidableEq

def BindingAccepts
    (currentLineage : Nat)
    (currentSource : SourceCommitment)
    (binding : OccurrenceBinding) : Prop :=
  And (currentLineage = binding.lineage)
    (And (currentSource = binding.source)
      (binding.certificate.source = binding.source))

theorem accepted_binding_has_exact_lineage
    (currentLineage : Nat)
    (currentSource : SourceCommitment)
    (binding : OccurrenceBinding)
    (accepted : BindingAccepts currentLineage currentSource binding) :
    currentLineage = binding.lineage := accepted.1

theorem accepted_binding_has_exact_path_and_content
    (currentLineage : Nat)
    (currentSource : SourceCommitment)
    (binding : OccurrenceBinding)
    (accepted : BindingAccepts currentLineage currentSource binding) :
    currentSource = binding.source := accepted.2.1

theorem accepted_binding_certificate_commits_to_source
    (currentLineage : Nat)
    (currentSource : SourceCommitment)
    (binding : OccurrenceBinding)
    (accepted : BindingAccepts currentLineage currentSource binding) :
    binding.certificate.source = currentSource := by
  rw [accepted.2.1]
  exact accepted.2.2

theorem same_typed_source_swap_rejects
    (lineage : Nat)
    (currentSource boundSource : SourceCommitment)
    (different : Not (currentSource = boundSource))
    (certificate : OccurrenceCertificate) :
    Not (BindingAccepts lineage currentSource
      { lineage := lineage,
        source := boundSource,
        certificate := certificate }) := by
  intro accepted
  exact different accepted.2.1

theorem post_certificate_content_mutation_rejects
    (lineage : Nat)
    (path typedSource oldContent newContent : String)
    (different : Not (newContent = oldContent))
    (certificate : OccurrenceCertificate) :
    Not (BindingAccepts lineage
      (SourceCommitment.mk path typedSource newContent)
      (OccurrenceBinding.mk lineage
        (SourceCommitment.mk path typedSource oldContent)
        certificate)) := by
  intro accepted
  exact different (congrArg SourceCommitment.content accepted.2.1)

theorem typed_source_substitution_rejects
    (lineage : Nat)
    (path content oldTypedSource newTypedSource : String)
    (different : Not (newTypedSource = oldTypedSource))
    (certificate : OccurrenceCertificate) :
    Not (BindingAccepts lineage
      (SourceCommitment.mk path newTypedSource content)
      (OccurrenceBinding.mk lineage
        (SourceCommitment.mk path oldTypedSource content)
        certificate)) := by
  intro accepted
  exact different (congrArg SourceCommitment.typedSource accepted.2.1)

theorem certificate_source_substitution_rejects
    (lineage : Nat)
    (source otherSource : SourceCommitment)
    (different : Not (otherSource = source))
    (proofId : Nat) :
    Not (BindingAccepts lineage source
      { lineage := lineage,
        source := source,
        certificate := { source := otherSource, proofId := proofId } }) := by
  intro accepted
  exact different accepted.2.2

structure LedgerApplication where
  occurrencePath : String
  source : SourceCommitment
  deriving DecidableEq

structure LedgerConstruction where
  application : LedgerApplication
  certificateIndex : CompleteChainIndex
  deriving DecidableEq

def ConstructionAdmitted
    (sourceLedger : List LedgerApplication)
    (construction : LedgerConstruction) : Prop :=
  construction.application ∈ sourceLedger

theorem admitted_construction_has_concrete_recorded_source_application
    (sourceLedger : List LedgerApplication)
    (construction : LedgerConstruction)
    (accepted : ConstructionAdmitted sourceLedger construction) :
    construction.application ∈ sourceLedger :=
  accepted

theorem unrecorded_construction_is_not_admitted
    (sourceLedger : List LedgerApplication)
    (construction : LedgerConstruction)
    (absent : construction.application ∉ sourceLedger) :
    Not (ConstructionAdmitted sourceLedger construction) :=
  absent

inductive ChainAdmission where
  | certified (index : ChainIndex) (valid : ValidDependentFold index)
  | exactFixedBinary (kind : ChainKind)
      (left right : List NominalSig)

def hasChainEqualityAuthority : ChainAdmission -> Bool
  | .certified _ _ => true
  | .exactFixedBinary _ _ _ => false

def unsupportedChainFallback
    (kind : ChainKind)
    (left right : List NominalSig) : ChainAdmission :=
  .exactFixedBinary kind left right

theorem unsupported_chain_falls_back_to_exact_fixed_binary
    (kind : ChainKind) (left right : List NominalSig) :
    unsupportedChainFallback kind left right =
      .exactFixedBinary kind left right := by
  rfl

theorem unsupported_chain_fallback_has_no_equality_authority
    (kind : ChainKind) (left right : List NominalSig) :
    hasChainEqualityAuthority (unsupportedChainFallback kind left right) = false := by
  rfl

structure ProjectionRequest where
  lineage : Nat
  source : SourceCommitment
  expectedIndex : CompleteChainIndex
  deriving DecidableEq

structure ProjectionEvidence where
  binding : OccurrenceBinding
  index : CompleteChainIndex
  deriving DecidableEq

def ProjectionAccepts
    (request : ProjectionRequest) (evidence : ProjectionEvidence) : Prop :=
  BindingAccepts request.lineage request.source evidence.binding /\
    evidence.index = request.expectedIndex

theorem accepted_projection_rechecks_occurrence_and_every_bound_index
    (request : ProjectionRequest)
    (evidence : ProjectionEvidence)
    (accepted : ProjectionAccepts request evidence) :
    request.lineage = evidence.binding.lineage /\
    request.source = evidence.binding.source /\
    evidence.binding.certificate.source = evidence.binding.source /\
    evidence.index = request.expectedIndex := by
  exact ⟨accepted.1.1, accepted.1.2.1,
    accepted.1.2.2, accepted.2⟩

structure AtomKey where
  identity : String
  exactType : String
  deriving DecidableEq

structure RepairAtom where
  display : String
  semantic : AtomKey
  deriving DecidableEq

def atomUpdateCost (left right : RepairAtom) : Nat :=
  if left.semantic = right.semantic then 0 else 1

theorem readable_spelling_is_not_an_edit
    (leftDisplay rightDisplay : String) (semantic : AtomKey) :
    atomUpdateCost
      { display := leftDisplay, semantic := semantic }
      { display := rightDisplay, semantic := semantic } = 0 := by
  simp [atomUpdateCost]

theorem exact_type_change_is_one_edit
    (display identity leftType rightType : String)
    (different : Not (leftType = rightType)) :
    atomUpdateCost
      { display := display,
        semantic := { identity := identity, exactType := leftType } }
      { display := display,
        semantic := { identity := identity, exactType := rightType } } = 1 := by
  simp [atomUpdateCost, different]

def admitConcreteDependent
    (declared derived : List Col) (hasExactTypeEvidence : Bool) : Bool :=
  if hasExactTypeEvidence then decide (declared = derived) else false

theorem concrete_result_mismatch_rejects
    (declared derived : List Col)
    (different : Not (declared = derived)) :
    admitConcreteDependent declared derived true = false := by
  simp [admitConcreteDependent, different]

theorem explicit_univ_can_receive_a_matching_flat_certificate
    (univColumn : Col) :
    admitConcreteDependent [univColumn] [univColumn] true = true := by
  simp [admitConcreteDependent]

theorem absent_type_receives_no_flat_certificate
    (declared derived : List Col) :
    admitConcreteDependent declared derived false = false := by
  rfl

inductive AssociationLicense where
  | licensed
  | unlicensed
  deriving DecidableEq

def associationRepairDistance : AssociationLicense -> Nat
  | .licensed => 0
  | .unlicensed => 1

def associationCertifiedEqual : AssociationLicense -> Prop
  | .licensed => True
  | .unlicensed => False

theorem licensed_reassociation_is_certified_equal_and_zero_distance :
    associationCertifiedEqual .licensed /\
      associationRepairDistance .licensed = 0 := by
  exact ⟨True.intro, rfl⟩

theorem unlicensed_reassociation_is_not_certified_and_remains_nonzero :
    Not (associationCertifiedEqual .unlicensed) /\
      associationRepairDistance .unlicensed ≠ 0 := by
  constructor
  · intro impossible
    exact impossible
  · decide

inductive ChainWireSchema where
  | v8
  | v9
  | v10
  deriving DecidableEq

inductive StandaloneChainOutcome where
  | exactChainEvidenceAccepted
  | uncheckableMissingEvidence
  | rejectedChainEvidence
  deriving DecidableEq

def hasNonexactBoundary (boundaries : List BoundaryWireIndex) : Bool :=
  boundaries.any fun boundary => boundary.rule != .exact

def productComponentCompleteIndex : CompleteChainIndex :=
  { kind := .join
    profile := "profile"
    sourceAssociation := "source"
    operandTypes := [[.product], [.component, .position]]
    boundaryEvidence := [productComponentWire]
    result := [.position]
    target := "target"
    theoryVersion := fixedDependentChainTheoryVersion
    theoryDigest := fixedDependentChainTheoryDigest }

def exactProductCompleteIndex : CompleteChainIndex :=
  { productComponentCompleteIndex with
    operandTypes := [[.product], [.product, .position]]
    boundaryEvidence := [exactProductBoundaryWire] }

def standaloneChainOutcome
    (schema : ChainWireSchema)
    (index : CompleteChainIndex) : StandaloneChainOutcome :=
  match schema with
  | .v8 => .rejectedChainEvidence
  | .v9 => .rejectedChainEvidence
  | .v10 =>
      if !checkCompleteChainEvidence index then .rejectedChainEvidence
      else if hasNonexactBoundary index.boundaryEvidence then
        .uncheckableMissingEvidence
      else .exactChainEvidenceAccepted

theorem schema_v8_is_rejected_without_reinterpretation
    (index : CompleteChainIndex) :
    standaloneChainOutcome .v8 index = .rejectedChainEvidence := by
  rfl

theorem schema_v9_is_rejected_without_reinterpretation
    (index : CompleteChainIndex) :
    standaloneChainOutcome .v9 index = .rejectedChainEvidence := by
  rfl

theorem mismatched_result_schema_v10_chain_is_rejected :
    standaloneChainOutcome .v10
      { productComponentCompleteIndex with result := [.product] } =
        .rejectedChainEvidence := by
  decide

theorem schema_v10_nonexact_chain_is_uncheckable_without_hierarchy_authority :
    standaloneChainOutcome .v10 productComponentCompleteIndex =
      .uncheckableMissingEvidence := by
  decide

theorem schema_v10_nonexact_chain_cannot_be_accepted_as_exact :
    standaloneChainOutcome .v10 productComponentCompleteIndex !=
      .exactChainEvidenceAccepted := by
  decide

theorem structurally_valid_exact_schema_v10_chain_evidence_is_accepted :
    standaloneChainOutcome .v10 exactProductCompleteIndex =
      .exactChainEvidenceAccepted := by
  decide

theorem mismatched_dependent_theory_digest_rejects :
    standaloneChainOutcome .v10
      { exactProductCompleteIndex with theoryDigest := "digest" } =
        .rejectedChainEvidence := by
  decide

structure ChainWireEvidence where
  schema : ChainWireSchema
  index : CompleteChainIndex
  source : SourceCommitment
  typedSourceTree : String
  leafRules : List String
  leafProofs : List String
  applications : List String
  positionalSchemas : List String
  deriving DecidableEq

def completeChainIndexFieldsMatch
    (expected encoded : CompleteChainIndex) : Bool :=
  decide (encoded.kind = expected.kind) &&
    decide (encoded.profile = expected.profile) &&
    decide (encoded.sourceAssociation = expected.sourceAssociation) &&
    decide (encoded.operandTypes = expected.operandTypes) &&
    decide (encoded.boundaryEvidence = expected.boundaryEvidence) &&
    decide (encoded.result = expected.result) &&
    decide (encoded.target = expected.target) &&
    decide (encoded.theoryVersion = expected.theoryVersion) &&
    decide (encoded.theoryDigest = expected.theoryDigest)

def chainWireFieldsMatch
    (expected encoded : ChainWireEvidence) : Bool :=
  decide (encoded.schema = expected.schema) &&
    completeChainIndexFieldsMatch expected.index encoded.index &&
    decide (encoded.source.path = expected.source.path) &&
    decide (encoded.source.typedSource = expected.source.typedSource) &&
    decide (encoded.source.content = expected.source.content) &&
    decide (encoded.typedSourceTree = expected.typedSourceTree) &&
    decide (encoded.leafRules = expected.leafRules) &&
    decide (encoded.leafProofs = expected.leafProofs) &&
    decide (encoded.applications = expected.applications) &&
    decide (encoded.positionalSchemas = expected.positionalSchemas)

def chainWireEvidenceComplete (encoded : ChainWireEvidence) : Bool :=
  let leaves := encoded.index.operandTypes.length
  leaves >= 2 &&
    encoded.leafRules.length == leaves &&
    encoded.leafProofs.length == leaves &&
    encoded.applications.length + 1 == leaves &&
    encoded.positionalSchemas.length == leaves

def replayChainWire
    (expected : ChainWireEvidence) (encoded : ChainWireEvidence) : Bool :=
  decide (encoded.schema = .v10) &&
    chainWireEvidenceComplete encoded &&
    chainWireFieldsMatch expected encoded &&
    checkCompleteChainEvidence encoded.index

def exactChainWireExample : ChainWireEvidence :=
  { schema := .v10
    index := exactProductCompleteIndex
    source :=
      { path := "root/0", typedSource := "typed-source", content := "source" }
    typedSourceTree := "tree"
    leafRules := ["exact", "exact"]
    leafProofs := ["left-proof", "right-proof"]
    applications := ["join-application"]
    positionalSchemas := ["left", "right"] }

theorem exact_chain_wire_example_replays :
    replayChainWire exactChainWireExample exactChainWireExample = true := by
  decide

theorem changed_chain_wire_source_content_rejects :
    replayChainWire exactChainWireExample
      { exactChainWireExample with
        source := { exactChainWireExample.source with content := "changed" } } =
      false := by
  decide

theorem changed_chain_wire_typed_tree_rejects :
    replayChainWire exactChainWireExample
      { exactChainWireExample with typedSourceTree := "changed-tree" } = false := by
  decide

theorem changed_chain_wire_leaf_proof_rejects :
    replayChainWire exactChainWireExample
      { exactChainWireExample with leafProofs := ["changed-proof"] } = false := by
  decide

theorem changed_chain_wire_positional_schema_rejects :
    replayChainWire exactChainWireExample
      { exactChainWireExample with positionalSchemas := ["swapped"] } = false := by
  decide

theorem empty_chain_wire_ledgers_reject_even_when_expected_matches :
    let empty :=
      { exactChainWireExample with
        leafRules := []
        leafProofs := []
        applications := []
        positionalSchemas := [] }
    replayChainWire empty empty = false := by
  decide

theorem accepted_chain_wire_replay_reconstructs_every_committed_field
    (expected encoded : ChainWireEvidence)
    (accepted : replayChainWire expected encoded = true) :
    encoded.schema = .v10 /\
    chainWireEvidenceComplete encoded = true /\
    chainWireFieldsMatch expected encoded = true /\
    checkCompleteChainEvidence encoded.index = true := by
  simp [replayChainWire] at accepted
  exact ⟨accepted.1.1.1, accepted.1.1.2,
    accepted.1.2, accepted.2⟩

theorem any_chain_wire_field_difference_rejects
    (expected encoded : ChainWireEvidence)
    (different : chainWireFieldsMatch expected encoded = false) :
    replayChainWire expected encoded = false := by
  simp [replayChainWire, different]

theorem schema_v8_chain_wire_rejects
    (expected encoded : ChainWireEvidence)
    (oldSchema : encoded.schema = .v8) :
    replayChainWire expected encoded = false := by
  simp [replayChainWire, oldSchema]

theorem schema_v9_chain_wire_rejects
    (expected encoded : ChainWireEvidence)
    (oldSchema : encoded.schema = .v9) :
    replayChainWire expected encoded = false := by
  simp [replayChainWire, oldSchema]

theorem accepted_nonexact_chain_wire_is_uncheckable_not_exact
    (expected encoded : ChainWireEvidence)
    (accepted : replayChainWire expected encoded = true)
    (nonexact : hasNonexactBoundary encoded.index.boundaryEvidence = true) :
    standaloneChainOutcome encoded.schema encoded.index =
      .uncheckableMissingEvidence := by
  have replayed := accepted
  simp [replayChainWire] at replayed
  simp [standaloneChainOutcome, replayed.1.1, replayed.2, nonexact]

structure SourceClass where
  memberCount : Nat
  leader : Nat
  self : Nat
  canonical : Nat

def PristineSource (source : SourceClass) : Prop :=
  And (source.memberCount = 1)
    (And (source.leader = source.self)
      (source.canonical = source.self))

theorem nonleader_union_is_not_pristine
    (source : SourceClass)
    (different : Not (source.leader = source.self)) :
    Not (PristineSource source) := by
  intro pristine
  exact different pristine.2.1

theorem noncanonical_union_is_not_pristine
    (source : SourceClass)
    (different : Not (source.canonical = source.self)) :
    Not (PristineSource source) := by
  intro pristine
  exact different pristine.2.2

end ACGN.Section3.PhaseA2
