# Seventh CI failure in the legacy sequence extractor

GitHub Actions run `44982396776`, job `137085531283`, failed at step 10 on `7aa4d5029f7b4078b40f581d949d5f8ffe1ce4d2`. The job log reports `VERIFIER_FAILURE: unexpected command outcome: build1-extract-chain-sequences`. The run had no downloadable diagnostic artifact. Local reproduction with the unchanged extractor on the seventh and eighth sources identified precisely two stale records. The remaining 26 records matched. [GitHub Actions job](https://github.com/AlexandervonWu/ACGN/actions/runs/44982396776/job/137085531283)

Both methods belong to `org.acgn.cert.SemanticEvidenceVerifier.SemanticReplay`. The seventh commit added the guarded reconstruction of a single concrete Alloy relation's exact v2 leaf proof to `dependentChainInput/3`. It marks that case as requiring external ARROW source authority. In `verifyDependentChain/1`, it retains the validated occurrence path when the caller supplies an expected ARROW digest. The surrounding verifier checks that path, source commitment, selected root and ordered leaves. The existing sequence checks still require every position of the certified target to match the source leaves, including repeated leaves. These edits changed both whole-method syntax and resolved-symbol fingerprints. The eighth source produced exactly the same two new pairs.

| Extractor object | Version | Shape SHA-256 | Compiler-binding SHA-256 |
| --- | --- | --- | --- |
| replay-source | Previous | `4cc45f14bf4ad74089ba62eae9a9f1daa4f612b9179dee4e7fe372bca2f7af74` | `c03e4e9fd111db518c63997f8fb8ec9d3a043ee80de6ee32cdfd0b0edf0be5fe` |
| replay-source | Reviewed | `2b5ba76cd32106acde5eb375b5f3f4a07bf0b4edc08dc0ae75a5d53659136f54` | `2fd56196eecfeb11371bd81ea0a8f38372b0b103946bfbe9e5b9e927482a8850` |
| replay-certificate | Previous | `a578ce184539c708e9f9b24b5757cfa9e048acfbe41296a8166089c82f51e38f` | `253f55eca20f1e12481db83947987977913183e792d073d88df895ec55b22390` |
| replay-certificate | Reviewed | `92b8dc6a2f9e2d3f704a83495510e0342d5750e689e559ad5a25448884b013d0` | `4627e6b16efd5f9aaf08590f733d36c337d06b191edcc423b27db6bddf8959d0` |

The Java extractor requires both reviewed hashes. The Python replay independently checks the owner, method, arity and both hashes for these two rows. Twelve subcases reject a stale individual hash, the whole stale pair and substitutions of owner, method or arity. Two additional source controls change the exact-proof tag or the retained path. The two-clean-build legacy next-five runner executes both controls against the actual source extractor.

Both source inventories passed all 28 Java checks and emitted identical TSV bytes after the repair. The focused sequence regression passed 55,204 checks, covering 1,872 typed, 12 pipeline, 12 certificate and four barrier observations, with 24 rejected bundles. The replay encoder emitted 1,900 Lean statements. All eight Python replay tests passed. The complete next-five result is recorded by its separate two-clean-build gate.
