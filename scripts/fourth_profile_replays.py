"""Bounded P3-03 plugin. The census is independent of Java observations.

This encoder is tested TCB, not a whole-JVM or parser refinement theorem.
"""

import base64
import binascii
import hashlib
from pathlib import Path
import re

from next_obligation_replays import rows
from run_submission_container_closure import Blocked

FIELDS = ("case surface fixture mutation authority testOnly bitwidth overflow temporal rewrite signature digest "
          "producerKey independentKey writer outcome detail").split()
SOURCE_FIELDS = "object owner shapeSha256 bindingsSha256".split()
P = "is.fivefivefive.CanDis.theory."
SOURCES = {
    "AlloySemanticProfileFactory": (P + "AlloySemanticProfileFactory", "d9821e2209abefbbc39e5ca2ef3b44fb82a0720b0f89c824b5bde13b28bdafc2", "9f2bb6130489dc740ba241f4811186be27d0ba8526300b0df2b7c6e2e3703818"),
    "CertificateBundleWriter": (P + "CertificateBundleWriter", "94c4ab8b81db73094f3dbf1987660fa2e662af108973b5c78dca58b82d213aa6", "880ff160e6040325eccf17d41bba699294ab06e13ee57a3d29ee188dae88566a"),
    "Codec": ("org.acgn.cert.Codec", "c0869254cca18a781b4952ae50e4c752d015f3734347dc877c2d60f62bafb1ec", "099694a8e4863290df0dbe1ef62e69237d728b92d2cfef1c5826cc5c28b1d77b"),
    "SemanticEvidenceVerifier": ("org.acgn.cert.SemanticEvidenceVerifier", "c91040e65f45bfc520051f2ccdba9aa6a609e01c0d597eba731fd613f65743da", "cd2fe91218d45a6eaebc03233f04d8119c8a23064ab520a3f7657e3ee54755cd"),
    "SemanticProfile": (P + "SemanticProfile", "1b9144c54170bcd98528f79b4432cb1203057dc2ee1b7fedc0d55c2223120492", "3bb8166269c04aa1cb967873088cfdeaefc3bafdbc3399c01122f12e1b99334b"),
    "StructuralKey": (P + "StructuralKey", "62183e7e02a6c3cb416290405dea37ea44a00d9cfe662b74e1c04ccc7e91ba96", "63f1e1524ff3c28e48a3991dccdbeeee7e9319f5b5bf47dc03523bfd8392386f"),
    "Wire": ("org.acgn.cert.Wire", "5f62baead2c72f173aad5319a4c84a46d5e757f91c1b973e021e37b707a37e84", "46015d7ca07b6ba13eb1b1fdebccb382f7492ee90d2827d9539bdde8853ad86e"),
}
TEXTS = ["plain", "[]{}:012", 'quote"slash\\', "line\nnext\tcell", "\u03b1\u4e2d", "\U0001f600", "e\u0301", "x\0y"]
REWRITE = "repaired-normal-form-v3;typed-alloy-normal-form-adapter-v13"
SIGNATURE = "canonical-alloy-signature-v8"
REGISTRY = "alloy-container-law-theory-v3"
REGISTRY_DIGEST = "b6479712e518b5dfc13f19866769f30ab81b49bd4bad508a175691fbb1d0633f"
CONTEXT_VERSION = "alloy-command-options-v4-independent-search-domain"
VERSION_CONTROLS = {"version-old": "alloy-command-options-v2", "version-future": "alloy-command-options-v5"}
MUTATIONS = ["base", *[f"stale-{i}" for i in range(5)], *[f"rehashed-{i}" for i in range(5)],
             "digest", "registry-version", "registry-digest", "publication"]


def utf16_length(value):
    return len(value.encode("utf-16-be")) // 2


def stable(tag, scalars, children=()):
    def frame(s):
        return f"{utf16_length(s)}:{s}"
    return frame(tag) + f"[{len(scalars)}:" + "".join(map(frame, scalars)) + "]{" + str(len(children)) + ":" + "".join(map(frame, children)) + "}"


def profile_key(fields):
    return stable("semantic-profile", fields)


