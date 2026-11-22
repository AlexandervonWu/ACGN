import P411ShapeIdentity

namespace ACGN.Eleventh.P407

structure Key where
  owner : Nat
  shape : Nat
  deriving DecidableEq, BEq, Repr

inductive Container where | seq | bag | set | bind | block deriving DecidableEq

-- append represents ordered concatenation of the finite children of an e-node or container.
inductive Ports where
  | nil | slot | invoke (child : Nat)
  | append (left right : Ports)
  | nested (container : Container) (inside : Ports)
  deriving DecidableEq

def children : Ports → List Nat
  | .nil | .slot => []
  | .invoke c => [c]
  | .append l r => children l ++ children r
  | .nested _ p => children p

def Occurs (c : Nat) : Ports → Prop
  | .nil | .slot => False
  | .invoke d => c = d
  | .append l r => Occurs c l ∨ Occurs c r
  | .nested _ p => Occurs c p

theorem collect_exact (p : Ports) (c : Nat) : c ∈ children p ↔ Occurs c p := by
  induction p <;> simp_all [children, Occurs]

abbrev Live := Key → Bool
abbrev Uses := Nat → Key → Bool

structure Index where
  buckets : Nat → Nat → Bool
  uses : Uses

def Exact (ports : Nat → Ports) (live : Live) (i : Index) : Prop :=
  (∀ shape owner, i.buckets shape owner = live ⟨owner,shape⟩) ∧
  (∀ c k, i.uses c k = true ↔ live k = true ∧ Occurs c (ports k.shape))

def setKey (v : Bool) (k : Key) (old : Live) (q : Key) : Bool :=
  if q = k then v else old q

def setUse (v : Bool) (k : Key) (old : Uses) (d c : Nat) (q : Key) : Bool :=
  if c = d ∧ q = k then v else old c q

def updateUses (v : Bool) (k : Key) (old : Uses) (ds : List Nat) : Uses :=
  ds.foldl (setUse v k) old

theorem updateUses_lookup (v : Bool) (k q : Key) (ds : List Nat) (c : Nat) (u : Uses) :
    updateUses v k u ds c q = (if q = k ∧ c ∈ ds then v else u c q) := by
  induction ds generalizing u with
  | nil => simp [updateUses]
  | cons d ds ih =>
    change updateUses v k (setUse v k u d) ds c q = _
    rw [ih]
    by_cases same : q = k <;> by_cases here : c = d <;> by_cases later : c ∈ ds <;>
      simp [setUse,same,here,later]

def changeIndex (ports : Nat → Ports) (v : Bool) (k : Key) (i : Index) : Index :=
  { buckets := fun s o => if (⟨o,s⟩ : Key) = k then v else i.buckets s o
    uses := updateUses v k i.uses (children (ports k.shape)) }

theorem write_key_exact (ports : Nat → Ports) (v : Bool) (k : Key) (live : Live) (i : Index)
    (before : Exact ports live i) : Exact ports (setKey v k live) (changeIndex ports v k i) := by
  constructor
  · intro s o
    simp [changeIndex,setKey,before.1]
  · intro c q
    change updateUses v k i.uses (children (ports k.shape)) c q = true ↔ _
    rw [updateUses_lookup]
    by_cases same : q = k
    · subst q
      by_cases found : c ∈ children (ports k.shape)
      · have occurs := (collect_exact _ _).mp found
        simp [setKey,found,occurs]
      · simp [setKey,found,before.2]
        intro occurs
        exact False.elim (found ((collect_exact _ _).mpr occurs))
    · simp [setKey,same,before.2]

theorem same_shape_other_owner_untouched (ports : Nat → Ports) (v : Bool) (i : Index)
    (shape a b c : Nat) (distinct : a ≠ b) :
    (changeIndex ports v ⟨a,shape⟩ i).buckets shape b = i.buckets shape b ∧
    (changeIndex ports v ⟨a,shape⟩ i).uses c ⟨b,shape⟩ = i.uses c ⟨b,shape⟩ := by
  simp [changeIndex,Ne.symm distinct,updateUses_lookup]

