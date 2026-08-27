# `.acgncert` Format

This document specifies `acgncert-schema-v10`, the closed input language of
the independent verifier. Brackets below list scalar fields in order; braces
list child nodes in order. A trailing `*` means zero or more children.

## Envelope

```text
8 bytes   ASCII "ACGNCERT"
2 bytes   unsigned format version, big endian (currently 1)
8 bytes   unsigned payload length, big endian
N bytes   canonical Wire tree
32 bytes  SHA-256(payload)
```

The encoder rejects ill-formed Java strings instead of replacing malformed
UTF-16, and the decoder rejects invalid UTF-8, signed/overflowing lengths, truncation,
trailing bytes, digest disagreement, configured depth/count violations, and
any payload that does not re-encode byte-identically.

## Wire Tree

Each node is encoded recursively:

```text
u32 + strict UTF-8 bytes   tag
u32                       scalar count
  u32 + strict UTF-8      each scalar
u32                       child count
  node                     each child
```

Embedded structural-key strings use their own injective grammar: each inner
length counts UTF-16 code units, and the standalone parser consumes exactly
that many code units. The enclosing wire scalar still uses the strict UTF-8
byte length above. Consequently, one supplementary scalar contributes two
inner structural-key units and four outer UTF-8 bytes; producer and verifier
retain that distinction byte-for-byte.

Operator semantic identities and polymorphic type-parameter identities use
the same well-formed visible scalar vocabulary as producer declarations;
whitespace, controls, format characters, surrogates, private-use code points,
and unassigned code points are not canonical declaration identities.

Tags and enum values are closed by the schemas below. Indexed tables are
strictly increasing by ID and contain no duplicates. Decimal integers use
their shortest unsigned spelling. Booleans are exactly `true` or `false`.

The records `context`, `embedding`, `term`, `proof`, `snapshot`,
`canonical-record`, and `unfolding` are content addressed. Their lowercase
SHA-256 ID is computed over the same node retagged as `<tag>/content`, with
the first scalar omitted. Hashes provide integrity and lookup only: every
referenced record is decoded, type-checked, and structurally compared.

## Bundle

The root has exactly this shape and child order:

```text
acgncert-bundle["acgncert-schema-v10"] {
  metadata manifest contexts embeddings terms proofs witnesses snapshots
  events canonical-records unfoldings publication
}
```

```text
metadata[
  producerCommit, dirty, producerVersion, componentVersions, runId, createdAt,
  PUBLICATION|TEST_ONLY, javaSourceSha256, producerJarSha256, dependencyHashes,
  inputIdentifier, inputSha256, exporterSourceSha256, verifierVersion,
  verifierSourceSha256, verifierJarSha256, configuration, configurationSha256
]

manifest[theoryDigest,vocabularyDigest] { theory vocabulary }
```

`theoryDigest` is the content ID of the complete `theory` child. Integrity is
not authority: the verifier caller must independently supply the same digest
as a trust pin. `vocabularyDigest` integrity-checks input-specific typed
declarations but is not an authority boundary. `PUBLICATION` metadata is
rejected when its dirty flag is true; `TEST_ONLY` is an explicit fixture mode.
The configuration hash is recomputed by the verifier. External release
provenance checks the recorded source, build, dependency, and input hashes.
`inputIdentifier` and `inputSha256` identify caller-supplied provenance only.
The semantic left endpoint certified by this schema is the decoded normalized
typed term in the replay records; the bundle contains no raw-Alloy parser or
normalization derivation.

## Pinned Theory And Typed Vocabulary

