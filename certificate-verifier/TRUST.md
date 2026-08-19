# Trust Boundary

## Trusted

The verifier trusts only:

1. its own canonical decoder/encoder;
2. finite data-structure and SHA-256 implementations from `java.base`;
3. the small dependent equality kernel: reflexivity, symmetry, exact-middle
   transitivity, typed injection transport, checked registered axiom
   instantiation, and forward congruence;
4. the explicitly implemented replay algorithms for restriction, container
   semantics, alpha action, full-interface symmetry, source-to-kernel replay,
   graph transitions, finite orbit enumeration, and finite unfolding;
5. a complete theory digest, including every admitted axiom, pinned out of
   band by the caller.

The JDK 17 runtime, operating system bytes supplied for the selected files,
and the caller's choice of resource limits and theory pin are environmental
assumptions. Resource limits may reduce an answer to `UNCHECKABLE`; they do
not authorize acceptance.

## Untrusted

Everything in a bundle is a claim, including producer metadata, endpoint
fields, contexts, type annotations, embeddings, proof IDs, hashes, orbit
members, state snapshots, revisions, canonical representatives, unfolding
trees, and observation forms.

The producer Java implementation, `verifyLocal()`, canonicalizer, adapter,
pipeline, repair projection, and distance metric are outside the verifier's
runtime and trust boundary.

The standalone build has no class-path dependency on those components. Its
import audit rejects their package names, and `jdeps -summary` must report
only `java.base`.

## Theory Pinning

Self-hashing is integrity, not authority. Verification requires
`--theory-digest`, and the complete decoded theory, including its ground
axioms, must hash to that pinned value. Typed schemas, operators, and binders
live in a separately hashed vocabulary; PAIR additionally checks exact
compatibility for declarations used by the common representative. Deployment
should keep explicitly approved digest files under `trusted/` or in an
external release manifest. A bundle-selected digest is not a trust decision.

The checked-in `trusted/theory-pins.tsv` currently contains fixture authorities
only. Both are marked pending author review. The empty theory authorizes no
ground equations; the parent-path authority is separately pinned and marked
`TEST_ONLY_INPUT_SPECIFIC`. Its ledger binds the single ground axiom's stable
origin to its axiom ID and lists both complete endpoints. It must not be
generalized into trust for arbitrary producer-supplied input equations.
Endpoint authority is Base64 of exact canonical `Codec.encodeNode` bytes;
human-readable renderings are never compared as an encoding.

## Fail-Closed Policy

Malformed or false supplied evidence is `REJECTED`. Missing evidence,
unsupported historical bundles, incomplete exhaustive orbits/unfoldings, and
resource caps are `UNCHECKABLE`. Neither is converted to success.

Unknown proof/event variants are rejected. There is no producer-validity,
generic equality, inverse congruence, equal-hash, or equal-observation rule.
Endpoint fields and content hashes are never accepted in place of a
bottom-up derivation.

## Producer Boundary Today

The independent checker implements the complete closed schema documented in
`FORMAT.md`. The producer writer serializes only two exact histories:

1. one fresh nullary or `ONE_SLOT` insertion with a height-one unfolding; or
2. two fresh `ONE_SLOT` leaves, one direct certified union, one unchanged
   `REBUILD_COMPLETE`, and one fresh `ONE_TERM` wrapper with a complete
   height-two unfolding and one nonempty retained parent path.

The second history permits one free slot of each type. That restriction makes
the complete free-renaming orbit identity; the writer emits that orbit rather
than asking the verifier to assume it. Every parent-path occurrence and edge
is explicit. The ground axiom is part of the pinned theory, while
input-specific typed symbol declarations are integrity-checked vocabulary.
Successful checking still requires an independently selected theory pin.
The bounded harness selects that pin from the source-controlled manifest before
inspecting any bundle; `ManifestInspector` is only a consistency check.

Publication provenance records Git cleanliness, source, producer/verifier
builds, dependencies, exact input identity, and configuration. The standalone
verifier validates the closed metadata shape and checkable internal hashes;
the release harness compares external source, build, dependency, dataset, and
input identities. Fixtures are visibly marked `TEST_ONLY` and cannot claim
dirty publication provenance.

The writer constructs all content-addressed tables before touching the target
and publishes through atomic sibling replacement. Unsupported histories are
`UNCHECKABLE` and cannot truncate an existing output. Collisions, nontrivial
symmetry, restriction, rebuild records, path compression, contraction,
nonidentity sigma/omega, repeated same-type free slots, flexible containers,
binders, indirect parent derivations, cycles, and multiple root unfoldings
remain outside the producer bridge.

Standalone DTO fixtures may exercise schema records that the producer cannot
yet emit. That does not expand the producer boundary. Historical artifacts
that predate retained proof traces cannot be retro-certified and remain
`UNCHECKABLE`.
