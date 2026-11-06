# Small-Model Relational Pilot

Version: `relational-pilot-v2`. This supersedes the v1 numeric-reference-only
vocabulary; existing assigned token IDs are unchanged.
Begin with 508,313,088, 709,664,256 and 910,534,656 parameters, all randomly
initialized and fully trainable. BF16 is the initial baseline; W8A16 and W4A16
are matched-size QAT ablations, not assumed memory savings. The 1.6-4.9B grid
remains an explicit later `scale` study. Do not scale before a useful effect
appears on the scoped, held-out repair tasks.

## Scope Before Size

The initial candidate language is a **static Boolean relational predicate**:

- One temporal phase; no temporal operators or inherited phase imports.
- Unary/binary relations and primitive, atom-valued ALL/SOME binders. Preserve
  exact type identities, binding order/ownership and disjointness partitions.
- Matrix operators: AND, OR, NOT, TRUE, FALSE, IN, EQ, SOME, NO, ONE, LONE,
  UNION, INTERSECT, DIFFERENCE, JOIN, ARROW, VAR, SIG, FIELD, NONE, UNIV, IDEN
  and the read-only integer literals 0 through 4.
- Existing certified normalization/type rules still govern these operators.
  JOIN/ARROW are read-only ordered operations with their existing dependent
  typing, not newly assumed associative operators. SOME/ONE/LONE/NO here include
  relational tests; only ALL/SOME are admitted as prefix quantifiers.
- Exclude CALL, LET, ITE, implication/IFF in the source slice, arithmetic,
  integer-valued cardinality, closures, comprehensions, higher-arity relations,
  functions, genuinely free variables, set-valued or complex-domain binders,
  and any unsupported feature. Inspect the whole source and all exported
  e-classes/members, not just one selected representative.

The source feature inventory is closed: BOOLEAN, RELATIONAL, ATOM_BINDER, DISJ
and INT_LITERAL. Literal values and the actual profile's signed integer bitwidth
must be supplied; e.g. 4 is excluded at bitwidth 3 rather than wrapped to -4.
Arithmetic, integer-valued cardinality and integer-repair templates remain
outside this slice. An unknown feature or operator excludes the input with a reason. Removing
unsupported constructs from the input to make it pass is prohibited.

The first four action templates are replacement-only:

1. Boolean: AND <-> OR.
2. Relational cardinality test: SOME / NO / ONE / LONE.
3. Same-exact-type set operator: UNION / INTERSECT / DIFFERENCE.
4. Atom quantifier: ALL <-> SOME.

Templates 1-3 map to MATRIX_UPDATE; template 4 maps to BINDING_UPDATE. This is
a subset of the existing nine metric families, not a redefinition of distance.
No arbitrary Alloy text generation, new symbol synthesis, operand replacement,
NOT insertion/removal, binder insertion/deletion, type/disjointness edits or
temporal repairs in v2. Each proposal still needs source replay, reparsing,
current type/profile checks and re-preparation. Intermediate steps may change
semantics; only final solver validation establishes a successful repair.

Actions outside this profile are counted as excluded. If the *scoped* complete
menu exceeds the limit, exclude the task; never take its first N actions. Also
reject already-truncated upstream menus, even if the retained scoped subset is
small. Identical before/after actions are excluded. No legal action means
NO_SCOPED_ACTION, not success.

## Closed Vocabulary

Exactly **128 embedding IDs**, of which **97 are assigned**, leaving 31 reserved:

The [historical census](VOCABULARY-CENSUS.md) independently confirms 67 prior
collapsed symbols, with four missing constants from the requested extension.

- 0-23: fixed structural record/container tags.
- 24-44: the 21 matrix operators listed above, in that order.
- 45-46: ALL/SOME binder tags, distinct from relational SOME.
- 47-50: the four edit-template tags.
- 51: `iden` (binary identity relation).
- 52-56: integer literals `0`, `1`, `2`, `3`, `4`.
- 64-79: hexadecimal digits for numeric payloads.
- 80-87: `$sig0` through `$sig7`.
- 88-95: alpha slots `$0` through `$7`.
- 96-103: `$rel0` through `$rel7`, shared by fields and other named relations.
- 57-63 and 104-127: reserved, rejected by the v2 packet validator.

