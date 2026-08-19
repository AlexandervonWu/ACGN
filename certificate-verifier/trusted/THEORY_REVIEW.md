# Fixture Theory-Pin Review Ledger

`theory-pins.tsv` is the source-controlled trust input used by the bounded
producer/verifier harness. It is not generated from a bundle during a test run.
Every current pin is author-approved only for its declared test scope. Approval
does not elevate either authority or make either pin a production theory.

## Shared Theory Identity

- Theory ID: `acgn-exact-alloy-theory-v2`
- Rule set: `phase-j-proof-kernel-v3`
- Vocabulary policy: `typed-content-addressed-uninterpreted-vocabulary-v1`

## `fixture-empty-theory-v1`

- Authority: `TEST_ONLY`
- Review status: `AUTHOR_APPROVED_FOR_DECLARED_TEST_SCOPE`
- Digest: `9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c`
- Scope: nullary, slot-only, bundle-level PAIR, and parsed-source PAIR fixtures
- Complete admitted axiom set: empty

The complete theory is the shared identity above with an empty `axioms`
section. This pin does not authorize any producer-supplied ground equation.

## `fixture-parent-path-theory-v1`

- Authority: `TEST_ONLY_INPUT_SPECIFIC`
- Review status: `AUTHOR_APPROVED_FOR_DECLARED_TEST_SCOPE`
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
| Authoritative left endpoint (`Codec.encodeNode`, Base64) | `AAAAB3BhdHRlcm4AAAAFAAAABklOVk9LRQAAAARURVJNAAAABEJvb2wAAAAGdy9lMUAyAAAAQDVmY2NkMzI2ZjlmMGU4Njc4YTM1MmFkZTliZTljMjYzYmZmMDM2ODJlNmJlZDczNTUzYTMzNjBmMDBkMGU1ZjIAAAAA` |
| Authoritative right endpoint (`Codec.encodeNode`, Base64) | `AAAAB3BhdHRlcm4AAAAFAAAABklOVk9LRQAAAARURVJNAAAABEJvb2wAAAAGdy9lMEAxAAAAQDVmY2NkMzI2ZjlmMGU4Njc4YTM1MmFkZTliZTljMjYzYmZmMDM2ODJlNmJlZDczNTUzYTMzNjBmMDBkMGU1ZjIAAAAA` |
| Type variables | none |
| Term variables | none |
| Side conditions | none |

The Base64 values above are the complete encoded endpoints. The harness
decodes them and compares their bytes directly with `Codec.encodeNode` of the
bundle endpoints. `Wire.Node.toString()` is not an authoritative encoding.

For human review only, the same nodes have the following explicit structure.
The tag, scalar-array length and indexed scalar boundaries, and child-array
length are all shown; these blocks are not used by the verifier or harness.

```text
left endpoint (non-authoritative structured rendering)
tag = "pattern"
scalars[5] = {
  [0] = "INVOKE"
  [1] = "TERM"
  [2] = "Bool"
  [3] = "w/e1@2"
  [4] = "5fccd326f9f0e8678a352ade9be9c263bff03682e6bed73553a3360f00d0e5f2"
}
children[0] = {}

right endpoint (non-authoritative structured rendering)
tag = "pattern"
scalars[5] = {
  [0] = "INVOKE"
  [1] = "TERM"
  [2] = "Bool"
  [3] = "w/e0@1"
  [4] = "5fccd326f9f0e8678a352ade9be9c263bff03682e6bed73553a3360f00d0e5f2"
}
children[0] = {}
```

The harness also recomputes the axiom ID from the four origin fields and
checks the empty variable and condition sections. This authority is
deliberately input-specific. It does not establish a policy under which
arbitrary producer-supplied input equations are trusted.

## Approval Boundary

The author approved both entries only under the authority and fixture scope
shown above. The parent entry admits exactly the listed `right=left` ground
equation for the deterministic fixture. It does not authorize arbitrary
producer equations, corpus-wide certification, or production claims. Copying
a digest from a generated bundle remains outside the trust decision.
