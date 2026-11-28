"""Verify distributed native ledgers, before/after identities, source retention, and independent receipts."""
import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path

sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE/"reproduce"))
from compare_censuses import rebuild
from native_release import FLOOR,INPUT,OLD_FAILURES,ORIG,ROWS,check_retained_rows,compare_historical,read,registered_audits,require,sha,verify_inventory


def compact(repo,edition,verifier,return_code):
    identity=HERE/"receipts"/edition/"runner-identity.json";manifest=HERE/"receipts/original/manifest.json"
    require(sha(manifest)==INPUT,"Original ranking input registration differs")
    if edition=="original":require(sha(identity)==ORIG,"Original runner identity differs")
    cmd=[sys.executable,"-B",str(HERE/"reproduce"/verifier/"verify_compact.py"),str(HERE/edition),str(repo),str(manifest),str(identity)]
    result=subprocess.run(cmd,capture_output=True,text=True)
    require(result.returncode==return_code,result.stderr or result.stdout)
    checked=json.loads(result.stdout)
    failed=OLD_FAILURES if edition=="original" else 0
    require(checked==dict(status="BLOCKED" if failed else "VERIFIED",rows=ROWS,checked=ROWS-failed,nonconforming=failed,summarySha256=sha(HERE/edition/"summary.json")),"Wrong "+edition+" compact verdict")
    return checked


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--repo",type=Path,default=HERE.parents[2],help="ACGN checkout with the classified corpus, published score ledgers, and measured Git revisions")
    ap.add_argument("--original-only",action="store_true",help="recount only the archived original engine")
    args=ap.parse_args();repo=args.repo.resolve()
    if args.original_only:
        print(json.dumps({"scope":"ORIGINAL_ONLY","original":compact(repo,"original","original-audit",2)},sort_keys=True));return
    verify_inventory(HERE)
    bound=registered_audits(HERE)
    compact(repo,"original","original-audit",2)
    compact(repo,"repaired","repaired-audit",0)
    subprocess.run([sys.executable,"-B",str(HERE/"receipts/recovery/verify.py"),
                    "--final-bindings",str(HERE/"repaired/shard-bindings.json")],check=True)
    retained=compare_historical(HERE,bound,repo)
    check_retained_rows(HERE,repo,retained)
    with tempfile.TemporaryDirectory() as scratch:
        target=Path(scratch)
        historical=repo/"docs/experimental-results/historical-retention/paid-rank-witnesses-floor.jsonl"
        rebuilt=rebuild(HERE/"original",HERE/"repaired",historical,target)
        for name in ("repaired-ranking-pairs.csv","before-after.json","paid-rank-witnesses-floor.jsonl"):
            require(sha(target/name)==sha(HERE/name),"Before/after recount differs: "+name)
        from compare_programs import rebuild as rebuild_programs, SUMMARY, TABLE
        changes=rebuild_programs(HERE,repo,target)
        for name in (TABLE,SUMMARY):
            require(sha(target/name)==sha(HERE/name),"Ranking program changes differ from the measured archives: "+name)
        require(changes["joinedPositiveScores"]==ROWS and changes["originalMatched"]==ROWS-OLD_FAILURES,
                "Original matched programs or scalar scores were lost from the comparison")
        require(rebuilt["originalNonconforming"]==OLD_FAILURES and rebuilt["newFloor"]==FLOOR and rebuilt["repairedNonconforming"]==0,"Historical repaired pair floor differs")
        floor=subprocess.check_output(["git","-C",str(repo),"show",bound["commit"]+":docs/historical-pair-coverage/paid-ranking-witnesses.jsonl"])
        require(floor==(HERE/"paid-rank-witnesses-floor.jsonl").read_bytes(),"Committed engine does not contain the released floor")
    assembly=read(HERE/"reproduce/jar-assembly/engines.json")
    require(assembly["repaired"]["git"]==bound["commit"] and assembly["repaired"]["sha256"]==bound["jar"] and sha(HERE/"reproduce/jar-assembly"/assembly["repaired"]["zipEntries"])==assembly["repaired"]["zipEntriesSha256"],"Measured repaired JAR cannot be identified from its ZIP layout")
    # Both downstream independent cohorts must have finished on this same repaired engine.
    from verify_additional_evidence import assess_extra_cohorts, check_build_and_proofs, diagnostic_controls, worked
    assess_extra_cohorts(HERE, bound, repo)
    subprocess.run([sys.executable,"-B",str(HERE/"reference-pool-scores/command-components/verify.py"),
                    "--archive",str(HERE),"--repo",str(repo)],check=True)
    subprocess.run([sys.executable,"-B",str(HERE/"temporal-program-replay/verify.py"),"--repo",str(repo)],check=True)
    subprocess.run([sys.executable,"-B",str(HERE/"temporal-program-replay/test_controls.py")],check=True)
    temporal=HERE/"temporal-program-replay"
    lineage=json.loads(subprocess.check_output([sys.executable,"-B",str(temporal/"verify_archived_lineages.py"),"--repo",str(repo)]))
    require(lineage==read(temporal/"archival-lineage-summary.json") and lineage["historicalProgramHashes"]==392,
            "Archival temporal lineage reconstruction changed")

    expanded=temporal/"full-temporal-scope"
    temporal_release=read(HERE/"receipts/repaired/full-temporal-export.json")
    require(temporal_release["jar"]==bound["jar"] and temporal_release["rows"]==26673 and
            temporal_release["inventorySha256"]==sha(expanded/"inventory.json") and
            temporal_release["summarySha256"]==sha(expanded/"summary.json") and
            temporal_release["portableCheckerSha256"]==sha(expanded/"verify.py"),"Temporal supplement provenance changed")
    full=json.loads(subprocess.check_output([sys.executable,"-B",str(expanded/"verify.py"),
                                             "--archive",str(HERE),"--repo",str(repo)]))
    require(full==read(expanded/"summary.json")==temporal_release["latestVerifiedResult"] and
            full["withinReplayStrictProgramMatches"]==26673 and full["archivedFinalHashEqual"]==26477 and
            full["archivedFinalHashDifferent"]==196 and full["solelyUniformFreshVersusColdEffectRelabelling"]==196 and
            full["archiveCommitmentsReconstructedWithOnlyLocalOccurrenceTranslation"]==196 and full["locallyNamedOnlyOnSource"]==173 and full["locallyNamedOnlyOnTarget"]==23 and
            full["fullMeasuredTemporalLedgerSha256"]==sha(HERE/"repaired/summary.json"),
            "Fresh full-temporal programs do not agree with the measured evidence")
    check_build_and_proofs(HERE, bound, repo)
    diagnostic_controls(HERE,bound,repo)
    worked(HERE, bound["jar"])
    subprocess.run([sys.executable,"-B",str(HERE/"diagnostic-controls/verify.py"),"--repo",str(repo)],check=True)
    subprocess.run([sys.executable,"-B",str(HERE/"reproduce/headlines.py")],cwd=HERE,check=True)
    print(json.dumps({"rankingPairs":ROWS,"originalDivergences":OLD_FAILURES,"repairedDivergences":0,"historicalFloor":FLOOR,"historicalDirections":2*FLOOR,"pairedNative":61598,"referenceZeros":19271,"archivedCommands":1339,"candidateCommit":bound["commit"],"candidateJarSha256":bound["jar"]},sort_keys=True))

if __name__=="__main__":main()
