# A2-24 dependent JOIN on admitted correlated families

Frozen English SHA-256 `b8a2af71393a0d31b4a39ecaa99be26a9e24b47701ff53b7370fff22db8749c7`.

A binary JOIN enumerates the normalized operand alternatives in their existing order. For left index `i`, right index `j`, and right cardinality `n`, the matrix stores exactly the pair at `i*n+j`. An exact, left-subtype, or right-subtype overlap emits one matrix entry with its boundary and the surviving columns from that pair. An authenticated divergence emits one entry with its witness and no result product. Failure to establish the comparison fails the operation. No semantic row is dropped on that path.

The surviving product is the whole left prefix followed by the whole right suffix. Its arity is the sum of the two input arities minus two. A positive-width all-disjoint step returns that specific typed empty, including vacuous matrices with an empty operand. A unary/unary step and checked arithmetic overflow are rejected. The result family coalesces duplicate product types and absorbs proper subtypes. Thus multiple overlap entries can have one representative in the output DAG. These statements concern individual binary applications and the normalized operands actually presented to them. The order/origin of all raw union inputs is a separate A2-21 question.

## Proofs

Thirty-one declarations checked with Lean 4.35.0, each with an individual axiom report. Only standard `propext`, `Quot.sound`, and `Classical.choice` appear.

- `A224Join` proves the complete matrix size, lookup address and row ordering for arbitrary finite lengths. Successful checked traversal preserves every index. An unclassified pair blocks the complete traversal. A raw product occurs exactly when an identified source pair has a classified, non-disjoint boundary and the product equals that pair's ordered projection.
- `A224BoundaryBridge` imports the actual A2-22 nominal classifier. Omission requires distinct endpoints, shared authority, absence of mutual ancestry, and the named first common ancestor. Its forest theorem excludes every potential atom inhabiting both endpoints on that branch. Every disjoint positive-width pairwise classification constructs the full matrix and a typed empty. Direct fieldwise equality for the ordered decoded record vector follows from size and aligned field comparisons.
- `A224Normalized` uses the current A2-23 coordinate-wise evidence merge. Every retained product’s ordered type key equals that of one projected overlap at an exact matrix address. When several raw products have the same type key, the normalizer may retain evidence from different source rows at different coordinates.
- `A224NinthDenotation` connects the ninth A2-21 coordinate-wise merge to A2-22 forest semantics. For any tuple of potential atoms, its membership in the normalized output is equivalent to an identified classified overlap whose correlated projection contains that tuple. The theorem handles both coalescing and absorption. It assumes that surviving input columns agree with their live forest and that the atom encoding is injective.
- `A224Compiled` interprets the admitted finite JOIN instruction stream and links it to the general row and typed-empty theorems. For the same accepted input, `registered_normalized_result` proves the exact cell at each row-major address, the empty result precisely when all entries omit their product, and membership in the concrete A2-21 normalized output precisely when some classified overlap projects an inhabiting tuple. Two abstract instruction controls remove the disjoint-case instruction or reverse the projected column order. Both fail admission. They run entirely on instruction lists.

The normalization modules compile separately because A2-23 and A2-21 each define an executable root `main`. Both modules use their current ninth sources. One establishes ordered-key provenance by matrix address; the other establishes the denotation of the retained normalized union.

## Java evidence

`A224SourceContract` attributes six Java compilation units with JDK 17 and checks eighteen methods. It checks the producer and independent verifier loop trees, exact indexed lookups, JOIN boundary endpoints, distinct disjoint and overlap branches, ordered column slices and final result construction. The writer serializes the ordered cases and the independent verifier recomputes them before checking count, address, tag, boundary, projected products and structural key. A digest also binds the complete registered method trees and their resolved invocation, constructor and member-reference targets. Four of the methods bind the exact issuer v2 leaf proof, the parser’s whole-product ordering key and the resulting relation spelling.

`A224JoinCases` runs thirteen positive parser/family constructions and four ordinary guards. Its ancestry oracle uses the explicit primitive signature declarations in the test module. It checks both boundary paths, addresses, results and individual source-column identity, then computes the expected normalized output keys independently. The mixed 3×3 case contains three exact decisions, two left-subtype, two right-subtype and two disjoint. Two other 2×2 matrices distinguish equal projected rows from subtype absorption. A raw unauthenticated boundary and incompatible live modules are rejected before a matrix can be returned.

