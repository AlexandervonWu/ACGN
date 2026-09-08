"""Strict delegation for the three independent v2.15 observation families.

The frozen v2.14 aggregator is reused in a private namespace. Only its static
area table and namespace label change; previous packages remain untouched.
"""

import ast
import hashlib
from pathlib import Path
from types import ModuleType

from run_next_obligation_repairs import require

AREAS = (
    {"id": "container", "parents": ("P2-20", "P2-18"),
     "plugin": "fourth_container_replays.py", "proof": "ContainerWitnessTransitions.lean",
     "replay": "ContainerWitnessReplay.lean",
     "test": "is.fivefivefive.CanDis.theory.ContainerWitnessTransitionsRegressionTest",
     "trace": "container-witness.tsv", "extractor": "ContainerWitnessTransitionsExtractor",
     "sourceTrace": "container-witness-source.tsv"},
    {"id": "chain", "parents": ("A2-07", "A2-11"),
     "plugin": "fourth_chain_replays.py", "proof": "DependentChainWitnesses.lean",
     "replay": "DependentChainWitnessReplay.lean",
     "test": "is.fivefivefive.CanDis.theory.DependentChainWitnessesRegressionTest",
     "trace": "dependent-chain-witness.tsv", "extractor": "DependentChainWitnessesExtractor",
     "sourceTrace": "dependent-chain-witness-source.tsv"},
    {"id": "profile", "parents": ("P3-03",),
     "plugin": "fourth_profile_replays.py", "proof": "SemanticProfileWire.lean",
     "replay": "SemanticProfileWireReplay.lean",
     "test": "is.fivefivefive.CanDis.theory.SemanticProfileWireRegressionTest",
     "trace": "semantic-profile-wire.tsv", "extractor": "SemanticProfileWireExtractor",
     "sourceTrace": "semantic-profile-wire-source.tsv"},
)

# Set from the immutable v2.14 aggregator, not from observed trace contents.
BASE_SHA256 = "79b9d7cf0e69c2dff34ed0630baf7b5ca343b29dcd949d71f8b3095a166cd025"


def load_dispatcher():
    path = Path(__file__).with_name("third_obligation_replays.py")
    source = path.read_bytes()
    require(hashlib.sha256(source).hexdigest() == BASE_SHA256,
            "v2.14 replay dispatcher changed", "UNDECLARED_DEPENDENCY")
    tree = ast.parse(source.decode("utf-8"), filename=str(path))
    sites = [node for node in ast.walk(tree) if isinstance(node, ast.Constant)
             and node.value == "_third_five_area_"]
    require(len(sites) == 1, "dispatcher namespace site changed", "UNDECLARED_DEPENDENCY")
    sites[0].value = "_fourth_five_area_"
    module = ModuleType("_fourth_five_dispatcher")
    module.__file__ = __file__
    exec(compile(tree, str(path), "exec"), module.__dict__)
    module.AREAS = AREAS
    return module


def generate(build, formal):
    return load_dispatcher().generate(build, formal)


def negatives(build, formal):
    return load_dispatcher().negatives(build, formal)


def source_mutations(build=None, formal=None):
    return load_dispatcher().source_mutations(build, formal)
