# Full-Corpus Experiment Preflight

Date: 2026-08-28

This inspection was performed before another 66,080-file experimental run.
It is a bounded source-to-runner preflight, not a claim that every possible
Alloy model is supported. Existing result directories were not modified.

## Trail Inspection

| ID | Reachable witness | Failure before repair | Repair and retained boundary |
| --- | --- | --- | --- |
| PF-F01 | `coursesNew/inv15`, including `h + prev[h] + next[h]` and `prev + iden + next` | Repair projection could request a typed `PLUS` occurrence introduced by normalization for which only the certification snapshot's occurrence had been registered. | Bind the immutable, already-authorized Alloy container law to exact repaired occurrences after certified-source-to-repair lineage transfer. This admits no new equality and does not orient a rewrite. |
| PF-F02 | `trainStationOld/inv14`, `let tr=t.pos | ... after ... tr ...` | Temporal skeleton extraction detached the `after`-phase use of `tr` before beta substitution; exact adaptation then encountered an arity-zero `LET`. | Beta-substitute local lets during the parser-owned skeleton traversal. The environment is an `IdentityHashMap` keyed by the exact `LetSymbol` occurrence, follows only recursive descendants and generated temporal children, and cannot capture another same-spelled binder. `NormalForm` retains its existing beta pass as a checked fallback. |
| PF-F03 | `trainStationOld/inv5`, `t.pos.next` after `open util/integer` | The full-corpus path rejected `util/integer/next` because it was absent from the independent imported-call ledger. | Pin exactly `util/integer/next` as an expression-valued imported declaration of arity zero. Its parser occurrence remains a CALL returning an `Int -> Int` relation; the surrounding dot is JOIN. Unknown imported members still fail closed. |
| PF-F04 | Unary `Int` expression joined with the `Int -> Int` result of `integer/next` | The dependent-chain constructor derived `Rel(Int)` while the parser stores the equivalent primitive unary carrier as `Int`; construction and repair replay rejected the representation mismatch. | Both boundaries now require the existing `PRIMITIVE_SET_SINGLETON` type proof. Exact relation results still require exact equality, unsupported primitive spellings still reject, and mismatched JOIN boundaries still reject. |
| PF-F05 | Ranking and ablation over tens of thousands of files | Ranking, reward, and ablation stages could enqueue the complete corpus as `FutureTask` objects, increasing retained heap before work completed. | Keep at most `4 * workers` tasks in flight and refill on completion. Result ordering remains source-index deterministic where required. |
| PF-F06 | OOM or another `VirtualMachineError` inside worker code | Several broad `catch (Throwable)` and `ExecutionException` paths could turn a fatal JVM failure into a file failure or retry it. | Propagate `VirtualMachineError` through parsing, deferred preparation, reward computation, ablation, and capability generation. Ordinary per-source failures remain reportable. |
| PF-F07 | A deferred oracle-only preparation or one incorrect-predicate preparation fails | `Alloy4FunAugmenter` could throw before writing any reports, losing completed work. | Record reference-pool and ranking preparation failures in `index.json` and `summary.md`. Equality-kernel contradictions and unexpected distance failures remain fatal and are not downgraded. |
| PF-F08 | `trash_rl/correct/b3LQRvSN97bZcbchu_inv1.als`: `(all f: File | f not in Trash) and no Trash` versus `no Trash` | R0 normalized the first conjunct to `no Trash`, and the certified flat `Set` construction merged both raw inputs into one output fiber before collapsing the AND to its singleton. The repair projection compared the two pre-quotient source trees and charged matrix distance 5. | Transfer the exact `ContainerApplicationTrace` fibers to the repaired occurrence by its already-checked source lineage. Each fiber retains all source representatives for pairwise minimum-cost comparison, and a certified singleton endpoint removes the variadic wrapper. This path is restricted to `SetPortSchema`; `Bag` and `Sequence` multiplicities are unchanged, no static or adaptive equality was added, and an occurrence/operator/arity mismatch rejects. |
| PF-F09 | `classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als` and the temporal/prenex witness `always all t: Trash | after t in Trash or t not in Trash` | The PF-F08 partition transfer retained trace indices. ACI normalization could reorder repaired children, so an exact fiber was attached to the wrong operands; a genuinely duplicate temporal Set operand also left an unreferenced repair phase. | Bind every trace input to the repaired input with its preserved positive source lineage before applying the certified fibers. Reject missing or unmatched lineage. Build the repair phase list from the selected certified alternatives, so a phase removed only by an exact Set/idempotence or certified alpha alternative is not charged as residual syntax. No new equality is admitted. |
| PF-F10 | Seven files failed their first parallel augmenter parse but passed the immediate retry | Replacing a successful retry erased the original failure path and message, leaving no durable way to reproduce transient parser/canonical-builder behavior. | Preserve the first error on the successful retry record and always emit `parse_retries.csv` with path, initial error, final status, and final error. Final corpus accounting continues to use the retry outcome. |
| PF-F11 | Six `trainStationOld/inv3` and `trash_ltl/inv12` files, minimized as `all f: File | once f in Trash implies always f in Trash`; the first full replay then exposed five IFF-expanded repeated-reference cases | The source binder remained local because unconditional global lifting was not sound, but temporal phase extraction detached its uses without importing the active lexical scope. Exact adaptation correctly rejected the resulting apparently free leaf. The first repair then rejected a second visit to the same child even when IFF normalization had repeated the exact `REF` under the same scope. | Snapshot every active local binder at each temporal reference and import it into the child by exact source-binder lineage, owner/target phase paths, binder context, local coordinate, slot, and graph type. The adapter resolves the child only while that owner frame is active. Repair projection records the distinct `LOCAL_INHERITED` role. An exact repeated snapshot is idempotent; any changed provenance field rejects as conflicting scope. Branches remain phase-distinct and same-spelled or unrelated binders reject. |
| PF-F12 | Rewarded full-corpus run at 62,144/66,080 with 32 workers, 4 GiB heap, and reward pool 100 | Eighteen concurrent Rewarder/SAT workers and thirteen certificate-preparation workers filled old generation. Over a 212-second diagnostic interval, full-GC time consumed 98.4% of wall time and only 17 files completed. | Share one heap-derived permit budget between exact preparation and Rewarder and place preparation in a helper scope that releases proof graphs before reward allocation. The 32-thread scheduler admits nine memory-intensive phases at 4 GiB; the augmenter's reward-only executor uses the same limit. This changes scheduling only; all semantic and metric operations remain unchanged. |
| PF-F13 | Capability witnesses `generated_cap002147.als` and `generated_cap002411.als`, each combining IFF expansion with a nested duplicate Boolean operand | The certification snapshot named the pre-saturation Set operand, but idempotence later adopted a semantically equal child representative and replaced the node's mutable source lineage. Exact Set-fiber replay then found the right repaired occurrence under the wrong lineage and rejected both pairs. | Retain a separate checkpoint occurrence lineage across clone and representative adoption. Set-partition transfer uses this immutable carrier while all semantic-origin lineage, operator, Set policy, arity, multiplicity, and unmatched-input checks remain fail closed. The exact two-file replay is 2/2 at certified distance zero. Capability reporting now throws unless the certificate-integrated arm closes every generated pair. No equality or rewrite rule was added. |

