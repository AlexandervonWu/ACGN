"""A2-12 retained-source slice. Independent fixture census, never pin learning.

The existing strict ASCII StructuralKey parser/type constructors are tested TCB.
No old observation or proof output is used as evidence for this slice.
"""

import base64
import binascii
import hashlib
import json
from pathlib import Path
import re

from fourth_chain_replays import key, parse_key, dag, relation, combine, CTX, rows
from run_submission_container_closure import Blocked

FIELDS = "fixture field value".split()
SOURCE_FIELDS = "object owner shapeSha256 bindingsSha256".split()
NAMESPACE = "ACGN.FifthFive.SourceReplay"
PINS = {
    "DependentChainCertificate": "800b128e0f225b68f242d201009689bb5eeded3391250ef4259378dce034c35f 123b6c433070bf4455f1a888010e09bd51b45b584833ff884c6d71d48f0978e4",
    "EGraphNode": "a3dcefcf9f13b10cf7883954a822a3d01d2a975d953214550eeb454958296a39 17723240dfec4fb1add3566251897704133d13eb339d0d7b5862cb5fa54aa637",
    "NormalForm": "ab9bfc73fc9e8489d60d8114188ae8fee2b5ef21486eee7767360ab9cb059f79 fc5576cd2d9e19533cbb680801d2972d2348a3c293b1f2495fc539d7e806e5f0",
    "StructuralKey": "62183e7e02a6c3cb416290405dea37ea44a00d9cfe662b74e1c04ccc7e91ba96 63f1e1524ff3c28e48a3991dccdbeeee7e9319f5b5bf47dc03523bfd8392386f",
    "TheoryAlloyAdapter": "e4c13603b97a2b342cd80a2aa25e131abdda5ff91aea63248f15bca102080495 2781b813137ddf634e7d56b3f3649302d7a94e1d1503449cb2e0cf21c0c4d2a5",
}
FROZEN = "IllegalStateException:A certified Fast Rewrite source e-graph is immutable"
LINEAGE = "IllegalStateException:A dependent certificate was attached to another source lineage"
PROJECTION = "IllegalArgumentException:Repair projection source identity differs at phase 0"
TRANSFER = "IllegalArgumentException:A dependent source changed outside its certified ACI operands"
def utf16_length(value):
    return len(value.encode("utf-16-le", errors="strict")) // 2


def stable(k):
    tag, scalars, children = k
    frame = lambda s: str(utf16_length(s)) + ":" + s
    return frame(tag) + "[" + str(len(scalars)) + ":" + "".join(map(frame, scalars)) + "]{" + str(len(children)) + ":" + "".join(frame(stable(c)) for c in children) + "}"


PROFILE = hashlib.sha256(stable(key("semantic-profile", ["4", "FORBID", "alloy-temporal",
    "repaired-normal-form-v2", "alloy-signature-v2"])).encode()).hexdigest()


def require(ok, message):
    if not ok:
        raise Blocked("source-bindings: " + message)


def decoded(value):
    require(isinstance(value, str) and len(value) < 200000, "value bound")
    try:
        data = base64.b64decode(value, validate=True)
        result = data.decode("utf-8", errors="strict")
    except (ValueError, UnicodeError, binascii.Error) as error:
        raise Blocked("source-bindings: canonical UTF-8 base64") from error
    require(base64.b64encode(data).decode() == value, "base64 spelling")
    return result


def owner(name):
    return "is.fivefivefive.CanDis." + ("core." if name in ("EGraphNode", "NormalForm") else "theory.") + name


def validate_sources(extracted):
    require(len(extracted) == len(PINS), "source census size")
    for row, name in zip(extracted, sorted(PINS)):
        require(set(row) == set(SOURCE_FIELDS), "source schema")
        require([row[k] for k in SOURCE_FIELDS] == [name, owner(name), *PINS[name].split()], "source pin/census")


def exact_type(width):
    return "RELATION[" + "1:A" * width + "]"


def leaf_content(name, width, transfer=False):
    return ("leaf", "GLOBALBINDING{" + PROFILE + ";" + exact_type(width) +
            ";K[0];ORDERED_SEQUENCE;nonflat;ABSENT}:" + name + "[]" + ("@{}" if transfer else ""))


def app_content(op, width, left, right):
    return "app", op, PROFILE, exact_type(width), "{}", left, "{}", right