```text
theory[
  "acgn-exact-alloy-theory-v2",
  "phase-j-proof-kernel-v3",
  "typed-content-addressed-uninterpreted-vocabulary-v1"
] { axioms }

vocabulary["typed-content-addressed-uninterpreted-vocabulary-v1"] {
  schemas operators binders semantic-evidence
}

schemas { schema* }
schema[id,kind,value,arityPolicy,siblingQuotient] { schema-ref[childSchema]* }

operators { operator* }
operator[id,outputType,semanticIdentity,flatPath] { schema-ref[portSchema]* }

binders { binder* }
binder[id] { coordinate* generator* }
coordinate[
  index,slotName,type,quantifier,disjointClass,domain,multiplicity,exchangeClass
] { dependencies[precedingSlotName*] }
generator[targetIndexForSource0, ...]

semantic-evidence[
  bitwidth,overflowMode,temporalMode,rewriteMode,signatureVersion,
  profileFingerprint,lawRegistryVersion,lawTheoryDigest
] {
  law-certificates flat-constructions container-constructions
  binder-occurrences exact-types call-occurrences
}

exact-types { exact-type* }
exact-type[id,kind,symbol] { type-ref[id]* }

flat-constructions { (flat-construction | dependent-chain-construction)* }
flat-construction[
  key,profile,operator,path,SINGLETON|NODE,target,leftEndpoint,rightEndpoint,
  sourceOwner
] { flatInput splices container-trace }

dependent-chain-construction[
  key,profile,JOIN|ARROW,target,leftEndpoint,rightEndpoint,sourceOwner,
  theoryVersion,theoryDigest,theoryIndex,sourceOccurrenceCommitment
] { dependent-chain-input }
dependent-chain-leaf[term,relationType,typeRule,key,typeProof] {
  dependent-type-dag
}
dependent-type-dag[relationFamilyType,commonAncestorType|NONE,arity,key] {
  dependent-type-product*
}
dependent-type-product[alternativeIndex,relationProductType,key] {
  dependent-chain-column+
}
dependent-chain-column[exactColumn,key] { dependent-chain-ancestor+ }
dependent-chain-ancestor[type]
dependent-chain-application[JOIN|ARROW,context,outputType,key] {
  dependent-chain-input dependent-chain-input
  dependent-type-dag dependent-chain-combination-cases
}
dependent-chain-combination-cases[count] {
  dependent-chain-combination-case*
}
dependent-chain-combination-case[
  leftAlternative,rightAlternative,
  ARROW_PRODUCT|JOIN_OVERLAP|JOIN_DISJOINT,key
] {
  (dependent-chain-boundary | dependent-chain-no-boundary)
  (dependent-type-product | dependent-chain-no-result)
}
dependent-chain-boundary[
  EXACT|LEFT_SUBTYPE_OF_RIGHT|RIGHT_SUBTYPE_OF_LEFT|DISJOINT_BRANCHES,
  leftBoundary,rightBoundary,meetBoundary|NONE,commonAncestor,key
] {
  dependent-chain-boundary-left-path
  dependent-chain-boundary-right-path
}
dependent-chain-boundary-left-path { dependent-chain-boundary-step+ }
dependent-chain-boundary-right-path { dependent-chain-boundary-step+ }
dependent-chain-boundary-step[type]
dependent-chain-no-boundary[ARROW]
dependent-chain-no-result[DISJOINT]

`sourceOccurrenceCommitment` is a canonical structural key with tag
`alloy-dependent-chain-source-occurrence-v1`, one nonblank deterministic path
scalar, one `alloy-dependent-chain-typed-source-v1` child containing the exact
independently replayed typed source key, and one
`alloy-dependent-chain-source-content-v1` child containing the canonical Fast
Rewrite binary-source content. It participates in the left certificate endpoint
and certificate key.

Dependent-chain theory v10 represents each relation type as a finite normalized
union of correlated ordered products. A union remains a product antichain;
ARROW takes the correlated Cartesian product; and JOIN serializes one complete
row-major decision for every pair of alternatives. Exact and one-sided subtype
boundaries contribute a product. Distinct authenticated `PrimSig` branches
serialize both paths to their first common ancestor and contribute no product.
Every exact column and ancestry step is either `Int` or a nullary constructor
with a nonempty, well-formed visible `AlloySig:` identity. Whitespace, Unicode
space separators, controls, format characters, surrogates, private-use code
points, and unassigned code points are rejected; generic constructors cannot
become exact singleton columns.
An explicit `univ` boundary is an ordinary exact column and may overlap by
exact identity or by a concrete-to-`univ` subtype path. By contrast, `univ`
appearing only as the first common ancestor of two divergent concrete branches
proves disjointness and never overlap. The term carrier remains an ordered,
duplicate-preserving dependent `Seq`. If every pair is disjoint, the DAG has
zero product alternatives but retains a positive-arity
`AlloyEmptyRelation$arity=n` carrier and the complete decision matrix.

The verifier independently reconstructs one acyclic, single-parent nominal
ancestry ledger, every normalized product family, every common-ancestor node,
every pair decision, and every application and flat result. Synthetic family
and common-ancestor nodes never enter the nominal parent ledger. The wire proves
only internal structural consistency. It contains neither raw Alloy declarations
nor an independently pinned signature hierarchy, so a well-formed nonexact
subtype or disjoint-branch proof produces
`UNCHECKABLE / MISSING_EVIDENCE` after structural replay. A malformed subtype
or disjointness proof is `REJECTED`; an exact-only chain can remain verifiable.
Zero `dependent-type-product` children are valid only for a positive-arity
`AlloyEmptyRelation$arity=n` carrier whose encoded arity is `n` and whose
common ancestor is `NONE`. Every nonempty relation family has one or more
products, and every product has exactly the encoded positive arity.

container-constructions { container-construction* }
container-construction[
  key,profile,operator,path,target,leftEndpoint,rightEndpoint,sourceOwner
] { input-occurrences container-trace }

binder-occurrences { binder-occurrence* }
binder-occurrence[
  key,source,target,rootRelativePath,automorphism,occurrencePermutation,
  leftEndpoint,rightEndpoint,enclosingRoot
]

call-occurrences { call-occurrence* }
call-occurrence[
  key,occurrenceId,sourcePath,sourceSpelling,qualifiedCallee,
  call/formula|call/expression,declaredArity,
  DECLARATION|TYPECHECKED_IMPORT,sourceEndpoint
] { call-argument[role,argumentEndpoint]* }

axioms { axiom* }
axiom[id] {
  leftPattern rightPattern type-variables term-variables side-conditions
}
pattern[kind, sortKind, sortValue, symbol, attribute*] { pattern* }
type-variables[typeVariable*]
term-variables { term-variable[name, sortKind, sortValue]* }
side-conditions { side-condition[kind, argument*]* }
```

