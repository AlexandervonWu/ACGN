"""Bounded P3-12 census and structural replay encoder; tested, explicit TCB.

SHA256 is computed by hashlib, not proved injective. The four source pins are
frozen javac-resolved syntax/bindings, not a whole-JVM refinement theorem.
"""

import base64
import binascii
import hashlib
from pathlib import Path
import re
import struct
from typing import NamedTuple

from next_obligation_replays import rows
from run_submission_container_closure import Blocked

FIELDS = "case surface fixture mutation input output preimage id outcome exact order".split()
SOURCE_FIELDS = "object owner shapeSha256 bindingsSha256".split()
SOURCES = {
    "Bundle": ("org.acgn.cert.Bundle", "ff78efef7d57a6ddc37bc35609a758d3ae1d5c7b453f75ae1851540d8dc11131", "6d2831b66e4cb1a1741ae5a8131914dad3c9ac1f3da953d36fb6bc67f0851e88"),
    "CertificateBundleWriter": ("is.fivefivefive.CanDis.theory.CertificateBundleWriter", "94c4ab8b81db73094f3dbf1987660fa2e662af108973b5c78dca58b82d213aa6", "880ff160e6040325eccf17d41bba699294ab06e13ee57a3d29ee188dae88566a"),
    "Codec": ("org.acgn.cert.Codec", "c0869254cca18a781b4952ae50e4c752d015f3734347dc877c2d60f62bafb1ec", "099694a8e4863290df0dbe1ef62e69237d728b92d2cfef1c5826cc5c28b1d77b"),
    "Wire": ("org.acgn.cert.Wire", "5f62baead2c72f173aad5319a4c84a46d5e757f91c1b973e021e37b707a37e84", "46015d7ca07b6ba13eb1b1fdebccb382f7492ee90d2827d9539bdde8853ad86e"),
}
TABLES = tuple(zip(
    ("contexts", "embeddings", "terms", "proofs", "witnesses", "snapshots", "canonical-records", "unfoldings"),
    ("context", "embedding", "term", "proof", "witness", "snapshot", "canonical-record", "unfolding")))
MUTATIONS = ("empty", "sorted", "duplicate", "reverse", "separated-duplicate", "section-scalars", "record-tag",
             "missing-id", "empty-id", "stale-scalar", "rehashed-scalar", "stale-child", "rehashed-child",
             "rehashed-tag", "rehashed-child-order")
TEXTS = ("", "a", "a:1\0b", "\u03b1\u4e2d", "\U0001f600", "e\u0301", "\n\t\"\\")
OUTCOMES = {"ACCEPT", "INVALID_RECORD_SHAPE", "UNKNOWN_VARIANT", "DUPLICATE_ID", "NONCANONICAL_ENCODING", "CONTENT_ID_MISMATCH",
            "TRUNCATED_INPUT", "TRAILING_BYTES", "INTEGER_OVERFLOW", "INVALID_UTF8"}
RESULT = {"ACCEPT": "accept", "INVALID_RECORD_SHAPE": "shape", "UNKNOWN_VARIANT": "shape", "DUPLICATE_ID": "duplicate",
          "NONCANONICAL_ENCODING": "order", "CONTENT_ID_MISMATCH": "contentMismatch"}


class Node(NamedTuple):
    tag: str
    scalars: tuple = ()
    children: tuple = ()


def frame(text):
    raw = text.encode("utf-8")
    return struct.pack(">I", len(raw)) + raw


def encode(n):
    return (frame(n.tag) + struct.pack(">I", len(n.scalars)) + b"".join(map(frame, n.scalars))
            + struct.pack(">I", len(n.children)) + b"".join(map(encode, n.children)))


def content(n):
    return Node(n.tag + "/content", n.scalars[1:], n.children)


def identify(n):
    preimage = encode(Node(n.tag + "/content", n.scalars, n.children))
    return Node(n.tag, (hashlib.sha256(preimage).hexdigest(), *n.scalars), n.children)