def content(op, variant, transfer=False):
    w = 2 if op == "JOIN" else 1
    a, b, c = [leaf_content(n, w, transfer) for n in ("a", "a" if variant == "repeat" else "b", "c")]
    return (app_content(op, w if op == "JOIN" else 3, a, app_content(op, 2, b, c))
            if variant == "right" else app_content(op, w if op == "JOIN" else 3, app_content(op, 2, a, b), c))


def encode_content(c):
    frame = lambda s: str(utf16_length(s)) + ":" + s
    if c[0] == "leaf":
        return frame("leaf") + frame(c[1])
    _, op, profile, ty, ls, l, rs, r = c
    return "".join(map(frame, ("application", op, profile, ty, ls))) + encode_content(l) + frame(rs) + encode_content(r)


class Framed:
    """Strict Java UTF-16 length framing over valid Unicode scalar input."""
    def __init__(self, value):
        require(len(value) < 50000, "framed input bound")
        self.value, self.at = value, 0

    def literal(self, token):
        require(self.value.startswith(token, self.at), "framed literal")
        self.at += len(token)

    def natural(self):
        end = self.value.find(":", self.at)
        require(end >= 0 and re.fullmatch(r"0|[1-9][0-9]{0,5}", self.value[self.at:end]) is not None,
                "canonical framed length")
        value = int(self.value[self.at:end])
        require(value <= 50000, "framed count bound")
        self.at = end + 1
        return value

    def scalar(self):
        remaining, start = self.natural(), self.at
        while remaining > 0:
            require(self.at < len(self.value), "truncated scalar")
            remaining -= 1 if ord(self.value[self.at]) < 65536 else 2
            self.at += 1
        require(remaining == 0, "split surrogate pair")
        return self.value[start:self.at]

    def end(self):
        require(self.at == len(self.value), "trailing framed data")


def parse_content(value):
    reader = Framed(value)

    def node(depth):
        require(depth < 128, "content depth")
        tag = reader.scalar()
        if tag == "leaf":
            return "leaf", reader.scalar()
        require(tag == "application", "content tag")
        op, profile, ty, ls = [reader.scalar() for _ in range(4)]
        l = node(depth + 1)
        rs = reader.scalar()
        return "app", op, profile, ty, ls, l, rs, node(depth + 1)
    result = node(0)
    reader.end()
    require(encode_content(result) == value, "content re-encoding")
    return result


def parse_utf16_key(value, depth=0):
    require(depth < 128, "key depth")
    reader = Framed(value)
    tag = reader.scalar()
    require(bool(tag), "empty key tag")
    reader.literal("[")
    scalars = [reader.scalar() for _ in range(reader.natural())]
    reader.literal("]{")
    children = [parse_utf16_key(reader.scalar(), depth + 1) for _ in range(reader.natural())]
    reader.literal("}")
    reader.end()
    result = key(tag, scalars, children)
    require(stable(result) == value, "key re-encoding")
    return result


def typed_source(op, variant):
    width = 2 if op == "JOIN" else 1
    family = width, (("A",) * width,)
    ty = relation(family)
    leaves = []
    for i in range(3):
        ident = 0 if variant == "repeat" and i == 1 else i
        eclass = key("eclass", [str(ident)], [ty, CTX])
        invocation = key("invocation", children=[eclass, key("embedding", children=[CTX, CTX])])
        port = key("port/one", children=[key("schema/one", children=[ty]), CTX,
                    key("port-leaf/invocation", children=[invocation])])
        proof = key("dependent-chain-leaf-type-proof-v2", ["EXACT_RELATION", exact_type(width)], [ty, dag(family)])
        leaves.append((family, key("dependent-chain-leaf-v4", children=[port, proof, dag(family)])))

    def app(l, r):
        out, cases = combine(op, l[0], r[0])
        return out, key("dependent-chain-application-v3", [op], [CTX, relation(out), dag(out), l[1], r[1],
                key("dependent-chain-combination-cases-v1", children=cases)])
    return (app(leaves[0], app(leaves[1], leaves[2])) if variant == "right" else
            app(app(leaves[0], leaves[1]), leaves[2]))[1]


def occurrence(path, typed, c):
    return key("alloy-dependent-chain-source-occurrence-v1", [path], [
        key("alloy-dependent-chain-typed-source-v1", children=[typed]),
        key("alloy-dependent-chain-source-content-v1", [encode_content(c)])])


