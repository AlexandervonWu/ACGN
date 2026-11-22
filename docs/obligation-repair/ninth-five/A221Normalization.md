# A2-21 dependent relation family normalization

The frozen A2-21 statement in `docs/section3-repair-audit/claim-ledger.md` has UTF-8 SHA-256 `4bf2b29d09a49228b6013a04ae6d04576b2e092719bf27e3b9a9d320d0fdd6d3`. The implementation boundary is the positive, uniform-width finite family admitted by `DependentTypeDag`, including the positive-arity empty case. The public union operation consumes the alternatives of already constructed operands. Each row is an ordered tuple of exact graph types and their column evidence.

## Production defect and repair

In the public Alloy model `sig A {}`, construct a narrow row `(A,A)` and two equal wider rows `(univ,univ)`. Supply a live parser column in both narrow positions. Supply live authority in only the first wider row's left position, then supply live authority in both positions of the second wider row. The remaining exact-only univ has the same primitive type and singleton ancestry as the parser-owned univ. All live columns came from the same module object. These are valid `exactAlternative` operands.

The original `preferAuthenticated` used `anyMatch` over an entire row. Grouping the partly authenticated wide row before the fully authenticated one left two products. Reversing the wide rows left one. With complementary wide rows, each of the two orders kept two products. The earlier wide representative had discarded an available column proof. Its ordered key and ancestry paths still matched, hiding the discrepancy from value equality.

After the shared module, hierarchy and equal-key checks, the repair takes the incoming column only if the corresponding incumbent is exact-only and the incoming column has live authority. Each of those four unions now yields one fully authenticated wide row. Omitting the complementary evidence altogether leaves two rows. Each chosen column is an original input object at the same index of the same exact product key. The change also preserves the exact-singleton use by `moreSpecific`.

## Proof and executable evidence

The Lean model groups by the complete ordered key. `representative_coverage` characterizes the authenticated positions by exact-key input membership. `representative_origin` supplies an actual input column at the same position for every coordinate of a representative. `absent_key_iff_strict` characterizes deletion of a represented key. `unique_row_survival` characterizes a product occurring at a unique key. `sibling_retained`, `survivors_incomparable`, `no_duplicate_keys`, `structural_order` and `normalized_key_from_input` establish the retained family properties. An incomparable sibling remains whenever no third represented product strictly dominates it.

Unequal columns can compare in the forward direction only with the same live module and the general carrier on the narrower column's strict parent path. Exact coordinates require matching graph types. `strictRows_spec` and `run_normalizes` relate the executable comparison and normalizer to the theorem statements. The optional `maximal_preserves_denotation` lemma quantifies over a decreasing rank and monotone denotation supplied by its caller.

`A221CompilerContract` binds 35 attributed Java methods and constructors, their bodies, and their resolved method, constructor and member-reference targets. Its ordered stage checks include preflight, equal-key insertion, exact-coordinate source selection, strict aligned comparison, common module identity, positioned parser edges and output sorting. The observed corrected digest is `46a7f0c8ad68d0f1a2cc3b943700d2f6dad34092e20de7ac55ac628b2014e019`. The earlier source fails at the missing coordinate loop before it can produce a result.

`A221NormalizationTest` checks the production result against an independent per-key Java oracle and replays 524 typed result traces in the executable Lean model. The traces cover two orders of every subset of an eight-row correlated family, twelve targeted positive cases, a transitive parent, opposite subtype directions, duplicate and sibling rows, exact-only evidence and typed empty inputs. Separate controls reject a second parse of identical source text, inconsistent ancestry, unequal arities, an omitted dominator, a crossed product and a lost authority. Lean rejects a wrong result for a valid input. The test ensures all live trace capabilities belong to one module before converting them to a local replay token. Structural ranks are taken over every exact carrier and ancestor in each trace.

The source-to-model boundary trusts the pinned Alloy parser and its live module and primitive-signature identities, the Java/JDK compiler and runtime, the registered source decoder, trace projection, and the pinned Lean checker. Java obtains paths by walking the actual parent references and checks reachable signatures, positioned declarations for nontrivial parent edges and the admitted built-in exception. Authority is held in memory by the original module and does not survive value serialization. The registration covers successful Java construction with representable arities and sufficient allocation. The generic denotation lemma has its stated premises. A formal semantics for arbitrary raw Alloy syntax, the parser, or the JVM is outside this claim.

## Focused invocation

After compiling the two witness classes with the candidate producer and its frozen dependencies, run the commands below. The result path must be in a fresh writable evidence directory. The integrated ninth driver supplies those paths and the frozen classpath.

```sh
export ACGN_NINTH_LEAN=/home/augustus/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean
export ACGN_NINTH_PROOF="$source_root/docs/section3-repair-audit/formal/A221Normalization.lean"
"$ACGN_NINTH_LEAN" -j1 -M512 "$ACGN_NINTH_PROOF"
java -XX:ActiveProcessorCount=1 -Xmx384m -cp "$witness_classpath" \
  is.fivefivefive.CanDis.theory.A221NormalizationTest \
  "$source_root" "$results/a221-normalization.tsv"
```

In the isolated draft, 33 named declarations passed the repository proof inventory and pinned Lean checker, with individual axiom reports containing only `propext`, `Classical.choice` and `Quot.sound` where needed. The JVM printed `A221NormalizationTest passed: rows=20`. All five witness outputs are deterministic on the tested inputs. The A2-23 companion updates its raw duplicate-selection model and decoder to use the same coordinate policy. Its existing fifteen executable result rows reproduced byte-for-byte, and its corrected instruction stream passed alongside both existing negative controls. Ninth-batch qualification, shared source pins and clean-build evidence are the responsibility of the integrated registration.