## Formal Obligations

`docs/section3-repair-audit/formal/FullCorpusPreflight.lean` is a standalone
Lean 4.33.0 model with no `sorry`, `axiom`, or `unsafe`. It proves the bounded
obligations used by these repairs:

- the pinned `integer/next` declaration is zero-arity and relation-valued;
- a unary `Int` relation joined with `Int -> Int` has unary `Int` result;
- stored primitive `Int` and that result share the admitted singleton relation
  view;
- a mismatched exact boundary rejects;
- beta substitution reaches every use under an `after` constructor before
  phase separation; and
- repaired container-law rebinding succeeds only for the same operator/carrier
  law key;
- certified e-class equality licenses duplicate removal only under an
  idempotent set operation; and
- ordered and multiplicity-preserving containers retain both occurrences; and
- repair distance takes the minimum across the exact representatives named by
  one certified quotient fiber;
- source-lineage remapping preserves every member of an exact quotient fiber;
- certification cloning and equivalent representative adoption preserve the
  checkpoint occurrence used by exact Set-fiber replay;
  and
- an exactly duplicated temporal operand has one occurrence under the certified
  idempotent Set quotient;
- every supported unary temporal constructor preserves its surrounding lexical
  depth;
- both child roles of every supported binary temporal constructor preserve the
  surrounding lexical depth;
- distinct temporal children may import the same exact owner coordinate while
  retaining distinct phase identities; and