def shape(variant):
    return ((), ((), ())) if variant == "right" else (((), ()), ())


def path_entries(forest):
    entries = []

    def walk(tree, phase, children):
        entries.append((len(entries), phase, children))
        for i, child in enumerate(tree):
            walk(child, phase, (*children, i))
    for phase, tree in enumerate(forest):
        if tree is not None:
            walk(tree, phase, ())
    return entries


def path_string(phase, children):
    return f"phase/{phase}/matrix" + "".join(f"/child/{i}" for i in children)


def parse_paths(value):
    if not value:
        return []
    result = []
    for line in value.split("\n"):
        require(re.fullmatch(r"phase/(0|[1-9][0-9]*)/matrix(?:/child/(?:0|[1-9][0-9]*))*", line) is not None,
                "canonical occurrence path")
        parts = line.split("/")
        phase, children = int(parts[1]), tuple(int(v) for v in parts[4::2])
        require(phase < 10000 and len(children) < 128 and all(i < 10000 for i in children), "path bound")
        require(path_string(phase, children) == line, "path re-encoding")
        result.append((phase, children))
    return result


def path_term(paths):
    return "([" + ", ".join("⟨" + str(p) + ", [" + ", ".join(map(str, cs)) + "]⟩" for p, cs in paths) + "] : List Path)"


def expected_census():
    result = {}

    def add(fixture, field, kind, value):
        require((fixture, field) not in result, "duplicate verifier fixture")
        result[fixture, field] = kind, value
    for op in ("JOIN", "ARROW"):
        for variant in ("left", "right", "repeat"):
            f = f"{op}:{variant}"
            c, t = content(op, variant), typed_source(op, variant)
            path = "phase/0/matrix/child/0"
            add(f, "paths", "paths", [(shape(variant),)])
            add(f, "path", "text", path)
            add(f, "typed", "key", t)
            add(f, "content", "content", c)
            add(f, "repairContent", "content", c)
            add(f, "commitment", "key", occurrence(path, t, c))
            add(f, "certificate", "key", occurrence(path, t, c))
            add(f, "sourceTransfer", "content", content(op, variant, True))
            add(f, "repairTransfer", "content", content(op, variant, True))
            for field, value in (("lineage", "true"), ("separate", "true"), ("matches", "ACCEPT"),
                                 ("rename", FROZEN), ("children", FROZEN), ("type", FROZEN), ("projection", PROJECTION)):
                add(f, field, "text", value)
        for equal in (True, False):
            f = op + (":equal-occurrences" if equal else ":different-occurrences")
            add(f, "paths", "paths", [((shape("left"),), (shape("left"),))])
            for field, value in (("first", "phase/0/matrix/child/0/child/0"),
                    ("second", "phase/0/matrix/child/1/child/0"), ("sameContent", str(equal).lower()),
                    ("sameCommitment", "false"), ("swap", LINEAGE)):
                add(f, field, "text", value)
    for field, value in (
            ("child", "IllegalStateException:One certification node represents two source occurrences: "
             "phase/0/matrix/child/0/child/0 and phase/0/matrix/child/0/child/1"),
            ("phase", "IllegalStateException:One certification node represents two source occurrences: "
             "phase/0/matrix and phase/1/matrix"),
            ("empty", ""), ("cycle", "IllegalStateException:A certification source contains a recursive occurrence")):
        add("ownership", field, "text", value)
    for f, forest, binding_paths in (
            ("temporal", [(((((), ()),), ()),), ((((), ()),),)],
                ["phase/0/matrix/child/0/child/0/child/0", "phase/1/matrix/child/0/child/0"]),
            ("aci", [(((((), ()), ()),),)], ["phase/0/matrix/child/0/child/0"])):
        add(f, "phases", "text", str(len(forest)))
        add(f, "paths", "paths", forest)
        add(f, "bindings", "text", "\n".join(binding_paths))
        for i in range(len(binding_paths)):
            leaf = leaf_content("r", 2)
            source_leaf = leaf
            if f == "aci":
                source_leaf = ("leaf", "PLUS{" + PROFILE + ";" + exact_type(2) +
                    ";K>=1;COMMUTATIVE_IDEMPOTENT_SET;flat@0/0;ABSENT}:BOPEXPR_PLUS[" + leaf[1] + "@{},]")
            for field, kind, value in (
                    ("content", "content", app_content("JOIN", 2, source_leaf, leaf)),
                    ("repairContent", "content", app_content("JOIN", 2, leaf, leaf)),
                    ("sourceTransfer", "content", app_content("JOIN", 2, leaf_content("r", 2, True), leaf_content("r", 2, True))),
                    ("repairTransfer", "content", app_content("JOIN", 2, leaf_content("r", 2, True), leaf_content("r", 2, True))),
                    ("certifiedContent", "content", app_content("JOIN", 2, source_leaf, leaf)),
                    ("certifiedPath", "text", binding_paths[i]), ("typedMatches", "text", "true"),
                    ("lineage", "text", "true"), ("matches", "text", "ACCEPT")):
                add(f, f"{i}/{field}", kind, value)
        if f == "temporal":
            add(f, "swap", "text", LINEAGE)
            add(f, "phaseOrder", "text", PROJECTION)
    for op in ("JOIN", "ARROW"):
        for change in ("content", "association"):
            add("provenance", op + "/" + change, "text", TRANSFER)
    for i, name in enumerate(("a:{}[];@", "\u03b1", "\U0001d400", "e\u0301")):
        c = app_content("ARROW", 2, leaf_content(name, 1), leaf_content("b", 1))
        add("encoding", f"{i}/content", "content", c)
        add("encoding", f"{i}/wrapper", "wrapper", c)
    return result


