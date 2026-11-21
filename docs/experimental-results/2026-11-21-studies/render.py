"""Render the release figure and its accessible data table with Python 3."""
import argparse
import csv
from collections import defaultdict
from pathlib import Path
from xml.etree import ElementTree as ET


def load(path):
    data = {}
    with path.open(newline="") as f:
        for r in csv.DictReader(f):
            key = r["question_class"], int(r["inv_id"].removeprefix("inv"))
            a, c = int(r["#UniqueAST"]), int(r["#UniqueCanonical"])
            if key in data or not 0 < c <= a:
                raise ValueError(f"Invalid pool: {key}")
            data[key] = a, c
    return data


def render(old, new, out):
    if old.keys() != new.keys() or len(new) != 181:
        raise ValueError("Expected the same 181 pools")
    groups = defaultdict(list)
    with (out / "per-invariant.csv").open("w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["question_class", "inv_id", "unique_ast", "canonical_v3",
                    "canonical_v3_1", "reduction_v3_1_pct", "gain_percentage_points"])
        for (group, inv), (a, c) in sorted(new.items()):
            a0, c0 = old[group, inv]
            if a != a0 or c > c0:
                raise ValueError(f"Pool drift or lost reduction: {group}/inv{inv}")
            rate, gain = 100*(a-c)/a, 100*(c0-c)/a
            groups[group].append((inv, a, c0, c))
            w.writerow([group, f"inv{inv}", a, c0, c, f"{rate:.4f}", f"{gain:.4f}"])

    ink, gray, grid, teal, gold = "#152d32", "#465e62", "#d6e0e1", "#17766f", "#de9a32"
    root = ET.Element("svg", xmlns="http://www.w3.org/2000/svg", width="1520", height="1780",
                      viewBox="0 0 1520 1780", role="img", attrib={"aria-labelledby": "title desc"})
    ET.SubElement(root, "title", id="title").text = "Reduction in distinct correct representations by invariant, ACGN v3.1"
    ET.SubElement(root, "desc", id="desc").text = (
        "Seventeen panels show all 181 invariant pools on the same zero to 100 percent scale. "
        "Teal is the reduction already present in v3, gold the additional v3.1 reduction. "
        "Exact counts and percentages are in per-invariant.csv.")
    parent = root

    def el(tag, **attrs):
        return ET.SubElement(parent, tag, {k.replace("_", "-"): str(v) for k, v in attrs.items()})

    def label(x, y, s, size=16, color=ink, **attrs):
        el("text", x=x, y=y, fill=color, font_size=size, **attrs).text = s

    def line(x1, y1, x2, y2, color=grid):
        el("line", x1=x1, y1=y1, x2=x2, y2=y2, stroke=color)

    def rect(x, y, w, h, color):
        return el("rect", x=x, y=y, width=w, height=h, fill=color)

    a, c = map(sum, zip(*new.values()))
    improved = sum(new[k][1] < old[k][1] for k in new)
    parent = el("g", font_family="DejaVu Sans, sans-serif")
    rect(0, 0, 1520, 1780, "#ffffff")
    label(48, 43, "ACGN   /   ALLOY4FUN CORRECT REFERENCE POOLS   /   v3.1", 17, teal, font_weight="bold")
    label(48, 99, "How much does each invariant shrink?", 44, font_weight="bold")
    label(48, 140, f"{a:,} distinct ASTs become {c:,} canonical forms across {len(new)} pools: "
          f"{100*(a-c)/a:.2f}% fewer representations overall.", 23)
    rect(49, 170, 19, 15, teal)
    label(78, 184, "Reduction in v3", 17)
    rect(277, 170, 19, 15, gold)
    label(306, 184, f"Additional reduction in v3.1 ({improved} pools)", 17)
    label(738, 184, "0 = no reduction", 17)
    label(948, 184, "* = only one AST to begin with", 17)
    line(48, 205, 1472, 205)
    for n, (group, rows) in enumerate(groups.items()):
        x = 48 + (n % 2) * 735
        y = 248 + (n // 2) * 163
        label(x, y, group, 23, font_weight="bold")
        a1 = sum(r[1] for r in rows)
        c1 = sum(r[3] for r in rows)
        label(x+680, y, f"{a1:,} ASTs  →  {c1:,} forms", 16, gray, text_anchor="end")
        left, right, base, height = x+45, x+681, y+103, 77
        for t in (0, 50, 100):
            yy = base-height*t/100
            line(left, yy, right, yy)
            label(left-7, yy+4, str(t), 12, gray, text_anchor="end")
        col = (right-left)/len(rows)
        for i, (inv, a1, c0, c1) in enumerate(rows):
            xx = left + (i+.5)*col
            w = min(27, col*.72)
            v0, v1 = (a1-c0)/a1, (a1-c1)/a1
            item = el("g")
            ET.SubElement(item, "title").text = (
                f"{group}/inv{inv}: {a1} AST(s), {c1} canonical form(s); "
                f"{100*v1:.2f}% reduction (v3: {c0} forms)")
            plot = parent
            parent = item
            if v0:
                rect(xx-w/2, base-v0*height, w, v0*height, teal)
            if v1 > v0:
                rect(xx-w/2, base-v1*height, w, (v1-v0)*height, gold)
            if not v1:
                label(xx, base-5, "0*" if a1 == 1 else "0", 13, gray, text_anchor="middle")
            label(xx, base+19, str(inv), 14, text_anchor="middle")
            parent = plot
    line(48, 1702, 1472, 1702)
    label(48, 1733, "Horizontal axis: invariant ID (1 = inv1). Vertical axis: 100 × (distinct ASTs − canonical forms) / distinct ASTs.", 18)
    label(48, 1762, "Counts are within each question set and invariant. The overall rate weights each pool by its AST count.", 17, gray)
    ET.ElementTree(root).write(out/"per-invariant.svg", encoding="utf-8", xml_declaration=True)


if __name__ == "__main__":
    here = Path(__file__).resolve().parent
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--current", type=Path, default=here.parent/"2026-11-21/question-pools.csv")
    p.add_argument("--baseline", type=Path, default=here/"v3-question-pools.csv")
    p.add_argument("--output", type=Path, default=here)
    args = p.parse_args()
    render(load(args.baseline), load(args.current), args.output)