Exact relation types retain ordered column references. A statically empty
relation whose parser type proves only tuple arity is encoded as the reserved
nullary constructor `AlloyEmptyRelation$arity=<n>`, where `<n>` is a canonical
base-10 positive integer with no sign or leading zero. It carries no
`type-ref` children because Alloy erases the unavailable parent column types;
the producer must not invent `none`, `univ`, or source-child columns. The old
arity-free `AlloyEmptyRelation`, zero/negative/noncanonical arities, and an
argument-bearing reserved constructor are invalid. A positive-arity typed
empty relation has no column children but may occur as a JOIN or ARROW source
or result family. Its retained arity participates in the JOIN flattening guard
and result-arity equation; no nominal boundary or subtype path may be invented
for its absent alternatives.

The binder-occurrence `key` commits to the complete enclosing-root term key,
descriptor, source context and occurrence map, descriptor automorphism,
conjugated occurrence permutation, root-relative path, and both endpoint term
keys. The verifier resolves the path from `enclosingRoot` to `source` and
reconstructs that rooted key independently. Schema v5 used the same record
shape but a rootless key and is therefore rejected as an unsupported historical
schema rather than reinterpreted.

The CALL occurrence `key` commits to every scalar, the complete typed source
term endpoint, and each ordered `(role, argumentEndpoint)` pair. Roles are
exactly `0..declaredArity-1`; the source endpoint must be an `APP` whose
operator identity is reconstructed from the qualified callee, arity, kind, and
arity authority, and whose children are exactly the listed argument endpoints.
Occurrence ID and source path are provenance only: they do not enter the CALL
operator declaration, canonical semantic equality, or repair cost. Distinct
records may therefore point to one hash-consed semantic term, but occurrence
IDs and source paths must each be unique.

