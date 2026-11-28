# Author-Facing Provenance Note

The main manuscript reports the supervised run completed on 27 November 2026 UTC at
commit `9693595eb4f60c6c70b6d8d174ee309d1fdcf9aa`. The paired, complete reference-pool, structural ablation,
controlled capability and slot-typing values come from that run. The primary
coverage chart uses its per-submission nearest distances, with the v3.1
figure style and the legend at bottom right. Appendix B retains the historical
v3.3 tables and per-invariant panels from 26 November 2026. The synthetic
scaling grid remains the v3 experiment. The release evidence records the exact
cohorts for the native trace diagnostics.

The exhaustive replay completed on 28 November 2026 UTC at `177500afd23b74d3d3695b9c38fb6ad0c0709838` (run `617d9fb3-5c46-419b-a596-e167f973985e`). It checked both native programs and both published costs for all 1,894,168 ranking pairs. The full-run figure still uses the original nearest-distance observations. The exhaustive comparison confirmed the score on every one of its ranked inputs. The supplementary replay repeated all 26,673 temporal comparisons. Across editions 196 ordered programs carried different JVM allocation numbers for the same local source occurrences. Substituting the archived numbers reproduced all 392 original and repaired digests. Historical structural and fixed-command cohorts have separate receipts. [Replay evidence and repaired-pair inventory](../docs/experimental-results/exhaustive-ranking-replay/README.md)

## Previous manuscript revisions

The v3.3 paper uses the audited paired, reference-pool, ablation, capability and natural slot-typing measurements. The exact source commit is d5c0c2a07504d53b13b28c61e9e64768c37eb984. The historical 540-predicate synthetic grid remains bound to the v3 release. See the v3.3 headlines and replay data.

**November 25, 2026 (fixed-command comparison).** The evaluation's correct-reference
pool result comes from the v3.2 release, `docs/experimental-results/2026-11-25/`
(pair ledger, per-invariant counts, and verifier) and the original v3 inventory
in `2026-11-21-studies/v3-question-pools.csv`. The three reported columns
are 4,496 raw unique ASTs, 2,074 v3 canonical forms and 1,954 v3.2 canonical
forms, summed over the same 181 invariants. The readers were separately invoked
in that experiment; the post-tag checkout invokes them by default for eligible
source comparisons. The manuscript does not report a new 66,080-file run,
new repair rankings, or an unconditional change to canonical keys.

**November 21, 2026 (v3.1).** Paired-corpus and full-reference numbers, the coverage figure, and appendix tables 1–3 now use `6648d7bd4148e6374a5446eaf12a3f1d7633db52`. The published sources are `docs/experimental-results/2026-11-21/{README.md,headlines.json,question-pools.csv}`. The paired gain is 239 (4,174 to 4,413); the distinct-AST correct-pool gain is 275 (11,607 to 11,882). These populations are not additive. The ablation, natural slot typing, capability and synthetic data below remain v3. Whole-file timing is not available for the two publication runners.

## Historical v3 provenance (not the current natural-corpus results)

- **Experiment commit:** `2d70f89ab67241cd071387ecedd3b2f432821921`
- **Release commit (tag `v3`):** `8770cb4b5f7133bad78058d9bc214f0ca36130d0`
- **Sources of truth:** `git show v3:docs/experimental-results/2026-11-16/README.md` and `git show v3:docs/experimental-results/2026-11-16/headlines.json` (plus the companion `v3` reports under `docs/experimental-results/2026-11-16/`).

## 1. Results Tables and Figures -> `v3` Sources

| Paper Artifact | Location | `v3` Repository Source(s) |
| --- | --- | --- |
| **Table 1** (`tab:eval-effectiveness`): Natural corpus & capability effectiveness | Main text §5.4 | `headlines.json` (`naturalArms`, `naturalAudits`, `capabilityAudits`); `natural-ablation/summary.md`; `capability/REPORT.md` |
| **Table 2** (`tab:eval-runtime`): Natural ablation runtime & memory (Fast Rewrite vs. Cert.-Integrated) | Main text §5.6 | `headlines.json` (`naturalArms`, `naturalAudits`); `natural-ablation/summary.md`; `natural-ablation/comparison.json` |
| **Figure 3** (`fig:distance-coverage`, `figures/v3_repair_coverage.pdf`) | Main text §5.3 | Plotted from `raw_edit_repair_coverage_ast_canonical.svg` in `/media/augustus/8618-0ED0/ACGN/intermediate/publication-capability-repair-20261115-v4/alloy4fun-augmented/` (verified via `summary.md` SHA-256 `de2fbc4f...` in `v3:SHA256SUMS`), matching `augmenter/summary.md` (`Raw Edit Distance Coverage Comparison`) |
| **Figure 4** (`fig:synthetic-grid`, `completion-grid.pdf` + `engine-speedup-surface.pdf`) | Main text §5.5 | Extracted verbatim from `v3:docs/experimental-results/2026-11-16/synthetic/plots/` (SHA-256 verified against `v3:SHA256SUMS`); `synthetic/summary.md`; `headlines.json` (`synthetic`) |
| **Table 5** (`tab:engine-boundary`): Pipeline variant definitions | Appendix B.1 | `natural-ablation/summary.md` (`Arms`); `paired/summary.md` |
| **Table 6** (`tab:compact`, `tables/table1_v3.tex`): Paired representation sizes ($n=61,598$) | Appendix B.2 | `paired/summary.md` (header summary metrics) |
| **Table 7** (`tab:truth_metrics`, `tables/table2_v3.tex`): 17 Alloy4Fun problem variants | Appendix B.2 | `augmenter/summary.md` (`Correct Truth Pools` + `By Question Set`) |
| **Table 8** (`tab:distance-summary`, `tables/table3_v3.tex`): Distance summaries & radius coverage | Appendix B.2 | `paired/summary.md`; `augmenter/summary.md` (`Nearest Correct-Predicate Distance Averages`, `Raw Edit Distance Coverage Comparison`, `Relative Repair Coverage Comparison`); `headlines.json` (`augmenter`) |
| **Table 9** (`tab:ablation-natural`, `tables/table6_v3.tex`): Complete natural ablation + transitions | Appendix B.3 | `headlines.json` (`naturalArms`, `naturalAudits`, `ablationTransitions`); `natural-ablation/summary.md`; `natural-ablation/comparison.json` |
| **Table 10** (`tab:capability-benchmark`, `tables/table7_v3.tex`): 11-family capability suite (5,500 pairs) | Appendix B.3 | `capability/REPORT.md` (`Recovery By Family`); `headlines.json` (`capabilityAudits`) |
| **Table 11** (`tab:typing-ablation`, `tables/table8_v3_typing.tex`): Natural slot typing & synthetic grid | Appendix B.4 | `natural-slot-typing/summary.md`; `natural-slot-typing/comparison.json`; `synthetic/summary.md`; `headlines.json` (`naturalSlotTyping`, `synthetic`) |
| **Figure 5** (`fig:synthetic-wall-surface`, `wall-speedup-surface.pdf`) | Appendix B.4 | Extracted verbatim from `v3:docs/experimental-results/2026-11-16/synthetic/plots/wall-speedup-surface.pdf` (SHA-256 `1fe91ad7...` in `v3:SHA256SUMS`) |
| **Bounded checks & provenance** (§5.4, B.5, B.6) | Main text §5.4, App. B.5–B.6 | `headlines.json` (`boundedSoundness`); `natural-ablation/semantic_soundness.md`; `capability/SOUNDNESS.md`; `synthetic/audit.json`; `synthetic/validation.json`; `README.md` |

