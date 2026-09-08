/- Bounded P2-20/P2-18 model. Exact identities below are structural coordinates,
   not digests. Java, source extraction and wire replay are separate evidence. -/
namespace ACGN.FourthFive.ContainerWitnessTransitions

structure OperatorIndex where
  head : String
  result : Nat
  path : List Nat
  schema : String
  profile : String
  theory : String
  production : Bool
  assoc : Bool
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

inductive Tree where
  | leaf (type identity : Nat)
  | node (index : OperatorIndex) (children : List Tree)
  deriving BEq

-- Local structural helpers keep both kernel reduction and executable compilation.
def ordered : Tree -> List Nat
  | .leaf _ identity => [identity]
  | .node _ children => go children
where
  go : List Tree -> List Nat
    | [] => []
    | head :: tail => ordered head ++ go tail

def orderedList : List Tree -> List Nat := ordered.go

def legal (root : OperatorIndex) : Tree -> Bool
  | .leaf type _ => type == root.result
  | .node index children => index == root && root.production && root.assoc && root.path == [0] &&
      !children.isEmpty && go children
where
  go : List Tree -> Bool
    | [] => true
    | head :: tail => legal root head && go tail

def legalList (root : OperatorIndex) : List Tree -> Bool := legal.go root

theorem legalList_eq_all (root : OperatorIndex) (children : List Tree) :
    legalList root children = children.all (legal root) := by
  induction children with
  | nil => rfl
  | cons head tail ih =>
      change (legal root head && legalList root tail) = _
      simp [ih]

theorem orderedList_eq_flatMap (children : List Tree) :
    orderedList children = children.flatMap ordered := by
  induction children with
  | nil => rfl
  | cons head tail ih =>
      change ordered head ++ orderedList tail = _
      simp [ih]

def flatten (root : OperatorIndex) (tree : Tree) : Option (List Nat) :=
  if legal root tree then some (ordered tree) else none

theorem flatten_some_iff (root : OperatorIndex) (tree : Tree) (out : List Nat) :
    flatten root tree = some out <-> legal root tree = true ∧ out = ordered tree := by
  simp only [flatten]
  split
  next h => simp [h, eq_comm]
  next h => simp [h]

theorem flatten_rejects_iff (root : OperatorIndex) (tree : Tree) :
    flatten root tree = none <-> legal root tree = false := by
  simp [flatten]

theorem recursive_same_head_decision (root index : OperatorIndex) (children : List Tree) :
    legal root (.node index children) = true <->
      index = root ∧ root.production = true ∧ root.assoc = true ∧ root.path = [0] ∧
      children.isEmpty = false ∧ children.all (legal root) = true := by
  change (index == root && root.production && root.assoc && root.path == [0] &&
    !children.isEmpty && legalList root children) = true <-> _
  simp [legalList_eq_all, Bool.and_eq_true, and_assoc]

theorem wrong_nested_instance (root index : OperatorIndex) (children : List Tree)
    (h : index ≠ root) : flatten root (.node index children) = none := by
  simp [flatten, legal, h]

theorem missing_typed_assoc (root index : OperatorIndex) (children : List Tree)
    (h : root.assoc = false) : flatten root (.node index children) = none := by
  simp [flatten, legal, h]

theorem unadmitted_authority (root index : OperatorIndex) (children : List Tree)
    (h : root.production = false) : flatten root (.node index children) = none := by
  simp [flatten, legal, h]

theorem recursive_order (index : OperatorIndex) (left right : List Tree) :
    ordered (.node index (left ++ right)) =
      left.flatMap ordered ++ right.flatMap ordered := by
  change orderedList (left ++ right) = _
  simp [orderedList_eq_flatMap]

theorem flatten_preserves_order (root : OperatorIndex) (tree : Tree) (out : List Nat)
    (h : flatten root tree = some out) : out = ordered tree :=
  ((flatten_some_iff root tree out).mp h).2

theorem flatten_preserves_repeats (root : OperatorIndex) (tree : Tree) (out : List Nat)
    (identity : Nat) (h : flatten root tree = some out) :
    out.count identity = (ordered tree).count identity := by
  rw [flatten_preserves_order root tree out h]

inductive Carrier where
  | seq | bag | set
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

-- The alphabet is an independently checked structural-key ranking, not a hash.
def insertBy (le : Nat -> Nat -> Bool) (value : Nat) : List Nat -> List Nat
  | [] => [value]
  | head :: tail => if le value head then value :: head :: tail else head :: insertBy le value tail

