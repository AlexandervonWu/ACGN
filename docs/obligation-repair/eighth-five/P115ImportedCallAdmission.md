# P1-15 imported-call admission

The original requirement says that an imported callable's arity is accepted only from a fixed library ledger. The production entry under review is the Alloy-to-MASG visitor. The installed Alloy 6.2.0 JAR supplies the reference declarations. Its SHA-256 is `8a8746b89d95f28762903c9acbd2bee8aca5014fe49a522b7184ba32ffcc5b58`.

| Production observation | Lean correspondence |
| --- | --- |
| `AlloyLibraryCallableLedger.key` admits a single member, then serializes the module, member, enum name and decimal arity. Module paths may contain slashes. | `last_field_decodes`, `field_injective` and `exact_tuple_key` recover the original components from equal serialized keys. The model assumes slash-free enum and decimal spellings. |
| `require` queries the immutable table constructed by `signatures`; its diagnostic branches cannot return a signature. The exhaustive probe also checks that this map has exactly the independently recognized 20 keys. | `lookup_exact` proves membership equivalence for any table of well-formed tuples and any requested tuple. `slash_member_never_admitted` covers resegmentation across the module/member boundary. |
| The ordinary parsed `ModelUnit` captures the Alloy parser adapter's `ExprCall` at wrapper construction. Its private identity map seals before traversal. The visitor compares the original resolved name, predicate/function mode and declared and actual argument counts against the selected ledger signature. It checks the original `Func` in a resolved open module with matching filename and actual module arguments. | `imported_admission_exact`, `other_pinned_overload_rejected` and `foreign_open_rejected` state the independent lookup, overload and ownership conditions. Natural-number tokens model compiler object identity. |
| Both `util/integer/max` and `min` have arities zero and one. Editing a wrapper and its public adapter map to select the other genuine overload rejects in both directions. | `same_request_preserves_original_arity_kind` preserves the two resolved fields even for repeated spelling. |

## Concrete dependency and execution scope

The regression checks the loaded distribution digest and both embedded resource digests. For the exhaustive fixture it also checks the source filename of every compiler-resolved declaration. `util/ordering` contributes ten functions and four predicates, all admitted. `util/integer` contributes 21 functions and ten predicates, of which six expression signatures are admitted. Every admitted tuple traverses the normal producer. The full set of keys in the actual Java map also excludes every other module or declaration.

The remaining executable controls cover malformed tuple boundaries, wrong kind, wrong arity, four swaps between genuine overloads, same-type callee renaming, import-to-local renaming, changed module parameters and a foreign parser instance. The existing `CallExtractionRegressionTest` exercises distinct aliases for two ordering instances.

Alloy also permits callers to supply module text. The focused source-map fixture replaces the body of `util/ordering/first` while retaining its zero-argument expression signature. The producer admits that exact fixed tuple and binds it to the actual declaration selected by that parser instance. Authenticating the bytes or semantics of arbitrary imports would require separately recording and checking what the loader consumed. Java-to-Lean correspondence, parser object issuance, archive loading, JDK execution and SHA-256 are explicit trust boundaries.
