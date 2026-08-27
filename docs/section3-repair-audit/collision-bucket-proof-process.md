# Quiescent Collision-Bucket Proof Process

## Claim Boundary

Requirement `P4-01` concerns public observations of a quiescent graph. It does
not assert that the internal hash table is an exact observation while a rebuild
transition is dirty and mutating ownership.

The claim ranges only over states reachable through the supported graph API
under ordinary Java encapsulation. Reflection, `Unsafe`, native-memory
corruption, and external mutation of private state are outside this boundary.
This assumption is necessary but not sufficient: supported transitions must
still be shown to preserve the invariant before a public observation succeeds.

For every exact canonical shape stored by at least one live union-find leader,
the public bucket is finite, nonempty, deterministic, and contains only live
leader owners.

## Implementation Invariant

`TypedSlottedPortEGraph.requireHashBucketsExact` independently reconstructs a
`TreeMap<CanonicalShape,TreeSet<EClassId>>` by visiting every class, retaining
only union-find leaders, and adding every shape currently owned by each leader.
It rejects unless this reconstructed map exactly equals the internal hash
table. `checkInvariants` repeats the reconstruction whenever graph status is
`QUIESCENT`.

The public `hashOwner`, `hashConsSnapshot`, and `hashBucketsSnapshot` methods
first require quiescence. Shapes with no live owner therefore have no bucket;
owned shapes have a nonempty `TreeSet`; every member came from a live leader;
and the sorted map/set order makes the observation deterministic.

## Formal Evidence

[`Phase4CollisionBuckets.lean`](formal/Phase4CollisionBuckets.lean) now models
stored `(owner,shape)` records, a live-owner predicate, a canonical bounded
enumeration of the extensional owner set, dirty/quiescent status, arbitrary
supported mutations, rebuild, and public observation. Lean 4.33.0 proves:

- every stored live owner is a member of its shape bucket;
- such a bucket cannot be empty and is finite because it is a `List`;
- every bucket member satisfies the live predicate;
- duplicate source records do not change membership;
- permutations of the stored records produce the same canonical bucket;
- every supported mutation makes the state dirty;
- rebuild creates an exact quiescent index; and
- any successful public observation after an arbitrary finite supported run
  equals reconstruction from the current stored records and live predicate.

The former reflexive determinism theorem and duplicate-preserving observation
were removed. The revised formal file contains no proof admission tokens and
compiles, but it is an abstract supported-operation contract rather than a
Java refinement proof. Its traceability status remains `PARTIAL/PARTIAL` until
a fresh independent review checks the statement and the Java transition
mapping.

## Executable Evidence

`TheoryStateTest.testGraphOwnershipAndQuiescence` directly checks:

- an empty quiescent graph has no bucket for an unowned shape;
- one live owner creates one observable bucket;
- two incomparable live leaders coexist in one deterministic sorted bucket;
- every observed owner is a current leader;
- reverse record insertion yields the same structural state; and
- dirty graphs reject bucket observations.

The complete suite currently passes 4,207 checks with deterministic seed
`55520260818`.

## Independent Falsification Review

The fresh bounded review retained at
`/tmp/acgn-p4-01-review/report.md` returned `GAP`, not `PASS`; its SHA-256 is
`ca9b9e84b4210749e5ea448d4c26997947b06499c58bf6667a20fad1466f6f67`.
Within 23 shell-command attempts it found no supported-API counterexample,
reran the 4,207-check state suite and 110-check rebuild suite, compiled the
Lean file, and ran a bounded concurrent probe with zero malformed successful
snapshots. It nevertheless blocked the claim because the formal model omits
the Java transition system and because the determinism lemma is only
reflexivity. A reflection-only corruption demonstrated the encapsulation
assumption: a private bucket can be corrupted while the status remains
`QUIESCENT`, after which the public snapshot trusts the status but an explicit
`checkInvariants()` rejects. This is outside the supported API and therefore
is not a behavioral counterexample, but it prevents an unstated universal
state claim.

## Remaining Obligations

The previous formal blockers have an implemented candidate repair but require
fresh independent falsification on immutable bytes. The Java side still needs
a checked abstraction/refinement argument,
instrumented statement/decision and MC/DC evidence, failed-mutator-exit tests,
explicit retired-owner tests across all transition families, and a review
bound to one immutable assurance manifest. The row remains
`PARTIAL/PARTIAL/INCOMPLETE`.