def sortBy (le : Nat -> Nat -> Bool) : List Nat -> List Nat
  | [] => []
  | head :: tail => insertBy le head (sortBy le tail)

def sorted (inputs : List Nat) : List Nat := sortBy (· ≤ ·) inputs
def outputs (carrier : Carrier) (inputs : List Nat) : List Nat :=
  match carrier with
  | .seq => inputs
  | .bag => sorted inputs
  | .set => (sorted inputs).eraseDups

def fibers (carrier : Carrier) (inputs : List Nat) : List (List Nat) :=
  match carrier with
  | .seq => (List.range inputs.length).map (fun i => [i])
  | .bag => (sortBy (fun i j => inputs[i]! ≤ inputs[j]!) (List.range inputs.length)).map
      (fun i => [i])
  | .set => (outputs .set inputs).map (fun v =>
      (List.range inputs.length).filter (fun i => inputs[i]! == v))

structure TraceIndex where
  schema : String
  context : String
  inputs : List Nat
  outputs : List Nat
  fibers : List (List Nat)
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def traceIndex (carrier : Carrier) (schema context : String) (inputs : List Nat) : TraceIndex :=
  ⟨schema, context, inputs, outputs carrier inputs, fibers carrier inputs⟩

def acceptsTrace (carrier : Carrier) (schema context : String) (inputs : List Nat)
    (candidate : TraceIndex) : Bool := candidate == traceIndex carrier schema context inputs

theorem trace_exact_fields (carrier : Carrier) (schema context : String) (inputs : List Nat)
    (candidate : TraceIndex) : acceptsTrace carrier schema context inputs candidate = true <->
      candidate.schema = schema ∧ candidate.context = context ∧ candidate.inputs = inputs ∧
      candidate.outputs = outputs carrier inputs ∧ candidate.fibers = fibers carrier inputs := by
  cases candidate
  simp [acceptsTrace, traceIndex, TraceIndex.mk.injEq]

theorem wrong_permutation_or_fiber (carrier : Carrier) (schema context : String)
    (inputs : List Nat) (candidate : TraceIndex) (h : candidate.fibers ≠ fibers carrier inputs) :
    acceptsTrace carrier schema context inputs candidate = false := by
  cases hc : acceptsTrace carrier schema context inputs candidate with
  | false => rfl
  | true => exact False.elim (h ((trace_exact_fields carrier schema context inputs candidate).mp hc).2.2.2.2)

structure SpliceIndex where
  path : List Nat
  outerArity : Nat
  nestedArity : Nat
  position : Nat
  nestedSource : String
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def spliceIndex (path : List Nat) (outer nested position : Nat) (source : String) : SpliceIndex :=
  ⟨path ++ [position], outer, nested, position, source⟩

theorem splice_exact_fields (path : List Nat) (outer nested position : Nat) (source : String)
    (candidate : SpliceIndex) : candidate = spliceIndex path outer nested position source <->
      candidate.path = path ++ [position] ∧ candidate.outerArity = outer ∧
      candidate.nestedArity = nested ∧ candidate.position = position ∧ candidate.nestedSource = source := by
  cases candidate
  simp [spliceIndex, SpliceIndex.mk.injEq]

-- The producer emits the parent marker before descending into the child.
def producerSplices (key : Tree -> String) (path : List Nat) : Tree -> List SpliceIndex
  | .leaf _ _ => []
  | .node _ children => go children.length 0 children
where
  go (outer position : Nat) : List Tree -> List SpliceIndex
    | [] => []
    | head :: tail =>
        (match head with
          | .leaf _ _ => []
          | .node _ children => [spliceIndex path outer children.length position (key head)]) ++
        producerSplices key (path ++ [position]) head ++ go outer (position + 1) tail

-- The verifier first validates the child, then inserts its marker at the saved
-- ledger position, before the child's recursively derived suffix.
def verifierSplices (key : Tree -> String) (path : List Nat) : Tree -> List SpliceIndex
  | .leaf _ _ => []
  | .node _ children => go children.length 0 children
where
  go (outer position : Nat) : List Tree -> List SpliceIndex
    | [] => []
    | head :: tail =>
        let validated := verifierSplices key (path ++ [position]) head
        let suffix := go outer (position + 1) tail
        match head with
        | .leaf _ _ => validated ++ suffix
        | .node _ children => spliceIndex path outer children.length position (key head) :: (validated ++ suffix)

