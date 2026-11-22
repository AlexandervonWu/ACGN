# Final Synthetic Typed/Untyped Grid

Run: `e3d9bc4e-a514-471b-9e01-162562663f2e`. Complete matched cells: 44/54.

The primary z-axis is mean log10(untyped/typed engine elapsed time) for the same predicate. Positive means typed faster; z=1 means 10x. Engine timing includes adaptation and representation, not startup/parsing. The secondary figure includes startup/parsing/output. These are concurrent elapsed times, not worker CPU times.

Five generated paired shapes per cell are input replicates, not five independent reruns. All ten predicate measurements must succeed in both arms for a cell to enter the surface. Only adjacent measured cells are joined; no fabricated curves cross missing cells. Success-only median/P95, success rates, and censored statuses remain in cells.csv.

![Engine speedup surface](engine-speedup-surface.png)

![Completion grid](completion-grid.png)

Raw evidence: `/media/augustus/8618-0ED0/ACGN/intermediate/publication-studies-20261115-v3/synthetic-run`. Source hashes are in surface-data.json.
