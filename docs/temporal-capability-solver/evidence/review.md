# Temporal Capability Solver Review

**PASS.** No scoped defect found in the current command-mode workaround, failure classification, or reporting path. This is a bounded independent semantic review, not a proof of Alloy/Pardinus/SAT4J correctness.

## Scope and Snapshot

Reviewed only `CapabilitySoundnessCheck.java`, `CapabilityBenchmark.appendSoundnessSummary`, `CapabilitySoundnessCheckTest.java`, `scripts/run_capability_soundness_tests.sh`, and `docs/temporal-capability-solver/TemporalCommandGuard.lean`. Inspected the local JAR implementation and the generated-source command assembly only to establish those paths. No internet, canonicalization/certificate review, inventory expansion, production edits, or published-result writes.

Production SHA-256 values remained unchanged during review:

- `CapabilitySoundnessCheck.java`: `a955f828018809d7be14ba79c463541e28d9bca467a94d3951ea67c3829092cf`
- `CapabilityBenchmark.java`: `ebc6aa359717d94d1334043f9da574ab8284165be53de2b05a49c1f3fcdd498c`
- `lib/alloy.jar`: `ac0ee637172ed035a4ca43327d5e09c05990aa0d073887308e30f88c2471370c`

Also reviewed the user's subsequent minimal UNTIL regression and standalone runner's Phase5SourceRules compilation addition. The incident README and Phase5SourceRules proof contents were outside this review.

## Semantic Findings

- Local `CompUtil.isTemporalModel` visits call arguments but not bodies. The added visitor follows nested/imported predicate and function bodies, with identity-based cycle protection, and covers the same temporal operators as the native detector.
- The parser resolves the check to global facts conjoined with the negated assertion. The guard is added to that counterexample query, not to the assertion before negation. `Command.change(Expr)` retains command metadata, including signature scopes, integer/sequence bounds, trace bounds, expectations, and parent. No predicate inlining, signature injection, or solver-option mutation is introduced.
- On total infinite traces, `after true` is true even for a one-state lasso. Guard equivalence therefore preserves satisfiability and counterexamples. The Lean artifact proves this logical guard only; it does not prove the visitor, bounds computation, translator, or solver.
- The local `ScopeComputer` consults the prepared command before translation. Temporal bounds feed `A4Solution`'s temporal options; the bundled Pardinus dispatch selects `TemporalPardinusSolver` with SAT4J for this bounded route. Default temporal bounds are 1..10.
- The inspected SAT4J solution outcome enum has only SAT/UNSAT and their trivial variants, not a normal UNKNOWN outcome. Null returns and thrown failures remain inconclusive; `Result.failed()` and the CLI reject them. A completed SAT counterexample is conclusive and failing. The summary keeps inconclusive cases separate and does not upgrade historical uncertain counterexamples.

## Independent Commands and Results

All new artifacts are under `/tmp/acgn-temporal-independent-review`. Seven Alloy probes were executed, including the repeated unbounded case through the CLI, plus one Lean compilation: eight focused checks total, below the limit of ten. The supplied full suite was read, not rerun.

Commands below use `R=/home/augustus/ACGN`, `W=/tmp/acgn-temporal-independent-review`, and `CP="$W/classes:$R/lib/*"` as path abbreviations.

```sh
javac --release 17 -encoding UTF-8 -cp "$R/lib/*" -sourcepath "$R/src" -d "$W/classes" "$W/ReviewProbe.java" "$R/src/is/fivefivefive/CanDis/CapabilitySoundnessCheck.java" "$R/src/is/fivefivefive/CanDis/CapabilityBenchmark.java"
java -ea -Xmx1g -cp "$CP" is.fivefivefive.CanDis.ReviewProbe "$W/hidden-past.als" "$W/global-fact.als" "$W/empty-univ.als" "$W/static.als" "$W/unbounded.als" > "$W/probes.log" 2>&1
java -ea -Xmx1g -cp "$CP" is.fivefivefive.CanDis.ReviewProbe "$W/empty-univ-valid.als" > "$W/empty-univ-valid.log" 2>&1
java -ea -Xmx1g -cp "$CP" is.fivefivefive.CanDis.CapabilitySoundnessCheck --root "$W/unknown-run" --output "$W/unknown-report" --per-subtype 1 > "$W/unknown-cli.log" 2>&1
lean -o "$W/TemporalCommandGuard.olean" "$R/docs/temporal-capability-solver/TemporalCommandGuard.lean"
```

Compilation, both diagnostic harness invocations, and Lean exited 0. The CLI intentionally exited 1. The harness prints actual results; it does not assert that every input is a passing equivalence.

| Probe | Observed result |
| --- | --- |
| Nested hidden `before some A` versus `some A`, exactly one A | Guard exposed; SAT counterexample; conclusive failure; trace 2..4. |
| Nested hidden `before` reachable through a global fact | Guard exposed; UNSAT, consistent with the impossible initial-state fact; trace 1..4. |
| Explicit `0 Int, 0 seq` | Alloy rejected the inconsistent scope; inconclusive and failed, never counted as completed evidence. |
| Static predicate equivalence | Command unchanged; UNSAT; temporal=false; trace -1..-1. |
| Hidden temporal dual with `1.. steps` | `ErrorAPI: Bounded engines do not support open bounds on steps.`; inconclusive and failed. |
| Valid zero-scope `univ` temporal dual without explicit `0 seq` | Guard exposed; UNSAT; scope 0, trace 1..1; no added signature. |
| Unbounded request through the actual CLI | Exit 1; all three reports written to the separate output directory; errors=1, inconclusive=1, completed temporal=0, failed=1. |

Every diagnostic command preparation was idempotent and retained the compared bounds. The five-case summary reported conclusive failures=1, completed temporal=2, inconclusive=2, and raw counterexamples among inconclusive checks=0. Logs and probe sources are retained in the directory above.

Local implementation evidence was obtained with `git diff --` on the scoped production files; `unzip -p lib/alloy.jar OSGI-OPT/src/edu/mit/csail/sdg/{parser/CompUtil,parser/CompModule,ast/VisitQuery,ast/VisitQueryOnce,ast/Command,translator/ScopeComputer,translator/A4Solution,translator/TranslateAlloyToKodkod}.java`; and `javap -classpath lib/alloy.jar -c -p kodkod.engine.PardinusSolver` / `javap -classpath lib/alloy.jar 'kodkod.engine.Solution$Outcome'`.

## Supplied Fresh Evidence

Read with `cat /tmp/acgn-temporal-capability-final-a/regression.log /tmp/acgn-temporal-capability-final-a/sample/SOUNDNESS.md` and `tail -n 3 /tmp/acgn-temporal-capability-final-a/sample.log`: **95 regression assertions passed; 29 sampled checks, zero counterexamples, errors, inconclusive results, or failed checks.** Eight samples used bounded temporal mode; all six temporal-normalization samples were exposed and completed at scope 4, traces 1..10. Earlier v2 logs independently recorded 94 assertions and the same clean 29-case sample.

The final runner produced both `.olean` files; the guard log was empty, and the existing Phase5SourceRules log contained `1, 1, 0, 0, 1` on separate lines. Its `set -euo pipefail` sequencing stops on compilation/proof/test/check failure and directs sample output to the requested work directory. No correction is required within the reviewed scope.