def vacant : Index := ⟨fun _ _ => false,fun _ _ => false⟩
theorem initial_exact (ports : Nat → Ports) : Exact ports (fun _ => false) vacant := by
  simp [Exact,vacant]

structure Edit where
  value : Bool
  key : Key

def applyAll (ports : Nat → Ports) (edits : List Edit) (i : Index) : Index :=
  edits.foldl (fun x e => changeIndex ports e.value e.key x) i
def liveAfter (edits : List Edit) (live : Live) : Live :=
  edits.foldl (fun x e => setKey e.value e.key x) live

theorem finite_updates_exact (ports : Nat → Ports) (edits : List Edit) (live : Live) (i : Index)
    (before : Exact ports live i) : Exact ports (liveAfter edits live) (applyAll ports edits i) := by
  induction edits generalizing live i with
  | nil => exact before
  | cons head rest ih => exact ih _ _ (write_key_exact _ _ _ _ _ before)

theorem stored_buckets_and_reverse_uses (ports : Nat → Ports) (edits : List Edit) (k : Key) (c : Nat) :
    let i := applyAll ports edits vacant
    let present := liveAfter edits (fun _ => false) k
    i.buckets k.shape k.owner = present ∧
      (i.uses c k = true ↔ present = true ∧ Occurs c (ports k.shape)) := by
  have e := finite_updates_exact ports edits (fun _ => false) vacant (initial_exact ports)
  exact ⟨e.1 _ _, e.2 _ _⟩

theorem two_owners_visible (ports : Nat → Ports) (live : Live) (i : Index)
    (exact : Exact ports live i) (c shape a b : Nat)
    (left : live ⟨a,shape⟩ = true) (right : live ⟨b,shape⟩ = true) (child : Occurs c (ports shape)) :
    i.buckets shape a = true ∧ i.buckets shape b = true ∧
      i.uses c ⟨a,shape⟩ = true ∧ i.uses c ⟨b,shape⟩ = true := by
  exact ⟨(exact.1 _ _).trans left,(exact.1 _ _).trans right,
         (exact.2 _ _).mpr ⟨left,child⟩,(exact.2 _ _).mpr ⟨right,child⟩⟩

theorem retiring_one_owner (ports : Nat → Ports) (live : Live) (i : Index)
    (exact : Exact ports live i) (s a b c : Nat) (siblings : a ≠ b)
    (retained : live ⟨b,s⟩ = true) (child : Occurs c (ports s)) :
    let next := changeIndex ports false ⟨a,s⟩ i
    next.buckets s a = false ∧ next.buckets s b = true ∧
      next.uses c ⟨a,s⟩ = false ∧ next.uses c ⟨b,s⟩ = true := by
  have found := (collect_exact _ _).mpr child
  have other := same_shape_other_owner_untouched ports false i s a b c siblings
  exact ⟨by simp [changeIndex], other.1.trans ((exact.1 _ _).trans retained),
         by simp [changeIndex,updateUses_lookup,found],
         other.2.trans ((exact.2 _ _).mpr ⟨retained,child⟩)⟩

open ACGN.Eighth.P411 in
theorem distinct_owner_distinct_wire_preimage (a b term : Bytes)
    (ha : Fits (a,term)) (hb : Fits (b,term)) (distinct : a ≠ b) :
    shapeBytes (a,term) ≠ shapeBytes (b,term) :=
  fun same => distinct (congrArg Prod.fst (shape_frame_injective ha hb same))

-- Each row is derived from the selected bound map receiver, key argument and
-- mutating call in Java. Pair construction uses the ordered (owner,shape) record.
inductive Op where
  | hash (v : Bool) | use (v : Bool)
  deriving DecidableEq, BEq

def readOp : String → Option Op
  | "attach hash shape owner" => some (.hash true)
  | "attach use child key" => some (.use true)
  | "retire hash shape owner" => some (.hash false)
  | "retire use child key" => some (.use false)
  | _ => none

