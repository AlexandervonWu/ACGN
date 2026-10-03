import Lean
import EGraph2Graph

open Lean RepairTransformer

deriving instance FromJson for Port
deriving instance FromJson for Request

def main : IO Unit := do
  let input ← IO.getStdin
  let output ← IO.getStdout
  let text ← input.getLine
  if text.utf8ByteSize > 8388608 then throw (IO.userError "Graph gate input exceeds bound")
  let json ← match Json.parse text with
    | .ok value => pure value
    | .error message => throw (IO.userError message)
  let request : Request ← match fromJson? json with
    | .ok value => pure value
    | .error message => throw (IO.userError message)
  if admitted request then
    output.putStrLn (Json.mkObj [("accepted", toJson true), ("request", json)]).compress
  else throw (IO.userError "Graph transformer structural contract rejected")
