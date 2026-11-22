# P5-11 scoped authority across ablation engines

The original obligation asks whether each of the five ablation engines uses declaration-derived lexical cardinality for guarded `IN` and `NOT_IN`, including shadowing and same-spelling synthetic variables. The five implementations expose six dataset modes because the slotted engine has both typed and untyped configurations. This package is a candidate for the original row after its two clean qualification builds and global registration. The focused runs used the ninth producer and JDK 17. No production repair was required by this witness.

## Production correspondence

`EGraphAblationStudy.processFile` parses the selected file, constructs a `ModelUnit`, selects the pair, adapts each predicate through `AlloyAstTermAdapter.fromPredicate`, and calls `Engine.newEngine().compare`. The study routes `CANONICAL` and `TYPED_SLOTTED_PORT` to their separate graph pipelines before this branch. The witness enumerates the real enum and invokes its factory. It also calls the study’s actual option parser and per-file worker for one positive and one shadowed file in every raw mode.

| Factory mode | Guard frontier | Storage or preparation |
| --- | --- | --- |
| `RAW` | Named, fixed arity | Original term |
| `RAW_DEBRUIJN` | Named, fixed arity through `RawEGraph` | `DeBruijnVariables.encode` on storage only |
| `EGGLOG` | Named, variadic | Original term |
| `EGGLOG_DEBRUIJN` | Named, variadic through `JavaEgglog` | `DeBruijnVariables.encode` on storage only |
| `SLOTTED` | Renamed, variadic | Erase slot types, canonicalize initially and after each changed pass |
| `SLOTTED_TYPED` | Renamed, variadic | Canonicalize while retaining exact slot types |

`RawEGraph.compare` and `JavaEgglog.compare` keep the two named rewrite frontiers alongside the stored representatives. The witness checks nearest and outer De Bruijn indices in both storage modes and observes that the stored index leaves have no source token. `SlottedEGraph.compare` passes an alpha representative into `rewriteSlottedOnce`. Its scope pass processes declaration domains in the incoming scope and allocates fresh binder names. `SlotBindingBlocks.normalize` splits or flattens eligible independent scalar declarations, carrying each binder and its domain. Slot permutations assign distinct names within a block and use separate block names. `AlloyTerm.renameVariable`, `eraseSlotTypes`, and internal `rewrittenChildren` preserve the original source token where the rewrite retains the occurrence.

The bounded public helpers `JavaEgglog.normalForm` and `SlottedEGraph.normalForm` also apply the common guard. Both were exercised on positive and nullable source pairs. `SlottedEGraph.alphaRepresentative` supplies the actual recorded slotted frontier. Four synthetic label-only inputs went through the explicitly synthetic `SlottedEGraph.representUnbounded` entry in a child process with a 15-second external deadline, covering both polarities and both slot modes.

`AlloyRewriteSystem.rewriteScopedTree` copies the outer scope, visits a declaration under the previous bindings, and installs its slots for following children. `addDeclarationBindings` stores either an authenticated admissible slot or a masking null value. `isStaticallyNonempty` requires the read’s non-null token to equal the current token for its name. `rewriteNode` uses this decision in both guarded branches. For a let, capture-avoiding substitution carries the replacement occurrence and its original token into the body. The witness independently resolves the RHS through the original Alloy `ExprLet` and inspects the membership read after the first real rewrite pass, across all six modes, for both positive aliasing and a nullable shadow.

`P511Entrypoints` attributes the selected source files with the system JDK and freezes 145 method bodies and 1,361 resolved invocation, construction, and method-reference targets. The digest is `416f8582fbb0f215ceb3a7386e894303a25761cb4330a81bc7b9de51cf992e2b`. Storage internals beneath the slotted frontier and unrelated study reporting lie outside the judgment. A change to the selected bodies or targets requires new review.

## Governing proof

`P511LexicalTransport` imports `P506SourceNonempty` and its source-root, declaration, ordered variable position, and variable identity check. Its 23 theorems include the following.

- `transport_lookup`, `allocate_next`, and `permute_injective` establish lookup after fresh scope allocation, whole-entry reordering, and a finite program of coordinate transpositions.
- `nullable_shadow_blocks`, `domain_precedes_shadow`, and `synthetic_label_has_no_authority` cover masking, the point at which a binding becomes active, and absent provenance.
- `cross_engine_guard` and `generated_guard_has_current_coordinate` derive the common decision and the original, visible one/some declaration for an accepted read at any of the six entries.
- `substitution_transports_original` proves that a visible replacement retains the RHS token and its guard under a capture-avoiding intervening scope. `shadow_withholds_substitution` covers an inner declaration masking the substituted variable.
- `checked_nullable_or_positive_owner` establishes visible token identity at both decoded frontiers even when the declaration permits an empty value. `checked_positive_same_original` links a positive decision at both frontiers to the same issued declaration coordinate.

`P511LexicalReplay` imports the primary. It rebuilds each grouped declaration, arity, multiplicity, ordered source slot, lexical stack, and observed read from the generated TSV. The executable checks both scope censuses, both current-token lookups and both decisions. Its two audited theorems link successful decoding and positive replay to the original issuer. The repository proof census and Lean 4.35.0 accepted all 25 named theorems. The full axiom union is `propext`, `Classical.choice`, and `Quot.sound`.

## Focused observations

The 17 parsed source pairs exercise bare, one, some, set, and lone declarations in both polarities, nullable and positive shadowing, outer references, dependent declarations, grouped/nested independent declarations, and let substitution. The source oracle resolves actual Alloy `ExprVar` identities and grouped positions before constructing its adapter model. For a nested exchange, the observed slotted environment reorders coordinates 3 and 4, while both membership reads continue to select the original source variables. The fixture-only oracle rejects syntax for which it has no interpreter.

| Artifact | Fresh focused result | SHA-256 |
| --- | --- | --- |
| `p511.tsv` | 102 parsed method/pair comparisons, 12 study file calls, 12 synthetic-label controls, 12 independently parsed foreign-read controls, 6 De Bruijn storage observations, 1 source census | `20084238bdffdb87d319aa7d95833173ab57ab9fa9130edcea525b3ae5a64ede` |
| `p511-frontiers.tsv` | 108 replayed occurrences, 66 authorized, 42 guarded | `5df485f28d5fc9ec08c500295e993e1283d67593b17a877e9b883797ec5d01aa` |

The Java witness also requires six public bounded fixed-point comparisons, 12 post-substitution RHS identity checks, and four deadline-governed synthetic uncapped checks. Lean rejects three ordinary inconsistent observations derived in memory from a genuine positive row by removing its visible name, removing its frontier, and reversing its source decision. Focused invocations are `P511LexicalTransportTest SOURCE FRESH/p511.tsv` and `lean --run P511LexicalReplay.lean FRESH/p511-frontiers.tsv`. Their markers are `P511LexicalTransportTest PASS methods=6 cases=17 rows=145` and `P511LexicalReplay PASS frontiers=108 authorized=66 guarded=42 controls=3`.

The correspondence trusts the pinned Alloy parser’s resolved identity and multiplicity, the JVM, the JDK’s attributed source trees, and the reviewed mapping from these Java methods to the Lean model. The trace replay demonstrates actual original and transformed inputs for the recorded cases. The general proof quantifies over fresh coordinates, capture-avoiding lexical scopes and permutations preserving whole entries. The source inventory freezes the implementation of those conditions for review. E-graph congruence, arbitrary unrelated rewrite equivalence, and corpus-wide results have separate obligations.
