#!/usr/bin/env python3
"""Matched log-speedup surfaces; never substitute deadlines for missing runtimes."""
import argparse
from collections import Counter, defaultdict
import csv
import hashlib
import json
import math
from pathlib import Path
import statistics


def cells_from_rows(rows):
    grouped = defaultdict(lambda: defaultdict(dict))
    for row in rows:
        key = (row["bindings"], row["types"])
        if row["arm"] in grouped[key][row["predicateKey"]]:
            raise ValueError("Duplicate predicate/arm")
        grouped[key][row["predicateKey"]][row["arm"]] = row
    cells = []
    for (n, m), predicates in sorted(grouped.items()):
        if not 2 <= n <= 10 or not 1 <= m <= n:
            raise ValueError("Out-of-grid observation")
        logs = {"engineNanos": [], "runtimeSeconds": []}
        if any(set(p) != {"typed", "untyped"} for p in predicates.values()):
            raise ValueError("Missing arm")
        cell = dict(variables=n, types=m, predicates=len(predicates), matched=0)
        for arm in ("typed", "untyped"):
            selected = [p[arm] for p in predicates.values()]
            counts = Counter(r["status"] for r in selected)
            cell[arm + "Statuses"] = dict(sorted(counts.items()))
            cell[arm + "SuccessRate"] = counts["SUCCESS"] / len(selected)
            for field, name, scale in (("engineNanos", "EngineSeconds", 1e9),
                                        ("runtimeSeconds", "WallSeconds", 1)):
                values = sorted(r[field]/scale for r in selected if r["status"] == "SUCCESS")
                cell[arm+name+"Median"] = statistics.median(values) if values else None
                cell[arm+name+"P95"] = values[math.ceil(.95*len(values))-1] if values else None
        for arms in predicates.values():
            if all(r["status"] == "SUCCESS" for r in arms.values()):
                for field in logs:
                    t, u = arms["typed"][field], arms["untyped"][field]
                    if not (math.isfinite(t) and math.isfinite(u) and t > 0 and u > 0):
                        raise ValueError("Nonpositive/nonfinite successful timing")
                    logs[field].append(math.log10(u/t))
                cell["matched"] += 1
        cell["completeMatchedCell"] = cell["matched"] == cell["predicates"]
        for field, name in (("engineNanos", "Engine"), ("runtimeSeconds", "Wall")):
            cell["matchedLog10"+name+"Speedup"] = statistics.mean(logs[field]) if logs[field] else None
        cells.append(cell)
    return cells


def surface(cells, field, title, destination, manifest):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import matplotlib.tri as mtri
    from matplotlib.colors import TwoSlopeNorm
    valid = [c for c in cells if c["completeMatchedCell"]]
    index = {(c["variables"], c["types"]): i for i, c in enumerate(valid)}
    triangles = []
    for n in range(2, 10):
        for m in range(1, n+1):
            for triangle in (((n,m), (n+1,m), (n+1,m+1)),
                             ((n,m), (n,m+1), (n+1,m+1))):
                if all(k in index for k in triangle):
                    triangles.append([index[k] for k in triangle])
    fig = plt.figure(figsize=(11, 8), layout="constrained")
    ax = fig.add_subplot(111, projection="3d")
    x, y, z = ([c[k] for c in valid] for k in ("variables", "types", field))
    limit = max([abs(v) for v in z] + [.01])
    norm = TwoSlopeNorm(vmin=-limit, vcenter=0, vmax=limit)
    if triangles:
        tri = mtri.Triangulation(x, y, triangles)
        artist = ax.plot_trisurf(tri, z, cmap="coolwarm", norm=norm,
                                 linewidth=.35, edgecolor="#555555", alpha=.9)
    elif valid:
        artist = ax.scatter(x, y, z, c=z, cmap="coolwarm", norm=norm)
    else:
        plt.close(fig)
        raise ValueError("No complete matched cells: no speedup surface can be drawn")
    ax.scatter(x, y, z, color="black", s=12, label="Measured complete cells")
    ax.set(xlabel="#Variables (N)", ylabel="#Types (M)",
           zlabel="log10(untyped / typed time)", title=title,
           xlim=(2,10), ylim=(1,10))
    ax.set_xticks(range(2,11,2))
    ax.set_yticks(range(1,11,2))
    ax.view_init(elev=28, azim=-130)
    ax.legend(loc="upper left")
    fig.colorbar(artist, ax=ax, shrink=.55, pad=.12, label="Positive = typed faster")
    fig.text(.02, .015, f"Seed {manifest['seed']}; 5 paired shapes/cell; {manifest['workers']} workers; {manifest['timeoutSeconds']:g} s deadline.\n"
             "z = mean paired log10 ratio; linear interpolation between measured cells only.\n"
             "Incomplete cells omitted; see cells.csv for timeouts and successful median/P95.", fontsize=8)
    fig.savefig(destination.with_suffix(".png"), dpi=180)
    fig.savefig(destination.with_suffix(".pdf"))
    plt.close(fig)