`A224PublicCases` checks five unmodified outputs of the normal producer and independent FULL API. The TEST_ONLY exact overlapping graph passes through ordinary typed graph construction, certificate verification and the public writer before independent replay. Its caller pin follows from the explicit test input and zero CALLs. The four historical writer inputs use the identifiers and bytes declared by their fixture constructors. The exact overlap and empty-interior fixtures return `VERIFIED/NONE`. The subtype, correlated-family and nontrivial all-disjoint fixtures return `UNCHECKABLE/MISSING_EVIDENCE`. The public diagnostic identifies the missing independently pinned JOIN source hierarchy.

## Ordinary source and admission boundary

`A224OrdinaryJoinCases` starts from seven UTF-8 Alloy modules and their selected nullary predicates. One parse resolves each left and right operand and reads each correlated primitive product. Another parse feeds the normal graph visitor and `AlloySemanticProfileFactory.fromExactlyOne` with the actual `run selected for 4` command, then calls the production `prepareForVerification` and certificate writer. The witness checks both exported operand operators and both exact parser spellings against the separate source parse. It checks every encoded pair decision, result arity and result cardinality before invoking the standalone FULL CLI with a source-derived empty CALL commitment. All fixture files carry explicit TEST_ONLY build provenance. The semantic profile is PARSED_SOURCE_COMMAND.

| Source root | Retained boundary decisions in matrix order | Result arity / products |
|---|---|---|
| sub/selected | left subtype | 1 / 1 |
| fields/selected | left subtype | 2 / 1 |
| dis/selected | disjoint | 1 / 0 |
| pair/selected | disjoint, disjoint | 2 / 0 |
| multi/selected | right subtype, disjoint | 3 / 1 |
| ordering/selected | right subtype, disjoint | 3 / 1 |
| equal/selected | exact | 1 / 1 |

The eighth decoder reconstructed v2 EXACT_RELATION spellings only for a single nominal product. It interpreted the correlated `pair` and `multi` issuer proofs as a type mismatch. The issuer's `ExactAlloyType` sorts by concatenated length-prefixed column names and encloses each sorted whole product in brackets. The wire DAG orders products by the graph's exact type comparator. On the mixed-length case the source spelling is `RELATION[1:X1:Z2:AA][1:X2:AA1:Z]`; alphabetical sorting of signature names would put AA first. The independent decoder reconstructs each tuple from the already validated DAG, sorts by the issuer's specified string order, and requires equality of the complete proof including its stored type and DAG key. The standalone distribution has only its Java base dependency.

All seven public CLI executions return exit 3, `UNCHECKABLE/MISSING_EVIDENCE`; the diagnostic identifies the missing independent source hierarchy. The two all-disjoint rows retain positive-width empty families. The last exact comparison has recorded nontrivial signature ancestry. Existing singly represented ARROW source checks and v1 JOIN semantics remain in force. The release exposes caller commitments for CALL and the separate bounded ARROW fragment. The Phase A2 independent-completeness boundary and A2-20 require a refusal when the only nonexact ancestry evidence comes from the bundle.

The original A2-24 clause concerns the exhaustive JOIN decision matrix on admitted typed inputs. Its general proof, compiler correspondence, live producer tests, exact public positive controls, and seven real-source admission observations cover the literal clauses. A broader positive public verification of nominal nonexact JOIN would require separately authenticated JOIN source inputs. It is outside the current caller interface and the matrix theorem.

## Reproduction

Run `org.acgn.cert.A224Qualification ROOT COVERAGE_DIR VERIFIER_JAR EXISTING_OUTPUT_DIRECTORY` with fresh producer and verifier classes, `lib/*`, the six Java witnesses in this directory's `java/`, and explicit test provenance. Set `ACGN_NINTH_LEAN` to Lean 4.35.0, `ACGN_NINTH_PROOF` to `A224Replay.lean`, and `LEAN_PATH` to the registered compiled dependencies. The original-row canonical proof is `docs/section3-repair-audit/formal/A224Compiled.lean`.

The integrated witness passed 18 source methods, 3 program controls, 17 producer cases, 5 public FULL fixtures and 7 ordinary source JOIN cases. The method/binding inventory digest is `91b8e60a360d2afe7a0192cf8300d66c2f10afc4b4c8644ec4294b117dc6e6fd`. The six deterministic result files are registered by the ninth runner. Trust assumptions include the selected JDK and Lean compiler, the finite Java lowering, and the parser-bound nominal forest at the producer.
