# Adaptive Equivalence Augmentation

## Status and stopping rule

The certified rewrite theory present before this change is immutable bootstrap
theory `R0`. Its identity is produced by `BootstrapTheoryR0` from the pipeline,
certificate-theory, verifier, Alloy-law, and repair-metric identities, plus
content hashes of the exact runtime producer, Alloy, and parser images. The
adaptive layer is optional: ordinary `CanonicalAlloyPipeline.distance` still
evaluates exactly `R0` and the established repair metric.

The static rewrite inventory is now frozen. A later semantically equivalent
positive-distance pair is evaluation data for this augmenter. It must not be
turned into another handwritten source rewrite.

Review discoveries are retained as future-work evidence but are nonblocking
unless they expose a false semantic result, false certificate, or violation of
another stated core invariant. A known positive-distance equivalence is not by
itself such a violation: it remains eligible for exact instance-local
observation under the fail-closed path below. Generalized support may be added
later through the augmentation proof boundary, not by expanding static `R0`.

## MVP assurance boundary

This implementation is an MVP, not a completed universal equivalence learner.
Its executable claim is deliberately narrower:

- exact instance-local evidence is a bounded Alloy counterexample search tied
  to one reconstructed source pair and one exact execution context; UNSAT in
  that bound is not an unbounded Alloy theorem;
- reusable admission is implemented only for the closed, atemporal Boolean
  schema fragment described below, after at least two distinct local pairs;
- explicit source `open` declarations are rejected at the adaptive authority
  boundary until parser-resolved dependency bytes are committed. Imports still
  work in ordinary parsing, canonicalization, and immutable `R0` evaluation;
- generated Lean proofs establish the generated finite propositional theorem.
  They do not prove the Java parser-to-AST translation, Alloy SAT engine, JVM,
  SHA-256 implementation, anti-unifier completeness, or unbounded schema-search
  completeness. Those links have bounded Java/Alloy regressions only;
- the JSON ledger is deterministic audit output, not portable admission
  authority. A live augmenter instance and its retained generation state are
  required for replay;
- no corpus-completeness, convergence, performance, or automatic rewrite-
  orientation claim is made.

Historical adversarial findings remain fault provenance. The earlier
open-ended reviewer ladder is no longer a release gate for this MVP. A future
finding blocks this implementation only when it demonstrates a source-
reachable false equality/certificate or another stated core invariant breach;
positive-distance discoveries are logged as future augmenter evaluation data.

## In-flight algorithm

For certified, provenance-retaining endpoints `a` and `b`:

1. Evaluate the established repair metric under `R0`.
2. If the result is already zero, return it without adaptive evidence.
3. Otherwise, record an `OBSERVED` local miss and move it to `CANDIDATE`.
4. Hash the exact Alloy source bytes and require that hash to equal both
   endpoint provenance hashes.
5. Reparse both zero-arity predicate/function selectors from those bytes,
   require both calls to resolve to callable objects declared by the root
   module, rebuild their MASGs and canonical forms through the production pipeline,
   and require zero repair distance plus canonical-observation equality with
   the claimed endpoints.
6. Authenticate both expression types from the parsed Alloy `Type`, including
   every relation column, and require exact equality with the certified graph
   types. For source-command-bound endpoints, replay the exact parser-owned
   command scopes, bitwidth, temporal bounds, and execution options; the
   request's convenience scope cannot replace that context. A selected Alloy
   follow-up command is rejected because its parent chain is not represented
   by the semantic profile. The generated equality command is always
   parentless. The parser-owned source command formula is already its executable
   search domain (`C` for `run C`, `not C` for `check C`), while the generated
   check formula is the equality's counterexample condition. Conjoin those two
   formulas so the returned solver result denotes an equality counterexample
   inside the selected command's model set, and bind that executed formula's
   digest into the evidence. Local identity uses the effective execution
   context: a request scope is retained for request-scoped validation but is
   omitted when the parser-owned command replaces it. Parser-equivalent endpoint
   spellings are identified by the already certified source-correspondence
   digest rather than raw selector text. Run the resulting bounded query. A counterexample produces
   `FALSIFIED`; the required UNSAT result produces `VERIFIED_LOCAL` and an
   exact-pair, unoriented overlay equality valid only for the hashed validation
   context. It cannot change context-free or differently scoped distance.