def decoded(text):
    if not isinstance(text, str) or len(text) > 32768:
        raise Blocked("wire bytes exceed finite bound")
    try:
        raw = base64.b64decode(text, validate=True)
    except (ValueError, binascii.Error) as error:
        raise Blocked("invalid wire Base64") from error
    if base64.b64encode(raw).decode("ascii") != text:
        raise Blocked("noncanonical wire Base64")
    return raw


def parse_node(raw):
    """Independent bounded parser used only to validate encoder fixtures/tests."""
    def u32(offset):
        if offset + 4 > len(raw):
            raise ValueError("truncated")
        n = struct.unpack_from(">i", raw, offset)[0]
        if n < 0 or n > 32768:
            raise ValueError("length")
        return n, offset + 4

    def text(offset):
        size, offset = u32(offset)
        if offset + size > len(raw):
            raise ValueError("truncated")
        return raw[offset:offset + size].decode("utf-8"), offset + size

    def node(offset, depth):
        if depth > 32:
            raise ValueError("depth")
        tag, offset = text(offset)
        if not tag:
            raise ValueError("tag")
        ns, offset = u32(offset)
        scalars = []
        for _ in range(ns):
            value, offset = text(offset)
            scalars.append(value)
        nc, offset = u32(offset)
        children = []
        for _ in range(nc):
            child, offset = node(offset, depth + 1)
            children.append(child)
        return Node(tag, tuple(scalars), tuple(children)), offset

    n, end = node(0, 0)
    if end != len(raw) or encode(n) != raw:
        raise ValueError("trailing/noncanonical")
    return n


def record(tag, text):
    return identify(Node(tag, (text,), (Node("left", ("x",)), Node("right", ("y",)))))


def table_case(section, tag, mutation):
    a, b = record(tag, "alpha"), record(tag, "beta")
    ordered = tuple(sorted((a, b), key=lambda n: n.scalars[0]))
    children, scalars, changed = (a,), (), a
    if mutation == "empty": children = ()
    elif mutation == "sorted": children = ordered
    elif mutation == "duplicate": children = (a, a)
    elif mutation == "reverse": children = tuple(reversed(ordered))
    elif mutation == "separated-duplicate": children = (*ordered, ordered[0])
    elif mutation == "section-scalars": scalars = ("unexpected",)
    elif mutation == "record-tag": changed = a._replace(tag="wrong")
    elif mutation == "missing-id": changed = a._replace(scalars=())
    elif mutation == "empty-id": changed = a._replace(scalars=("", "alpha"))
    elif mutation in ("stale-scalar", "rehashed-scalar"):
        changed = a._replace(scalars=(a.scalars[0], "changed"))
    elif mutation in ("stale-child", "rehashed-child"):
        changed = a._replace(children=(Node("left", ("changed",)), a.children[1]))
    elif mutation == "rehashed-tag": changed = a._replace(tag="wrong")
    elif mutation == "rehashed-child-order": changed = a._replace(children=tuple(reversed(a.children)))
    elif mutation in ("named-order", "named-reverse"):
        children = (r1 := Node(tag, ("\U00010000", "alpha")), r2 := Node(tag, ("\ue000", "beta")))
        if mutation == "named-reverse": children = (r2, r1)
    else: raise AssertionError(mutation)
    if mutation.startswith("rehashed"):
        changed = identify(changed._replace(scalars=changed.scalars[1:]))
    if changed != a:
        children = (changed,)
    outcome = ("DUPLICATE_ID" if mutation == "duplicate" else
               "NONCANONICAL_ENCODING" if mutation in ("reverse", "separated-duplicate", "named-reverse") else
               "UNKNOWN_VARIANT" if mutation in ("record-tag", "rehashed-tag") else
               "INVALID_RECORD_SHAPE" if mutation in ("section-scalars", "missing-id", "empty-id") else
               "CONTENT_ID_MISMATCH" if mutation.startswith("stale") and section != "witnesses" else "ACCEPT")
    return Node(section, scalars, children), outcome, bool(changed.scalars) and content(a) == content(changed)


