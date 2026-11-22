import Category72Contracts

/- Kernel tests of the retained diagnostics. Atom IDs are collision-free table
   indices exported with the full occurrence/admission and four-field tuple.
   Tests establish replay and the observed refusal, NOT repaired corpus parity.
   The JSON-to-Lean exporter and parser source linkage remain explicit trust. -/
namespace Category72.FixtureChecks
open DeclarationReplay

structure Program where
  source : List Atom
  target : List Atom
  edits : List Edit
  cost : Nat

def programCheck (program : Program) : Bool :=
  decide (replay program.source program.edits = some (program.target, program.cost))

theorem program_check_exact (program : Program) (checked : programCheck program = true) :
    replay program.source program.edits = some (program.target, program.cost) := by
  simpa [programCheck] using checked

structure Slice where
  sourceTuples : List Nat
  targetTuples : List Nat
  dp : List (List Nat)
  allowed : List (Nat × Nat × Bool)

def allowedAt (slice : Slice) (source target : Nat) : Bool :=
  slice.allowed.any (fun entry => entry.1 == source && entry.2.1 == target && entry.2.2)

def costAt (slice : Slice) (i j : Nat) : Option Nat := do
  let row ← slice.dp[i]?
  row[j]?

def costStep (slice : Slice) (i j pi pj charge : Nat) : Bool :=
  match costAt slice i j, costAt slice pi pj with
  | some total, some previous => total == previous + charge
  | _, _ => false

/- Coordinates are shifted by one: zero means the Java -1 absent side.
   Compute each DP cell once in row order, as in DeclarationReplay.capture.
   Repeated recursive evaluation of predecessor paths is unnecessary. -/
def cell (slice : Slice) (i j : Nat) (previous current : List Bool) : Bool :=
  if i = 0 ∧ j = 0 then true else
    (decide (0 < i ∧ 0 < j) && (previous[j - 1]?).getD false && allowedAt slice i j &&
      costStep slice i j (i - 1) (j - 1)
        (if slice.sourceTuples[i - 1]? = slice.targetTuples[j - 1]? then 0 else 1)) ||
    (decide (0 < i) && (previous[j]?).getD false && allowedAt slice i 0 &&
      costStep slice i j (i - 1) j 1) ||
    (decide (0 < j) && (current[j - 1]?).getD false && allowedAt slice 0 j &&
      costStep slice i j i (j - 1) 1)

def reachable (slice : Slice) (n m : Nat) : Bool :=
  let last := (List.range (n + 1)).foldl (fun previous i =>
    (List.range (m + 1)).foldl (fun current j => current ++ [cell slice i j previous current]) []) []
  (last[m]?).getD false

def refusedSlice (slice : Slice) : Bool :=
  let n := slice.sourceTuples.length
  let m := slice.targetTuples.length
  slice.dp.length == n + 1 && slice.dp.all (fun row => row.length == m + 1) &&
    decide (costAt slice 0 0 = some 0) && !reachable slice n m

/- Little-endian UTF-8 bytes, with length retained for trailing zero bytes.
   Packed natural literals avoid elaborating one expression per byte. The
   exporter checks a lossless roundtrip against the retained full strings. -/
structure EncodedBytes where
  size : Nat
  value : Nat
  deriving DecidableEq, BEq

def EncodedBytes.at (bytes : EncodedBytes) (index : Nat) : Option Nat :=
  if index < bytes.size then some ((bytes.value >>> (8 * index)) % 256) else none

inductive Boundary where
  | component (fast certified : Nat)
  | declaration (slice : Slice)
  | phases (original fast projected : Nat)
  | alternative (count : Nat)
  | actions (fast certified : EncodedBytes) (expectedEqual : Bool) (differenceByte : Nat)
  | budget (remaining : Int) (depth children : Nat)
  | call (argumentOpcode : String) (scopedAdmission : Bool) (arity : Nat)

def boundaryCheck : Boundary → Bool
  | .component fast certified => fast != certified
  | .declaration slice => refusedSlice slice
  | .phases original fast projected => !(original == fast && fast == projected)
  | .alternative count => count != 0
  | .actions fast certified expectedEqual differenceByte =>
      if expectedEqual then decide (fast = certified)
      else decide (fast.at differenceByte ≠ certified.at differenceByte)
  | .budget remaining depth children => !decide (0 ≤ remaining ∧ depth ≤ 48 ∧ children ≤ 64)
  | .call opcode scopedAdmission arity => !scopedAdmission && arity != 0 && opcode != "GLOBALBINDING" &&
      !["VARIABLE", "GLOBALBINDING", "JOIN", "MINUS"].contains opcode

structure Case where
  event : Nat
  direction : Nat
  sourceHash : String
  sourcePredicate : String
  targetPredicate : String
  receiptHash : String
  fast : List Program
  certified : List Program
  fastQuantifier : Nat
  certifiedQuantifier : Nat
  boundary : Boundary

