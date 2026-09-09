"""Strict delegation for the four independent v2.17 observation families.

The frozen v2.14 aggregator is reused in a private namespace. Only its static
area table and namespace label change; previous packages remain untouched.
"""

import ast
import hashlib
from pathlib import Path
from types import ModuleType

from run_next_obligation_repairs import require

AREAS = (
    {
        "id": "law",
        "parents": [
            "P3-04"
        ],
        "plugin": "fifth_law_record_replays.py",
        "proof": "LawRecordWire.lean",
        "replay": "LawRecordWireReplay.lean",
        "test": "is.fivefivefive.CanDis.theory.LawRecordWireRegressionTest",
        "trace": "law-record-wire.tsv",
        "extractor": "LawRecordWireExtractor",
        "sourceTrace": "law-record-wire-source.tsv"
    },
    {
        "id": "records",
        "parents": [
            "P3-05",
            "P3-06"
        ],
        "plugin": "fifth_flat_container_replays.py",
        "proof": "FlatContainerRecords.lean",
        "replay": "FlatContainerRecordsReplay.lean",
        "test": "is.fivefivefive.CanDis.theory.FlatContainerRecordsRegressionTest",
        "trace": "flat-container-records.tsv",
        "extractor": "FlatContainerRecordsExtractor",
        "sourceTrace": "flat-container-records-source.tsv"
    },
    {
        "id": "wire",
        "parents": [
            "P3-12"
        ],
        "plugin": "fifth_wire_tables_replays.py",
        "proof": "CanonicalWireTables.lean",
        "replay": "CanonicalWireTablesReplay.lean",
        "test": "is.fivefivefive.CanDis.theory.CanonicalWireTablesRegressionTest",
        "trace": "canonical-wire-tables.tsv",
        "extractor": "CanonicalWireTablesExtractor",
        "sourceTrace": "canonical-wire-tables-source.tsv"
    },
    {
        "id": "source",
        "parents": [
            "A2-12"
        ],
        "plugin": "fifth_source_bindings_replays.py",
        "proof": "SourceOccurrenceBindings.lean",
        "replay": "SourceOccurrenceBindingsReplay.lean",
        "test": "is.fivefivefive.CanDis.theory.SourceOccurrenceBindingsRegressionTest",
        "trace": "source-occurrence-bindings.tsv",
        "extractor": "SourceOccurrenceBindingsExtractor",
        "sourceTrace": "source-occurrence-bindings-source.tsv"
    },
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
    sites[0].value = "_fifth_five_area_"
    module = ModuleType("_fifth_five_dispatcher")
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