def grammar_cases():
    good = encode(Node("t", ("a",)))
    result = [("valid", good, "ACCEPT"), ("truncated", good[:-1], "TRUNCATED_INPUT"),
              ("trailing", good + b"\0", "TRAILING_BYTES")]
    for label, offset in (("negative-tag-length", 0), ("negative-scalar-count", 5),
                          ("negative-string-length", 9), ("negative-child-count", 14)):
        result.append((label, good[:offset] + b"\xff" * 4 + good[offset + 4:], "INTEGER_OVERFLOW"))
    for hextext in ("80", "c080", "eda080", "f4908080", "f09f98", "f09f9880"):
        text = bytes.fromhex(hextext)
        raw = frame("t") + struct.pack(">II", 1, len(text)) + text + struct.pack(">I", 0)
        result.append(("utf8-" + hextext, raw, "ACCEPT" if hextext == "f09f9880" else "INVALID_UTF8"))
    return result


def census():
    """Fixed before observations; never derive keys, counts, or outcomes from TSV."""
    result = {}
    for count in (1, 3):
        n = identify(Node("context"))
        result["writer", str(count), "base"] = (n, "ACCEPT", True, "|".join(sorted(f"e{i}" for i in range(count))))
    for section, tag in TABLES:
        for mutation in MUTATIONS if section in ("terms", "witnesses") else ("empty", "sorted"):
            result["table", section, mutation] = (*table_case(section, tag, mutation), "")
        if section == "witnesses":
            for mutation in ("named-order", "named-reverse"):
                result["table", section, mutation] = (*table_case(section, tag, mutation), "")
    for i, text in enumerate(TEXTS):
        result["content", str(i), "base"] = (identify(Node("term", (text, "tail"), (Node("child", ("x",)),))), "ACCEPT", True, "")
    for label, raw, outcome in grammar_cases():
        result["grammar", label, "base"] = (raw, outcome, None, "")
    return result


def validate_sources(extracted):
    if len(extracted) != 4 or [r.get("object") for r in extracted] != sorted(SOURCES):
        raise Blocked("incomplete/duplicate/reordered wire source census")
    for row in extracted:
        if set(row) != set(SOURCE_FIELDS) or tuple(row[k] for k in SOURCE_FIELDS[1:]) != SOURCES[row["object"]]:
            raise Blocked("unregistered wire source pin")


class Dictionary:
    def __init__(self):
        self.defs, self.bytes, self.nodes = [], {}, {}

    def byte_ref(self, value):
        if isinstance(value, str): value = value.encode("utf-8")
        if value not in self.bytes:
            name = "b" + str(len(self.bytes))
            self.bytes[value] = name
            self.defs.append(f"def {name} : Bytes := [" + ", ".join(map(str, value)) + "]")
        return self.bytes[value]

    def node_ref(self, n):
        if n not in self.nodes:
            tag = self.byte_ref(n.tag)
            scalars = "[" + ", ".join(self.byte_ref(s) for s in n.scalars) + "]"
            children = "[" + ", ".join(self.node_ref(c) for c in n.children) + "]"
            name = "n" + str(len(self.nodes))
            self.nodes[n] = name
            self.defs.append(f"def {name} : Node := .mk {tag} {scalars} {children}")
        return self.nodes[n]