## 2. Key Lemmas / Theorems -> `v3` Lean Declarations

| Paper Statement | `v3` Lean File Path | Exact Lean Declaration(s) |
| --- | --- | --- |
| **Theorem 1** (`thm:shape-exactness`): Effective-support canonical-shape exactness | `paper-claims/formal/TypedSlottedEGraphsPaper/NormalizationBridge.lean` | `TypedSlottedEGraphsPaper.NormalizationBridge.AmbientQuotientPresentation.ambientQuotientNormalFormExactness`, `TypedSlottedEGraphsPaper.NormalizationBridge.EffectiveSupportCanonicalizer.effectiveSupportCanonicalShapeExactness`, `TypedSlottedEGraphsPaper.NormalizationBridge.EffectiveSupportCanonicalizer.canonicalRecordPostconditions` |
| **Proposition 1** (`thm:structural-soundness`): Structural realization and congruence soundness | `paper-claims/formal/TypedSlottedEGraphsPaper/StructuralContainerAdapter.lean`; `StructuralSemantics.lean` | `TypedSlottedEGraphsPaper.concreteTypedAlphaSemanticSoundness`, `TypedSlottedEGraphsPaper.concretePortAndNodeCongruenceCertificate`, `TypedSlottedEGraphsPaper.concretePortAndNodeCongruenceSemanticSoundness`, `TypedSlottedEGraphsPaper.StructuralRealizer.structuralRealizationNaturality`, `TypedSlottedEGraphsPaper.structuralAlphaBinderBlockSemanticSoundness`, `TypedSlottedEGraphsPaper.structuralPortAndNodeCongruenceSoundness` |
| **Proposition 2** (`thm:collision-soundness`): Compatible effective-shape collisions preserve equality | `paper-claims/formal/TypedSlottedEGraphsPaper/TheoremBridge.lean` | `TypedSlottedEGraphsPaper.paperF25CertifiedLeaderKernelExtraction`, `TypedSlottedEGraphsPaper.canonicalEqualityYieldsKernelCollision`, `TypedSlottedEGraphsPaper.paperF26CertifiedEffectiveShapeCollision`, `TypedSlottedEGraphsPaper.paperAtom038AmbientCollisionCertificate` |
| **Theorem 2** (`thm:semantic-sound`): Certificate-preserving reachability and finite-unfolding soundness | `paper-claims/formal/TypedSlottedEGraphsPaper/TheoremBridge.lean`; `Reachability.lean`; `TraceSemantics.lean` | `TypedSlottedEGraphsPaper.paperF24FindAndFiniteUnfoldingPreserveEquationalCertificates`, `TypedSlottedEGraphsPaper.paperF27CertificatePreservingReachabilityAndFiniteUnfoldingSoundness`, `TypedSlottedEGraphsPaper.certificatePreservingReachabilityAndFiniteUnfoldingSoundness`, `TypedSlottedEGraphsPaper.obligationAdditionPreservesCoherence`, `TypedSlottedEGraphsPaper.obligationRekeyPreservesCoherence`, `TypedSlottedEGraphsPaper.obligationRemovalPreservesCoherence`, `TypedSlottedEGraphsPaper.obligationCompositionPreservesCoherence` |
| **Section 5.5 mechanism**: Typed-slot fibre partitioning | `docs/slot-typing-ablation/PartitionedPermutation.lean` | `PartitionedPermutation.generated_preserves_key`, `PartitionedPermutation.generated_rejects_cross_partition`, `PartitionedPermutation.every_preserving_mapping_is_represented` |
