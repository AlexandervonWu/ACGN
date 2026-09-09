"""Bounded P3-04 codec/registry correspondence. This encoder is tested TCB.

The census, type witnesses, expected records and rejection predicates are fixed
independently of Java observations. SHA-256 computation is trusted, not proved
injective. Registry operator IDs are opaque TEST_ONLY references; their exact
identity/type/schema payloads and all schema/type content preimages are checked.
"""

import base64
import binascii
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import re
import struct

from fourth_chain_replays import parse_key
from fourth_profile_replays import SOURCES as PROFILE_SOURCES, source_fields, stable
from next_obligation_replays import rows
from run_submission_container_closure import Blocked

FIELDS = ("case fixture profile op type mutation profileKey resultKey elementKey schemaKey "
          "producer writer candidate vocabulary outerFresh outcome detail").split()
SOURCE_FIELDS = "object owner shapeSha256 bindingsSha256".split()
NAMESPACE = "ACGN.FifthFive.LawRecordWireReplay"
REGISTRY = "alloy-container-law-theory-v3"
DIGEST = "b6479712e518b5dfc13f19866769f30ab81b49bd4bad508a175691fbb1d0633f"
OPS = "AND OR PLUS INTERSECT IPLUS MUL EQUALS NOT_EQUALS IFF DISJOINT".split()
LAWS = "ASSOCIATIVITY COMMUTATIVITY IDEMPOTENCY UNIT".split()
FAMILIES = ["all-legal-outer-nested-arities-and-splice-positions", "all-admitted-sibling-permutations",
            "all-admitted-quotient-surjections", "exact-empty-fold-deletion"]
RECOMPUTED = "operator result element carrier policy path law profile digest parameter endpoints".split()
REGISTRY_ATTACKS = "operator result element carrier policy".split()
SOURCES = dict(PROFILE_SOURCES, **{
    "AlloyLawRegistry": ("is.fivefivefive.CanDis.theory.AlloyLawRegistry",
        "272257f8d03588e9cd009512c35a32a18c5194b5f74044c87a2716081690fb7b", "9cad15d627e624d2998e965e86e8f5b52868552ca5c2d0015e12fb2fecebd041"),
    "ContainerLawCertificate": ("is.fivefivefive.CanDis.theory.ContainerLawCertificate",
        "b058b18d175022e193564a5e93c254fbd48924e82de99820daf6ad7142cdc0f2", "d952931af1f841172ecdef2d6d04e8f94279d45869f97b0e5e0de49d4cea049e"),
    "CertificateOrigin": ("is.fivefivefive.CanDis.theory.CertificateOrigin",
        "c88d33167e5b9a53f361ab0522a0b9d8559f5e934fa13039be7a98daad5ce9cb", "621cef08d188571283089f056b2cf8bb44e22881b9d6a124952774694a3807e9"),
})


def require(ok, message):
    if not ok:
        raise Blocked("law-record: " + message)


