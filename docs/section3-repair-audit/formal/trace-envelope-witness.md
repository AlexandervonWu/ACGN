# Trace-Envelope Inhabitation Witness

Status: **machine-checked witness present**.

`paper-claims/formal/TypedSlottedEGraphsPaper/TraceEnvelopeWitness.lean`
constructs one end-to-end inhabitant of the generic `StructuralTrace` /
`TraceInterpreter` interface.  The indexed trace contains, in this order:

1. AC reassociation;
2. a binder block with an explicit bijective `BinderMapping` (identity followed
   by the checked two-slot swap);
3. union insertion;
4. rebuild; and
5. forward congruence restoration after operand reordering.

The interpreter denotes nodes as finite-set membership predicates.  AC and
union use disjunction, the binder block transports its two bound slots through
the explicit mapping, and rebuild is semantically transparent.  The local
equations are proved directly, and `ProfileRules.replayTrace` discharges the
end-to-end D2 replay obligation.  The indexed `StructuralTrace` constructor
discharges D1 adjacency; `d1_trace_obligation` exposes its inhabitation as a
`Nonempty` proposition.

The focused command is:

```bash
cd paper-claims/formal
lake build TypedSlottedEGraphsPaper.TraceEnvelopeWitness
```

This witness establishes only that the specified envelope is inhabited by at
least one nontrivial execution.  It does not establish completeness, general
implementation faithfulness, or coverage of any other trace shape.  Future
changes that remove or weaken this witness reopen the acceptance block.

