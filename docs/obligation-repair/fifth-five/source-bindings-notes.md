# Source Occurrence Bindings

## Scope And Integration

This is the bounded `source` candidate for parent **A2-12**, following
`next-candidates-v2.16.md`. It does not promote the parent, change a ledger,
or constitute the aggregate mechanical-closure decision. The original parent
hash is `7238742b9ecea6ad607bbb6fc152d0226175bb229caa2ed5a69352dd5f5aafae`.
The main harness owns frozen manifests, registered claim/verifier hashes,
independent review, complete two-build closure, and final machine evidence.

Only these six new files belong to this slice:

- `docs/section3-repair-audit/formal/SourceOccurrenceBindings.lean`
- `docs/obligation-repair/fifth-five/source-bindings-notes.md`
- `src/is/fivefivefive/CanDis/theory/SourceOccurrenceBindingsRegressionTest.java`
- `scripts/java/SourceOccurrenceBindingsExtractor.java`
- `scripts/fifth_source_bindings_replays.py`
- `scripts/test_fifth_source_bindings_replays.py`

The general proof is in the established engine's formal directory, not in
`fifth-five`. Namespace: `ACGN.FifthFive.Source`. It has 21 named theorems,
each with exactly one `#print axioms`. It imports only `Std`.

Java main: `is.fivefivefive.CanDis.theory.SourceOccurrenceBindingsRegressionTest`.
Zero arguments runs the assertions; one argument names the output TSV. It
removes stale output before starting and writes successful output only after
all fixtures complete. Failure writes only `<output>.failed.tsv` diagnostics.
No diagnostic or synthetic unit-test trace can substitute for implementation
observations. Runtime needs JDK17, compiled producer classes and local `lib/*`.

Extractor: `SourceOccurrenceBindingsExtractor ROOT OUTPUT.tsv`, JDK17. It
resolves the complete source tree with javac, including ownership, declaration
and use types, modifiers, and constructor/method/field bindings. Exactly five
whole-class AST/binding pairs are pinned: `TheoryAlloyAdapter`, `EGraphNode`,
`NormalForm`, `StructuralKey`, and `DependentChainCertificate`. Both Java and
Python contain fixed expected pairs. There is no learn-current-pins mode.
Changed or unresolved sources cannot emit successful correspondence output.

Plugin APIs match the third/fourth dispatcher:

- `generate(build, formal)` returns one `SourceOccurrenceBindingsReplay.lean`,
  namespace `ACGN.FifthFive.SourceReplay`, with 187 audited propositions.
- Inputs are exactly `source-occurrence-bindings.tsv` (171 observations) and
  `source-occurrence-bindings-source.tsv` (five source rows).
- `negatives(build, formal)` returns 16 one-theorem rejection modules.
- `source_mutations()` returns 16 exact-site five-tuples, each ending with
  `SourceOccurrenceBindingsExtractor`. These run only in isolated copies.

The plugin reuses the existing strict ASCII StructuralKey parser and exact
dependent-type constructors from `fourth_chain_replays.py`; that source and
its transitive Python imports are verifier dependencies to manifest. It uses
none of the old Java traces, replay outputs, or closure results as evidence.

## General Contract

`walk` and `walkChildren` recursively enumerate arbitrary finite ordered trees;
`traverse` enumerates the complete phase list. Empty matrices preserve phase
indices. Paths have a phase coordinate and an ordered list of child indices.
The child-injectivity theorem preserves both the parent path and the appended
index; a child cannot move to another phase. The root and children equations
expose the complete executable traversal, rather than a fixed list of paths.

`admitOccurrences` accepts exactly the unchanged traversal with unique object
identities. `index_exact` and `admitted_unique` establish this result generally;
duplicate ownership is rejected. Object identities are model tokens, not
semantic equality, source spelling, e-class IDs, or process-local lineage
numbers. Cyclic JVM heaps are outside the finite-tree model; the actual Java
cycle guard is separately exercised through a public constructed input.

`Content` retains the leaf sort key, binary association, opcode, profile,
exact type, and the ordered left/right slot-map texts. `encodeContent` is an
executable UTF-16-length-prefixed encoder. `content_encoding_grammar` proves,
for every descriptor, that the incremental encoder equals framing the full
recursive grammar-token traversal. `commitment_encoding_grammar` proves that
the occurrence wrapper has exactly its versioned tag, rendered path, typed
source child, and source-content child in the StructuralKey grammar.