Reuse existing TRUE/FALSE/NONE/UNIV tokens (27/28/43/44); do not allocate
duplicates. Each compact reference or literal occupies one token instead of
four numeric digits. Literal `0`, alpha slot `$0`, signature `$sig0`, relation
`$rel0`, and a hexadecimal digit zero all have distinct IDs and roles.

Signatures and fields/relations have independent, injective local numbering;
two fields are never merged because they share a type or source spelling.
Retain each field's declaring signature, exact type and ordered columns in its
record/sidecar. Bindings use already certified owner-context coordinates, not
first-use order or alphabetical names. Use the same maps across graph, actions,
types and worlds. Eight slots suffice for the existing single-phase/eight-binder
bound; this does not authorize merging slots across distinct binder contexts.
Unresolved admissible renamings remain an exporter exclusion, not an arbitrary
sort. Compact token injectivity is not a proof of the upstream alpha mapping.

Each unsigned scalar/reference is four little-endian hexadecimal digit tokens,
representing 0 through 65,535. Out-of-range values fail instead of wrapping.
Types, nodes, classes and atoms retain **local numeric references**; signatures,
bound slots and named relations use the compact banks above. Exhausting one of
those banks excludes the input rather than aliasing, wrapping, or falling back
to an unbounded family. There is no per-source-spelling token, UNK fallback,
BPE tokenizer or hash bucketing.
Bounded lengths and record tags disambiguate IDs and tuple structure.

Keep exact source spelling, full type/provenance descriptions, profile hashes
and inverse maps in a source-bound sidecar. This is a structured observation,
not a lossless spelling-level source encoding. References must preserve their
relationships, exact type distinctions and binding ownership. Administrative
renaming/canonical labeling remains subject to the existing certified transport
requirements; merely assigning integers is not alpha canonicalization.

The concrete scope/token gates operate on adapter-supplied inventories and
packets. The full Java source-to-inventory exporter is still open. Passing these
gates alone is not a certificate or proof that a source has the stated features.

## Bounded Admission

Cap each task at 64 e-classes, 128 e-nodes, 256 source nodes, 8 atom bindings,
8 signatures, 8 named relations (16 globals total) and 16 exact type records.
Global count must equal signature count plus relation count. Built-in constants
are not user globals. Observe at most 4 worlds, each
with at most 8 atoms and 128 tuples. Cap the complete scoped menu at 64 actions
and the encoded packet at 2,048 tokens. Bounds are admission tests, not clipping.
Changing a bound requires a recorded profile revision; it must not silently
change the solver's Alloy scope or the original semantic validation profile.

Select a bounded training witness bank using the existing declared procedure;
never omit tuples or atoms from a selected world. Report exclusions separately
by source feature, graph size, witness size, menu size and token budget. Corpus
coverage is not claimed before the exporter census is run.

## First Comparison

Use a group-disjoint scoped split and identical action menus. Compare random
selection, a small ranker, then the 508M model with graph-only, witness-only and
joint inputs. Freeze the split and budgets before collecting teacher labels.
Only promote the 710M/911M models after the source-backed pipeline works; retain
failed and excluded cases. Report solver-validated repairs, coverage and budget,
not just cross-entropy. Repair success wins; smaller parameter count breaks ties.

Short synthetic SGD probes test numerical functionality/memory only. They are
not a substitute for this comparison, and do not establish Adam/long-context fit.

## Formal Contracts

`HybridRepair.lean` proves that the template mapping uses only update families,
the abstract scope admission requires all three gates, the numeric token band
fits 128 IDs, numeric decoding round-trips, the compact banks are bounded,
injective and disjoint with exact decoders, and the three exact model counts.
Python tests check the bounded codecs and gates. Neither constitutes complete
source-exporter refinement, semantic soundness of edits, or learned efficacy.
