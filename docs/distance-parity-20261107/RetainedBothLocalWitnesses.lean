import RetainedBothLocalPaid

/- Generated from frozen native diagnostic executions. Exact costs and outer
   declaration replay are checked here; Java object authority, typed/source
   correspondence and whole matrix reconstruction remain separate obligations. -/
namespace RetainedBothLocalWitnesses
open RetainedBothLocalPaid

def event248_0_mapping : Mapping := [("_q0", "_q3")]
def event248_0_variables : List (Variable × Variable) := [({ name := "_q0", registered := true, isLocal := false }, { name := "_q3", registered := true, isLocal := false }),
  ({ name := "@fast-local:0:0", registered := true, isLocal := true }, { name := "@fast-local:0:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:1", registered := true, isLocal := true }, { name := "@fast-local:0:1", registered := true, isLocal := true }),
  ({ name := "@fast-local:1:0", registered := true, isLocal := true }, { name := "@fast-local:1:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:0", registered := true, isLocal := true }, { name := "@fast-local:0:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:1:0", registered := true, isLocal := true }, { name := "@fast-local:1:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:1", registered := true, isLocal := true }, { name := "@fast-local:0:1", registered := true, isLocal := true })]
def event248_0_locals : List (Variable × Variable) := [({ name := "@fast-local:0:0", registered := true, isLocal := true }, { name := "@fast-local:0:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:1", registered := true, isLocal := true }, { name := "@fast-local:0:1", registered := true, isLocal := true }),
  ({ name := "@fast-local:1:0", registered := true, isLocal := true }, { name := "@fast-local:1:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:0", registered := true, isLocal := true }, { name := "@fast-local:0:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:1:0", registered := true, isLocal := true }, { name := "@fast-local:1:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:1", registered := true, isLocal := true }, { name := "@fast-local:0:1", registered := true, isLocal := true })]
theorem event248_0_old_gate (remaining : Bool) : oldSupplemental true true true true remaining = false := by simp [oldSupplemental]
theorem event248_0_actual_charges : event248_0_variables.map (fun p => variableCost event248_0_mapping p.1 p.2) = [0,0,0,0,0,0,0] := by decide
theorem event248_0_old_charges : event248_0_variables.map (fun p => variableCost [] p.1 p.2) = [1,0,0,0,0,0,0] := by decide
theorem event248_0_local_separation : event248_0_locals.all (localSeparation event248_0_mapping) = true := by decide
theorem event248_0_local_charges_preserved : event248_0_locals.map (fun p => variableCost event248_0_mapping p.1 p.2) = event248_0_locals.map (fun p => variableCost [] p.1 p.2) := all_local_charges_unchanged _ _ event248_0_local_separation
def event248_0_source : List PaidDeclarationAlignment.Atom := [{ occurrence := 0, tuple := 0 }, { occurrence := 1, tuple := 0 }]
def event248_0_target : List PaidDeclarationAlignment.Atom := [{ occurrence := 3, tuple := 1 }]
def event248_0_edits : List PaidDeclarationAlignment.Edit := [.pair ({ occurrence := 0, tuple := 0 }) ({ occurrence := 3, tuple := 1 }), .delete ({ occurrence := 1, tuple := 0 })]
theorem event248_0_declaration_replay : PaidDeclarationAlignment.replay event248_0_source event248_0_edits = some (event248_0_target, 2, [(0, 3)]) := by decide

def event248_1_mapping : Mapping := [("_q3", "_q0")]
def event248_1_variables : List (Variable × Variable) := [({ name := "_q3", registered := true, isLocal := false }, { name := "_q0", registered := true, isLocal := false }),
  ({ name := "@fast-local:0:0", registered := true, isLocal := true }, { name := "@fast-local:0:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:1", registered := true, isLocal := true }, { name := "@fast-local:0:1", registered := true, isLocal := true }),
  ({ name := "@fast-local:1:0", registered := true, isLocal := true }, { name := "@fast-local:1:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:0", registered := true, isLocal := true }, { name := "@fast-local:0:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:1:0", registered := true, isLocal := true }, { name := "@fast-local:1:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:1", registered := true, isLocal := true }, { name := "@fast-local:0:1", registered := true, isLocal := true })]
def event248_1_locals : List (Variable × Variable) := [({ name := "@fast-local:0:0", registered := true, isLocal := true }, { name := "@fast-local:0:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:1", registered := true, isLocal := true }, { name := "@fast-local:0:1", registered := true, isLocal := true }),
  ({ name := "@fast-local:1:0", registered := true, isLocal := true }, { name := "@fast-local:1:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:0", registered := true, isLocal := true }, { name := "@fast-local:0:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:1:0", registered := true, isLocal := true }, { name := "@fast-local:1:0", registered := true, isLocal := true }),
  ({ name := "@fast-local:0:1", registered := true, isLocal := true }, { name := "@fast-local:0:1", registered := true, isLocal := true })]
theorem event248_1_old_gate (remaining : Bool) : oldSupplemental true true true true remaining = false := by simp [oldSupplemental]
theorem event248_1_actual_charges : event248_1_variables.map (fun p => variableCost event248_1_mapping p.1 p.2) = [0,0,0,0,0,0,0] := by decide
theorem event248_1_old_charges : event248_1_variables.map (fun p => variableCost [] p.1 p.2) = [1,0,0,0,0,0,0] := by decide
theorem event248_1_local_separation : event248_1_locals.all (localSeparation event248_1_mapping) = true := by decide
theorem event248_1_local_charges_preserved : event248_1_locals.map (fun p => variableCost event248_1_mapping p.1 p.2) = event248_1_locals.map (fun p => variableCost [] p.1 p.2) := all_local_charges_unchanged _ _ event248_1_local_separation
def event248_1_source : List PaidDeclarationAlignment.Atom := [{ occurrence := 3, tuple := 0 }]
def event248_1_target : List PaidDeclarationAlignment.Atom := [{ occurrence := 0, tuple := 1 }, { occurrence := 1, tuple := 1 }]
def event248_1_edits : List PaidDeclarationAlignment.Edit := [.pair ({ occurrence := 3, tuple := 0 }) ({ occurrence := 0, tuple := 1 }), .insert ({ occurrence := 1, tuple := 1 })]
theorem event248_1_declaration_replay : PaidDeclarationAlignment.replay event248_1_source event248_1_edits = some (event248_1_target, 2, [(3, 0)]) := by decide

end RetainedBothLocalWitnesses
