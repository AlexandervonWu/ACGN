import A222Intersection

namespace A222.Replay
open A222

inductive Rule where | exact | left | right | divergent deriving BEq, DecidableEq, Repr
inductive Ref where | left | right | common | empty deriving BEq, DecidableEq, Repr
inductive Slice where | leftOne | rightOne | leftToRight | rightToLeft | leftToCommon | rightToCommon
  deriving BEq, DecidableEq, Repr
structure Operation where
  rule : Rule
  meet : Ref
  common : Ref
  leftPath : Slice
  rightPath : Slice
  deriving BEq, DecidableEq, Repr

def rule? : String → Option Rule
  | "Rule.EXACT" => some .exact
  | "Rule.LEFT_SUBTYPE_OF_RIGHT" => some .left
  | "Rule.RIGHT_SUBTYPE_OF_LEFT" => some .right
  | "Rule.DISJOINT_BRANCHES" => some .divergent
  | _ => none

def ref? : String → Option Ref
  | "leftBoundary" => some .left
  | "rightBoundary" => some .right
  | "common" => some .common
  | "null" => some .empty
  | _ => none

def slice? : String → Option Slice
  | "List.of(leftBoundary)" => some .leftOne
  | "List.of(rightBoundary)" => some .rightOne
  | "left.ancestry().subList(0, rightInLeft + 1)" => some .leftToRight
  | "right.ancestry().subList(0, leftInRight + 1)" => some .rightToLeft
  | "left.ancestry().subList(0, leftCommon + 1)" => some .leftToCommon
  | "right.ancestry().subList(0, rightCommon + 1)" => some .rightToCommon
  | _ => none

def decode (line : String) : Option Operation := do
  let [rule,"leftBoundary","rightBoundary",meet,common,l,r] := line.splitOn "|" | none
  return ⟨←rule? rule, ←ref? meet, ←ref? common, ←slice? l, ←slice? r⟩

def canonical : List Operation := [
  ⟨.exact,.left,.left,.leftOne,.rightOne⟩, ⟨.left,.left,.right,.leftToRight,.rightOne⟩,
  ⟨.right,.right,.left,.leftOne,.rightToLeft⟩, ⟨.divergent,.empty,.common,.leftToCommon,.rightToCommon⟩]

def through (target : Nat) (path : List Nat) := path.takeWhile (· != target) ++ [target]

structure Answer where
  rule : Rule
  meet : Option Nat
  common : Nat
  leftPath : List Nat
  rightPath : List Nat
  deriving BEq, DecidableEq, Repr

def eval (ops : List Operation) (l r : Col) : Option Answer := do
  let (index, a) ← match classify l r with
    | .exact => some (0,l.head)
    | .leftSubtype => some (1,r.head)
    | .rightSubtype => some (2,l.head)
    | .disjoint a => some (3,a)
    | .unsupported => none
  let op ← ops[index]?
  let read : Ref → Option Nat := fun s => match s with
    | .left => some l.head | .right => some r.head | .common => some a | .empty => none
  let segment : Slice → List Nat := fun s => match s with
    | .leftOne => [l.head] | .rightOne => [r.head]
    | .leftToRight => through r.head l.path | .rightToLeft => through l.head r.path
    | .leftToCommon => through a l.path | .rightToCommon => through a r.path
  return ⟨op.rule, read op.meet, ← read op.common, segment op.leftPath, segment op.rightPath⟩

theorem compiler_returns (ops : List Operation) (l r : Col) (registered : ops = canonical) :
    eval ops l r = match classify l r with
    | .exact => some ⟨.exact,some l.head,l.head,[l.head],[r.head]⟩
    | .leftSubtype => some ⟨.left,some l.head,r.head,through r.head l.path,[r.head]⟩
    | .rightSubtype => some ⟨.right,some r.head,l.head,[l.head],through l.head r.path⟩
    | .disjoint a => some ⟨.divergent,none,a,through a l.path,through a r.path⟩
    | .unsupported => none := by
  subst ops
  cases e : classify l r <;> simp [eval, e, canonical]

