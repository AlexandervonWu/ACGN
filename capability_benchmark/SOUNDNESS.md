# Capability Benchmark Bounded Soundness

- Cases per transformation subtype: 1
- Checked cases: 29
- Families: 11
- Family/subtype combinations: 29
- Solver-reported counterexamples at generated scope 4: 1
- Solver/translation errors: 0
- Inconclusive temporal checks: 6
- Conclusive non-temporal failures: 0

These checks execute the generated Alloy equivalence assertions with SAT4J. Unsatisfiability at scope 4 is a finite-scope sanity check, not a semantic proof; the benchmark ground truth remains the recorded sound transformation and side condition. Temporal results are retained but marked inconclusive because this installation lacks a temporal backend and Alloy warns that SAT4J uses a possibly-unsound static reduction.
