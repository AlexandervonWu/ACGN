# Next Five Obligation Repairs (v2.13)

This package continues the fixed obligation queue without changing the five
parent statements or their claim hashes. The order is P2-06, A2-01, A2-02,
P1-08, then P1-05. It adds proof and correspondence evidence; it does not add
rewrite rules or certificate authority.

| Order | Parent | Exact surface | Progress |
| ---: | --- | --- | --- |
| 1 | P2-06 | Flat element/result type equality under one substitution | PROVED/DIRECT; bounded replay VERIFIED |
| 2 | A2-01 | Ordered dependent JOIN/ARROW sequences | PROVED/DIRECT; bounded replay VERIFIED |
| 3 | A2-02 | Dependent-chain occurrence multiplicity | PROVED/DIRECT; bounded replay VERIFIED |
| 4 | P1-08 | Complete CALL validation without neighboring-visit fallback | PROVED/DIRECT; bounded replay VERIFIED |
| 5 | P1-05 | Ordered CALL arguments through supported boundaries | PROVED/DIRECT; bounded replay VERIFIED |

## Final Result

The authoritative [machine report](evidence/report.json) is **VERIFIED**:
five configured claims, two clean builds, and 1,026 identical artifacts per
build. The [manifest](evidence/input-manifest.json) binds 603 inputs.

- Closure ID: `next-five-v2.13-c627da30a64e6650`.
- Input root: `c627da30a64e66506a1dcb777fd94e9dcbee7e2b5a64ad7bcb7e37557d360da0`.
- Per build: 48 general Lean theorems and 2,636 generated propositions;
  every positive proof compiled and passed its axiom audit.
- Per build: 66,872 assertions in the three new Java tests, plus 187 existing
  law-policy and 161 existing CALL assertions.
- Per build: 12 rejected Lean observation controls and nine rejected source
  variants. The chain test also rejected 24 semantic bundle variants.
- Python: 33 runner tests and seven encoding tests passed.
- Both builds recorded the same TEST_ONLY fixture-source commit:
  `e42d37c2d0608419e5e153730fc04e35767735f9`.

The [evidence archive](evidence/evidence.tar.gz) contains both builds' generated
proofs/observations, control inputs, hash inventories, reports, and command
logs. Rebuildable source snapshots, classes, and temporary Git objects are
excluded. [SHA256SUMS](evidence/SHA256SUMS) binds the retained outputs.
[Review records](reviews.md) retain the independent findings and follow-ups;
[stopped-run records](incidents/) remain separate and labeled BLOCKED.

The full bounded Java suite and standalone producer/verifier harness passed.
The standard exported census remains one verified, two uncheckable, and zero
rejected; both trusted theory digests and distinct parsed-source hashes remain
unchanged. The publication snapshot verifier checked all 5,808 files. No
production Java, experimental tree, authority ledger, or archived JAR changed.

The parent assessment now has 97 ready requirements and 123 diagnostics. The
original queue remains immutable: ten original diagnostics are absent with
evidence in the two five-claim packages, 122 remain, and the separate A-01
missing-registry diagnostic remains. Full assurance is still `INCOMPLETE`.

```bash
python3 -B scripts/run_next_obligation_repairs.py /tmp/acgn-v213-next-five
```

Use a fresh output directory outside the repository. The runner is registered
in bounded CI and supports either a checkout or the extracted assurance bundle.

## Claim Boundary

General theorems describe the named algorithms and typed interfaces. Java
correspondence is established by registered compiler extraction and bounded
direct observations, with their encoders explicitly trusted and tested.
`PROVED/DIRECT` retains its existing meaning: a matching proved model plus
direct bounded implementation coverage, not universal parser/JVM refinement.
The original diagnostic baseline remains immutable. No finite test is used
to narrow an authoritative parent claim.

The verification inputs include source, proof, library, extractor, observation
encoder, configuration, claim mappings, and CI entry points. Publication
requires two isolated clean builds with matching deterministic artifacts.
Lean 4.33.0 is explicitly selected in each isolated proof directory. The
runner makes no network requests and does not run the full corpus.

## P2-06

The old formal mapping projected a Boolean homogeneous-type premise. The
replacement models `One`, `Seq`, `Bag`, and `Set` schemas, proves the exact
flat-type validation condition, and proves that applying the same type
substitution to the schema and result preserves it. The proof is parametric
in the exact type carrier and substitution function; it does not assume
injectivity or equate different instantiations by operator spelling.

The compiler extractor checks constructor-dominated validation, exact
`One(outputType)` comparison, container element access, and the two uses of
the captured instantiation map. It also checks nominal method/type owners.
The runtime matrix uses an independent recursive expected substitution over
all six `GraphType` kinds, including nested types, with 675 observations.
It tests mismatched declared types, missing/extra substitution entries, and
cross-instantiation operands. Existing registry/adapter regressions retain
authenticated relational widening and type-coercion checks.

