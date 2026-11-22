import Init

/-! A completed strict union folds over the distinct keys of a child leader's
shape map before installing its parent. The state below projects exactly the
parent's live shape records, the retiring child's ledger entries, and the
ordered disposition trace. Other owners are separate map slices. -/
namespace P406

inductive Expr where
  | input (id : Nat)
  | acted (map : Nat) (value : Expr)
  | trans (left right : Expr)
  deriving DecidableEq

structure Record where
  shape : Nat
  owner : Nat
  witness : Expr
  equation : Expr
  deriving DecidableEq

structure Edge where
  child : Nat
  parent : Nat
  inclusion : Nat
  relabel : Nat
  equation : Expr
  deriving DecidableEq

/-- The oriented old equation is composed with the edge in the original
ambient support; the final renaming acts on the entire resulting equation. -/
def transfer (edge : Edge) (old : Record) : Record :=
  ⟨old.shape, edge.parent, .acted edge.relabel old.witness,
    .acted edge.relabel (.trans old.equation (.acted edge.inclusion edge.equation))⟩

/-- Parametric typed certificate calculus for the two composition rules.
The JVM certificate verifier supplies oriented premises at concrete endpoints. -/
inductive Checked {Term Map : Type} (act : Map → Term → Term)
    (input : Term → Term → Type) : Term → Term → Type where
  | given {a b} : input a b → Checked act input a b
  | compose {a b c} : Checked act input a b → Checked act input b c → Checked act input a c
  | rename {a b} (m : Map) : Checked act input a b → Checked act input (act m a) (act m b)

def rebuiltProof {T M : Type} {act : M → T → T} {input : T → T → Type}
    {shape owner child parent : T} (included renamed : M)
    (old : Checked act input shape owner) (edge : Checked act input child parent)
    (aligned : owner = act included child) :
    Checked act input (act renamed shape) (act renamed (act included parent)) := by
  subst owner
  exact .rename renamed (.compose old (.rename included edge))

theorem rebuilt_proof_exists {T M : Type} {act : M → T → T} {input : T → T → Type}
    {shape owner child parent : T} (included renamed : M)
    (old : Checked act input shape owner) (edge : Checked act input child parent)
    (aligned : owner = act included child) :
    Nonempty (Checked act input (act renamed shape) (act renamed (act included parent))) :=
  ⟨rebuiltProof included renamed old edge aligned⟩

theorem checked_sound {T M : Type} {act : M → T → T} {input : T → T → Type}
    {meaning : T → T → Prop} (base : ∀ a b, input a b → meaning a b)
    (chain : ∀ a b c, meaning a b → meaning b c → meaning a c)
    (rename : ∀ m a b, meaning a b → meaning (act m a) (act m b))
    {a b : T} (d : Checked act input a b) : meaning a b := by
  induction d with
  | given p => exact base _ _ p
  | compose _ _ x y => exact chain _ _ _ x y
  | rename m _ x => exact rename m _ _ x

structure Retirement where
  old : Record
  candidate : Record
  retained : Record
  edge : Edge
  deriving DecidableEq

inductive Outcome where
  | rehome (old candidate : Record)
  | retire (evidence : Retirement)
  deriving DecidableEq

def Outcome.source : Outcome → Record
  | .rehome old _ => old
  | .retire evidence => evidence.old

structure State where
  live : Nat → Option Record
  retired : Nat → Option Retirement

def put {α : Type} (entries : Nat → Option α) (key : Nat) (record : α) (k : Nat) : Option α :=
  if k = key then some record else entries k

def step (e : Edge) (before : State) (old : Record) : State × Outcome :=
  let candidate := transfer e old
  match before.live old.shape with
  | none => (⟨put before.live old.shape candidate, before.retired⟩, .rehome old candidate)
  | some retained =>
    let evidence := ⟨old, candidate, retained, e⟩
    (⟨before.live, put before.retired old.shape evidence⟩, .retire evidence)

def run (e : Edge) (state : State) : List Record → State × List Outcome
  | [] => (state, [])
  | old :: tail =>
    let (next, result) := step e state old
    let (final, log) := run e next tail
    (final, result :: log)

@[simp]
theorem step_source (e : Edge) (s : State) (r : Record) :
    (step e s r).2.source = r := by
  unfold step; split <;> rfl

theorem exact_ordered_sources (e : Edge) (s : State) (rs : List Record) :
    (run e s rs).2.map Outcome.source = rs := by
  induction rs generalizing s with
  | nil => rfl
  | cons r rs ih => simp [run, ih]

