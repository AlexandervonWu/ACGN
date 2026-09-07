# Submission Refinement Record, 2026-09-07

## Mechanically Checked Result

The finite package reports **VERIFIED** for SCR-01 through SCR-08. Its
[machine-readable report](evidence/closure-report.json) is authoritative; the
[generated Markdown](evidence/closure-report.md) renders the same result.

- Starting repository commit: `b44c2e47` on `aislop`.
- Closure ID: `submission-container-replay-v1-c389f3321c1180bf`.
- Frozen input root: `c389f3321c1180bf7c96449fcd2679c4d0531c85212472bf21de4120a9edccae`.
- Input files: 337, with no mutation between freeze and final verification.
- Isolated clean builds: two; all Java class, Lean proof-object, replay-source,
  trace-payload, and per-claim outcome comparisons matched.
- Positive Java traces checked in Lean: 726 per build, 242 each for Seq/Bag/Set.
- Negative trace controls checked in Lean: 14 per build.
- Census and encoding regression tests: 12.
- General container-checker theorems: 12.
- Phase 2 theorems compiled and assumption-audited: 55, including 13 added
  AND/OR construction theorems; 11 existing native proofs now use `decide`.
- New Boolean construction regression: 68 checks per build.

Lean 4.33.0 checked the proof terms. The assumption inventories contain only
the declared standard logical dependencies `propext`, `Quot.sound`, and
`Classical.choice`. There are no declarations using the prohibited proof escapes
in the two scoped formal modules or their generated replay obligations.

The [evidence archive](evidence/evidence.tar.gz) contains the input manifest,
raw trace payloads, generated Lean proof source, proof-assumption logs, command
logs, reports, and deterministic output manifests. Its SHA-256 is
`c7fb63fab4dae0cf3723b63dc00d08e7d9eaf6ae2896bfe5dfea247fe7d81f22`;
the value is also in [archive-hash.json](evidence/archive-hash.json).
All 31 entries in its output hash manifest were independently rehashed after
packaging. The original full build directories are at
`/tmp/acgn-submission-container-final-20260907`.

The archive records a dirty source worktree. Its source-file hashes identify
the exact verification inputs; the starting Git commit alone does not identify
the new patch. Review and documentation output files are not proof inputs and
do not confer equality authority.

## Independent Review

The implementation tasks were separated: agent
`01a07c9a-3adf-75e1-9a38-fecb8f1ad876` developed the Boolean proof/test extension,
and agent `01a07c9b-2989-7542-b8ae-01e672255fc3` developed the Java probe. The
integrating agent authored the independent Lean trace checker, driver, evidence
format, census checks, and CI integration, and executed the final closure.

Fresh reviewer `01a07ca2-778e-7aa3-9920-f21ff5e6da8a` returned `PASS` on the
bounded replay logic. Its independently compiled distinguishing witnesses were:

| Input | Kind | Output | Fibers | Result |
| --- | --- | --- | --- | --- |
| `[2,0,2]` | Set | `[0,2]` | `[[1],[0,2]]` | Accepted |
| `[2,0,2]` | Bag | `[0,2]` | `[[1],[0,2]]` | Rejected |
| `[2,0,2]` | Seq | `[2,0,2]` | `[[2],[1],[0]]` | Rejected |
| `[2,0,2]` | Set | `[0,2]` | `[[0],[1,2]]` | Rejected |

It also independently rejected missing-row, duplicate-input, Boolean-as-slot,
and duplicate-JSON-key cases. Its initial review explicitly left fresh clean
builds and final reporting to the integrating agent. The final closure above
supplies that execution evidence. Review opinions are supplementary; they do
not discharge the eight claims or establish universal semantic correctness.

The same independent reviewer performed a final bounded review of the assembled
driver, archive/provenance reporting, required proof inventory, and added fiber
corollaries. It returned `PASS` against the frozen input root above with no
concrete scoped blocker. It retained three explicit limitations: the extraction
and toolchain are trusted, individual claims reference shared run-wide logs,
and the evidence archive requires the matching repository sources and
dependencies for reconstruction. Those limitations are reflected in the
declared trusted components and reproduction instructions.

## Compatibility Checks

The existing bounded Java suite completed successfully. Selected results:

| Check | Result |
| --- | --- |
| CanonicalAlloyPipelineTest | 2,041 checks |
| CanonicalBacktranslatorTest | Passed |
| AlloySourceRuleRegressionTest | 332 checks |
| QuotientRepairDistanceTest | 2,266 checks |
| TheoryCanonicalizationTest | 14,481 checks |
| TheoryPortsTest | 1,014 checks |
| TheoryCertificatesTest | 445 checks |
| TheoryRebuildTest | 522 checks |
| Distance artifact regeneration | Passed in a temporary directory |
| Existing rewrite Lean gate | Passed, five catalog-mapped formal files |

The full [bounded Java log](evidence/acgn-submission-bounded-java-20260907.log)
has SHA-256 `2cef4e1224dd279a159abf6e025006614f498c8a15b4d4ec264c0617291f611b`.
The [rewrite Lean log](evidence/acgn-submission-rewrite-lean-20260907.log) has
SHA-256 `729501687191f8096f402d0aae7762f2debcbc12d2c8060671b11519e7926c3a`.
These are additional regression evidence, outside the frozen eight-claim
closure, and are not used to infer broader proof coverage.

## Remaining Obligations

Regenerating the existing Section 3 catalog yields 191 claims, 87 ready rows,
and 132 open diagnostics. The [assessment log](evidence/acgn-submission-assurance-20260907.log)
has SHA-256 `e3678c9780201149a562cf3a1ada1610e5d54a70e977f51e1f10c1618744de2d`.
P2-16 stays `PARTIAL/DIRECT`, with its improved proof and test references.
This pass does not remove open diagnostics by weakening their predicates.

The open surfaces include complete Java/parser refinement, source-child
derivation into normalization inputs, general graph/certificate replay,
independent production theory authority, and the broader assurance coverage
and review obligations. Constructor replay establishes no new production law.
Bag/Set canonical ordering and minimality are also beyond its semantic quotient
checks. The existing empirical trees, publication manifests, and repair metric
semantics have no changes in this patch; no full-corpus experiment was run.
