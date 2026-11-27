"""Check that the seven CV Lean goals are transcriptions of the frozen Alloy sources."""
import gzip
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROOFS = ROOT / "docs/section3-repair-audit/formal/HistoricalCVPairs.lean"
INVENTORY = ROOT / "docs/experimental-results/2026-11-25/references.jsonl.gz"
HEADER = """/- Generated from the seven v3.1-to-v3.3 regression pairs by
   scripts/check_historical_cv_proofs.py. Each input file declares
   User.visible : set Work. Carriers may be empty and need not be finite. -/
namespace HistoricalCVPairs

structure Model (Atom : Type) where
  user : Atom → Prop
  work : Atom → Prop
  visible : Atom → Atom → Prop
  profile : Atom → Atom → Prop
  visibleRange : ∀ u w, user u → visible u w → work w

variable {Atom : Type} (m : Model Atom)

"""


def translate(body):
    # This grammar admits universal singleton binders, membership in a field
    # image, and implication. Reject every other operator or declaration.
    body = " ".join(body.split())
    scope = {}
    prefix = []
    binder = re.compile(r"(?:all\s+)?(\w+)\s*:\s*(\w+(?:\.\w+)?)\s*([,|])\s*")
    while match := binder.match(body):
        v, domain, _ = match.groups()
        if v in scope or not re.fullmatch("[a-z][a-z0-9]*", v):
            raise ValueError(f"Invalid binder {v}")
        if domain in ("User", "Work"):
            predicate = f"m.{domain.lower()} {v}"
            scope[v] = domain
        else:
            owner, field = domain.split(".")
            if scope.get(owner) != "User" or field != "visible":
                raise ValueError(f"Unsupported dependent range {domain}")
            predicate = f"m.visible {owner} {v}"
            scope[v] = "Work"
        prefix.append(f"∀ {v}, {predicate} → ")
        body = body[match.end():]
    predicates = []
    for term in body.split(" implies "):
        match = re.fullmatch(r"(\w+) in (\w+)\.(visible|profile)", term)
        if not match:
            raise ValueError(f"Unsupported membership {term}")
        w, u, relation = match.groups()
        if scope.get(w) != "Work" or scope.get(u) != "User":
            raise ValueError(f"Wrong membership types {term}")
        predicates.append(f"m.{relation} {u} {w}")
    return "".join(prefix) + " → ".join(predicates)


def render():
    with gzip.open(INVENTORY, "rt") as stream:
        refs = {r["id"]: r for r in map(json.loads, stream)}
    pairs = [(a, b) for a in (1484, 1486, 1487) for b in (1488, 1489)] + [(1524, 1526)]
    sources = {i: refs[i] for p in pairs for i in p}
    # Verify the historical loss ledger names these exact original paths and predicates.
    losses = json.loads((ROOT / "docs/experimental-results/v3.3/changed-v31-pool-zeros.json").read_text())
    expected = {tuple(sorted((r["leftSource"], r["rightSource"]))) for r in losses
                if r["leftPredicate"] == r["rightPredicate"] == "inv1"}
    actual = {tuple(sorted((sources[a]["source"], sources[b]["source"]))) for a, b in pairs}
    if len(losses) != 7 or expected != actual:
        raise ValueError("CV regression identities changed")
    sections = [HEADER]
    for i, ref in sorted(sources.items()):
        path = ref["source"]
        raw = (ROOT / "classified-data" / path).read_bytes()
        if hashlib.sha256(raw).hexdigest() != ref["sha"] or ref["operator"] != "inv1":
            raise ValueError(f"Reference source changed for {i}")
        source = " ".join(raw.decode().split())
        if not re.search(r"\bsig User extends Source\s*\{\s*profile\s*:\s*set Work\s*,\s*visible\s*:\s*set Work\s*\}", source):
            raise ValueError(f"Expected typed static fields for {i}")
        bodies = re.findall(r"\bpred inv1\s*\{([^{}]*)\}", source)
        if len(bodies) != 1:
            raise ValueError(f"Cannot select original predicate {i}")
        formula = translate(bodies[0])
        sections.append(f"/-- {path}, predicate inv1. -/\ndef ref{i} : Prop :=\n  {formula}\n\n")
    sections.append("""private theorem workFirst :
    (∀ w, m.work w → ∀ u, m.user u → m.visible u w → m.profile u w) ↔
    (∀ u, m.user u → ∀ w, m.visible u w → m.profile u w) :=
  ⟨fun h u hu w hv => h w (m.visibleRange u w hu hv) u hu hv,
   fun h w _ u hu hv => h u hu w hv⟩

private theorem userFirst :
    (∀ u, m.user u → ∀ w, m.work w → m.visible u w → m.profile u w) ↔
    (∀ u, m.user u → ∀ w, m.visible u w → m.profile u w) :=
  ⟨fun h u hu w hv => h u hu w (m.visibleRange u w hu hv) hv,
   fun h u hu w _ hv => h u hu w hv⟩

""")
    for a, b in pairs:
        sections.append(f"theorem pair_{a}_{b} : ref{a} m ↔ ref{b} m := by\n"
                        "  first | exact workFirst m | exact userFirst m | exact (workFirst m).symm\n\n")
    return "".join(sections) + "end HistoricalCVPairs\n"


if __name__ == "__main__":
    if PROOFS.read_text() != render():
        raise SystemExit("CV Lean goals differ from the archived Alloy sources")
    print("Matched all seven CV Lean goals to the hash-checked original predicates.")