theorem no_silent_loss (e : Edge) (s : State) (rs : List Record) (r : Record)
    (present : r ∈ rs) : ∃ out ∈ (run e s rs).2, out.source = r := by
  rw [← exact_ordered_sources e s rs] at present
  exact List.mem_map.mp present

theorem no_double_disposition (e : Edge) (s : State) (rs : List Record)
    (unique : (rs.map Record.shape).Nodup) :
    ((run e s rs).2.map (fun out => out.source.shape)).Nodup := by
  rw [← exact_ordered_sources e s rs] at unique
  simpa only [List.map_map, Function.comp_def] using unique

theorem exact_disposition_count (e : Edge) (s : State) (rs : List Record) :
    (run e s rs).2.length = rs.length := by
  simpa using congrArg List.length (exact_ordered_sources e s rs)

theorem step_other (e : Edge) (s : State) (r : Record) (k : Nat) (h : k ≠ r.shape) :
    (step e s r).1.live k = s.live k ∧ (step e s r).1.retired k = s.retired k := by
  unfold step; split <;> simp [put, h]

theorem all_other_records (e : Edge) (s : State) (rs : List Record) (k : Nat)
    (missing : k ∉ rs.map Record.shape) :
    (run e s rs).1.live k = s.live k ∧ (run e s rs).1.retired k = s.retired k := by
  induction rs generalizing s with
  | nil => exact ⟨rfl, rfl⟩
  | cons r rs ih =>
    have unequal : k ≠ r.shape := fun h => missing (by simp [h])
    have outside : k ∉ rs.map Record.shape := fun h => missing (by simp [h])
    have later := ih (step e s r).1 outside
    have here := step_other e s r k unequal
    exact ⟨later.1.trans here.1, later.2.trans here.2⟩

def HasDisposition (e : Edge) (before after : State) (log : List Outcome) (r : Record) : Prop :=
  match before.live r.shape with
  | none =>
    after.live r.shape = some (transfer e r) ∧
    after.retired r.shape = before.retired r.shape ∧ .rehome r (transfer e r) ∈ log
  | some keep =>
    let evidence : Retirement := ⟨r, transfer e r, keep, e⟩
    after.live r.shape = some keep ∧ after.retired r.shape = some evidence ∧ .retire evidence ∈ log

theorem exact_final_disposition (e : Edge) (s : State) (rs : List Record)
    (unique : (rs.map Record.shape).Nodup) (r : Record) (inside : r ∈ rs) :
    HasDisposition e s (run e s rs).1 (run e s rs).2 r := by
  induction rs generalizing s with
  | nil => simp at inside
  | cons x xs ih =>
    have un := List.nodup_cons.mp unique
    rcases List.mem_cons.mp inside with eq | later
    · subst x
      have frame := all_other_records e (step e s r).1 xs r.shape un.1
      cases h : s.live r.shape with
      | none => simpa [HasDisposition, run, step, h, put] using frame
      | some keep => simpa [HasDisposition, run, step, h, put] using frame
    · have other : r.shape ≠ x.shape :=
        fun eq => un.1 (eq ▸ List.mem_map.mpr ⟨r, later, rfl⟩)
      have frame := step_other e s x r.shape other
      have tail := ih (step e s x).1 un.2 later
      unfold HasDisposition at *
      rw [frame.1, frame.2] at tail
      cases h : s.live r.shape <;> simp only [h] at tail ⊢ <;>
        exact ⟨tail.1, tail.2.1, List.mem_cons_of_mem _ tail.2.2⟩

theorem rehomed_proof_and_identity (e : Edge) (s : State) (rs : List Record)
    (unique : (rs.map Record.shape).Nodup) (r : Record) (inside : r ∈ rs)
    (fresh : s.live r.shape = none) :
    (run e s rs).1.live r.shape = some
      ⟨r.shape, e.parent, .acted e.relabel r.witness,
        .acted e.relabel (.trans r.equation (.acted e.inclusion e.equation))⟩ := by
  have d := exact_final_disposition e s rs unique r inside
  simp only [HasDisposition, fresh] at d
  exact d.1

theorem duplicate_keeps_proof_and_ledger (e : Edge) (s : State) (rs : List Record)
    (unique : (rs.map Record.shape).Nodup) (r keep : Record) (inside : r ∈ rs)
    (duplicate : s.live r.shape = some keep) :
    (run e s rs).1.live r.shape = some keep ∧
    (run e s rs).1.retired r.shape = some ⟨r, transfer e r, keep, e⟩ := by
  have d := exact_final_disposition e s rs unique r inside
  simp only [HasDisposition, duplicate] at d
  exact ⟨d.1, d.2.1⟩

