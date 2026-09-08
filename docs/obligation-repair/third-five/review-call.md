# Independent CALL Review: P1-06 / P1-09 / P1-16

## Verdict

**PASS for the declared general model and bounded DIRECT conformance surface.** No concrete supported-source, pipeline, certificate-binding, or registered proof/evidence-transition blocker was found. All ten registered source mutation controls were independently executed and rejected by the actual extractor after successful javac analysis.

Reviewed 2026-09-08, including `call-notes.md` and its subsequent two tense corrections. The original P1-06, P1-09 and P1-16 statements and claim hashes remain unchanged. Their starting statuses were PARTIAL/DIRECT; Main's current candidate ledger/matrix marks them PROVED/DIRECT with the new bounded evidence references, pending the final aggregate run. This is an independent bounded audit, not the integrated five-obligation closure report or universal Java/parser/compiler refinement. No final closure `VERIFIED` is assigned here. Per the requested review boundary, one fresh compile was sufficient; the final aggregate owns the required two isolated builds and determinism decision.

Only this report was written in the repository. All copied inputs, compilation, registered mutations and generated evidence are under `/tmp/acgn-call-review-m8ys2Y`. No worker build output was reused, no internet was used, and no production, status, experimental result, or static rewrite file was edited. The mechanical-closure skill and protocol were consulted in audit mode.

## Independent Execution

Evidence authority for the commands below is [result.json](/tmp/acgn-call-review-m8ys2Y/result.json), which records exact argv, working directory, exit code and log SHA-256. The [review driver](/tmp/acgn-call-review-m8ys2Y/run-review.py) retains the complete reproducible procedure. It creates a fresh source/library/script snapshot, compiles all Java sources with `--release 17 -proc:none -implicit:none -encoding UTF-8`, compiles the extractor with unchanged `JoinGuardExtractor.java`, and executes each control separately. Re-execution requires a fresh output directory; existing evidence is not overwritten.

| Check | Independent result |
| --- | --- |
| Fresh full-source Java compile and extractor compile | Both exit 0 |
| CALL regression | Exit 0; 91 occurrences, 441 boundary rejections, 4,487 assertions |
| Positive source extractor | Exit 0; 43 exact source objects, validated against the frozen encoder records |
| General Lean model | Exit 0; 23 theorem axiom reports |
| Generated real-observation Lean replay | Exit 0; 91 theorem axiom reports |
| Encoder unit tests | Exit 0; all 17 pass |
| Lean negative controls | All 13 exit 1 because `decide` reports the proposition false; not import, scope or syntax failures |
| `CallExtractionRegressionTest` | Exit 0; 161 checks |
| `ZeroArgumentCallRegressionTest` | Exit 0; 5 fixtures, 13 occurrences, 2 invalid sources, 1,160 checks |
| `OrderedCallValidationRegressionTest` | Exit 0; 7 fixtures, 56 occurrences, 637 rejections, 70 order controls, 5,355 checks |

The model's printed axiom union is exactly `propext`, `Quot.sound`; positive replay proofs depend on `propext`. Neither positive log contains `sorryAx`. Negative error-recovery axiom output is not accepted as proof evidence. The existing extraction test's expected generator diagnostics accompany an exit-0 test result, not an unhandled failure.

### All Ten Source Controls

Each control was applied exactly once to its own copied source tree, with the unchanged hashed extractor. Every invocation completed javac parse/analyze without ERROR diagnostics, then exited **1 with `UNMODELED_SOURCE`**. A pre-existing sentinel output TSV was deleted and no new TSV survived. These are actual extractor executions, not merely replacement-presence checks; mutated variants were analyzed, not separately emitted as runnable class files.

| Registered control | Rejected source boundary |
| --- | --- |
| `call-grouped-declaration-arity` | Grouped parameter name count replaced with one per group |
| `call-import-observed-arity` | Observed arity substituted for ledger-returned arity |
| `call-synthesized-ledger-entry` | Independent lookup replaced by a newly synthesized signature |
| `call-shared-arity-state` | Per-instance final arity changed to shared static state |
| `call-counter-no-increment` | Traversal counter increment removed |
| `call-reuse-guard-omitted` | Past-maximum reuse guard disabled |
| `call-reversed-arguments` | Argument role traversal reversed |
| `call-skipped-repeats` | Every second argument traversal omitted |
| `call-erased-nesting` | CALL returned its first child instead of its own node |
| `call-commutative-policy` | Ordered sequence changed to commutative-idempotent set |

