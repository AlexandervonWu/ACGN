# A2-04 Independent Bounded JOIN Review

## Result

**PASS for the examined general model and bounded DIRECT conformance surface. No concrete scoped blocker found.** This records the mechanical area-check outcomes below, not subjective authority to discharge A2-04, a registered aggregate closure result, or universal Java/refinement correctness. No parent matrix, production source, or results were edited. One fresh area build was completed; the requested aggregate two-clean-build transition remains the aggregate runner's responsibility.

Review date: 2026-09-08. Evidence directory: `/tmp/acgn-join-review-UzzA96Mw` (abbreviated `E` below). The frozen review snapshot is `E/build1/source`; commands, working directories, environment overrides, exit codes, and log hashes are in `E/commands.json` and `E/probe-commands.json`. The SHA-256 of `E/input-manifest.json` is `792d810afed9004a28f9b0a3b443a3a0f0ef4923ea2faf92f2a730f362761b8b`. This is a review-snapshot digest, not an aggregate manifest root. Concurrent CALL-note work changed an unrelated input after capture; examined JOIN inputs remained unchanged. No evidence is transferred to a later aggregate root.

## Mechanical Evidence

| Obligation | Observed result |
| --- | --- |
| A2-04-SEMANTICS | PASS: fresh compilation of all four Lean modules; all 34 named JOIN theorems and their exact axiom inventory checked, without warnings or forbidden assumptions. |
| A2-04-SOURCE | PASS: JDK 17 resolves all four registered whole methods; exact owners, modifiers, AST/binding digests and guard/boundary coordinates match. |
| A2-04-OBSERVATIONS | PASS: Java exits 0, reports 2,930 checks, and emits exactly 469 guard + 458 finite + 2 counterexample + 92 parser rows. Of the guarded finite rows, 132 have nonempty outputs. |
| A2-04-REPLAY | PASS: exactly 1,025 named theorems and 1,025 matching axiom prints; fresh Lean compilation exits 0. Outcomes, including finite tuple outputs, are checked rather than replaced with expected values. |
| A2-04-NEGATIVE | PASS: all 12 generated modules exit 1 with exactly one false-proposition `decide` error each. No missing imports, namespace/syntax errors, or failed reduction substituted for rejection. |
| A2-04-VARIANTS | PASS: all 12 unique anchors mutate once and reject with the intended guard-grammar, whole-method digest, or modifier diagnostic. Each seeded stale output is deleted. Mutations were confined to the snapshot and restored byte-for-byte. |
| A2-04-ENCODER | PASS: all eight registered unit tests. Six additional missing/duplicate/foreign observation or source probes reject against actual emitted tables. |
| Supplemental scoped probes | PASS: 41 ordinary Java API assertions and five Lean propositions; see `E/JoinDirectProbe.java`, `E/JoinModelProbe.lean`, and `E/probe-result.json`. These are review evidence, not additions to the registered census. |