def expectedProgram : List Op := [.hash true,.use true,.hash false,.use false]

def opValue : Op → Bool | .hash v | .use v => v

def executeOp (ports : Nat → Ports) (k : Key) (i : Index) : Op → Index
  | .hash v => { i with buckets := fun s o => if (⟨o,s⟩ : Key) = k then v else i.buckets s o }
  | .use v => { i with uses := updateUses v k i.uses (children (ports k.shape)) }

def executeEdit (program : List Op) (ports : Nat → Ports) (i : Index) (e : Edit) : Index :=
  (program.filter fun op => opValue op == e.value).foldl (executeOp ports e.key) i

theorem compiled_pair_operations (ports : Nat → Ports) (v : Bool) (k : Key) (i : Index) :
    executeEdit expectedProgram ports i ⟨v,k⟩ = changeIndex ports v k i := by
  cases v <;> rfl

theorem compiled_trace_exact {lines : List String} (decoded : lines.mapM readOp = some expectedProgram)
    (ports : Nat → Ports) (edits : List Edit) (live : Live) (i : Index) (start : Exact ports live i) :
    (lines.mapM readOp).map (fun prog => edits.foldl (executeEdit prog ports) i) =
       some (applyAll ports edits i) ∧ Exact ports (liveAfter edits live) (applyAll ports edits i) := by
  constructor
  · rw [decoded]
    have step : executeEdit expectedProgram ports =
        (fun state e => changeIndex ports e.value e.key state) := by
      funext state e
      exact compiled_pair_operations ports e.value e.key state
    simp [applyAll,step]
  · exact finite_updates_exact ports edits live i start

open ACGN.Eighth.P411 in
theorem accepted_wire_id_separates_owners {D} [DecidableEq D] {hash : Bytes → D} {s t : Registry D}
    {pairs : List Shape} {a b term : Bytes} (done_ : run hash s pairs = some t)
    (left : (a,term) ∈ pairs) (right : (b,term) ∈ pairs) (distinct : a ≠ b) :
    hash (shapeBytes (a,term)) ≠ hash (shapeBytes (b,term)) :=
  fun equal => distinct (congrArg Prod.fst (observed_digest_nonaliasing done_ left right equal))

open ACGN.Eighth.P411 in
theorem replayed_wire_reverse_use_iff {D} [DecidableEq D] {hash : Bytes → D} {s t : Registry D}
    {pairs : List Shape} {query : Shape} (accepted : run hash s pairs = some t)
    (registered : query ∈ pairs) (references : Bytes → Nat → Prop) (child : Nat) :
    (∃ record ∈ pairs, hash (shapeBytes record) = hash (shapeBytes query) ∧ references record.2 child)
      ↔ references query.2 child := by
  constructor
  · rintro ⟨record, present, equal, uses⟩
    have same := observed_digest_nonaliasing accepted present registered equal
    simpa [same] using uses
  · exact fun uses => ⟨query, registered, rfl, uses⟩

theorem hash_and_reverse_edits_commute (ports : Nat → Ports) (k : Key) (i : Index) (v : Bool) :
    executeOp ports k (executeOp ports k i (.hash v)) (.use v) =
      executeOp ports k (executeOp ports k i (.use v)) (.hash v) := rfl

#print axioms replayed_wire_reverse_use_iff
#print axioms hash_and_reverse_edits_commute
#print axioms compiled_pair_operations
#print axioms compiled_trace_exact
#print axioms accepted_wire_id_separates_owners
#print axioms collect_exact
#print axioms updateUses_lookup
#print axioms write_key_exact
#print axioms same_shape_other_owner_untouched
#print axioms initial_exact
#print axioms finite_updates_exact
#print axioms stored_buckets_and_reverse_uses
#print axioms two_owners_visible
#print axioms retiring_one_owner
#print axioms distinct_owner_distinct_wire_preimage

end ACGN.Eleventh.P407