Every CALL record also has one nullary model anchor whose operator identity is
`ACGN/CALL-OCCURRENCE/` followed by the canonical unpadded Base64url encoding
of that record's replayed wire key. The verifier reconstructs this identity
from the record, requires exact equality between the complete anchor set and
the complete record set, and separately requires every semantic CALL operator
present in model terms to be covered. The anchor is provenance-only and is not
a canonical CALL operand: it must match the source term's context and sort,
and its term ID must occur exactly once in the complete bundle. This detects
unpaired row or anchor omission/insertion within the serialized normalized
model, including nested or repeated occurrences of one callee. Coordinated
removal of both a row and its self-declared anchor is checked against a
caller-owned `call-occurrence-commitment-v1` value. Its subject is the
length-delimited SHA-256 of the commitment version, caller-owned input
identifier, and input SHA-256. Its value is the length-delimited SHA-256 of
the version, subject, and sorted complete set of replayed occurrence wire
keys. Every non-fixture semantic verification requires this commitment even
when the set is empty. Absence is `UNCHECKABLE / MISSING_EVIDENCE`; mismatch
is `REJECTED / MISSING_EVIDENCE`.

`--inspect-call-occurrences` only formats an untrusted candidate from bundle
claims. It is not source authority and must not be fed back automatically.
Correspondence from arbitrary raw Alloy source to the externally retained
commitment remains outside the standalone verifier and is not claimed by this
MVP.

Schemas, operators, and binders are typed uninterpreted declarations whose
complete vocabulary is independently hashed. In PAIR mode, declarations used
by the common representative must agree exactly across both bundles. Axioms
remain inside the externally pinned theory digest: an untrusted producer
cannot add a ground equality assumption under an unchanged pin.

Schema kinds are exactly `ONE`, `ONE_SLOT`, `ONE_TERM`, `SEQ`,
`DEPENDENT_SEQ`, `BAG`, `SET`, `BIND`, and `BIND_BLOCK`. A homogeneous
container and each binder schema has one child schema. `DEPENDENT_SEQ` has
two or more ordered child schemas, exact finite arity equal to that child
count, and `ORDERED_SEQUENCE` quotient. It is used by the fixed JOIN/ARROW
chain theory: each position is checked against its own schema, duplicates are
retained, and no commutativity or idempotency is admitted. Binder generators must be total
descriptor-preserving permutations:
type, quantifier, disjointness class, domain, multiplicity, exchange class,
and the dependency relation all have to agree.

The fixed dependent theory licenses ARROW reassociation for every well-typed
ordered chain. JOIN reassociation of more than two source operands additionally
requires every interior operand to have at least two relation columns. This
guard is necessary because Alloy JOIN is not associative when an interior
relation is unary. A JOIN source that does not satisfy the guard remains fixed
binary and receives no dependent-chain reassociation authority.

The semantic-evidence ledger is independently replayed. Every construction
referenced by a kernel replay and every binder occurrence referenced by an
orbit must have exactly one matching record; omitted and unreferenced records
are rejected. `RELATION` exact types retain their ordered column list as
`type-ref` children. Publication records must cover every type used by the
model and proof tables, so a textual source type cannot stand in for an absent
exact occurrence type.

## Typed Tables

```text
contexts { context* }
context[id] { slot[name, type]* }

embeddings { embedding* }
embedding[id, INJECTION|BIJECTION, sourceContext, targetContext] {
  image[sourceSlot, targetSlot]*
}

terms { term* }
term[id, kind, context, sortKind, sortValue, symbol, attribute*] {
  term-ref[childTerm]*
}

witnesses { witness* }
witness[id, revision, eclass, context, type, definitionTerm]
```

