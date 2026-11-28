"""Compare complete temporal effect programs and original owner tables under an explicit allocator offset."""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "reproduce/original-audit"))
from native_commitment import SerializedNumber, canonical

def require(ok, message):
    if not ok:
        raise ValueError(message)

def digest(value):
    return hashlib.sha256(canonical(value).encode("utf-8",errors="replace")).hexdigest()

def project(raw, expected, block_count):
    evidence = json.loads(raw, parse_float=SerializedNumber)
    require((evidence["status"],evidence["reason"]) == ("MATCHED","CHECKED_NATIVE_ACTIONS_EQUAL"),"Native replay failed")
    for k in ("orderedBlockEffectsEqual","endpointCorrespondenceChecked","sourceCertificatesChecked",
              "fixedChoiceReplaysChecked","allNativeEntriesRetained"):
        require(evidence[k] is True,"Native check missing: "+k)
    costs = {}
    programs = []
    for arm in ("fast","certified"):
        data = evidence["diagnostic"][arm]
        require(data["distance"] == expected, "Changed "+arm+" distance")
        seq = [[b["component"],b["effect"]] for b in evidence[arm+"Blocks"]]
        require(len(seq) == block_count,"Changed temporal block count")
        programs.append(seq)
        costs[arm] = {k: data[k] for k in ("distance","matrixDistance","quantifierDistance","temporalDistance")}
    require(canonical(programs[0]) == canonical(programs[1]), "Original native effect arrays differ")
    for end in ("source","target"):
        require(all(x["correspondence"]["sourceOccurrenceTransportChecked"] is True for x in evidence[end+"LocalOwners"]),
                "Unverified original owner transport")
    return dict(program=programs[0], costs=costs, sourcePhases=evidence["sourcePhases"], targetPhases=evidence["targetPhases"],
                sourceOwners=evidence["sourceLocalOwners"],targetOwners=evidence["targetLocalOwners"],
                sourceBoundary=evidence["sourceBoundary"])

OWNER_ROOT = ("*", "correspondence", "owners", "*")
OWNER_IDS = {
    OWNER_ROOT+("ownerOccurrence",), OWNER_ROOT+("parentOccurrence",),
    OWNER_ROOT+("orderedDeclarations","*","occurrence"), OWNER_ROOT+("orderedDeclarations","*","domainOccurrence"),
    OWNER_ROOT+("orderedDeclarations","*","slots","*","occurrence")
}

def offset_between(baseline, observed):
    """Return a single signed offset after strict structural comparison, including both endpoint owner tables."""
    delta = None
    changes = 0
    def compare(a,b,path):
        nonlocal delta, changes
        role=path[0] if path else ""
        owner_id=role in ("sourceOwners","targetOwners") and path[1:] in OWNER_IDS
        variable_id=role=="program" and path[1:] in {
            ("*","*","*","source","localBinding","sourceOccurrence"),
            ("*","*","*","target","localBinding","sourceOccurrence")}
        if owner_id or variable_id:
            require(type(a) is int and type(b) is int and a>=0 and b>=0,"Invalid occurrence label")
            if a==0 or b==0:
                require(a==b==0 and owner_id and path[-1]=="parentOccurrence","Invalid root occurrence or sentinel")
                return
            if delta is None:
                delta=b-a
            require(b-a==delta,"Inconsistent occurrence alias or allocator offset at "+"/".join(path))
            if variable_id:changes+=1
        elif type(a) is dict:
            require(type(b) is dict and a.keys()==b.keys(),"Different effect or source authority keys at "+"/".join(path))
            for k in a:compare(a[k],b[k],path+(k,))
        elif type(a) is list:
            require(type(b) is list and len(a)==len(b),"Changed operation list length at "+"/".join(path))
            for x,y in zip(a,b):compare(x,y,path+("*",))
        else:
            require(type(a) is type(b) and canonical(a)==canonical(b),"Changed effect or source authority at "+"/".join(path))
    compare(baseline,observed,())
    require(delta is not None and changes>0,"No scoped local-use occurrence to corroborate this translation")
    return delta

def archived_label_reconstruction(program, delta):
    """Translate positive local-use labels only; callers must verify the exact original archive hash."""
    def translate(x,p):
        if p in {("*","*","*","source","localBinding","sourceOccurrence"),("*","*","*","target","localBinding","sourceOccurrence")}:
            require(type(x) is int and x>0 and x+delta>0,"Invalid archived allocator offset")
            return x+delta
        if isinstance(x,dict): return {k:translate(y,p+(k,)) for k,y in x.items()}
        if isinstance(x,list): return [translate(y,p+("*",)) for y in x]
        return x
    return translate(program,())
