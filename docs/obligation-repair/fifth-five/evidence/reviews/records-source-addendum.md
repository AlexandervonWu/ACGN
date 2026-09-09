# v2.17 Records/Source Review Addendum

Verdict: **PASS for the bounded negative-emitter and strict-classifier delta.**
The combined frozen closure must still run against its new input root.

## Correction to the Earlier Review

My earlier driver checked negative Lean output for the substring
``Tactic `decide` proved that the proposition`` after requiring exit 1. That
was weaker than `run_fifth_obligation_repairs.check_rejection`. It did not
establish that the complete diagnostic satisfied the registered grammar.
Likewise, the earlier source-control driver checked markers rather than
calling the full registered classifier. The original report's negative-control
PASS statements must not be interpreted as full strict-classifier validation.
This addendum supplies that missing check; it does not retroactively validate
the original blocked integration run.

I reproduced the rejection of the actual failing integration log. Its genuine
false-proposition diagnostic is followed by a failed theorem's multiline
`#print axioms` output containing `sorryAx`. The unchanged strict classifier
rejects that extra output. The `sorryAx` here is Lean's recovery placeholder
after an intentionally failed theorem, not evidence of an accepted positive
proof or a production semantic change. Emitting an anonymous failing `example`
without a post-failure audit avoids exporting that recovery declaration.

The original report remains byte-for-byte unchanged:
`/tmp/acgn-v217-records-source-review.md`, SHA-256
`74436fe6b165cd6088b53d7f72d28809f14fa05adc4d779d509113ff40550349`.
The failed aggregate run and original review evidence are preserved.

## Independent Delta Checks

Evidence root: `/tmp/acgn-v217-records-source-delta-checks`.
Driver: `/tmp/acgn-v217-records-source-delta-review.py`.
The driver completed with exit 0. Every new negative invocation requires exit
1 and directly calls the unchanged `check_rejection` on the entire raw output.

| Check | Result |
| --- | --- |
| Records Lean negatives, freshly emitted and executed | 7/7 strict PASS |
| Source-area Lean negatives, freshly emitted and executed | 16/16 strict PASS |
| Retained records source-control logs, full strict reclassification | 8/8 PASS |
| Retained source-area source-control logs, full strict reclassification | 16/16 PASS |
| Records/source Python unit suites | 9/9 and 17/17 PASS |
| General Lean models, freshly compiled with registered audit | 20 and 21 named theorems PASS |
| Regenerated positive replay text | Both byte-identical to the earlier checked replays |
| Old failing aggregate diagnostic | Correctly BLOCKED by the unchanged strict classifier |

The 24 Java source mutants were not reexecuted in this delta. Their actual
previous logs were copied, hashed and reclassified after checking that all
production Java and extractor sources were byte-identical. This is explicitly
log reclassification, not a new Java execution claim. All 23 Lean negatives
were executed afresh with Lean 4.33.0. No substring-only test determines PASS.

AST comparison of the records plugin found exactly one changed declaration:
`negatives`. Its positive reconstruction/generation functions and both general
Lean proof files are unchanged. The records controls now contain an anonymous
`example` and no `#print axioms`; the source-area emitter remains unchanged.

I also inspected the standalone runner delta: it calls `check_rejection` for
both Lean and Java source controls, adds the classifier regression, and includes
`run_fifth_obligation_repairs.py` and `fifth_obligation_replays.py` in its explicit
snapshot dependencies. This delta review did not rerun its full two-build
`--live-root` command. The main aggregate closure remains the release gate.

## Hashes and Scope

| Input or Evidence | SHA-256 |
| --- | --- |
| Unchanged `scripts/run_fifth_obligation_repairs.py` classifier | `bdad6f07f56699ba2e9e929b8e7ac2228bb50f82d209d12590809f0595b1d4c2` |
| Updated `scripts/fifth_flat_container_replays.py` | `64e0f1898269e88f7960927dbe311a192a41daf43bade161dff8e25e1b2e930a` |
| Updated `scripts/test_fifth_flat_container_replays.py` | `798059606d422d3d2b6ff01c22c55caff6ca8f33b546471c89e91b9e9c05f5da` |
| Copied failing integration log | `a31400de35ce77d3bdd86a3ab07e307b91f2a25a18bde8601df302b0bcc3484b` |
| Delta `inputs.json` | `de35f4f70db3a1510e7cd270e9562c6dd174cd4161852534c92f05548e0f201a` |
| Delta `commands.json` | `36ef86041ecbec027b1b363be7178e27aadbbb6f9b9eb8b71c995c934bacd104` |
| Delta `result.json` | `01d46625a7d05b41a2eba0a4ea572b3c3e98df6d3a1c4aa62e2bf8faf794ee98` |

The input manifest binds the copied proof and script dependencies and all four
reused TSVs. `commands.json` records fresh exit codes, strict classifications
and log hashes; `result.json` records each retained source-log hash. The final
check confirmed the relevant live files still match the reviewed snapshot.

No repository file was edited by this reviewer, no experiments were run, and
no production behavior or accepted positive proof was changed. This is a finite
integration delta under the original trust/exclusion boundary, not universal
semantic correctness or an aggregate closure verdict.
