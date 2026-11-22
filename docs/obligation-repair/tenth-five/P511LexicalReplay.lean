import P511LexicalTransport

namespace ACGN.Tenth.P511.Replay

open P506SourceNonempty
open ACGN.Tenth.P511

def syntaxOf : String → Option Syntax
  | "bare" => some .bare
  | "one" => some .one
  | "some" => some .some
  | "set" => some .set
  | "lone" => some .lone
  | "exactly" => some .exactly
  | _ => none

def declaration (s : String) : Option Declaration := do
  let k :: a :: ns := s.splitOn "," | none
  let ids ← ns.mapM String.toNat?
  guard (!ids.isEmpty)
  return ⟨ids, ⟨← syntaxOf k, ← a.toNat?⟩⟩

def tokenFor (root : Root) (i : Nat) : Option Slot := do
  let (d,di) ← root.decls.zipIdx.find? (fun item => item.1.vars.contains i)
  let vi ← d.vars.idxOf? i
  return ⟨root.identity,di,vi,i⟩

def frame (root : Root) (s : String) : Option Entry := do
  let [spelling,sourceId] := s.splitOn "," | none
  let coord ← sourceId.toNat?
  let token ← tokenFor root coord
  return ⟨← spelling.toNat?,coord,some token⟩

def methodOf : String → Option Method
  | "RAW" => some .raw
  | "RAW_DEBRUIJN" => some .rawDeBruijn
  | "EGGLOG" => some .egglog
  | "EGGLOG_DEBRUIJN" => some .egglogDeBruijn
  | "SLOTTED" => some .slotted
  | "SLOTTED_TYPED" => some .typedSlotted
  | _ => none

structure Observation where
  root : Root
  before : List Entry
  after : List Entry
  preKey : Nat
  postKey : Nat
  read : Option Slot
  expected : Bool

def decode (line : String) : Option Observation := do
  let [id,m,op,groups,readId,preKey,pre,postKey,post,outcome] := line.splitOn "\t" | none
  guard (!id.isEmpty && (op == "IN" || op == "NOT_IN"))
  let _ ← methodOf m
  let root : Root := ⟨1, ← (groups.splitOn "|").mapM declaration⟩
  let names := root.decls.flatMap (·.vars)
  guard (names.Nodup && !names.contains 0)
  let id ← readId.toNat?
  let token ← if id = 0 then some none else (tokenFor root id).map some
  let expected ← match outcome with
    | "true" => some true
    | "false" => some false
    | _ => none
  return ⟨root, ← (pre.splitOn "|").mapM (frame root), ← (post.splitOn "|").mapM (frame root),
    ← preKey.toNat?, ← postKey.toNat?, token,expected⟩

def validates (row : Observation) :=
  checkFrontiers row.root row.before row.after row.preKey row.postKey row.read row.expected

theorem accepted_trace_has_one_source (o : Observation) (ok : validates o = true)
    (yes : o.expected = true) :
    ∃ s d, o.read = some s ∧ Visible o.preKey s (o.before.map named) ∧
      Visible o.postKey s (o.after.map named) ∧ Issued o.root s d ∧
      (effective d = .one ∨ effective d = .some) := by
  unfold validates at ok
  rw [yes] at ok
  exact checked_positive_same_original _ _ _ _ _ _ ok

theorem decoded_frame_recovers_issuer (root : Root) (s : String) (entry : Entry)
    (ok : frame root s = some entry) :
    ∃ token, entry.token = some token := by
  unfold frame at ok
  split at ok <;> simp_all
  simp only [Option.bind_eq_some_iff, Option.some.injEq] at ok
  rcases ok with ⟨_,_,token,_,_,_,rfl⟩
  exact ⟨token,rfl⟩

end ACGN.Tenth.P511.Replay

#print axioms ACGN.Tenth.P511.Replay.accepted_trace_has_one_source
#print axioms ACGN.Tenth.P511.Replay.decoded_frame_recovers_issuer

open ACGN.Tenth.P511.Replay in
def main (args : List String) : IO UInt32 := do
  let [file] := args | throw (IO.userError "expected one P5-11 frontiers TSV")
  let data := (← IO.FS.readFile file).trimAsciiEnd.toString.splitOn "\n"
  let expectedHeader := "case\tengine\toperation\tdomains\tread-slot\tbefore-key\tbefore-scope\tafter-key\tafter-scope\tsource-guard"
  unless data.head? == some expectedHeader do throw (IO.userError "invalid P5-11 trace header")
  let mut controls := false
  let mut accepted := 0
  let mut withheld := 0
  for line in data.drop 1 do
    let some row := decode line | throw (IO.userError ("invalid P5-11 frontier: " ++ line))
    unless validates row do throw (IO.userError ("P5-11 source/frontier mismatch: " ++ line))
    if row.expected then
      accepted := accepted + 1
      unless controls do
        if validates {row with postKey := 0} then throw (IO.userError "absent label accepted")
        if validates {row with after := []} then throw (IO.userError "omitted frontier accepted")
        if validates {row with expected := false} then throw (IO.userError "changed source outcome accepted")
        controls := true
    else withheld := withheld + 1
  if accepted = 0 || withheld = 0 then throw (IO.userError "both guard outcomes are required")
  IO.println s!"P511LexicalReplay PASS frontiers={accepted+withheld} authorized={accepted} guarded={withheld} controls=3"
  return 0
