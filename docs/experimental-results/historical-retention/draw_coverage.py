"""Render the published v3.1 figure geometry with the supplied nearest-distance observations."""
import argparse
import csv
import gzip
import hashlib
import itertools
import subprocess
import os
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

STYLE = "docs/experimental-results/2026-11-21/raw_edit_repair_coverage_ast_canonical.svg"
SERIES = {"#ff7f0e": ("Raw AST", "rawAstDistance"), "#1f77b4": ("CanDis", "canonicalDistance")}
NS = "{http://www.w3.org/2000/svg}"
ET.register_namespace("", NS[1:-1])

def render(ledger, repo, expected, prefix):
    seen = set()
    counts = {color: Counter() for color in SERIES}
    with gzip.open(ledger, "rt", newline="") as records:
        for row in csv.DictReader(records):
            path = row["path"]
            if not path or path in seen:
                raise ValueError(f"Duplicated or empty source path {path!r}")
            seen.add(path)
            for color, (_, field) in SERIES.items():
                distance = int(row[field])
                if distance < 0:
                    raise ValueError(f"Negative {field} for {path!r}")
                counts[color][distance] += 1
            if row["canonicalDistance"] != row["legacyCanonicalDistance"]:
                raise ValueError(f"Canonical paths give different minima for {path!r}")
    n = len(seen)
    if n != expected or n == 0:
        raise ValueError(f"Expected {expected} unique submissions, observed {n}")
    totals = {color: list(itertools.accumulate(freq[r] for r in range(51))) for color, freq in counts.items()}
    src = (repo / STYLE).read_bytes()
    if hashlib.sha256(src).hexdigest() != "909e4f26285a38ea096467ef1d637c863011046d7df686ddf8d32c0ff3859d41":
        raise ValueError("v3.1 figure template fingerprint changed")
    svg = ET.fromstring(src)

    # Coordinates are the axis endpoints of the pinned 980-by-620 template.
    def point(color, r):
        return 88 + r * 17, 534 - totals[color][r] * 464 / n

    for path in svg.findall(NS + "path"):
        color = path.attrib["stroke"]
        path.set("d", " ".join(f"{'M' if r == 0 else 'L'} {x:.6f} {y:.6f}"
                              for r in range(51) for x,y in [point(color, r)]))
    for circle in svg.findall(NS + "circle"):
        title = circle.find(NS + "title")
        if title is None:
            continue
        color = circle.attrib["fill"]
        r = round((float(circle.attrib["cx"]) - 88) / 17)
        _, y = point(color, r)
        circle.set("cy", f"{y:.6f}")
        title.text = f"{SERIES[color][0]}, radius {r}: {totals[color][r]:,} of {n:,}"
    for element in svg:
        text = element.text
        if element.tag == NS + "text":
            font_size = element.get("font-size")
            element.set("font-size", {"12": "17", "14": "18"}.get(font_size, font_size))
            if text in {"Raw AST", "Canonical"}:
                element.text = "CanDis" if text == "Canonical" else text
        legend = (element.tag == NS+"line" and element.get("stroke") in SERIES
                  or element.tag == NS+"circle" and element.find(NS+"title") is None
                  or element.tag == NS+"text" and text in {"Raw AST", "Canonical"})
        if legend:
            element.set("transform", "translate(155 395)")
    svg_data = ET.tostring(svg, encoding="utf-8", xml_declaration=True)
    prefix.with_suffix(".svg").write_bytes(svg_data)
    with prefix.with_suffix(".csv").open("w", newline="") as table:
        writer = csv.writer(table)
        writer.writerow(["radius", "allSubmissions", "rawAstWithinRadius", "canonicalWithinRadius"])
        writer.writerows([r, n, totals["#ff7f0e"][r], totals["#1f77b4"][r]] for r in range(51))
    subprocess.run(["rsvg-convert", "--format", "pdf", "--dpi-x", "72", "--dpi-y", "72",
                    "--output", str(prefix.with_suffix(".pdf")), str(prefix.with_suffix(".svg"))],
                   check=True, env={**os.environ, "SOURCE_DATE_EPOCH": "946684800"})
    print(f"{n:,} submissions, inclusive integer radii 0–50, {prefix}.pdf")

if __name__ == "__main__":
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("ledger", type=Path)
    cli.add_argument("output_prefix", type=Path)
    cli.add_argument("--repo", type=Path, required=True)
    cli.add_argument("--expected", type=int, required=True)
    options = cli.parse_args()
    render(options.ledger, options.repo, options.expected, options.output_prefix)