Environment: Lean 4.33.0, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`; OpenJDK/javac 17.0.20; Python 3.10.11; local `lib/*.jar`; no network. All compilation, generated proofs, controls, and probes stayed under `/tmp`. The initial review driver encountered the inherited PhaseA2 private-theorem inventory restriction in the unadapted v2.13 scanner. It then kernel-compiled that dependency with generated public axiom prints and separately checked the full JOIN/replay inventories. This is not evidence that the evolving aggregate private/mutual inventory adapter has passed; that unrelated work remains with its owner.

## Semantic And Source Review

- **Actual relational reassociation:** `GuardedJoinChain.lean:26` proves rotation using tuple witnesses and middle width, not an associativity hypothesis. `wide_eval`, `middle_wide`, and `rotations_preserve_relations` supply width for composite middle subtrees and carry the guard through contexts, symmetry, and transitivity. `rotations_complete` is only syntactic completeness; `arbitrary_chain_relational_equality:187` combines it with semantic preservation. The four-operand supplemental theorem exercises this combination without an equality/associativity premise. `SourceTree` is head-indexed; `TheoryAlloyAdapter.java:1856` traverses matching heads and makes different heads opaque leaves.
- **Imported finite interpretation:** `finite_join_refines_relation:405` connects the imported PhaseA2 `splitLast`/`tupleJoin`/`relationJoin` to existential last/first-column matching and deletion. The specialization is to `Nat`, so the generic imported `BEq` is not silently assumed lawful for arbitrary instances. `finite_tree_refines_relation:422` requires the explicit leaf-membership link, including the empty default for absent indices. `sameRelation_iff:435` is extensional set equality, not duplicate-sensitive list equality. Supplemental kernel probes cover duplicate/permuted tuples, empty input tuples, and `[[]]` versus `[]`.
- **Typing boundary:** `guard_supplies_license:195` links the imported scan to all interior arities; positive operand widths come from `Operand`, not the guard. `wellTyped:278` and `well_typed_chain_equality:294` explicitly require both trees' positive-result typing and leaf column interpretation; they do not derive Java admission from guard acceptance or prove Java DAG equality. `DependentTypeDag.combine:387` and standalone `requireChainCombination:2195` both reject nullary results. The supplemental normal-API probe confirms exact `[A,B] JOIN [B,M,C] JOIN [C,D]` output `[A,M,D]` in both associations/profiles, unary endpoints with ternary interior, retained explicit `univ`, typed empties at every position, nullary construction rejection despite guard acceptance, unary-empty interior rejection, and rejection of nonrelation producer operands.
- **Real bounded certificate/pipeline path:** finite fixtures construct `DependentChainApplication`, call `TypedENode.constructDependentChainCertified`, and locally verify certificates under both overflow profiles. `DependentChainCertificate.build` rechecks ordered leaves, result DAG, target schema and profile. Parser rows really call the parser, visitor, `CanonicalAlloyPipeline.prepare`, and `Prepared.equivalentTo`; the latter compares canonical observations, not Alloy SAT semantics or independent bundle acceptance. The private standalone guard is exercised through ordinary reflective construction, but its null enclosing instance/ledgers provide no full admission authority. No broader claim is made from these rows.
- **Source and evidence mapping:** the extractor first checks the typed guard grammar, then whole-method structure, literal strings, resolved bindings, signatures and modifiers. Its emitted coordinates are registered interpretations of accepted method digests, not a proof of arbitrary Java execution. Fixed hashes are independently enforced by the encoder. The strict census binds fixture IDs, arities, associations and finite inputs. Generated source-coordinate propositions and every observed outcome survive into kernel targets. All negative modules close their namespace and retain the failing theorem; the observed rejection reasons were checked beyond the aggregate engine's exit-code-only negative gate.

## Scope, Trust, And Opportunities

PROVED: the declared relational, guard-link, exact positional-typing and imported finite-interpreter propositions under their stated premises. TESTED: the fixed Java guard, construction/certificate and parser-observation census, plus the explicitly listed supplemental probes. CHECKED: source conformance, fixture/schema completeness, theorem inventories, axiom sets, and actual negative-control failures. None of these categories alone implies universal implementation correspondence.

TRUSTED: Lean 4.33.0 kernel and the printed foundations `propext`, `Classical.choice`, `Quot.sound`; JDK compiler resolution, JVM/reflection and standard libraries; the hashed Alloy/parser jars; Python/extractor interpretation and correspondence from exact Java type/column evidence to Lean predicates; SHA-256, filesystem, OS and hardware. Aggregate snapshot, provenance, verifier registration, input binding and final evidence transition are not certified by this area review.

Nonblocking opportunities: retain the nonuniform exact-column/nullary probes as future registered regressions; diagnostic classification in the aggregate negative gate would make future unrelated exit-1 failures explicit. Neither changes the present result because all current targets were checked to fail for their intended reason. Outside scope, without expanding obligations: general subtype/disjoint alternative matrices, full standalone bundle admission, arbitrary parser/type authority, mixed-head rewrite extensions, integer/resource limits beyond admitted bounds, wire security, hostile object mutation, performance, universal Java/heap/compiler refinement, future revisions, and parent status promotion. No latent meaningful issue affecting the stated current surface was found.

## Examined Hashes

Full paths and SHA-256 values, including every compiled Java source, helper, and all seven jars, are recorded in `E/input-manifest.json`. Principal examined inputs are listed here; basenames are unambiguous within the named JOIN package/formal/theory paths.

| Input | SHA-256 |
| --- | --- |
| `join-notes.md` | `9b2dcddd1dacca4be578326ce8663465020151e4968aa6029b5cf6be6bf8167b` |
| `GuardedJoinChain.lean` | `3e90db2012cb6eb34f60034e4ebf858ed0e21ed674795b34a20dfab1bd3d3eb9` |
| `GuardedJoinChainRegressionTest.java` | `146fde7d8efe6c315fbf31ee4298dce09c56357628f046787a8ca9a8d78009d4` |
| `GuardedJoinChainExtractor.java` | `fa551217a524bc84303bc9feac83c9bf2a47a69db7a8667044d4364f4a467e9d` |
| `third_join_replays.py` | `a1dbebe0cc52717ecae0e55cf7515c07ad17d4995a9662eb57a17c5f7a42c6f3` |
| `test_third_join_replays.py` | `75a898e690e235d976bbb5c18c2da1098e20e0978e0d6a242840509f4fe76310` |
| `DependentChainSequence.lean` | `e46aebdc2ecb6ff7d27c46baefba4fcf545c07403d721618317c6792f4a6d988` |
| `DependentJoinGuard.lean` | `e4eded2514027f04f138bcb2b3af03befe8a933cc41219dbc425eb1305e63fb6` |
| `PhaseA2DependentChains.lean` | `06ec3fc185582f02dc578d74ce9f78002686a90fa19f48ce253b426475e1e4e8` |
| `JoinGuardExtractor.java` | `9cc4a1f067c92cb63f4591fad1b537cf38a61304b670cc1cf11971dc76c6c6a4` |
| `next_obligation_replays.py` | `77a1b5384a9dbb99479a7fec2754f209ba1e02cb87311d22b0d20b8dc053aac2` |
| `DependentChainTheory.java` | `acf07fb882785b963efd3429cd23e733b9dd7903833e64b1fb3034713c9456f7` |
| `DependentTypeDag.java` | `6bfcc55db74a7861fc3801e749dcae2a42653931667c4b88d1f28d30936e0df5` |
| `SemanticEvidenceVerifier.java` | `4a05263577e428f49d9d93eba775938abdc4f0b841b6a465458a26aa31c7f7d0` |
| `DependentChainApplication.java` | `3b1a801ec0f787aa08e2c5d769f7b789ab70b31997fbdaf819ddf8f04baa9220` |
| `DependentChainCertificate.java` | `f0ecb7f46796cc2009b2e9beea5fdce8c3e4c5637db7dfcf1fb228b995018f30` |
| `TypedENode.java` | `ca10df4894cacd51565fe2a898dc309194a01cc170647a971f5a0ac4c5b4914a` |
| `AlloyTypeBridge.java` | `5e30c9cc91978ca5549c98eac6ac27571e72137d4a14fcbcd790fc2326f5f475` |
| `TheoryAlloyAdapter.java` | `a5462fae4faf0824a6531cf03ff21829f77c71855171ff0d3d14224b65980f61` |
| `CanonicalAlloyPipeline.java` | `4b78303e8009fae9be073ca431c9417c5840e6fe53388ff6c4e5623c9d5b4854` |

Artifact hashes: observation TSV `ef48b1ab5fceb72a6326a4383effe3abd8f59ad092b586b77266dd6f2bfe895b`; source TSV `eebe9933d6d3235b89c2788e152ac0e846cbdd41e17119fc11d3314598363dda`; generated replay `1ac839901373bba221c23f4ab525b2e3ea7b631081f9597393b6bfbe7700e87b`. Command ledger `2a1f1c41cd30586d0d7a46a2c6a369a1cfd4fc65f0cd8e3604d7538903b9b237`; probe ledger `2032fa5ca2db285ec1fd9297b03501f91a1592cc6868f88ee8f29a5e821f8d28`; supplemental summary `bcbdcad7cc8ac7059c3a3acc691f0ace0e295509a9430b4c2f27b7fdc6943acc`. Reproduction driver `E/run_review.py` hashes to `e56a8d8beb323c8ff150f2e0d28381181f20a140e30236b137df56a8b9c863aa`; the probe summary binds all supplemental source hashes.

To reproduce against the retained snapshot in a new temporary directory (not run a second time for this review):

```bash
E=/tmp/acgn-join-review-UzzA96Mw
R=$(mktemp -d /tmp/acgn-join-rerun-XXXXXXXX)
cp "$E/run_review.py" "$E/run_probes.py" "$E/JoinDirectProbe.java" "$E/JoinModelProbe.lean" "$R/"
ACGN_JOIN_ROOT="$E/build1/source" python -B "$R/run_review.py"
python -B "$R/run_probes.py"
```