def sha(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def b64(value):
    return base64.b64encode(value.encode("utf-8")).decode("ascii")


def decoded(value):
    require(isinstance(value, str) and len(value) <= 131072, "encoded field bound")
    try:
        raw = base64.b64decode(value, validate=True)
        result = raw.decode("utf-8")
    except (UnicodeError, ValueError, binascii.Error) as error:
        raise Blocked("law-record: Base64/UTF8") from error
    require(b64(result) == value and result.isascii(), "canonical ASCII fixture field")
    return result


def node(tag, scalars=(), children=()):
    return tag, tuple(scalars), tuple(children)


def tree_key(n):
    return stable(n[0], n[1], [tree_key(c) for c in n[2]])


def wire_bytes(n):
    def string(value):
        encoded = value.encode("utf-8")
        return struct.pack(">I", len(encoded)) + encoded
    return (string(n[0]) + struct.pack(">I", len(n[1])) + b"".join(map(string, n[1]))
            + struct.pack(">I", len(n[2])) + b"".join(map(wire_bytes, n[2])))


def content_id(n):
    return hashlib.sha256(wire_bytes(n)).hexdigest()


def java_order(value):
    return value.encode("utf-16-be")


def unpack_table(value):
    require(isinstance(value, str) and len(value) < 131072, "law table bound")
    if not value:
        return []
    result = []
    for record in value.split(";"):
        parts = record.split(":")
        require(len(parts) == 3 and parts[1] in ("0", "1"), "record observation framing")
        result.append((decoded(parts[0]), tuple(map(decoded, parts[2].split("|"))), int(parts[1])))
    require(len(result) <= 4, "finite table bound")
    return result


def pack_table(records):
    return ";".join(b64(tag) + ":" + str(children) + ":" + "|".join(map(b64, scalars))
                    for tag, scalars, children in records)


def graph_type(t):
    a, b = node("CONSTRUCTOR", ["AlloySig:LawA"]), node("CONSTRUCTOR", ["AlloySig:LawB"])
    ra, rb = node("RELATION", [], [a]), node("RELATION", [], [b])
    return {"bool": node("BOOL"), "int": node("INT"), "rel": ra, "rel2": node("RELATION", [], [a, b]),
            "empty": node("CONSTRUCTOR", ["AlloyEmptyRelation$arity=1"]),
            "union": node("CONSTRUCTOR", ["AlloyRelationUnion"], [ra, rb]),
            "comparable": node("CONSTRUCTOR", ["AlloyComparableCarrier"], [ra, rb]),
            "opaque": node("CONSTRUCTOR", ["LawOpaque"])}[t]


def type_key(t):
    return stable("type/" + t[0], t[1], [type_key(c) for c in t[2]])


def runtime_type(t):
    if t[0] in ("BOOL", "INT"):
        return "Bool" if t[0] == "BOOL" else "Int"
    head = "Rel" if t[0] == "RELATION" else t[1][0]
    return head + ("(" + ",".join(map(runtime_type, t[2])) + ")" if t[2] else "")


def exact_type(t):
    content = node("exact-type/content", [t[0], t[1][0] if t[1] else ""],
                   [node("type-ref", [exact_type(c)[1][0]]) for c in t[2]])
    return node("exact-type", [content_id(content), *content[1]], content[2])


def profile_key(p):
    mode = "MODULAR" if p % 2 else "FORBID"
    fields = (["4", mode, "alloy-temporal", "repaired-normal-form-v2", "alloy-signature-v2"]
              if p < 2 else source_fields(3 if p == 2 else 6, mode))
    return stable("semantic-profile", fields)


def primary(op):
    return "rel" if op in ("PLUS", "INTERSECT", "DISJOINT") else "int" if op in ("IPLUS", "MUL") else "bool"


def laws(p, op):
    return LAWS[:3] if op in OPS[:4] else LAWS[:2] if op in ("IPLUS", "MUL") and p % 2 else ["COMMUTATIVITY"]


def schema_key(carrier, arity, element):
    quotient = "COMMUTATIVE_IDEMPOTENT_SET" if carrier == "SET" else "COMMUTATIVE_BAG"
    return stable("schema/" + carrier.lower(), [quotient],
                  [stable("arity-policy", arity.split(":")), stable("schema/one", [], [element])])


def schema_id(key):
    return "schema/" + content_id(node("schema-id", [key]))


def coordinates(p, op, t):
    element = graph_type(t)
    result = element if op in ("PLUS", "INTERSECT", "IPLUS", "MUL") else graph_type("bool")
    flat = "ASSOCIATIVITY" in laws(p, op)
    return dict(op=op, profile=profile_key(p), result=type_key(result), element=type_key(element),
                carrier="SET" if op in OPS[:4] else "BAG", arity="AT_LEAST:1" if flat or op == "DISJOINT" else "FINITE:2",
                runtime=runtime_type(result), exact=exact_type(result)[1][0], path="0/0", digest=DIGEST,
                flat="0/0" if flat else "none", resultType=result, elementType=element, p=p)


def record(c, law, attack=""):
    c = dict(c)
    if attack == "operator": c["op"] = "IFF"
    if attack == "result": c.update(result=type_key(graph_type("int")), runtime="Int", exact=exact_type(graph_type("int"))[1][0])
    if attack == "element": c["element"] = type_key(graph_type("int"))
    if attack == "carrier": c["carrier"] = "BAG" if c["carrier"] == "SET" else "SET"
    if attack == "policy": c["arity"] = "AT_LEAST:0"
    if attack == "path": c["path"] = "0/1"
    if attack == "law": law = "UNIT"
    if attack == "profile": c["profile"] = profile_key(1)
    if attack == "digest": c["digest"] = "0" * 64
    schema = schema_key(c["carrier"], c["arity"], c["element"])
    parameter = stable("alloy-law-parameter-v1", [c["op"], c["path"], law, FAMILIES[LAWS.index(law)]],
                       [c["profile"], c["result"], schema])
    if attack == "parameter": parameter = stable("wrong-parameter", [])
    identity = "ALLOY/" + c["op"]
    index = stable("container-law-index-v2", ["ALLOY_PROFILE_THEORY", identity, c["path"], law, c["digest"]],
                   [c["profile"], c["result"], schema, parameter])
    return (index, "ALLOY_PROFILE_THEORY", identity, c["runtime"], c["exact"], c["path"], law, c["digest"],
            schema_id(schema), schema, parameter,
            stable("container-law-source-endpoint", ["right" if attack == "endpoints" else "left"], [index]),
            stable("container-law-source-endpoint", ["right"], [index]), "SIGNATURE_CONTAINER_LAW",
            REGISTRY + "/" + c["digest"], identity + "@" + c["path"] + ":" + law + ":" + sha(parameter), str(LAWS.index(law)))


@lru_cache(maxsize=None)
def expected_records(p, op, t):
    c = coordinates(p, op, t)
    return tuple(sorted((record(c, law) for law in laws(p, op)), key=lambda r: java_order(r[0])))


def census():
    result = []
    for p in range(4):
        for op in OPS:
            t = primary(op)
            mutations = ["base"]
            if (p, op) in ((0, "AND"), (1, "IPLUS"), (2, "IFF")):
                mutations += [f"field-{i}" for i in range(17)]
                mutations += ["omit-record", "duplicate-record", "duplicate-field", "order-fields", "tag", "child"]
                if len(laws(p, op)) > 1: mutations.append("order-records")
            if (p, op) == (0, "AND"):
                mutations += [f"omit-field-{i}" for i in range(17)]
                mutations += ["recompute-" + a for a in RECOMPUTED] + ["registry-" + a for a in REGISTRY_ATTACKS]
            result.extend((p, op, t, m) for m in mutations)
    result += [(3, "PLUS", t, "base") for t in ("int", "rel2", "empty", "union", "comparable")]
    result += [(2, "EQUALS", t, "base") for t in ("int", "rel", "opaque")]
    return result


def candidate(spec):
    p, op, t, mutation = spec
    records = [("law-certificate", r, 0) for r in expected_records(p, op, t)]
    tag, original, children = records[0]
    fields = list(original)
    if mutation.startswith("field-"):
        i = int(mutation[6:]); fields[i] = stable("wrong", []) if i in (0, 9, 10, 11, 12) else fields[i] + ":changed"
    elif mutation.startswith("omit-field-"): fields.pop(int(mutation[11:]))
    elif mutation == "duplicate-field": fields.append(fields[-1])
    elif mutation == "order-fields": fields[1], fields[2] = fields[2], fields[1]
    elif mutation == "tag": tag = "wrong"
    elif mutation == "child": children = 1
    elif mutation.startswith("recompute-"): fields = record(coordinates(p, op, t), original[6], mutation[10:])
    records[0] = tag, tuple(fields), children
    if mutation == "omit-record": records.pop(0)
    if mutation == "duplicate-record": records.insert(0, records[0])
    if mutation == "order-records": records.reverse()
    if mutation.startswith("registry-"):
        records = [("law-certificate", record(coordinates(p, op, t), r[6], mutation[9:]), 0)
                   for r in expected_records(p, op, t)]
    if mutation.startswith(("field-", "recompute-", "registry-")):
        records.sort(key=lambda r: java_order(r[1][0]))
    return records


def expected_outcome(spec):
    p, op, t, mutation = spec
    original = expected_records(p, op, t)
    if mutation == "base": return "VERIFIED:NONE", "kernel profile independently verified"
    if mutation.startswith("registry-"):
        attack = mutation[9:]
        detail = ("ALLOY/IFF" if attack == "operator" else "ALLOY/AND") + (
            " has the wrong exact result/element types" if attack in ("result", "element")
            else " has a container outside the fixed Alloy law matrix")
        return "REJECTED:THEORY_MISMATCH", detail
    if mutation == "omit-record":
        return "REJECTED:MISSING_EVIDENCE", "Missing exact Alloy law certificates: [" + original[0][0] + "]"
    if mutation == "duplicate-record": return "REJECTED:DUPLICATE_ID", "law certificate records are duplicated or unsorted"
    if mutation == "order-records": return "REJECTED:NONCANONICAL_ENCODING", "law certificate records are duplicated or unsorted"
    if mutation in ("tag", "child", "duplicate-field") or mutation.startswith("omit-field-"):
        tag, fields, n = candidate(spec)[0]
        return "REJECTED:INVALID_RECORD_SHAPE", f"Expected law-certificate(17,0) but found {tag}({len(fields)},{n})"
    if mutation == "field-0" or mutation.startswith("recompute-") and mutation != "recompute-endpoints":
        r = next(r for r in candidate(spec) if r[1] not in original)
        return "REJECTED:THEORY_MISMATCH", "Law certificate is not required by a production operator: " + r[1][0]
    return "REJECTED:THEORY_MISMATCH", "Law certificate does not reconstruct from its fixed registry index"


def validate_sources(extracted):
    require(len(extracted) == 10 and [r.get("object") for r in extracted] == sorted(SOURCES), "source census/order")
    for r in extracted:
        require(set(r) == set(SOURCE_FIELDS) and tuple(r[k] for k in SOURCE_FIELDS[1:]) == SOURCES[r["object"]], "frozen source pin")


def vocabulary_checks(spec, encoded):
    """Exact types, schemas and references; only baseline operator IDs are opaque."""
    p, op, t, mutation = spec
    c = coordinates(p, op, t)
    tree = parse_key(decoded(encoded))
    require(tree[:2] == ("law-vocabulary", ()) and len(tree[2]) == 3, "vocabulary envelope")
    schemas, operators, types = tree[2]
    require([n[:2] for n in tree[2]] == [("schemas", ()), ("operators", ()), ("exact-types", ())], "vocabulary sections")
    exact = {}
    def collect(typ):
        n = exact_type(typ); exact[n[1][0]] = n
        for child in typ[2]: collect(child)
    collect(c["resultType"]); collect(c["elementType"])
    if mutation in ("registry-result", "registry-element"): collect(graph_type("int"))
    require(list(types[2]) == sorted(exact.values(), key=lambda n: n[1][0]), "exact type registry reconstruction")
    one_key = stable("schema/one", [], [c["element"]]); one_id = schema_id(one_key)
    sk = schema_key(c["carrier"], c["arity"], c["element"]); sid = schema_id(sk)
    one = node("schema", [one_id, "ONE", runtime_type(c["elementType"]), "FINITE:1", "RIGID"])
    container = node("schema", [sid, c["carrier"], "", c["arity"],
                     "COMMUTATIVE_IDEMPOTENT_SET" if c["carrier"] == "SET" else "COMMUTATIVE_BAG"], [node("schema-ref", [one_id])])
    expected_schemas = {one_id: one, sid: container}
    extra = None
    if mutation.startswith("registry-"):
        attack = mutation[9:]; r = candidate(spec)[0][1]; new_sid = r[8]
        fields = list(container[1]); children = container[2]; fields[0] = new_sid
        if attack == "carrier": fields[1], fields[4] = "BAG", "COMMUTATIVE_BAG"
        if attack == "policy": fields[3] = "AT_LEAST:0"
        if attack == "element":
            new_one = schema_id(stable("schema/one", [], [type_key(graph_type("int"))]))
            expected_schemas[new_one] = node("schema", [new_one, "ONE", "Int", "FINITE:1", "RIGID"])
            children = (node("schema-ref", [new_one]),)
        expected_schemas[new_sid] = node("schema", fields, children)
        extra_id = "operator/" + content_id(node("operator-id", ["law-counterfeit/" + attack]))
        extra = node("operator", [extra_id, "Int" if attack == "result" else "Bool",
                     "ALLOY/IFF" if attack == "operator" else "ALLOY/AND", "0/0"], [node("schema-ref", [new_sid])])
    require(list(schemas[2]) == sorted(expected_schemas.values(), key=lambda n: n[1][0]), "schema registry reconstruction")
    require(len(operators[2]) == (4 if extra else 3), "operator census")
    ids = [n[1][0] for n in operators[2]]
    require(ids == sorted(set(ids)) and all(re.fullmatch(r"operator/[0-9a-f]{64}", s) for s in ids), "operator IDs/order")
    remaining = list(operators[2])
    if extra:
        require(extra in remaining, "counterfeit declared vocabulary"); remaining.remove(extra)
    expected = [(c["runtime"], "ALLOY/" + op, c["flat"], (node("schema-ref", [sid]),)),
                (runtime_type(c["elementType"]), "law-wire-a", "none", ()),
                (runtime_type(c["elementType"]), "law-wire-b", "none", ())]
    actual = []
    for n in remaining:
        require(n[0] == "operator" and len(n[1]) == 4, "operator shape")
        actual.append((*n[1][1:], n[2]))
    require(sorted(actual) == sorted(expected), "operator payload/reference reconstruction")


class Lean:
    """Intern exact texts and records; references do not equate different values."""
    def __init__(self):
        self.defs, self.texts, self.records, self.tables = [], {}, {}, {}

    def text(self, value):
        if value not in self.texts:
            name = "s" + str(len(self.texts)); self.texts[value] = name
            parsed = None
            if re.match(r"[0-9]+:", value):
                try:
                    parsed = parse_key(value)
                except Blocked:
                    pass
            if parsed is not None:
                # This tested TCB lowering preserves the entire observed text.
                # It cannot substitute a registry key for a different wire key.
                require(tree_key(parsed) == value, "structural dictionary roundtrip")
                tag, scalars, children = parsed
                body = "stable " + self.text(tag) + " " + self.strings(scalars) + " " + self.strings([tree_key(c) for c in children])
                self.defs.append(f"def {name} : Text := {body}")
            else:
                self.defs.append(f"def {name} : Text := ofCodepoints [" + ", ".join(str(ord(c)) for c in value) + "]")
        return self.texts[value]

    def strings(self, values):
        return "[" + ", ".join(map(self.text, values)) + "]"

    def record(self, values):
        values = tuple(values)
        require(len(values) == 17, "record projection arity")
        if values not in self.records:
            name = "r" + str(len(self.records)); self.records[values] = name
            body = ", ".join(map(self.text, values))
            self.defs.append(f"def {name} : LawRecord := ⟨{body}⟩")
        return self.records[values]

    def table(self, values):
        values = tuple(values)
        if values not in self.tables:
            name = "w" + str(len(self.tables)); self.tables[values] = name
            body = ", ".join("⟨" + self.text(tag) + ", " + self.strings(fields) + ", " + str(children) + "⟩"
                             for tag, fields, children in values)
            self.defs.append(f"def {name} : List WireRecord := [{body}]")
        return self.tables[values]

    def entry(self, c, law, r):
        fields = [c["op"], c["profile"], c["result"], c["element"], c["carrier"].lower(),
                  "COMMUTATIVE_IDEMPOTENT_SET" if c["carrier"] == "SET" else "COMMUTATIVE_BAG",
                  stable("arity-policy", c["arity"].split(":")), c["runtime"], c["exact"], r[8], c["path"], law,
                  FAMILIES[LAWS.index(law)], str(LAWS.index(law))]
        return "(ExpectedEntry.mk " + " ".join(map(self.text, fields)) + ")"

    def shape(self, spec):
        p, op, t, mutation = spec
        c = coordinates(p, op, t)
        def category(typ):
            if typ[0] in ("BOOL", "INT"): return typ[0].lower()
            return "other" if typ[1] == ("LawOpaque",) else "relation"
        fields = [op, category(c["resultType"]), category(c["elementType"])]
        carrier, arity, flat = c["carrier"], c["arity"], c["flat"]
        same = c["result"] == c["element"]
        if mutation == "registry-operator": fields[0] = "IFF"
        if mutation == "registry-result": fields[1] = "int"; same = False
        if mutation == "registry-element": fields[2] = "int"; same = False
        if mutation == "registry-carrier": carrier = "BAG"
        if mutation == "registry-policy": arity = "AT_LEAST:0"
        return "(RegistryShape.mk " + " ".join(map(json.dumps, fields)) + " " + str(same).lower() + " " + " ".join(
            map(json.dumps, [carrier, arity, flat])) + " " + str(bool(p % 2)).lower() + ")"


def program(observed, extracted, only=None):
    validate_sources(extracted)
    expected = census()
    require(len(expected) == len(observed) == 152, "predeclared observation census")
    lean = Lean(); proofs = []; entries = set()
    for i, (row, spec) in enumerate(zip(observed, expected)):
        p, op, t, mutation = spec
        require(set(row) == set(FIELDS), "column census")
        require([row[k] for k in ("case", "fixture", "profile", "op", "type", "mutation")] ==
                [str(i), f"{p}:{op}:{t}", str(p), op, t, mutation], "case identity/order")
        c = coordinates(p, op, t)
        require([decoded(row[k]) for k in ("profileKey", "resultKey", "elementKey", "schemaKey")] ==
                [c["profile"], c["result"], c["element"], schema_key(c["carrier"], c["arity"], c["element"])], "fixture coordinates")
        actual_candidate = unpack_table(row["candidate"])
        require(actual_candidate == candidate(spec), "exact predeclared mutation")
        require(row["outerFresh"] in ("true", "false"), "outer hash observation")
        require(row["outcome"] in {"VERIFIED:NONE", "REJECTED:THEORY_MISMATCH", "REJECTED:INVALID_RECORD_SHAPE",
                "REJECTED:MISSING_EVIDENCE", "REJECTED:DUPLICATE_ID", "REJECTED:NONCANONICAL_ENCODING"}, "public verifier stage")
        vocabulary_checks(spec, row["vocabulary"])
        if only is not None and i != only: continue
        expected_r = expected_records(p, op, t)
        registry = "[" + ", ".join(lean.record(r) for r in expected_r) + "]"
        for r in expected_r:
            if r not in entries and only is None:
                entries.add(r)
                entry = lean.entry(c, r[6], r)
                # A finite SHA result with an exact, separately checked preimage.
                # No function is inferred from Java's observed fingerprint.
                check = f"expectedRecord (fun _ => {lean.text(sha(r[10]))}) {entry} = {lean.record(r)}"
                proofs.append((f"entry{len(entries) - 1}", check, "by rfl"))
        outcome, detail = expected_outcome(spec)
        checks = [f"{lean.table(unpack_table(row['producer']))} = ({registry}).map encode",
                  f"{lean.table(unpack_table(row['writer']))} = ({registry}).map encode",
                  f"admitTable {registry} {lean.table(actual_candidate)} = {str(mutation == 'base').lower()}",
                  f"matrixAllowed {lean.shape(spec)} = {str(not mutation.startswith('registry-')).lower()}",
                  f"{row['outerFresh']} = true", f"{lean.text(row['outcome'])} = {lean.text(outcome)}",
                  f"{lean.text(decoded(row['detail']))} = {lean.text(detail)}"]
        if mutation.startswith("recompute-"):
            changed = next(r for r in actual_candidate if r[1] not in expected_r)
            checks.append(f"admitted {registry} ({lean.table([changed])}).head! = false")
        proof = ["by", "  refine ⟨" + ", ".join("?_" for _ in checks) + "⟩"]
        for j in range(len(checks)):
            if j == 2 and mutation == "base":
                proof += ["  · apply (table_admission_iff _ _).mpr", "    constructor", "    · decide +kernel", "    · rfl"]
            elif j == 2:
                proof += ["  · apply table_change_rejects", "    decide +kernel"]
            else:
                proof.append("  · first | rfl | decide +kernel")
        proofs.append((f"observation{i}", " ∧\n    ".join(checks), "\n".join(proof)))
    source = ["import LawRecordWire", "open ACGN.FifthFive.LawRecordWire", "namespace " + NAMESPACE,
              "set_option maxRecDepth 8192", "set_option maxHeartbeats 2000000", *lean.defs]
    for name, proposition, proof in proofs:
        source += [f"theorem {name} : {proposition} := {proof}", f"#print axioms {name}"]
    source.append("end " + NAMESPACE)
    return "\n".join(source) + "\n", len(proofs)


def generate(build, formal):
    source, count = program(rows(Path(build) / "law-record-wire.tsv", FIELDS),
                            rows(Path(build) / "law-record-wire-source.tsv", SOURCE_FIELDS))
    return [("LawRecordWireReplay.lean", source, count)]


def negatives(build, formal):
    observed = rows(Path(build) / "law-record-wire.tsv", FIELDS)
    extracted = rows(Path(build) / "law-record-wire-source.tsv", SOURCE_FIELDS)
    targets = [(0, "producer"), (0, "writer"), (0, "outerFresh")]
    targets += [(i, "outcome") for i, row in enumerate(observed) if row["fixture"] == "0:AND:bool" and row["mutation"] != "base"]
    result = []
    for i, field in targets:
        changed = [dict(row) for row in observed]
        if field in ("producer", "writer"):
            table = unpack_table(changed[i][field]); tag, fields, count = table[0]; fields = list(fields); fields[16] = "99"
            table[0] = tag, tuple(fields), count; changed[i][field] = pack_table(table)
        else: changed[i][field] = "false" if field == "outerFresh" else "VERIFIED:NONE"
        code, _ = program(changed, extracted, only=i)
        result.append((f"law-{i}-{field}", "RejectLawRecordWire.lean", code))
    return result


def source_mutations():
    base = "src/is/fivefivefive/CanDis/theory/"
    verifier = "certificate-verifier/src/org/acgn/cert/SemanticEvidenceVerifier.java"
    specs = [
        ("record-arity", verifier, 'record.requireShape("law-certificate", 17, 0)', 'record.requireShape("law-certificate", 16, 0)'),
        ("record-missing", verifier, "if (!expected.isEmpty())", "if (false)"),
        ("record-order", verifier, 'prior = requireIncreasing(prior, record.scalar(0), "law certificate");', 'prior = record.scalar(0);'),
        ("record-registry", verifier, "ExpectedLaw law = expected.remove(record.scalar(0));", "ExpectedLaw law = expected.get(record.scalar(0));"),
        ("record-fields", verifier, "if (!actual.equals(required)\n                || !claimedIndex.equals(expected.index())", "if (false\n                || !claimedIndex.equals(expected.index())"),
        ("record-exact-type", verifier, "|| !record.scalar(4).equals(expected.resultType().id())", "|| false"),
        ("record-schema", verifier, "|| !schema.equals(expected.schemaKey())", "|| false"),
        ("record-parameter", verifier, "|| !parameter.equals(expected.parameter())", "|| false"),
        ("record-left", verifier, "|| !left.equals(expected.left())", "|| false"),
        ("record-right", verifier, "|| !right.equals(expected.right())", "|| false"),
        ("registry-carrier", verifier, "if (schema.kind() != kind", "if (false"),
        ("registry-exact-carrier", verifier, "requireExactLawCarrier(opcode, resultType, elementType);", ";"),
        ("registry-path", base + "AlloyLawRegistry.java", "if (!PortPath.at(0).equals(path))", "if (!PortPath.at(1).equals(path))"),
        ("registry-parameter", base + "AlloyLawRegistry.java", "certificate.lawParameter().equals(expectedParameter)", "true"),
        ("index-theory", base + "ContainerLawCertificate.java", 'requireText(sourceTheoryDigest, "sourceTheoryDigest")),', '"wrong-theory"),'),
        ("writer-ordinal", base + "CertificateBundleWriter.java", "Integer.toString(origin.ordinal()));\n        }\n\n        private void collectExactTypes()", '"0");\n        }\n\n        private void collectExactTypes()'),
        ("writer-endpoint", base + "CertificateBundleWriter.java", "certificate.leftSourceEndpoint().stableString(),", "certificate.rightSourceEndpoint().stableString(),"),
        ("producer-key-length", base + "StructuralKey.java", "target.append(value.length())", "target.append(value.codePointCount(0, value.length()))"),
    ]
    return [(*s, "LawRecordWireExtractor") for s in specs]
