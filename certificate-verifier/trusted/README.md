# Trusted Theory Pins

`theory-pins.tsv` is the static authority selected by the bounded certificate
harness. `THEORY_REVIEW.md` renders its complete admitted theory for author
review, including the origin and endpoints of the parent-path ground axiom.

All current entries are visibly test-only and pending review. The verifier does
not auto-trust this directory: the harness selects a named pin and passes its
digest explicitly with `--theory-digest`. `ManifestInspector` is used only to
confirm that a generated bundle matches that prior selection; its output is
never fed back as authority.
