"""Fail-closed delegation to the three independently censused third-five areas.

Area plugins own their exact observation/source-key sets and semantics. This
module never infers a census from observed rows, fills missing rows, renames
theorems, suppresses a plugin error, or supplies a substitute replay.
"""

from __future__ import annotations

import importlib.util
import inspect
from pathlib import Path
import sys

from run_next_obligation_repairs import (
    mutation_spec, negative_specs, proof_inventory, replay_specs, require,
)

AREAS = (
    {"id": "call", "parents": ("P1-06", "P1-09", "P1-16"), "plugin": "third_call_replays.py",
     "proof": "CallAuthorityTransitions.lean", "replay": "CallAuthorityReplay.lean",
     "test": "is.fivefivefive.CanDis.CallAuthorityTransitionsRegressionTest",
     "trace": "call-authority.tsv", "extractor": "CallAuthorityTransitionsExtractor",
     "sourceTrace": "call-authority-source.tsv"},
    {"id": "join", "parents": ("A2-04",), "plugin": "third_join_replays.py",
     "proof": "GuardedJoinChain.lean", "replay": "GuardedJoinChainReplay.lean",
     "test": "is.fivefivefive.CanDis.theory.GuardedJoinChainRegressionTest",
     "trace": "guarded-join-chains.tsv", "extractor": "GuardedJoinChainExtractor",
     "sourceTrace": "guarded-join-source.tsv"},
    {"id": "registry", "parents": ("P2-19",), "plugin": "third_registry_replays.py",
     "proof": "RegistryAdmission.lean", "replay": "RegistryAdmissionReplay.lean",
     "test": "is.fivefivefive.CanDis.theory.RegistryAdmissionRegressionTest",
     "trace": "registry-admission.tsv", "extractor": "RegistryAdmissionExtractor",
     "sourceTrace": "registry-admission-source.tsv"},
)


def load_area(area):
    path = Path(__file__).with_name(area["plugin"])
    require(path.is_file() and not path.is_symlink(), "missing area plugin: " + path.name, "MISSING_INPUT")
    name = "_third_five_area_" + area["id"]
    spec = importlib.util.spec_from_file_location(name, path)
    require(spec is not None and spec.loader is not None, "cannot load " + path.name, "UNDECLARED_DEPENDENCY")
    module = importlib.util.module_from_spec(spec)
    previous = sys.modules.get(name)
    sys.modules[name] = module
    try:
        spec.loader.exec_module(module)
    finally:
        if previous is None:
            sys.modules.pop(name, None)
        else:
            sys.modules[name] = previous
    for method in ("generate", "negatives", "source_mutations"):
        require(callable(getattr(module, method, None)), path.name + " lacks " + method, "VERIFIER_NOT_RUN")
    return module


def generate(build, formal):
    generated, namespaces = [], set()
    for area in AREAS:
        records = replay_specs(load_area(area).generate(build, formal), [area["replay"]])
        # Inventory with the shared scanner, without writing a generated artifact.
        class Source:
            name = area["replay"]

            def read_text(self, encoding="utf-8"):
                return records[0][1]

        names = proof_inventory(Source())
        require(len(names) == records[0][2], "area theorem count mismatch", "VERIFIER_NOT_RUN")
        current = {name.rpartition(".")[0] for name in names}
        require("" not in current and not current & namespaces,
                "area replay namespaces must be qualified and disjoint", "AMBIGUOUS_CORRESPONDENCE")
        namespaces.update(current)
        generated.extend(records)
    return replay_specs(generated, [area["replay"] for area in AREAS])


def negatives(build, formal):
    result = []
    positives = [area[key] for area in AREAS for key in ("proof", "replay")]
    for area in AREAS:
        records = negative_specs(load_area(area).negatives(build, formal), positives)
        result.extend((area["id"] + "-" + label, name, source) for label, name, source in records)
    return negative_specs(result, positives)


def source_mutations(build=None, formal=None):
    result = []
    for area in AREAS:
        function = load_area(area).source_mutations
        try:
            inspect.signature(function).bind(build, formal)
        except TypeError:
            inspect.signature(function).bind()
            records = function()
        else:
            require(build is not None and formal is not None, "area source controls need build paths")
            records = function(build, formal)
        require(isinstance(records, list) and records, "missing area source controls", "VERIFIER_NOT_RUN")
        seen = set()
        for record in records:
            label, source, old, new, extractor = mutation_spec(record, {area["extractor"]})
            require(label not in seen, "duplicate area source control", "AMBIGUOUS_CORRESPONDENCE")
            seen.add(label)
            result.append((area["id"] + "-" + label, source, old, new, extractor))
    return result