Context slots are sorted by `(type,name)`. Embeddings are total typed
injections and their images occur in source-context order. `BIJECTION`
additionally requires onto-ness. Term kinds are:

```text
SLOT BOUND APP INVOKE ONE_SLOT ONE_TERM SEQ BAG SET BIND BIND_BLOCK META
```

`BOUND` carries De Bruijn `[depth,coordinate]` attributes. Free-slot action
and invocation-embedding composition are capture avoiding. Seq preserves
order, Bag preserves occurrence multiplicity, and Set deduplicates only
after each element has been quotiented.

## Proof DAG

```text
proofs { proof* }
proof[id, variant, context, sortKind, sortValue, claimedLhs, claimedRhs] {
  premises { proof-ref[id]* }
  payload
}
```

Coordinate dependencies must be unique names of preceding coordinates.
Generators are complete coordinate permutations preserving type, quantifier,
disjointness class, domain, multiplicity, exchange class, and the dependency
relation. The `domain` field is the exact structural declaration-domain key;
it is not a display scope or an implicit `univ` fallback.

The verifier recursively synthesizes `(context,sort,lhs,rhs)` from the
premises and payload, detects cycles, and only then compares the result with
the four claimed fields. The closed payload vocabulary is:

```text
REFL                         refl[term]
SYM                          sym
TRANS                        trans
TRANSPORT                    transport[embedding]
AXIOM                        axiom-instance[axiom,context] {
                               type-substitution { type-entry[name,type]* }
                               term-substitution { term-entry[name,term]* }
                               side-evidence { evidence[kind,argument*]* }
                             }
CONGRUENCE                   congruence[leftTerm,rightTerm]
RESTRICT                     restriction[oldWitness,newWitness,inclusion]
PARENT_EDGE                  parent-edge[childWitness,parentWitness,embedding]
CONTAINER_NORMALIZE          container-normalization[
                               kind,source,target,operator,schemaPath
                             ] {
                               occurrence[sourceIndex,premiseProof]*
                             }
STRUCTURAL_ALPHA             structural-alpha[leftTerm,rightTerm]
FULL_INTERFACE_SYMMETRY      full-interface-symmetry[permutation,leftTerm]
WITNESS_UNFOLD               witness-unfold[witness,embedding]
KERNEL_REPLAY                kernel-replay[
                               source,Gamma0,kernel,Delta,iota,sigma,omega
                             ] {
                               parent-paths
                               port-normalizations
                               structural-proof[proof]
                               effective-support[slot*]
                               source-construction[
                                 NONE|FLAT|CHAIN|CONTAINER,key,leftEndpoint,sourceOwner
                               ]
                             }
FRESH_WITNESS                fresh-witness[witness,kernel,iota,replayProof]
CANONICAL_ORBIT              canonical-orbit[
                               source,base,targetContext,representative,
                               selectedWitness,candidateCount
                             ] {
                               free-renamings { embedding-ref[id]* }
                               leader-groups[snapshot,"complete"] {
                                 leader-group[path,witness] {
                                   generator[embedding,proof]*
                                 }*
                               }
                               orbit-minimum {
                                 term-ref[representative]
                                 embedding-ref[selectedWitness]
                               }
                               binder-occurrence-refs {
                                 binder-occurrence-ref[key]*
                               }
                             }
COLLISION                    collision[
                               leftReplay,rightReplay,leftShapeKey,rightShapeKey
                             ]
REBUILD_CONGRUENCE           rebuild-congruence[firstPremiseProof]
```

`WITNESS_UNFOLD` is a closed, zero-premise definitional rule. The verifier
requires the embedding source to equal the witness context and its target to
equal the claimed proof context, then independently synthesizes
`INVOKE(witness,embedding) = act(witness.definition,embedding)`. The ordinary
claimed-judgment check compares both synthesized endpoints, context, and sort;
none of those fields are taken as authority from the payload.

