import Std

namespace ReceiptStructuralSharing

inductive Key where
  | node : String → List String → List Key → Key

structure Row where
  tag : String
  scalars : List String
  children : List Nat
  deriving DecidableEq

abbrev Table := Nat → Option Key

def resolve (table : Table) : List Nat → Option (List Key)
  | [] => some []
  | i :: is => do
    let k ← table i
    let ks ← resolve table is
    pure (k :: ks)

def decode (table : Table) (row : Row) : Option Key :=
  (resolve table row.children).map (Key.node row.tag row.scalars)

inductive Links (table : Table) : List Nat → List Key → Prop
  | nil : Links table [] []
  | cons : table i = some k → Links table is ks → Links table (i :: is) (k :: ks)

theorem resolve_links (h : Links table ids keys) : resolve table ids = some keys := by
  induction h with
  | nil => rfl
  | cons hit _ ih => simp [resolve, hit, ih]

theorem row_roundtrip (h : Links table ids keys) :
    decode table ⟨tag, scalars, ids⟩ = some (.node tag scalars keys) := by
  simp [decode, resolve_links h]

def put (table : Table) (i : Nat) (key : Key) : Table :=
  fun j => if j = i then some key else table j

theorem put_hit : put table i key i = some key := by simp [put]
theorem put_other (h : j ≠ i) : put table i key j = table j := by simp [put, h]

theorem put_preserves_hit (free : table i = none) (old : table j = some key) :
    put table i added j = some key := by
  have h : j ≠ i := by intro same; subst j; rw [free] at old; contradiction
  simpa [put, h] using old

theorem put_preserves_links (free : table i = none) (old : Links table ids keys) :
    Links (put table i added) ids keys := by
  induction old with
  | nil => exact .nil
  | cons hit _ ih => exact .cons (put_preserves_hit free hit) ih

-- Cache entries are authenticated exact keys, not hashes treated as equality.
structure CacheHit (table : Table) (key : Key) where
  index : Nat
  exactKey : table index = some key

theorem reuse_exact (hit : CacheHit table key) : table hit.index = some key := hit.exactKey

theorem miss_materializes_exact (free : table next = none)
    (children : Links table ids keys) :
    decode table ⟨tag, scalars, ids⟩ = some (.node tag scalars keys) ∧
    put table next (.node tag scalars keys) next = some (.node tag scalars keys) ∧
    Links (put table next (.node tag scalars keys)) ids keys :=
  ⟨row_roundtrip children, put_hit, put_preserves_links free children⟩

theorem ordered_roots_preserved (free : table next = none) (roots : Links table ids keys) :
    resolve (put table next added) ids = some keys :=
  resolve_links (put_preserves_links free roots)

theorem wrong_cached_key_rejected (table : Table) (hit : table i = some old) (different : old ≠ requested) :
    ¬ table i = some requested := by
  intro forged
  exact different (Option.some.inj (hit.symm.trans forged))

-- The model charges an expansion only on an exact-cache miss. Java must really
-- perform the cache lookup before recursive expansion and retain separate CPU,
-- stack, service memory, output-size and timeout enforcement.
inductive Event where
  | hit | expand
  deriving DecidableEq
def expansions : List Event → Nat
  | [] => 0
  | .hit :: es => expansions es
  | .expand :: es => 1 + expansions es

theorem cache_hit_cost (es : List Event) : expansions (.hit :: es) = expansions es := rfl
theorem expansion_cost (es : List Event) : expansions (.expand :: es) = 1 + expansions es := rfl
theorem expansions_append (a b : List Event) :
    expansions (a ++ b) = expansions a + expansions b := by
  induction a with
  | nil => simp [expansions]
  | cons a as ih => cases a <;> simp [expansions, ih, Nat.add_assoc]

-- A producer history records actual materializations, not only the final size.
-- Each expand allocates one fresh row; a validated hit allocates none.
inductive History : Nat → List Event → Nat → Prop
  | done : History n [] n
  | hit : History n es final → History n (.hit :: es) final
  | expand : History (n + 1) es final → History n (.expand :: es) final

theorem history_exact_expansions (h : History start events final) :
    final = start + expansions events := by
  induction h with
  | done => simp [expansions]
  | hit _ ih => simpa [expansions] using ih
  | expand _ ih => simpa [expansions, Nat.add_assoc] using ih

theorem materialization_bound (h : History start events final) (cap : final ≤ limit) :
    expansions events ≤ limit := by
  have same := history_exact_expansions h
  omega

theorem missing_reference_fails (table : Table) (absent : table i = none) :
    resolve table (i :: rest) = none := by simp [resolve, absent]

theorem duplicate_root_order_retained (hit : table i = some key) :
    resolve table [i, i] = some [key, key] := by simp [resolve, hit]

structure Budget where
  depth : Nat
  visits : Nat
  units : Nat
  bytes : Nat
  deriving DecidableEq
def allowed (b : Budget) : Bool :=
  decide (b.depth ≤ 128 ∧ b.visits ≤ 120000 ∧ b.units ≤ 120000 ∧ b.bytes ≤ 4000000)

-- Extracted event36: actual old object visits and lossless distinct-shape census.
-- This is a counter/census witness, not an executed Java replacement receipt.
def event36Old : Budget := ⟨42, 183115, 22440, 105684⟩
def event36Shared : Budget := ⟨42, 3654, 22440, 105684⟩
theorem old_event36_rejected : allowed event36Old = false := by decide
theorem shared_event36_census_fits : allowed event36Shared = true := by decide
theorem real_depth_violation_rejected : allowed ⟨129, 1, 1, 1⟩ = false := by decide
theorem real_visit_violation_rejected : allowed ⟨1, 120001, 1, 1⟩ = false := by decide
theorem real_unit_violation_rejected : allowed ⟨1, 1, 120001, 1⟩ = false := by decide
theorem real_byte_violation_rejected : allowed ⟨1, 1, 1, 4000001⟩ = false := by decide

def leaf : Key := .node "typed-variable" ["owner:0", "slot:0", "Person"] []
def empty : Table := fun _ => none
def one : Table := put empty 0 leaf
theorem repeated_edges_retained :
    decode one ⟨"pair", [], [0, 0]⟩ = some (.node "pair" [] [leaf, leaf]) := by
  simp [decode, resolve, one, put]
theorem missing_reference_rejected : decode one ⟨"pair", [], [0, 1]⟩ = none := by
  simp [decode, resolve, one, put, empty]
theorem forward_or_self_reference_rejected :
    decode empty ⟨"cycle", [], [0]⟩ = none := by simp [decode, resolve, empty]
theorem changed_payload_not_equal :
    Key.node "typed-variable" ["owner:1", "slot:0", "Person"] [] ≠ leaf := by
  intro h
  have bad := congrArg (fun k => match k with | .node _ xs _ => xs) h
  simp [leaf] at bad
theorem truncating_multiplicity_not_equal :
    Key.node "pair" [] [leaf] ≠ Key.node "pair" [] [leaf, leaf] := by
  intro h
  have bad := congrArg (fun k => match k with | .node _ _ xs => xs.length) h
  simp at bad

end ReceiptStructuralSharing
