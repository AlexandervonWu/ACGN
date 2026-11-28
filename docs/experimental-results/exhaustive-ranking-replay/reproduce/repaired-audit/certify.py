"""Incrementally verify closed candidate shards, then package all original forward native receipts and attached retention."""
import argparse
from collections import Counter
import datetime
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import time

from verify_inputs import atomic,sha,jsonfile,check
from verify_results import native_rows
from verify_compact import verify as verify_portable
from registry import inspect,select,ORIGINAL_INPUT
from controls import reverse
from historical_forward import verify as historical
D=Path(__file__).resolve().parent
def registered(w):
    v=jsonfile(w/'independent-auditor.json')
    digest,_,_=select(w/'runner-identity.json')
    check(v['candidateIdentitySha256']==digest and v['inputManifestSha256']==ORIGINAL_INPUT,'Wrong registered candidate audit')
    for name,h in v['files'].items():check(sha(D/name)==h,'Changed independent candidate checker '+name)
    return v
def watch(w,delay,once):
    meta,j=inspect(w,plans=True);registered(w);c=w/'independent-checkpoints';c.mkdir(exist_ok=True)
    cache={};shards={s['id']:s for s in meta['shards']}
    while True:
        completed={p.name.removesuffix('.receipt.json'):p for p in (w/'results').glob('shard-*.receipt.json')}
        check(set(completed)<=shards.keys() and cache.keys()<=completed.keys(),'Unexpected or missing complete result shard')
        for name,path in sorted(completed.items()):
            checksum=sha(path)
            if name in cache:
                check(cache[name]['receiptSha256']==checksum,'Closed candidate receipt changed');continue
            s=shards[name];r=jsonfile(path);cnt=Counter();modes=Counter();cp=c/(name+'.json')
            for _,row,state in native_rows(w,s,r):
                cnt[state]+=1
                if state=='MATCHED':modes[row['sequenceKind']]+=1
            result=dict(shard=name,inputSha256=s['sha256'],planSha256=r['executionPlanSha256'],rows=s['rows'],status=dict(cnt),matchedModes=dict(modes),receiptSha256=checksum,outputSha256=r['outputSha256'],candidateIdentitySha256=sha(w/'runner-identity.json'))
            if cp.exists():check(jsonfile(cp)==result,'Previously audited candidate shard changed')
            else:atomic(cp,result)
            cache[name]=result
        total=Counter();modes=Counter()
        for x in cache.values():total.update(x['status']);modes.update(x['matchedModes'])
        snapshot=dict(at=datetime.datetime.now(datetime.timezone.utc).isoformat(),verifiedCompletedShards=len(cache),requiredShards=len(shards),rows=sum(total.values()),statusCounts=dict(total),matchedModes=dict(modes),closedShardInputsVerified=True,candidateIdentitySha256=sha(w/'runner-identity.json'))
        atomic(c/'progress.json',snapshot)
        if once:return snapshot
        if len(cache)==len(shards) and (w/'producer-complete.json').is_file():return snapshot
        time.sleep(delay)