Structural injectivity lemmas concern `Content` and `Commitment` constructors.
They DO NOT prove injectivity of `encodeContent`, `encodeCommitment`, arbitrary
Java sort-key strings, or SHA-256. No claim of encoded-string collision freedom
is made. Source-content leaves use the implementation's existing `sortKey`
boundary, including its Set/Bag treatment; they are not raw Alloy syntax.

`checkMatches` tests lineage, the bound repair commitment, and transfer content
separately. It does not confuse the certified source commitment with the repair
commitment. `transferTo` preserves certified source and lineage and changes only
the repair commitment, requiring the same lineage, transfer preimage, certified
path and typed source. Its general theorems prove preservation and successful
matching; mismatching lineage, repair content or transfer content is rejected.
The transfer preimage is a supplied parameter, not a new proof of ACI laws.

## Actual Observations

**Read-only private-indexer observations:** the driver invokes the actual
private `Builder.indexSourceOccurrencePaths(List)` via reflection to read its
complete path map, after public adaptation succeeds for every positive fixture.
This is explicitly read-only invocation, not reflection-based field mutation,
allocation bypass, certificate construction, or forged provenance. The local
indexer's own map construction is its ordinary execution. Returned node paths
are canonically sorted for TSV emission. All public binding observations come
from the real adapter result, not from this reflective read.

**Public retained-source and transition observations:** six normalized fixtures
cover JOIN and ARROW with left association, right association and repeated
equal leaf content. Each exercises public `NormalForm.normalize` and adapter
construction, observes distinct retained/repair objects with positive equal
lineage, and checks `requireMatches`. Python independently reconstructs all
six typed source keys, full dependent DAG/case payloads, exact retained content,
source paths and occurrence commitments. The certificate's occurrence key is
also observed separately. Post-certification rename, child order, exact type
and wrong projection-source transitions are attempted through public APIs.

Four additional unnormalized fixtures retain two equal-typed chains, with
either identical or different content. Equal-valued occurrences have distinct
paths and commitments. Swapping their bindings is rejected by lineage. These
are separate node objects, not duplicate ownership. Public malformed inputs
separately test one object shared by children, one root shared across phases,
an empty matrix, and a cycle. The phase-ownership test uses an otherwise valid
tree, so an earlier child-ownership defect cannot mask its rejection.

**Valid-source temporal/ACI transitions:** in-memory Alloy modules are parsed
through the real parser, MASGVisitor and IRAgent. `some (r.r) and after some
(r.r)` retains two phase-local bindings with distinct paths; cross-phase binding
swap and projection phase reordering reject. `some ((r + r).r)` has different
retained and repaired content but equal admitted transfer preimages and
preserved lineage. Observations check that the binding still contains the
retained content and path, and that its typed child equals its certificate's
typed source. This typed-child equality is an observation, not a separately
reproved parser typing theorem. No temporal phase is flattened into another.

Four supported provenance controls change the mutable repair tree after
normalization but before adaptation, for JOIN and ARROW, independently changing
leaf content or binary association. Public adaptation rejects with
`A dependent source changed outside its certified ACI operands`. They never
mutate frozen objects or impersonate lineage using reflection.

Four real adapter-admitted source-name vectors cover delimiters `a:{}[];@`,
Greek alpha, supplementary U+1D400, and combining `e` plus U+0301. Each observes
core content and a package-visible occurrence-wrapper call using the explicit
test path `phase/10/matrix/child/12` and a small supplied typed key. That path
tests rendering/framing, not an assertion that the fixture has eleven phases.
The complete adapter paths in this census have empty invocation slot maps;
arbitrary slot-map construction and arbitrary leaf-sort-key semantics are not
universally refined by these tests. The general descriptor retains both maps.

The census is fixed independently in Python: JOIN 60, ARROW 60, ownership 4,
temporal 23, ACI 12, provenance 4, encoding 8. Every observation cell is used.
Unknown, missing, duplicate, reordered or extra rows/columns fail closed.

## Encoding And Controls

Canonical TSV and Base64 are checked strictly. Source content is independently
decoded with exact UTF-16 framing, recursive application/leaf grammar, bounded
depth/length, no leading-zero lengths, no truncated/split surrogate payloads,
and no trailing data. Re-encoding must recover the entire observed string.
The Unicode wrapper parser applies the same framing checks recursively.
Only valid Unicode scalar sequences are admitted; isolated Java surrogates
are not covered. Canonical path parsing also checks exact re-encoding.