7. Given at least two `VERIFIED_LOCAL` records in one exact guarded region,
   compute the least general structural anti-unifier for both the certified
   keys and parser-resolved Boolean meanings. Shared holes are shared across
   both sides, and redundant origin witnesses are removed.
8. Keep the result at `CANDIDATE` until all schema evidence succeeds:
   parser-derived operator/type/arity guard weakening checks, bounded Alloy
   searches, exact source provenance, a mechanically generated Lean statement,
   and an independently compiled self-contained Lean proof.
9. Move a proved equality to `VERIFIED_SCHEMA`. This does not orient it.
10. A separate `admitSchema` operation checks dependencies and growth limits,
    increments the theory generation, invalidates only the affected region's
    comparison cache, and moves it to `ADMITTED`.
11. Every generalized application first authenticates its request command and
    execution options against the prepared endpoints' semantic profile, then
    reparses and reconstructs its own two source endpoints. This happens before
    cache lookup or ledger mutation. Its source-correspondence and effective
    semantic-context digests are part of the zero certificate and are retained
    with its theory generation in the audit ledger. Live replay remains tied to
    the originating augmenter state; JSON is not admission authority after
    restart.

`augmentEquivalentInFlight` implements steps 1-6 for callers that possess a
semantic-equivalence obligation. Proposal, proof, and admission remain
separate operations so an observation cannot silently become global theory.

## Lifecycle

Local and generalized records are deliberately separate but linked by origin
witness IDs:

```text
local:   OBSERVED -> CANDIDATE -> FALSIFIED | VERIFIED_LOCAL
schema:                         CANDIDATE -> FALSIFIED | VERIFIED_SCHEMA
                                                        -> ADMITTED
```

Malformed, missing, timed-out, or rejected proof submissions do not falsely
label a schema equality as semantically falsified. They leave it at
`CANDIDATE`; only a direct Alloy counterexample to the proposed equality moves
the schema to `FALSIFIED`.

## Admitted schema scope

The first implementation intentionally admits only closed, atemporal Boolean
predicate/function equalities whose two endpoints can be reconstructed from
one exact source module. Quantified, temporal, parameterized-call, cross-file,
and term-valued misses may be recorded locally only when their direct validator
supports them; they cannot acquire generalized authority through this schema
path. Unsupported cases fail closed.

## Logged future-work discoveries

These observations do not invalidate the current soundness boundary:

- Closed cardinality/empty-relation identities such as `no R iff R = none`,
  `some R iff R != none`, `lone R iff no R or one R`, and
  `one R iff some R and lone R` can remain positive under `R0`. The main agent
  independently reproduced all four with Alloy `NO_COUNTEREXAMPLE` results;
  the log `/tmp/acgn-main-cardinality-probe.log` has SHA-256
  `7ddffddc8ac7aa2d92278836114939dde6cce7af6ebb3a85470c092f919df6f6`.
  These are adaptive evaluation data. No handwritten bootstrap rewrite was
  added.
- Direct validation supports more local claims than automatic schema
  correspondence currently generalizes, notably term equality and requests
  with a universal binder. Those claims remain exact-context local evidence;
  they cannot enter global schema admission without a parser-authenticated
  semantic model and an independently checked Lean obligation.

Both items are deliberately deferred. They become blocking only if a later
path promotes them beyond their certified scope or falsely reports semantic
equality.

