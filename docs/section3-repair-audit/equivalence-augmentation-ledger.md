# Equivalence Augmentation Assurance Ledger

This is the bounded claim/proof ledger for the optional adaptive overlay. It
does not change the status of the wider Section 3 assurance matrix and does not
claim corpus-wide semantic completeness.

| Claim | Implementation evidence | Formal/semantic evidence | Bounded result |
| --- | --- | --- | --- |
| R0 remains the default and immutable within one augmenter. | `BootstrapTheoryR0`, `CanonicalAlloyPipeline.distance`, optional `augmentedDistanceEvaluation` | Bootstrap digest includes the declared pipeline, theory, verifier, Alloy-law digest, and metric identities. | Default pipeline suite: 1,953 checks. |
| A positive semantic miss is recorded before it can merge. | `evaluateAndObserveEquivalent`, `observeEquivalent`, `LocalRecord.transition` | `AdaptiveEquivalenceAugmenter.lean`: `LocalStep`. | Lifecycle regression observes `OBSERVED -> CANDIDATE -> VERIFIED_LOCAL`. |
| A direct counterexample cannot merge. | `AlloyEquivalenceValidator`, local `FALSIFIED` transition, context-bound exact-pair index | Alloy SAT witness for `a` versus `falsehood`; equivalence requests cannot target SAT. | Falsified pair retains positive distance and a wrong-outcome request rejects before recording. |
| Bounded local evidence cannot escape its validation context. | `semanticContextDigest`, context-aware `evaluate`, local certificate binding, parser-command replay | Scope-1 `some Z` iff `one Z` is UNSAT; scope 2 has a SAT counterexample. A separate source command fixes exactly two `A` atoms while a forged request asks for scope one. | Fixed fixtures close only with their exact request. Source-bound evidence replays its parser-owned command/options, finds the exact-two counterexample, and rejects a missing context before ledger mutation. |
| Context identity contains only effective execution inputs. | `semanticContextDigest`, source-bound `ExecutionPlan` | `sourceBoundConvenienceScopesHaveOneIdentity` and `unboundRequestScopeRemainsEffective`. | Two source-bound requests differing only in replaced convenience scope reuse one local record and certificate; request-scoped scope-1/scope-2 evidence remains distinct. |
| Endpoint aliases use parser-resolved identity. | `SourceEndpointCorrespondence.Evidence`, `semanticContextDigest` | `parserEquivalentEndpointSpellingsHaveOneContext`. | `left` and `this/left` rebuild the same root declaration and reuse one local record, context, and certificate in both command modes. |
| A solver result denotes the generated equality in the selected command's model set. | `AlloySemanticProfileFactory.requireIndependentCommand`, `AlloyEquivalenceValidator.sourceBoundValidationCommand`, `Evidence.executedFormulaSha256` | `independentValidationExecutesItsOwnFormula`, `copiedParentCanSubstituteAnotherFormula`, the run/check search guards, and `noContextualCounterexampleProvesEqualityInSearchDomain`. | A valid follow-up-command witness rejects before profile authority. Parentless run/check witnesses certify only contextual equalities; both unbound equalities retain SAT counterexamples. |
| Local evidence denotes the actual root-local prepared endpoints. | `SourceEndpointCorrespondence.verify` | Exact source SHA-256 plus parser-resolved root-module callable object identity, call kind, declared arity, and production MASG/canonical reconstruction; no spelling, import alias, or trailing-name authority. | Changed-byte, wrong-endpoint, and imported/local name-collision probes reject before recording. Nullary/unary overloads reconstruct distinct roots and the nullary endpoint reaches its real Alloy counterexample. |
| A schema requires at least two independent local witnesses. | `proposeSchema`, `StructuralAntiUnifier.propose` | Anti-unifier rejects one witness, endpoint root holes, reflexive patterns, and zero-hole patterns. | One-witness proposal rejects. |
| Repeated validation of one pair is not independent schema evidence. | Distinct endpoint-pair checks before and after witness minimization | Scope is part of local identity but not a second semantic example. | Scope-3 and scope-4 records for one pair remain local and cannot propose a schema. |
| Shared schema holes preserve cross-side equality constraints. | One `AntiUnification` hole table is used for both endpoint columns; matching uses one binding map. | Mechanically generated Boolean proposition uses one Lean variable per shared hole. | Consensus schema exposes exactly three shared `Prop` variables. |
| Opaque Alloy propositions retain complete scope and domain identity. | `AlloyBooleanSchema.AtomIdentityEncoder` | Parser AST digest includes source, operators, exact types, declaration domains/flags, lets, calls, fields, and De Bruijn binder slots; unsupported nodes reject. Lean proves the resulting distinct proposition variables. | Alpha-renamed quantifiers and lets have equal keys; changed domains, bound expressions, disjointness, and multiplicity have different keys. Both A3 false-zero schemas are rejected by Lean and remain unadmitted. |
| Guard evidence changes the guard it names. | `requireMechanicallyWeakenedGuards`, `requireOperatorWeakening`, `requireArityWeakening`, `AlloyEquivalenceValidator.requireExpectedType` | Parser-derived root tags/arities and exact parser-authenticated relation columns; `forgedExactTypeCannotAuthenticate` proves the exact-equality gate algebra; source hash must be an origin witness. | Operator, arity, and exact-type counterexamples pass. A forged same-arity carrier produces `ERROR`, leaves the schema at `CANDIDATE`, and cannot be admitted. |
| Lean proves the inferred semantics, not a caller-selected theorem, file image, executable, axiom, digest decoy, or audit command. | `AlloyBooleanSchema.LeanObligation`, `LeanSchemaProofValidator` | Exact digest, theorem parameters/statement, source hash, dependencies, and the content-pinned 3,791-file no-import Lean environment at its exact version; checked bytes compile through `--stdin` into a private module; proof-language extensions are rejected; checker-owned source proves the executable digest constant by reduction and `#print axioms` admits only `propext`, `Classical.choice`, and `Quot.sound`. | Representative theorem compiles; unrelated theorem, `sorry`, `sorryAx`, warning-suppressed implicit-sorry tactic, axiom-audit macro shadowing, producer axiom, comment-only/string-only marker, and `/usr/bin/printf` launcher reject. |
| Equality admission is separate from orientation. | `verifySchema`, `admitSchema`, `Orientation.UNORIENTED` | No adaptive API creates an oriented rule; duplicate/inverse region admissions reject. | Verified-but-unadmitted schema remains positive. |
| Unoriented equality is symmetric in source correspondence and context identity. | Directionless endpoint/expression pair digests | Both orders reconstruct the same two source declarations and retain the same proof evidence. | Local and generalized reverse applications return the same certificate digest. |
| Dependency proofs cannot be circular or self-justifying. | `requireSchemaDependencies`, `requireAcyclicDependency` | Exact R0 dependency plus only schemas already admitted when the candidate was created; every dependency is earlier than eventual admission. Self/duplicate/future dependencies reject. | Lean/schema dependency mismatch leaves the candidate unadmitted and retryable. |
| Schema applications denote their compared endpoints. | Schema-aware `evaluate`, `ApplicationRecord`, certificate correspondence digest | Every use repeats source reconstruction and binds that evidence into the private certificate. | Application-free and wrong-endpoint requests stay positive/reject; correct unseen instance closes. |
| Schema applications use an authenticated execution context. | `EquivalenceAugmenter.evaluate`, `AlloyEquivalenceValidator.requireSemanticContext` | `AdaptiveEquivalenceAugmenter.lean`: `SchemaApplicationAuthorized` and `mismatchedApplicationContextHasNoAuthority`. | A command context attached to fixed-profile endpoints rejects before cache or ledger mutation; the frozen pre-fix executable accepts the same witness. |
| Adaptive evidence commits its complete admitted Alloy source closure. | `AlloyModuleClosureAuthority`, `AlloyEquivalenceValidator`, `SourceEndpointCorrespondence` | `AdaptiveEquivalenceAugmenter.lean`: `SourceClosureAuthorized` and `explicitOpenHasNoSourceClosureAuthority`. | The currently admitted closure is exactly the committed root source plus parser-owned implicit modules from the pinned Alloy dependency. Any explicit `open` rejects before adaptive ledger mutation. A frozen valid-source witness changed an opened predicate body and obtained `NO_COUNTEREXAMPLE`; repaired classes return `ERROR` and reject correspondence. |
| Admission reprocesses only its affected region. | Region-indexed schema map, semantic cache key, `regionRevision`, `invalidateRegion` | Generation strictly increases (`generationStrictlyAdvances`). | A pre-admission cached miss closes after generation 1; unrelated/no-application cache entries do not. |
| Saturation growth is bounded. | `Limits`, persistent affected-pair set, candidate/generation/check/application/cache budgets | Bounds are checked before admission and before each unseen schema application; failed admission leaves `VERIFIED_SCHEMA`. | One-pair affected-region budget rejects the two-witness schema. |
| Runtime evidence is deterministic and live certificates are replay-checked in process. | `EquivalenceAugmentationLedger`, private certificate constructors, `verifyCertificate` | JSON records R0, contexts, origins, transitions, patterns, all five structured guards plus their digest, Alloy/Lean identities, dependencies, generations, and applications. Objects use recursive lexical key order and arrays use stable record order. JSON alone is explicitly not portable admission authority. | Two unchanged writes are byte-identical; required fields, all guard dimensions, and lexical root order are asserted for three locals, one schema, and two context-distinct generalized applications; live certificates verify against private state. |
| New misses do not expand static R0. | Frozen rewrite inventory plus adaptive consensus-law regression | Two local witnesses, inferred schema, bounded Alloy evidence, generated Lean theorem, and unseen source-bound application. | Consensus closes only after generation-1 admission; absorption/distributivity probes confirm existing R0 coverage. |