def program(observed, extracted):
    validate_sources(extracted)
    expected = census()
    if len(expected) != 66 or len(observed) != 66:
        raise Blocked("incomplete wire observation census")
    d, theorems = Dictionary(), []
    # A finite SHA256 interpretation computed independently in Python. This is
    # explicit trusted data for the replay, not a Lean implementation of SHA256.
    digests = {}
    for (surface, _, _), (n, _, _, _) in expected.items():
        if surface in ("writer", "content"):
            digests[encode(content(n))] = hashlib.sha256(encode(content(n))).hexdigest()
        if surface == "table":
            for child in n.children:
                if child.scalars:
                    digests[encode(content(child))] = hashlib.sha256(encode(content(child))).hexdigest()
    digest_defs = "\n".join(f"  if bytes == {d.byte_ref(raw)} then {d.byte_ref(digest)} else" for raw, digest in digests.items())
    for i, (row, (key, spec)) in enumerate(zip(observed, expected.items())):
        if set(row) != set(FIELDS) or row["case"] != str(i) or tuple(row[k] for k in ("surface", "fixture", "mutation")) != key:
            raise Blocked("unregistered/duplicate/reordered wire observation")
        n, outcome, exact, order = spec
        raw = n if isinstance(n, bytes) else encode(n)
        if decoded(row["input"]) != raw:
            raise Blocked("wire fixture input changed")
        if row["outcome"] not in OUTCOMES or row["exact"] not in ("true", "false", "-"):
            raise Blocked("unregistered wire outcome/evidence state")
        actual_result = d.byte_ref(row["outcome"])
        checks = [f"{actual_result} = {d.byte_ref(outcome)}",
                  f"{d.byte_ref(row['exact'])} = {d.byte_ref('-' if exact is None else str(exact).lower())}",
                  f"{d.byte_ref(decoded(row['order']))} = {d.byte_ref(order)}"]
        if row["output"] == "-":
            checks.append(f"{str(outcome != 'ACCEPT').lower()} = true")
        else:
            checks += [f"{str(outcome == 'ACCEPT').lower()} = true",
                       f"{d.byte_ref(decoded(row['output']))} = {d.byte_ref(raw)}"]
        if key[0] != "grammar":
            ref = d.node_ref(n)
            checks += [f"encode {ref} = {d.byte_ref(raw)}", f"grammar {ref} = true"]
            checks.append(f"(decode 32 {d.byte_ref(raw)}).map encode = some {d.byte_ref(raw)}")
            if key[0] == "table":
                tag = dict(TABLES)[key[1]]
                checks.append(f"indexedTable sha256Observed {d.byte_ref(key[1])} {d.byte_ref(tag)} "
                              f"{str(key[1] != 'witnesses').lower()} {ref} = .{RESULT[outcome]}")
                baseline = record(tag, "alpha")
                if key[2] not in ("empty", "sorted", "duplicate", "reverse", "separated-duplicate", "named-order", "named-reverse"):
                    child = n.children[0]
                    if child.scalars:
                        checks.append(f"claimedContent {d.node_ref(baseline)} {d.node_ref(child)} = {str(exact).lower()}")
            else:
                if not re.fullmatch("[0-9a-f]{64}", row["id"]):
                    raise Blocked("noncanonical observed wire digest")
                checks += [f"preimage {ref} = {d.byte_ref(decoded(row['preimage']))}",
                           f"{d.byte_ref(row['id'])} = sha256Observed (preimage {ref})",
                           f"recordId {ref} = {d.byte_ref(row['id'])}"]
                if key[0] == "writer":
                    ids = [f"e{j}" for j in range(int(key[1]))]
                    projected = [Node("class", (ident,)) for ident in ids]
                    checks.append(f"encode (sortedSection {d.byte_ref('classes')} [" +
                                  ", ".join(d.node_ref(x) for x in projected) + "]) = encode " +
                                  d.node_ref(Node("classes", (), tuple(sorted(projected, key=lambda x: x.scalars[0])))))
        else:
            checks.append(f"(decode 32 {d.byte_ref(raw)}).isSome = {str(outcome == 'ACCEPT').lower()}")
        if key[0] not in ("writer", "content") and (row["id"] != "-" or row["preimage"] != "-"):
            raise Blocked("invented wire preimage/id observation")
        proof = "by\n  refine ⟨" + ", ".join("?_" for _ in checks) + "⟩\n" + "\n".join("  · decide +kernel" for _ in checks)
        theorems.append(f"theorem observation{i} : " + " ∧\n    ".join(checks) + " := " + proof +
                        f"\n#print axioms observation{i}")
    header = ["import CanonicalWireTables", "namespace ACGN.FifthFive.WireReplay",
              "open ACGN.FifthFive.CanonicalWireTables", "set_option maxRecDepth 8192", "set_option maxHeartbeats 2000000"]
    return "\n".join(header + d.defs + ["def sha256Observed (bytes : Bytes) : Bytes :=\n" + digest_defs + "\n  []"] +
                     theorems + ["end ACGN.FifthFive.WireReplay", ""]), len(theorems)


def generate(build, formal):
    code, count = program(rows(Path(build) / "canonical-wire-tables.tsv", FIELDS),
                          rows(Path(build) / "canonical-wire-tables-source.tsv", SOURCE_FIELDS))
    return [("CanonicalWireTablesReplay.lean", code, count)]


