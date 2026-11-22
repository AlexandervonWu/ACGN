import P407QualifiedUses

namespace ACGN.Eleventh.P407.Replay
open ACGN.Eleventh.P407

inductive Kind where | record | hash | use deriving BEq
structure Row where
  epoch : Nat
  kind : Kind
  key : Key
  children : List Nat
  deriving BEq

def parseRow (text : String) : Option Row := do
  let [t,tag,o,s,ds] := text.splitOn "\t" | none
  let which ← match tag with
    | "record" => some Kind.record | "hash" => some Kind.hash | "use" => some Kind.use | _ => none
  let children ← if ds = "_" then some [] else (ds.splitOn ",").mapM String.toNat?
  if (which == .hash && !children.isEmpty) || (which == .use && children.length != 1) then none
  return ⟨← t.toNat?,which,⟨← o.toNat?,← s.toNat?⟩,children⟩

def asPorts (children : List Nat) : Ports :=
  children.foldr (fun c rest => .append (.invoke c) rest) .nil

theorem flattened_invocation_membership (children : List Nat) (c : Nat) :
    Occurs c (asPorts children) ↔ c ∈ children := by
  induction children with
  | nil => simp [asPorts,Occurs]
  | cons h t ih => change (c = h ∨ Occurs c (asPorts t)) ↔ c ∈ h :: t
                   simp [ih]

def test (program : List Op) (rows : List Row) : Bool := Id.run do
  if rows.isEmpty || rows.eraseDups != rows then return false
  let epochs := (rows.map (·.epoch)).eraseDups
  if epochs != List.range epochs.length then return false
  let records := rows.filter (fun r => r.kind == .record)
  let childrenOf := fun s => (records.find? fun r => r.key.shape == s).elim [] (·.children)
  if !records.all (fun r => r.children == childrenOf r.key.shape) then return false
  let ports := fun s => asPorts (childrenOf s)
  let candidateKeys := (rows.map (·.key)).eraseDups
  let childIds := (rows.flatMap (·.children)).eraseDups
  let mut before : List Key := []
  let mut actual : Index := vacant
  for epoch in epochs do
    let current := rows.filter (fun r => r.epoch == epoch)
    let keys := (current.filter (fun r => r.kind == .record)).map (·.key)
    let removed := (before.filter (fun k => !keys.contains k)).map (fun k => Edit.mk false k)
    let attached := (keys.filter (fun k => !before.contains k)).map (fun k => Edit.mk true k)
    actual := (removed ++ attached).foldl (executeEdit program ports) actual
    for k in candidateKeys do
      if actual.buckets k.shape k.owner != current.contains ⟨epoch,.hash,k,[]⟩ then return false
      for c in childIds do
        if actual.uses c k != current.contains ⟨epoch,.use,k,[c]⟩ then return false
    before := keys
  return true

#print axioms flattened_invocation_membership

end ACGN.Eleventh.P407.Replay

def main (args : List String) : IO UInt32 := do
  let [programFile, observationsFile] := args | return 2
  let lines := (← IO.FS.readFile programFile).trimAscii.toString.splitOn "\n"
  let some ops := lines.mapM ACGN.Eleventh.P407.readOp | return 1
  if ops != ACGN.Eleventh.P407.expectedProgram then return 1
  let input := (← IO.FS.readFile observationsFile).trimAscii.toString.splitOn "\n"
  let some rows := input.mapM ACGN.Eleventh.P407.Replay.parseRow | return 1
  if !ACGN.Eleventh.P407.Replay.test ops rows then
    IO.println "P407 owner-qualified observation rejected"
    return 1
  IO.println s!"P407 owner-qualified observations verified {rows.length} rows"
  return 0
