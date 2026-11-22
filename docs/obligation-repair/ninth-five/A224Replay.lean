import A224BoundaryBridge

def main (args : List String) : IO UInt32 := do
  let [file] := args | return 64
  let text ← IO.FS.readFile file
  if (A224.lower (text.trimAsciiEnd.toString.splitOn "\n")).isSome then
    IO.println "A224 compiler program accepted"
    return 0
  IO.println "A224 compiler program rejected"
  return 1
