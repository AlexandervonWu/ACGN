# A-01 Design Review

Observed: 2026-09-07, approximately 16:58 UTC. Design analysis only, not a closure certification. Repository reads and one non-writing checker invocation; no repository edits, internet, builds, or investigation of the remaining diagnostics.

## Answer

**No: the existing formal mappings alone cannot mechanically supply a semantics-preserving atomic decomposition of all 191 scoped high-level claims.** They can seed candidate obligations. The concrete missing prerequisite is a mechanically interpretable parent-contract inventory, a defined structural meaning of atomicity, and checked correspondence between each complete parent contract and its decomposition. Exact prose hashes establish identity, not that a formal statement expresses that prose.

## Evidence

- `claim-ledger.md:47` requires every scoped high-level requirement to have an atomic low-level requirement. `requirements-traceability.tsv:2` explicitly leaves decomposition review open. The existing assurance plan (`do178c-assurance-plan.md:39`) requires zero unmapped parents; the already-recorded `global-fault-register.md:277` identifies independent conjuncts being lost inside supposedly atomic rows. Nonempty unrelated children would not satisfy this requirement in its existing context.
- `formal/AssuranceTraceability.lean:3,51,121,135`: `RequirementEvidence` supplies an arbitrary count and Boolean. `GatePass` assumes their desired values; `pass_implies_requirements_decomposed` is exactly `passed.1`. There are no child objects, atom syntax, parent IDs, decomposition semantics, or connection to the frozen 191 IDs. An empty requirements list also satisfies this particular decomposition predicate vacuously. The theorem is a valid conditional projection, not evidence that the actual matrix is decomposed.
- `Section3AssuranceTraceability.java:43,324,395`: the ten-column schema and validation check parent membership/order/hashes, declaration and symbol presence, classifications, and status strings. They neither represent nor check children or atomicity. Formal validation scans theorem/lemma names, not elaborated proposition types. `traceability-schema.md:31,35,41,53` requires exact-claim correspondence in words but expressly limits the mechanical checks. The synthetic passing fixture even maps its rejection claim to `True` (`Section3AssuranceTraceabilityTest.java:191,209`); this tests mapping integrity, not semantic validity.
- Concrete obstruction within the 191: G-05 says certified semantic equality implies repair distance zero (`claim-ledger.md:69`), but its current mapping (`requirements-traceability.tsv:19`) covers conditional presentation equality and bounded pairs/triples. `TemporalAciPhasePresentation.lean:34` itself bundles five conjuncts. Splitting those declarations cannot recover the general claim. The older ledger-named theorem in `CrossPhaseContract.lean:257` additionally assumes `zeroCost`; it does not derive zero cost from certification alone. This is evidence against automatic reuse, not a separate G-05 repair request.

Observed inventory: 191 matrix rows, 24 mapped Lean files, 985 declaration links, 896 distinct file/declaration pairs, and 149 rows naming multiple declarations. None of these counts establishes atomicity or complete semantic coverage.

## Smallest Real Closing Path

1. **Preserve the parent requirements.** Keep the existing 191 ordered IDs, classes, and claim hashes, including A-01. Add a separate low-level table keyed by stable child IDs and parent ID/hash; do not replace the parent census with theorem names. Low-level records do not automatically become additional high-level parents.
2. **Supply exact contracts and a checkable atom language.** Each parent needs an authoritative typed contract with explicit domain, binders, assumptions, and model/implementation boundary. Each child needs an exact typed predicate and independently addressable obligation. Define structural atomicity over a finite interpreted grammar or elaborated syntax with a fixed primitive vocabulary and explicit definition-expansion rules. An arbitrary `Prop`, opaque wrapper, theorem name, single row, or `atomic=true` field cannot certify a leaf. This operational definition is a necessary specification addition, not evidence that existing prose was translated correctly.
3. **Check complete decomposition without new assumptions.** Bind each parent and child contract to their exact bytes/types and require a kernel-checked equivalence between the parent contract and the reconstructed child formula, under the parent's unchanged context. Preserve quantifiers, shared witnesses, implications, and disjunctions; simple textual splitting or conjoining all leaves is not generally equivalent. Existing mappings are candidates, with missing residual obligations made explicit. Merely proving that the parent implies one weaker child is insufficient.
4. **Make A-01 acceptance executable.** Add decomposition validation to the Java assessment and schema. Accept A-01 only when the parent set/order/class/hash is exact, every parent has a nonempty child set, child IDs are unique and parent bindings resolve, every child passes the structural atom check, and every parent has a current checked reconstruction certificate. Derive counts/atomicity from checked records. Replace or supplement the Boolean-only Lean model with actual records and a checker-soundness theorem, plus a concrete checked result for this census. Use pinned Lean/type extraction rather than regex as the proposition authority. A-01's own decomposition must be checked without assuming `GatePass` or its `DIRECT` label.
5. **Validate this predicate and bind its evidence.** Focused tests must reject a missing parent/child, duplicate or orphan child, stale parent/contract hash, an unexpanded compound leaf, omitted conjunct, substituted `True`, strengthened hypothesis, and bounded replacement of an unbounded parent. Include a genuinely valid decomposition. Bind the actual checker/Lean results to the scope, contracts, decomposition, verifier, and toolchain bytes. Only then update A-01's matrix/ledger state and generated rendering; changing the status is an output, never an acceptance condition for decomposition.

