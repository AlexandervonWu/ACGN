/- P3-05/P3-06 structural records. External identities and source-key interpretation
   are explicit parameters, not hash injectivity or universal JVM refinement. -/
namespace ACGN.FifthFive.FlatContainerRecords

inductive Wire where
  | node (tag : String) (scalars : List String) (children : List Wire)

def wireEqual : Wire -> Wire -> Bool
  | .node t ss cs, .node u vs ds => t == u && ss == vs && go cs ds
where
  go : List Wire -> List Wire -> Bool
    | [], [] => true
    | a :: as, b :: bs => wireEqual a b && go as bs
    | _, _ => false

instance : BEq Wire := ⟨wireEqual⟩

theorem wire_equality_exact (a : Wire) : ∀ b, wireEqual a b = true ↔ a = b := by
  refine Wire.rec
    (motive_1 := fun a => ∀ b, wireEqual a b = true ↔ a = b)
    (motive_2 := fun xs => ∀ ys, wireEqual.go xs ys = true ↔ xs = ys) ?_ ?_ ?_ a
  · intro tag ss cs ih b
    cases b
    simp [wireEqual, ih, Wire.node.injEq, and_assoc]
  · intro ys; cases ys <;> simp [wireEqual.go]
  · intro h t ih it ys
    cases ys <;> simp [wireEqual.go, ih, it]

instance : ReflBEq Wire where
  rfl := (wire_equality_exact _ _).mpr rfl
instance : LawfulBEq Wire where
  eq_of_beq := (wire_equality_exact _ _).mp
instance : DecidableEq Wire := fun a b => decidable_of_iff ((a == b) = true) (wire_equality_exact a b)

def leaf (tag : String) (scalars : List String) : Wire := .node tag scalars []

def readNat (s : String) : Option Nat :=
  if s.isEmpty then none else
    s.toList.foldl (fun acc c => do
      let n <- acc
      if '0' ≤ c && c ≤ '9' then some (n * 10 + (c.toNat - '0'.toNat)) else none) (some 0)

def natural (s : String) : Bool :=
  match readNat s with
  | some n => toString n == s
  | none => false

def sourceShape : Wire -> Bool
  | .node "flat-leaf" [_] [] => true
  | .node "flat-application" [_, _, arity, _] children =>
      arity == toString children.length && !children.isEmpty && go children
  | _ => false
where
  go : List Wire -> Bool
    | [] => true
    | h :: t => sourceShape h && go t

def pathParts : List Char -> List (List Char)
  | [] => [[]]
  | '/' :: cs => [] :: pathParts cs
  | c :: cs => match pathParts cs with
    | [] => [[c]]
    | h :: t => (c :: h) :: t

def spliceShape : Wire -> Bool
  | .node "splice" [path, outer, nested, position, _] [] =>
      (pathParts path.toList).all (fun p => natural (String.ofList p)) &&
        natural outer && natural nested && natural position
  | _ => false

def inputShape (tag : String) : Wire -> Bool
  | .node t [_] [] => t == tag
  | _ => false

def outputShape : Wire -> Bool
  | .node "trace-output" (_ :: fiber) [] => fiber.all natural
  | _ => false

def traceShape : Wire -> Bool
  | .node "container-trace" [_, _, ni, no, _] children =>
      match readNat ni, readNat no with
      | some i, some o => natural ni && natural no && children.length == i + o &&
          (children.take i).all (inputShape "trace-input") &&
          (children.drop i).all outputShape
      | _, _ => false
  | _ => false

structure FlatRecord where
  certificate : String
  profile : String
  operator : String
  path : String
  kind : String
  target : String
  left : String
  right : String
  owner : String
  source : Wire
  splices : List Wire
  trace : Wire
  deriving BEq, DecidableEq, ReflBEq, LawfulBEq

