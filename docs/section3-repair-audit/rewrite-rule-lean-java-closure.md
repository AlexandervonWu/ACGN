# Rewrite Rule Catalog Reference Record

## Scope

This record covers the cataloged `R0` identifiers used by the Fast Rewrite IR
and the shared e-graph ablation engines. It records that each catalog row names
present Lean theorem or lemma declarations, compiled Java methods carrying the
same row identifier, and source-level regression entry points. It does not
compare a Lean theorem type with Java behavior, prove Java--Lean refinement, or
establish an exhaustive census of executable rewrite branches.

The authoritative inventory is
`docs/section3-repair-audit/rewrite-rule-traceability.tsv`:

- 61 cataloged rule families;
- 24 shared bootstrap names, exactly equal to `JavaEgglog.ruleNames()`;
- 37 production-only alpha, binder, and relational catalog rows;
- explicit Lean, Java, and regression references on every row;
- legacy checker status `PROVED_AND_CONNECTED` on every row. In this record,
  that token means only that the catalog-selected references passed the
  implemented connectivity checks; it is not a Java-refinement result.

## Located Gap

The claim-level requirements matrix grouped many source normalizations under
large Phase 5 obligations. The rewrite catalog makes method-level identifiers
and supporting declaration names inspectable, and it mechanically compares the
24 runtime ablation names with the catalog. That is still not a completeness
or refinement check. The reverse annotation pass visits methods in classes
reached from catalog rows and therefore cannot discover an unannotated method
or branch outside that starting inventory. The Lean resolver checks declaration
kind and name, not whether the declaration's type matches a Java branch.

No Java semantic rewrite is admitted by this metadata. The alias and negated
comparison dispatch tables are modeled explicitly in Lean and independently
cross-checked for literal table parity; those checks do not establish semantic
Java refinement. A third live path, `EGraphNode.dualOf`, participates in
saturation complement folding. Among comparison opcodes, its switch contains
the four ordinary comparison pairs and no `NOT_*` inputs. That comparison slice
is censused, but no checked reachability invariant establishes that the omitted
opcodes cannot arrive there. The absence check locks the audited Java snapshot;
a future Java repair must update the Lean table and parity expectation in the
same change.

## Checks

1. `LeanVerifiedRewrite` records stable `R0-*` catalog identifiers on named
   Java methods; the annotation carries no proof claim.
2. `RewriteRuleTraceability` parses the TSV catalog, checks referenced Lean
   theorem or lemma names, resolves compiled Java methods and matching
   annotations, checks named regression entry points, and reverse-checks the
   annotations found in catalog-reached classes.
3. The checker requires exact equality between the catalog's 24 bootstrap
   names and the names exported by `JavaEgglog`.
4. The bounded checks execute the catalog gate, its Java test, the exact
   dispatch-parity script, and the catalog-referenced Lean files.
5. `Phase5SourceRules.lean` states independent mathematical obligations and
   explicit models of the active alias and negated-comparison dispatch tables.

The earlier source-audit parser repair remains relevant: balanced Java
annotations are erased before source declaration matching so an annotation
array is not mistaken for the declaration itself. This is a syntactic source
check only.

## Verification Meaning

A successful catalog-reference gate reports:

```text
R0 rewrite-rule traceability
rules=61
baselineRules=24
failures=0
```

The output labels are retained for compatibility. They establish only that the
catalog's referenced names, annotations, and baseline list passed the
implemented presence checks. Lean 4.33.0 must separately compile the referenced
formal files, and the parity script must separately compare the explicitly
modeled dispatch tables. The bounded regression inventory includes:

- `AlloySourceRuleRegressionTest`;
- `EGraphSaturationTest`;
- `CanonicalAlloyPipelineTest`;
- `MASGVisitorTypeRegressionTest`;
- `EGraphAblationTest`;
- `RewriteRuleTraceabilityTest`: 61 families, 24 bootstrap names, and a legacy
  output label of zero "correspondence failures" whose implemented meaning is
  catalog-reference connectivity only.

The unchanged Java class comment also uses the legacy phrase "Lean/Java rewrite
correspondence." It has the same catalog-connectivity meaning here; it is not a
refinement or executable-branch-completeness claim.

Passing these checks does not change the broader Section 3 assurance state,
which remains `INCOMPLETE` while its separately recorded diagnostics remain
open.

## Exact Claim Boundary

The Lean declarations prove only their stated mathematical propositions. The
catalog gate checks reference and annotation presence; it neither interprets
the theorem types against Java nor proves that the named method implements
them. Bounded regressions and table-parity checks provide separate finite
evidence. None of these mechanisms proves Java--Lean refinement, inventories
every executable rewrite branch, or closes unrelated diagnostics in the
broader Section 3 assurance matrix.