Minimum added records: parent ID/hash plus typed contract/context; child ID, parent binding, typed leaf and structural location; reconstruction certificate reference; registered verifier and hash-bound result. The existing parent matrix can remain intact, with evidence mapped to child obligations as their respective diagnostics are handled.

**Why this would close A-01:** it exhibits actual nonempty child requirements for every frozen parent, mechanically checks their defined atomic form, and proves that no parent content was dropped during decomposition. It does not merely assert those facts as gate premises. A-01 concerns decomposition: children can remain explicitly unproved or implementation-incomplete. Proving every child true, implementing every behavior, or closing A-02 through A-12 is not a prerequisite to demonstrating a correct decomposition.

## Immediate Implementation Boundary

The current inputs do not establish that their mapped formal contracts are complete interpretations of the 191 prose claims. A new exact-contract inventory must first resolve that specification boundary. An LLM-authored translation, a review verdict, a claim hash, or compiling the existing theorems cannot mechanically establish English-to-contract equivalence. Adopting formal contracts as authoritative would be an explicit requirements decision, not evidence that the old meaning was preserved; any unsupported correspondence must remain unresolved under this request's constraints.

**Smallest justified actual repair now:** add `validateDecomposition` to Java's ordinary assessment path, independently of the declared status fields. Require a separate low-level registry and fail closed with an A-01 diagnostic when it is absent. When present, check exact parent ID/hash coverage, unique child IDs, nonempty child sets, and references to checked atom/reconstruction evidence; absent or unsupported evidence must still reject. Suggested diagnostic categories: `MISSING_LOW_LEVEL_REGISTRY`, `MISSING_PARENT_CONTRACT`, `UNCHECKED_ATOMICITY`, and `UNPROVED_DECOMPOSITION`. Do not implement a successful semantic branch by accepting theorem-name rows or an author-supplied Boolean.

Minimum immediate regression: a fixture with otherwise valid mappings and both ledger/matrix labels changed to `PROVED/DIRECT` must still fail A-01 when the registry is absent; a one-row-per-theorem registry without atom and coverage certificates must also fail. Assert the decomposition diagnostic, not merely a nonzero global exit caused by unrelated rows. Keep the existing 191 requirement texts/hashes unchanged and A-01 `PROVED/PARTIAL` open; clarify in notes that `PROVED` refers only to the old conditional theorem. This repairs the executable gate's missing obligation check, **not the unmet decomposition obligation itself**.

The precise remaining prerequisite is an exact parent-contract/atom specification and current checked semantic reconstruction for every parent, with unresolved prose correspondence exposed rather than assumed. No further theory search, broad threat model, or global audit is needed for this bounded recommendation.

## Reproduction And Input Identity

Executed, exit 1:

```text
timeout 30s java -Xmx256m src/is/fivefivefive/CanDis/Section3AssuranceTraceability.java --only=A-01 --gate /home/augustus/ACGN
requirements=191
matrixRows=191
ready=87
failures=132
FAIL A-01 conformance_status is PARTIAL
```

`--only` filters printed diagnostics, not the global assessment. Lean was not executed; no mutation tests were run. Paths above are under `docs/section3-repair-audit/`, except the Java files under `src/is/fivefivefive/CanDis/`. These observed SHA-256 values identify the principal inputs, not a frozen closure root; concurrent later changes require rechecking:

```text
claim-ledger.md                 419fa303b9f8a9546c44a6dd2f853e467b415a08a1ae568f965a746bd5455fe8
formal/AssuranceTraceability.lean b2245407eca782310d2737d9e91bb876463ec586ba7d8f613996d696e53b3fe1
Section3AssuranceTraceability.java 3cab407ebd0955dab82e4808c99160177fa732ef2540a146864b5c0bc7e436a1
assurance-scope.tsv             35af1f85302ac791de4ec1fa2136ee97f009123b330bf7c67c464f7a97670b58
traceability-schema.md          cab2606b9177e52b7b249dc878fceca07753f29f498014cbc8021fe6c7538120
requirements-traceability.tsv   ce7a315eaa21d75ca6668e04fab1d01ac2af24e537546c935dc4ba496626323b
```