- another source lineage or binder context cannot discharge a phase-local
  import.

The Lean model proves internal equations conditional on the imported-call pin.
The fact that the bundled Alloy library exports `util/integer/next` is source
provenance checked by the parser-backed Java regression, not a theorem derived
from spelling.

## Regression Gates

- `CallExtractionRegressionTest` includes the exact imported-call arity,
  authority, JOIN construction, and serialized identity checks.
- `CanonicalAlloyPipelineTest` compares a temporal-crossing `let` source with
  its beta-expanded source and requires certified equality and distance zero.
- `CanonicalAlloyPipelineTest` also reproduces PF-F08 and requires the
  certificate-integrated repair projection to preserve the quotient zero.
- `CanonicalAlloyPipelineTest` reproduces both PF-F09 cases: reordered prenex
  guards retain their correct temporal reference, and a duplicate temporal
  operand removes its redundant repair phase at zero distance.
- `CanonicalAlloyPipelineTest` reproduces PF-F13 with an IFF-expanded formula
  containing nested idempotent `AND` and `OR` operands and requires certified
  equality and repair distance zero against its explicit expansion.
- `CanonicalAlloyPipelineTest` reproduces PF-F11 with `ONCE` and `ALWAYS`
  sibling phases. Alpha renaming remains distance zero, while changing the
  imported temporal use remains nonzero. A separate IFF case repeats the same
  `ALWAYS`/`AFTER` references and requires exact-snapshot idempotence.
- `TemporalPhaseLocalBinding.lean` exhaustively covers `BEFORE`,
  `HISTORICALLY`, `ONCE`, `ALWAYS`, `EVENTUALLY`, `AFTER`, and both child roles
  of `UNTIL`, `RELEASES`, `SINCE`, and `TRIGGERED` for the scope/provenance
  obligation.
- `CanonicalBatchConcurrencyTest` pins the deterministic heap-derived worker
  bound, including the 4 GiB and 2 GiB configurations. It is an operational
  resource test; no semantic Lean claim is manufactured for scheduling.
- Corpus replays include every file in the five oracle-only groups, plus the
  previously failing complete `coursesNew/inv12` and `trash_rl/inv1` groups.
- The serial smoke uses temporary output roots. Publication and experimental
  result trees are protected from this preflight.

The final bounded replay evaluated all 587 files in the two historical groups:
383 distances succeeded, 204 AST-identical pairs were skipped, and 0 failed.
The complete 241-file historical failure replay then produced 241 successful
distances and 0 failures; the six PF-F11 witnesses also passed independently.
After correcting exact repeated-reference snapshots, the complete 66,080-file
corpus produced 61,598 successful distances, 4,482 AST-identical skips, and 0
failures. The report also recorded 0 incorrect zero-distance merges. Its
temporary output root is `/tmp/acgn-phase-local-full-v2.OCa5Ws`.
The 30-file serial smoke completed CanonicalBatchTest, Alloy4FunAugmenter, all
seven ablation arms, and the capability benchmark with zero preparation,
ranking, batch, or conclusive soundness failures.

The final clean publication replay used 16 workers, an 8 GiB heap, and reward
pool 100. Publication run `57f5a2d8-f501-494d-81d5-b3f1396dbe18` completed all
four stages from source `88363ea23728329948ccc9d5cdad690cc5787ca5`:
CanonicalBatchTest produced 61,598 successes, 4,482 AST skips, and 0 failures;
Alloy4FunAugmenter ranked and rewarded all 42,386 incorrect predicates with 0
failures and 0 certified incorrect-to-truth zeroes; all seven ablation arms
completed 61,598 pairs with 0 failures; and the capability benchmark generated
and evaluated 5,500 valid pairs. The slotted, Fast Rewrite IR, and
Certificate-Integrated IR arms each recovered 5,500/5,500. The bounded semantic
checker found no counterexample among 4,088 claimed-equivalent natural-corpus
pairs, and all four targeted negative controls remained unmerged. This replay
is the checked-in empirical snapshot.

## Intentional Stop Conditions

The following still terminate a run because continuing would make the result
semantically unreliable: any remaining certified-equality/repair-kernel contradiction,
cross-profile evidence, malformed certificate provenance, `VirtualMachineError`,
or an unexpected metric invariant failure. A source-specific unsupported
preparation is instead counted and named in the augmenter reports.
