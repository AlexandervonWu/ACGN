# P5-08 · Empty-domain quantifiers

The original row requires the empty-domain quantifier rule to fire only after establishing that the admissible binding set is empty. The unit of quantification is an assignment of relation-valued variables. A mandatory ONE or SOME slot over an empty relation has no admissible value. SET, LONE, and EXACTLY over the empty relation admit the empty relation as their single value. Alloy's resolved undecorated unary domain is ONE and an undecorated relation of larger arity is SET.

## Two branch-source corrections

The ordinary parser accepted both counterexamples on the tenth baseline.

* `some x:(none->none) | no none` has a binary domain with zero tuples and exactly one admissible variable value. The canonical normalizer reported false. `NormalForm.domainDescriptor` recognized the width of a `RELATION` but treated `EMPTY_RELATION` as unary. The unused-variable pass, which precedes prenex elimination, consequently added a false existence guard. The patch reads the width of both exact type variants. Prenex and local empty-binding preflights also require a real variable slot and a known multiplicity, established from an explicit operator, known arity, integer type, or authenticated unary builtin none. The retained IR can represent an older bare domain with missing width without granting it this reduction.
* With a binary parameter `r:A->A`, `some x:(r-r) | no none` admits the same single empty value. The raw bottom-up rewrite reduced `r-r` to an untyped `none` before deciding a bare declaration's multiplicity. The patch retains the original declaration domain when that transformation would lose its arity, unless the declaration owns the parser's resolution of an implicitly unary variable. The change counter rolls back all work discarded with that subtree. Applying one normal rewrite pass to just the parsed declaration preserves object identity and reports zero applications.

## Compiler and semantic correspondence

`CanonicalAlloyPipeline.prepare` uses `Canonical.prepare`, `IRAgent.computeNormalForm` and `NormalForm.normalize`. The governed compiler census covers unused-binding elimination, prenex and local quantification, both empty-domain preflights, the declaration descriptor, its exact type producer, the reserved builtin constant recognizer and the semantic-invocation equality used by the difference rule. The canonical guard recognizes none, intersections with a proved-empty operand and differences with a proved-empty left operand or identical semantic invocations. Typed semantic identity and the reserved builtin identity supply the respective premises.

The ordinary raw, raw de Bruijn, Java egglog, Java egglog de Bruijn, slotted, and typed slotted arms come from the production study's engine factory. Each uses the shared scoped bottom-up rewriter. The JDK audit checks its two descent routes, alias/rewrite entry, unary authority, original multiplicity, empty-domain guard and constant-body rule. It independently parses both switch ASTs and requires exact agreement on ALL/NO/LONE/NOTONE=true and SOME/ONE/NOTLONE=false, with an undecided default. Counting/comprehension expression results retain their separate semantics.

`P508EmptyBinding.lean` imports `P506SourceNonempty`, which imports `Phase5SourceRules`. The 16 local kernel-checked declarations include:

* `derived_empty`, `no_value_iff_positive`, and `bare_width_decides` establish the syntax-to-empty predicate, establish exactly which multiplicities exclude all values, and resolve the width-sensitive default.
* `grouped_dependent_fold_requires_no_assignment` applies to arbitrary lists of declaration groups, variable counts, prefix-dependent environments and extra filters such as disjointness. Every group uses its own incoming environment for all shared slots. `no_slot_cannot_block` rejects the empty group as evidence. `shadow_reads_nearest` and `unrelated_coordinate_retains_domain` distinguish nearest and unrelated bindings.
* `all_nullable_zero_admit_empty_choices`, `group_nullable_keeps_empty_tuple`, `nullable_empty_semantics_in_any_width`, and `replacing_wide_declaration_with_unary_none_changes_some` give explicit counterassignments to a blanket empty-domain reduction, including relations on tuples of arbitrary natural width.
* `quantifier_truth_at_blocked` derives the full Boolean table for all bodies from absence of assignments. Its premises follow from `any_blocked_excludes_assignments` and `blocked_slot`.

## Focused measurements

The original tenth checkout and its shared producer supplied the unmodified dependencies. JDK compiled only the two patched production sources and two witness sources into private RAM. `P508EmptyBindingTest <source> <fresh-results>/empty-binding.tsv` reads the original Alloy declarations before production adaptation, checks both truth and falsity endpoints for each example, exercises the isolated fixpoint control, and writes a separate compiler census. A retained observation means the engine equated the formula with neither Boolean endpoint. Ordinary checks cover every multiplicity available in the tested Alloy quantifier grammar, explicit positive and nullable shared groups, prefix-dependent and shadowed declarations, used variables, signed quantifiers and widths through three. EXACTLY is included in the general multiplicity theorem. The executable cases use ordinary Alloy grammar.

| Observation | Result |
|---|---|
| `empty-binding.tsv` | 24 parsed examples × 7 routes, 168 observed endpoints, 92 constant equivalences and 76 retained. SHA-256 `90a60841ae17614155c0a057cf7c292627337c88070069ba6381d73b0ec12965`. |
| `empty-binding-source.tsv` | 32 full method bodies with 888 JDK-resolved call, construction or member-reference targets; both quantifier tables decoded. SHA-256 `4b53160d4eec36b975fa3e3099518a2a0602232852e49dc0ae1c9726f1fc89d0`. |
| Pinned Lean 4.35.0 `-j1` | Fresh Phase5SourceRules → P506SourceNonempty → P508EmptyBinding. All 16 theorem-specific axiom records passed. Only `propext` and `Quot.sound` occur in the new records. |
| Ordinary regressions | `EGraphAblationTest` and `EGraphSaturationTest` passed. `AlloySourceRuleRegressionTest` passed all 332 checks. |
| Production patch | `empty-binding-domain.patch`, SHA-256 `08edf057b90d2d839305ee549b020320a5b113c2eef240f417c78ab54987b194`. |

The preconditions at implementation correspondence are the parser's actual typing and binder ownership, soundness of the certified invocation identity and preceding relational rewrites, the named source-to-compiler binding, and the Lean kernel. The scoped proof establishes safety of this reduction, including conservative retention. It makes no completeness claim for recognizing every semantically impossible assignment. The staged evidence supports the original row on these frozen inputs. The integrated decision belongs to the registered two-build qualifier.