def finish(w,retention):
    contract=registered(w);meta,ide=inspect(w,plans=True);out=w/'independent-final';score=w/'original-inputs';identity,engine,_=select(w/'runner-identity.json')
    prod=jsonfile(w/'producer-complete.json')
    check(prod['identitySha256']==identity and prod['candidateRunId']==engine['uuid'] and prod['completedShards']==1059 and prod['attemptedRows']==1894168,'Incomplete candidate engine run')
    if not out.exists():
        raw=subprocess.run([sys.executable,str(D/'verify_results.py'),'--workspace',str(w),'--output',str(out)],capture_output=True,text=True)
        (w/'independent-raw-recount.log').write_text(raw.stdout+raw.stderr)
        check(raw.returncode in (0,2) and (out/'summary.json').is_file(),'Candidate native recount failed; see independent-raw-recount.log')
    s=jsonfile(out/'summary.json')
    check(s['checkerSha256']==contract['files']['verify_results.py'] and s['orderedProgramCheckerSha256']==contract['files']['native_commitment.py'] and s['inputCheckerSha256']==contract['files']['verify_inputs.py'],'Candidate results came from different independent verifiers')
    portable=verify_portable(out,score,w/'cohort/manifest.json',w/'runner-identity.json');atomic(w/'independent-portable-recount.json',portable)
    check(portable['status']==s['status'] and portable['rows']==s['rows']==1894168 and portable['nonconforming']==s['nonconforming'],'Candidate raw/portable verdicts disagree')
    fwd=historical(out,w);rev=reverse(w,False);atomic(w/'independent-forward-retention.json',fwd)
    if retention:
        while not (retention/'compact/combined-verdict.json').is_file():time.sleep(30)
        base=retention.parents[1]
        for name,cmd in [('source-native',[sys.executable,str(base/'recount.py'),str(retention)]),
                         ('archived-native',[sys.executable,str(base/'archived-commands/check.py'),str(retention),'--verify-only'])]:
            result=subprocess.run(cmd,capture_output=True,text=True)
            (w/('independent-retention-'+name+'.log')).write_text(result.stdout+result.stderr)
            check(result.returncode==0,'Independent historical counterpart was not reproducible')
        sources=jsonfile(retention/'verification.json');cmds=jsonfile(retention/'archived-commands/receipt.json');both=jsonfile(retention/'compact/combined-verdict.json')
        checks=jsonfile(retention/'compact/SHA256.json')
        for n,h in checks.items():check(sha(retention/'compact'/n)==h,'Changed compact historical evidence')
        check(both['candidateSha256']==sources['candidateJarSha256']==cmds['candidateJarSha256']==engine['jar'] and both['candidateCommit']==sources['sourceCommit']==cmds['candidateCommit']==engine['commit'] and sources['cohorts']=={'paired':61598,'zero':19271,'fixed':1234,'sat-control':105} and cmds['total']==1339,'Wrong historical engine or denominator')
        retained=dict(status=both['status'],sourceLedgerSha256=sha(retention/'verification.json'),commandLedgerSha256=sha(retention/'archived-commands/receipt.json'),releaseSha256=sha(retention/'compact/SHA256.json'),cohorts=sources['cohorts'],nonconforming=sources['nonconforming'],archivedSolver=cmds['native'],sourceScopes=sources['historical'])
    else:retained={'status':'UNASSESSED'}
    passed=all(x['status']=='VERIFIED' for x in (portable,fwd,rev,retained));infra=any(x['status']=='INFRASTRUCTURE_FAILURE' for x in (portable,fwd,rev,retained))
    verdict=dict(status='VERIFIED' if passed else 'INFRASTRUCTURE_FAILURE' if infra else 'BLOCKED',rows=portable['rows'],nonconforming=portable['nonconforming'],candidateNativeRanking=portable,archivedForward=fwd,archivedReverse=rev,sourceAndScopeRetention=retained,
                 experimentUuid=engine['uuid'],candidateJarSha256=engine['jar'],candidateCommit=engine['commit'],candidateRunnerSha256=identity,
                 executionPlansSha256=engine['plan'],auditorRegistrationSha256=sha(w/'independent-auditor.json'),originalScoreProducer=ide['originalProducer'],producerCompletionSha256=sha(w/'producer-complete.json'))
    atomic(w/'independent-closure.json',verdict);return verdict
if __name__=='__main__':
    a=argparse.ArgumentParser(description=__doc__);a.add_argument('workspace',type=Path);a.add_argument('--retention-run',type=Path);a.add_argument('--once',action='store_true');a.add_argument('--delay',type=int,default=25)
    arg=a.parse_args();w=arg.workspace.resolve();print(json.dumps(watch(w,arg.delay,arg.once),sort_keys=True),flush=True)
    if not arg.once: print(json.dumps(finish(w,arg.retention_run.resolve() if arg.retention_run else None),sort_keys=True),flush=True)
