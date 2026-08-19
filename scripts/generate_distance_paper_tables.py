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
    ("Rewards enabled", ("Rewards enabled",), True),
    ("Rewarded files", ("Rewarded files",), True),
    ("Pearson correlation sample", ("Pearson correlation sample",), True),
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
]

CORRELATION_METRICS = [
    ("Pearson correlation, Certificate-Integrated IR distance vs candidate reward",
     ("Pearson correlation, Certificate-Integrated IR distance vs candidate reward",
      "Pearson correlation, certified repair distance vs candidate reward")),
    ("Pearson correlation, canonical representative TED vs candidate reward",
     ("Pearson correlation, canonical representative TED vs candidate reward",)),
    ("Pearson correlation, Fast Rewrite IR distance vs candidate reward",
     ("Pearson correlation, Fast Rewrite IR distance vs candidate reward",
      "Pearson correlation, direct reference-metric distance vs candidate reward")),
    ("Pearson correlation, Levenshtein vs candidate reward",
     ("Pearson correlation, Levenshtein vs candidate reward",)),
    ("Pearson correlation, raw AST tree distance vs candidate reward",
     ("Pearson correlation, raw AST tree distance vs candidate reward",)),
    ("Pearson correlation, normalized raw AST distance vs candidate reward",
     ("Pearson correlation, normalized raw AST distance vs candidate reward",)),
    ("Pearson correlation, normalized Certificate-Integrated IR distance vs candidate reward",
     ("Pearson correlation, normalized Certificate-Integrated IR distance vs candidate reward",
      "Pearson correlation, normalized certified repair distance vs candidate reward")),
    ("Pearson correlation, normalized canonical representative TED vs candidate reward",
     ("Pearson correlation, normalized canonical representative TED vs candidate reward",)),
    ("Pearson correlation, normalized Fast Rewrite IR distance vs candidate reward",
     ("Pearson correlation, normalized Fast Rewrite IR distance vs candidate reward",
      "Pearson correlation, normalized direct reference-metric distance vs candidate reward")),
]

UNAVAILABLE_REWARD_COLUMNS = {"Avg reward", "Corr(distance,reward)"}


def parse_bullets(lines):
    parsed = {}
    pattern = re.compile(r"^- ([^:]+):\s*(.+)$")
    for line in lines:
        match = pattern.match(line)
        if match:
            parsed[match.group(1)] = match.group(2)
    return parsed


def parse_metrics(parsed):
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


def parse_reward_correlations(parsed):
    enabled_text = parsed["Rewards enabled"].strip().lower()
    if enabled_text not in {"true", "false"}:
        raise ValueError("Rewards enabled must be true or false")
    rewards_enabled = enabled_text == "true"
    try:
        rewarded_files = int(parsed["Rewarded files"].replace(",", ""))
    except ValueError as exception:
        raise ValueError("Rewarded files must be an integer") from exception
    sample = parsed["Pearson correlation sample"]
    match = re.search(r"\(([0-9,]+)\s+files?\)", sample)
    if match is None:
        raise ValueError("Pearson correlation sample must state its file count")
    sample_size = int(match.group(1).replace(",", ""))

    available = rewards_enabled and rewarded_files > 0 and sample_size > 0
    values = {}
    if available:
        missing = []
        for key, aliases in CORRELATION_METRICS:
            value = next((parsed[alias] for alias in aliases if alias in parsed), None)
            if value is None:
                missing.append(key)
            else:
                values[key] = value
        if missing:
            raise ValueError("Missing reward correlations: " + ", ".join(missing))

    if not rewards_enabled and sample_size == 0:
        reason = ("Reward correlations are unavailable because rewards were "
                  "disabled and the Pearson correlation sample size is zero files.")
    elif not rewards_enabled:
        reason = "Reward correlations are unavailable because rewards were disabled."
    elif rewarded_files == 0 or sample_size == 0:
        reason = ("Reward correlations are unavailable because the Pearson "
                  "correlation sample size is zero files.")
    else:
        reason = None
    return {
        "available": available,
        "reason": reason,
        "rewardsEnabled": rewards_enabled,
        "rewardedFiles": rewarded_files,
        "sample": sample,
        "sampleSize": sample_size,
        "values": values,
    }


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


def markdown_cells(row):
    stripped = row.strip()
    if stripped.startswith("|"):
        stripped = stripped[1:]
    if stripped.endswith("|"):
        stripped = stripped[:-1]
    return [cell.strip() for cell in stripped.split("|")]


def hide_unavailable_reward_cells(table):
    if len(table) < 2:
        return table
    headers = markdown_cells(table[0])
    unavailable = [
        index for index, header in enumerate(headers)
        if header in UNAVAILABLE_REWARD_COLUMNS
    ]
    if not unavailable:
        return table
    result = table[:2]
    for row in table[2:]:
        cells = markdown_cells(row)
        if len(cells) != len(headers):
            raise ValueError("Malformed Markdown table row: " + row)
        for index in unavailable:
            cells[index] = "N/A"
        result.append("| " + " | ".join(cells) + " |")
    return result


def main():
    summary = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("distance_results/summary.md")
    output = (Path(sys.argv[2]) if len(sys.argv) > 2 else
              Path(os.environ.get("TMPDIR", "/tmp")) /
              "acgn-distance-paper-artifacts" / "paper_tables.md")
    metrics_output = output.with_name("paper_metrics.json")
    output.parent.mkdir(parents=True, exist_ok=True)
    raw = summary.read_bytes()
    lines = raw.decode("utf-8").splitlines()
    parsed = parse_bullets(lines)
    metrics = parse_metrics(parsed)
    reward_correlations = parse_reward_correlations(parsed)
    metrics.update(reward_correlations["values"])
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
    markdown.extend(["", "## Reward Correlations", ""])
    if reward_correlations["available"]:
        markdown.extend(["| Metric | Pearson correlation |", "| --- | ---: |"])
        for key, _ in CORRELATION_METRICS:
            markdown.append(f"| {key} | {reward_correlations['values'][key]} |")
    else:
        markdown.append(reward_correlations["reason"])
    for heading, table in tables:
        markdown.extend(["", f"## {heading}", ""])
        if not reward_correlations["available"]:
            table = hide_unavailable_reward_cells(table)
        markdown.extend(table)
    markdown.append("")
    output.write_text("\n".join(markdown), encoding="utf-8")

    payload = {
        "generatedAt": generated_at,
        "source": str(summary),
        "summarySha256": summary_hash,
        "metrics": metrics,
        "rewardCorrelations": reward_correlations,
        "tableCount": len(tables),
    }
    metrics_output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {output}")
    print(f"Wrote {metrics_output}")


if __name__ == "__main__":
    main()
