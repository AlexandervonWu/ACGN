"""Audit theorem constants owned by the requested compiled Lean modules."""
import re
import subprocess
import sys

modules = sys.argv[1:]
if not modules or not all(re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*(?:\.[A-Za-z][A-Za-z0-9_]*)*", m) for m in modules):
    raise SystemExit("Expected Lean module names")
program = "import Lean\n" + "".join(f"import {m}\n" for m in modules) + """
open Lean Elab Command
def auditTheory (mod : Name) : CommandElabM Unit := do
  let env ← getEnv
  let some idx := env.getModuleIdx? mod | throwError "missing compiled module {mod}"
  let mut names := #[]
  for (n, ci) in env.constants do
    if env.getModuleIdxFor? n != some idx then continue
    match ci with
    | .thmInfo _ => names := names.push n
    | .axiomInfo _ => throwError "unapproved module axiom {n}"
    | _ => pure ()
  if names.isEmpty then throwError "no compiled theorems in {mod}"
  for n in names.qsort Name.quickLt do
    let deps ← collectAxioms n
    for dep in deps do
      unless #[`propext, `Classical.choice, `Quot.sound].contains dep do
        throwError "unapproved dependency {dep} in {n}"
    IO.println s!"'{n}' depends on axioms: {deps.toList}"
  IO.println s!"AUDITED {names.size} theorem constants in {mod}"
""" + "".join(f"run_cmd auditTheory `{m}\n" for m in modules)
sys.exit(subprocess.run(["lean", "-DwarningAsError=true", "--stdin"], input=program, text=True).returncode)