Alloy validation is explicitly bounded by the recorded scope. Generalized
semantic authority does not come from bounded UNSAT alone: the parser-derived
Boolean schema is translated mechanically into a universal Lean proposition,
and that exact proposition must compile without `sorry`, `axiom`, `unsafe`,
`admit`, `opaque`, `implemented_by`, or imports. The schema digest, theorem
header, dependency list, exact pinned Lean executable/toolchain image, compiler
version, and proof-source hash are checked.
Lean receives the already checked byte array over `--stdin`; the recorded source
path is provenance only and is never reopened as kernel input. All Lean warnings
are errors, and `sorryAx` is rejected explicitly, so tactics that elaborate to
an implicit sorry cannot receive proof evidence. The checked module is then
imported by checker-owned source, which first proves by reduction that its
executable `acgnSchemaDigest` constant equals the exact inferred digest.
`#print axioms` must then report only Lean's
pinned foundational `propext`, `Classical.choice`, and `Quot.sound`; any
producer declaration or `sorryAx` dependency rejects.
The accepted proof language also excludes parser, macro, notation, command
elaborator, and initializer extensions. This keeps the checker-owned axiom
command fixed when the private proof module is imported; a proof cannot replace
`#print axioms` with a command that conceals its dependencies.

Opaque Boolean atoms are never keyed by Alloy's normalized display text. Their
identity is the SHA-256 of a complete parser-AST key containing source identity,
operators, exact types, multiplicities, declaration domains, declaration flags,
calls, signatures, fields, and De Bruijn-style binder slots. Alpha-renaming is
therefore ignored while changed domains remain distinct. An unsupported parser
node rejects schema extraction instead of falling back to a lossy spelling.
Regression coverage exercises alpha-renamed lets, nested dependent quantifier
domains, nested calls, fields, declaration disjointness, and declaration
multiplicity as separate identity dimensions.

## Guards and authority

Every candidate is region-indexed by exact operator declarations, output type,
port arities, semantic-profile fingerprint, and certified normalized-IR
authority. Guard probes are accepted only when parser structure demonstrates
that the named operator or arity dimension changed. Exact-type probes are term
equalities whose full relation types are reconstructed from parser-owned Alloy
types and compared exactly with the claimed graph types; arity-only agreement
cannot supply evidence. Probe bytes must come from a verified origin witness.
Provenance and semantic-profile guard failures are enforced by the endpoint
reconstruction and uncompacted-certificate boundaries.

No authority is inferred from a predicate spelling, a source path, or
caller-created metadata. A spelling is only a selector into bytes whose hash is
already bound to endpoint provenance; the selected declaration must rebuild to
the claimed certified observation.

## Equality versus orientation

Adaptive records contain only `UNORIENTED` equalities. They may merge an exact
pair or satisfy a guarded e-graph equality query, but they do not become
one-way rewrites. Duplicate and inverse admissions in one region are rejected,
which also prevents orientation oscillation. R0's rewrite orientation is not
changed.

## Generation and growth controls

The augmenter bounds observations, candidates, admitted schemas, theory
generations, affected pairs, schema checks per comparison, application-ledger
records, and cached comparisons. Each unseen schema application consumes the
schema's affected-pair budget. Dependencies must include the exact `R0` digest,
must be unique, and may name only schemas admitted before the candidate was
created; those dependencies are strictly earlier than the candidate's eventual
admission generation. Self-dependencies and dependency cycles reject.
Cache identity includes endpoint identity plus parser-resolved semantic
application identity; admission advances the region revision and invalidates
only that region.

## Ledger

`EquivalenceAugmentationLedger` writes an atomic deterministic JSON document
containing:

- R0 components and digest;
- every local origin endpoint and input hash;
- complete state transitions and observed positive distance;
- Alloy outcome and evidence digest;
- source-to-endpoint reconstruction evidence;
- anti-unified certified and semantic schema patterns;
- exact structured operator/type/arity/profile/provenance guards, their digest,
  and positive/negative evidence;
- generated Lean obligation, proof path, proof digest, and dependencies;
- pinned Lean executable path, toolchain-content digest, and exact version;
- admission scope, orientation, theory generation, and affected-pair count;
- every successful generalized application and its correspondence-bound
  certificate digest.

Object keys are serialized recursively in lexical order; record arrays are
sorted by stable IDs before serialization. Repeated writes of unchanged state
are therefore byte-identical rather than relying on `JSONObject` map order.

## Located faults and repairs

