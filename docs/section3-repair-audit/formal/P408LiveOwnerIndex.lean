import Init

namespace ACGN.Tenth.P408

-- Identifiers represent exact Java comparator-equivalence classes for shapes
-- and e-class ids. An absent map key differs from an explicitly empty bucket.
structure Row where
  owner : Nat
  leader : Bool
  shapes : List Nat
  deriving DecidableEq

abbrev Bucket := Nat → Bool
abbrev Index := Nat → Option Bucket

def empty : Index := fun _ => none
def present (i : Index) (s : Nat) : Bool := (i s).isSome
def owns (i : Index) (s o : Nat) : Bool := (i s).elim false (· o)

def put (i : Index) (shape owner : Nat) : Index :=
  fun s => if s = shape then some (fun o => decide (o = owner) || owns i s o) else i s

theorem present_put (i : Index) (s o q : Nat) :
    present (put i s o) q = true ↔ present i q = true ∨ q = s := by
  by_cases h : q = s <;> simp [present,put,h]

theorem owns_put (i : Index) (s o q a : Nat) :
    owns (put i s o) q a = true ↔ owns i q a = true ∨ (q = s ∧ a = o) := by
  by_cases h : q = s <;> simp [owns,put,h,or_comm]

def addShapes (i : Index) (r : Row) : Index := r.shapes.foldl (fun v s => put v s r.owner) i
def visit (i : Index) (r : Row) : Index := if r.leader then addShapes i r else i

theorem present_shapes (ss : List Nat) (i : Index) (o q : Nat) :
    present (ss.foldl (fun v s => put v s o) i) q = true ↔ present i q = true ∨ q ∈ ss := by
  induction ss generalizing i with
  | nil => simp
  | cons h t ih => simp [List.foldl_cons,ih,present_put,or_assoc]

theorem owns_shapes (ss : List Nat) (i : Index) (o q a : Nat) :
    owns (ss.foldl (fun v s => put v s o) i) q a = true ↔ owns i q a = true ∨ (q ∈ ss ∧ a = o) := by
  induction ss generalizing i with
  | nil => simp
  | cons h t ih => simp [List.foldl_cons,ih,owns_put,or_and_right,or_assoc]

def liveShape (r : Row) (s : Nat) : Prop := r.leader = true ∧ s ∈ r.shapes

theorem present_visit (i : Index) (r : Row) (s : Nat) :
    present (visit i r) s = true ↔ present i s = true ∨ liveShape r s := by
  cases h : r.leader <;> simp [visit,h,liveShape,addShapes,present_shapes]

theorem owns_visit (i : Index) (r : Row) (s o : Nat) :
    owns (visit i r) s o = true ↔ owns i s o = true ∨ (liveShape r s ∧ o = r.owner) := by
  cases h : r.leader <;> simp [visit,h,liveShape,addShapes,owns_shapes]

theorem present_fold (rows : List Row) (i : Index) (s : Nat) :
    present (rows.foldl visit i) s = true ↔ present i s = true ∨ ∃ r ∈ rows, liveShape r s := by
  induction rows generalizing i with
  | nil => simp
  | cons r rs ih => simp [List.foldl_cons,ih,present_visit,or_assoc]

theorem owns_fold (rows : List Row) (i : Index) (s o : Nat) :
    owns (rows.foldl visit i) s o = true ↔ owns i s o = true ∨ ∃ r ∈ rows, liveShape r s ∧ o = r.owner := by
  induction rows generalizing i with
  | nil => simp
  | cons r rs ih => simp [List.foldl_cons,ih,owns_visit,or_assoc]

def Exact (rows : List Row) (i : Index) : Prop :=
  (∀ s, present i s = true ↔ ∃ r ∈ rows, liveShape r s) ∧
  (∀ s o, owns i s o = true ↔ ∃ r ∈ rows, liveShape r s ∧ o = r.owner)

theorem rebuilt_exact (rows : List Row) : Exact rows (rows.foldl visit empty) := by
  constructor
  · intro s
    rw [present_fold]
    simp [present,empty]
  · intro s o
    rw [owns_fold]
    simp [owns,empty]

theorem every_published_bucket_has_owner {rows : List Row} {i : Index} (h : Exact rows i)
    {s : Nat} (key : present i s = true) : ∃ o, owns i s o = true := by
  obtain ⟨r,hr,hs⟩ := (h.1 s).mp key
  exact ⟨r.owner,(h.2 s r.owner).mpr ⟨r,hr,hs,rfl⟩⟩

-- Java map equality checks both the domain of the outer map and the set
-- members for every key. The independently built expected table has no
-- explicitly empty buckets.
def MapEquivalent (a b : Index) : Prop :=
  (∀ s, present a s = present b s) ∧ (∀ s o, owns a s o = owns b s o)