Lean replays use decoded structures and dictionary-interned subkeys, with
codepoint lists for longer text. Parser/encoder correspondence in Python is
tested TCB, not a universal Lean theorem about the Python implementation.
The general Lean encoding theorems cover the declared descriptor grammar.
Definitional equality does not remove observations: a wrong value either
fails canonical parsing or enters a different, false Lean proposition.
Path replay unfolds the proved recursive traversal equations before deciding
equality against the independently parsed observed path list. It cannot
replace an unequal traversal with the expected list.

The 16 Lean negatives corrupt paths, typed source, retained content, wrapper,
certificate, lineage, frozen-source rejection, same-content occurrence swap,
phase ownership, temporal paths/order, ACI retained/transfer content, and both
supported provenance rejection classes. Successful rejection must be the
shared harness's exact false-`decide` diagnostic, not an import, elaboration,
reduction, timeout, or resource failure.

The 16 source variants change phase/child indexing, repeated ownership, cycle,
lineage, repair matching, transfer checking, all three occurrence-wrapper tags,
content length, leaf content, association traversal, profile content, freezing,
and retained-matrix selection. Each old anchor occurs exactly once. Successful
controls compile and resolve, then fail with `UNMODELED_SOURCE:` AST/binding
mismatch. They are correspondence sensitivity checks, not claims that every
mutant's runtime behavior was exercised.

## Evidence And Limits

Development evidence lives under `/tmp/source-bindings-dev`, entirely offline.
No production behavior changed. No production/shared/ledger/output files were
edited by this slice; no commit, release, or publication provenance was created.
The following are development checks, not an aggregate closure verdict:

- Java: `run-final.log` and clean-build `java.log`, 171 rows, 22 assertions plus
  mandatory transition exceptions; no-argument run also required below.
- Source conformance: `extractor-final.log` on the isolated snapshot and
  `current-source.log` on the current full worktree; five exact resolved pins.
- General proof: `formal/general-registered.log`, 21 clean audits.
- Replay: clean-build `replay.log`, 187 clean audits, approximately 2-3 seconds.
- Encoder: `encoder-final-complete.log`, 17 adversarial tests, synthetic fixtures only.
- Source controls: `source-controls/results.json`, all 16 strict rejections.
- Final negative-control and repeat-build results are recorded in the handoff
  addendum below; earlier builds are not reused after edits.

Failed development evidence is retained, not counted as success:

- `formal/initial.log`: nested-recursion/deriving/name/proof errors in the first
  Lean draft; corrected with terminating mutual traversal and completed proofs.
- `extractor-unregistered.log`: unrelated concurrently written law-test compile
  errors; tests moved to a tracked-source snapshot. Current worktree extraction
  subsequently passes without changing that agent's file.
- `extractor-pins.log`: initial deliberate unregistered-pin rejection used to
  inspect reviewed AST/binding identities, before fixed pins were installed.
- Initial census inspection found a doubled nominal prefix in this new Python
  encoder; the existing constructor already adds it. No producer was changed.
- `formal/actual.log` and `formal/actual-final.log`: oversized long-text kernel
  reductions stopped with exit 143. `formal/probe*.log` and the structural-probe
  attempts isolated the expensive reductions. These are not passing evidence.
- The first negative path proposition did not reduce to `isFalse`; the strict
  rejection checker correctly blocked it. A subsequent `change` attempt also
  failed because the well-founded traversal was not definitionally reduced.
  `build-C/replay.log` retains that failure. Unfolding the proved recursion
  equations fixes the issue without changing the expected paths. The first
  local negative log was overwritten during iteration; its reduction failure
  is reported here, not claimed as immutable bound evidence.
- `build-D/replay.log` and `build-E/replay.log` contain unused-simp warnings;
  the strict build checker correctly blocked both. Removing the unused
  `List.append` simp argument resolves them without suppressing the linter.
- Integration scanning rejected the ordinary definition name `admit`, which
  the shared scanner reserves as a proof escape. It was renamed
  `admitOccurrences`; no proof escape or scanner exception was introduced.

PROVED: the 21 stated Lean descriptor/traversal/grammar/lineage theorems, under
their explicit parameter boundaries. TESTED: the finite real Java observations,
supported public transitions, and separate Python encoder tests. CHECKED:
compiler-resolved pins, canonical traces, independent finite census, audited
replay propositions and registered rejection diagnostics.

