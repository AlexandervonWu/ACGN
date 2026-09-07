# Five Bounded Obligation Repairs

This work takes P2-02, A2-06, P2-05, P1-10, and P5-15 in that order.
The parent claim text and hashes remain authoritative. A bounded conformance
result does not replace a universal parent claim with a smaller test claim.
The original 132-diagnostic baseline is retained.

| Order | Parent | Work item | Progress |
| ---: | --- | --- | --- |
| 1 | P2-02 | Independent nominal policy fields, constructor and getters | PROVED/DIRECT; bounded two-build replay VERIFIED |
| 2 | A2-06 | Complete JOIN interior-arity guard in producer and verifier | PROVED/DIRECT; bounded two-build replay VERIFIED |
| 3 | P2-05 | One root-container port for an admitted flat declaration | PROVED/DIRECT; bounded two-build replay VERIFIED |
| 4 | P1-10 | General zero-argument CALL capture and validation | PROVED/DIRECT; bounded two-build replay VERIFIED |
| 5 | P5-15 | Built-in identity and empty-cardinality normalization | PROVED/DIRECT; bounded two-build replay VERIFIED |

These are repairs to formalization and implementation evidence, not changes
to the production rewrite inventory. The general proofs replace finite or
weaker models for the first four items; P5-15 gains direct bounded source
conformance. `DIRECT` has its existing bounded meaning. Full parser/JVM
refinement and other parent requirements are not inferred from these results.

## Final Result

Authoritative [machine report](evidence/report.json): **VERIFIED**, five frozen
claims, two clean builds, 887 byte-identical artifacts per build. The run used
Lean 4.33.0, Java 17, UTF-8 compilation, 1 GiB Java process heaps, and no network.

- Closure ID: `bounded-five-v1-5c9400cca03d749b`.
- Input root: `5c9400cca03d749ba25568b406ec968bc0b02d7a8904652f4f57de954b613de6`.
- Per build: 77 general Lean theorems and 93 generated extraction/observation
  theorems; all axiom audits passed without admissions or native decision axioms.
- Per build: 370,365 assertions in the five new Java tests, plus 149 existing
  dependent-chain and 161 existing CALL regression assertions.
- Per build: 17 required rejection controls. Both builds rejected all 17.
- Five Python schema/encoding tests passed. No expected rejection accepts a
  crash or signal as a successful negative control.

The [input manifest](evidence/input-manifest.json) freezes sources, proofs,
libraries, extractors, encoders, claim mappings, configuration, and CI entry
points. [Evidence archive](evidence/evidence.tar.gz) contains both builds'
generated Lean inputs, observation TSVs, artifact hash inventories, command
logs, and the report. [SHA256SUMS](evidence/SHA256SUMS) binds the retained files.
Large copied source trees and class files remain intermediate outputs in `/tmp`.

Separately, the full bounded Java suite passed, including distance-artifact
regeneration smoke tests. The standalone producer/verifier suite passed:
181 verifier checks, 109 writer checks in each of two runs, 68 producer
inspection checks, 31 trusted-pin checks, and 10 parsed-source pair checks.
The census remains `VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`.
Both theory digests and distinct parsed source hashes are retained in its log.
These supporting regressions are not substituted for the five proof claims.

The fresh [parent assessment](../current.md) has 92 ready requirements and
128 diagnostics: 127 from the original 132-entry queue plus the A-01
missing-registry diagnostic. Its five `ABSENT_REQUIRES_EVIDENCE` entries point
to the proof and conformance evidence here; the diagnostic reporter itself
does not claim proof closure. Original parent claim hashes remain unchanged.

```bash
python3 -B scripts/run_bounded_obligation_repairs.py /tmp/acgn-five-reproduction
```

Use a fresh output directory. The driver is also registered in bounded CI,
and all five Java regressions run from `run_bounded_ci_java_tests.sh`.

## Evidence Boundary

Proofs use the pinned Lean kernel without admissions or native decision axioms.
Java execution, javac symbol resolution, Java standard-library contracts, the
explicitly registered extraction/encoding code, SHA-256, and the execution
platform are trusted dependencies, not additional Lean-proved software.
Source extraction checks and tests must be recorded separately from semantic
theorems. Two isolated builds must agree before publishing a bounded result.

No corpus, reward, publication, or release run is part of this repair. Existing
rewrite families, certificate authority, and experimental outputs are unchanged.

## P2-02

The prior theorem described a policy with Boolean flat/unit fields, while Java
stores separate nominal `ArityPolicy`, `SiblingQuotient`, `FlatLicense`, and
`UnitLicense` values. The new compiler extractor resolves the actual four
private final fields, constructor parameter assignments guarded by
`Objects.requireNonNull`, and effect-free field getters. It emits the actual
parameter and getter indices rather than a desired mapping. Unknown fields,
mutable storage, ambiguous signatures, missing null guards, and unmodeled
constructor/getter effects reject.

The runtime regression exercises all current opcodes, two overflow profiles,
five arity boundary representatives, and both variadic flags. This finite
matrix checks representation behavior; it grants no new algebraic law authority.

The first check, `bounded-five-v1-aa20957c978d95eb`, passed in two clean builds
at `/tmp/acgn-bounded-five-p2-second`. It compiled 13 general model theorems
and three generated correspondence theorems, ran 4,303 Java checks per build,
and rejected changed getter, removed null guard, and mutable-field controls.
This is evidence for the named representation boundary, not factory semantics
or a whole-JVM refinement. Later changes require an integrated replay.

