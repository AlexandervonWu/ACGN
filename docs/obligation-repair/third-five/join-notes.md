# A2-04 Guarded Relational JOIN Chains

This is the A2-04 candidate contribution to the third bounded assurance batch.
The aggregate registry and harness own closure status, manifest, provenance,
two isolated clean builds, and the final machine-readable report. This note
does not promote the parent ledger, announce a closure run as VERIFIED, or
claim universal Java refinement. No production rules or experiment behavior
are changed.

## Integration Contract

- Proof: `docs/section3-repair-audit/formal/GuardedJoinChain.lean`.
- Frozen proof imports, in build order: `DependentChainSequence.lean`,
  `DependentJoinGuard.lean`, `PhaseA2DependentChains.lean`.
- Java main: `is.fivefivefive.CanDis.theory.GuardedJoinChainRegressionTest`.
  Zero arguments runs all assertions; one argument writes the observation TSV.
  Recommended output: `guarded-join-chains.tsv`.
- Extractor: `scripts/java/GuardedJoinChainExtractor.java`, compiled together
  with existing `scripts/java/JoinGuardExtractor.java`. Invoke
  `GuardedJoinChainExtractor SNAPSHOT_ROOT OUTPUT_TSV`. Recommended output:
  `guarded-join-source.tsv`. No generated Java helper is required.
- Delegate: `scripts/third_join_replays.py`; `generate(build, formal)` returns
  `[('GuardedJoinChainReplay.lean', source, 1025)]`. The generated namespace is
  `ACGN.ThirdFive.JoinReplay`, disjoint from other delegates.
- `negatives(build, formal)` returns 12 `(label, 'RejectGuardedJoin.lean', source)`
  tuples. Each slice closes its namespace. Rejection must arise from a false
  target proposition, not incomplete syntax, missing imports, or failed reduction.
- `source_mutations()` returns 12 `(label, relativePath, old, new,
  'GuardedJoinChainExtractor')` tuples for isolated snapshot mutation only.
- Encoder tests: `PYTHONDONTWRITEBYTECODE=1 python scripts/test_third_join_replays.py`.
  The aggregate plugin may concatenate this delegate's lists with other lists.

## Frozen Claims And Predicates

| Local claim | Required mechanical check | Block condition |
| --- | --- | --- |
| A2-04-SEMANTICS | Lean checks all 34 named theorems and their axiom inventories | Compilation failure, warning, missing theorem, or forbidden assumption |
| A2-04-SOURCE | Javac resolves exactly four registered whole methods, matching AST and binding hashes, exact owner/signature/modifiers, and typed guard grammar | Missing/ambiguous method, compiler error, changed shape/binding/modifier/guard |
| A2-04-OBSERVATIONS | Java completes the fixed 1,021-row census and all assertions | Any assertion failure, absent output, or different census |
| A2-04-REPLAY | Strict encoder emits 1,025 named, namespaced theorems; Lean checks each observed proposition | Schema/input/census drift, false proposition, missing theorem, or compilation failure |
| A2-04-NEGATIVE | All 12 closed negative modules fail on their false propositions | Any acceptance, infrastructure error, or unrelated diagnostic |
| A2-04-VARIANTS | Each of 12 unique source anchors mutates exactly once and its extractor rejects | Missing/multiple anchor, accepted mutation, or unrelated infrastructure failure |
| A2-04-ENCODER | Eight fail-closed unit tests pass | Missing or failing test |

Claims, source hashes, and verifier hashes must be bound by the aggregate
manifest before a closure run. All verification-relevant Java sources, JARs,
the four Lean modules, both extractors, replay delegate/helper modules, test,
runtime/compiler configuration, and harness are inputs. Any later mutation
invalidates evidence from that root. Development checks are not a substitute
for the aggregate's two clean builds and deterministic artifact comparison.

## What Is Proved

`join R S out` is actual set-valued relational composition:
there are `pre`, `boundary`, and `suffix` such that `R (pre ++ [boundary])`,
`S (boundary :: suffix)`, and `out = pre ++ suffix`. It existentially matches
the last column of the left tuple with the first column of the right tuple,
and deletes exactly those two columns. Relations are predicates on tuples;
they need not be finite, nonempty, or functional. This is not a theorem about
lists of operand identifiers alone.

