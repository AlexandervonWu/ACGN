# A2-01 / A2-02 Bounded Sequence Handoff

The matrix claims are unchanged:

- A2-01: JOIN and ARROW chain carriers are ordered `Seq`, never `Bag` or `Set`.
- A2-02: Duplicate chain operands are retained.

This is an assurance-only candidate for v2.13. No production behavior, rules,
matrix, CI, runner, or ledger is changed by this work. Main owns registration,
input hashes, evidence retention, negative-control integration, and closure
status. Local compilation/test results are not a whole-release VERIFIED claim.

## Frozen Interfaces

Lean namespace: `ACGN.Section3.DependentChainSequence`.
`SourceTree Nat .join` and `SourceTree Nat .arrow` have constructors `.leaf n`
and `.app .join left right` / `.app .arrow left right`. Children must have the
same kind as their parent. A mixed-head subexpression is an opaque leaf whose
identity includes the complete port, not a tree node of the other kind.

`accepts (t : SourceTree Nat k) (target : Target Nat) : Bool` is the replay
entrypoint. For example, after importing the compiled standalone module:

```lean
open ACGN.Section3.DependentChainSequence
example : accepts (.app .join (.leaf 0) (.app .join (.leaf 1) (.leaf 0)))
    (Target.mk .seq [0, 1, 0]) = true := by decide
example : accepts (.app .arrow (.leaf 0) (.leaf 0))
    (Target.mk .seq [0]) = false := by decide
```

The sequence theorem is not relational associativity. Arbitrary finite
homogeneous trees are covered for their sequence projection; production still
requires its existing type, family, arity, context, and source-authority guards.
No theorem admits an ill-typed JOIN or flattens JOIN through ARROW. The Java
`DependentChainInput` interface permits more inhabitants than this model:
arbitrary custom implementations, mutable/forged objects, and mixed-kind direct
applications are excluded. The supported adapter's same-head descent and opaque
leaf construction are separately checked and tested.

## Observation TSV

`DependentChainSequenceRegressionTest [observations.tsv]` writes UTF-8 with LF,
one header, 1,900 data rows, no escaping, timestamps, paths, or platform IDs:

```text
surface profile kind fixture tree source output length counts carrier replay
```

The eleven columns above are separated by literal TABs. All integer lists use
commas, without brackets/spaces. `tree` grammar is `N | (tree,tree)` with
nonnegative decimal N. `length` is output length. `counts` has exactly three
entries: occurrences of IDs 0, 1, 2 in output. `carrier` is `SEQ`.

- `typed`: 1,872 rows. FORBID then MODULAR; JOIN then ARROW; length 2..4;
  lexicographic words over 0,1,2; every full binary association by increasing
  root split recursively. Per kind/profile: 9 + 27*2 + 81*5 = 468 rows.
  `fixture` is `length:wordOrdinal`, zero-based base-3 word ordinal.
  IDs identify three distinct same-type OnePorts, backed by source slots with
  ordinals 91001, 91002, 91003 and type `Relation(SequenceA,SequenceA)`.
  The admitted nominal GraphType literal is `AlloySig:SequenceA`.
- `pipeline`: 12 rows. Both source-command overflow profiles, both heads, then
  `Left`, `Right`, `Swapped`. Parsed functions use `sig A { r, s: set A }`;
  Left is `(r op s) op r`, Right is `r op (s op r)`, Swapped is `(s op r) op r`.
  IDs are local first-occurrence complete OnePort identities: Left/Right
  observe 0,1,0; Swapped observes 0,1,1. Do not compare IDs across these rows.
  Tests independently assert the expected duplicate pattern and distinctness,
  same schema, reassociation equality, and swapped pipeline inequality.
- `certificate`: 12 rows, interleaved immediately after each pipeline row.
  Fresh supported graph insertions of same-type nullary `sequence-r` and
  `sequence-s` operators, using fixed compatibility FORBID/MODULAR profiles.
  These literals are fixture identities, not inferred Alloy source names or
  new production operator registrations. IDs 0/1 mean those two complete
  invocation ports; Swapped therefore observes 1,0,0. Source trees retain the
  requested left/right association. Real production construction, source
  ledger, insertion, finite unfolding, export and public FULL replay execute.
- `barrier`: 4 rows, after the three pipeline/certificate pairs for each
  kind/profile. `(r->s).r` for JOIN and `(r.s)->r` for ARROW. The root has two
  opaque distinct leaves 0,1; the other-head subtree has its own certificate.
  It is not spliced into the outer source sequence.

