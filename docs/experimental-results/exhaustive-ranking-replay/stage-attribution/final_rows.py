"""Derive final bidirectional rows directly from a verified 469-pair native checkpoint."""

import csv
import gzip
import io
import json


def require(ok, why):
    if not ok:
        raise ValueError(why)


def load_rows(path):
    with gzip.open(path, "rt") if path.suffix == ".gz" else path.open() as f:
        yield from map(json.loads, f)


def derive(ledger, catalog, past, floor):
    with catalog.open() as f:
        refs = {
            (r["source"], r["predicate"]): (int(r["referenceId"]), r["sourceSha256"])
            for r in csv.DictReader(f, delimiter="\t")
        }
    closed = {
        (r["left"], r["leftPredicate"], r["right"], r["rightPredicate"]): r for r in load_rows(past)
    }
    floor_rows = list(load_rows(floor))
    specs = {
        tuple(r[s] for s in ("submission", "predicate", "reference", "referencePredicate")): (
            r["sourceSha256"],
            r["referenceSha256"],
        )
        for r in floor_rows
    }
    require(
        len(floor_rows) == len(specs) == 469
        and len(closed) == 386
        and closed.keys() <= specs.keys(),
        "Incorrect historical floor",
    )
    selected = {}
    for row in load_rows(ledger):
        a = row["left"], row["leftPredicate"]
        b = row["right"], row["rightPredicate"]
        direction = row["direction"]
        key = a + b if direction == "forward" else b + a
        require(
            direction in ("forward", "reverse")
            and key in specs
            and (key, direction) not in selected,
            "Unexpected selected direction",
        )
        prior = closed.get(key)
        group = "baselineFailure" if prior else "historical83"
        require(
            row["groups"] == [group]
            and row["checked"]
            and row["status"] == "MATCHED"
            and row["reason"] == "CHECKED_NATIVE_ACTIONS_EQUAL"
            and row["nativeSequencesEqual"]
            and all(
                row.get(n) is True
                for n in (
                    "endpointCorrespondenceChecked",
                    "fixedChoiceReplaysChecked",
                    "sourceCertificatesChecked",
                )
            ),
            "Final checked result missing",
        )
        mode = row["sequenceKind"]
        suffix = "ActionCount" if mode == "FLAT_ACTIONS" else "BlockCount"
        require(
            mode == "FLAT_ACTIONS"
            or (mode == "TEMPORAL_BLOCK_EFFECTS" and row["orderedBlockEffectsEqual"] is True),
            "Invalid temporal/flat representation",
        )
        h = row["fastSequenceSha256"]
        cost = row["expected"]
        count = row["fast" + suffix]
        require(
            len(h) == 64
            and h == row["certifiedSequenceSha256"]
            and count == row["certified" + suffix]
            and cost == row["fastDistance"] == row["certifiedDistance"],
            "Final directions disagree",
        )
        rid, sha = refs[key[2:]]
        require(sha == specs[key][1], "Final selected reference context differs")
        state = prior["nativeStages"][direction]["candidate-04"] if prior else None
        if prior:
            require(
                (prior["leftSha256"], prior["rightSha256"]) == specs[key]
                and prior["referenceId"] == rid
                and prior["expected"] == cost,
                "Historical score/source mismatch",
            )
        selected[key, direction] = dict(
            submission=key[0],
            predicate=key[1],
            sourceSha256=specs[key][0],
            reference=key[2],
            referencePredicate=key[3],
            referenceSha256=sha,
            referenceId=rid,
            cohort=group,
            direction=direction,
            expected=cost,
            previous04=state["nativeStatus"] if state else "",
            final=row["status"],
            fastChanged=(state["fastProgramSha256"] != h) if state else "",
            certifiedChanged=(state["certifiedProgramSha256"] != h) if state else "",
            mode="F" if mode == "FLAT_ACTIONS" else "T",
            steps=count,
            programSha256=h,
        )
    require(
        set(selected) == {(k, d) for k in specs for d in ("forward", "reverse")},
        "Final checkpoint misses selected directions",
    )
    return [selected[k] for k in sorted(selected)]


def table(rows):
    f = io.StringIO(newline="")
    w = csv.DictWriter(f, fieldnames=list(rows[0]))
    w.writeheader()
    w.writerows(rows)
    return f.getvalue().encode()


def history(final_rows, past):
    """Join every final observation to the measured original and four intermediate native stages."""
    import collections

    prior = {
        (r["left"], r["leftPredicate"], r["right"], r["rightPredicate"]): r for r in load_rows(past)
    }
    names = ["original-replay", "candidate-01", "candidate-02", "candidate-03", "candidate-04"]
    final = []
    first = collections.Counter()
    changed = collections.Counter()
    grouped = collections.Counter()
    for row in final_rows:
        if row["cohort"] != "baselineFailure":
            continue
        k = tuple(row[v] for v in ["submission", "predicate", "reference", "referencePredicate"])
        d = row["direction"]
        earlier = prior[k]["nativeStages"][d]
        require(set(names) == set(earlier), "Missing historical stage")
        stages = {n: earlier[n]["nativeStatus"] for n in names}
        stages["final"] = row["final"]
        sequence = list(stages)
        first_durable = next(
            (
                n
                for i, n in enumerate(sequence)
                if all(stages[t] == "MATCHED" for t in sequence[i:])
            ),
            "UNRESOLVED",
        )
        first[d, first_durable] += 1
        transition = "RESTORED" if row["previous04"] != "MATCHED" else "RETAINED"
        changed[d, transition, row["fastChanged"], row["certifiedChanged"]] += 1
        pool = row["submission"].split("/")[0] + "/" + row["predicate"]
        grouped[pool, d, first_durable] += 1
        final.append(
            dict(
                submission=k[0],
                predicate=k[1],
                reference=k[2],
                referencePredicate=k[3],
                referenceId=row["referenceId"],
                direction=d,
                expected=row["expected"],
                **stages,
                firstDurableWithinObservedSeries=first_durable,
            )
        )
    require(len(final) == 772, "Incomplete closed-pair final timeline")
    return final, dict(
        originalPairs=len(prior),
        directions=len(final),
        historicalDirections=len(final_rows) - len(final),
        firstDurable=[
            dict(direction=d, stage=n, rows=count) for (d, n), count in sorted(first.items())
        ],
        fromStage04=[
            dict(direction=d, change=n, fastProgramChanged=f, certifiedProgramChanged=c, rows=count)
            for (d, n, f, c), count in sorted(changed.items())
        ],
        byPool=[
            dict(pool=p, direction=d, stage=s, rows=count)
            for (p, d, s), count in sorted(grouped.items())
        ],
    )
