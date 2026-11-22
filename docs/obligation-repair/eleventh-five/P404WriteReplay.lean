import P404InstalledParent
open ACGN.Eleventh.P404

def main (args : List String) : IO Unit := do
  let [path] := args | throw (IO.userError "expected parent-writes.tsv")
  let rows := ((← IO.FS.readFile path).trimAsciiEnd.toString).splitOn "\n"
  unless (decode rows).isSome do throw (IO.userError "unregistered parent write program")
  let stale := [rows.drop 1, rows.reverse, rows ++ rows.take 1,
    rows.map (fun row => row.replace "ParentStep.certified(edge)" "edge")]
  unless stale.all (fun changed => (decode changed).isNone) do
    throw (IO.userError "parent write replay accepted altered compiler evidence")
  IO.println "P404 replay accepted six compiled stores and rejected four altered write streams"
