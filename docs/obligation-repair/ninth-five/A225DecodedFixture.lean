import A225WireCommitment
import Lean.Data.Json

open ACGN.Ninth.A225 Lean

private def fromWireJson : Nat → Json → Except String Wire
  | 0, _ => throw "fixture depth"
  | fuel+1, j => do
    let a ← j.getArr?
    if a.size != 3 then throw "fixture node"
    let tag ← a[0]!.getStr?
    let scalars ← fromJson? (α := List String) a[1]!
    let children ← a[2]!.getArr?
    return .node tag scalars (← children.toList.mapM (fromWireJson fuel))

private def same : Nat → Wire → Wire → Bool
  | 0, _, _ => false
  | fuel+1, .node t f c, .node u g k =>
    t == u && f == g && c.length == k.length && (c.zip k).all (fun p => same fuel p.1 p.2)

private def checkLine (line : String) : Except String Unit := do
  let json ← Json.parse line
  let w ← fromWireJson 64 json
  match w with
  | .node "dependent-type-dag" _ _ =>
    let some decoded := readDag w | throw "DAG does not decode"
    unless same 64 w (dag decoded) do throw "DAG round trip changed a field"
  | .node "dependent-chain-combination-cases" _ _ =>
    let some decoded := readMatrix w | throw "matrix does not decode"
    unless same 64 w (matrix decoded) do throw "matrix round trip changed a field"
  | _ => throw "unexpected fixture"

def main (args : List String) : IO Unit := do
  let [file] := args | throw (IO.userError "expected JSON lines file")
  let lines ← IO.FS.lines file
  if lines.isEmpty then throw (IO.userError "no decoded wire records")
  for line in lines do
    match checkLine line with
    | .ok () => pure ()
    | .error e => throw (IO.userError e)
  IO.println s!"A225 Lean field round trips: {lines.size}"
