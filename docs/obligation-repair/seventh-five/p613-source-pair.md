# P6-13 · Source-bound PAIR for the local CALL fragment

The caller supplies two raw Alloy files, one local predicate selector and certificate per file, and one independently trusted theory SHA-256. The result concerns the selected source expressions in the retained typed CALL vocabulary. The registered examples use the TEST_ONLY theory digest `9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c`.

```sh
java -cp "$SEVENTH_CLASSPATH" org.acgn.cert.P613SourcePair \
  "$THEORY_SHA256" "$LEFT_SOURCE" "$LEFT_MODULE/$LEFT_PRED" "$LEFT_CERT" \
  "$RIGHT_SOURCE" "$RIGHT_MODULE/$RIGHT_PRED" "$RIGHT_CERT"
```

The classpath contains the seventh companion, sixth `RawCallSourceAuthority`, the independent verifier classes, the producer classes used by the source authority, and frozen dependencies. No producer export runs inside the companion. A JSON result gives the outcome, code and detail. Exit 0 denotes VERIFIED, 2 REJECTED, 3 UNCHECKABLE and 64 invalid invocation. Java clients may call `P613SourcePair.verify(...)` with the same arguments as byte arrays for source and certificate data. `verifyFull(theoryDigest, source, selector, certificate)` runs the source binding and ordinary FULL verification for a single side.

## What the verifier checks

For each side, `RawCallSourceAuthority.fromSource` parses a named local module, selects a unique nullary predicate and reads its SOME expression. A supported expression contains a tree of local function applications with ordered arguments, exact declared unary relation types and primitive signature leaves. The helper enforces its existing source size and nesting limits. It excludes user imports, macros, overloads and unsupported expressions. A module can declare functions with more than one argument.

`commitment` requires the raw-byte hash and selected declaration in the metadata and compares the entire expected typed tree to the published root. It derives expected CALL occurrence positions, callee identities and ordered roles before checking the candidate occurrence records through FULL. The two commitment subjects include their respective source identifiers and hashes. The companion rejects conflicting inventories under one subject. A caller-supplied theory pin remains necessary on both sides.

`IndependentVerifier.verifyPair` opens the two bound certificate snapshots, runs FULL on each and looks up each published source’s canonical record. Within a bundle, its kernel replay must end at the source of its orbit proof. `CanonicalProfileVerifier.verifyOrbitPayload` enumerates the admitted finite orbit, checks the candidate count, and compares both the winning term and its tie-breaking witness with the claimed minimum. For cross-bundle PAIR, the canonical term comparison key and sort must match, and `requireCompatibleVocabulary` checks the reachable declarations and follows witness definitions. PAIR then composes the left replay and orbit with the reverse of the right orbit and replay. Equal local proof identifiers in different bundles supply no independent authority.

## Finite evidence and limits

`P613SourcePairTest` exports four raw selections, runs four FULL checks through the verifier-only JAR, exercises the caller-facing companion and separately invokes the JAR's PAIR CLI with raw-derived commitments. The final TSVs are `pair/p613-cases.tsv` and `pair/p613-owners.tsv`. The latter binds each source identifier/hash, commitment subject, and local proof and endpoint identifiers to the checked sort and orbit count. Only the recorded display of each canonical key is hashed. The equality check uses the full key.

`some f[A]` and `some (f[A])` produce a common representative for different declared predicates and for identically named predicates in files with different bytes. Two submissions of the identical bytes/selector also verify. The variant `some g[B]` has a different typed canonical key and returns UNCHECKABLE with MISSING_PAIR_DERIVATION. Other controls cover foreign source owners, incorrect theory trust, missing occurrence authority and an absent selector. All four witness orbits contain one candidate. The examples exercise independent ownership and composition while the general canonical verifier supplies the exhaustive orbit implementation.

`P613PairComposition.lean` formalizes owner-indexed endpoints, exact replay/orbit joins, minima over finite candidate lists and the two-sided composition. The final theorem assumes interpretations preserve the source binding and each verified step, and agree for exactly matched typed shapes with compatible vocabularies. It derives equality in that interpretation and membership/minimality of the common shape on both sides. It does not formalize the Alloy parser, the Java verifier, callee implementations or the cryptographic representation of exact source bytes.

The retained vocabulary treats local CALLs by declaration identity, type and ordered arguments. Function implementations and ambient module facts can change the Alloy meaning of an expression without changing this representation. Accordingly, the positive outcome certifies a common checked typed representative in the stated fragment. MISSING_PAIR_DERIVATION records the lack of that common derivation and supplies no Alloy counterexample.