Typed rows come first. Then each FORBID/MODULAR, JOIN/ARROW block has alternating
pipeline/certificate Left, Right, Swapped rows and one barrier row.
Only certificate rows have `FULL_VERIFIED`; all others have `LOCAL_VERIFIED`.
These are observed test outcomes, not closure statuses or Lean certificates.
The program prints a summary without a path argument. With a path, it writes
the TSV only after every assertion passes. Existing parser diagnostics on stdout
are not deterministic evidence; use the TSV, not a hash of console output.

Plugin checks should validate the exact header, census/order/unique row keys,
profile/head/fixture enums, tree grammar, integer range, and three-entry counts.
Decode each row tree at its one root kind. Generate separate kernel-checked
`by decide` checks for `sourceLeaves tree = source`, `accepts tree target = true`,
`leafCount tree = length`, and `occurrenceCount n tree = counts[n]` for n=0,1,2.
This prevents agreement between two corrupted output fields from hiding loss.
Do not use native evaluation as proof evidence.

## Extractor TSV

Compile `JoinGuardExtractor.java` and `ChainSequenceExtractor.java` together.
Run `ChainSequenceExtractor ROOT OUTPUT.tsv`. Header:

```text
object owner method arity shapeSha256 bindingsSha256 model
```

The seven columns are literal TAB-separated; 28 data rows. `method` is the
exact simple Javac method name (`<init>` for constructors); `arity` is the
number of Java parameters, not chain length. Selectors additionally bind the
first resolved parameter type where overloads need it. `owner` is the complete
resolved Java owner, never a package prefix match. Model names refer to the
namespace above, not identically named Java methods.

Frozen object order and model mapping:

| Objects | Model |
| --- | --- |
| source-application, source-leaf, source-left, source-right, source-leaves | sourceLeaves |
| source-collector, source-leaf-inputs | collect |
| construction, construction-default, schema-factory, schema-copy, schema-kind, schema-quotient, schema-dependent, schema-position, sequence-copy, sequence-elements | construct |
| producer-certificate | accepts |
| wire-source | sourceLeaves |
| wire-certificate | accepts |
| wire-port, wire-container, wire-normalization | construct |
| adapter-application, adapter-barrier | sourceLeaves |
| replay-source | replayLeaves |
| replay-certificate, replay-schema | accepts |

Exact source owners live in `is.fivefivefive.CanDis.theory` (including nested
`CertificateBundleWriter.Assembler` and `TheoryAlloyAdapter.Builder`) and
`org.acgn.cert` (nested `SemanticEvidenceVerifier.SemanticReplay` and
`KernelModel.Schema`). These are literal existing package/class names, not
placeholder or nominal-authority assumptions. The executable TARGETS table is
the authoritative owner/method/arity inventory. Require precisely that set;
missing, duplicate, added, or mismapped objects must block integration.

The extractor reuses `JoinGuardExtractor.shape` on the complete analyzed method
tree, including signature and body, then also binds every string literal in
traversal order. It checks a frozen SHA-256 structural grammar fingerprint and
a second fingerprint of every resolved identifier, member selection, invocation,
constructor, and method reference (including owner, kind and declared type).
Bindings also include sorted element and owner modifiers. The `construction`
row additionally binds `InstantiatedOperator` class modifiers and its unique
`portSchemas` field's owner/type/modifiers, retaining the exact private-final
instance-state contract. This attached state constraint adds no TSV row.
Tokens are encoded as ASCII byte-length plus colon plus UTF-8 token bytes.
No source regex/substring matching, name-only call acceptance, learning mode, or
manual accept override is used. JDK 17, unambiguous owners/overloads and error-free
analysis of both entire source roots are required. Failure removes requested
output and exits nonzero; success writes all rows at once. This closed snapshot
grammar intentionally rejects even harmless unregistered body/literal changes.

This is structural membership of selected Java bodies, NOT a theorem that Java
implements Lean. The trusted interpretation maps singleton leaves, left-then-right
append, index-preserving copies, Seq tags, length checks and per-index equality
to the model. The model does not represent other effects in those checked bodies.
The finite runtime checks support that interpretation; they do not promote the
extractor, javac, parser, or all transitive callees to formally verified code.

## Proof Inventory

All names below are in `ACGN.Section3.DependentChainSequence`, fixed, and each
has an in-file `#print axioms` command:

