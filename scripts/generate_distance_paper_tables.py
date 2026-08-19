#!/usr/bin/env python3
import hashlib
import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path


HEADLINE_METRICS = [
    ("Total files", ("Total files",), True),
    ("Successful distances", ("Successful distances",), True),
    ("Skipped identical raw AST predicate pairs",
     ("Skipped identical raw AST predicate pairs",), True),
    ("Failures", ("Failures",), True),
    ("Average Certificate-Integrated IR repair distance",
     ("Average Certificate-Integrated IR repair distance",
      "Average certified repair distance"), True),
    ("Average canonical representative TED baseline",
     ("Average canonical representative TED baseline",), True),
    ("Average Fast Rewrite IR distance",
     ("Average Fast Rewrite IR distance",
      "Average direct reference-metric distance"), True),
    ("Average predicate-body Levenshtein distance",
     ("Average predicate-body Levenshtein distance",), True),
    ("Average raw AST tree distance", ("Average raw AST tree distance",), True),
    ("Average raw AST size", ("Average raw AST size",), True),
    ("Average Certificate-Integrated IR repair observation size",
     ("Average Certificate-Integrated IR repair observation size",
      "Average repair observation size"), True),
    ("Average canonical representative tree size",
     ("Average canonical representative tree size",), True),
    ("Average Fast Rewrite IR NormalForm size",
     ("Average Fast Rewrite IR NormalForm size",
      "Average reference NormalForm metric size"), True),
    ("Average normalized predicate-body Levenshtein distance",
     ("Average normalized predicate-body Levenshtein distance",), True),
    ("Average normalized raw AST distance",
     ("Average normalized raw AST distance",), True),
    ("Average normalized Certificate-Integrated IR distance",
     ("Average normalized Certificate-Integrated IR distance",
      "Average normalized certified repair distance"), True),
    ("Average normalized canonical representative TED",
     ("Average normalized canonical representative TED",), True),
    ("Average normalized Fast Rewrite IR distance",
     ("Average normalized Fast Rewrite IR distance",
      "Average normalized direct reference-metric distance"), True),
    ("CORRECT models with canonical distance 0 and raw AST distance > 0",
     ("CORRECT models with canonical distance 0 and raw AST distance > 0",), True),
    ("Incorrect zero-distance merges", ("Incorrect zero-distance merges",), True),
    ("Inexact alpha searches", ("Inexact alpha searches",), True),
    ("Average certified repair metric time",
     ("Average certified repair metric time",), True),
    ("Average canonical representative TED time",
     ("Average canonical representative TED time",), True),
    ("Min distance", ("Min distance",), True),
    ("Max distance", ("Max distance",), True),
    ("Pearson correlation, certified repair distance vs candidate reward",
     ("Pearson correlation, certified repair distance vs candidate reward",), False),
    ("Pearson correlation, canonical representative TED vs candidate reward",
     ("Pearson correlation, canonical representative TED vs candidate reward",), False),
    ("Pearson correlation, direct reference-metric distance vs candidate reward",
     ("Pearson correlation, direct reference-metric distance vs candidate reward",), False),
    ("Pearson correlation, Levenshtein vs candidate reward",
     ("Pearson correlation, Levenshtein vs candidate reward",), False),
    ("Pearson correlation, raw AST tree distance vs candidate reward",
     ("Pearson correlation, raw AST tree distance vs candidate reward",), False),
]


def parse_metrics(lines):
    parsed = {}
    pattern = re.compile(r"^- ([^:]+):\s*(.+)$")
    for line in lines:
        match = pattern.match(line)
        if match:
            parsed[match.group(1)] = match.group(2)
    metrics = {}
    missing = []
    for key, aliases, required in HEADLINE_METRICS:
        value = next((parsed[alias] for alias in aliases if alias in parsed), None)
        if value is not None:
            metrics[key] = value
        elif required:
            missing.append(key)
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
    output = (Path(sys.argv[2]) if len(sys.argv) > 2 else
              Path(os.environ.get("TMPDIR", "/tmp")) /
              "acgn-distance-paper-artifacts" / "paper_tables.md")
    metrics_output = output.with_name("paper_metrics.json")
    output.parent.mkdir(parents=True, exist_ok=True)
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
    for key, _, _ in HEADLINE_METRICS:
        if key not in metrics:
            continue
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
        "metrics": metrics,
        "tableCount": len(tables),
    }
    metrics_output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {output}")
    print(f"Wrote {metrics_output}")


if __name__ == "__main__":
    main()