theorem expected_map_test (rows : List Row) (actual : Index) :
    MapEquivalent actual (rows.foldl visit empty) ↔ Exact rows actual := by
  have h := rebuilt_exact rows
  constructor
  · rintro ⟨keys,members⟩
    exact ⟨fun s => by rw [keys s]; exact h.1 s,
           fun s o => by rw [members s o]; exact h.2 s o⟩
  · intro a
    exact ⟨fun s => Bool.eq_iff_iff.mpr ((a.1 s).trans (h.1 s).symm),
           fun s o => Bool.eq_iff_iff.mpr ((a.2 s o).trans (h.2 s o).symm)⟩

-- The dirty queue/collision loop may produce any later collection of records.
-- Reconstruction uses this final collection. It is never assumed to preserve
-- the former classes, shapes, leader assignment or index.
inductive Op where | check | clear | scan | publish deriving DecidableEq, BEq
structure Machine where
  index : Index
  quiescent : Bool

noncomputable def step (rows : List Row) (m : Machine) : Op → Option Machine := by
  classical
  exact fun
    | .check => if MapEquivalent m.index (rows.foldl visit empty) then some m else none
    | .clear => some { m with index := empty }
    | .scan => some { m with index := rows.foldl visit m.index }
    | .publish => some { m with quiescent := true }

noncomputable def execute (rows : List Row) (ops : List Op) (m : Machine) : Option Machine :=
  ops.foldlM (step rows) m

-- The outer clear makes a missing inner reconstruction observable to the
-- subsequent map equality guard. The helper also resets its own index.
def production : List Op := [.check,.clear,.clear,.scan,.check,.publish]

attribute [local instance] Classical.propDecidable

theorem production_exact (rows : List Row) (before : Index) :
    execute rows production ⟨before,false⟩ =
    (if Exact rows before then some (Machine.mk (rows.foldl visit empty) true) else none) := by
  classical
  by_cases h : Exact rows before <;> simp [execute,production,step,expected_map_test,h,rebuilt_exact]

theorem observed_owners_after_restriction (rows : List Row) (before : Index) (after : Machine)
    (successful : execute rows production ⟨before,false⟩ = some after) :
    after.quiescent = true ∧ Exact rows after.index := by
  classical
  rw [production_exact] at successful
  split at successful
  · cases Option.some.inj successful
    exact ⟨rfl,rebuilt_exact rows⟩
  · contradiction

theorem missing_scan_cannot_publish (rows : List Row) (before : Index)
    (nonempty : ∃ r ∈ rows, ∃ s, liveShape r s) :
    execute rows [.check,.clear,.check,.publish] ⟨before,false⟩ = none := by
  classical
  obtain ⟨r,hr,s,hs⟩ := nonempty
  have bad : ¬ Exact rows empty := fun h => by
    have := (h.1 s).mpr ⟨r,hr,hs⟩
    simp [empty,present] at this
  by_cases h : Exact rows before <;> simp [execute,step,expected_map_test,h,bad]

theorem absent_retired_shape (rows : List Row) (q o : Nat)
    (absent : ∀ r ∈ rows, liveShape r q → o ≠ r.owner) :
    owns (rows.foldl visit empty) q o = false := by
  apply Bool.eq_false_iff.mpr
  intro h
  obtain ⟨r,hr,hs,ho⟩ := ((rebuilt_exact rows).2 q o).mp h
  exact absent r hr hs ho

def readProgram (commands : List String) : Option (List Op) := commands.mapM fun c =>
  match c with
  | "validate" => some .check
  | "clear-index" => some .clear
  | "visit-live-owners" => some .scan
  | "publish-quiescent" => some .publish
  | _ => none

theorem source_program_publishes_exact (commands : List String) (rows : List Row)
    (before : Index) (after : Machine) (decoded : readProgram commands = some production)
    (success : (readProgram commands).bind (fun ops => execute rows ops ⟨before,false⟩) = some after) :
    after.quiescent = true ∧ Exact rows after.index := by
  rw [decoded] at success
  exact observed_owners_after_restriction rows before after success

-- Successful restriction marks the graph dirty before any normal client
-- observation. A failed rebuild has no successful publication, including
-- failure after the temporary status assignment in the checked try block.
def restricted (m : Machine) : Machine := {m with quiescent := false}

def publicBuckets (m : Machine) : Option Index :=
  if m.quiescent then some m.index else none

theorem restrict_blocks_observation (m : Machine) : publicBuckets (restricted m) = none := rfl

