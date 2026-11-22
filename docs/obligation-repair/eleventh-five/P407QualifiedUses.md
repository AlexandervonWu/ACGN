# P4-07 owner-qualified hash ownership and reverse uses

P4-07 concerns the identity of a live stored record. A parent record is the pair of its e-class owner and canonical shape. Several incomparable leaders can own the same shape. Hash lookup returns a set of owners. A reverse use identifies the child and the complete parent record. Repeated invocation of a child within a single record contributes one use.

## Implementation and proof

`TypedSlottedPortEGraph.addHashOwner` and `removeHashOwner` change a single owner in its shape bucket. `indexRecord` and `unindexRecord` visit the invocation children and change the complete `ParentRecordKey` under each child. The traversal handles scalar slots and invocations, sequences, bags, sets, binders and binder blocks. `ParentRecordKey` includes both fields in equality, hashing and ordering. The public `hashOwner` and `hashConsSnapshot` compatibility methods select the least owner at quiescence. `hashBucketsSnapshot` returns them all. The complete census is also used by the collision and rebuild code.

`P407QualifiedUses.lean` proves exact membership after any finite sequence of owner-qualified insertions and removals, starting from an exact index. The initial empty index is exact. The proof covers arbitrary finite nested ports, duplicate invocations, repeated edits, sibling noninterference and removal of just one owner. The compiled hash and reverse operations commute. The wire theorem `replayed_wire_reverse_use_iff` applies to every record in an accepted finite registry and every child predicate on the underlying term. It uses the prior P4-11 result that an accepted registry resolves a queried digest to its exact owner and term. It permits an arbitrary digest function.

The source witness checks 54 attributed method bodies, their resolved calls, constructors and references, and 20 method invocations with an index field as their direct receiver. It extracts the four edit instructions from the Java syntax trees. The Lean executable applies those instructions to the differences between the independently observed live-record sets and compares both full index families at four graph states. The trust boundary includes the source extractor, the use of canonical shape identities and e-class IDs as equality tokens, JDK 17 attribution and execution, the admitted input equations, and Lean 4.35.0. This correspondence applies at completed edits. The tenth P4-08 proof separately covers restoration of all live-owner buckets at quiescence.

## Focused evidence

The public witness inserts two distinct nullary Boolean markers and two parent records using the same operator. Its interpretation maps both markers to true and makes the parent return its first marker while ignoring its other arguments. The certified interface restrictions retain an Int slot on one parent and a Bool slot on the other. Uniting the equivalent markers and rebuilding gives both parents the same canonical shape and two incomparable owners. Both reverse keys survive repeated invocation of the same child. A further certified restriction makes the owners comparable. Rebuild coalesces them, leaving one owner and one use.

Two fresh focused compiles on the tenth candidate passed all 15 governing declarations and the one replay declaration with the registered axiom audit. The witness checked 37 graph rows and rejected an omitted sibling observation. Both passes emitted byte-identical results and printed `P407QualifiedUsesTest passed: rows=13 snapshots=4`.

| Output | SHA-256 |
| --- | --- |
| `p407.tsv` | `fe1361694cb26b80e8147ac4bb6d037c4955fdd43d711998d8b493ca8cf93416` |
| `p407-program.txt` | `a122f68b312101a4a3bc447c7a3ed3538d011f7fb9d22b40da6d19c136b4f548` |
| `p407-observations.tsv` | `d0acd60efc2370f625e64f6aa91e28b748bade47d56eb9b06de37703e6d24b87` |

The independent standalone FULL checker accepted the existing ordinary writer fixture `parent-path-a.acgncert` under its externally established theory and empty CALL commitment. The wire witness walked six snapshots, checked the complete reverse-use relation in all six and matched the full hash-owner set in all five quiescent snapshots. Four distinct owner/term pairs included one term shared by different owners across history. There was one observed wire reverse use. The writer currently returns `UNCHECKABLE` for histories with nonempty rebuild records. The simultaneous two-owner history therefore supplies graph-level evidence. The FULL result pertains to the separate parent-path history. General positive export of nonempty rebuild records remains open.
