# Trust Boundary

## Trusted

The verifier trusts only:

1. its own canonical decoder/encoder;
2. finite data-structure and SHA-256 implementations from `java.base`;
3. the small dependent equality kernel: reflexivity, symmetry, exact-middle
   transitivity, typed injection transport, checked registered axiom
   instantiation, forward congruence, and definitional witness unfolding;
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
only. Both are author-approved only for their declared test scopes. The empty
theory authorizes no ground equations; the parent-path authority is separately
pinned and remains `TEST_ONLY_INPUT_SPECIFIC`. Its ledger binds the single
ground axiom's stable origin to its axiom ID and lists both complete endpoints.
It does not authorize arbitrary producer equations, corpus-wide certification,
or production claims.
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

`WITNESS_UNFOLD` does not enlarge the admitted theory. It accepts no premises
and treats its payload only as references: the verifier checks the embedding's
exact source and target contexts and synthesizes both sides as
`INVOKE(witness,embedding)` and `act(witness.definition,embedding)` before the
normal claimed-judgment comparison.

## Producer Boundary Today

The independent checker implements the complete closed schema documented in
`FORMAT.md`. The producer writer serializes two bounded history families:

1. a nonempty, contiguous, bottom-up history containing only fresh insertions,
   with the final insertion as the published root; or
2. the exact six-event parent-path history: two fresh `ONE_SLOT` leaves, one
   direct certified union, one exact no-op `REBUILD_START`, one unchanged
   `REBUILD_COMPLETE`, and one fresh `ONE_TERM` wrapper.

Both families require a final quiescent snapshot, exactly one complete root
unfolding, complete retained insertion provenance, and a free-renaming orbit
within the configured finite bound. Nonidentity free renaming is confined to
the explicit slot-only slice; graph/support embeddings (`iota`, `sigma`,
`omega`, fresh return, and shape instantiation) otherwise obey the writer's
checked support restrictions. Within a supported term, the writer recursively handles `One`,
homogeneous `Seq`/`Bag`/`Set`, `Bind`, `BindBlock`, and the dedicated ordered
dependent `Seq` for guarded JOIN and ARROW. Nonidentity binder descriptor and
occurrence actions are explicit semantic evidence; they are not graph
interface symmetries. Flat/container/dependent normalization is exported only
with its concrete source construction and fixed-theory evidence.

In the parent-path family, every parent occurrence and edge is explicit. The
ground axiom is part of the pinned theory, while input-specific typed symbol
declarations are integrity-checked vocabulary. Successful checking still
requires an independently selected theory pin. The bounded harness selects
that pin from the source-controlled manifest before inspecting any bundle;
`ManifestInspector` is only a consistency check.

Publication provenance records Git cleanliness, source, producer/verifier
builds, dependencies, exact input identity, and configuration. The standalone
verifier validates the closed metadata shape and checkable internal hashes;
the release harness compares external source, build, dependency, dataset, and
input identities. Those input fields are provenance, not semantic authority:
certificate replay starts from the decoded normalized typed term and does not
prove raw-Alloy parsing or normalization. Fixtures are visibly marked
`TEST_ONLY` and cannot claim dirty publication provenance.

The writer constructs all content-addressed tables before touching the target
and publishes through atomic sibling replacement. Unsupported histories are
`UNCHECKABLE` and cannot truncate an existing output. Insertion collisions,
nontrivial graph e-class symmetry, interface restriction, nonempty rebuild
records, path compression, support contraction, nonidentity graph-level
`iota`/`sigma`/`omega`, indirect parent derivations, cyclic unfoldings, and
multiple root unfoldings remain outside the producer bridge. Repeated
same-type free slots are confined to the bounded slot-only renaming slice.
Flexible containers and binders are inside the bridge only under the concrete
evidence restrictions above.

Standalone DTO fixtures may exercise schema records that the producer cannot
yet emit. That does not expand the producer boundary. Historical artifacts
that predate retained proof traces cannot be retro-certified and remain
`UNCHECKABLE`.