def expected_value(spec):
    kind, value = spec
    if kind == "key":
        return stable(value)
    if kind == "content":
        return encode_content(value)
    if kind == "paths":
        return "\n".join(path_string(p, cs) for _, p, cs in path_entries(value))
    if kind == "wrapper":
        return stable(occurrence("phase/10/matrix/child/12", key("fixture", ["typed"]), value))
    return value


class Dictionary:
    """Intern structural subkeys; do not expand repeated long wire strings."""
    def __init__(self):
        self.definitions = []
        self.terms = {}

    def intern(self, value):
        if value not in self.terms:
            name = "v" + str(len(self.terms))
            self.terms[value] = name
            self.definitions.append(f"def {name} : Text := {value}")
        return self.terms[value]

    def text(self, s):
        # All fixture text is ASCII; JSON's Unicode escapes are not Lean escapes.
        if len(s) <= 80 and s.isascii() and all(ord(c) >= 32 or c in "\n\t" for c in s):
            return self.intern(f"{json.dumps(s)}.toList")
        return self.intern("ofCodepoints [" + ", ".join(str(ord(c)) for c in s) + "]")

    def key(self, k):
        tag, scalars, children = k
        t = self.text(tag)
        ss = ", ".join(self.text(s) for s in scalars)
        cs = ", ".join(self.key(c) for c in children)
        return self.intern(f"encodeKey {t} [{ss}] [{cs}]")

    def content(self, c):
        if c[0] == "leaf":
            return f"(.leaf {self.text(c[1])})"
        _, op, p, ty, ls, l, rs, r = c
        return f"(.app {self.text(op)} {self.text(p)} {self.text(ty)} {self.text(ls)} {self.content(l)} {self.text(rs)} {self.content(r)})"

    def forest(self, forest):
        counter = 0

        def walk(tree):
            nonlocal counter
            identity = counter
            counter += 1
            children = ", ".join(walk(child) for child in tree)
            return f"(.node {identity} [{children}])"
        return "[" + ", ".join("none" if tree is None else "some " + walk(tree) for tree in forest) + "]"

    def expected(self, spec):
        kind, value = spec
        if kind == "key":
            return self.key(value)
        if kind == "content":
            return self.content(value)
        if kind == "paths":
            return f"((traverse {self.forest(value)}).map Prod.snd)"
        if kind == "wrapper":
            return self.key(occurrence("phase/10/matrix/child/12", key("fixture", ["typed"]), value))
        return self.text(value)