Structural fixture declarations are used only to test the constructor. They
confer no semantic or certificate authority. The parametric proof does not
purport to implement Alloy subtyping or verify the entire Java `GraphType`
interpreter. Those boundaries remain visible in the declared trust model.

The independent review found an extraction/coverage gap: a source variant
with static instantiated `portSchemas` passed the first checks. Instantiating
Int and then Bool made the retained Int instance expose a Bool element type.
The production field was already private/final per instance; this was a
false-acceptance hole in the new verification tooling, not a production
behavior change. The extractor now enforces per-instance private/final state,
the Java regression checks retained instances after a second instantiation,
and the closure includes this source mutation as a required rejection.

The first observation encoder used verbose structural-key strings; kernel
evaluation hit its recursion bound. The final test emits compact, lossless
kind/symbol-length/recursive-argument strings, not type hashes. All 675
observations replay with the normal Lean limits. The Java equality assertions
and independent recursive expected substitution are unchanged.

## A2-01 and A2-02

The [chain handoff](chain-notes.md) documents 18 general theorems, 28 frozen
compiler-resolved source objects, and 1,900 direct observations. The model is
indexed by a single root operator: different-head expressions are opaque
leaves, not flattened child applications. It proves sequence, length, and
per-identity occurrence preservation; it does not assert unconditional JOIN
associativity or replace the independent type/arity guards.

The observations distinguish 1,872 typed construction cases, 12 parsed local
pipeline cases, 12 separate fixture-owned FULL certificate checks, and four
mixed-head barriers. FULL fixtures have 24 same-type source-swap/substitution
rejections at the public verifier boundary. Parsed cases are not labeled FULL:
their existing export limitations are documented explicitly. No authority is
inferred from fixture names, command spelling, or this model's carrier tags.

The source extractor also binds field modifiers. The same private-final to
static-state witness found during P2-06 review is rejected by the chain
extractor and a retained-instance check. This strengthens evidence for the
existing implementation without changing production storage or semantics.

## P1-08 and P1-05

The [CALL handoff](call-notes.md) documents 17 general theorems and 56 observed
calls at seven arities. The recursive validator reads arguments rather than
assuming a valid visit, proves exact roles and source order, and never searches
another visit bucket. The Java checks include 637 validator rejections and
70 order controls. The source extractor resolves three control regions.

Replay uses independently observed source and target callee tuples. Both sets
are included in the injective token map, so a different target cannot silently
inherit its source's token. Numeric payloads are decoded separately from the
parser, MASG edges, retained certification-source IR, and certified operands.
The Java interpretation assumes the documented signed-index bound; it does
not prove allocations of arbitrary size or universal parser refinement.

## Integration Incident

The first integrated run stopped before the chain certificate checks because
the isolated source snapshot had no Git repository. `CertificateProvenance`
correctly requires Git capture even under its existing `TEST_ONLY` override.
No producer guard was weakened. The runner now initializes and commits each
hashed temporary snapshot using fixed fixture identity/date and local Git,
then records and compares its `fixtureGitCommit` in both builds. That commit
identifies **verification inputs only**, not a release or result-producing
commit. The TEST_ONLY fixture policy remains explicit. This also makes the
new runner usable from the extracted assurance archive without a `.git`.

A unit test creates two independent miniature fixture repositories and checks
their equal commits and clean state. The stopped run and exact failure remain
recorded separately from the eventual verified evidence.

A second integration attempt correctly blocked when the original exhaustive
source census treated the generated `.git` files as unexpected inputs. The
final composition distinguishes this generated metadata only after explicit
fixture initialization. It still checks every other source file and hash,
rejects extra source files, and requires the final fixture HEAD and clean
status to match the initial commit. The real-Git unit test now exercises that
composition and both changed-source and extra-file rejection.

The next attempt blocked because this explanatory README was edited during
the input freeze. The definitive input set now distinguishes executable
verification inputs and the two explicit schema/TCB handoffs from explanatory
summaries and review narratives. The config lists those handoffs as hashed
inputs; this README and the reviews do not determine any pass condition.
Changing source, proofs, configuration, either handoff, or a verifier still
invalidates a run. Generated summaries can reference the final report without
creating a circular input/report hash dependency.

The fourth attempt completed both builds but the final outer audit still used
the pre-Git census mode. The same explicit generated-metadata handling now
applies there. The lifecycle fixture writes an actual `.git/HEAD` file, so
this composition is covered rather than simulated as an empty directory.
The fifth frozen run above completed every audit; earlier reports were not
edited or promoted to success.