structure ContainerRecord where
  certificate : String
  profile : String
  operator : String
  path : String
  target : String
  left : String
  right : String
  owner : String
  inputs : List Wire
  trace : Wire
  deriving BEq, DecidableEq, ReflBEq, LawfulBEq

def encodeFlat (r : FlatRecord) : Wire :=
  .node "flat-construction"
    [r.certificate, r.profile, r.operator, r.path, r.kind, r.target, r.left, r.right, r.owner]
    [r.source, .node "splices" [] r.splices, r.trace]

def encodeContainer (r : ContainerRecord) : Wire :=
  .node "container-construction"
    [r.certificate, r.profile, r.operator, r.path, r.target, r.left, r.right, r.owner]
    [.node "input-occurrences" [] r.inputs, r.trace]

def decodeFlat : Wire -> Option FlatRecord
  | .node "flat-construction" [c, p, o, path, k, t, l, r, owner]
      [s, .node "splices" [] sp, tr] =>
      if sourceShape s && sp.all spliceShape && traceShape tr then
        some ⟨c, p, o, path, k, t, l, r, owner, s, sp, tr⟩ else none
  | _ => none

def decodeContainer : Wire -> Option ContainerRecord
  | .node "container-construction" [c, p, o, path, t, l, r, owner]
      [.node "input-occurrences" [] inputs, tr] =>
      if inputs.all (inputShape "input") && traceShape tr then
        some ⟨c, p, o, path, t, l, r, owner, inputs, tr⟩ else none
  | _ => none

theorem flat_decode_lossless (w : Wire) (r : FlatRecord) (h : decodeFlat w = some r) :
    encodeFlat r = w := by
  unfold decodeFlat at h
  split at h <;> simp_all
  rw [← h.2]
  rfl

theorem container_decode_lossless (w : Wire) (r : ContainerRecord)
    (h : decodeContainer w = some r) : encodeContainer r = w := by
  unfold decodeContainer at h
  split at h <;> simp_all
  rw [← h.2]
  rfl

theorem flat_decode_roundtrip (r : FlatRecord)
    (h : sourceShape r.source && r.splices.all spliceShape && traceShape r.trace = true) :
    decodeFlat (encodeFlat r) = some r := by
  cases r
  simp_all [encodeFlat, decodeFlat]

theorem container_decode_roundtrip (r : ContainerRecord)
    (h : r.inputs.all (inputShape "input") && traceShape r.trace = true) :
    decodeContainer (encodeContainer r) = some r := by
  cases r
  simp_all [encodeContainer, decodeContainer]

inductive Carrier where
  | seq | bag | set
  deriving BEq

def insertBy (le : Nat -> Nat -> Bool) (n : Nat) : List Nat -> List Nat
  | [] => [n]
  | h :: t => if le n h then n :: h :: t else h :: insertBy le n t

def sortBy (le : Nat -> Nat -> Bool) : List Nat -> List Nat
  | [] => []
  | h :: t => insertBy le h (sortBy le t)

def outputs (carrier : Carrier) (xs : List Nat) : List Nat :=
  match carrier with
  | .seq => xs
  | .bag => sortBy (· ≤ ·) xs
  | .set => (sortBy (· ≤ ·) xs).eraseDups

def fibers (carrier : Carrier) (xs : List Nat) : List (List Nat) :=
  match carrier with
  | .seq => (List.range xs.length).map (fun i => [i])
  | .bag => (sortBy (fun i j => xs[i]! ≤ xs[j]!) (List.range xs.length)).map (fun i => [i])
  | .set => (outputs .set xs).map (fun x => (List.range xs.length).filter (fun i => xs[i]! == x))

inductive Source where
  | leaf (identity : Nat)
  | app (children : List Source)
  deriving BEq

def leaves : Source -> List Nat
  | .leaf i => [i]
  | .app children => go children
where
  go : List Source -> List Nat
    | [] => []
    | h :: t => leaves h ++ go t

