"""Exercise the production classpath and both ordinary source entry points."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[3]
CASES = {
    "classroom_rl/correct/6SaKTDtHbkfiD6pbh_inv8.als": "fiber",
    "trainStationNew/correct/2j59AQ2mBXJ3HFHRu_inv5.als": "classifier",
    "coursesNew/correct/YrQBtYjxRadc3HhJi_inv1.als": "role",
    "socialMedia/correct/8PX5zdXt3Q226DThH_inv4.als": "mixedRole",
    "graphs/correct/Xj8o4rH8bNcE7oZ5A_inv2.als": "difference",
    "classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als": None,
}


def check(classes, tmp):
    source = tmp / "input"
    for path in CASES:
        (source / path).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / "classified-data" / path, source / path)

    def run(runner, output, *flags):
        subprocess.run(["java", "-ea", "-Xmx1g", "-Dorg.slf4j.simpleLogger.defaultLogLevel=warn",
                        "-cp", f"{classes}:{ROOT}/lib/*", "is.fivefivefive.CanDis." + runner,
                        source, tmp / output, "--threads", "2", "--skip-rewards", *flags], check=True)

    run("CanonicalBatchTest", "batch", "--diagnostic-operations")
    rows = json.loads((tmp / "batch/diagnostic-operations-distances.json").read_text())["results"]
    assert len(rows) == len(CASES) and {r["relativePath"] for r in rows} == CASES.keys()
    for row in rows:
        rule = CASES[row["relativePath"]]
        decision, = row["commandComparisons"]
        assert row["success"] and row["distance"] > 0 and decision["carrierBounds"]
        assert decision["rules"] == ([rule] if rule else [])
        assert decision["native"] == ("UNSAT" if rule else "NOT_RUN")
        assert decision["comparisonDistance"] == (0 if rule else row["distance"])

    run("Alloy4FunAugmenter", "pool")
    pool = tmp / "pool"
    index = json.loads((pool / "index.json").read_text())
    edges = [json.loads(line) for line in (pool / index["defaultCorrectPoolComparisons"]).read_text().splitlines()]
    assert len(edges) == 5 and {e["rules"][0] for e in edges} == set(CASES.values()) - {None}
    assert all(e["equivalent"] and not e["structuralZero"] and e["native"] == "UNSAT" for e in edges)
    counts = json.loads((pool / index["defaultCorrectPoolCounts"]).read_text())
    assert (counts["structuralClasses"], counts["commandScopedComponents"]) == (11, 6)
    assert len(counts["pools"]) == 6 and all(p["noCommonCommand"] == 0 for p in counts["pools"])
    print("Both default runners exercised all five rule families; structural distances retained.")


if __name__ == "__main__":
    with tempfile.TemporaryDirectory() as temporary:
        check(Path(sys.argv[1]).resolve(), Path(temporary))
