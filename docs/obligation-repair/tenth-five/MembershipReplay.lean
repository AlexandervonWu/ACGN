import MembershipStream
open ACGN.Tenth.Membership

def main (args : List String) : IO Unit := do
  let [file] := args | throw (IO.userError "membership instruction TSV required")
  let lines := (← IO.FS.readFile file).splitOn "\n"
  let header := "engine\tpolarity\tleft\tright\tsame-width\tauthority\tcan-expand\tresult"
  let h::body := lines | throw (IO.userError "missing header")
  unless h == header && body.getLast? == some "" do throw (IO.userError "invalid table framing")
  let rows := body.dropLast
  unless checkStream rows do throw (IO.userError "UNMODELED_MEMBERSHIP_INSTRUCTION")
  let first := rows.head!
  let altered := first.dropEnd 1 |>.toString
  unless !checkStream (rows.drop 1) && !checkStream (first :: rows) &&
    !checkStream ((altered ++ (if first.endsWith "T" then "F" else "T")) :: rows.tail!) &&
    !checkStream rows.reverse do throw (IO.userError "incomplete instruction control")
  IO.println s!"MembershipReplay verified {rows.length} compiler decisions and four stale-trace controls"
