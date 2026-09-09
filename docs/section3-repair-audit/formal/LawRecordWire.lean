import Std

namespace ACGN.FifthFive.LawRecordWire

-- Scalar sequences keep kernel replay independent of repeated UTF-8 packing.
abbrev Text := List Char
def ofCodepoints (values : List Nat) : Text := values.map Char.ofNat

-- This codec starts at the decoded node boundary, not at arbitrary byte streams.
structure LawRecord where
  index : Text
  authority : Text
  operatorIdentity : Text
  runtimeType : Text
  exactType : Text
  path : Text
  law : Text
  theoryDigest : Text
  schemaId : Text
  schema : Text
  parameter : Text
  leftEndpoint : Text
  rightEndpoint : Text
  originKind : Text
  sourceArtifact : Text
  declarationId : Text
  ordinal : Text
  deriving DecidableEq

structure WireRecord where
  tag : Text
  scalars : List Text
  childCount : Nat
  deriving DecidableEq, Inhabited

def fields (r : LawRecord) : List Text :=
  [r.index, r.authority, r.operatorIdentity, r.runtimeType, r.exactType, r.path, r.law, r.theoryDigest, r.schemaId, r.schema, r.parameter, r.leftEndpoint, r.rightEndpoint, r.originKind, r.sourceArtifact, r.declarationId, r.ordinal]

def reconstruct : List Text -> Option LawRecord
  | [x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16] => some ⟨x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16⟩
  | _ => none

def encode (r : LawRecord) : WireRecord := ⟨"law-certificate".toList, fields r, 0⟩

def decode (w : WireRecord) : Option LawRecord :=
  if w.tag = "law-certificate".toList ∧ w.childCount = 0 then reconstruct w.scalars else none

def exact (r : LawRecord) (w : WireRecord) : Bool := decide (decode w = some r)

def utf16Length (s : Text) : Nat :=
  (s.map fun c => if c.toNat < 65536 then 1 else 2).sum

def frame (s : Text) : Text := (toString (utf16Length s)).toList ++ ":".toList ++ s

def stable (tag : Text) (scalars children : List Text) : Text :=
  frame tag ++ "[".toList ++ (toString scalars.length).toList ++ ":".toList ++ List.flatten (scalars.map frame) ++
    "]{".toList ++ (toString children.length).toList ++ ":".toList ++ List.flatten (children.map frame) ++ "}".toList

-- An entry is supplied by an independently admitted registry, never by decoding
-- the claimed record. Exact keys retain profile, result, element, carrier, policy.
structure ExpectedEntry where
  opcode : Text
  profileKey : Text
  resultKey : Text
  elementKey : Text
  carrier : Text
  quotient : Text
  arityKey : Text
  runtimeType : Text
  exactType : Text
  schemaId : Text
  path : Text
  law : Text
  family : Text
  ordinal : Text
  deriving DecidableEq, BEq

def registryVersion : Text := "alloy-container-law-theory-v3".toList
def registryDigest : Text := "b6479712e518b5dfc13f19866769f30ab81b49bd4bad508a175691fbb1d0633f".toList

def schemaKey (e : ExpectedEntry) : Text :=
  stable ("schema/".toList ++ e.carrier) [e.quotient]
    [e.arityKey, stable "schema/one".toList [] [e.elementKey]]

def parameterKey (e : ExpectedEntry) : Text :=
  stable "alloy-law-parameter-v1".toList [e.opcode, e.path, e.law, e.family]
    [e.profileKey, e.resultKey, schemaKey e]

def indexKey (e : ExpectedEntry) : Text :=
  stable "container-law-index-v2".toList
    ["ALLOY_PROFILE_THEORY".toList, "ALLOY/".toList ++ e.opcode, e.path, e.law, registryDigest]
    [e.profileKey, e.resultKey, schemaKey e, parameterKey e]

def endpoint (index side : Text) : Text :=
  stable "container-law-source-endpoint".toList [side] [index]

-- SHA-256 is supplied as an arbitrary function. No converse digest theorem.
def expectedRecord (hash : Text -> Text) (e : ExpectedEntry) : LawRecord :=
  ⟨indexKey e, "ALLOY_PROFILE_THEORY".toList, "ALLOY/".toList ++ e.opcode, e.runtimeType,
   e.exactType, e.path, e.law, registryDigest, e.schemaId, schemaKey e,
   parameterKey e, endpoint (indexKey e) "left".toList, endpoint (indexKey e) "right".toList,
   "SIGNATURE_CONTAINER_LAW".toList, registryVersion ++ "/".toList ++ registryDigest,
   "ALLOY/".toList ++ e.opcode ++ "@".toList ++ e.path ++ ":".toList ++ e.law ++ ":".toList ++ hash (parameterKey e),
   e.ordinal⟩

