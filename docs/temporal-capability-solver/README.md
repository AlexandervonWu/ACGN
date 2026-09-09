# Temporal Capability Solver Repair

## Incident

The v2.15 publication retained six temporal checks as inconclusive. Its
explanation that a temporal backend was absent was incorrect. The bundled
Alloy 6.1 contains Pardinus bounded temporal solving using SAT4J.

The actual transition failure is in Alloy 6.1 `CompUtil.isTemporalModel`:
its `VisitQueryOnce` visitor visits call arguments but not callee bodies.
With no mutable signatures/fields and all temporal operators inside called
predicates, `ScopeComputer` chooses trace bounds `-1..-1`. Pardinus then
warns that the formula will be reduced to a possibly unsound static version.
`CapabilitySoundnessCheck` additionally exempted every case labelled
`temporal_normalization`, including potential solver errors, before solving.

Smallest retained reproduction:

```alloy
sig A {}
pred p { not ((some A) until (no A)) }
pred q { (no A) releases (some A) }
assert CapBenchEquivalent_captest { p iff q }
check CapBenchEquivalent_captest for 4
```

On the unprepared command the bundled solver reports a counterexample with
trace bounds `-1..-1`. The repaired command reports no counterexample with
trace bounds `1..10`. The predicates themselves are not changed.

## Repair Boundary

`CapabilitySoundnessCheck.prepareCommand` inspects reachable predicate and
function bodies as well as arguments, recording visited function identities.
If the existing detector already recognizes the temporal model, or the
command is static, the original command is returned unchanged. Otherwise
the check query `Q` becomes `Q and after true` using Alloy AST constructors.
This exposes a temporal operator to the existing mode detector. The same
SAT4J backend then runs through Pardinus's bounded temporal path.

No predicate inlining, new signatures, altered `univ`, binder manipulation,
changed source scopes, certificate issuance, or canonical rewrite is involved.
This is a capability-check command workaround, not a shared Alloy/parser fix.
The normal experiment, reward and certificate producers are unchanged.

The checker verifies that a temporal solve returns positive, ordered trace
bounds. Errors, missing results and inconclusive checks now fail the run.
Temporal counterexamples are counted normally. Reports record actual temporal
mode, whether exposure was required, overall scope and min/max trace bounds;
report generation no longer hardcodes an absent backend. Historical unknown
results remain unknown when read by the current report generator.

## Proof And Correspondence

[TemporalCommandGuard.lean](TemporalCommandGuard.lean) proves five constructive
theorems over an arbitrary state space with a total successor: `after true`,
pointwise guard equivalence, preservation of satisfiability and unsatisfiability,
and preservation of the facts-plus-counterexample query. Alloy's infinite
traces, including lassos used for bounded checking, have a successor at every
position. This argument does not assume a final state with no successor.

The existing six duality proofs are recompiled in
`docs/section3-repair-audit/formal/Phase5SourceRules.lean`:

| Capability subtype | Lean theorem |
| --- | --- |
| always-eventually-dual | `negated_always_is_eventually_not` |
| eventually-always-dual | `negated_eventually_is_always_not` |
| historically-once-dual | `negated_historically_is_once_not` |
| once-historically-dual | `negated_once_is_historically_not` |
| until-releases-dual | `negated_until_is_release_not` |
| since-triggered-dual | `negated_since_is_triggered_not` |

The Java correspondence is bounded execution evidence: tests exercise the
actual parser, command preparation and solver, including nested/imported calls,
functions, all 11 temporal operators (including prime), command-context
preservation, idempotent preparation and deliberately wrong equalities.
The logical guard is proved; whole-Java refinement and correctness of Alloy,
Pardinus and SAT4J are trusted here, not established by these tests.

## Results

The original six files `generated_cap002500.als` through
`generated_cap002505.als` all complete with no counterexample at overall scope
4 and trace bounds 1 through 10. The full deterministic family/subtype sample
has **29 checks, zero counterexamples, zero errors and zero inconclusive
results**. Eight commands use temporal solving: the six repaired cases and
two already temporal base models outside the temporal-normalization family.

This is finite-scope/trace evidence, not an unbounded semantic proof.
The regression suite also requires real temporal counterexamples for wrong
equalities and a nonzero runner failure for a temporal negative control.

Two fresh builds each passed **95 Java assertions** and compiled both Lean
files. Their complete Java class directories, both Lean objects and sample
CSVs compare byte-for-byte; JSON generation times and progress timings are
not claimed deterministic. The broader bounded CI suite passed **46 Java
entry points** plus the distance-artifact regeneration smoke check. A bounded
independent review returned PASS after seven focused Alloy probes and an
independent guard-proof compilation.

Raw sample results and logs are under [evidence/build-a](evidence/build-a/)
and [evidence/build-b](evidence/build-b/). The intentional negative-control
CLI prints one failure before the regression suite asserts that this is the
required outcome. [The review record](evidence/review.md) and its probe
archive retain the separate findings. Input and evidence checksums bind these
records; this package does not claim a complete artifact-wide closure.

The published v2.15 empirical directories, manifests, JAR and release remain
unchanged. New results are kept alongside this incident, not substituted into
the archived clean run. Its 5,808 imported output hashes still verify.
The [v2.16 validation-only publication](../../publication_runs/659e248c-d3d6-4a2b-8d99-67a0ebcf9eb4/capability_validation/SOUNDNESS.md)
records the subsequent clean-source run of these 29 checks, with its separate
manifest and frozen JAR.

## Reproduce

Java 17, Python-free shell tooling and the pinned Lean toolchain suffice;
no new solver installation or network access is required after tool setup.

```bash
./scripts/run_capability_soundness_tests.sh /tmp/acgn-temporal-checks
```

Use a fresh output directory. The runner compiles current Java sources and
the new guard plus existing duality proofs, executes the regressions, and
reruns the 29-case sample into the supplied directory. Future ordinary
`run_capability_benchmark.sh` runs automatically use the repaired checker.
To check an existing generated corpus without changing its reports:

```bash
java -ea -Xmx1g -cp '/tmp/acgn-temporal-checks/classes:lib/*' \
  is.fivefivefive.CanDis.CapabilitySoundnessCheck \
  --root capability_benchmark --output /tmp/acgn-temporal-recheck --per-subtype 1
```