The `CANONICAL_ORBIT` payload retains the selected witness because the declared
minimum is a pair, not a term-only minimum. `base` is the term before the
selected free action, and replay requires
`act(base, selectedWitness) = source`. The verifier reconstructs every admitted
candidate and compares terms structurally first, then compares the complete
source-ordered witness mapping textually. `candidateCount` counts candidates
before equal-term deduplication, so a witness tie cannot disappear behind an
idempotent container.

`KERNEL_REPLAY.parent-paths` contains sorted records:

```text
parent-path[path,initialWitness,leaderWitness,finalInvocation] {
  edge-ref[parentEdgeProof]*
}
```

`port-normalizations` contains one sorted record for every Seq/Bag/Set
occurrence:

```text
port-normalization[path,containerNormalizationProof]
```

There is no generic proof, producer-validity proof, inverse congruence, or
catch-all variant. If a required composed embedding, action term, orbit,
path, occurrence, or premise is absent, the semantic outcome is
`UNCHECKABLE`; false supplied evidence is `REJECTED`.

## Snapshots And Events

```text
snapshots { snapshot* }
snapshot[id, revision, QUIESCENT|DIRTY] {
  classes { class[eclass,witness,context,type]* }
  parents { parent[edge,child,parent,embedding,proof]* }
  shapes {
    shape[
      shape,owner,term,replayProof,occurrenceBijection,
      ownerAmbientEmbedding,shapeOwnerProof
    ]*
  }
  hash-cons { hash-owner[completeKey,eclass]* }
  parent-uses { parent-use[parent,shape]* }
  symmetries { symmetry[eclass,embedding,proof]* }
  maintenance {
    retirements {
      retirement[
        retiredShape,retiredOwner,retiredTerm,retiredReplay,
        retiredOccurrenceBijection,retainedShape,causeProof,
        transferredOwnerAmbientEmbedding,transferredOwnerProof,
        retainedOwnerProof
      ]*
    }
    dirty { dirty-shape[shape]* }
  }
}

events { event* }
event[sequence, kind, beforeSnapshot, afterSnapshot] { payload }
```

Sequence numbers start at zero and are consecutive. Each pre-state must be
the previous post-state. Event kinds and payloads are:

```text
INSERT_FRESH       insert-fresh[eclass,shape,replay,orbit,freshWitness]
INSERT_COLLISION   insert-collision[
                     eclass,sourceTerm,shapeTerm,sourceReplay,freshWitness,
                     occurrenceBijection,ownerAmbientEmbedding,shapeOwnerProof,
                     collidedLiveShape,collisionProof,installedParentEdgeProof
                   ]
UNION              union[parentEdge]
ADD_SYMMETRY       add-symmetry[eclass,embedding,fullInterfaceProof]
RESTRICT_INTERFACE restrict-interface[
                     eclass,oldContext,newContext,restrictionProof
                   ] {
                     transported-evidence {
                       (transported-parent[
                          edge,oldEmbedding,oldProof,newEmbedding,newProof
                        ]
                       | transported-shape[
                          shape,oldOwnerAmbient,oldProof,newOwnerAmbient,newProof
                        ]
                       | transported-symmetry[
                          eclass,oldEmbedding,oldProof,newEmbedding,newProof
                        ])*
                     }
                   }
REBUILD_RECORD      rebuild-record[oldShape,newShape,rebuildRootProof] {
                      replace[] | retire[retirement]
                    }
PATH_COMPRESS       path-compress[child,parentEdgeProof] {
                     original-edge[edge]*
                   }
REBUILD_START       rebuild-start[beforeSnapshot]
REBUILD_COMPLETE    rebuild-complete[changed]
```

The checkpoint verifier recomputes complete state differences and rejects
all mutations not authorized by the named event. Only
`RESTRICT_INTERFACE` may change an existing class interface. Its transport
children are an exact ledger of every changed parent, shape, and symmetry
record; unchanged sections are exact frames. Schema v10 currently fails closed
when restriction would add or remove a symmetry key.

