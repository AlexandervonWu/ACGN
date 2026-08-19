# `.acgncert` Format

This document specifies `acgncert-schema-v2`, the closed input language of
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

The decoder rejects invalid UTF-8, signed/overflowing lengths, truncation,
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
acgncert-bundle["acgncert-schema-v2"] {
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

## Pinned Theory And Typed Vocabulary

```text
theory[
  "acgn-exact-alloy-theory-v2",
  "phase-j-proof-kernel-v3",
  "typed-content-addressed-uninterpreted-vocabulary-v1"
] { axioms }

vocabulary["typed-content-addressed-uninterpreted-vocabulary-v1"] {
  schemas operators binders
}

schemas { schema* }
schema[id, kind, value] { schema-ref[childSchema]? }

operators { operator* }
operator[id, outputType] { schema-ref[portSchema]* }

binders { binder* }
binder[id] { coordinate* generator* }
coordinate[index, slotName, type, quantifier, disjointClass, scope]
generator[targetIndexForSource0, ...]

axioms { axiom* }
axiom[id] {
  leftPattern rightPattern type-variables term-variables side-conditions
}
pattern[kind, sortKind, sortValue, symbol, attribute*] { pattern* }
type-variables[typeVariable*]
term-variables { term-variable[name, sortKind, sortValue]* }
side-conditions { side-condition[kind, argument*]* }
```

Schemas, operators, and binders are typed uninterpreted declarations whose
complete vocabulary is independently hashed. In PAIR mode, declarations used
by the common representative must agree exactly across both bundles. Axioms
remain inside the externally pinned theory digest: an untrusted producer
cannot add a ground equality assumption under an unchanged pin.

Schema kinds are exactly `ONE`, `ONE_SLOT`, `ONE_TERM`, `SEQ`, `BAG`, `SET`,
`BIND`, and `BIND_BLOCK`. Binder generators must be total
descriptor-preserving permutations:
type, quantifier, disjointness class, and scope all have to agree.

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
CONTAINER_NORMALIZE          container-normalization[kind,source,target] {
                               occurrence[sourceIndex,premiseProof]*
                             }
STRUCTURAL_ALPHA             structural-alpha[leftTerm,rightTerm]
FULL_INTERFACE_SYMMETRY      full-interface-symmetry[permutation,leftTerm]
KERNEL_REPLAY                kernel-replay[
                               source,Gamma0,kernel,Delta,iota,sigma,omega
                             ] {
                               parent-paths
                               port-normalizations
                               structural-proof[proof]
                               effective-support[slot*]
                             }
FRESH_WITNESS                fresh-witness[witness,kernel,iota,replayProof]
CANONICAL_ORBIT              canonical-orbit[
                               source,targetContext,representative,orbitSize
                             ] {
                               free-renamings { embedding-ref[id]* }
                               leader-groups[snapshot,"complete"] {
                                 leader-group[path,witness] {
                                   generator[embedding,proof]*
                                 }*
                               }
                               orbit-members { term-ref[id]* }
                             }
COLLISION                    collision[
                               leftReplay,rightReplay,leftShapeKey,rightShapeKey
                             ]
REBUILD_CONGRUENCE           rebuild-congruence[firstPremiseProof]
```

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
  shapes { shape[shape,owner,term,replayProof]* }
  hash-cons { hash-owner[completeKey,eclass]* }
  parent-uses { parent-use[parent,shape]* }
  symmetries { symmetry[eclass,embedding,proof]* }
  dirty { dirty-shape[shape]* }
}

events { event* }
event[sequence, kind, beforeSnapshot, afterSnapshot] { payload }
```

Sequence numbers start at zero and are consecutive. Each pre-state must be
the previous post-state. Event kinds and payloads are:

```text
INSERT_FRESH       insert-fresh[eclass,shape,replay,orbit,freshWitness]
INSERT_COLLISION   insert-collision[eclass,shape,replay,collision,parentEdge]
UNION              union[parentEdge]
ADD_SYMMETRY       add-symmetry[eclass,embedding,fullInterfaceProof]
RESTRICT_INTERFACE restrict-interface[
                     eclass,oldContext,newContext,restrictionProof
                   ] { transported-evidence[changedRecordId*] }
REBUILD_RECORD      rebuild-record[shape,rebuildProof,collisionProofOrEmpty]
PATH_COMPRESS       path-compress[child,parentEdgeProof] {
                     original-edge[edge]*
                   }
REBUILD_COMPLETE    rebuild-complete[changed]
```

The checkpoint verifier recomputes complete state differences and rejects
all mutations not authorized by the named event. Only
`RESTRICT_INTERFACE` may change an existing class interface.

## Canonical Records

```text
canonical-records { canonical-record* }
canonical-record[id, orbitProof, representative] {
  source-replay-ref[kernelReplayProof]
}
```

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

## Current Producer Subset

The wire schema and binary envelope versions are `acgncert-schema-v2` and `1`.
`CertificateBundleWriter` currently identifies its bridge as
`phase-j-producer-export-v3` and emits rule-set version
`phase-j-proof-kernel-v3`.

That producer subset admits `ONE`, `ONE_SLOT`, and `ONE_TERM`; APP and INVOKE
terms; identity typed embeddings; AXIOM, SYM, PARENT_EDGE, CONGRUENCE, TRANS,
KERNEL_REPLAY, CANONICAL_ORBIT, and FRESH_WITNESS proofs; and either one fresh
event or the exact five-event parent-path history described in `README.md`.
All tables are content-interned, collision-checked, and emitted in canonical
ID order. Per-input axioms stay under the theory pin; typed symbol declarations
are carried by the separately hashed vocabulary. Recursive term keys include
kind, context, sort, symbol, ordered
attributes, and recursively keyed children.

This subsection limits only the current producer. It does not remove any
closed verifier record above, nor does it authorize a verifier to infer
missing evidence. The theory digest remains an untrusted bundle field until
the caller supplies the same digest out of band.
