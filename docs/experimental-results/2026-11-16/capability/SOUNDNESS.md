# Capability Benchmark Bounded Soundness

- Cases per transformation subtype: 1
- Checked cases: 29
- Families: 11
- Family/subtype combinations: 29
- Solver-reported counterexamples: 0
- Solver/translation errors: 0
- Completed bounded temporal checks: 8
- Inconclusive checks: 0
- Failed checks (including inconclusive): 0

These checks execute the generated Alloy equivalence assertions with SAT4J. Temporal commands use Pardinus bounded temporal solving; exact scope and trace bounds are recorded per check. Unsatisfiability within those bounds is a finite-scope sanity check, not a semantic proof; the benchmark ground truth remains the recorded sound transformation and side condition. An inconclusive result or solver error fails the check, including temporal cases.