`REBUILD_START` is an exact no-op over one dirty snapshot. Its payload must
name the event pre-state, and its post-state must be the same content-addressed
snapshot. A successful rebuild report begins at this retained boundary; a
completion cannot absorb an earlier ordinary union into its accounting
interval.

Every live shape carries two independent ambient maps. The occurrence map is
a bijection from the exact shape-term context. The owner ambient map starts at
the current owner witness context and has the same target. `shapeOwnerProof`
must prove, in that orientation and common target context,

```text
act(shapeTerm, occurrenceBijection)
  = act(currentOwnerWitnessDefinition, ownerAmbientEmbedding).
```

The retirement section is an append-only snapshot ledger. Each record
conserves the complete removed live record, identifies the retained live shape
(possibly through a finite acyclic retirement chain), carries the exact
transfer equation to the retained owner, and preserves that retained record's
owner proof. Its cause is the exact installed `PARENT_EDGE` for a duplicate
union or the exact `REBUILD_CONGRUENCE` root proof for rebuild retirement.

`UNION` partitions every live shape owned by the absorbed leader into exactly
one case:

1. An unrelated record is unchanged.
2. If the parent did not already own the exact term, the record is rehomed to
   the parent-qualified ID and no retirement is added.
3. If that parent-qualified record already existed, it remains byte-for-byte
   unchanged and the absorbed record is retired to it.

These cases are exclusive. In particular, an ordinary rehome accompanied by
a retirement is invalid. Hash-cons, reverse parent-use, dirty, and retirement
deltas are recomputed exactly.

`REBUILD_RECORD` is likewise an exclusive sum. `replace[]` requires the target
shape to have been absent, installs exactly that target with the supplied
nontrivial checked root proof as replay, and adds no retirement. `retire[id]`
requires the exact target shape to have existed already and remain unchanged;
it removes only the old dirty shape and appends exactly the named retirement.
No record may take both branches, and an omitted branch or ledger field is a
closed-schema error.

`INSERT_COLLISION` keeps source replay, fresh witness allocation, occurrence
embedding, owner ambient embedding, shape-owner equation, collision sides,
and installed parent edge distinct. All are endpoint-bound. The collision
proof consumes exactly two replay sides for the exact structural key, and the
installed edge consumes that exact collision proof.

## Canonical Records

```text
canonical-records { canonical-record* }
canonical-record[id, orbitProof, representative] {
  source-replay-ref[kernelReplayProof]
}
```

Every `shape` identifier is owner-qualified and content-addressed as
`shape/sha256(producer-shape-id[owner, exactCanonicalTermId])`. The verifier
recomputes this identity. Rehoming a live shape therefore creates a different
record identity even when its structural term is unchanged, and a union must
retain the exact term, replay evidence, and occurrence embedding unless the
parent already owned that same exact term.
`parent-use` and `dirty-shape` always reference that complete record identity,
never a shape-only alias.

`hash-cons` is a total finite relation from each complete structural key to a
nonempty set of current leader owners. Records are canonically ordered by
`(completeKey,eclass)`. Equal shape proposes a collision but does not imply a
union: multiple leaders may remain in one bucket only when neither exposed
interface admits the exact directed embedding induced by the two serialized
shape-to-occurrence bijections. The verifier reconstructs the same
parent-witness inverse followed by child-witness action used by the graph. A
compatible pair retained without its directed parent proof is
`INVALID_COLLISION`. Schema v2's
single-owner map is ambiguous and is rejected as an unsupported format; it is
never migrated implicitly.

The canonical profile reconstructs all globally admissible free-slot,
leader-group, and binder-block actions, applies declared Seq/Bag/Set
semantics, compares the supplied complete orbit, and proves the selected
structural key is the global minimum. A resource cap or incomplete finite
orbit is `UNCHECKABLE`.

## Finite Unfolding

```text
unfoldings { unfolding* }
unfolding[id, rootInvocation, height, normalizedTerm, snapshot] { rep }

rep[invocation, shape, restoredTerm, height] {
  ambient-extension[embedding]
  redundant-assignments { fresh[sourceSlot,targetSlot]* }
  rep-children { rep-child[indexPath] { rep }* }
}
```