-- Categories are supplied by exact-type reconstruction; equality of relational
-- carriers is still equality of the complete structural keys, not categories.
structure RegistryShape where
  opcode : String
  resultClass : String
  elementClass : String
  sameType : Bool
  carrier : String
  arity : String
  flatPath : String
  modular : Bool
  deriving DecidableEq

def matrixAllowed (q : RegistryShape) : Bool :=
  let set := ["AND", "OR", "PLUS", "INTERSECT"].contains q.opcode
  let integer := ["IPLUS", "MUL"].contains q.opcode
  let fixed := ["EQUALS", "NOT_EQUALS", "IFF"].contains q.opcode
  let disjoint := q.opcode == "DISJOINT"
  let flat := set || (integer && q.modular)
  let types :=
    if q.opcode == "AND" || q.opcode == "OR" || q.opcode == "IFF" then
      q.resultClass == "bool" && q.elementClass == "bool"
    else if q.opcode == "PLUS" || q.opcode == "INTERSECT" then
      (q.resultClass == "int" || q.resultClass == "relation") && q.sameType
    else if integer then q.resultClass == "int" && q.elementClass == "int"
    else if disjoint then q.resultClass == "bool" && q.elementClass == "relation"
    else q.resultClass == "bool"
  (set || integer || fixed || disjoint) && types &&
    (q.carrier == if set then "SET" else "BAG") &&
    (q.arity == if flat || disjoint then "AT_LEAST:1" else "FINITE:2") &&
    (q.flatPath == if flat then "0/0" else "none")

def guardedAdmission (shape : RegistryShape) (registry : List LawRecord) (w : WireRecord) : Bool :=
  matrixAllowed shape && match decode w with
    | none => false
    | some r => decide (r ∈ registry)

def admitted (registry : List LawRecord) (w : WireRecord) : Bool :=
  match decode w with
  | none => false
  | some r => decide (r ∈ registry)

-- The supplied registry table is in canonical increasing index order. This
-- predicate checks the complete table, so no repeated, missing or extra entry
-- can be hidden by a successful per-record membership test.
def reconstructTable (ws : List WireRecord) : Option (List LawRecord) := ws.mapM decode

def utf16Units (s : Text) : List Nat := s.flatMap fun c =>
  let n := c.toNat
  if n < 65536 then [n] else
    [55296 + (n - 65536) / 1024, 56320 + (n - 65536) % 1024]

def unitsLess : List Nat -> List Nat -> Bool
  | [], [] => false
  | [], _ :: _ => true
  | _ :: _, [] => false
  | a :: xs, b :: ys => if a = b then unitsLess xs ys else decide (a < b)

def javaLess (a b : Text) : Bool := unitsLess (utf16Units a) (utf16Units b)

def increasing (rs : List LawRecord) : Bool :=
  match rs with
  | [] => true
  | [_] => true
  | a :: b :: rest => javaLess a.index b.index && increasing (b :: rest)

def admitTable (registry : List LawRecord) (ws : List WireRecord) : Bool :=
  increasing registry && decide (reconstructTable ws = some registry)

theorem seventeen_fields (r : LawRecord) : (fields r).length = 17 := rfl

theorem reconstruct_fields (r : LawRecord) : reconstruct (fields r) = some r := by
  cases r
  rfl

theorem reconstruct_some_iff (xs : List Text) (r : LawRecord) :
    reconstruct xs = some r ↔ xs = fields r := by
  constructor
  · intro h
    unfold reconstruct at h
    split at h
    · cases r
      simp_all [fields]
    · contradiction
  · intro h
    rw [h, reconstruct_fields]

theorem fields_injective (r s : LawRecord) : fields r = fields s ↔ r = s := by
  constructor
  · intro h
    have := congrArg reconstruct h
    simpa only [reconstruct_fields, Option.some.injEq] using this
  · intro h
    rw [h]