def sourceCode : Source -> String
  | .leaf i => toString i
  | .app cs => "[" ++ String.intercalate "," (go cs) ++ "]"
where
  go : List Source -> List String
    | [] => []
    | h :: t => sourceCode h :: go t

structure Environment where
  operator : String
  context : String
  schema : String
  term : Nat -> String
  sourceKey : Source -> String
  traceKey : Carrier -> List Nat -> String

def encodeSource (e : Environment) : Source -> Wire
  | .leaf i => leaf "flat-leaf" [e.term i]
  | .app children => .node "flat-application"
      [e.operator, e.context, toString children.length, e.sourceKey (.app children)] (go children)
where
  go : List Source -> List Wire
    | [] => []
    | h :: t => encodeSource e h :: go t

def encodePath (path : List Nat) : String := String.intercalate "/" (path.map toString)

def splices (e : Environment) (path : List Nat) : Source -> List Wire
  | .leaf _ => []
  | .app children => go children.length 0 children
where
  go (outer position : Nat) : List Source -> List Wire
    | [] => []
    | h :: t =>
        (match h with
          | .leaf _ => []
          | .app cs => [leaf "splice" [encodePath (path ++ [position]), toString outer,
              toString cs.length, toString position, e.sourceKey h]]) ++
        splices e (path ++ [position]) h ++ go outer (position + 1) t

def reconstructTrace (e : Environment) (carrier : Carrier) (xs : List Nat) : Wire :=
  .node "container-trace"
    [e.schema, e.context, toString xs.length, toString (outputs carrier xs).length, e.traceKey carrier xs]
    (xs.map (fun i => leaf "trace-input" [e.term i]) ++
      ((outputs carrier xs).zip (fibers carrier xs)).map (fun (i, fiber) =>
        leaf "trace-output" (e.term i :: fiber.map toString)))

def reconstructFlat (e : Environment) (carrier : Carrier) (s : Source) (bound : FlatRecord) : FlatRecord :=
  { bound with
    source := encodeSource e s
    splices := splices e [] s
    trace := reconstructTrace e carrier (leaves s) }

def reconstructContainer (e : Environment) (carrier : Carrier) (xs : List Nat)
    (bound : ContainerRecord) : ContainerRecord :=
  { bound with inputs := xs.map (fun i => leaf "input" [e.term i]), trace := reconstructTrace e carrier xs }

def acceptsFlat (expected : FlatRecord) (w : Wire) : Bool := decodeFlat w == some expected
def acceptsContainer (expected : ContainerRecord) (w : Wire) : Bool := decodeContainer w == some expected

theorem accepted_flat_complete (r : FlatRecord) (w : Wire)
    (h : sourceShape r.source && r.splices.all spliceShape && traceShape r.trace = true) :
    acceptsFlat r w = true <-> w = encodeFlat r := by
  constructor
  · intro ha
    exact (flat_decode_lossless w r (by simpa [acceptsFlat] using ha)).symm
  · intro hw
    rw [hw]
    simp [acceptsFlat, flat_decode_roundtrip r h]

theorem accepted_container_complete (r : ContainerRecord) (w : Wire)
    (h : r.inputs.all (inputShape "input") && traceShape r.trace = true) :
    acceptsContainer r w = true <-> w = encodeContainer r := by
  constructor
  · intro ha
    exact (container_decode_lossless w r (by simpa [acceptsContainer] using ha)).symm
  · intro hw
    rw [hw]
    simp [acceptsContainer, container_decode_roundtrip r h]

theorem changed_flat_field_rejects (r : FlatRecord) (w : Wire) (h : w ≠ encodeFlat r) :
    acceptsFlat r w = false := by
  cases ha : acceptsFlat r w with
  | false => rfl
  | true => exact False.elim (h (flat_decode_lossless w r (by simpa [acceptsFlat] using ha)).symm)