def negatives(build, formal):
    observed = rows(Path(build) / "canonical-wire-tables.tsv", FIELDS)
    sources = rows(Path(build) / "canonical-wire-tables-source.tsv", SOURCE_FIELDS)
    targets = [(0, "output", base64.b64encode(b"wrong").decode()),
               (0, "preimage", base64.b64encode(b"wrong").decode()), (0, "id", "0" * 64),
               (1, "order", base64.b64encode(b"e2|e1|e0").decode())]
    for mutation in ("duplicate", "reverse", "missing-id", "stale-scalar", "rehashed-scalar", "rehashed-child", "rehashed-child-order"):
        i = next(i for i, r in enumerate(observed) if r["fixture"] == "terms" and r["mutation"] == mutation)
        targets.append((i, "exact" if mutation.startswith("rehashed") else "outcome", "true" if mutation.startswith("rehashed") else "ACCEPT"))
    i = next(i for i, r in enumerate(observed) if r["fixture"] == "utf8-eda080")
    targets.append((i, "outcome", "ACCEPT"))
    i = next(i for i, r in enumerate(observed) if r["mutation"] == "named-reverse")
    targets.append((i, "outcome", "ACCEPT"))
    result = []
    for k, (i, field, value) in enumerate(targets):
        changed = [dict(r) for r in observed]
        changed[i][field] = value
        code = program(changed, sources)[0]
        header = code.split("theorem observation0 :", 1)[0]
        theorem = f"theorem observation{i} :" + code.split(f"theorem observation{i} :", 1)[1].split(f"#print axioms observation{i}", 1)[0]
        result.append((f"wire-{k}-{field}", "RejectCanonicalWireTables.lean", header + theorem + "\nend ACGN.FifthFive.WireReplay\n"))
    return result


def source_mutations():
    writer = "src/is/fivefivefive/CanDis/theory/CertificateBundleWriter.java"
    bundle = "certificate-verifier/src/org/acgn/cert/Bundle.java"
    codec = "certificate-verifier/src/org/acgn/cert/Codec.java"
    wire = "certificate-verifier/src/org/acgn/cert/Wire.java"
    specs = [
        ("writer-sort", writer, "sorted.sort(Comparator.comparing(value -> scalar(value, 0)));", "sorted.sort(Comparator.comparing((Node value) -> scalar(value, 0)).reversed());"),
        ("writer-preimage-tag", writer, 'tag + "/content",', 'tag + "/changed",'),
        ("writer-preimage-scalars", writer, "provisional.scalars.subList(1, provisional.scalars.size())", "provisional.scalars.subList(0, provisional.scalars.size())"),
        ("writer-byte-length", writer, "output.writeInt(encoded.length);", "output.writeInt(value.length());"),
        ("bundle-order", bundle, "prior.compareTo(id) >= 0", "prior.compareTo(id) <= 0"),
        ("bundle-empty-id", bundle, "if (id.isEmpty())", "if (false)"),
        ("bundle-content-check", bundle, "if (contentAddressed && !id.equals(contentId(record)))", "if (false)"),
        ("bundle-content-children", bundle, "identifiedRecord.children());", "List.of());"),
        ("bundle-witness-policy", bundle, '"witnesses", "witness", false', '"witnesses", "witness", true'),
        ("codec-byte-length", codec, "output.writeInt(encoded.length);", "output.writeInt(value.length());"),
        ("codec-utf8", codec, ".onMalformedInput(CodingErrorAction.REPORT)", ".onMalformedInput(CodingErrorAction.REPLACE)"),
        ("wire-sha", wire, 'MessageDigest.getInstance("SHA-256")', 'MessageDigest.getInstance("SHA-1")'),
    ]
    # Disambiguate the decoder UTF8 site from the encoder's same setting.
    specs[10] = ("codec-utf8", codec, "StandardCharsets.UTF_8.newDecoder()\n                    .onMalformedInput(CodingErrorAction.REPORT)",
                 "StandardCharsets.UTF_8.newDecoder()\n                    .onMalformedInput(CodingErrorAction.REPLACE)")
    return [(*spec, "CanonicalWireTablesExtractor") for spec in specs]