One follow-up extractor defect was found before finalization: resolving only
the returned field symbol did not establish that its receiver was `this`.
The extractor now admits only direct own-field reads and verifies nominal
parameter and return types. A compiled foreign-receiver mutation is included
in the final negative controls. The first run above predates this tightening.

The independent source review additionally identified a static method called
through an effectful receiver. Restricting the resolved `requireNonNull`
qualifier to the `java.util.Objects` type prevents evaluating an unrelated
receiver expression. A helper that throws for arity four is the regression
witness. The targeted source rereview passed; final execution remains below.

## A2-06

The old formal mapping checked one unary and one binary three-operand example.
The replacement proves a terminating scan over arbitrary arity lists: JOIN
accepts exactly when length is at least two and every interior arity is at
least two. It relates the indexed loop to an independent `drop 1/dropLast`
specification, exempts both endpoints, and handles ARROW separately.

The compiler extractor checks both producer and verifier guard statement
trees, helper owners, start/end coordinates, and absence of unmodeled effects.
It exports the actual threshold, so a threshold of three is extracted but
cannot satisfy the expected Lean contract. Omitting the first interior fails
the grammar check. Operand type decoding is a declared boundary, not a new
claim to prove the entire parser or dependent type DAG.

The local Java regression passed 358,847 assertions over 6,560 exhaustive
short cases, 1,416 longer cases, 218 retained-family cases, and 567 invalid
inputs. These assertions include unchanged-input checks; their count is not
the number of distinct semantic expressions.

The source review found that a same-spelled `JOIN` field could shadow the
enum reference in an otherwise identical parsed guard. The extractor now
requires the resolved enum constant and its exact type qualifier in each
implementation. Enum spelling alone is not evidence.

## P2-05

The new Lean control model takes the actual required port count and root index
as parameters, proves single-root acceptance and malformed-index/count
rejection for arbitrary inputs, and proves that mapping a substitution over
schemas preserves this control property. Typed-element, associativity,
splice, and unit checks remain distinct obligations rather than assumptions
used to manufacture a root-port proof.

The compiler check binds the entire flat-admission body and the constructor's
unconditional validation call. The Java matrix passed 3,400 checks: 1,080
constructor cases (132 admitted, 948 rejected), 54 polymorphic instances,
24 flat-node results, and wrong source-port-count controls. Fourteen Lean
theorems compile; `TheoryPortsTest` additionally passed 1,014 checks.

## P1-10

The old witness fixed one occurrence number and one callee. The replacement
constructs and validates zero-argument visits for arbitrary occurrence, owner,
visit, callee, call kind, and declared authority. Its validation function
handles malformed lists rather than assuming a `ValidVisit` premise, and
proves the exact two positions and their owners. The lowering theorem removes
the structural END child while retaining the complete CALL declaration key.

The Java observer follows the actual parser call object through the returned
visitor node, certification-source IR occurrence, and certified CALL record.
It exports primitive observations for independent Lean replay. Thirteen
occurrences across five positive fixtures cover local predicates/functions,
`ord/first`, `ord/last`, `integer/next`, and repeated calls in separate bodies.
Two invalid source fixtures exercise public parse/type rejection. The local
regression passed 1,160 checks in two builds with identical TSVs; all twelve
general Lean theorems compile.

An initial regression wrongly required every source CALL to remain in the
optimized matrix. That is not the P1-10 invariant: legal quotient elimination
may remove a matrix occurrence. The repaired probe uses the retained
certification-source matrix, records optimized occurrence counts separately,
and preserves the existing production behavior. It does not create a new
requirement to certify all source normalization or retain every optimized node.
Read-only target-field inspection is part of the observation adapter's trust
boundary; no reflective mutation of live intermediate graphs is required.

## P5-15

The missing evidence was direct source conformance, not a new normalization
law. The replacement standalone model distinguishes reserved spelling,
nominal signature kind, semantic identity, source kind, metatype, and child
count. It proves exact admission for set constants and that arbitrary user
signature identities cannot acquire built-in identity. Empty-cardinality
results hold over arbitrary tuple carriers, including an empty carrier.
`some univ` is not silently equated with true.

Eight positive fixtures cover `some/no/one/lone none`, the `none` union
identity, membership in `univ`, and the complementary cardinality tests of
`univ`. Four negative fixtures retain user declarations `None`, `Univ`,
`NoneNear`, and `UnivNear`. Each is parsed, normalized through Fast and
Certificate-Integrated paths, compared through the five remaining engines,
and rebuilt to Alloy. The solver checks source/reference satisfiability,
backtranslation preservation, and a distinguishing witness where applicable.
The three scopes include no atoms and no Int atoms, one `A` with empty user
signatures, and nonempty user signatures.

The frozen TSV has 36 actual fixture/scope rows. Lean independently checks
their nominal-kind/name/identity correspondence and the expected finite
solver-result vectors. The latter are observations, not a Lean interpretation
of arbitrary Alloy source strings. General semantic theorems, finite solver
checks, and Java-to-observation transport remain separate evidence. Changed
nominal kind, semantic identity, or preservation result each fails replay.

## Remaining Boundaries

The extraction code and observation encoders are hashed and negatively
tested, but their own implementation is not Lean-verified. Java library
contracts, parser/translator correctness, SAT4J, and the execution platform
are explicit trust dependencies. The proofs do not establish exhaustive
coverage of every Java branch, arbitrary optimizer survival, whole-corpus
equality, or a general certificate replay bridge. No other ledger requirement
is promoted because these five passed. Independent review findings and their
bounded follow-up checks are preserved in [reviews.md](reviews.md).