Every invocation occurrence must have exactly one child record. Recursive
cycles, undeclared cutoffs, non-fresh assignments, wrong heights, and stale
snapshot references are rejected. Exhaustion of configured finite limits is
`UNCHECKABLE`.

## Publication

```text
publication[snapshot,revision,rootTerm,observationTerm,theoryDigest] {
  ec-evidence { ec[eclass,witness]* }
  pc-evidence { pc[parentEdge,proof]* }
  sc-evidence { sc[eclass,embedding,proof]* }
  canonical-refs { canonical-ref[id]* }
  unfolding-refs { unfolding-ref[id]* }
}
```

Publication must name the final quiescent snapshot, its exact revision, the
pinned theory, complete current EC/PC/SC families, and every canonical and
unfolding record. Dirty, stale, incomplete, or cross-theory publication can
never verify.

## Producer Compatibility

The verifier wire schema and binary envelope versions are exclusively
`acgncert-schema-v10` and `1`. Historical roots, including v9, are rejected
rather than migrated or reinterpreted. `CertificateBundleWriter` emits v10 and
must provide the v10 occurrence embeddings, owner equations, maintenance
ledgers, source constructions, and closed event branches for every supported
bundle. Neither writer nor verifier synthesizes those fields for older bytes.

The producer bridge otherwise identifies itself as
`phase-j-producer-export-v3` and emits rule-set version
`phase-j-proof-kernel-v3`. Its semantic subset admits rigid schemas,
homogeneous Seq/Bag/Set, and
ordered positional `DEPENDENT_SEQ`; APP and INVOKE
terms; identity typed embeddings; AXIOM, SYM, PARENT_EDGE, CONGRUENCE, TRANS,
WITNESS_UNFOLD, KERNEL_REPLAY, CANONICAL_ORBIT, and FRESH_WITNESS proofs. JOIN and plain ARROW
may use a `DEPENDENT_SEQ` only with an independently replayed source tree,
normalized correlated-family DAG, complete alternative-pair proof matrix,
fixed theory digest, and construction owner. The
leaf `typeRule` is `EXACT_RELATION` when the stored One-port type is already
the claimed relation type, or `PRIMITIVE_SET_SINGLETON` when an `Int` or
`AlloyCarrier(S)` slot is independently lifted to unary `Rel(Int)` or
`Rel(AlloySig:S)`. Parameters use this exact underlying carrier rule and remain
distinct through their typed-slot ordinals; constructor spellings such as
`Parameter0` grant no typing authority. No other coercion is accepted. An
explicit source relation containing `AlloySig:univ` may receive a dependent
certificate when the complete chain equation and JOIN interior-arity guard
hold; missing or unresolved typing cannot fabricate that column. Generic flat/container evidence
cannot consume `DEPENDENT_SEQ`.
The emitted bounded history subset uses either a nonempty contiguous sequence
of bottom-up fresh insertions or the exact six-event parent-path history
described in `README.md`. It requires a bounded complete free-renaming orbit,
checked graph/support embeddings, a final quiescent snapshot, and exactly one
complete root unfolding. Nonidentity free renaming is confined to the
slot-only slice. Insertion collisions, graph e-class symmetries, interface
restriction, nonempty rebuild records, path compression, unsupported support
contraction, indirect parent derivations, cycles, and multiple root unfoldings
are outside the producer bridge.
All tables are content-interned, collision-checked, and emitted in canonical
ID order. Per-input axioms stay under the theory pin; typed symbol declarations
are carried by the separately hashed vocabulary. Recursive term keys include
kind, context, sort, symbol, ordered
attributes, and recursively keyed children.

This subsection records producer capability rather than relaxing v10. It does not remove any
closed verifier record above, nor does it authorize a verifier to infer
missing evidence. The theory digest remains an untrusted bundle field until
the caller supplies the same digest out of band.