def sha(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def decoded(value):
    if not isinstance(value, str) or len(value) > 16384:
        raise Blocked("profile string exceeds finite bound")
    try:
        raw = base64.b64decode(value, validate=True)
        result = raw.decode("utf-8")
    except (ValueError, UnicodeError, binascii.Error) as error:
        raise Blocked("invalid profile Base64/UTF8") from error
    if base64.b64encode(raw).decode("ascii") != value:
        raise Blocked("noncanonical profile Base64")
    return result


def text(value):
    # The kernel checks exact scalar sequences, including NUL and supplementary
    # Unicode, without repeatedly packing long source contexts into UTF-8.
    return "(ofCodepoints [" + ", ".join(str(ord(c)) for c in value) + "])"


def strings(values):
    return "[" + ", ".join(map(text, values)) + "]"


def source_fields(width, mode, version=CONTEXT_VERSION):
    context = stable("alloy-source-command-context-v1", [
        version, "wire", "AND[some this/A]", "false", "3",
        str(width), "-1", "-1", "-1", "-1", "-1"], [
        stable("scopes", []), stable("additional-exact-scopes", []),
        stable("execution-options", ["true", "20", "0", "2", "0", "sat4j",
                                     "true" if mode == "FORBID" else "false", "-1", "0", "4"])])
    return [str(width), mode, context, REWRITE, SIGNATURE]


def census():
    result = {}
    for width in (0, 4, 30):
        for mode in ("FORBID", "MODULAR"):
            for variant in range(22):
                fields = [str(width), mode, "plain", "plain", "plain"]
                if variant:
                    fields[2 + (variant - 1) // 7] = TEXTS[1 + (variant - 1) % 7]
                result["serialization", f"{width}:{mode}:{variant}", "base"] = (fields, "custom", fields)
    for mode in ("FORBID", "MODULAR"):
        profiles = [(f"fixed:{mode}", "compatibility", ["4", mode, "alloy-temporal", "repaired-normal-form-v2", "alloy-signature-v2"])]
        profiles += [(f"source:{w}:{mode}", "source", source_fields(w, mode)) for w in (3, 4, 6)]
        for fixture, authority, original in profiles:
            for mutation in MUTATIONS + (list(VERSION_CONTROLS) if authority == "source" else []):
                fields = list(original)
                if mutation.startswith(("stale-", "rehashed-")):
                    i = int(mutation[-1])
                    fields[i] = str(int(fields[0]) + 1) if i == 0 else (
                        "MODULAR" if fields[1] == "FORBID" else "FORBID") if i == 1 else fields[i] + ":changed"
                if mutation in VERSION_CONTROLS:
                    fields = source_fields(int(original[0]), mode, VERSION_CONTROLS[mutation])
                result["boundary", fixture, mutation] = (fields, authority, original)
            result["clone", fixture, "same-spelling"] = (original, "custom", original)
    return result


def expected_outcome(surface, authority, mutation):
    if surface == "serialization":
        return "UNEXPORTED", ""
    if surface == "clone":
        return "AUTHORITY_REJECT", ""
    fixed = authority == "compatibility"
    fixed_error = "Fixed compatibility profiles are authorized only for TEST_ONLY evidence"
    version_error = "Source-command evidence names unsupported semantic implementation versions"
    digest_error = "Semantic-profile fingerprint does not match its five-scalar profile"
    if mutation in VERSION_CONTROLS:
        return "THEORY_MISMATCH", "Source-command semantic context has an unsupported version"
    if mutation.startswith(("stale-", "rehashed-")):
        i = int(mutation[-1])
        if fixed:
            if i == 1:
                return ("ACCEPT", "kernel profile independently verified") if mutation.startswith("rehashed-") else ("DIGEST_MISMATCH", digest_error)
            return "THEORY_MISMATCH", version_error if i == 2 else fixed_error
        if i == 2:
            return "INVALID_RECORD_SHAPE", "source-command semantic context has trailing structural-key data"
        return "THEORY_MISMATCH", ("Source-command context and profile bitwidth disagree" if i == 0 else
                                   "Source-command context and overflow mode disagree" if i == 1 else version_error)
    if mutation == "publication" and fixed:
        return "THEORY_MISMATCH", fixed_error
    if mutation == "publication":
        return "MISSING_EVIDENCE", ("operator operator/0190b3c27d2deb75d870c7322fc691c1acd4d01a1c4c66e4aaadb115c4c4ad78 "
                                    "output has no exact structural type for Bool")
    if mutation == "digest":
        return "DIGEST_MISMATCH", digest_error
    if mutation == "registry-version":
        return "THEORY_MISMATCH", "Semantic evidence names an unknown Alloy law registry"
    if mutation == "registry-digest":
        return "DIGEST_MISMATCH", "Alloy law-registry digest does not match the fixed v2 source text"
    return "ACCEPT", "kernel profile independently verified"


def validate_sources(extracted):
    if len(extracted) != len(SOURCES) or [r.get("object") for r in extracted] != sorted(SOURCES):
        raise Blocked("incomplete/duplicate/reordered profile source census")
    for row in extracted:
        if set(row) != set(SOURCE_FIELDS) or tuple(row[k] for k in SOURCE_FIELDS[1:]) != SOURCES[row["object"]]:
            raise Blocked("unregistered profile source pin")


def program(observed, extracted):
    validate_sources(extracted)
    expected = census()
    if len(expected) != 272 or len(observed) != len(expected):
        raise Blocked("incomplete profile observation census")
    output = ["import SemanticProfileWire", "namespace ACGN.FourthFive.ProfileReplay",
              "open ACGN.FourthFive.SemanticProfileWire", "set_option maxRecDepth 8192",
              "set_option maxHeartbeats 2000000"]
    for i, (row, (key, spec)) in enumerate(zip(observed, expected.items())):
        if set(row) != set(FIELDS) or row["case"] != str(i) or tuple(row[k] for k in ("surface", "fixture", "mutation")) != key:
            raise Blocked("unregistered/duplicate/reordered profile observation")
        fields, authority, original = spec
        actual = [row["bitwidth"], row["overflow"], *(decoded(row[k]) for k in ("temporal", "rewrite", "signature"))]
        test_only = key[0] != "serialization" and key[2] != "publication"
        if actual != fields or row["authority"] != authority or row["testOnly"] != str(test_only).lower():
            raise Blocked("profile fixture/authority/field mutation changed")
        if row["outcome"] not in {"UNEXPORTED", "AUTHORITY_REJECT", "ACCEPT", "THEORY_MISMATCH", "DIGEST_MISMATCH", "INVALID_RECORD_SHAPE", "MISSING_EVIDENCE"}:
            raise Blocked("unregistered profile verifier stage")
        if not re.fullmatch("[0-9a-f]{64}", row["digest"]):
            raise Blocked("noncanonical profile digest")
        expected_digest = sha(profile_key(fields if key[2].startswith("rehashed-") or key[2] in VERSION_CONTROLS else original))
        if key[2] == "digest":
            expected_digest = "0" * 64
        p = "(Profile.mk " + " ".join(map(text, fields)) + ")"
        outcome, detail = expected_outcome(key[0], authority, key[2])
        checks = [f"encode {p} = {text(decoded(row['producerKey']))}",
                  f"{text(decoded(row['producerKey']))} = {text(decoded(row['independentKey']))}"]
        checks += [f"verifierEncoding {strings(fields)} = some (encode {p})",
                   f"reconstruct {strings(fields)} = some {p}",
                   f"{text(row['digest'])} = {text(expected_digest)}",
                   f"{text(row['outcome'])} = {text(outcome)}", f"{text(decoded(row['detail']))} = {text(detail)}"]
        if key[0] == "serialization":
            if row["writer"] != "-":
                raise Blocked("invented custom writer output")
        else:
            packed = row["writer"].split("|")
            if len(packed) != 8:
                raise Blocked("writer scalar arity changed")
            written = list(map(decoded, packed))
            checks.append(f"({strings(written)} : List Text) = {strings(original + [sha(profile_key(original)), REGISTRY, REGISTRY_DIGEST])}")
            if key[2].startswith(("stale-", "rehashed-")) or key[2] in VERSION_CONTROLS:
                original_p = "(Profile.mk " + " ".join(map(text, original)) + ")"
                checks.append(f"exact {original_p} {strings(fields)} = false")
            if key[1].startswith("source:"):
                version = VERSION_CONTROLS.get(key[2], CONTEXT_VERSION)
                checks.append(f"contextVersionAllowed {text(version)} = {str(key[2] not in VERSION_CONTROLS).lower()}")
        checks.append(f"exportAllowed .{authority} {str(test_only).lower()} = "
                      + str(authority == "source" or authority == "compatibility" and test_only).lower())
        # Reuse the general reconstruction lemmas instead of repeatedly reducing
        # the long source-context encoding inside one giant decision procedure.
        proof = ["by", "  refine ⟨" + ", ".join("?_" for _ in checks) + "⟩"]
        for j, check in enumerate(checks):
            if j == 0:
                proof.append("  · decide +kernel")
            elif j == 2:
                proof.append(f"  · exact encoding_agreement {p}")
            elif j == 3:
                proof.append(f"  · exact reconstruct_fields {p}")
            else:
                proof.append("  · first | rfl | decide +kernel")
        output += [f"theorem observation{i} : " + " ∧\n    ".join(checks) + " := " + "\n".join(proof),
                   f"#print axioms observation{i}"]
    output.append("end ACGN.FourthFive.ProfileReplay")
    return "\n".join(output) + "\n", len(expected)


def generate(build, formal):
    code, count = program(rows(Path(build) / "semantic-profile-wire.tsv", FIELDS),
                          rows(Path(build) / "semantic-profile-wire-source.tsv", SOURCE_FIELDS))
    return [("SemanticProfileWireReplay.lean", code, count)]


def negatives(build, formal):
    observed = rows(Path(build) / "semantic-profile-wire.tsv", FIELDS)
    extracted = rows(Path(build) / "semantic-profile-wire-source.tsv", SOURCE_FIELDS)
    result = []
    targets = [(0, "producerKey", base64.b64encode(b"wrong").decode()),
               (0, "independentKey", base64.b64encode(b"wrong").decode()), (0, "digest", "0" * 64)]
    for field in range(5):
        i = next(i for i, r in enumerate(observed) if r["surface"] == "boundary" and r["mutation"] == f"stale-{field}")
        targets.append((i, "outcome", "ACCEPT"))
    targets.append((next(i for i, r in enumerate(observed) if r["surface"] == "clone"), "outcome", "ACCEPT"))
    for mutation in VERSION_CONTROLS:
        targets.append((next(i for i, r in enumerate(observed) if r["mutation"] == mutation), "outcome", "ACCEPT"))
    for n, (i, field, value) in enumerate(targets):
        changed = [dict(r) for r in observed]
        changed[i][field] = value
        full = program(changed, extracted)[0]
        code = full.split("theorem observation0 :", 1)[0] + f"theorem observation{i} :" + full.split(
            f"theorem observation{i} :", 1)[1].split(f"#print axioms observation{i}\n", 1)[0]
        result.append((f"profile-{n}-{field}", "RejectSemanticProfileWire.lean", code + "\nend ACGN.FourthFive.ProfileReplay\n"))
    return result


def source_mutations():
    base = "src/is/fivefivefive/CanDis/theory/"
    verifier = "certificate-verifier/src/org/acgn/cert/SemanticEvidenceVerifier.java"
    specs = [("profile-writer-" + field, base + "CertificateBundleWriter.java", old, new)
             for field, old, new in [
                 ("bitwidth", "Integer.toString(profile.bitwidth()),", '"4",'),
                 ("overflow", "profile.overflowMode().name(),", '"FORBID",'),
                 ("temporal", "profile.temporalMode(),", '"alloy-temporal",'),
                 ("rewrite", "profile.rewriteMode(),", '"repaired-normal-form-v2",'),
                 ("signature", "profile.signatureVersion(),", '"alloy-signature-v2",')]]
    specs += [
        ("profile-producer-length", base + "StructuralKey.java", "target.append(value.length())", "target.append(value.codePointCount(0, value.length()))"),
        ("profile-verifier-length", verifier, "target.append(value.length())", "target.append(value.codePointCount(0, value.length()))"),
        ("profile-verifier-field-count", verifier, "evidence.scalars().subList(0, 5)", "evidence.scalars().subList(0, 4)"),
        ("profile-verifier-digest", verifier, "if (!fingerprint.equals(evidence.scalar(5)))", "if (false)"),
        ("profile-producer-authority", base + "SemanticProfile.java", "return authority == Authority.PARSED_SOURCE_COMMAND\n                &&", "return true\n                &&"),
        ("profile-producer-export", base + "SemanticProfile.java", "if (testOnly && isFixedCompatibilityProfile())", "if (testOnly)"),
        ("profile-verifier-publication", verifier, "if (!testOnly\n                    || bitwidth != 4", "if (false\n                    || bitwidth != 4"),
        ("profile-producer-modifiers", base + "SemanticProfile.java", "public StructuralKey structuralKey()", "public synchronized StructuralKey structuralKey()"),
        ("profile-verifier-crypto", verifier, 'MessageDigest.getInstance("SHA-256")', 'MessageDigest.getInstance("SHA-1")'),
        ("profile-verifier-context-version", verifier, "if (!context.scalars().get(0).equals(SOURCE_COMMAND_CONTEXT_VERSION))", "if (false)"),
    ]
    return [(*spec, "SemanticProfileWireExtractor") for spec in specs]