Each label has a corresponding log and retained `mutations/<label>/src` tree under the evidence root. `result.json` additionally records each mutated file hash and the absence of output. No compiler error was counted as a successful rejection.

## Claim And Production Inspection

**P1-06: PASS.** In [MASGVisitor.java](/home/augustus/ACGN/src/is/fivefivefive/ACGN/visitor/MASGVisitor.java:1365), declarations are indexed before call visitation, `declaredArity` sums grouped parameter names, and selection checks kind and arity against those descriptors. Imported resolution returns the independently fixed [library ledger](/home/augustus/ACGN/src/is/fivefivefive/ACGN/alloy/AlloyLibraryCallableLedger.java:20) entry; observed arity selects an entry but cannot construct one. Missing, mismatched and ambiguous entries fail closed. `CallSymbol` stores declared arity and explicit authority independently of source spelling. The model's `selected_from_independent_authority` proves membership and matching metadata; `observed_arity_cannot_create_authority` does not assume a matching entry. Local group counts and the import table in the observer are collected before visitor execution, not reconstructed from the observed child list. Both pinned integer/max overloads are tested through the ledger API; the emitted parser fixtures themselves do not exercise overloaded calls.

**P1-09: PASS.** The model executes `advance` and `allocations` over arbitrary initial counters and arbitrary finite owner schedules. Its nonreuse theorem has no input uniqueness premise: strict increase for the selected owner and monotonicity under other-owner steps establish `Nodup`. Java's [nextTov](/home/augustus/ACGN/src/is/fivefivefive/CanDis/ir/IRAgent.java:938) updates an identity-keyed map before [downlinksFor](/home/augustus/ACGN/src/is/fivefivefive/CanDis/ir/IRAgent.java:693) checks the exact CALL visit and maximum. The first selection, consumed selection, interleaved other owner and final valid signed-int increment were executed against real captured nodes. The pipeline reuse control redirects one nested argument to an already consumed occurrence and reaches the intended reuse exception. Fresh owner distinctness is checked against observed captures; it is not a supplied premise to the general theorem. The proved allocation keys are owner/visit pairs within a traversal, not unbounded global Java `long` occurrence IDs.

**P1-16: PASS.** Separate recursive source and representation datatypes preserve ordered children and explicit CALL/barrier constructors. The left-inverse theorem establishes full-tree injectivity; the repeat, swap, non-deduplication, same-call nesting and barrier results are more than policy booleans. Production [CALL construction](/home/augustus/ACGN/src/is/fivefivefive/CanDis/ir/IRAgent.java:572) traverses every ordered argument, [CALL policy](/home/augustus/ACGN/src/is/fivefivefive/CanDis/core/AlloyOperatorPolicy.java:56) is exact-arity, ordered and nonflat, and `EGraphNode.appendChild` and `appendSortKey` retain sequence occurrences. The [typed adapter](/home/augustus/ACGN/src/is/fivefivefive/CanDis/theory/TheoryAlloyAdapter.java:1595) builds ordered OnePorts and a non-container CALL node; [requireExactBinding](/home/augustus/ACGN/src/is/fivefivefive/CanDis/theory/CallOccurrenceCertificate.java:60) compares the full operator head and every argument endpoint at its role. Repeated semantic invocations may share an e-class while retaining both ports and distinct parser occurrences. No uniqueness assumption is used to discard repeats.

**Observation and authority transition: PASS within the stated trust.** The regression independently counts parser objects and captures actual returned MASG nodes after `super.visit`. It reads certification-source IR, not the optimized matrix, and recursively decodes actual stored certified shape witnesses and operator metadata. Actual canonical observations distinguish swapped, repeated, nested and barrier-bearing examples and equate the repeated identical example. The encoder constructs a joint injective token map from the independent table, source and all observed targets; a previously unseen wrong callee cannot inherit the source token. Explicit authority is encoded independently of its name. `sourceName`, occurrence IDs and source paths remain provenance, not semantic authority; the certified semantic head uses qualified identity, arity, kind and the explicit authority enum. No claim authenticates arbitrary caller-supplied TSVs or promotes a source-path string to parser authority.