/-- The supported JDK control fragment includes every conditional, bound, operand selection,
flag assignment and exit in the finite family controller; javac pins its complete method bindings. -/
def controller : List String := [
  "control:binary|width|(left.arity() != right.arity())|THROW",
  "control:binary|authority|requireCompatibleAuthority(left.alternatives, right.alternatives)",
  "control:binary|empty|(left.alternatives.isEmpty() || right.alternatives.isEmpty())|RETURN",
  "control:binary|start|products=new ArrayList<>()",
  "control:binary|each|leftProduct in left.alternatives",
  "control:binary|each|rightProduct in right.alternatives",
  "control:binary|new|product=new ArrayList<>(left.arity())",
  "control:binary|flag|disjoint=false",
  "control:binary|each|column=0|column < left.arity()|column++",
  "control:binary|derive|proof=DependentBoundaryCorrespondence.derive(leftProduct.get(column), rightProduct.get(column))",
  "control:binary|omit|(!proof.overlaps())|disjoint = true|break",
  "control:binary|column|product.add(moreSpecific(leftProduct.get(column), rightProduct.get(column), proof))",
  "control:binary|row|(!disjoint)|products.add(product)",
  "control:binary|finish|products.isEmpty() ? empty(left.arity()) : new DependentTypeDag(products)",
  "control:derive|value|leftBoundary=left.exactColumn()",
  "control:derive|value|rightBoundary=right.exactColumn()",
  "control:derive|guard|(leftBoundary.equals(rightBoundary))|RETURN",
  "control:derive|guard|(!isAlloySignature(leftBoundary) || !isAlloySignature(rightBoundary))|THROW",
  "control:derive|guard|(!left.sharesParserModuleAuthorityWith(right))|THROW",
  "control:derive|value|rightInLeft=left.ancestorIndex(rightBoundary)",
  "control:derive|value|leftInRight=right.ancestorIndex(leftBoundary)",
  "control:derive|guard|(rightInLeft > 0 && leftInRight > 0)|THROW",
  "control:derive|guard|(rightInLeft > 0)|RETURN",
  "control:derive|guard|(leftInRight > 0)|RETURN",
  "control:derive|value|common=firstCommonAncestor(left.ancestry(), right.ancestry())",
  "control:derive|guard|(common == null)|THROW",
  "control:derive|value|leftCommon=left.ancestorIndex(common)",
  "control:derive|value|rightCommon=right.ancestorIndex(common)",
  "control:derive|guard|(leftCommon <= 0 || rightCommon <= 0)|THROW",
  "control:fold|operands|Objects.requireNonNull(operands, \"operands\")",
  "control:fold|minimum|(operands.size() < 2)|THROW",
  "control:fold|first|result=Objects.requireNonNull(operands.get(0), \"intersection operand\")",
  "control:fold|next|index=1|index < operands.size()|index++",
  "control:fold|step|result = intersectPair(result, Objects.requireNonNull(operands.get(index), \"intersection operand\"))",
  "control:fold|end|result"]

/-- Read the registered returns and the complete control fragment emitted by javac.
Both the executable fixture replay and the normalized-family proof use this decoder. -/
def readProgram (program : List String) : Option (List Operation) := do
  let ops ← (program.take 4).mapM decode
  if ops = canonical ∧ program.drop 4 = controller then some ops else none

def sourceHeader (lines : List String) := lines.takeWhile (·.startsWith "P\t")

def sourceProgram (lines : List String) := (sourceHeader lines).map fun s => (s.drop 2).toString

def transcriptProgram (lines : List String) := readProgram (sourceProgram lines)

theorem readProgram_registered (program : List String) (ops : List Operation)
    (ok : readProgram program = some ops) : ops = canonical := by
  unfold readProgram at ok
  cases h : (program.take 4).mapM decode with
  | none => simp [h] at ok
  | some decoded =>
    by_cases good : decoded = canonical ∧ program.drop 4 = controller
    · simpa [h,good,good.1] using ok.symm
    · simp [h,good] at ok

#print axioms compiler_returns
#print axioms readProgram_registered
end A222.Replay
