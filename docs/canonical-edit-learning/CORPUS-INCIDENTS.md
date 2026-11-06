# Corpus Pilot Development Record

The following were found and corrected before the full-sized training run.
They concern the new learning bridge, not changes to canonicalization laws.

1. The original hardware input scope admitted only 2/96 inspected corpus files.
   Common source-only operators and four-digit encoding of every small count
   consumed coverage. The separately versioned corpus codec adds five read-only
   operator IDs (102 assigned of 128), explicitly stores complex source domains,
   and uses a proved prefix-tagged compact integer encoding. No edit template or
   semantic rewrite was added. Subsequent exclusions remain in the ledger.
2. An action pointer at the beginning of its record could not see the replacement
   payload through causal attention. Pointers now target the record's final END
   token; a live-source test checks the replacement precedes that pointer.
3. The first padding implementation combined an explicit attention mask with
   `is_causal=True`, which the installed backend rejects on exercised paths.
   Packets now use right padding and gather their last non-PAD query state, so
   causal attention naturally excludes the padding suffix. Tests compare padded
   and unpadded predictions. All-pad packets and legal pointers beyond the query
   are rejected. No large dense mask or changed GPU attention backend is needed.
4. Candidate scores change if validation grows the counterexample bank.
   The exporter evaluates every candidate on the same snapshot first, then
   performs solver validation. This preserves comparability of score lookahead.
   Exhaustive score ranking is explicitly reported as a more expensive baseline,
   not disguised as equal-attempt-cost search. Uniform random is budget-matched.
5. Codec export is never allowed to omit signature facts silently. The current
   source adapter excludes signature-fact contexts instead of pretending the
   remaining context is complete. Module facts are exported and type checked.
6. The tiny end-to-end development probe inspected three examples from two test
   question groups. The final 508M evaluation excludes those entire groups:
   `classroom_fol:inv8` and `trash_fol:inv10`. They are not moved into training.
7. Labels are minimum residual canonical distances, not semantic verdicts.
   The loader rejects an initially faulty zero-distance pair or a candidate
   whose distance is zero while two-direction solver validation says unsolved.
   Only solver-checked results count as repair successes.
8. One of 4,096 source-metadata subprocesses returned undecodable JSON. The
   original stdout was not retained, so its precise transport cause is unknown;
   it must not be attributed to a semantic or solver failure. A fresh metadata
   probe succeeded. The single bounded retry then reached the normal
   `UNKNOWN_SYMBOL` scope exclusion. The initial failure ledger and retry receipt
   are retained. Future collection preserves source stdout/stderr, and the serial
   runner retries only FAILED rows once, never scope exclusions or inconvenient
   repair outcomes. The retry did not add or remove an accepted training example.

The frozen 4,096-file collection admitted 1,643 AST-distinct examples, with 2,453
explicit exclusions and no remaining runtime failures after that retry. The
final split is 1,192 train / 221 validation / 192 test, after removing 38
examples belonging to the two development-test question groups. Dataset hashes,
per-record solver results and actual training source hashes are retained in
the run, separately from the earlier collection-launch source snapshot.

The bounded theorem drafts initially needed an explicit `Nat.min_le_left` step;
the corrected standalone file compiles without sorry/axiom/unsafe. Lean proves
the stated abstract arithmetic/gating contracts, not the numerical backend or
an end-to-end source-to-proof refinement. Each retained run must be interpreted
under its recorded source hashes, including preflight failures.