```text
collect_prefix
construction_preserves_source_sequence
replay_preserves_source_sequence
construction_replay_correspondence
source_length
source_occurrences
construction_preserves_length
construction_preserves_occurrences
construction_is_seq
construction_never_bag_or_set
accepted_iff_source_sequence
constructed_target_replays
accepted_preserves_length_and_count
changed_sequence_rejects
reassociation_preserves_sequence
distinct_order_is_observable
duplicate_is_retained
duplicate_deletion_rejects
```

A2-01 maps primarily to the sequence, correspondence, carrier, accepted-iff and
distinct-order theorems. A2-02 maps primarily to source/construction occurrence
and length preservation, accepted length/count, duplicate retention/deletion.
Shared proofs and tests should execute once and feed both obligations.

## Public Boundary And TCB

PROVED: arbitrary finite homogeneous model trees preserve exact leaf sequence,
length and every identity's count. Construction is Seq. Accepted projected replay
has the exact original sequence. Reassociation preserves that projection only.
All 18 proofs compile with Lean 4.33.0, no unfinished proofs or extra declarations
of assumptions; axiom inventory is `propext` only, except `construction_is_seq`
which uses none.

CHECKED: the 28 closed compiler-resolved source objects. TESTED: 1,900 observations,
same-type order, repeated operands, all associations to length four, short-schema
rejections, immutability, producer certificate rejection of same-typed swaps and
substitution, and twelve public FULL byte-bundle controls with 24 negative variants.
Each bundle variant swaps source branches or substitutes a different same-type
leaf ID. Public Wire/Codec reconstructs the envelope and vocabulary digest, so
the required result is exactly `REJECTED:THEORY_MISMATCH`, not a checksum failure,
UNCHECKABLE, or INTERNAL_ERROR. This does not claim every hostile coordinated
certificate rewrite is rejected at the positional loop specifically.

The public API bridge uses reflection only to avoid compile-time producer-to-
verifier dependency. It calls public `org.acgn.cert` Wire, Codec, Bundle,
VerificationPolicy, CallOccurrenceCommitment, and IndependentVerifier APIs;
it never accesses private fields or invokes internal SemanticReplay methods.
Only verifier **src**, not verifier tests, is needed at runtime.

Fixture policy is explicitly TEST_ONLY: the test temporarily sets and restores
`acgn.provenance.testOverride`; provenance is checked for testOnly. The original
fixture's exported theory is pinned once before mutations. These fresh fixtures
contain no CALLs, and the test checks an empty exported CALL set and pins the
original empty commitment once. This is a fixture-owned assumption, not a way to
acquire authority for unknown source. No mutation is reinspected for new authority.
Fixed compatibility profiles are used for these synthetic exported fixtures;
the parser-pipeline tests separately use actual command-derived profiles.

TRUSTED: pinned Lean kernel and its standard library/propext; JDK 17 compiler,
JVM and Java collections; hashed extractor/TSV encoders and the interpretation
above; existing admitted producer typing, adapter, graph, serialization and
independent verifier dependencies outside this projection; bundled Alloy parser
and visitor for finite pipeline observations; SHA-256, filesystem, OS, hardware.
No internet, solver call, extra axiom, unsafe proof evaluation, or production
rewrite was used. Java memory exhaustion, stack limits, hostile custom chain
implementations, parser universality and unregistered revisions are excluded.

OUT_OF_SCOPE: relational denotation, soundness of all JOIN guards/type DAGs,
all source-command profiles, full parser-to-normalized-IR proof, all graph states,
publication provenance, and complete Java-to-Lean semantic refinement. Parsed
repeated-field functions were observed to hit the exporter's existing
`UNCHECKABLE: retired collision records are not exportable` restriction. A trial
export with command-derived profile also hit the independent verifier's existing
unsupported source-command context version. Neither is repaired or labeled FULL
here. Fresh supported graph certificates provide the distinct public-boundary
checks; pipeline rows never claim FULL export.

## Local Commands And Results

Run from `/home/augustus/ACGN`. All build outputs are under `/tmp`:

