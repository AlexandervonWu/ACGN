# Fixture Theory-Pin Review Ledger

`theory-pins.tsv` is the source-controlled trust input used by the bounded
producer/verifier harness. It is not generated from a bundle during a test run.
Every current pin is explicitly test-only and pending author review; no entry
is represented as a reviewed release authority.

## Shared Theory Identity

- Theory ID: `acgn-exact-alloy-theory-v2`
- Rule set: `phase-j-proof-kernel-v3`
- Vocabulary policy: `typed-content-addressed-uninterpreted-vocabulary-v1`

## `fixture-empty-theory-v1`

- Authority: `TEST_ONLY`
- Review status: `PENDING_AUTHOR_REVIEW`
- Digest: `9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c`
- Scope: nullary, slot-only, bundle-level PAIR, and parsed-source PAIR fixtures
- Complete admitted axiom set: empty

The complete theory is the shared identity above with an empty `axioms`
section. This pin does not authorize any producer-supplied ground equation.

## `fixture-parent-path-theory-v1`

- Authority: `TEST_ONLY_INPUT_SPECIFIC`
- Review status: `PENDING_AUTHOR_REVIEW`
- Digest: `0901e1ee21d8f82c128ebc93f0e5f1e0b421f7a6833ec16cf5473df3b222b147`
- Scope: deterministic `parent-path` fixture only
- Complete admitted axiom set: the single entry below

| Field | Value |
| --- | --- |
| Axiom ID | `axiom/58e94d294f4ad124f5714584f2c4ad63e5b1886c4ddf83eddc699ed6f8ef3c68` |
| Origin kind | `INPUT_EQUATION` |
| Origin source | `certificate-writer-fixture` |
| Origin declaration | `right=left` |
| Origin ordinal | `0` |
| Left endpoint | `pattern[INVOKE, TERM, Bool, w/e1@2, 5fccd326f9f0e8678a352ade9be9c263bff03682e6bed73553a3360f00d0e5f2][]` |
| Right endpoint | `pattern[INVOKE, TERM, Bool, w/e0@1, 5fccd326f9f0e8678a352ade9be9c263bff03682e6bed73553a3360f00d0e5f2][]` |
| Type variables | none |
| Term variables | none |
| Side conditions | none |

The harness recomputes the axiom ID from the four origin fields and compares
the complete encoded endpoints and empty variable/condition sections with the
bundle. This authority is deliberately input-specific. It does not establish a
policy under which arbitrary producer-supplied input equations are trusted.

## Release Boundary

Before an immutable release tag, an author must review this complete ledger and
either approve a release authority explicitly or retain the narrower fixture-
only claim. Copying a digest from a generated bundle is not review and is never
used by the harness as a trust decision.