theorem changed_container_field_rejects (r : ContainerRecord) (w : Wire)
    (h : w ≠ encodeContainer r) : acceptsContainer r w = false := by
  cases ha : acceptsContainer r w with
  | false => rfl
  | true => exact False.elim (h (container_decode_lossless w r (by simpa [acceptsContainer] using ha)).symm)

theorem reconstructed_flat_source (e : Environment) (c : Carrier) (s : Source) (r : FlatRecord) :
    (reconstructFlat e c s r).source = encodeSource e s ∧
    (reconstructFlat e c s r).splices = splices e [] s ∧
    (reconstructFlat e c s r).trace = reconstructTrace e c (leaves s) := by
  exact ⟨rfl, rfl, rfl⟩

theorem reconstructed_container_occurrences (e : Environment) (c : Carrier) (xs : List Nat)
    (r : ContainerRecord) :
    (reconstructContainer e c xs r).inputs = xs.map (fun i => leaf "input" [e.term i]) ∧
    (reconstructContainer e c xs r).trace = reconstructTrace e c xs := by
  exact ⟨rfl, rfl⟩

theorem seq_exact_order_and_repeats (xs : List Nat) : outputs .seq xs = xs := rfl
theorem bag_exact_multiplicity_representation (xs : List Nat) :
    outputs .bag xs = sortBy (· ≤ ·) xs := rfl
theorem set_exact_quotient (xs : List Nat) :
    outputs .set xs = (outputs .bag xs).eraseDups := rfl

theorem insert_preserves_count (le : Nat -> Nat -> Bool) (n v : Nat) (xs : List Nat) :
    (insertBy le n xs).count v = (n :: xs).count v := by
  induction xs with
  | nil => rfl
  | cons h t ih =>
      simp only [insertBy]
      split <;> simp_all [List.count_cons, Nat.add_comm, Nat.add_left_comm]

theorem sort_preserves_count (le : Nat -> Nat -> Bool) (xs : List Nat) (v : Nat) :
    (sortBy le xs).count v = xs.count v := by
  induction xs with
  | nil => rfl
  | cons h t ih => simp [sortBy, insert_preserves_count, List.count_cons, ih]

theorem bag_preserves_every_multiplicity (xs : List Nat) (v : Nat) :
    (outputs .bag xs).count v = xs.count v := sort_preserves_count _ xs v

theorem singleton_fibers_flatten (xs : List Nat) :
    (xs.map (fun i => [i])).flatten = xs := by
  induction xs with
  | nil => rfl
  | cons h t ih => simp [ih]

theorem bag_fibers_cover_each_occurrence (xs : List Nat) (i : Nat) :
    (fibers .bag xs).flatten.count i = (List.range xs.length).count i := by
  simp only [fibers, singleton_fibers_flatten]
  exact sort_preserves_count _ _ _

theorem set_fiber_exact_indices (xs : List Nat) :
    fibers .set xs = (outputs .set xs).map (fun v =>
      (List.range xs.length).filter (fun i => xs[i]! == v)) := rfl

#print axioms wire_equality_exact
#print axioms flat_decode_lossless
#print axioms container_decode_lossless
#print axioms flat_decode_roundtrip
#print axioms container_decode_roundtrip
#print axioms accepted_flat_complete
#print axioms accepted_container_complete
#print axioms changed_flat_field_rejects
#print axioms changed_container_field_rejects
#print axioms reconstructed_flat_source
#print axioms reconstructed_container_occurrences
#print axioms seq_exact_order_and_repeats
#print axioms bag_exact_multiplicity_representation
#print axioms set_exact_quotient
#print axioms insert_preserves_count
#print axioms sort_preserves_count
#print axioms bag_preserves_every_multiplicity
#print axioms singleton_fibers_flatten
#print axioms bag_fibers_cover_each_occurrence
#print axioms set_fiber_exact_indices
end ACGN.FifthFive.FlatContainerRecords