def caseCheck (item : Case) : Bool :=
  decide (item.direction < 2) && item.sourceHash.length == 64 && item.receiptHash.length == 64 &&
  item.fast.all programCheck && item.certified.all programCheck &&
  (item.fast.map Program.cost).sum == item.fastQuantifier &&
  (item.certified.map Program.cost).sum == item.certifiedQuantifier && boundaryCheck item.boundary

theorem checked_case_preserves_both_programs (item : Case) (checked : caseCheck item = true) :
    (∀ p ∈ item.fast, replay p.source p.edits = some (p.target, p.cost)) ∧
    (∀ p ∈ item.certified, replay p.source p.edits = some (p.target, p.cost)) := by
  have checks : item.fast.all programCheck = true ∧ item.certified.all programCheck = true := by
    simp only [caseCheck, Bool.and_eq_true] at checked
    exact ⟨checked.1.1.1.1.2, checked.1.1.1.2⟩
  exact ⟨fun p member => program_check_exact p (List.all_eq_true.mp checks.1 p member),
    fun p member => program_check_exact p (List.all_eq_true.mp checks.2 p member)⟩

theorem retained_discrepancy_is_not_match (fast certified : EncodedBytes) (differenceByte : Nat)
    (checked : boundaryCheck (.actions fast certified false differenceByte) = true) :
    fast ≠ certified := by
  intro equal
  subst certified
  simp [boundaryCheck] at checked

theorem identical_action_rejects_difference_witness (action : EncodedBytes) (differenceByte : Nat) :
    boundaryCheck (.actions action action false differenceByte) = false := by
  simp [boundaryCheck]

theorem changed_payload_cannot_pass_action_equality (fast certified : EncodedBytes)
    (changed : fast ≠ certified) (differenceByte : Nat) :
    boundaryCheck (.actions fast certified true differenceByte) = false := by
  simp [boundaryCheck, changed]

theorem authenticated_action_bytes_differ (encode : String → EncodedBytes) (fast certified : String)
    (fastBytes certifiedBytes : EncodedBytes) (differenceByte : Nat)
    (sourceBytes : encode fast = fastBytes)
    (targetBytes : encode certified = certifiedBytes)
    (checked : boundaryCheck (.actions fastBytes certifiedBytes false differenceByte) = true) :
    fast ≠ certified := by
  intro equal
  have bytesEqual : fastBytes = certifiedBytes := by rw [← sourceBytes, ← targetBytes, equal]
  exact retained_discrepancy_is_not_match fastBytes certifiedBytes differenceByte checked bytesEqual

theorem corrupt_declaration_charge_rejected :
    programCheck ⟨[⟨0, 0⟩], [⟨1, 1⟩], [.pair ⟨0, 0⟩ ⟨1, 1⟩], 0⟩ = false := by decide

theorem foreign_declaration_occurrence_rejected :
    programCheck ⟨[⟨0, 0⟩], [], [.delete ⟨1, 0⟩], 1⟩ = false := by decide

theorem omitted_declaration_action_rejected :
    programCheck ⟨[⟨0, 0⟩], [], [], 0⟩ = false := by decide

theorem unchanged_prior_declaration_path :
    programCheck ⟨[⟨0, 0⟩], [⟨1, 0⟩], [.pair ⟨0, 0⟩ ⟨1, 0⟩], 0⟩ = true := by decide

theorem same_cost_is_not_same_program :
    let first : Selection.Key := ⟨19, 0⟩
    let second : Selection.Key := ⟨19, 1⟩
    first.cost = second.cost ∧ first ≠ second ∧
      Selection.select first [second] = Selection.select second [first] := by decide

theorem omitted_live_reference_fails (reference : TemporalReferenceReachability.Reference) :
    TemporalReferenceReachability.construct
      (fun _ => none : TemporalReferenceReachability.Reference → Option Bool)
      (.reference reference) = none := rfl

theorem context_is_part_of_census_key :
    Census.validate (fun (entry : Nat × Nat) => entry.2 == 0)
      [(1,0),(1,1)].eraseDups = false := by decide

theorem memoized_census_keeps_repeated_reads :
    Census.checkedLedger (fun (_ : Nat) => true) [1,1,2,1] = some [1,1,2,1] := by decide

theorem live_bad_record_not_hidden_by_repetition :
    Census.checkedLedger (fun (n : Nat) => n == 0) [0,0,1,0] = none := by decide

theorem reordered_call_arguments_are_observable :
    ([true,false] : List Bool).head? ≠ ([false,true] : List Bool).head? := by decide

theorem changed_union_leaf_is_observable :
    Calls.relation (fun (slot : Nat) (_ : Fin 1 → Unit) => slot = 0)
      (.plus (.leaf 0) (.leaf 1)) (fun _ => ()) ∧
    ¬ Calls.relation (fun (slot : Nat) (_ : Fin 1 → Unit) => slot = 0)
      (.plus (.leaf 1) (.leaf 1)) (fun _ => ()) := by
  simp [Calls.relation]

end Category72.FixtureChecks