| ID | Located fault | Repair and regression |
| --- | --- | --- |
| EA-F01 | Hashing a very large certificate snapshot through `stableString()` exhausted a 2 GiB heap. | Replace it with memoized streaming, length-delimited SHA-256 over `StructuralKey`. The adaptive suite completes under `-Xmx2g`. |
| EA-F02 | A Lean file could prove an unrelated proposition while merely repeating the inferred schema digest. | Derive the exact Lean theorem from parser-resolved Boolean anti-unification and require its exact parameters and statement. Unrelated-theorem and comment-only-marker regressions reject. |
| EA-F03 | Source hashes alone could attach valid Alloy evidence to the wrong prepared graph. | Reparse, rebuild MASG/canonical endpoints, and require exact metric/observation correspondence before local verification. Wrong-byte and wrong-endpoint regressions reject. |
| EA-F04 | A generalized application initially matched supplied semantic syntax without proving that syntax denoted the compared endpoints. | Apply the same source reconstruction to every schema use and bind its digest into the certificate and application ledger. |
| EA-F05 | Schema-cache identity initially omitted the source-level semantic application. | Include direction-independent semantic application identity and region revision; application-free and mismatched applications remain positive. |
| EA-F06 | Caller-labelled guard probes could be unrelated counterexamples. | Mechanically check origin source, parser root operator, parser root arity, and certified exact-type change before running each search. |
| EA-F07 | A malformed dependency/proof submission initially transitioned a sound candidate to `FALSIFIED`. | Keep malformed or inconclusive submissions at `CANDIDATE`; reserve schema `FALSIFIED` for a direct Alloy counterexample. Dependency mismatch is a permanent regression. |
| EA-F08 | Concurrent verification attempts could race the same candidate. | Add a synchronized in-flight claim and release it on every checked completion/error path. |
| EA-F09 | Certified and semantic anti-unifiers could minimize to different origin subsets while the ledger retained only one subset. | Retain the sorted union of both minimal witness bases in schema identity and positive evidence. |
| EA-F10 | A semantic-cache hit could reuse an earlier alias-equivalent application certificate rather than the current correspondence proof, and application/cache maps had no explicit limits. | Include the exact correspondence digest in cache identity and impose fail-closed application/cache budgets. |
| EA-F11 | Bounded Alloy UNSAT was initially promoted to an unrestricted exact-pair zero. `some Z` and `one Z` agree at scope 1 but differ at scope 2. | Bind local identity, lookup, and certificates to the complete semantic validation context. Context-free and scope-2 comparison stay positive; scope 2 records the SAT counterexample. |
| EA-F12 | The configured `acgn.lean` launcher could name a non-Lean process that returned exit status zero. | Resolve the actual toolchain prefix, hash the exact kernel/runtime files against the artifact pin, require the exact authorized version, recheck before every proof, and bind that identity into R0, proof evidence, and the ledger. `/usr/bin/printf` rejects. |
| EA-F13 | Duplicate local validation could race, timeout/error could become terminal, and local cache invalidation targeted a non-existent partial key. | Claim each in-flight validation under synchronization, leave inconclusive evidence retryable at `CANDIDATE`, and invalidate every cached decision carrying the exact endpoint-pair field. |
| EA-F14 | The admission growth check counted only pairs already present when a schema was admitted. | Charge every unseen generalized application against the schema's persistent affected-pair set and reject before exceeding the bound. |
| EA-F15 | Duplicate admission compared only certified patterns, not parser-derived semantic patterns. | Compare both complete certified and semantic pattern pairs in either direction before rejecting duplicates. |
| EA-F16 | An equivalence observation could be misconstrued if its target outcome were SAT. | Require `NO_COUNTEREXAMPLE` for local observations and schema direct evidence; only weakening probes may require a counterexample. A pre-record regression rejects the wrong outcome. |
| EA-F17 | Direction-sensitive source/context digests prevented an `UNORIENTED` equality from replaying when endpoints were swapped. | Hash endpoint observations, profiles, selectors, and expression identities as unordered pairs. Local and schema certificates now replay identically in either order. |
| EA-F18 | Schema comparison-cache identity included semantic syntax and correspondence but omitted the semantic validation context. | Include the context digest in cache identity. Different finite scopes receive distinct certificate/application records even when the global Lean-proved equality applies to both. |
| EA-F19 | Two validation scopes of one endpoint pair could be counted as two observations, and a rejected application could partially consume growth state. | Require two distinct endpoint pairs before and after witness minimization; preflight cache, affected-pair, and application limits before mutating any ledger state. |
| EA-F20 | The first Lean content pin covered the executable and shared libraries but omitted the automatically loaded `Init` environment. | Bind the executable, Lean shared objects, root `Init.*` artifacts, and the complete no-import `Init/` tree: 3,791 files under the authorized Lean 4.33.0 toolchain. The aggregate digest is part of R0 and is revalidated for successful proofs. |
| EA-F21 | The assurance ledger still described one schema application after the context-cache regression intentionally began recording scope-3 and scope-4 applications separately. | Correct the bounded-result claim to two context-distinct applications and invalidate the in-flight review manifest before accepting any ballot. |
| EA-F22 | Alloy's normalized rendering omitted quantified declaration domains. Distinct propositions such as `all x: U | P` and `all x: V | P` collapsed onto one Lean variable, allowing a globally false schema and an unseen distance zero. | Replace display-text atoms with complete parser-AST identities and De Bruijn binder slots. Two independently reproduced false-zero families now infer distinct domain propositions; Lean rejects the schema, admission rejects, and the unseen Alloy counterexample remains positive. |
| EA-F23 | The validator checked and hashed a Lean file, then passed its path to Lean, allowing the path contents to diverge from the bytes named by successful evidence. | Pass the exact checked bytes to the pinned Lean process through `--stdin`; retain the original path only as provenance. Existing valid, malformed, unrelated, comment-marker, and fake-launcher proof regressions exercise the byte-bound path. |
| EA-F24 | The ledger sorted records but delegated object serialization to `JSONObject`'s `HashMap`, so its byte-determinism claim was not guaranteed. | Serialize every JSON object with recursively sorted keys and every array in its already canonical record order. Repeated-write, lexical-key-order, and required-field regressions cover local, schema, and application entries. |
| EA-F25 | The ledger retained a guard digest and internal affected-region string but did not expose each admitted guard as a structured audit field. | Record exact `OPERATOR`, `EXACT_TYPE`, `ARITY`, `SEMANTIC_PROFILE`, and `PROVENANCE` values alongside the digest. The schema-ledger regression requires all five dimensions. |
| EA-F26 | Lean's built-in `sorryAx` was not matched by the identifier-bounded `sorry` filter. It could inhabit the exact generated proposition, emit only a warning, and return exit status zero. Tactics such as `impossible` could also elaborate to the same axiom without spelling either token, and source could locally reset warning handling. | Reject `sorryAx` explicitly, compile checked bytes into a private module, and use checker-owned Lean source to audit the target theorem's axiom dependencies. Only the pinned foundational set is allowed. Regressions cover direct `sorry`, direct `sorryAx`, a locally warning-suppressed `impossible` proof of `forall p q, p <-> q`, and a producer-declared axiom. |
| EA-F27 | An imported proof module could export a macro for the exact `#print axioms` syntax. A false theorem using an implicit `sorryAx` then compiled with a warning and made the audit print an unrelated declaration instead of its dependency census. | Freeze the accepted proof language against parser, macro, notation, elaborator, and initializer extensions before compilation. The minimized macro-shadowing false theorem is a permanent rejection regression. |
| EA-F28 | Endpoint reconstruction placed raw source spelling and trailing path segments ahead of parser declaration identity. In a module with imported `ord/first` and a distinct local `first`, valid UNSAT evidence for `ord/first = second` rebuilt the local `first`, reached `VERIFIED_LOCAL`, returned distance zero for a false pair, and passed certificate replay. | Require the parsed `ExprCall.fun` object to belong to the root module's callable declarations. MASG lookup uses only that declaration's exact label and its `this/`-stripped local form; imported calls and spelling-derived trailing aliases reject before any record is created. Direct Alloy regressions retain both the imported UNSAT equality and local SAT distinction. |
| EA-F29 | The schema-digest marker check searched source text while preserving string contents. A raw string containing the expected declaration text therefore produced evidence claiming an executable digest binding that did not exist. | The checker-owned Lean module now requires `example : acgnSchemaDigest = "<exact digest>" := by rfl` before auditing theorem axioms. Missing, decoy, or non-definitionally-equal constants fail in the kernel. Comment-only and raw-string-only markers are permanent regressions. |
| EA-F30 | A weakened exact-type probe was authenticated only by relation arity. A caller could claim `Rel(NotTheActualCarrier)` for expressions whose parser type was `Rel(U)`, obtain SAT evidence, admit the schema, and verify a generalized zero certificate. | Convert each parser-owned Alloy `Type` through `ExactAlloyType` and `AlloyTypeBridge`, require exact structural `GraphType` equality, bind both exact types into the evidence digest, and require a term-equality probe that is neither the guarded pair nor its reversal. The minimized forged-carrier witness now remains `CANDIDATE` with `ERROR` evidence and cannot be admitted. |
| EA-F31 | A source-command-bound endpoint could be checked with a fresh request-only command. In the minimized witness, the source fixed exactly two `A` atoms while a request at scope one certified `some A` iff `#A = 1`. | Require an immutable parser-command index and full Alloy option snapshot for source-bound validation; reconstruct the source profile, require it to equal the certified endpoint profile, and run the comparison with that command's exact scopes, bitwidth, sequence/temporal bounds, and options. The witness now finds the scope-two counterexample; a missing context rejects before ledger mutation. Fixed compatibility fixtures retain their explicit request-scoped mode. |
| EA-F32 | Valid Alloy overloads such as nullary `foo` and unary `foo[x]` collided in MASG's spelling-only callable map, so source reconstruction failed before an adaptive result existed. | Index local declarations, forest roots, and callable targets by semantic name, call kind, and declared arity. Source correspondence carries the parser-resolved kind/arity tuple. The nullary and unary roots are distinct, while a same-kind/same-arity collision still rejects. The nullary endpoint now reaches Alloy and retains its counterexample. |
| EA-F33 | EA-F30 through EA-F32 initially had executable Java/Alloy regressions but no corresponding standalone kernel model in the adaptive Lean ledger. | Add constructive Lean obligations showing that a forged unequal type cannot satisfy authenticated exact equality, request context cannot override a source-bound command, and distinct arities induce distinct callable keys. Lean 4.33.0 checks all three without `sorry`, `axiom`, or `unsafe`. |
| EA-F34 | A source follow-up command's `parent` was copied onto the generated equality check. Alloy executed an UNSAT ancestor first, the validator classified that unrelated result as `NO_COUNTEREXAMPLE`, and a false `l iff r` pair reached `VERIFIED_LOCAL`, adaptive distance zero, and successful certificate replay. | Reject parser commands with a non-null parent at source-profile construction and adaptive replay until complete chain semantics are represented. Generated validation commands require and retain a null parent. The minimized valid Alloy witness now rejects before profile authority exists, while an independently executed equality check remains SAT. `AdaptiveEquivalenceAugmenter.lean` proves that an independent command executes its own formula and that a copied distinct parent can substitute another formula. |
| EA-F35 | Source-command replay committed the selected command formula in its profile but copied only bounds/options into validation. Under `run { one A }`, `some A` and `one A` are equivalent, yet the unguarded query found a two-atom counterexample outside the selected model set and permanently falsified the contextual equality. | Treat the parser-owned `Command.formula` as the exact executable search domain and conjoin it with the generated equality-counterexample formula. This uniformly gives `C and not E` for `run C` and `not C and not E` for `check C`. Evidence explicitly binds the executed formula digest. Run- and check-context regressions now reach `VERIFIED_LOCAL` and zero only in their exact contexts, while unbound comparison retains its SAT counterexample. Lean proves both command-target guards and that absence of a contextual counterexample entails equality inside the search domain. |
| EA-F36 | Source-bound local identity still hashed the request's convenience scope even though execution replaced it with the parser-owned command scope. Two otherwise identical requests therefore ran the same query but created distinct `VERIFIED_LOCAL` records and certificates. | Build the context digest from the effective execution context: request scope only in request-scoped mode, or the command index/options identity in source-bound mode. Run/check regressions vary the ignored request scope and now reuse one local record, context digest, and certificate; unbound scope remains significant. Lean proves both normalization cases. |
| EA-F37 | Local context identity hashed raw endpoint selector text. Parser-equivalent calls such as `left` and `this/left` reconstructed the same declaration and prepared graph but created distinct verified records and certificates. | Derive endpoint-pair context identity from `SourceEndpointCorrespondence.Evidence`, which already binds exact source bytes, root declaration identity, canonical observation, and semantic profile. Qualified/unqualified run/check regressions now reuse one record/context/certificate. Lean models spelling-independent resolved declaration identity. |
| EA-F38 | Generalized-schema application reconstructed its source endpoints but did not authenticate the supplied command/options context against their certified semantic profile. A caller could therefore obtain a zero certificate whose context digest named a command that never authorized the application. | Call the same fail-closed semantic-context replay used by local observation before correspondence, cache lookup, or application-ledger mutation. The frozen v20 classes accept the minimized foreign-context request and fail the new regression; the repaired path rejects it without changing the application ledger. `mismatchedApplicationContextHasNoAuthority` gives the standalone Lean obligation. |
| EA-F39 | Adaptive evidence committed only the root source bytes. A valid root could `open` a filesystem module, prepare endpoints under one dependency body, then validate under a replacement body while retaining the same endpoint profile and root-source hash. The reproduced transition changed Alloy from `COUNTEREXAMPLE` to `NO_COUNTEREXAMPLE`, and source correspondence still accepted the stale prepared endpoints. | Keep ordinary Alloy parsing and canonicalization unchanged, but fail closed at every adaptive validator and endpoint-correspondence entry point when the root contains an explicit `open`. This boundary remains until parser-resolved dependency bytes are committed in endpoint provenance. The frozen v22 transition is retained in `/tmp/acgn-main-import-correspondence.log`; repaired classes return `ERROR` before and after replacement and reject correspondence. `explicitOpenHasNoSourceClosureAuthority` is the standalone Lean obligation. |

