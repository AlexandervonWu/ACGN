# Bounded Review Record

Reviews locate counterexamples; they do not discharge Lean or correspondence
claims. Each finding below concerns the newly added evidence path, not a
reported change to Alloy semantics in the production implementation.

## P2-02

Reviewer `James` independently inspected the source extractor and runtime
matrix after developing the separate nominal-product model.

- Initial result: FAIL. Resolving a getter's field symbol alone did not bind
  its receiver. Main additionally checked nominal getter and parameter types.
- Additional result: FAIL. A static `requireNonNull` call could be qualified by
  `guardReceiver(arityPolicy)`; that expression could throw for an otherwise
  valid arity-four policy. A runtime sample matrix alone does not rule this out.
- Repair: require direct own-field getters, exact nominal signatures, and a
  type-qualified, compiler-resolved `java.util.Objects.requireNonNull` call.
- Targeted rereview: PASS. Both concrete source variants are registered as
  negative controls; their execution belongs to the final machine report.

## A2-06

Reviewer `Boole` independently inspected the JOIN source extractor after
developing the separate scan theorem and producer differential tests.

- Initial result: FAIL. A field named `DependentChainKind` could shadow the
  type qualifier, and its `JOIN` field could hold `ARROW`. The guard's parsed
  expression spelling remained unchanged. The reviewer compiled this variant
  against the current sources in memory with no compiler errors.
- Repair: resolve `JOIN` as the expected enum constant and its qualifier as
  the expected type, separately in producer and verifier.
- Targeted rereview: PASS. The exact shadowing witness is a required extractor
  rejection in the final driver.

## P2-05

Reviewer `Curie` independently inspected the extractor and generated source
contract after developing the separate root-port model and constructor tests.

- Initial result: FAIL. The constructor's `FlatLicense` factories could resolve
  through a same-spelled field. A non-null input index could become a disabled
  license while the guard body still appeared correct.
- Repair: bind the constructor factory qualifiers and callees to the actual
  `FlatLicense` type, and resolve registered nominal types in both constructor
  and guard. This is distinct from checking only calls inside the guard.
- Targeted rereview: PASS. The reviewer recompiled the extractor, observed the
  retained witness reject with exit 1 and no TSV, and the original source
  extract `(1,0)` with exit 0. The final driver repeats this negative control.

The control proof, Java constructor matrix, and compiler extraction remain
separate evidence and are not substituted for each other.

## P1-10

Reviewer `Poincare` inspected the independent row encoder after developing the
separate source observation probe and generic visit model. Result: PASS for
finite model-to-row replay. The generated thirteen proofs all compiled using
only `propext`. Terminology was corrected from raw IR to certification-source
IR; the result does not assert whole-parser refinement or universal survival
of every source occurrence in an optimized matrix.

The main agent removed an initially overstrong optimizer-survival test and
kept intermediate-object mutation out of the required test obligations. The
final driver instead corrupts emitted observation rows at its explicit replay
input boundary: END presence, edge owner, and certified callee. Each must fail
Lean replay, independently of Java source execution.

## P5-15

Reviewer `Ampere` checked the main agent's independent encoder after developing
the separate semantic model and source tests. Result: PASS for the bounded
replay boundary. The reviewer compiled all 72 generated proofs from the actual
36-row TSV and observed each of the three negative rows fail on a false Lean
proposition. Nominal signature kind remains independent of display spelling.
Source/scope strings are provenance observations, not parsed semantic proofs.
The review record is `/tmp/acgn-p515-review.75r1B3`; the final driver independently
repeated the same controls in both clean builds.

## Final Execution

All five scoped reviews are complete. They were not votes establishing
correctness: the final result comes from the registered proofs, extraction,
Java checks, and replay under the declared trust boundary. No review claims
to independently verify its author's own proof implementation.

`bounded-five-v1-5c9400cca03d749b` completed both clean builds with all five
configured claims VERIFIED. The 17 negative controls per build rejected.
The earlier integrated run `bounded-five-v1-48b495f01e229400` also passed, but
predates final traceability descriptions and report provenance fields; it is
superseded by the final hashed run, not used as current evidence.