theorem exact_fields_iff (r s : LawRecord) :
    fields r = fields s ↔
    r.index = s.index ∧
    r.authority = s.authority ∧
    r.operatorIdentity = s.operatorIdentity ∧
    r.runtimeType = s.runtimeType ∧
    r.exactType = s.exactType ∧
    r.path = s.path ∧
    r.law = s.law ∧
    r.theoryDigest = s.theoryDigest ∧
    r.schemaId = s.schemaId ∧
    r.schema = s.schema ∧
    r.parameter = s.parameter ∧
    r.leftEndpoint = s.leftEndpoint ∧
    r.rightEndpoint = s.rightEndpoint ∧
    r.originKind = s.originKind ∧
    r.sourceArtifact = s.sourceArtifact ∧
    r.declarationId = s.declarationId ∧
    r.ordinal = s.ordinal := by
  cases r; cases s
  simp [fields]

theorem decode_encode (r : LawRecord) : decode (encode r) = some r := by
  unfold decode
  rw [if_pos ⟨rfl, rfl⟩]
  exact reconstruct_fields r

theorem encode_injective (r s : LawRecord) : encode r = encode s ↔ r = s := by
  constructor
  · intro h
    have := congrArg decode h
    simpa only [decode_encode, Option.some.injEq] using this
  · intro h
    rw [h]

theorem decode_some_iff (w : WireRecord) (r : LawRecord) :
    decode w = some r ↔ w = encode r := by
  constructor
  · intro h
    unfold decode at h
    split at h
    · rename_i condition
      have parsed := (reconstruct_some_iff w.scalars r).mp h
      cases w with
      | mk tag scalars children =>
        dsimp only at condition parsed
        rw [condition.1, parsed, condition.2]
        rfl
    · contradiction
  · intro h
    rw [h, decode_encode]

theorem exact_iff (r : LawRecord) (w : WireRecord) :
    exact r w = true ↔ w = encode r := by
  simp [exact, decode_some_iff]

theorem all_field_corruptions_reject (r s : LawRecord) (h : r ≠ s) :
    exact r (encode s) = false := by
  simp [exact, decode_encode, Ne.symm h]

theorem accepted_field (r : LawRecord) (w : WireRecord) (i : Nat)
    (h : exact r w = true) : w.scalars[i]? = (fields r)[i]? := by
  rw [(exact_iff r w).mp h]
  rfl

theorem malformed_arity_rejects (r : LawRecord) (w : WireRecord)
    (h : w.scalars.length ≠ 17) : exact r w = false := by
  apply Bool.eq_false_iff.mpr
  intro yes
  have eq := (exact_iff r w).mp yes
  subst w
  exact h (seventeen_fields r)

theorem admitted_iff (registry : List LawRecord) (w : WireRecord) :
    admitted registry w = true ↔ ∃ r ∈ registry, w = encode r := by
  unfold admitted
  split
  · rename_i h
    simp only [Bool.false_eq_true, false_iff]
    rintro ⟨r, _, eq⟩
    rw [eq, decode_encode] at h
    contradiction
  · rename_i r h
    simp only [decide_eq_true_eq]
    constructor
    · intro mem
      exact ⟨r, mem, (decode_some_iff w r).mp h⟩
    · rintro ⟨s, mem, eq⟩
      rw [eq, decode_encode] at h
      cases h
      exact mem

theorem registry_reconstruction_iff (hash : Text -> Text) (entries : List ExpectedEntry)
    (w : WireRecord) :
    admitted (entries.map (expectedRecord hash)) w = true ↔
      ∃ e ∈ entries, w = encode (expectedRecord hash e) := by
  simp only [admitted_iff, List.mem_map]
  constructor
  · rintro ⟨r, ⟨e, mem, eq⟩, hw⟩
    exact ⟨e, mem, eq ▸ hw⟩
  · rintro ⟨e, mem, hw⟩
    exact ⟨expectedRecord hash e, ⟨e, mem, rfl⟩, hw⟩

theorem recomputed_but_unregistered_rejects (registry : List LawRecord) (r : LawRecord)
    (h : r ∉ registry) : admitted registry (encode r) = false := by
  simp [admitted, decode_encode, h]

theorem registry_matrix_required (shape : RegistryShape) (registry : List LawRecord) (w : WireRecord)
    (h : guardedAdmission shape registry w = true) : matrixAllowed shape = true := by
  cases hm : matrixAllowed shape <;> simp_all [guardedAdmission]

theorem recomputed_outside_matrix_rejects (shape : RegistryShape) (registry : List LawRecord)
    (w : WireRecord) (h : matrixAllowed shape = false) : guardedAdmission shape registry w = false := by
  simp [guardedAdmission, h]