`Operand` retains a positive arity and a relation whose tuples all have that
arity. `Tree` reuses v2.13 `SourceTree` at the homogeneous JOIN head. Different
operator heads may be opaque relation leaves; no cross-head flattening rule
is introduced. A tree has at least one leaf; the executable admission guard
requires at least two. The empty operand sequence has no JOIN denotation or
invented unit here.

`join_rotation` proves ternary relational equality from the *middle relation's
tuple width*, without assuming associativity. `wide_eval` proves a whole
subchain of arity-at-least-two leaves still has tuples of width at least two.
`middle_wide` derives that premise for every rotation from the global
interior-leaf guard. `rotations_preserve_relations` handles rotations under
arbitrary contexts, reversal, and finite composition, carrying the guard
through each syntactic step.

Separately, `rotations_complete` constructs a finite rotation derivation
between any two trees having the same ordered leaves. Its list manipulation
is only a syntactic completeness lemma. `arbitrary_chain_relational_equality`
combines completeness with the relational preservation theorem to conclude
`eval source = eval target` for *arbitrary finite length and parenthesization*.
`accepted_chain_relational_equality` connects the actual arity-scan model to
that global semantic premise through `guard_supplies_license`.

### Exact Typing Boundary

`typed meaning columns row` checks every column, positionally, against an
explicit interpretation of the exact column symbol. `join_exact_columns`
proves output typing at `left.dropLast ++ right.tail`; neither endpoint is
replaced with `univ`. `eval_exact_columns` lifts this to every node in a tree.
`wellTyped` additionally requires leaf schema lengths to equal retained
arities and every application result to have positive arity.
`well_typed_chain_equality` records both trees' well-typedness, proves their
relational equality, and proves tuple membership satisfies each exact result
schema. It does not claim that satisfaction of two column predicates is
structural equality of two Java type DAGs.

Both endpoints may be unary. Every *interior* leaf must have arity at least
two, including empty families. The guard alone does not establish complete
type admission: `[1,1]`, and longer chains with both unary endpoints and only
binary interiors, produce a nullary whole result and are excluded by Alloy's
positive-result type constraint. The semantic equality theorem itself is
stronger and permits that mathematical nullary output; Java admission is not
expanded. Explicit `univ` has the supplied universal column predicate, proved
in `explicit_univ_column`; absent type information has no default predicate.

An empty family retains its positive arity in `emptyOperand`. Binary empty
annihilation and `empty_leaf_annihilates` prove that an empty leaf makes every
parenthesization's result empty. No witness is inferred from type inhabitation.
The inherited unary-interior counterexample remains: over atoms `0,1`, with
`R={(0,1)}`, `S={(1)}`, `T={(0,0)}`, left association yields `{(0)}` and right
association yields the empty relation. Both guards reject its flat license.

### Executable Semantics Connection

The replay uses the existing `PhaseA2` finite `tupleJoin`/`relationJoin`, not a
second unconnected list-flattening model. `splitLast_spec`, `tupleJoin_spec`,
and `finite_join_refines_relation` prove its tuple and relation membership
meaning. `finite_tree_refines_relation` extends that correspondence to every
tree under an explicit leaf-membership link. `sameRelation_iff` proves the
executable set comparison is exactly extensional tuple-membership equality,
not list order or duplicate-sensitive equality.

`guard_executable` rewrites the imported well-founded scan to its proved slice
specification before ordinary kernel `decide`. No native decision procedure,
unchecked evaluator, new axiom declaration, or admitted proof is used.

## Fixed Execution Census

Observation TSV columns are `surface`, `fixture`, `arities`, `tree`,
`relations`, `output`, `producer`, `verifier`, `equivalent`. Arrays are canonical
JSON, arities are canonical comma-separated naturals, Boolean cells are
lowercase, and nonapplicable cells are `-`. No TSV is emitted before all Java
assertions pass. The encoder rejects missing, duplicated, foreign, malformed,
or changed-input fixtures; it preserves observed outcomes for Lean to check.

- 469 guard rows: all 364 arity words of length 0 through 5 over `{1,2,3}`;
  89 single-unary-position probes at lengths 8,17,64; 15 typed-empty-position
  probes in length-five chains at retained arities 1,2,3; one explicit-univ row.
