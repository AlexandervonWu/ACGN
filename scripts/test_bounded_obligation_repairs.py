import csv
from pathlib import Path
import tempfile
import unittest

from run_bounded_obligation_repairs import (
    Blocked, policy_mapping, join_mapping, flat_mapping, ZERO_FIELDS, ZERO_CENSUS, zero_trace_program,
    BUILTIN_FIELDS, BUILTIN_CENSUS, builtin_trace_program,
    pinned_lean_environment,
)


class PolicyMappingTest(unittest.TestCase):
    def test_toolchain_pin_across_working_directories(self):
        pin = "leanprover/lean4:v4.33.0"
        for old in ({}, {"ELAN_TOOLCHAIN": "leanprover/lean4:stable"},
                    {"ELAN_TOOLCHAIN": "leanprover/lean4:v4.33.1", "PATH": "/test/bin"}):
            original = dict(old)
            result = pinned_lean_environment(old, pin + "\n", "4.33.0")
            self.assertEqual(result, dict(old, ELAN_TOOLCHAIN=pin))
            self.assertEqual(old, original)
        for bad in ("", "leanprover/lean4:stable", "leanprover/lean4:v4.33.1"):
            with self.assertRaises(Blocked):
                pinned_lean_environment({}, bad, "4.33.0")

    def test_builtin_codec(self):
        rows = []
        for fixture, (name, left, right, equivalent) in BUILTIN_CENSUS.items():
            for scope in range(3):
                row = dict.fromkeys(BUILTIN_FIELDS, "unused-text")
                row.update(fixture=fixture, scope_index=str(scope), source_name=name,
                           source_kind="BUILTIN_NONE" if name == "none" else "BUILTIN_UNIV" if name == "univ" else "USER",
                           semantic_identity=("alloy/builtin/" if name in ("none", "univ") else "alloy/signature/") + name)
                l, r = left[scope] == "1", right[scope] == "1"
                values = [equivalent] * 7 + [l, r, l, r, False, False, l != r]
                row.update({key: str(value).lower() for key, value in
                            zip(BUILTIN_FIELDS[11:18] + BUILTIN_FIELDS[20:27], values)})
                rows.append(row)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "builtin.tsv"
            def write(values):
                with path.open("w", encoding="utf-8", newline="") as stream:
                    writer = csv.DictWriter(stream, fieldnames=BUILTIN_FIELDS, delimiter="\t")
                    writer.writeheader()
                    writer.writerows(values)
            write(rows)
            self.assertEqual(builtin_trace_program(path)[1], 72)
            for bad in (rows[:-1], rows + [rows[0]]):
                write(bad)
                with self.assertRaises(Blocked):
                    builtin_trace_program(path)
            for field, value in (("scope_index", "01"), ("source_kind", "BUILTIN_BY_NAME"),
                                 ("raw_equivalent", "yes")):
                bad = [dict(row) for row in rows]
                bad[0][field] = value
                write(bad)
                with self.assertRaises(Blocked):
                    builtin_trace_program(path)
            bad = [dict(row) for row in rows]
            bad[0]["source_kind"] = "USER"
            write(bad)
            self.assertIn("(.user : SignatureKind) = (.builtin .noneSet)", builtin_trace_program(path)[0])

    def test_zero_trace_census_and_encoding(self):
        rows = []
        for fixture, callees in ZERO_CENSUS.items():
            occurrence = 0
            for callee, count in callees.items():
                for _ in range(count):
                    row = dict.fromkeys(ZERO_FIELDS, "0")
                    row.update(fixture=fixture, parser_path="p/" + str(occurrence), occurrence=str(occurrence),
                               owner=str(occurrence + 10), visit="1", parser_kind="call/expression",
                               parser_source="call", edge_count="2", callee_match="true",
                               e1_owner=str(occurrence + 10), e2_owner=str(occurrence + 10),
                               e1_visit="1", e2_visit="1", e1_position="1", e2_position="2",
                               e1_is_end="false", e2_is_end="true")
                    for prefix in ("", "target_", "ir_", "cert_"):
                        row.update({prefix + "source": "call", prefix + "callee": callee,
                                    prefix + "kind": "call/expression", prefix + "arity": "0",
                                    prefix + "authority": "DECLARATION"})
                    row["ir_occurrence"] = row["cert_occurrence"] = str(occurrence)
                    rows.append(row)
                    occurrence += 1
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "zero.tsv"
            def write(values):
                with path.open("w", encoding="utf-8", newline="") as stream:
                    writer = csv.DictWriter(stream, fieldnames=ZERO_FIELDS, delimiter="\t")
                    writer.writeheader()
                    writer.writerows(values)
            write(rows)
            self.assertEqual(zero_trace_program(path)[1], 13)
            for bad in (rows[:-1], rows + [rows[0]]):
                write(bad)
                with self.assertRaises(Blocked):
                    zero_trace_program(path)
            for field, value in (("occurrence", "true"), ("callee_match", "1"),
                                 ("ir_authority", "TRUST_ME"), ("parser_kind", "predicate")):
                bad = [dict(r) for r in rows]
                bad[0][field] = value
                write(bad)
                with self.assertRaises(Blocked):
                    zero_trace_program(path)
            bad = [dict(r) for r in rows]
            bad[0]["e2_is_end"] = "false"
            write(bad)
            self.assertIn(".other", zero_trace_program(path)[0])

    def test_flat_mapping(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "flat.tsv"
            header = "requiredPortCount\trootPortIndex\n"
            path.write_text(header + "1\t0\n", encoding="utf-8")
            self.assertEqual(flat_mapping(path), {"requiredPortCount": 1, "rootPortIndex": 0})
            for bad in ("", "1\t0\n1\t0\n", "-1\t0\n", "1\tfalse\n", "01\t0\n"):
                path.write_text(header + bad, encoding="utf-8")
                with self.assertRaises(Blocked):
                    flat_mapping(path)

    def test_join_mapping(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "join.tsv"
            header = "guard\tminimumInteriorArity\tstart\tendOffset\n"
            valid = "producer\t2\t1\t1\nverifier\t2\t1\t1\n"
            path.write_text(header + valid, encoding="utf-8")
            self.assertEqual(join_mapping(path), {"producer": 2, "verifier": 2})
            for bad in (valid.splitlines()[0] + "\n", valid.replace("verifier", "producer"),
                        valid.replace("\t2\t", "\ttrue\t"), valid.replace("\t1\t1", "\t2\t1")):
                path.write_text(header + bad, encoding="utf-8")
                with self.assertRaises(Blocked):
                    join_mapping(path)
            path.write_text(header + valid.replace("\t2\t", "\t3\t"), encoding="utf-8")
            self.assertEqual(join_mapping(path)["producer"], 3)

    def test_schema_and_coordinates(self):
        header = ["field", "nominalType", "constructorParameter", "getterField"]
        names = ["arityPolicy", "siblingQuotient", "flatLicense", "unitLicense"]
        types = ["ArityPolicy", "SiblingQuotient", "FlatLicense", "UnitLicense"]
        rows = [[name, "is.fivefivefive.CanDis.theory." + kind, str(i), str(i)]
                for i, (name, kind) in enumerate(zip(names, types))]
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "mapping.tsv"

            def write(values):
                with path.open("w", newline="", encoding="utf-8") as stream:
                    csv.writer(stream, delimiter="\t").writerows([header, *values])

            write(rows)
            self.assertEqual(policy_mapping(path)["getterField"], [0, 1, 2, 3])
            for bad in (rows[:-1], rows + [rows[0]], list(reversed(rows))):
                write(bad)
                with self.assertRaises(Blocked):
                    policy_mapping(path)
            for column, value in ((1, "Bool"), (2, "true"), (3, "04"), (3, "-1")):
                changed = [list(row) for row in rows]
                changed[0][column] = value
                write(changed)
                with self.assertRaises(Blocked):
                    policy_mapping(path)
            # A well-formed but wrong program is preserved for Lean to reject.
            changed = [list(row) for row in rows]
            changed[0][3] = "1"
            write(changed)
            self.assertEqual(policy_mapping(path)["getterField"], [1, 1, 2, 3])


if __name__ == "__main__":
    unittest.main()