TRUSTED: Lean 4.33.0 kernel and admitted `propext`, `Classical.choice`,
`Quot.sound`; JDK17 compiler/JVM/reflection/standard library; pinned local Alloy
and producer dependencies; Python including the strict parsers, independent
fixture constructors and source-to-descriptor interpretation; SHA-256 for
integrity pins; OS/filesystem/hardware; and the main closure machinery.

OUT OF SCOPE: P1-19 independent raw-source authority; A-01 contract-registry
completion; universal JVM/heap/parser/Unicode-codec refinement; arbitrary
sort-key or encoded-string injectivity; hash injectivity; new ACI or dependent
typing laws; full provenance for unauthenticated raw Alloy occurrences;
unlisted claims, future revisions, and automatic original-parent promotion.

Reproduction entry points:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 scripts/test_fifth_source_bindings_replays.py -v
java -cp 'CLASSES:lib/*' is.fivefivefive.CanDis.theory.SourceOccurrenceBindingsRegressionTest OUTPUT.tsv
java -cp 'EXTRACTOR_CLASSES:lib/*' SourceOccurrenceBindingsExtractor ROOT SOURCE.tsv
```

Use the main fifth-five harness to bind these files and dependencies to a
fresh manifest and final closure result. This note cannot confer VERIFIED.

## Final Handoff

READY_FOR_REVIEW / integration. No known slice blocker remains. The shared
fifth dispatcher accepts the `source` area unchanged: 187 replay theorems,
16 negatives and 16 source mutations. The main engine's actual proof scanner
accepts all 21 general theorem audits and 187 replay audits. Independent review
and aggregate frozen-root closure remain main-owned, not implied by this note.

Final development checks:

| Check | Result | Evidence Under `/tmp/source-bindings-dev` |
| --- | --- | --- |
| Encoder tests | 17 PASS, 9.7 seconds | `encoder-final-complete.log` |
| No-argument Java main | 171 observations, 22 checks | `noargs.log` |
| Real source correspondence | Five exact pins on current worktree | `current-source.log` |
| Lean negatives | 16 intended false-proposition rejections | `negative-controls/results.json` and individual `lean.log` files |
| Source controls | 16 intended AST/binding rejections | `source-controls/results.json` and individual logs |
| Fresh slice build F | PASS; general 0.8s, replay 3.5s | `build-F/results.json` |
| Fresh slice build G | PASS; general 0.9s, replay 3.1s | `build-G/results.json` |
| Determinism | All 1,023 artifact paths and hashes equal | `final-development-results.json` |

F/G each freshly compile tracked producer and verifier sources plus this new
regression and extractor, use local libraries without network access, emit the
real observations, resolve the source census, regenerate the Lean replay,
compile the general/replay proofs, and require complete clean assumption
audits. No generated classes or proof outputs are reused between builds.
Comparison covers all 1,018 class files, two TSVs, generated replay source and
both compiled Lean modules. Timing, absolute log paths and parser diagnostic
identity strings are not reproducible artifacts. This is slice development
evidence, not a frozen aggregate claim/provenance report.

All failed drafts and superseded builds described above remain excluded.
Production `TheoryAlloyAdapter.java` and `EGraphNode.java` are byte-identical
to this slice's initial tracked-source snapshot. No production regression or
experiment rerun was triggered by a behavior change, because none was made.

Final code hashes, with this note's hash left to the enclosing manifest:

| Owned File | SHA-256 |
| --- | --- |
| `SourceOccurrenceBindings.lean` | `a71582e72bdd503b8c7a39ae4f439327ce747cbdf6d3511482e0f64f90982a54` |
| `SourceOccurrenceBindingsRegressionTest.java` | `00b8196673ae72c3d558777d567d7b67c8433dcee853b3465776ec128a354f43` |
| `SourceOccurrenceBindingsExtractor.java` | `7bfeefbe51fa914beb64dc9cf08d914e1f20fc1c6acf75e72b497af8d82339b4` |
| `fifth_source_bindings_replays.py` | `b721116ef80b88b86d23c4f86214b52dbaae13a26e4ddc1ba755fc7b6867efd9` |
| `test_fifth_source_bindings_replays.py` | `ef6115af4da1d5e72ee13110e9ab2ca492b756c50de31d449d75d7ca0288d2a1` |
