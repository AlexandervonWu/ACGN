import Lean
import ApplicationCore

open Lean RepairApplication

deriving instance FromJson for Step
deriving instance FromJson for Request

def checkRequest (text : String) : Except String Json := do
  let json <- Json.parse text
  let request : Request <- fromJson? json
  match admit request with
  | none => throw "Application rollout contract rejected"
  | some certified =>
    return Json.mkObj [
      ("accepted", toJson true),
      ("request", json),
      ("returns", toJson (targets certified))]

def main : IO Unit := do
  let input <- IO.getStdin
  let output <- IO.getStdout
  let text <- input.getLine
  if text.utf8ByteSize > 262144 then
    throw (IO.userError "Application gate input exceeds bound")
  match checkRequest text with
  | .error message => throw (IO.userError message)
  | .ok result => output.putStrLn result.compress
