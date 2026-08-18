#!/usr/bin/env python3
import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path


HEADLINE_KEYS = [
    "Total files",
    "Successful distances",
    "Skipped identical raw AST predicate pairs",
    "Failures",
    "Average certified repair distance",
    "Average canonical representative TED baseline",
    "Average direct reference-metric distance",
    "Average predicate-body Levenshtein distance",
    "Average raw AST tree distance",
    "Average raw AST size",
    "Average repair observation size",
    "Average canonical representative tree size",
    "Average reference NormalForm metric size",
    "Average normalized predicate-body Levenshtein distance",
    "Average normalized raw AST distance",
    "Average normalized certified repair distance",
    "Average normalized canonical representative TED",
    "Average normalized direct reference-metric distance",
    "CORRECT models with canonical distance 0 and raw AST distance > 0",
    "Incorrect zero-distance merges",
    "Inexact alpha searches",
    "Average certified repair metric time",
    "Average canonical representative TED time",
    "Min distance",
    "Max distance",
    "Pearson correlation, certified repair distance vs candidate reward",
    "Pearson correlation, canonical representative TED vs candidate reward",
    "Pearson correlation, direct reference-metric distance vs candidate reward",
    "Pearson correlation, Levenshtein vs candidate reward",
    "Pearson correlation, raw AST tree distance vs candidate reward",
    "Pearson correlation, normalized raw AST distance vs candidate reward",
    "Pearson correlation, normalized canonical distance vs candidate reward",
    "Pearson correlation, normalized canonical representative TED vs candidate reward",
    "Pearson correlation, normalized direct reference-metric distance vs candidate reward",
]


def parse_metrics(lines):
    metrics = {}
    pattern = re.compile(r"^- ([^:]+):\s*(.+)$")
    for line in lines:
        match = pattern.match(line)
        if match:
            metrics[match.group(1)] = match.group(2)
    missing = [key for key in HEADLINE_KEYS if key not in metrics]
    if missing:
        raise ValueError("Missing summary metrics: " + ", ".join(missing))
    return metrics


def parse_tables(lines):
    tables = []
    heading = "Summary"
    index = 0
    while index < len(lines):
        line = lines[index]
        if line.startswith("## "):
            heading = line[3:]
        if line.startswith("|"):
            block = []
            while index < len(lines) and lines[index].startswith("|"):
                block.append(lines[index])
                index += 1
            tables.append((heading, block))
            continue
        index += 1
    return tables


def main():
    summary = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("distance_results/summary.md")
    output = Path(sys.argv[2]) if len(sys.argv) > 2 else summary.with_name("paper_tables.md")
    metrics_output = output.with_name("paper_metrics.json")
    raw = summary.read_bytes()
    lines = raw.decode("utf-8").splitlines()
    metrics = parse_metrics(lines)
    tables = parse_tables(lines)
    generated_at = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    summary_hash = hashlib.sha256(raw).hexdigest()

    markdown = [
        "# CanDis Paper Tables",
        "",
        "This file is generated from `distance_results/summary.md`. Do not edit it manually.",
        "",
        f"- Generated at: `{generated_at}`",
        f"- Summary SHA-256: `{summary_hash}`",
        "",
        "## Headline Results",
        "",
        "| Metric | Current value |",
        "| --- | ---: |",
    ]
    for key in HEADLINE_KEYS:
        markdown.append(f"| {key} | {metrics[key]} |")
    for heading, table in tables:
        markdown.extend(["", f"## {heading}", ""])
        markdown.extend(table)
    markdown.append("")
    output.write_text("\n".join(markdown), encoding="utf-8")

    payload = {
        "generatedAt": generated_at,
        "source": str(summary),
        "summarySha256": summary_hash,
        "metrics": {key: metrics[key] for key in HEADLINE_KEYS},
        "tableCount": len(tables),
    }
    metrics_output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {output}")
    print(f"Wrote {metrics_output}")


if __name__ == "__main__":
    main()