**Source/proof connection: PASS as bounded DIRECT evidence, not semantic compilation.** The extractor selects 43 exact owners/members and hashes whole-object AST shapes, literal strings and resolved bindings, including modifiers. Both the extractor and encoder pin complete records; there is no learn-current-source mode. The controls demonstrate rejection of the listed semantic changes. Those pins and hand-registered model labels are trusted correspondence machinery, not a proof of every Java helper's semantics. The proof-to-observation transition is an actual kernel-checked conjunction for each of the 91 independently generated rows, not a digest-only assertion about representation.

## Hash Binding

The canonical [input manifest](/tmp/acgn-call-review-m8ys2Y/input-manifest.json) is a sorted relative-path-to-SHA-256 JSON object, compact separators and one terminal LF. It covers the copied `src`, `lib`, `scripts`, Lean selector/model, notes and scope configuration. Its audit root is **`447b50fc14caec0ac121b935e0737b56f253e4b16820691a947becb436814207`**. It is not the final aggregate's manifest root. Snapshot inputs and their workspace originals were rehashed immediately after execution: both change lists were empty at that point, as recorded in the immutable result. Hashing all copied files does not imply source review of unrelated modules.

After Main announced `/tmp/acgn-third-five-final1`, a second workspace comparison found only three differences within that audit manifest: `call-notes.md`, `scripts/run_third_obligation_repairs.py` and `scripts/test_third_obligation_repairs.py`. All compiled source, libraries, CALL model/regression/extractor/encoder/tests and executed helper inputs still match. The aggregate runner/test were copied and hashed but were not executed by this independent procedure; their later revisions remain outside this review. The notes diff contains exactly the two announced historical-status tense corrections, with no changed claim, boundary or evidence assertion. Current candidate ledger/matrix CALL rows were read and retain the original claim hashes and explicit bounded DIRECT limitations. These later edits do not acquire the old audit root or an inherited closure status; the final candidate must use its own frozen manifest and execution.

Read-only follow-up hashes (not substituted into the completed audit manifest):

```text
67c90d9319942e453669e09560e297efc045e9e164374bf17e32a2ceb18a8733  docs/obligation-repair/third-five/call-notes.md
ac5fe766cbf7e4f58c15a3d1ed38f0411437556353f1536ed8aa1a9f30eb535c  docs/section3-repair-audit/claim-ledger.md
4e331f06f7670c99e38346f206909a7a5888feb3fad46aa401d1978dbfecaf82  docs/section3-repair-audit/requirements-traceability.tsv
```

Whole-file SHA-256 for the CALL package and extractor helper at independent execution:

```text
722784dcbef90997165ebe94cc3fec9a7cac25a462c07bdfb71fe4ea47379f79  docs/obligation-repair/third-five/call-notes.md
9a83023f6c96790b8b6fc422f52db086257e7f0fe666aaee426b0aac4a3c7cd5  docs/section3-repair-audit/formal/CallAuthorityTransitions.lean
fcb0ab6ebbc091afaeeaa8f2442d86b1e76c3cfe5aea5273c9a85914ce7ee21e  src/is/fivefivefive/CanDis/CallAuthorityTransitionsRegressionTest.java
0348a84797b8f153cf59ee787604e3a6dd2d4c1daf13c9a3b40d3293dc48f54b  scripts/java/CallAuthorityTransitionsExtractor.java
9cc4a1f067c92cb63f4591fad1b537cf38a61304b670cc1cf11971dc76c6c6a4  scripts/java/JoinGuardExtractor.java
6077141dba0e51b89ba9961546dd851c4fa4750d906cda8db08315a5499dc2b6  scripts/third_call_replays.py
8e26fd50404b532a65510547c7d56bff6469bc3de0c110d7030f8ae3b3da5b95  scripts/test_third_call_replays.py
```

Selected production file hashes, with inspection restricted to the paths described above:

```text
33f8ccb1bb0908893c248b703f45a12e7ac61cb6189d5d7755e4d3738252afd3  src/is/fivefivefive/ACGN/visitor/MASGVisitor.java
4238cb04cab230dbd0e1c96d173e7943101e0f3c2c50a84b40ca0294acd23037  src/is/fivefivefive/ACGN/alloy/AlloyLibraryCallableLedger.java
88ff43e75372cb3e5c88a9b164e5282896bc6fb3ff116d213d3c856472325365  src/is/fivefivefive/ACGN/alloy/CallSymbol.java
72c3f57102ef7c96d27aa02df2fc39d85fa3a42e2c73c90511892ccd4c929da0  src/is/fivefivefive/CanDis/ir/IRAgent.java
e6545555d4f09f91e5ec2e16b98cc4cd2b649f682ce3e59dfa41e081f980f339  src/is/fivefivefive/CanDis/core/CallMetadata.java
7c82611c58950f459dcaeb1785a38912edf83bff4090c2b44ddc828af3f99110  src/is/fivefivefive/CanDis/core/AlloyOperatorPolicy.java
c4d398b99fb8706f2af89176bfab8f2701cd0937b0aaab010bd211fc5af62f5b  src/is/fivefivefive/CanDis/core/EGraphNode.java
a5462fae4faf0824a6531cf03ff21829f77c71855171ff0d3d14224b65980f61  src/is/fivefivefive/CanDis/theory/TheoryAlloyAdapter.java
723437a7e23cbf345ff4a4e621ded3d409a028226b290c7d1beef88a5d045897  src/is/fivefivefive/CanDis/theory/CallOccurrenceCertificate.java
4b78303e8009fae9be073ca431c9417c5840e6fe53388ff6c4e5623c9d5b4854  src/is/fivefivefive/CanDis/CanonicalAlloyPipeline.java
```

Evidence hashes relative to `/tmp/acgn-call-review-m8ys2Y`:

```text
d62a06d1674490adb1776bba27e2a8e279957e377e23e6b1f29586e0bd8a9f79  run-review.py
94c5f10414bd570d41841e6a9517190f5d34b61ad08b0850feb5dc8f5d0f66f2  result.json
72cfe86f67c3cd462020f55a39243a5a1c1fe23e0ce8130cb5f9a1769dd5c907  call-authority.tsv
bdefb511da8dc77fa4c36781b0ff5aacd10308bbad080b14a77b17dc2042c240  call-authority-source.tsv
f668fea35dbda43e5cc0a30505e9c55f2c24d122795daf0d9aaea72f9eb4bc1d  formal/CallAuthorityReplay.lean
7b318e9fc286a75d0a71de54de7ffa45f1c6ee5ad3ebc319b1660df18a0dd55e  formal/CallAuthorityTransitions.olean
```

## Limits And TCB

- **PROVED:** 23 generally quantified model theorems and 91 finite replay conjunctions, under the printed foundational axioms. Natural arity requires `arity + 3 <= 2147483647`; every modeled executed increment separately requires `before + 1 <= 2147483647`.
- **TESTED/CHECKED:** 7 arity fixtures at `{0,1,2,3,5,8,16}` with 8 occurrences each, 30 nested occurrences and 5 imported occurrences; exact 43-object source census; the listed Java/encoder/control checks. The finite payload grammar uses nonnegative integer atoms, CALL and CARDINALITY, erases parser NOOP wrappers, and decodes unique acyclic certified fixture shapes. Encoder depth is at most 128, child/group lists at most 64, and signature tables at most 128. Arbitrary barriers belong to the general model, not to the finite parser census.
- **TRUSTED:** Lean 4.33.0 kernel, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`, and `propext`/`Quot.sound`; OpenJDK/javac 17.0.20+8-1-24.04-Ubuntu and Java collection/array/reflection contracts; Python 3.10.11 and standard library; hashed local Alloy/parser/JSON jars; observer, extractor/helper and encoder interpretation, including heap/identity-to-token correspondence; source/module/type/ledger authenticity and unproved production helpers, certification and canonical-observation machinery outside the inspected finite boundary; SHA-256, filesystem, Linux 7.0.0-31-generic x86_64, OS and hardware. Runtime toolchains are version-declared trust, not proved or included as binary payloads in this audit manifest.
- **OUT_OF_SCOPE:** universal Java/parser/compiler or whole-corpus refinement; arbitrary optimizer occurrence survival; raw-source replay or independent source completeness for arbitrary certificates; certificate wire-protocol verification; negative machine values, wraparound, allocation/resource feasibility, concurrent heap mutation and `long` exhaustion; hostile arbitrary-object/reflection mutation; new hardening/performance or static rewrite demands; the other two obligations and aggregate closure execution. **P1-19 coordinated source-row-plus-anchor omission remains explicitly OUT_OF_SCOPE.** Fixture-local independent counts do not resolve it.

The audit follows the named parent claims through the stable notes, model/regression/extractor/encoder and freshly executed, hash-bound evidence under this TCB. There are no blocking findings or unresolved focused executions. Final aggregate provenance, two-build reproducibility and closure status remain the integrating harness's responsibility; no absence-of-bugs or universal production guarantee follows from this PASS.