The first adaptive-review snapshot was invalidated by EA-F11 through EA-F15.
The reports are `/tmp/acgn-adaptive-luna-1.md` (SHA-256
`f703aaa9c98479c8424e6aa7696649cbd523c9fdab7dfb2000da87e9f291d0b0`)
and `/tmp/acgn-adaptive-luna-2.md` (SHA-256
`4716714016d71aa378b02107ba2b40f6358e2d3cabc65c612965560a28f1276a`).
Their absorption and distributivity discoveries were independently reduced to
three source-backed instances each. All six pairs were already zero under
unchanged R0, so they are bootstrap-coverage regressions, not adaptive
admissions or new static rules.

## Bounded verification record

- `EquivalenceAugmenterTest`: 113 checks pass.
- `SemanticProfileSourceCommandTest`: 41 checks pass.
- `CallExtractionRegressionTest`: 150 checks pass.
- `CanonicalAlloyPipelineTest`: 1,953 checks pass.
- `EGraphSaturationTest`: passes.
- `AdaptiveEquivalenceAugmenter.lean`: Lean 4.33.0 accepts the lifecycle,
  monotone-generation, and representative generated-schema proofs.

These are bounded implementation results, not a claim that bounded Alloy UNSAT
is a complete decision procedure for arbitrary Alloy semantics.

An additional, unrelated run of `AlloySourceRuleRegressionTest` currently stops
at its pre-existing empty-universe assertion, `univ has no unconditional
nonemptiness witness`. The adaptive package and optional pipeline methods are
not called by that path, so this task does not alter its normalization behavior
or reinterpret the failure as adaptive evidence.
