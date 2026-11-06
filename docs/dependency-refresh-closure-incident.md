# Alloy dependency refresh: closure binding-pin incident

## Failure

GitHub Actions run `42272364004` on `dd06d86d7459bef5672d9e2ea92dda42b6ea0cb6`
blocked fourth-five extraction at `build1-extract-profile` and fifth-five at
`build1-extract-law`. Both rejected the same resolved compiler binding fingerprint
for `AlloySemanticProfileFactory`. The strict extractors behaved correctly.

The dependency refresh updated Alloy and its Java API usage but omitted three
dependency-sensitive verifier pins. Passing Java/Lean/unit tests did not exercise
the full fourth/fifth two-build closure extraction. The dependency-refresh report
explicitly did not claim new closure evidence; that remaining validation gap
surfaced in CI.

Failed closure IDs: `fourth-five-v1-37c306e22a2fd401` and
`fifth-five-v1-e2805462cecbeed7`. Original CI artifacts remain attached to
[the failed run](https://github.com/AlexandervonWu/ACGN/actions/runs/42272364004).
Downloaded copies are in `/tmp/acgn-ci-dd06-closure`.

## Independently isolated cause

JDK 17 attribution of the **same** `AlloySemanticProfileFactory` source against
the previous Alloy JAR and the upgraded JAR reproduces these exact fingerprints:

- Unchanged source-shape SHA-256:
  `d9821e2209abefbbc39e5ca2ef3b44fb82a0720b0f89c824b5bde13b28bdafc2`.
- Previous resolved bindings:
  `9f2bb6130489dc740ba241f4811186be27d0ba8526300b0df2b7c6e2e3703818`.
- Alloy 6.2 resolved bindings:
  `e980db5ae20141c0f80954196610a284d59da5ef586ba0d4bd13108c4338cebd`.

The complete binding-sequence diff has four changed entries: two accesses to
`A4Options.solver` change type from `A4Options.SatSolver` to
`kodkod.engine.satlab.SATFactory`; the method-invocation and member-selection
entries for `id()` resolve to the abstract public method on `SATFactory` instead
of the public method on the final nested `SatSolver` class. Its return type
remains `String`. No other binding entry changed.

Local diagnostic inputs/outputs: `/tmp/ProfileBindingProbe.java`,
`/tmp/acgn-profile-bindings-old.txt`, `/tmp/acgn-profile-bindings-new.txt`.
This is a dependency-attribution check, not a proof of equivalence of arbitrary
SAT solver implementations. The Alloy runtime remains a declared trusted
dependency; the existing source-profile tests check the supported boundary.

## Repair and boundaries

The initial repair updates the factory binding pin in `SemanticProfileWireExtractor`,
`LawRecordWireExtractor`, and `fourth_profile_replays.SOURCES`. The fifth law
encoder imports the latter inventory. Keep the source-shape digest, complete
object census, all other digests, exact-match predicates, mutation controls,
Lean theorems and certificate authority unchanged. The old fingerprint is not
accepted as an alternative under the new dependency set.

Add explicit old-pin rejection regressions to both profile and law encoders.
The updated unit suites pass 17 and 19 tests respectively. Full closure repair
requires fresh manifests, two clean builds and all registered source mutations
and Lean replays, not just these unit tests. Existing historical closure reports
must not be edited or reused as evidence for the new dependency binding.

## Follow-on blockers found by full execution

The repaired fifth runner exposed two further stale source pins at
`build1-extract-source` (closure `fifth-five-v1-6209954aa8142d5e`). Commit
`820d909d` added the detached Fast Rewrite comparison projection to `EGraphNode`
and `NormalForm`, and factored snapshot payload assignments into `copyPayloadTo`.
Their whole-class AST and binding fingerprints therefore changed. These are
source changes, not the Alloy dependency-attribution change above.

Review of that commit shows the certified source accessor and source lineage
contract remain intact: the new view keeps the original certification matrix,
and the payload helper retains the previous snapshot assignments. The frozen
candidate's `FastRewriteParityTest` passes 199 checks, including unchanged
certified digests and retained source text for the 14 historical parity pairs.
The retained-source closure still requires its independent 171-observation
census, 187 Lean replay propositions, and source-mutation rejection controls.
Refreshing whole-class pins does not claim a new theorem about every method of
the Fast Rewrite projection.

Update the two pairs in `SourceOccurrenceBindingsExtractor` and
`fifth_source_bindings_replays.PINS`, with explicit rejection regressions for
both superseded pairs (18 source-encoder tests pass). New pairs are:

```text
EGraphNode
shape    2f0f8bbdf5f7651d87f1d217426f01760b279d69d4e526f52c5f7eab87bf6153
bindings 12843c82704c68ca2a0c9344803261826b23e0ba016121a8288f065152f271d4
NormalForm
shape    0503e95cbaeb1f925c33dcc814e2274fb5be3e158138f2667f18c4835e98cf23
bindings 2a09deac7cce49358f82930e5211b8394379d0e8bc8abe448046c67d9424f78b
```

The next run (`fifth-five-v1-b843c1f7ac2dd5e7`) reached Lean and blocked on
the deprecated `if_pos` name under Lean 4.35. Replace it with `ite_eq_left` in
`LawRecordWire.lean`, `CanonicalWireTables.lean`, and the generated source-transfer
replay template. The theorem statements and admitted axioms do not change.
All seven general proof files used by these closures then compile without
warnings. The no-warning gate remains enabled; no linter suppression is added.

## Fresh verification

An initial local attempt at `/tmp/acgn-fourth-alloy62-repair` passed the repaired
extractor, but was interrupted when unrelated benchmark sources changed in the
shared worktree. It is not closure evidence. The replacement candidate at
`/tmp/acgn-alloy62-closure-candidate` was extracted from commit `dd06d86d`, with
only the initial repair overlaid. Subsequent candidates under
`/tmp/acgn-alloy62-closure-final` exposed the follow-on blockers above.
Superseded fourth-run attempts were interrupted rather than used as evidence
for later input manifests. No concurrent benchmark changes are included.

The complete runners use the final isolated candidate
`/tmp/acgn-closure-repair-v3`, containing all ten repair/proof/test files over
`dd06d86d`, to fresh output directories:

```sh
cd /tmp/acgn-closure-repair-v3
python3 -B scripts/run_fourth_obligation_repairs.py /tmp/acgn-fourth-closure-v3
python3 -B scripts/run_fifth_obligation_repairs.py /tmp/acgn-fifth-closure-v3
```

Their machine-readable reports determine closure status for their finite frozen
claim surfaces under the declared TCB. No experimental results are regenerated
by this repair, and no universal Java-to-Lean refinement is asserted.

The fifth closure completed with `VERIFIED`, all five claims passed and zero
unresolved claims, two passing fresh builds, identical artifacts, 365 registered
command records, and no errors:

- Closure ID: `fifth-five-v1-1cceffdd17e68c31`.
- Input root: `1cceffdd17e68c311beca97b203a127891d312e50440a6b33ed0d1137de25024`.
- Machine report: `/tmp/acgn-fifth-closure-v3/report.json`.
- Report SHA-256: `cd98a3d4314026a70a57c3e0d5f7315dff016da818efd9a2c68535d73ea2b923`.
- Identical artifacts per build: 1,177; successful expected-rejection controls
  across both builds: 300.

The fourth closure also completed with `VERIFIED`, all five claims passed and
zero unresolved claims, two passing fresh builds, identical artifacts, 212
registered command records, and no errors:

- Closure ID: `fourth-five-v1-f0e7557e5de09245`.
- Input root: `f0e7557e5de092451a52a69fd23c13079e1c63429ca28eebae259261f91fcdb7`.
- Machine report: `/tmp/acgn-fourth-closure-v3/report.json`.
- Report SHA-256: `aa7144b9a6978e373005f430aa83afc3b5907cc632d8d70e5ec2b857ba3b418c`.
- Identical artifacts per build: 1,171; successful expected-rejection controls
  across both builds: 156.

Both runs used JDK 17.0.20.1 and Lean 4.35.0. The three updated encoder suites
passed 17, 19, and 18 tests. The ten repaired code/proof/test files were compared
byte-for-byte with the frozen candidate before committing. Historical reports
and empirical result directories remain unchanged. These local machine reports
describe this isolated candidate; CI must independently verify the pushed commit.
