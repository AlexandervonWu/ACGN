# Numeric Runtime Interface

Current executor version: `feedback-executor-canonical-v4`. This interface is a
migration surface, not yet the complete `feedback-intent-path-v1` representation.
Every row contains signed 32-bit integers, with at most sixteen columns. `-1`
means an absent optional address. Rows are addresses, not learned name identities.

## Predicate Tables

Both `initial` and `current` use the same tables. The initial packet is immutable.

- `nodes`: operator, exact type, payload, phase, enclosing binder context.
- `ports`: parent node, child node, ordered position, role (ordinary/domain/body).
- `types`: Boolean flag, integer flag, small-integer flag, relational arity.
- `typePorts`: type, product, ordered column, primitive signature pointer.
- `symbols`: kind (primitive/subset/field), type, owner, built-in identity,
  abstract flag, multiplicity, mutable flag.
- `symbolParents`: child signature, parent signature.
- `bindings`: declaring node, type, quantifier/LET operator, domain node,
  disjointness class, column-disjointness class, phase, imported-from binding.
- `scopes`: node, available binding.
- `occurrences`: node, editable flag. Text spans remain controller-private.
- `phases`: parent phase, introducing node, child position.

Node payloads are symbol addresses for SIG/FIELD, binding addresses for VAR and
literal values for constants. The static catalog defines operator categories.
Types retain all products/columns rather than replacing disjoint products with
`univ`. Transparent parser NOOP wrappers are not source operations.

## Canonical Tables

The same `initial`/`current` packets now also contain:

- `canonicalNodes`: canonical opcode, exact structured type, container kind
  (ONE/SEQ/BAG/SET), payload kind, payload, phase.
- `canonicalPorts`: parent, child, position (`-1` for unordered), role
  (operand=0, certified alternative=1). BAG occurrences are not deduplicated.
- `canonicalTypes`: kind, payload. Kinds are BOOL=0, INT=1, product=2,
  union=3, empty relation=4, primitive column=5, certified unary carrier=6.
  Payloads are source signature pointers for 5/6 and exact arity for 4.
- `canonicalTypePorts`: type, child type, ordered column/alternative position.
- `canonicalBindings`: phase, role, ordinal, owner phase, owner coordinate,
  type, quantifier, cardinality, disjointness class, exchange class, domain symbol.
- `canonicalDependencies`, `canonicalOrbits`: binding and owner binding.
- `canonicalPhases`: root matrix node for each phase.
- `canonicalPhasePorts`: temporal node, phase, branch position.

Node payload kinds: absent=0, source symbol=1, canonical binding=2, built-in
constant=3, exact integer=4. No printable semantic keys are parsed into features.
The projection retains structured type/domain/phase metadata alongside unchanged
metric fields. Names resolve only against the allowed source namespace.
Local canonical binders, non-primitive domain keys, and unsupported node payloads
explicitly reject observation export. Their coverage is reported, not hidden.

`tables.py` turns row references into typed incidence edges. Integers retain all
32 bits before learned maps. Synthetic group nodes retain product, tuple and
disjointness identity without learned IDs. The small policy supports histories
whose referenced revisions are initial/current; missing older source snapshots
fail explicitly. Graph address transport is tested independently of storage order.

## Feedback Tables

- `symbols`: signature/field kind, current-source symbol address when present,
  first selected returned-world origin, built-in identity.
- `typePorts`: feedback symbol, product, ordered column, feedback type symbol.
- `worlds`: query ordinal, queried revision, expected Boolean, candidate Boolean,
  finite trace length, loop index.
- `atoms`: world, world-local address, integer flag, exact integer value.
- `tuples`: world, time, relation symbol, tuple, ordered column, atom address.
- `omittedWorlds`: exact count omitted by the public last-eight-world policy.

Feedback contains only completed explicit query responses. Solver-side display
names resolve private addresses; names and oracle source are not neural tokens.

## Draft And Action Heads

`draft` rows contain operator/leaf kind, payload, parent, position, arity, filled
ports, introduced-binder count, disjointness flag and first introduced binder ID.
Negative leaf categories are COPY=-1, SYMBOL=-2, VARIABLE=-3, DRAFT_VARIABLE=-4;
constant kinds none/univ/iden/true/false/integer use -5 through -10.
FEEDBACK_SYMBOL=-11 points into the actually returned symbol namespace.
`draftDeclarations` records quantifier node, group position, slot, cardinality
and disjointness for every introduced slot. DECLARATION appends a group at the
unfilled body hole without changing the quantifier into a nested quantifier.

`actions` contains factorized numeric choice tables:

- `controls`: available control IDs, from the static catalog.
- `sites`: allowed family/site pairs for BEGIN.
- `deletions`: allowed family/site/child triples, preserving joint choices.
- `holes`: parent draft node, port, coarse sort, original-site type hint,
  destination phase/context, family, site. The type hint is not an obligation to
  retain the old exact type; the full new expression is rechecked at commit.
- `copies`, `symbols`, `variables`, `draftVariables`, `feedbackSymbols`: scoped
  operand addresses in their respective namespaces.
- `operators`, `quantifiers`: supported constructor categories at this hole.
- `constants`: kind and inclusive value bounds.
- `counts`, `disjointness`, `cardinalities`: inclusive bounded argument ranges.

Coarse sorts are ANY=0, BOOL=1, REL=2, INT=3. Relational integer overlap and exact
dependent column constraints require final Alloy checking; masks are not proofs
of validity of every combination. Only one unresolved prefix hole is active.
No mask queries a target or ranks actions by target distance.

Each decision supplies exact `revision` and `turn`, plus its control and semantic
arguments. History records every attempt, including rejected attempts. Draft
completion does not query the target; only VALIDATE or STOP does. STOP is not a
success label. Exhausted and closed sessions expose no available controls.

## Offline Labels

`FeedbackTeacherMain` is a separate offline program, not an operation supported
by `FeedbackRepairWorker`. It can inspect the private target while compiling
labels, but may refer only to symbols already in the source or actually returned
feedback namespace.
Missing symbols and constructors are explicit coverage outcomes. Whole-root
construction costs one choice per operator/operand; paths are not claimed optimal.

`replay.py` captures the public observation before each label, refreshes its
revision/turn, checks public masks and calls the same source executor. It rejects
extra fields, malformed numeric values, missing final validation and unsuccessful
repairs. It never uses future teacher responses as an earlier observation.