def program(observed, extracted):
    validate_sources(extracted)
    expected = expected_census()
    require(len(expected) == 171 and len(observed) == len(expected), "observation census size")
    d, claims, path_proofs = Dictionary(), [], {}
    for row, ((fixture, field), spec) in zip(observed, expected.items()):
        require(set(row) == set(FIELDS), "observation schema")
        require((row["fixture"], row["field"]) == (fixture, field), "missing/duplicate/reordered/unknown observation")
        actual = decoded(row["value"])
        if spec[0] == "key":
            actual_term = d.key(parse_key(actual))
        elif spec[0] == "wrapper":
            actual_term = d.key(parse_utf16_key(actual))
        elif spec[0] == "content":
            actual_term = "(" + d.content(parse_content(actual)) + " : Content)"
        elif spec[0] == "paths":
            paths = parse_paths(actual)
            actual_term = path_term(paths)
            path_proofs[len(claims)] = ("by\n  simp only [traverse, List.zipIdx, List.flatMap, walk, walkChildren, "
                "List.map, childPath, rootPath] <;> decide +kernel")
        else:
            actual_term = d.text(actual)
        claims.append(f"{actual_term} = {d.expected(spec)}")
    for row in extracted:
        claims.append(f"{d.text(row['shapeSha256'] + ' ' + row['bindingsSha256'])} = {d.text(PINS[row['object']])}")
    for forest in ([None], [()], [((), ())], [None, ((),)]):
        fs = d.forest(forest)
        claims.append(f"index {fs} = some (traverse {fs})")
    claims.append("index [some (.node 0 [.node 1 [], .node 1 []])] = none")
    claims.append("index [some (.node 0 []), some (.node 0 [])] = none")
    # The ACI fixture uses distinct retained and repaired content, but the same
    # certified path, typed-source parameter and admitted transfer preimage.
    census = expected_census()
    c = d.content(census["aci", "0/content"][1])
    repair = d.content(census["aci", "0/repairContent"][1])
    transfer = d.text(expected_value(census["aci", "0/sourceTransfer"]))
    typed = d.text("supplied-typed-source")
    certified = f"(Commitment.mk ⟨0, [0, 0]⟩ {typed} {c})"
    current = f"(Commitment.mk ⟨0, [0, 0]⟩ {typed} {repair})"
    binding = f"(Binding.mk 1 {certified} {certified} {transfer})"
    transferred = f"(Binding.mk 1 {certified} {current} {transfer})"
    transition_start = len(claims)
    wrong_current = f"(Commitment.mk ⟨0, [0, 0]⟩ {typed} (.leaf []))"
    claims += [f"transferTo {binding} 1 {current} {transfer} = some {transferred}",
               f"checkMatches {transferred} 1 {current} {transfer} = true",
               f"checkMatches {transferred} 2 {current} {transfer} = false",
               f"checkMatches {transferred} 1 {wrong_current} {transfer} = false",
               f"checkMatches {transferred} 1 {current} {d.text('changed-transfer')} = false"]
    header = ["import SourceOccurrenceBindings", "namespace " + NAMESPACE,
              "open ACGN.FifthFive.Source", "set_option maxRecDepth 65536", "set_option maxHeartbeats 4000000"]
    proofs = {**path_proofs,
        transition_start: "by\n  unfold transferTo\n  exact if_pos ⟨rfl, rfl, rfl, rfl⟩",
        transition_start + 1: "by\n  apply (matches_iff _ _ _ _).2\n  exact ⟨rfl, rfl, rfl⟩",
        transition_start + 2: "by\n  apply wrong_lineage_rejected\n  decide +kernel",
        transition_start + 3: "by\n  apply changed_content_rejected\n  intro h\n  cases h",
    }
    body = [f"theorem observation{i} : {claim} := " + proofs.get(i, "by first | rfl | decide +kernel")
            + f"\n#print axioms observation{i}" for i, claim in enumerate(claims)]
    return "\n".join(header + d.definitions + body + ["end " + NAMESPACE]) + "\n", len(claims)


def generate(build, formal):
    source, count = program(rows(Path(build) / "source-occurrence-bindings.tsv", FIELDS),
                            rows(Path(build) / "source-occurrence-bindings-source.tsv", SOURCE_FIELDS))
    return [("SourceOccurrenceBindingsReplay.lean", source, count)]