theorem table_roundtrip (rs : List LawRecord) :
    reconstructTable (rs.map encode) = some rs := by
  induction rs with
  | nil => rfl
  | cons r rs ih => simp_all [reconstructTable, List.mapM_cons, decode_encode]

theorem reconstruct_table_iff (ws : List WireRecord) (rs : List LawRecord) :
    reconstructTable ws = some rs ↔ ws = rs.map encode := by
  induction ws generalizing rs with
  | nil => cases rs <;> simp [reconstructTable]
  | cons w ws ih =>
    cases rs with
    | nil =>
      simp [reconstructTable, List.mapM_cons]
      cases decode w <;> cases ws.mapM decode <;> simp
    | cons r rs =>
      simp only [reconstructTable, List.mapM_cons, List.map_cons, List.cons.injEq]
      change ((decode w).bind fun a => (reconstructTable ws).bind fun b => some (a :: b)) =
        some (r :: rs) ↔ w = encode r ∧ ws = rs.map encode
      have he (x : LawRecord) : w = encode x ↔ decode w = some x := (decode_some_iff w x).symm
      simp only [he, ← ih]
      cases hw : decode w <;> cases ht : reconstructTable ws <;> simp

theorem table_admission_iff (registry : List LawRecord) (ws : List WireRecord) :
    admitTable registry ws = true ↔ increasing registry = true ∧ ws = registry.map encode := by
  simp [admitTable, reconstruct_table_iff]

theorem complete_table_admitted (rs : List LawRecord) (h : increasing rs = true) :
    admitTable rs (rs.map encode) = true := by
  simp [admitTable, h, table_roundtrip]

theorem table_change_rejects (rs : List LawRecord) (ws : List WireRecord)
    (h : ws ≠ rs.map encode) : admitTable rs ws = false := by
  apply Bool.eq_false_iff.mpr
  intro yes
  exact h ((table_admission_iff rs ws).mp yes).2

theorem complete_table_cardinality (rs : List LawRecord) (ws : List WireRecord)
    (h : admitTable rs ws = true) : ws.length = rs.length := by
  rw [((table_admission_iff rs ws).mp h).2, List.length_map]

theorem exact_index_preimage (hash : Text -> Text) (e : ExpectedEntry) :
    (expectedRecord hash e).index = stable "container-law-index-v2".toList
      ["ALLOY_PROFILE_THEORY".toList, "ALLOY/".toList ++ e.opcode, e.path, e.law, registryDigest]
      [e.profileKey, e.resultKey, schemaKey e, parameterKey e] := rfl

theorem exact_endpoints (hash : Text -> Text) (e : ExpectedEntry) :
    (expectedRecord hash e).leftEndpoint = endpoint (indexKey e) "left".toList ∧
    (expectedRecord hash e).rightEndpoint = endpoint (indexKey e) "right".toList := ⟨rfl, rfl⟩

theorem equal_preimage_equal_digest (hash : Text -> Text) (a b : Text)
    (h : a = b) : hash a = hash b := congrArg hash h

theorem utf16_boundary_order :
    javaLess ([Char.ofNat 65536]) ([Char.ofNat 57344]) = true ∧
    javaLess ([Char.ofNat 57344]) ([Char.ofNat 65536]) = false ∧
    javaLess "prefix".toList "prefix-more".toList = true ∧ javaLess "same".toList "same".toList = false := by decide +kernel

#print axioms seventeen_fields
#print axioms reconstruct_fields
#print axioms reconstruct_some_iff
#print axioms fields_injective
#print axioms exact_fields_iff
#print axioms decode_encode
#print axioms encode_injective
#print axioms decode_some_iff
#print axioms exact_iff
#print axioms all_field_corruptions_reject
#print axioms accepted_field
#print axioms malformed_arity_rejects
#print axioms admitted_iff
#print axioms registry_reconstruction_iff
#print axioms recomputed_but_unregistered_rejects
#print axioms registry_matrix_required
#print axioms recomputed_outside_matrix_rejects
#print axioms table_roundtrip
#print axioms reconstruct_table_iff
#print axioms table_admission_iff
#print axioms complete_table_admitted
#print axioms table_change_rejects
#print axioms complete_table_cardinality
#print axioms exact_index_preimage
#print axioms exact_endpoints
#print axioms equal_preimage_equal_digest
#print axioms utf16_boundary_order

end ACGN.FifthFive.LawRecordWire
