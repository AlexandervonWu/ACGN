# Adaptive Augmenter MVP Status

## Delivered scope

The adaptive augmenter is optional and leaves immutable bootstrap theory `R0`
unchanged. It records positive-distance equivalence observations, validates an
exact source pair in one bounded Alloy execution context, and can issue an
unoriented instance-local equality. Generalization is restricted to the
closed, atemporal Boolean fragment and requires multiple distinct witnesses,
guard checks, negative probes, a generated Lean theorem, dependency checks,
and bounded generation growth before admission.

GC-F108 is handled by a separate verifier input:
`call-occurrence-commitment-v1`. The caller pins the complete occurrence-key
set for a subject derived from the selected input identifier and source hash.
The verifier returns `UNCHECKABLE / MISSING_EVIDENCE` without that authority
and rejects a mismatching set. Thus coordinated deletion of one nested CALL
row and its internal marker no longer verifies against a retained full-set
commitment.

## Explicitly unverified

- Bounded Alloy UNSAT is not an unbounded semantic proof.
- The standalone Lean models do not prove parser/JVM/SAT/SHA implementation
  refinement.
- The anti-unifier and schema search are not proved complete.
- Explicit Alloy `open` dependencies are not yet content-committed by the
  adaptive path; adaptive certification rejects them fail-closed.
- The augmentation JSON ledger is audit output, not restart authority.
- `--inspect-call-occurrences` reads bundle claims and emits an untrusted
  candidate. It is not an independent raw-source derivation.
- The verifier does not independently parse arbitrary Alloy source. A caller
  must retain or review the occurrence commitment out of band and must use a
  distinct input identifier for each selected predicate/function root.
- No convergence, corpus completeness, performance, or rewrite-orientation
  claim is made.

These limits are not hidden behind a `PASS` label. They define the MVP trust
boundary. A source-reachable false equality, false certificate, or violation
of a stated core invariant remains blocking; missing positive-distance rewrite
families are future evaluation data rather than reasons to expand static `R0`.

## Focused reproduction

From the repository root:

```bash
scripts/run_certificate_verifier_tests.sh
scripts/run_certificate_bundle_writer_tests.sh
scripts/run_bounded_ci_java_tests.sh
```

For a reviewed external CALL pin:

```bash
java -jar certificate-verifier/build/acgn-certificate-verifier.jar \
  --inspect-call-occurrences artifact.acgncert

java -jar certificate-verifier/build/acgn-certificate-verifier.jar \
  --profile full \
  --theory-digest <pinned-theory-sha256> \
  --call-occurrence-commitment <subject-sha256>=<occurrence-sha256> \
  artifact.acgncert
```

Do not automate the first command directly into the second; that would make
the bundle its own completeness authority.

## Validation record

The focused 2026-08-26 MVP run completed with:

- `EquivalenceAugmenterTest`: 113 checks;
- `CallExtractionRegressionTest`: 150 checks;
- standalone `VerifierTest`: 181 checks;
- `CertificateBundleWriterTest`: 109 checks in each deterministic run;
- `ProducerSemanticEvidenceMutationTest`: 116 checks;
- producer/verifier integration: 68 inspection checks, 31 theory-pin checks,
  parsed-source PAIR success, and census `VERIFIED=1`, `UNCHECKABLE=2`,
  `REJECTED=0`;
- `Phase1CallExtraction.lean` and `AdaptiveEquivalenceAugmenter.lean`: accepted
  by Lean without output.

The broader `run_bounded_ci_java_tests.sh` is not claimed green. It completed
the pipeline, backtranslation, and e-graph tests before stopping at the
pre-existing `MASGVisitorTypeRegressionTest` assertion
`A directly liftable guarded binder lost its primitive File carrier`. That
normal-form/type-regression issue is outside the adaptive/CALL MVP and was not
silently repaired or reclassified here. No corpus experiment was rerun.