def negatives(build, formal):
    observed = rows(Path(build) / "source-occurrence-bindings.tsv", FIELDS)
    extracted = rows(Path(build) / "source-occurrence-bindings-source.tsv", SOURCE_FIELDS)
    result = []
    targets = [("JOIN:left", field) for field in ("paths", "path", "typed", "content", "commitment", "certificate", "lineage", "rename")]
    targets += [("ARROW:equal-occurrences", "swap"), ("ownership", "phase"), ("temporal", "bindings"),
                ("temporal", "phaseOrder"), ("aci", "0/content"), ("aci", "0/repairTransfer"),
                ("provenance", "JOIN/association"), ("provenance", "ARROW/content")]
    for fixture, field in targets:
        changed = [dict(row) for row in observed]
        i = next(i for i, row in enumerate(changed) if (row["fixture"], row["field"]) == (fixture, field))
        kind = expected_census()[fixture, field][0]
        wrong = (stable(key("wrong")) if kind in ("key", "wrapper") else
                 encode_content(("leaf", "wrong")) if kind == "content" else
                 "phase/999/matrix" if kind == "paths" else "wrong")
        changed[i]["value"] = base64.b64encode(wrong.encode()).decode()
        full = program(changed, extracted)[0]
        header = full.split("theorem observation0 :", 1)[0]
        theorem = f"theorem observation{i} :" + full.split(f"theorem observation{i} :", 1)[1].split(f"#print axioms observation{i}", 1)[0]
        result.append((fixture.replace(":", "-") + "-" + field.replace("/", "-"),
                       "RejectSourceOccurrenceBindings.lean", header + theorem + "\nend " + NAMESPACE + "\n"))
    return result


def source_mutations():
    adapter = "src/is/fivefivefive/CanDis/theory/TheoryAlloyAdapter.java"
    core = "src/is/fivefivefive/CanDis/core/EGraphNode.java"
    normal = "src/is/fivefivefive/CanDis/core/NormalForm.java"
    specs = [
        ("phase-path", adapter, '"phase/" + phase + "/matrix"', '"phase/" + 0 + "/matrix"'),
        ("child-path", adapter, 'path + "/child/" + index', 'path + "/child/" + 0'),
        ("ownership", adapter, 'if (!prior.equals(path))', 'if (false)'),
        ("cycle", adapter, 'if (!active.add(node))', 'if (false)'),
        ("lineage", adapter, 'if (source.getSourceOccurrenceLineage() != sourceOccurrenceLineage)', 'if (false)'),
        ("repair-match", adapter, 'if (!boundRepairOccurrenceCommitment.equals(current)', 'if (false'),
        ("transfer", adapter, 'if (!transferContentCommitment.equals(repairTransferContent))', 'if (false)'),
        ("occurrence-tag", adapter, '"alloy-dependent-chain-source-occurrence-v1"', '"alloy-dependent-chain-source-occurrence-v0"'),
        ("typed-tag", adapter, '"alloy-dependent-chain-typed-source-v1"', '"alloy-dependent-chain-typed-source-v0"'),
        ("content-tag", adapter, '"alloy-dependent-chain-source-content-v1"', '"alloy-dependent-chain-source-content-v0"'),
        ("content-length", core, "output.append(value.length()).append(':').append(value);", "output.append(0).append(':').append(value);"),
        ("content-leaf", core, 'appendLengthEncoded(output, node.sortKey());', 'appendLengthEncoded(output, "leaf");'),
        ("content-association", core, 'appendDependentChainSourceContent(\n                        childRef.getEClass().getRepresentative(),', 'appendDependentChainSourceContent(\n                        node.childClasses.get(0).getEClass().getRepresentative(),'),
        ("content-profile", core, 'appendLengthEncoded(output, node.semanticProfile.fingerprint());\n            appendLengthEncoded(output, node.exactAlloyType == null\n                    ? "" : node.exactAlloyType.stableString());\n            for (EClassRef childRef : node.childClasses) {\n                appendLengthEncoded(\n                        output,\n                        new java.util.TreeMap<>(childRef.getSlotMap()).toString());\n                appendDependentChainSourceContent(', 'appendLengthEncoded(output, "profile");\n            appendLengthEncoded(output, node.exactAlloyType == null\n                    ? "" : node.exactAlloyType.stableString());\n            for (EClassRef childRef : node.childClasses) {\n                appendLengthEncoded(\n                        output,\n                        new java.util.TreeMap<>(childRef.getSlotMap()).toString());\n                appendDependentChainSourceContent('),
        ("freeze", core, 'if (frozenCertificationSources.contains(source))', 'if (false)'),
        ("retained-source", normal, 'return certificationMatrixEGraphRoot == null\n                    ? matrixEGraphRoot : certificationMatrixEGraphRoot;', 'return matrixEGraphRoot;'),
    ]
    return [(*spec, "SourceOccurrenceBindingsExtractor") for spec in specs]
