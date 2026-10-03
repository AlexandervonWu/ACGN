# Graph Policy Experiments: Unsuccessful Research Direction So Far

The tested graph policies have not established stable improvement over uniform
random walks. This is a conclusion about the current data, observation/action
interface and learning procedures, not an impossibility claim about graph ML.

Earlier small-fixture runs produced occasional wins but not stable generalization.
The larger corpus study selected 104 genuine incorrect predicates across 36
question groups: 64 training, 16 validation, and 24 held-out evaluation tasks.
All runs used the same bounded scope-3 evaluation profile.

Completed larger-study validation results:

- GAT: 0/48 and 0/48; paired random: 2/48 and 1/48.
- GCN: 0/48 and 0/48; paired random: 2/48 and 1/48.
- Graph transformer: 9/48 and 0/48; paired random: 2/48 and 1/48.
- First fresh-seed transformer test: 0/72; paired random: 4/72.

The positive transformer validation result comprised three predicates, each
repeated three times; it was not nine independent successful tasks. The first
held-out seed already failed the predeclared criterion of beating random on
every one of five fresh seeds.

The user stopped this direction before the remaining tests completed. Seven
child runs completed; the next child was interrupted. Do not report an aggregate
five-seed result or a completed final GCN comparison. The retained run is
`/tmp/acgn-rl-corpus-tuning-01`; `runs.json`, `selection.json`, child manifests,
checkpoints and episode logs retain the completed evidence. No surviving
experiment or repair worker process was found after the interruption.

Interpretation: increasing width/depth or adding graph attention did not solve
the learning problem. Sparse successful trajectories, a restricted edit menu,
aggregate feedback rather than concrete counterexample features, and limited
training diversity are plausible limitations; this experiment does not isolate
their causal effects. More VRAM usage is not itself an improvement criterion.

Next direction: verifier-guided search to generate useful trajectories, and
pretrained language models trained with checked repairs and counterexamples.
See `repair-search/SPECIFICATION.md`. The prior 13-claim, two-clean-build gate
passed, but that gate concerns protocol invariants, not empirical model quality.
