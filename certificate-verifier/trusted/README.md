# Trusted Theory Pins

`theory-pins.tsv` is the static authority selected by the bounded certificate
harness. `THEORY_REVIEW.md` renders its complete admitted theory for author
review, including the origin and endpoints of the parent-path ground axiom.
The TSV's endpoint authority is Base64 of the exact `Codec.encodeNode` bytes;
the Markdown structure is a non-authoritative review aid.

All current entries are author-approved only for their declared test scopes.
The verifier does not auto-trust this directory: the harness selects a named
pin and passes its digest explicitly with `--theory-digest`. The parent pin
remains input-specific and cannot authorize arbitrary producer equations.
`ManifestInspector` is used only to confirm that a generated bundle matches
that prior selection; its output is never fed back as authority.
