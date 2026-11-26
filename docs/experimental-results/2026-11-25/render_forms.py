"""Render raw/v3/v3.2 pool counts for the paper from the two release inventories."""
import argparse
from collections import Counter, defaultdict
import csv
import gzip
import hashlib
import json
from pathlib import Path

DATA = Path(__file__).resolve().parent
V3 = DATA.parent / "2026-11-21-studies/v3-question-pools.csv"


def keyed(path, key, value):
    rows = {}
    with path.open(newline="") as f:
        for row in csv.DictReader(f):
            k = key(row)
            if k in rows:
                raise ValueError(f"Duplicate pool {k} in {path}")
            rows[k] = value(row)
    return rows


def counts():
    if hashlib.sha256(V3.read_bytes()).hexdigest() != "3dd2ca7ab76df078c3fdeef2afc6bc2ee218fd5c69fe72ea98d66a8c05fcd88d":
        raise ValueError("Unexpected v3 source inventory")
    for line in (DATA / "SHA256SUMS").read_text().splitlines():
        digest, name = line.split("  ", 1)
        if hashlib.sha256((DATA / name).read_bytes()).hexdigest() != digest:
            raise ValueError(name)
    earlier = keyed(V3, lambda r: (r["question_class"], r["inv_id"]),
                    lambda r: (int(r["#UniqueAST"]), int(r["#UniqueCanonical"])))
    later = keyed(DATA / "question-pools.csv", lambda r: (r["question_set"], r["invariant"]),
                  lambda r: int(r["v3_2_scoped_components"]))
    with gzip.open(DATA / "references.jsonl.gz", "rt") as f:
        refs = Counter(tuple(json.loads(line)["group"]) for line in f)
    if not (earlier.keys() == later.keys() == refs.keys()) or len(refs) != 181:
        raise ValueError("Different pool inventories")
    groups = defaultdict(list)
    for k in sorted(refs, key=lambda k: (k[0], int(k[1].removeprefix("inv")))):
        raw, v3 = earlier[k]
        if raw != refs[k] or not 0 < later[k] <= v3 <= raw:
            raise ValueError(f"Invalid comparison: {k}")
        groups[k[0]].append((k[1], raw, v3, later[k]))
    return groups


def figure(groups, out):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.backends.backend_pdf import PdfPages
    from matplotlib.gridspec import GridSpec
    from matplotlib.lines import Line2D

    colors = ["#bfc5c8", "#ad6323", "#145a72"]
    labels = ["Raw unique ASTs", "v3 canonical", "v3.2 canonical"]
    items = list(groups.items())
    plt.rcParams["pdf.fonttype"] = 42
    with PdfPages(out, metadata={"Title": "Unique forms by invariant", "CreationDate": None}) as pdf:
        for start in range(0, len(items), 6):
            page = items[start:start+6]
            ratios = [max(len(rs) for _, rs in page[i:i+2]) + 4 for i in range(0, len(page), 2)]
            fig = plt.figure(figsize=(7.0, 8.2))
            grid = GridSpec(len(ratios), 2, height_ratios=ratios, left=.07, right=.985,
                            top=.91, bottom=.025, wspace=.20, hspace=.22)
            fig.legend([Line2D([0], [0], color=c, lw=4) for c in colors], labels, frameon=False,
                       loc="upper center", ncol=3, fontsize=11)
            for j, (name, rows) in enumerate(page):
                ax = fig.add_subplot(grid[j//2, j%2])
                maximum = max(r[1] for r in rows)
                for i, (inv, *values) in enumerate(rows):
                    for n, c, offset in zip(values, colors, (-.24, 0, .24)):
                        ax.barh(i + offset, n, height=.20, color=c)
                    ax.text(maximum*1.05, i, " / ".join(map(str, values)), va="center", fontsize=8.7)
                ax.set_yticks(range(len(rows)), labels=[r[0] for r in rows], fontsize=8.5)
                ax.set_ylim(len(rows)-.4, -.75)
                ax.set_xlim(0, maximum*1.63)
                ax.set_xticks([])
                ax.set_title(name, loc="left", fontsize=11, weight="bold", pad=3)
                ax.tick_params(axis="y", length=0, pad=3)
                ax.spines[:].set_visible(False)
            pdf.savefig(fig)
            plt.close(fig)


def table(groups, target):
    def row(name, values):
        return name + " & " + " & ".join(f"{v:,}" for v in values) + r"\\"
    lines = [r"\begin{table}[H]\centering",
             r"\caption{Unique correct-reference ASTs and canonical forms, summed across invariants within each problem. The v3.2 column counts classes under the matching Alloy commands.}",
             r"\label{tab:truth_metrics}", r"\small\begin{tabular}{@{}lrrr@{}}\toprule",
             r"Problem & Raw unique ASTs & v3 canonical & v3.2 canonical\\\midrule"]
    totals = [0, 0, 0]
    for name, rows in groups.items():
        values = [sum(r[i] for r in rows) for i in (1, 2, 3)]
        totals = [a+b for a,b in zip(totals, values)]
        lines.append(row(r"\texttt{" + name.replace("_", r"\_") + "}", values))
    lines += [r"\midrule", row("Total", totals), r"\bottomrule\end{tabular}\end{table}"]
    target.write_text("\n".join(lines)+"\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tex-table", type=Path)
    args = parser.parse_args()
    groups = counts()
    with (DATA / "forms-by-invariant.csv").open("w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["question_set", "invariant", "raw_unique_asts", "canonical_v3", "canonical_v3_2"])
        for name, rows in groups.items():
            w.writerows((name, *r) for r in rows)
    figure(groups, DATA / "forms-by-invariant.pdf")
    if args.tex_table:
        table(groups, args.tex_table)