- 458 guarded finite association rows: lengths 2 through 5; all 1,2,5,14
  Catalan associations respectively; two deterministic tuple assignments over
  `{0,1}`. Fixtures are binary, left-unary, right-unary, wide (arity three),
  explicit-univ, both-unary for lengths at least three (one ternary interior),
  and an empty family at every position. The exact data generator and census
  live in Java and independently in `fixture_spec`/`census` in the delegate.
- Two rows retain both associations of the unary-interior counterexample.
- 92 parser-backed association rows: binary lengths 3,4,5 and length-four
  left-unary, right-unary, both-unary, empty, and explicit-univ fixtures, in
  both overflow profiles, over every association. The real parser, visitor,
  `CanonicalAlloyPipeline.prepare`, and `equivalentTo` are exercised.
- Four source rows plus all 1,021 observation rows become 1,025 replay theorems.

Each guarded finite row uses an independent binary finite relational
interpreter and a separate n-way tuple-witness enumerator, requiring equal
sets. It also constructs and locally verifies actual dependent chain
certificates under both profiles, compares target structural keys across
associations, and checks retained result arity. No solver oracle or internet
is needed. The parser rows observe canonical equivalence, not Alloy SAT model
checking; their finite Boolean replay is deliberately labeled TESTED.

The standalone guard is invoked reflectively on an ordinarily constructed
`SemanticReplay` instance, with exact `ExactType`/`StableKey` fixture objects.
The unused enclosing instance and ledgers are null. No allocation bypass or
production visibility edit is used. This exercises the *real private guard*
and its actual arity decoder but is not a complete standalone bundle replay,
parser authority validation, or proof of arbitrary `ExactType` validity.
Only positive exact relation families are supplied at this declared boundary.

## Frozen Controls And Trust

The extractor checks `DependentChainTheory.requireSoundFlattening`,
`DependentTypeDag.combine`,
`SemanticEvidenceVerifier.SemanticReplay.requireSoundDependentFlattening`,
and `SemanticReplay.requireChainCombination`. It first runs the existing typed
guard grammar, then checks whole-method AST hashes including literal strings,
resolved method/field/local/type/constructor bindings and their modifiers,
exact method owners and signatures. The four fixed hash pairs are duplicated
in the strict replay source census. There is no accept-current-source mode;
hash registration is a reviewed candidate-generation step, not evidence of
semantic correspondence. Failed extraction deletes stale requested output.

The 12 Lean negatives falsify each guard's unary rejection and endpoint
exemption, a nonempty relational output, the counterexample outcome, a parser
equivalence observation, and five extracted guard/boundary coordinates.
All are closed modules with their failing target theorem retained.

The 12 source variants weaken each interior threshold, change producer start
and verifier end bounds, remove producer relation-family validation, change
each producer/verifier left/right boundary, retain the wrong right output
column, and change each guard's synchronization modifier. All are applied
only to isolated source snapshots, never this shared worktree.

PROVED: the declared Lean relational, typing, guard-link, and finite-interpreter
theorems. TESTED: Java guard outcomes, typed construction, finite tuples, and
parser equivalence on the census. CHECKED: source structure/binding conformance,
schemas, census, generated propositions, and negative-control rejection.

TRUSTED: Lean 4.33.0 kernel and standard imported logical foundations
(`propext`, `Classical.choice`, `Quot.sound` as printed); JDK 17 javac resolution
and JVM/reflection; the local Alloy/parser dependencies; Python encoder and
extractor interpretation; SHA-256, filesystem/OS/hardware; aggregate snapshot,
build, provenance, and evidence machinery. Structural extraction establishes
conformance to a reviewed grammar, not a verified Java operational semantics.
The interpretation of exact Java families and column evidence as the Lean
predicates remains an explicit conservative trusted correspondence boundary.

OUT OF SCOPE: universal Java/heap/compiler refinement, arbitrary parser/type
authority, general subtype/disjoint alternative-matrix semantic refinement,
integer-overflow behavior outside admitted arity bounds, full standalone
certificate admission in this test, wire parsing/security, mixed-head rewrite
extensions, production data/evaluation changes, future revisions, and any
parent status promotion not justified by the aggregate frozen report.
