# Failure Codes

The CLI emits a stable `FailureCode` with every non-verified result.
Unless explicitly noted below, a present malformed or false record is
`REJECTED`. `MISSING_EVIDENCE`, incomplete finite evidence, and resource
exhaustion are `UNCHECKABLE`.

## Encoding And Identity

`BAD_MAGIC`, `UNSUPPORTED_FORMAT_VERSION`, `TRUNCATED_INPUT`,
`TRAILING_BYTES`, `INVALID_UTF8`, `INTEGER_OVERFLOW`, `RESOURCE_LIMIT`,
`NONCANONICAL_ENCODING`, `UNKNOWN_VARIANT`, `INVALID_RECORD_SHAPE`,
`DUPLICATE_ID`, `DANGLING_REFERENCE`, `CYCLIC_PROOF_DAG`,
`CONTENT_ID_MISMATCH`, `DIGEST_MISMATCH`, `UNTRUSTED_THEORY`.

## Typed Kernel

`INVALID_TYPE`, `INVALID_CONTEXT`, `ILL_TYPED_TERM`,
`ILL_TYPED_EMBEDDING`, `NON_BIJECTIVE_RENAMING`, `INVALID_SUBSTITUTION`,
`FAILED_SIDE_CONDITION`, `UNREGISTERED_AXIOM`, `ENDPOINT_CLAIM_MISMATCH`,
`TRANSITIVITY_MIDDLE_MISMATCH`, `MISSING_CONGRUENCE_PREMISE`,
`INVERSE_CONGRUENCE`, `INVALID_CONTEXT_RESTRICTION`,
`INVALID_CONTAINER_NORMALIZATION`, `INVALID_STRUCTURAL_ALPHA`.

## Canonical And Graph Evidence

`INCOMPLETE_PARENT_PATH`, `INVALID_EFFECTIVE_SUPPORT`,
`INVALID_KERNEL_REPLAY`, `INVALID_OMEGA`, `INCOMPLETE_ORBIT`,
`NONMINIMAL_CANONICAL_REPRESENTATIVE`, `INVALID_FRESH_WITNESS`,
`INVALID_COLLISION`, `INVALID_UNION`, `INVALID_SYMMETRY`,
`IMPLICIT_INTERFACE_CONTRACTION`, `INVALID_RESTRICTION`,
`INVALID_REBUILD`, `INVALID_PATH_COMPRESSION`, `SNAPSHOT_DISCONTINUITY`,
`UNEXPLAINED_STATE_DELTA`, `STALE_WITNESS_REVISION`,
`DIRTY_PUBLICATION`.

## Observation And Pair

`INVALID_UNFOLDING`, `INCOMPLETE_UNFOLDING`, `OBSERVATION_MISMATCH`,
`THEORY_MISMATCH`, `MISSING_PAIR_DERIVATION`,
`EQUAL_HASH_WITHOUT_DERIVATION`, `MISSING_EVIDENCE`.

For CALL completeness, a missing caller-owned occurrence commitment is
`UNCHECKABLE / MISSING_EVIDENCE`. A present commitment that disagrees with the
complete replayed occurrence-key set is malformed supplied evidence and is
`REJECTED / MISSING_EVIDENCE`.

`IO_ERROR` and `INTERNAL_ERROR` indicate verifier/runtime failures rather than
a certified semantic result.

## Outcome Classification

| Condition | Outcome |
| --- | --- |
| Canonical bytes decode, theory pin matches, and every requested judgment is independently derived | `VERIFIED` |
| Supplied bytes, records, types, equations, transitions, orbit members, or publication claims are false | `REJECTED` |
| A required proof/path/orbit/unfolding record is absent or an exhaustive check exceeds a configured cap | `UNCHECKABLE` |

The same failure code is deterministic for a fixed bundle, profile, theory
pin, and limits. A timeout or cap must not be retried internally and converted
to `VERIFIED`.