inductive Cause where | union | rebuild deriving DecidableEq
theorem strict_live_key_has_no_prior_retirement {cause : Cause → Prop}
    (leader live : Prop)
    (unionRule : cause .union → ¬leader) (rebuildRule : cause .rebuild → ¬live)
    (l : leader) (r : live) : ¬∃ c, cause c := by
  rintro ⟨c, present⟩
  cases c with
  | union => exact unionRule present l
  | rebuild => exact rebuildRule present r


/-- Branch and completion operations emitted from the attributed implementation. -/
def expectedProgram : List String := [
  "snapshot-child-keys", "visit-each-shape", "source-owner-shape", "load-certified-source",
  "derive-candidate", "remove-old-equation", "candidate-owner-shape", "check-candidate",
  "lookup-parent-shape", "fresh-install-candidate-and-rehome", "duplicate-keep-add-retirement",
  "install-parent-records", "empty-child-records", "install-directed-edge", "emit-dispositions",
  "proof-orient-rename-edge-trans-rename-orient"]

def installed (program : List String) (e : Edge) (s : State) (rs : List Record) :
    Option (State × List Outcome) :=
  if program = expectedProgram then some (run e s rs) else none

theorem installation_implies_completed_partition (program : List String) (e : Edge) (s : State)
    (rs : List Record) (final : State) (log : List Outcome)
    (accepted : installed program e s rs = some (final, log)) :
    program = expectedProgram ∧ log.map Outcome.source = rs := by
  by_cases h : program = expectedProgram
  · simp only [installed, h, ite_eq_left, Option.some.injEq] at accepted
    have eq : (run e s rs).2 = log := congrArg Prod.snd accepted
    exact ⟨h, eq ▸ exact_ordered_sources e s rs⟩
  · simp [installed, h] at accepted

private def parseKeys (s : String) : Option (List Nat) :=
  if s == "_" then some [] else (s.splitOn ",").mapM String.toNat?

private def dummy (owner shape : Nat) : Record :=
  ⟨shape,owner,.input shape,.input (owner + shape)⟩

def checkProjection (program : List String) (line : String) : Bool := Id.run do
  let [_, a, b, c, d, f, g] := line.splitOn "\t" | return false
  let some keys := parseKeys a | return false
  let some prior := parseKeys b | return false
  let some moved := parseKeys c | return false
  let some retired := parseKeys d | return false
  let some final := parseKeys f | return false
  let some ledger := parseKeys g | return false
  let e : Edge := ⟨0,1,2,3,.input 4⟩
  let s : State := ⟨fun k => if prior.contains k then some (dummy 1 k) else none, fun _ => none⟩
  let some (after, log) := installed program e s (keys.map (dummy 0)) | return false
  let fresh := log.filterMap fun | .rehome old _ => some old.shape | _ => none
  let dup := log.filterMap fun | .retire x => some x.old.shape | _ => none
  let observed := (keys ++ prior ++ final ++ ledger).eraseDups
  return keys.Nodup && prior.Nodup && final.Nodup && ledger.Nodup &&
    fresh == moved && dup == retired && observed.all fun k =>
       ((after.live k).isSome == final.contains k && (after.retired k).isSome == ledger.contains k)

#print axioms rebuilt_proof_exists
#print axioms checked_sound
#print axioms step_source
#print axioms exact_ordered_sources
#print axioms no_silent_loss
#print axioms no_double_disposition
#print axioms exact_disposition_count
#print axioms step_other
#print axioms all_other_records
#print axioms exact_final_disposition
#print axioms rehomed_proof_and_identity
#print axioms duplicate_keeps_proof_and_ledger
#print axioms strict_live_key_has_no_prior_retirement
#print axioms installation_implies_completed_partition

end P406

def main (args : List String) : IO UInt32 := do
  let [program, observations] := args | return 1
  let ops := (← IO.FS.readFile program).splitOn "\n" |>.filter (· != "")
  if ops != P406.expectedProgram then
    IO.println "P406 attributed transfer program rejected"
    return 1
  let rows := (← IO.FS.readFile observations).splitOn "\n" |>.filter (· != "")
  if rows.isEmpty || !rows.all (P406.checkProjection ops) then
    IO.println "P406 transfer projection rejected"
    return 1
  IO.println s!"P406 transfer partitions verified: {rows.length}"
  return 0
