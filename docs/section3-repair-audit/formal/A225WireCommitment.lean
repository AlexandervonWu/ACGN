import Std
import Std.Data.String.ToNat
import P611SchemaAdmission
import A224Join
import CanonicalWireTables

namespace ACGN.Ninth.A225

inductive Wire where
  | node (tag : String) (fields : List String) (children : List Wire)

open Wire

structure Column where
  exactType : String
  key : String
  ancestors : List String
  deriving DecidableEq

structure Product where
  relation : String
  key : String
  columns : List Column
  deriving DecidableEq

/-- The emitted optional type reference is distinct from the NONE sentinel. -/
abbrev TypeRef := {s : String // s ≠ "NONE"}

def optionalRef : Option TypeRef → String
  | none => "NONE"
  | some r => r.val

def readRef (s : String) : Option TypeRef :=
  if h : s = "NONE" then none else some ⟨s, h⟩

theorem ref_roundtrip (x : Option TypeRef) : readRef (optionalRef x) = x := by
  cases x with
  | none => simp [optionalRef, readRef]
  | some r => simp [optionalRef, readRef, r.property]

def encPath (tag : String) (path : List String) : List Wire :=
  path.map (fun s => node tag [s] [])

def decPath (tag : String) (nodes : List Wire) : Option (List String) :=
  nodes.mapM fun n => match n with
  | node actual [s] [] => if actual = tag then some s else none
  | _ => none

theorem read_mapped {α β : Type} (e : α → β) (d : β → Option α)
    (roundtrip : ∀ x, d (e x) = some x) (xs : List α) :
    (xs.map e).mapM d = some xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp only [List.map_cons, List.mapM_cons, roundtrip, ih]; rfl

theorem path_roundtrip (tag : String) (xs : List String) :
    decPath tag (encPath tag xs) = some xs := by
  unfold decPath encPath
  apply read_mapped
  intro x
  simp

def column (c : Column) : Wire :=
  node "dependent-chain-column" [c.exactType, c.key] (encPath "dependent-chain-ancestor" c.ancestors)

def readColumn : Wire → Option Column
  | node "dependent-chain-column" [ty, key] children => do
    return ⟨ty, key, ← decPath "dependent-chain-ancestor" children⟩
  | _ => none

theorem column_roundtrip (c : Column) : readColumn (column c) = some c := by
  cases c; simp [readColumn, column, path_roundtrip]

def product (index : String) (p : Product) : Wire :=
  node "dependent-type-product" [index, p.relation, p.key] (p.columns.map column)

def readProduct (index : String) : Wire → Option Product
  | node "dependent-type-product" [found, ty, key] cs => do
    guard (found = index)
    return ⟨ty, key, ← cs.mapM readColumn⟩
  | _ => none

theorem product_roundtrip (index : String) (p : Product) :
    readProduct index (product index p) = some p := by
  cases p; simp [readProduct, product, guard, read_mapped column readColumn column_roundtrip]

def indexed (i : Nat) : List Product → List Wire
  | [] => []
  | p :: tail => product i.repr p :: indexed (i+1) tail

def readIndexed (i : Nat) : List Wire → Option (List Product)
  | [] => some []
  | h :: t => return (← readProduct i.repr h) :: (← readIndexed (i+1) t)

theorem indexed_roundtrip (i : Nat) (rows : List Product) :
    readIndexed i (indexed i rows) = some rows := by
  induction rows generalizing i with
  | nil => rfl
  | cons r xs ih => simp [indexed, readIndexed, product_roundtrip, ih]

structure Dag where
  relation : String
  common : Option TypeRef
  arity : Nat
  key : String
  alternatives : List Product
  deriving DecidableEq

def dag (d : Dag) : Wire :=
  node "dependent-type-dag" [d.relation, optionalRef d.common, d.arity.repr, d.key]
    (indexed 0 d.alternatives)

def readDag : Wire → Option Dag
  | node "dependent-type-dag" [relation, common, arity, key] cs => do
    let n ← arity.toNat?
    guard (n.repr = arity)
    return ⟨relation, readRef common, n, key, ← readIndexed 0 cs⟩
  | _ => none

theorem dag_roundtrip (d : Dag) : readDag (dag d) = some d := by
  cases d; simp [readDag, dag, guard, Nat.toNat?_repr, ref_roundtrip, indexed_roundtrip]

structure Boundary where
  rule : String
  left : String
  right : String
  meet : Option TypeRef
  ancestor : String
  key : String
  leftPath : List String
  rightPath : List String
  deriving DecidableEq

def boundary : Option Boundary → Wire
  | none => node "dependent-chain-no-boundary" ["ARROW"] []
  | some b => node "dependent-chain-boundary"
     [b.rule, b.left, b.right, optionalRef b.meet, b.ancestor, b.key]
     [node "dependent-chain-boundary-left-path" [] (encPath "dependent-chain-boundary-step" b.leftPath),
      node "dependent-chain-boundary-right-path" [] (encPath "dependent-chain-boundary-step" b.rightPath)]

def readBoundary : Wire → Option (Option Boundary)
  | node "dependent-chain-no-boundary" ["ARROW"] [] => some none
  | node "dependent-chain-boundary" [rule, left, right, meet, anc, key]
      [node "dependent-chain-boundary-left-path" [] ls, node "dependent-chain-boundary-right-path" [] rs] => do
    return some ⟨rule, left, right, readRef meet, anc, key,
                 ← decPath "dependent-chain-boundary-step" ls, ← decPath "dependent-chain-boundary-step" rs⟩
  | _ => none

theorem boundary_roundtrip (b : Option Boundary) : readBoundary (boundary b) = some b := by
  cases b with
  | none => rfl
  | some x => cases x; simp [boundary, readBoundary, path_roundtrip, ref_roundtrip]

def result : Option Product → Wire
  | none => node "dependent-chain-no-result" ["DISJOINT"] []
  | some p => product "-1" p

def readResult : Wire → Option (Option Product)
  | node "dependent-chain-no-result" ["DISJOINT"] [] => some none
  | w => some <$> readProduct "-1" w

theorem result_roundtrip (x : Option Product) : readResult (result x) = some x := by
  cases x with
  | none => rfl
  | some p => change some <$> readProduct "-1" (product "-1" p) = some (some p)
              rw [product_roundtrip]; rfl

structure PairCase where
  left : Nat
  right : Nat
  decision : String
  key : String
  witness : Option Boundary
  output : Option Product
  deriving DecidableEq

def pairCase (c : PairCase) : Wire :=
  node "dependent-chain-combination-case" [c.left.repr, c.right.repr, c.decision, c.key]
    [boundary c.witness, result c.output]

def readPairCase : Wire → Option PairCase
  | node "dependent-chain-combination-case" [l, r, d, key] [b, out] => do
    let li ← l.toNat?
    let ri ← r.toNat?
    guard (li.repr = l ∧ ri.repr = r)
    return ⟨li, ri, d, key, ← readBoundary b, ← readResult out⟩
  | _ => none

theorem case_roundtrip (c : PairCase) : readPairCase (pairCase c) = some c := by
  cases c; simp [pairCase, readPairCase, guard, Nat.toNat?_repr, boundary_roundtrip, result_roundtrip]

def matrix (rows : List PairCase) : Wire :=
  node "dependent-chain-combination-cases" [rows.length.repr] (rows.map pairCase)

def readMatrix : Wire → Option (List PairCase)
  | node "dependent-chain-combination-cases" [count] cs => do
    guard (count = cs.length.repr)
    cs.mapM readPairCase
  | _ => none

theorem matrix_roundtrip (cs : List PairCase) : readMatrix (matrix cs) = some cs := by
  simp [matrix, readMatrix, guard, read_mapped pairCase readPairCase case_roundtrip]

theorem complete_commitment (a b : Dag) (xs ys : List PairCase)
    (hdag : dag a = dag b) (hmat : matrix xs = matrix ys) : a = b ∧ xs = ys := by
  constructor
  · simpa only [dag_roundtrip, Option.some.injEq] using congrArg readDag hdag
  · simpa only [matrix_roundtrip, Option.some.injEq] using congrArg readMatrix hmat

/-- An unclassified cell blocks enumeration. Every emitted cell uses the loop's indices. -/
def atAddress (classify : Nat × Nat → Option PairCase) (ij : Nat × Nat) : Option PairCase :=
  (classify ij).map (fun cell => { cell with left := ij.1, right := ij.2 })

theorem committed_pair_matrix (m n : Nat) (classify : Nat × Nat → Option PairCase)
    (rows : List PairCase) (complete : A224.collect (atAddress classify) (A224.grid 0 n m) = some rows) :
    readMatrix (matrix rows) = some rows ∧ rows.length = m * n ∧
      ∀ i < m, ∀ j < n, rows[i*n+j]? = atAddress classify (i,j) := by
  refine ⟨matrix_roundtrip _, (A224.collected_length complete).trans (A224.matrix_size ..), ?_⟩
  intro i hi j hj
  rw [A224.collected_at complete, A224.row_major_address 0 m n i j hi hj]
  simp

/-- Project the envelope fields of the same decoded tree that owns the nested record. -/
def envelope (w : Wire) : ACGN.Eighth.P611.Root :=
  match w with | node tag scalars children => ⟨tag, scalars, children.length⟩

def atPath : Wire → List Nat → Option Wire
  | w, [] => some w
  | node _ _ cs, i :: tail => do
    let child ← cs[i]?
    atPath child tail

def readApplication (bundle : Wire) (path : List Nat) : Option (Dag × List PairCase) := do
  let _ ← (ACGN.Eighth.P611.schemaGate (envelope bundle)).toOption
  let node "dependent-chain-application" [_, _, _, _] [_, _, d, m] ← atPath bundle path | none
  return (← readDag d, ← readMatrix m)

theorem schema_bound_roundtrip (bundle : Wire) (path : List Nat)
    (kind context output key : String) (l r : Wire) (d : Dag) (cs : List PairCase)
    (admitted : ACGN.Eighth.P611.schemaGate (envelope bundle) = .ok (envelope bundle))
    (address : atPath bundle path = some (node "dependent-chain-application"
      [kind, context, output, key] [l, r, dag d, matrix cs])) :
    (envelope bundle).scalars = [ACGN.Eighth.P611.schema] ∧
      readApplication bundle path = some (d, cs) := by
  constructor
  · exact (ACGN.Eighth.P611.exact_scalar_necessary _ _ admitted).2
  · simp [readApplication, admitted, address, dag_roundtrip, matrix_roundtrip, Except.toOption]

theorem other_schema_cannot_reinterpret (v : String) (body : List Wire) (path : List Nat)
    (different : v ≠ ACGN.Eighth.P611.schema) (size : body.length = 12) :
    readApplication (node "acgncert-bundle" [v] body) path = none := by
  unfold readApplication
  simp only [envelope, size, ACGN.Eighth.P611.every_other_string_rejects v different]
  rfl

private abbrev BinaryNode := ACGN.FifthFive.CanonicalWireTables.Node
private def utf8 (s : String) : List Nat := s.toUTF8.data.toList.map UInt8.toNat

mutual
def binaryTree : Wire → BinaryNode
  | node t f c => .mk (utf8 t) (f.map utf8) (binaryChildren c)
def binaryChildren : List Wire → List BinaryNode
  | [] => []
  | w :: ws => binaryTree w :: binaryChildren ws
end

/-- The binary payload actually decoded for this envelope re-encodes exactly.
    The same envelope supplies schema admission and the addressed field-level result. -/
theorem admitted_payload_commitment (fuel : Nat) (bytes : List Nat)
    (bundle : Wire) (path : List Nat) (kind context output key : String)
    (l r : Wire) (d : Dag) (cs : List PairCase)
    (decoded : ACGN.FifthFive.CanonicalWireTables.decode fuel bytes = some (binaryTree bundle))
    (admitted : ACGN.Eighth.P611.schemaGate (envelope bundle) = .ok (envelope bundle))
    (address : atPath bundle path = some (node "dependent-chain-application"
      [kind, context, output, key] [l, r, dag d, matrix cs])) :
    ACGN.FifthFive.CanonicalWireTables.encode (binaryTree bundle) = bytes ∧
      (envelope bundle).scalars = [ACGN.Eighth.P611.schema] ∧
      readApplication bundle path = some (d, cs) :=
  ⟨ACGN.FifthFive.CanonicalWireTables.decode_exact fuel bytes _ decoded,
   schema_bound_roundtrip bundle path kind context output key l r d cs admitted address⟩

#print axioms ref_roundtrip
#print axioms path_roundtrip
#print axioms column_roundtrip
#print axioms read_mapped
#print axioms product_roundtrip
#print axioms indexed_roundtrip
#print axioms dag_roundtrip
#print axioms boundary_roundtrip
#print axioms result_roundtrip
#print axioms case_roundtrip
#print axioms matrix_roundtrip
#print axioms complete_commitment

#print axioms admitted_payload_commitment
#print axioms committed_pair_matrix
#print axioms schema_bound_roundtrip
#print axioms other_schema_cannot_reinterpret

end ACGN.Ninth.A225
