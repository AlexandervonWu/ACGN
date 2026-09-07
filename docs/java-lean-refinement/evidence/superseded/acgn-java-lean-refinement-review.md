# Bounded Java-Lean Correspondence Review

Review result: **BLOCKED on JLR-06**. One reproducible replay-boundary defect; no additional scoped semantic defect found in this single read-only pass.

Reviewed the requested package and necessary proof/driver dependencies. No internet, producer changes, repository edits, or full rerun. Reviewed source hashes match the recorded input manifest.

Input root: `fe9b3b951766cd0bec103c81d453313e7d88eecd943193ba98b94985d4cf77e5`.
Existing run: `/tmp/acgn-java-lean-refinement-20260907-a`; its report records VERIFIED, two matching builds, and 2,356 rows each. This review does not modify that evidence.

## Finding: Malformed Certificate Trace Output Is Accepted

**[P2] JLR-06**, `docs/java-lean-refinement/closure-config.json:18` promises malformed execution data fail the replay boundary. In `scripts/run_java_lean_refinement.py:153`, certificate `traceOutput` is compared with returned `output` using Python equality. The strict integer validation at line 158 covers only `output` and `traceInput`, omitting `traceOutput`. Python treats `[True] == [1]` as true. At line 187, Lean receives `output`, not `traceOutput`, so this malformed certificate-side encoding disappears before proof checking.

Concrete witness: take actual build-A row 2 (AND/FORBID, flat source `{"children":[{"leaf":1}]}`, singleton output `[1]`) and change only `traceOutput` from `[1]` to JSON `[true]`. The full 2,356-row payload passes `check_rows`; generated replay source is byte-identical to the existing successfully compiled `CertifiedReplay.lean`. No unsupported Java object, reflection, source rewrite, or replacement producer is involved: this is a data mutation at the boundary explicitly covered by JLR-06.

Reproduce from any directory, without writing inputs or rerunning builds:

```bash
python3 -B - <<'PY'
import json, sys
from pathlib import Path
repo = Path('/home/augustus/ACGN')
sys.path.insert(0, str(repo / 'scripts'))
import run_java_lean_refinement as r
run = Path('/tmp/acgn-java-lean-refinement-20260907-a')
payload = json.loads((run / 'A-probe.log').read_text(),
                     object_pairs_hook=r.unique_object)
config = json.loads((repo / r.CONFIG).read_text())
row = payload['rows'][2]
assert row['output'] == row['traceOutput'] == [1]
row['traceOutput'] = json.loads('[true]')
rows = r.check_rows(payload, config)
proof, _ = r.render_observations(rows)
print(len(rows), proof == (run / 'build-A/proofs/CertifiedReplay.lean').read_text())
PY
```

Observed result: `2356 True`. Generated proof SHA-256: `caa66a068df2ff900b83c7fa2cfdc35731848fca61920768cfcf566bac550300`. Existing A/B certified-replay commands both exited 0. Equality with their proof input establishes that downstream Lean checking cannot distinguish this witness; a full replay rerun was unnecessary.

**Minimal correction:** include `traceOutput` in strict list/integer/range validation before endpoint equality, and add a regression requiring this boolean-valued mutation to raise `Blocked`. Freeze the corrected verifier under a fresh input root and rerun the closure. Alternatively, explicitly narrow JLR-06 to its enumerated negative controls rather than claiming malformed-data rejection generally.

This finding concerns the declared malformed-data rejection boundary, not a Java-produced false certificate. The unchanged typed producer emits integer IDs. It does not refute JLR-02's universal selector theorem, JLR-04/05's valid observed constructions, or the recorded build determinism.

## P2-16 Boundary

No global P2-16 closure overclaim found in the reviewed text. `docs/java-lean-refinement/README.md:3` claims only a scoped part; lines 72-75 explicitly leave broader P2-16 separate. Universal flattening/certificate-factory correctness, parser correctness, mixed-head sealing, and source empty normalization remain excluded. Promoting this fragment's result to global P2-16 closure would be unsupported. Documents outside the requested review scope were not audited.