## Proof process

1. The source parser resolves each local selector and rebuilds the exact
   production representation.
2. The validator authenticates exact expression types from the parsed module.
   Source-bound claims reconstruct and replay the selected parser command and
   immutable execution options. Commands with executable parents reject until
   chain semantics are represented, and the generated equality command is
   parentless. Its executable counterexample formula is conjoined with the
   parser-owned source command search domain and hashed into evidence. Fixed
   test fixtures use their explicit request scope. Alloy searches the bounded
   conjunction and records SAT/UNSAT, effective
   context, solver identity, exact types, and deterministic evidence hashes.
3. Opaque propositions are converted to complete scope-aware parser-AST keys;
   structural and semantic anti-unification are then computed independently and
   bound into one schema digest.
4. The semantic anti-unifier mechanically generates the only Lean theorem
   statement the candidate may submit.
5. The content-pinned Lean kernel compiles the exact byte array already parsed
   and hashed by the validator into a private module. A second checker-owned
   invocation audits the exact theorem's axiom dependencies. Textual markers,
   imports, path replacement, warning suppression, producer axioms, and
   admitted proof constructs cannot substitute for the exact theorem.
6. Admission checks dependency generation and growth bounds, then records one
   new theory generation without selecting a rewrite direction.
7. Application authenticates command/options against the endpoint profile,
   repeats the source correspondence check, and records both context and
   endpoint evidence in its zero certificate and ledger entry.

The persisted ledger is a deterministic audit transcript. It retains the
generation and dependency provenance needed to reconstruct a replay, but the
current implementation deliberately does not deserialize that transcript into
trusted equality state. Re-admission after process restart requires rerunning
the source, Alloy, guard, and Lean checks.

The incident and repair history is maintained in
[`docs/adaptive-equivalence-augmentation.md`](../adaptive-equivalence-augmentation.md).
