#!/usr/bin/env python3
"""Fail closed when selected Java rewrite dispatch tables drift from Lean."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


EXPECTED_CANONICAL_ALIAS_COUNT = 15
EXPECTED_ATOMIC_NEGATION_DUAL_COUNT = 14
EXPECTED_NEGATED_COMPARISONS = {
    "NOT_GT",
    "NOT_GTE",
    "NOT_LT",
    "NOT_LTE",
}
EXPECTED_POSITIVE_COMPARISONS = {"GT", "GTE", "LT", "LTE"}
NON_COMPARISON_NEGATED_OPCODES = {"NOT_EQUALS", "NOT_IN"}


class ParityError(RuntimeError):
    """A governed source or dispatch table did not have the expected shape."""


def read_source(path: Path) -> str:
    if not path.is_file():
        raise ParityError(f"missing governed source: {path}")
    return path.read_text(encoding="utf-8")


def strip_java_comments(source: str) -> str:
    result: list[str] = []
    index = 0
    quote = ""
    escaped = False
    line_comment = False
    block_comment = False
    while index < len(source):
        current = source[index]
        following = source[index + 1] if index + 1 < len(source) else ""
        if line_comment:
            if current == "\n":
                line_comment = False
                result.append(current)
            else:
                result.append(" ")
        elif block_comment:
            if current == "*" and following == "/":
                result.extend((" ", " "))
                index += 1
                block_comment = False
            else:
                result.append("\n" if current == "\n" else " ")
        elif quote:
            result.append(current)
            if escaped:
                escaped = False
            elif current == "\\":
                escaped = True
            elif current == quote:
                quote = ""
        elif current == "/" and following == "/":
            result.extend((" ", " "))
            index += 1
            line_comment = True
        elif current == "/" and following == "*":
            result.extend((" ", " "))
            index += 1
            block_comment = True
        else:
            result.append(current)
            if current in {'"', "'"}:
                quote = current
        index += 1
    if block_comment or quote:
        raise ParityError("unterminated Java comment or literal")
    return "".join(result)


def strip_lean_comments(source: str) -> str:
    result: list[str] = []
    index = 0
    quote = False
    escaped = False
    line_comment = False
    block_depth = 0
    while index < len(source):
        current = source[index]
        following = source[index + 1] if index + 1 < len(source) else ""
        if line_comment:
            if current == "\n":
                line_comment = False
                result.append(current)
            else:
                result.append(" ")
        elif block_depth:
            if current == "/" and following == "-":
                result.extend((" ", " "))
                index += 1
                block_depth += 1
            elif current == "-" and following == "/":
                result.extend((" ", " "))
                index += 1
                block_depth -= 1
            else:
                result.append("\n" if current == "\n" else " ")
        elif quote:
            result.append(current)
            if escaped:
                escaped = False
            elif current == "\\":
                escaped = True
            elif current == '"':
                quote = False
        elif current == "-" and following == "-":
            result.extend((" ", " "))
            index += 1
            line_comment = True
        elif current == "/" and following == "-":
            result.extend((" ", " "))
            index += 1
            block_depth = 1
        else:
            result.append(current)
            if current == '"':
                quote = True
        index += 1
    if block_depth or quote:
        raise ParityError("unterminated Lean comment or string literal")
    return "".join(result)


def method_body(java_source: str, method: str) -> str:
    declaration = re.compile(
        r"\bprivate\s+static\s+[A-Za-z0-9_$.<>?\[\]]+\s+"
        + re.escape(method)
        + r"\s*\([^)]*\)\s*\{"
    )
    matches = list(declaration.finditer(java_source))
    if len(matches) != 1:
        raise ParityError(
            f"expected one private static declaration for {method}, found {len(matches)}"
        )
    opening = matches[0].end() - 1
    depth = 0
    quote = ""
    escaped = False
    for index in range(opening, len(java_source)):
        current = java_source[index]
        if quote:
            if escaped:
                escaped = False
            elif current == "\\":
                escaped = True
            elif current == quote:
                quote = ""
            continue
        if current in {'"', "'"}:
            quote = current
        elif current == "{":
            depth += 1
        elif current == "}":
            depth -= 1
            if depth == 0:
                return java_source[opening + 1 : index]
            if depth < 0:
                break
    raise ParityError(f"unbalanced Java method body for {method}")


def exact_switch_content(body: str, selector: str, method: str) -> str:
    switch = re.fullmatch(
        r"\s*switch\s*\(\s*" + re.escape(selector) + r"\s*\)\s*\{(.*)\}\s*",
        body,
        re.DOTALL,
    )
    if switch is None:
        raise ParityError(
            f"{method} must contain exactly one switch over {selector} and no "
            "other executable control flow"
        )
    return switch.group(1)


def decode_quoted(encoded: str) -> str:
    try:
        value = json.loads('"' + encoded + '"')
    except json.JSONDecodeError as error:
        raise ParityError(f"invalid string literal {encoded!r}: {error}") from error
    if not isinstance(value, str):
        raise ParityError(f"non-string literal decoded from {encoded!r}")
    return value


def string_switch_table(body: str, method: str) -> dict[str, str]:
    expected_defaults = {
        "canonicalHead": "head",
        "atomicNegationDual": "null",
    }
    expected_default = expected_defaults.get(method)
    if expected_default is None:
        raise ParityError(f"no governed default return is declared for {method}")
    string_literal = r'"(?:\\.|[^"\\])*"'
    case_group = (
        r'(?:\s*case\s+' + string_literal + r'\s*:)+'
        r'\s*return\s+' + string_literal + r'\s*;'
    )
    default_group = (
        r'\s*default\s*:\s*return\s+'
        + re.escape(expected_default)
        + r'\s*;\s*'
    )
    if re.fullmatch(r'(?:' + case_group + r')+' + default_group, body) is None:
        raise ParityError(
            f"{method} must be a simple string switch with no unparsed statements"
        )
    token = re.compile(
        r'\bcase\s+"((?:\\.|[^"\\])*)"\s*:'
        r'|\breturn\s+"((?:\\.|[^"\\])*)"\s*;'
        r'|\b(default)\s*:'
    )
    pending: list[str] = []
    table: dict[str, str] = {}
    saw_default = False
    for match in token.finditer(body):
        if match.group(1) is not None:
            if saw_default:
                raise ParityError(f"{method} has a case after default")
            pending.append(decode_quoted(match.group(1)))
        elif match.group(2) is not None:
            if not pending:
                continue
            target = decode_quoted(match.group(2))
            for source in pending:
                if source in table:
                    raise ParityError(f"{method} repeats case {source}")
                table[source] = target
            pending.clear()
        else:
            if pending:
                raise ParityError(f"{method} has cases without a string return: {pending}")
            saw_default = True
    if pending or not saw_default or not table:
        raise ParityError(f"{method} switch was not parsed completely")
    return table


def opcode_switch_table(body: str, method: str) -> dict[str, str]:
    case_group = (
        r'(?:\s*case\s+[A-Z][A-Z0-9_]*\s*:)+'
        r'\s*return\s+Opcode\.[A-Z][A-Z0-9_]*\s*;'
    )
    default_group = r'\s*default\s*:\s*return\s+null\s*;\s*'
    if re.fullmatch(r'(?:' + case_group + r')+' + default_group, body) is None:
        raise ParityError(
            f"{method} must be a simple opcode switch with no unparsed statements"
        )
    token = re.compile(
        r"\bcase\s+([A-Z][A-Z0-9_]*)\s*:"
        r"|\breturn\s+Opcode\.([A-Z][A-Z0-9_]*)\s*;"
        r"|\b(default)\s*:"
    )
    pending: list[str] = []
    table: dict[str, str] = {}
    saw_default = False
    for match in token.finditer(body):
        if match.group(1) is not None:
            if saw_default:
                raise ParityError(f"{method} has a case after default")
            pending.append(match.group(1))
        elif match.group(2) is not None:
            if not pending:
                continue
            target = match.group(2)
            for source in pending:
                if source in table:
                    raise ParityError(f"{method} repeats case {source}")
                table[source] = target
            pending.clear()
        else:
            if pending:
                raise ParityError(f"{method} has cases without an Opcode return: {pending}")
            saw_default = True
    if pending or not saw_default or not table:
        raise ParityError(f"{method} switch was not parsed completely")
    return table


def lean_string_table(lean_source: str, definition: str) -> dict[str, str]:
    declaration = re.compile(r"(?m)^\s*def\s+" + re.escape(definition) + r"\b")
    matches = list(declaration.finditer(lean_source))
    if len(matches) != 1:
        raise ParityError(
            f"expected one Lean definition {definition}, found {len(matches)}"
        )
    assignment = lean_source.find(":=", matches[0].end())
    next_declaration = re.search(
        r"(?m)^\s*(?:def|abbrev|theorem|lemma|inductive|structure)\s+",
        lean_source[matches[0].end() :],
    )
    boundary = (
        matches[0].end() + next_declaration.start()
        if next_declaration is not None
        else len(lean_source)
    )
    if assignment < 0 or assignment >= boundary:
        raise ParityError(f"Lean definition {definition} has no local assignment")
    opening = lean_source.find("[", assignment + 2, boundary)
    if opening < 0:
        raise ParityError(f"Lean definition {definition} is not a list literal")
    depth = 0
    quote = False
    escaped = False
    closing = -1
    for index in range(opening, boundary):
        current = lean_source[index]
        if quote:
            if escaped:
                escaped = False
            elif current == "\\":
                escaped = True
            elif current == '"':
                quote = False
            continue
        if current == '"':
            quote = True
        elif current == "[":
            depth += 1
        elif current == "]":
            depth -= 1
            if depth == 0:
                closing = index
                break
    if closing < 0:
        raise ParityError(f"Lean definition {definition} has an unclosed list")

    content = lean_source[opening + 1 : closing]
    pair = re.compile(
        r'\(\s*"((?:\\.|[^"\\])*)"\s*,\s*'
        r'"((?:\\.|[^"\\])*)"\s*\)'
    )
    matches = list(pair.finditer(content))
    residue = pair.sub("", content)
    if residue.replace(",", "").strip() or not matches:
        raise ParityError(f"Lean definition {definition} is not an exact string-pair list")
    table: dict[str, str] = {}
    for match in matches:
        source = decode_quoted(match.group(1))
        target = decode_quoted(match.group(2))
        if source in table:
            raise ParityError(f"Lean definition {definition} repeats key {source}")
        table[source] = target
    return table


def compare_tables(label: str, actual: dict[str, str], expected: dict[str, str]) -> None:
    if actual == expected:
        return
    actual_keys = set(actual)
    expected_keys = set(expected)
    details: list[str] = []
    if expected_keys - actual_keys:
        details.append(f"missing={sorted(expected_keys - actual_keys)}")
    if actual_keys - expected_keys:
        details.append(f"extra={sorted(actual_keys - expected_keys)}")
    changed = {
        key: (actual[key], expected[key])
        for key in sorted(actual_keys & expected_keys)
        if actual[key] != expected[key]
    }
    if changed:
        details.append(f"changed(actual,expected)={changed}")
    raise ParityError(f"{label} mismatch: {'; '.join(details)}")


def governed_negated_comparisons(table: dict[str, str], prefix: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for source, target in table.items():
        if prefix and not source.startswith(prefix):
            continue
        normalized_source = source.removeprefix(prefix)
        if normalized_source.startswith("NOT_") and (
            normalized_source not in NON_COMPARISON_NEGATED_OPCODES
        ):
            if prefix and not target.startswith(prefix):
                raise ParityError(
                    f"negated comparison target lacks required {prefix!r} prefix: "
                    f"{source}->{target}"
                )
            normalized_target = target.removeprefix(prefix)
            result[normalized_source] = normalized_target
    if set(result) != EXPECTED_NEGATED_COMPARISONS:
        raise ParityError(
            "active NOT_* comparison inventory mismatch: "
            f"expected={sorted(EXPECTED_NEGATED_COMPARISONS)} actual={sorted(result)}"
        )
    return result


def check(root: Path) -> None:
    alloy_path = root / "src/is/fivefivefive/CanDis/core/egraph/AlloyRewriteSystem.java"
    normal_path = root / "src/is/fivefivefive/CanDis/core/NormalForm.java"
    egraph_path = root / "src/is/fivefivefive/CanDis/core/EGraphNode.java"
    lean_path = root / "docs/section3-repair-audit/formal/Phase5SourceRules.lean"

    alloy = strip_java_comments(read_source(alloy_path))
    normal = strip_java_comments(read_source(normal_path))
    egraph = strip_java_comments(read_source(egraph_path))
    lean = strip_lean_comments(read_source(lean_path))

    canonical_java = string_switch_table(
        exact_switch_content(
            method_body(alloy, "canonicalHead"), "head", "canonicalHead"
        ),
        "canonicalHead",
    )
    if len(canonical_java) != EXPECTED_CANONICAL_ALIAS_COUNT:
        raise ParityError(
            "canonicalHead alias count mismatch: "
            f"expected={EXPECTED_CANONICAL_ALIAS_COUNT} actual={len(canonical_java)}"
        )
    canonical_lean = lean_string_table(lean, "activeJavaCanonicalHeadTable")
    if len(canonical_lean) != EXPECTED_CANONICAL_ALIAS_COUNT:
        raise ParityError(
            "activeJavaCanonicalHeadTable count mismatch: "
            f"expected={EXPECTED_CANONICAL_ALIAS_COUNT} actual={len(canonical_lean)}"
        )
    compare_tables("canonicalHead versus Lean", canonical_java, canonical_lean)

    atomic_all = string_switch_table(
        exact_switch_content(
            method_body(alloy, "atomicNegationDual"),
            "head",
            "atomicNegationDual",
        ),
        "atomicNegationDual",
    )
    if len(atomic_all) != EXPECTED_ATOMIC_NEGATION_DUAL_COUNT:
        raise ParityError(
            "atomicNegationDual case count mismatch: "
            f"expected={EXPECTED_ATOMIC_NEGATION_DUAL_COUNT} actual={len(atomic_all)}"
        )
    atomic_lean = lean_string_table(lean, "activeJavaAtomicNegationDualTable")
    if len(atomic_lean) != EXPECTED_ATOMIC_NEGATION_DUAL_COUNT:
        raise ParityError(
            "activeJavaAtomicNegationDualTable count mismatch: "
            f"expected={EXPECTED_ATOMIC_NEGATION_DUAL_COUNT} actual={len(atomic_lean)}"
        )
    compare_tables("atomicNegationDual full table versus Lean", atomic_all, atomic_lean)
    atomic = governed_negated_comparisons(atomic_all, "BF/")
    normal_all = opcode_switch_table(
        exact_switch_content(
            method_body(normal, "dualOpcode"), "opcode", "dualOpcode"
        ),
        "dualOpcode",
    )
    normal_comparisons = governed_negated_comparisons(normal_all, "")
    lean_comparisons = lean_string_table(lean, "activeJavaNegatedComparisonTable")
    if set(lean_comparisons) != EXPECTED_NEGATED_COMPARISONS:
        raise ParityError(
            "activeJavaNegatedComparisonTable key mismatch: "
            f"expected={sorted(EXPECTED_NEGATED_COMPARISONS)} "
            f"actual={sorted(lean_comparisons)}"
        )
    compare_tables("atomicNegationDual versus Lean", atomic, lean_comparisons)
    compare_tables("dualOpcode versus Lean", normal_comparisons, lean_comparisons)
    compare_tables("Java NOT_* dispatch implementations", atomic, normal_comparisons)

    egraph_all = opcode_switch_table(
        exact_switch_content(method_body(egraph, "dualOf"), "opcode", "dualOf"),
        "dualOf",
    )
    unexpected_negated = EXPECTED_NEGATED_COMPARISONS & set(egraph_all)
    if unexpected_negated:
        raise ParityError(
            "EGraphNode.dualOf must exclude the active NOT_* comparison inputs: "
            f"present={sorted(unexpected_negated)}"
        )
    egraph_comparisons = {
        source: target
        for source, target in egraph_all.items()
        if source in EXPECTED_POSITIVE_COMPARISONS
    }
    if set(egraph_comparisons) != EXPECTED_POSITIVE_COMPARISONS:
        raise ParityError(
            "EGraphNode.dualOf ordinary comparison inventory mismatch: "
            f"expected={sorted(EXPECTED_POSITIVE_COMPARISONS)} "
            f"actual={sorted(egraph_comparisons)}"
        )
    egraph_lean = lean_string_table(lean, "activeJavaEGraphComparisonDualTable")
    if set(egraph_lean) != EXPECTED_POSITIVE_COMPARISONS:
        raise ParityError(
            "activeJavaEGraphComparisonDualTable key mismatch: "
            f"expected={sorted(EXPECTED_POSITIVE_COMPARISONS)} "
            f"actual={sorted(egraph_lean)}"
        )
    compare_tables("EGraphNode.dualOf versus Lean", egraph_comparisons, egraph_lean)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--root",
        type=Path,
        default=Path(__file__).resolve().parent.parent,
        help="repository root",
    )
    args = parser.parse_args()
    try:
        check(args.root.resolve())
    except (OSError, ParityError) as error:
        print(f"rewrite dispatch parity: FAIL: {error}", file=sys.stderr)
        return 1
    print(
        "rewrite dispatch parity: PASS: "
        "15 canonical aliases, the full 14-case atomic negation table, 4 NOT_* "
        "normalization mappings, and 4 ordinary EGraph complement mappings "
        "match Lean; EGraph NOT_* inputs are absent"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
