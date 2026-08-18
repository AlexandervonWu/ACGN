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
5. a theory digest pinned out of band by the caller.

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
`--theory-digest`, and the complete decoded manifest must hash to that pinned
value. Deployment should keep reviewed digest files under `trusted/` or in an
external release manifest. A bundle-selected digest is not a trust decision.

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
`FORMAT.md`, but the producer writer currently serializes only the exact
nullary fresh-insertion vertical slice. It rejects richer traces before
opening an output file. In particular, producer serialization is still
missing for nonempty typed ports/support, contractions and nonidentity alpha
actions, collision/union/symmetry/restriction/rebuild/path-compression
histories, container laws, and recursive or multiple unfoldings.

Those cases have independent DTO-level positive and adversarial fixtures;
that does not make their producer histories available. Historical artifacts,
including the checked-in August 17 run, predate the retained trace and cannot
be retro-certified. Their correct outcome is `UNCHECKABLE`.
