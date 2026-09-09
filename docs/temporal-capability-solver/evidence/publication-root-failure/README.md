# Retained Setup Failure

The first validation-only publication attempt at source `2bddaa64` stopped
with exit 1 before any solver check. Lean correctly required the copied
proof file to be under its configured package root; the runner had retained
the repository working directory as that root.

The retained manifest remains incomplete (`running`, no stage records), not
a successful publication. The replacement runner specifies
`--root="$OUTPUT/inputs"` for both proof compilations. An isolated invocation
with that root compiled the unchanged guard successfully. A fresh clean-source
run, with a different run ID, is required; this attempt is not resumed or
promoted to a pass.

An overlapping local fourth-obligation closure was intentionally terminated
before changing its hashed runner input (exit 143). Its partial output remains
under `/tmp/acgn-v216-fourth-closure`; it is not claimed VERIFIED or reused.
