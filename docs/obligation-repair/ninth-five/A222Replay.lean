import A222Program

namespace A222.Replay
open A222

theorem through_is_actual_prefix (pre post : List Nat) (target : Nat) (before : target ∉ pre) :
    through target (pre ++ target :: post) = pre ++ [target] := by
  induction pre with
  | nil => simp [through]
  | cons a pre ih =>
    have ha : a ≠ target := by grind
    simp_all [through]

def nats (s : String) := (s.splitOn ",").mapM String.toNat?

def column (s : String) : Option Col := do
  let x :: tail ← nats s | none
  return ⟨x,tail,some 0⟩

def observation (ops : List Operation) (line : String) : Bool := Id.run do
  let ["C",ls,rs,rule,common,meet,lp,rp] := line.splitOn "\t" | return false
  let some l := column ls | return false
  let some r := column rs | return false
  let some ans := eval ops l r | return false
  return rule? ("Rule."++rule) == some ans.rule && common.toNat? == some ans.common &&
    (if meet == "-1" then ans.meet.isNone else meet.toNat? == ans.meet && ans.meet.isSome) &&
    nats lp == some ans.leftPath && nats rp == some ans.rightPath

def verify (lines : List String) : Bool := Id.run do
  let some ops := transcriptProgram lines | return false
  let cases := lines.drop (sourceHeader lines).length
  let keys := cases.map fun s => (s.splitOn "\t").take 3
  return cases.length == 100 && keys.eraseDups.length == 100 && cases.all (observation ops)

theorem verified_program (lines : List String) (verified : verify lines = true) :
    ∃ ops, transcriptProgram lines = some ops ∧ ops = canonical := by
  cases ok : transcriptProgram lines with
  | none => simp [verify, ok] at verified
  | some ops => exact ⟨ops, rfl, readProgram_registered (sourceProgram lines) ops ok⟩

def diagnosticControls (lines : List String) : List (List String) := [
  lines.map (fun s => s.replace "rightBoundary|leftBoundary|List.of(leftBoundary)|right.ancestry()"
    "leftBoundary|leftBoundary|List.of(leftBoundary)|right.ancestry()"),
  lines.map (fun s => s.replace "column < left.arity()|column++" "column < left.arity()|column--"),
  lines.map (fun s => if s.startsWith "C\t" then s.replace "\tDISJOINT_BRANCHES\t" "\tEXACT\t" else s),
  lines.dropLast]

#print axioms through_is_actual_prefix
#print axioms verified_program
end A222.Replay

def main (args : List String) : IO UInt32 := do
  let [path] := args | return 2
  let lines := ((← IO.FS.readFile path).trimAscii.toString).splitOn "\n"
  if A222.Replay.verify lines then
    if !(A222.Replay.diagnosticControls lines).all (fun bad => bad != lines && !A222.Replay.verify bad) then
      IO.println "A222 diagnostic control unexpectedly accepted"
      return 1
    IO.println "A222 diagnostic controls rejected=4"
    IO.println "A222 compiler and 100 parser decisions verified"
    return 0
  IO.println "A222 interchange rejected"
  return 1