def outcome_grid(cells, destination):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import numpy as np
    fig, axes = plt.subplots(1, 2, figsize=(12, 6), layout="constrained")
    for ax, arm in zip(axes, ("untyped", "typed")):
        values = np.full((10, 9), np.nan)
        for c in cells:
            values[c['types']-1,c['variables']-2] = c[arm+'SuccessRate']
        artist = ax.imshow(values, origin='lower', extent=(1.5,10.5,.5,10.5),
                           vmin=0,vmax=1,cmap='viridis',aspect='equal')
        for c in cells:
            ax.text(c['variables'], c['types'], f"{c[arm+'Statuses'].get('SUCCESS',0)}/10",
                    ha='center',va='center',fontsize=7,
                    color='black' if c[arm+'SuccessRate'] > .5 else 'white')
        ax.set(title=arm.capitalize()+' completed representations', xlabel='#Variables (N)', ylabel='#Types (M)',
               xticks=range(2,11),yticks=range(1,11))
    fig.colorbar(artist,ax=axes,shrink=.7,label='Success fraction within 300 seconds')
    fig.suptitle('Final grid coverage: ten predicates per cell per arm')
    fig.savefig(destination.with_suffix('.png'),dpi=180)
    fig.savefig(destination.with_suffix('.pdf'))
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    manifest = json.loads((args.run / "manifest.json").read_text())
    rows = [json.loads(line) for line in (args.run/"trials.jsonl").read_text().splitlines()]
    if not manifest.get("complete") or {r["id"] for r in rows} != {r["id"] for r in manifest["trials"]}:
        raise ValueError("Final surface requires a completed schedule")
    cells = cells_from_rows(rows)
    if {(c["variables"],c["types"]) for c in cells} != {(n,m) for n in range(2,11) for m in range(1,n+1)}:
        raise ValueError("Missing grid cells")
    if any(c["predicates"] != 10 for c in cells):
        raise ValueError("Expected five pairs / ten predicates per cell")
    args.output.mkdir(parents=True, exist_ok=False)
    with (args.output/"cells.csv").open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=list(cells[0]))
        writer.writeheader()
        writer.writerows(cells)
    source_hashes = {p: hashlib.sha256((args.run/p).read_bytes()).hexdigest()
                     for p in ("trials.jsonl", "manifest.json", "summary.json")}
    summary = dict(runRoot=str(args.run.resolve()), runId=manifest["runId"],
                   sourceHashes=source_hashes, cells=cells,
                   continuation=manifest.get("continuation"),
                   statistic="mean log10(untyped/typed engine elapsed time), matching exact predicate",
                   interpolation="piecewise linear; no extrapolation, smoothing, or timeout imputation")
    (args.output/"surface-data.json").write_text(json.dumps(summary, indent=2)+"\n")
    surface(cells, "matchedLog10EngineSpeedup", "Typed slot speedup: construction + adaptation",
            args.output/"engine-speedup-surface", manifest)
    surface(cells, "matchedLog10WallSpeedup", "Typed slot speedup: end-to-end JVM runtime",
            args.output/"wall-speedup-surface", manifest)
    outcome_grid(cells, args.output/'completion-grid')
    successful = [c for c in cells if c["completeMatchedCell"]]
    continuation = manifest.get("continuation")
    continuation_note = ""
    if continuation:
        continuation_note = (
            "The schedule was continued after a host-memory reserve stop. "
            f"The first {continuation['preservedCompleted']} completed records were preserved unchanged, "
            f"including all timeouts; only {continuation['resumed']} interrupted/unstarted trials "
            "were executed in the continuation using identical frozen classes, inputs and limits. "
            "Timing spans two host-load periods; it is not an uninterrupted or repeated-run estimate.\n\n")
    (args.output/"README.md").write_text(
        "# Final Synthetic Typed/Untyped Grid\n\n"
        f"Run: `{manifest['runId']}`. Complete matched cells: {len(successful)}/54.\n\n"
        "The primary z-axis is mean log10(untyped/typed engine elapsed time) for the same predicate. "
        "Positive means typed faster; z=1 means 10x. Engine timing includes adaptation and representation, "
        "not startup/parsing. The secondary figure includes startup/parsing/output. "
        "These are concurrent elapsed times, not worker CPU times.\n\n"
        "Five generated paired shapes per cell are input replicates, not five independent reruns. "
        "All ten predicate measurements must succeed in both arms for a cell to enter the surface. "
        "Only adjacent measured cells are joined; no fabricated curves cross missing cells. "
        "Success-only median/P95, success rates, and censored statuses remain in cells.csv.\n\n"
        + continuation_note +
        "![Engine speedup surface](engine-speedup-surface.png)\n\n"
        "![Completion grid](completion-grid.png)\n\n"
        f"Raw evidence: `{args.run.resolve()}`. Source hashes are in surface-data.json.\n")
    print(json.dumps({"completeCells":len(successful), "cells":len(cells), "output":str(args.output)}))


if __name__ == "__main__":
    main()