```sh
mkdir -p /tmp/acgn-v213-chain/formal /tmp/acgn-v213-chain/classes /tmp/acgn-v213-chain/verifier /tmp/acgn-v213-chain/extractor
/home/augustus/.elan/bin/elan run leanprover/lean4:v4.33.0 lean -o /tmp/acgn-v213-chain/formal/DependentChainSequence.olean docs/section3-repair-audit/formal/DependentChainSequence.lean
javac -J-Xmx1g --release 17 -encoding UTF-8 -cp 'lib/*' -d /tmp/acgn-v213-chain/classes $(rg --files src -g '*.java' | sort)
javac -J-Xmx1g --release 17 -encoding UTF-8 -d /tmp/acgn-v213-chain/verifier $(rg --files certificate-verifier/src -g '*.java' | sort)
javac --release 17 -encoding UTF-8 -d /tmp/acgn-v213-chain/extractor scripts/java/JoinGuardExtractor.java scripts/java/ChainSequenceExtractor.java
java -Xmx1g -cp '/tmp/acgn-v213-chain/classes:/tmp/acgn-v213-chain/verifier:lib/*' is.fivefivefive.CanDis.theory.DependentChainSequenceRegressionTest /tmp/acgn-v213-chain/observations.tsv
java -Xmx1g -cp /tmp/acgn-v213-chain/extractor ChainSequenceExtractor /home/augustus/ACGN /tmp/acgn-v213-chain/extraction.tsv
```

Lean: exit 0, 18 axiom inventories, no warnings. Java regression: exit 0,
`typed=1872 pipeline=12 certificate=12 barrier=4 rejectedBundles=24 checks=55204`.
Extractor: exit 0, `objects=28`. A shared-worktree compile temporarily encountered
the other agent's incomplete CALL test, then passed after that agent's fix;
no change to their file was made here. Integration must use fresh classes.
For snapshot execution, provenance needs a Git root containing src/lib/verifier
inputs; the existing `acgn.repo.root` setting may identify that root. Provenance
bytes are deliberately not part of the deterministic TSV.

A second empty output tree `/tmp/acgn-v213-chain/build2` was compiled with the
same javac/Lean commands (substituting that directory for the output root), then
the regression/extractor were rerun. `cmp` of both observation TSVs and both
extraction TSVs returned 0. These are local repeatability checks, not two frozen
release closures; main still owns immutable input snapshots and manifests.

Final deterministic TSV SHA-256 values:

```text
observations.tsv 17c36bcff8ca50261cd44c860afcc244710e8c0e41f6a6e80bae0a5eecb2668b
extraction.tsv   b229d1c0ace85a39c1ea25579cd8911846336bc06a94cfe8921fae33767cc120
```

The reviewer-supplied retained-state negative was executed locally: copy
`src lib certificate-verifier` into `/tmp/acgn-v213-chain/static-negative`, then
change ONLY that copy's `InstantiatedOperator.portSchemas` declaration from
`private final` to `private static`. No real production file was changed.
Commands after the single declaration mutation:

```sh
java -Xmx1g -cp /tmp/acgn-v213-chain/build2/extractor ChainSequenceExtractor /tmp/acgn-v213-chain/static-negative /tmp/acgn-v213-chain/static-negative.tsv
javac --release 17 -encoding UTF-8 -cp '/tmp/acgn-v213-chain/classes:lib/*' -d /tmp/acgn-v213-chain/static-negative-classes /tmp/acgn-v213-chain/static-negative/src/is/fivefivefive/CanDis/theory/InstantiatedOperator.java
java -Xmx1g -cp '/tmp/acgn-v213-chain/static-negative-classes:/tmp/acgn-v213-chain/classes:/tmp/acgn-v213-chain/verifier:lib/*' is.fivefivefive.CanDis.theory.DependentChainSequenceRegressionTest
```

Extractor exited 1 naming `construction` binding mismatch, leaving no TSV;
mutant javac exited 0; regression exited 1 at
`different-type interleaving cannot overwrite retained operator schemas`.
The new check retains an earlier relation chain, constructs an Int chain, and
rechecks earlier source/target/schema/certificate state for both heads/profiles.
This is a normal supported constructor interleaving, not a hostile-object model.
Candidate binding hashes were generated, then fixed as expected literals;
there is no runtime baseline-update option.

## Negative-Control Recommendations

For A2-01, replace output 0,1,0 by 1,0,0 with tree fixed; change carrier to BAG or
SET; swap the source-collector's left/right calls or the producer's append order;
change the adapter same-head gate to recurse through the other head. The source
extractor must reject mutated bodies even if a fixture happens to mask the change.

For A2-02, remove one occurrence from 0,1,0; change count[0] alone; replace a
same-type repeated operand without changing length; make the positional loop
skip an endpoint. Negative generation must verify it actually changed the input,
and must not rewrite the frozen model/expected source to agree with the mutation.

Wrong resolved owners, unknown enum/carrier values, duplicate/missing TSV rows,
stale output, mixed-kind Lean trees, and malformed tree tokens must block. Keep
these integration controls finite and tied to the two unchanged claims. No
additional static rewrites are needed for this handoff.
