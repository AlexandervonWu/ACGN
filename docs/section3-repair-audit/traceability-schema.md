# Section 3 Assurance Traceability Schema

`assurance-scope.tsv` is the closed scope manifest. It fixes the ordered set of
requirement IDs and binds each ID to its claim class and exact claim-text hash.
The checker rejects any ledger or matrix set/order/class/hash that differs from
that manifest. Changing the scope is therefore an explicit review-invalidating
artifact change, not an incidental consequence of Markdown discovery.

`requirements-traceability.tsv` is the machine-checked bridge from that scoped
set and `claim-ledger.md` to Lean, implementation, and bounded test evidence.
It is generated initially by `Section3AssuranceTraceability --init` and then
reviewed and completed manually.

The final `State` cell of every requirement row in `claim-ledger.md` is a
readable mirror of `formal_status/conformance_status`. The checker rejects a
missing, duplicated, stale, or otherwise different ledger state; the matrix
remains the source of the two component values.

`Section3AssuranceTraceability --write-markdown` regenerates
`docs/section3-assurance-claims.md`, which documents every claim and its proof
process from these same bytes. The generated Markdown is never an independent
source of authority.

The columns are:

| Column | Meaning |
| --- | --- |
| `requirement_id` | Exact requirement ID from the ledger. |
| `claim_sha256` | SHA-256 of the exact trimmed Markdown claim cell. A wording change invalidates the row. |
| `formal_file` | Repository-relative Lean source path. |
| `formal_declarations` | Semicolon-separated Lean declarations jointly proving the exact claim. |
| `implementation_refs` | Semicolon-separated `path#symbol` references to the implementing boundary. |
| `test_refs` | Semicolon-separated `path#symbol` references to bounded executable evidence. |
| `test_classes` | `+`-separated test classes; every row requires `NOMINAL+BOUNDARY+ROBUSTNESS`. |
| `formal_status` | `PROVED` only after the mapped Lean file compiles under the pinned toolchain and the statement matches the claim. |
| `conformance_status` | `DIRECT` only when bounded tests reach the actual implementation boundary; an abstract model alone is not direct. `DIRECT` is inherently bounded and there is no separate `DIRECT-BOUNDED` state. |
| `notes` | Assumptions, limits, counterexamples, and evidence identifiers. |

Report mode lists all gaps and exits zero so an incomplete matrix can be
developed incrementally. `--gate` exits nonzero unless every scoped row is
complete. Neither mode invokes Lean; the assurance runner must compile every
distinct mapped Lean file and bind its output hash separately.

`--only=<requirement-id>` limits printed diagnostics without changing the
global counts or gate result.

The checker deliberately rejects paths (including resolved symlinks) outside
the repository, absent or malformed scope manifests, malformed requirement-like
ledger rows, scope/ledger/matrix set or order differences, stale claim hashes,
mappings to definitions instead of named
`theorem`/`lemma` proofs, absent declarations, missing symbols, banned Lean
admissions, missing test classes, duplicate rows, and extra or missing
requirement IDs. Symbol presence validates mapping integrity only; the
independent review and bounded test execution establish whether that symbol
actually reaches the claimed semantic boundary. The execution-coverage gate
also requires every `DIRECT` Java test owner to run from a governed entry point
and every named non-`main` test method to be called by that owner's `main`.
