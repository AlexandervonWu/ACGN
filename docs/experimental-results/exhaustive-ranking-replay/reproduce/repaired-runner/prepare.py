#!/usr/bin/env python3
"""Prepare a fresh repair-candidate replay against an original, unmodified ranking census."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import uuid
from plans import create_plan


def sha(p):
    with p.open('rb') as f:
        digest=hashlib.sha256()
        for chunk in iter(lambda:f.read(4*1024*1024),b''):digest.update(chunk)
        return digest.hexdigest()


def value_at(value,field):
    for key in field.split('.'):value=value[key]
    return value


def require(ok,msg):
    if not ok:raise ValueError(msg)


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    for name in ('baseline-root','run-root','engine-jar','build-receipt'):ap.add_argument('--'+name,required=True,type=Path)
    ap.add_argument('--engine-commit',required=True)
    ap.add_argument('--jar-receipt-field',default='experimentJar.sha256',help='Dotted field in the supplied build receipt')
    ap.add_argument('--commit-receipt-field',default='git.commit',help='Dotted field in the supplied build receipt')
    ap.add_argument('--workers',type=int,default=25)
    ap.add_argument('--initial-heap-mib',type=int,default=48)
    ap.add_argument('--max-heap-mib',type=int,default=480)
    ap.add_argument('--collector',choices=('serial','parallel-one'),default='serial')
    ap.add_argument('--min-heap-free-ratio',type=int,default=40)
    ap.add_argument('--max-heap-free-ratio',type=int,default=70)
    args=ap.parse_args()
    baseline,out,jar,receipt=[p.resolve() for p in (args.baseline_root,args.run_root,args.engine_jar,args.build_receipt)]
    require(not out.exists(),'Choose an unused run directory; completed and partial outputs are immutable')
    require(re.fullmatch('[0-9a-f]{40}',args.engine_commit),'Expected a full engine Git commit')
    require(1<=args.workers<=len(os.sched_getaffinity(0)),'Outstanding worker count exceeds available CPUs')
    require(320<=args.max_heap_mib<=1900 and 16<=args.initial_heap_mib<=args.max_heap_mib,'Initial heap must fit the registered maximum')
    require(0<=args.min_heap_free_ratio<=args.max_heap_free_ratio<=100,'HotSpot free ratios must be ordered percentages')
    cohort=baseline/'cohort';inputs=baseline/'frozen'
    producer_manifest=cohort/'manifest.json';m=json.loads(producer_manifest.read_bytes())
    old_runner=json.loads((baseline/'runner-identity.json').read_bytes());original_jar=inputs/'measured.jar'
    require(sha(producer_manifest)==old_runner['inputManifestSha256'] and sha(original_jar)==old_runner['jarSha256']==m['jarSha256'],
            'Baseline JAR and ranking provenance do not match the original producer')
    require(m['rows']==1894168 and m['submissions']==42386 and old_runner['sourceRunId']==m['measuredRunId'],'Unexpected original-ranking denominator')
    engine_sha=sha(jar);build=json.loads(receipt.read_bytes())
    require(value_at(build,args.jar_receipt_field)==engine_sha and value_at(build,args.commit_receipt_field)==args.engine_commit,
            'Candidate commit/JAR do not match the selected fields of its build receipt')
    source=Path(__file__).resolve().parent
    out.mkdir()
    for sub in ('engine','logs','results/incidents','results/inflight','runner','runner-classes','plans'): (out/sub).mkdir(parents=True)
    (out/'original-inputs').symlink_to(inputs,target_is_directory=True)
    (out/'cohort').symlink_to(cohort,target_is_directory=True)
    candidate=out/'engine/candidate.jar';shutil.copyfile(jar,candidate)
    build_file=out/'engine/build-receipt.json';shutil.copyfile(receipt,build_file)
    require(sha(candidate)==engine_sha and sha(build_file)==sha(receipt),'Candidate changed during freeze')
    native=out/'runner/ExhaustiveNativeReplay.java'
    require(sha(baseline/'runner/ExhaustiveNativeReplay.java')==old_runner['files']['runner/ExhaustiveNativeReplay.java'],'Baseline checked driver source changed')
    shutil.copyfile(source/'ExhaustiveNativeReplay.java',native)
    for name in ('supervise.py','prepare.py','launch.sh','plans.py'):
        shutil.copy2(source/name,out/'runner'/name)
    subprocess.run(['javac','--release','17','-encoding','UTF-8','-cp',f'{candidate}:{inputs}/lib/*','-d',out/'runner-classes',native],check=True)
    cfg=dict(workers=args.workers,heapMiB=args.max_heap_mib,referenceCache=2,startAvailableGiB=7,retireAvailableGiB=5)
    heap_policy=dict(collector=args.collector,initialMiB=args.initial_heap_mib,maximumMiB=args.max_heap_mib,minFreeRatio=args.min_heap_free_ratio,maxFreeRatio=args.max_heap_free_ratio)
    (out/'runner-control.json').write_text(json.dumps(cfg)+'\n')
    plan_hashes={}
    for shard in m['shards']:
        original=cohort/shard['path']
        require(sha(original)==shard['sha256'],'Original ranking input drift')
        plan_hashes[shard['id']]=create_plan(original,out/'plans'/(shard['id']+'.tsv'))
    (out/'plans/manifest.json').write_text(json.dumps(plan_hashes,sort_keys=True,indent=2)+'\n')
    paths=[out/'plans/manifest.json',*sorted((out/'runner-classes').rglob('*.class')),*sorted((out/'runner').iterdir()),candidate,build_file]
    files={str(p.relative_to(out)):sha(p) for p in paths}
    for p in sorted((inputs/'lib').glob('*.jar')):
        frozen=old_runner['files']['frozen/lib/'+p.name]
        require(sha(p)==frozen,'Original measured dependency changed')
        files['original-inputs/lib/'+p.name]=frozen
    ident=dict(schema='acgn-paid-native-candidate-replay-v1',candidateRunId=str(uuid.uuid4()),
               originalProducer=dict(runId=m['measuredRunId'],commit=m['measuredCommit'],jarSha256=m['jarSha256'],
                                     rankingManifestSha256=sha(producer_manifest),combinedInputsSha256=m['combinedInputsSha256'],
                                     baselineNativeRunnerIdentitySha256=sha(baseline/'runner-identity.json')),
               engine=dict(role='REPAIR_CANDIDATE',commit=args.engine_commit,jarSha256=engine_sha,jarPath='engine/candidate.jar',
                           buildReceiptSha256=sha(build_file),buildReceipt='engine/build-receipt.json',commitReceiptField=args.commit_receipt_field,
                           jarReceiptField=args.jar_receipt_field),
               scoreAuthority='originalProducer',inputManifestSha256=sha(producer_manifest),executionOrder='Four original submissions at a time, grouped by exact reference path/predicate/SHA; published by original ordinals',rows=m['rows'],submissions=m['submissions'],
               shards=len(m['shards']),dataset=m['dataset'],files=files,initialControl=cfg,registeredHeapPolicy=heap_policy,
               javaVersion=subprocess.check_output(['java','-version'],stderr=subprocess.STDOUT,text=True))
    ident_path=out/'runner-identity.json';ident_path.write_text(json.dumps(ident,sort_keys=True,indent=2)+'\n')
    print(json.dumps(dict(candidateRunId=ident['candidateRunId'],originalScoreRunId=m['measuredRunId'],engineSha256=engine_sha,
                          identitySha256=sha(ident_path),launch=str(out/'runner/launch.sh')),indent=2))


if __name__=='__main__':
    main()