theorem recursive_splice_order (key : Tree -> String) (tree : Tree) :
    ∀ path, producerSplices key path tree = verifierSplices key path tree := by
  refine Tree.rec
    (motive_1 := fun tree => ∀ path, producerSplices key path tree = verifierSplices key path tree)
    (motive_2 := fun children => ∀ path outer position,
      producerSplices.go key path outer position children = verifierSplices.go key path outer position children)
    ?_ ?_ ?_ ?_ tree
  · intro type identity path; rfl
  · intro index children ih path; exact ih path children.length 0
  · intro path outer position; rfl
  · intro head tail ihHead ihTail path outer position
    simp only [producerSplices.go, verifierSplices.go, ihHead, ihTail]
    cases head <;> simp

theorem saved_ledger_position (initial suffix : List SpliceIndex) (parent : SpliceIndex) :
    (initial ++ suffix).insertIdx initial.length parent = initial ++ parent :: suffix := by
  induction initial with
  | nil => rfl
  | cons head tail ih => simpa using congrArg (List.cons head) ih

def spliceCoordinates (splices : List SpliceIndex) : List (List Nat) :=
  splices.map (fun s => s.path ++ [s.outerArity, s.nestedArity, s.position])

def acceptsSpliceLedger (key : Tree -> String) (tree : Tree) (candidate : List (List Nat)) : Bool :=
  spliceCoordinates (verifierSplices key [] tree) == candidate

theorem accepted_ledger_exact_order (key : Tree -> String) (tree : Tree) (candidate : List (List Nat)) :
    acceptsSpliceLedger key tree candidate = true <->
      candidate = spliceCoordinates (producerSplices key [] tree) := by
  rw [recursive_splice_order key tree []]
  change (spliceCoordinates (verifierSplices key [] tree) == candidate) = true <-> _
  exact beq_iff_eq.trans eq_comm

theorem changed_ledger_order_rejects (key : Tree -> String) (tree : Tree) (candidate : List (List Nat))
    (h : candidate ≠ spliceCoordinates (producerSplices key [] tree)) :
    acceptsSpliceLedger key tree candidate = false := by
  cases hc : acceptsSpliceLedger key tree candidate with
  | false => rfl
  | true => exact False.elim (h ((accepted_ledger_exact_order key tree candidate).mp hc))

structure LawIndex where
  authority : String
  operator : String
  path : String
  law : String
  theory : String
  profile : String
  result : String
  schema : String
  parameter : String
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def lawIndex (i : LawIndex) : List String × List String :=
  ([i.authority, i.operator, i.path, i.law, i.theory], [i.profile, i.result, i.schema, i.parameter])

theorem law_index_injective (a b : LawIndex) : lawIndex a = lawIndex b <-> a = b := by
  cases a; cases b
  simp [lawIndex, LawIndex.mk.injEq, and_assoc]

structure WitnessIndex where
  law : LawIndex
  trace : TraceIndex
  splices : List SpliceIndex
  left : String
  right : String
  deriving DecidableEq, BEq, ReflBEq, LawfulBEq

def acceptsWitness (expected candidate : WitnessIndex) : Bool := candidate == expected

theorem witness_exact_fields (expected candidate : WitnessIndex) :
    acceptsWitness expected candidate = true <-> candidate.law = expected.law ∧
      candidate.trace = expected.trace ∧ candidate.splices = expected.splices ∧
      candidate.left = expected.left ∧ candidate.right = expected.right := by
  cases candidate; cases expected
  simp [acceptsWitness, WitnessIndex.mk.injEq]

-- Empty structural carriers do not create UNIT/deletion authority.
def productionUnit (_schema : String) (_deletionPosition : Nat) : Bool := false

theorem unit_deletion_remains_unadmitted (schema : String) (position : Nat) :
    productionUnit schema position = false := rfl

#print axioms legalList_eq_all
#print axioms orderedList_eq_flatMap
#print axioms flatten_some_iff
#print axioms flatten_rejects_iff
#print axioms recursive_same_head_decision
#print axioms wrong_nested_instance
#print axioms missing_typed_assoc
#print axioms unadmitted_authority
#print axioms recursive_order
#print axioms flatten_preserves_order
#print axioms flatten_preserves_repeats
#print axioms trace_exact_fields
#print axioms wrong_permutation_or_fiber
#print axioms splice_exact_fields
#print axioms recursive_splice_order
#print axioms saved_ledger_position
#print axioms accepted_ledger_exact_order
#print axioms changed_ledger_order_rejects
#print axioms law_index_injective
#print axioms witness_exact_fields
#print axioms unit_deletion_remains_unadmitted
end ACGN.FourthFive.ContainerWitnessTransitions