theorem restricted_rebuild_observation {records : List Row} {before after : Machine}
    (h : execute records production (restricted before) = some after) :
    publicBuckets after = some after.index ∧ Exact records after.index := by
  have a := observed_owners_after_restriction records before.index after h
  exact ⟨by simp [publicBuckets,a.1],a.2⟩

-- The work queue and reconciliation can change every class and parent. Their
-- final rows and the incremental index they leave behind are independently
-- quantified. An exceptional return exposes no ordinary hash observation.
inductive Completion where
  | deferred
  | reconciled (rows : List Row) (incremental : Index)

noncomputable def completionView : Completion → Option Index
  | .deferred => none
  | .reconciled rows incremental =>
    (execute rows production ⟨incremental,false⟩).bind publicBuckets

theorem completed_view (rows : List Row) (incremental : Index) :
    completionView (.reconciled rows incremental) =
    (if Exact rows incremental then some (rows.foldl visit empty) else none) := by
  classical
  simp only [completionView,production_exact]
  split <;> rfl

theorem every_completed_view_is_live {ending : Completion} {visible : Index}
    (readable : completionView ending = some visible) :
    ∃ rows incremental, ending = .reconciled rows incremental ∧ Exact rows visible := by
  cases ending with
  | deferred => cases readable
  | reconciled rows incremental =>
    refine ⟨rows,incremental,rfl,?_⟩
    rw [completed_view] at readable
    split at readable
    · cases Option.some.inj readable
      exact rebuilt_exact rows
    · contradiction

#print axioms completed_view
#print axioms every_completed_view_is_live
#print axioms expected_map_test
#print axioms restrict_blocks_observation
#print axioms restricted_rebuild_observation
#print axioms present_put
#print axioms owns_put
#print axioms present_shapes
#print axioms owns_shapes
#print axioms present_visit
#print axioms owns_visit
#print axioms present_fold
#print axioms owns_fold
#print axioms rebuilt_exact
#print axioms every_published_bucket_has_owner
#print axioms production_exact
#print axioms observed_owners_after_restriction
#print axioms missing_scan_cannot_publish
#print axioms absent_retired_shape
#print axioms source_program_publishes_exact
end ACGN.Tenth.P408

private def numbers (s : String) : Option (List Nat) :=
  if s = "_" then some [] else (s.splitOn ",").mapM String.toNat?

private def parseRow (s : String) : Option ACGN.Tenth.P408.Row := do
  let [owner,leader,shapes] := s.splitOn ":" | none
  let id ← owner.toNat?
  let live ← match leader with | "1" => some true | "0" => some false | _ => none
  return ⟨id,live,← numbers shapes⟩

private def parseBucket (s : String) : Option (Nat × List Nat) := do
  let [shape,owners] := s.splitOn ":" | none
  return (← shape.toNat?, ← numbers owners)

private def entries (s : String) (read : String → Option α) : Option (List α) :=
  if s = "-" then some [] else (s.splitOn ";").mapM read

private def snapshot (s : String) : Bool := Id.run do
  let [_,rs,bs] := s.splitOn "\t" | return false
  let some rows := entries rs parseRow | return false
  let some buckets := entries bs parseBucket | return false
  let ids := rows.map (·.owner)
  if ids.eraseDups != ids then return false
  let sourceKeys := rows.flatMap (·.shapes)
  let keys := buckets.map (·.1)
  if keys.eraseDups != keys then return false
  if !buckets.all (fun b => !b.2.isEmpty && b.2.eraseDups == b.2) then return false
  let owners := rows.map (·.owner) ++ buckets.flatMap (·.2)
  let actual := rows.foldl ACGN.Tenth.P408.visit ACGN.Tenth.P408.empty
  for k in sourceKeys ++ keys do
    let found := (buckets.find? fun b => b.1 == k).map (·.2)
    if ACGN.Tenth.P408.present actual k != found.isSome then return false
    for o in owners do
      if ACGN.Tenth.P408.owns actual k o != (found.elim false (·.contains o)) then return false
  return true

def main (args : List String) : IO UInt32 := do
  let [programFile,traceFile] := args | return 2
  let lines := (← IO.FS.readFile programFile).splitOn "\n"
  if lines.getLast? != some "" || ACGN.Tenth.P408.readProgram lines.dropLast != some ACGN.Tenth.P408.production then
    IO.println "P408 live-owner reconstruction program rejected"
    return 1
  let observations := (← IO.FS.readFile traceFile).splitOn "\n"
  if observations.getLast? != some "" || observations.dropLast.isEmpty || !observations.dropLast.all snapshot then
    IO.println "P408 live-owner snapshot rejected"
    return 1
  IO.println s!"P408 live-owner reconstruction verified {observations.dropLast.length} snapshots"
  return 0
