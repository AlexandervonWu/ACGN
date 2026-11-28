"""Freeze a candidate and run fresh, resumable low-priority reproductions of historical trace/command obligations."""
import argparse,collections,datetime,json,os,resource,shutil,subprocess,sys,time,uuid
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor,as_completed
from queue import Queue,Empty
from threading import Lock
P=Path(__file__).resolve().parent;W=P.parent;sys.path.insert(0,str(W/'cohort'))
from verify_inputs import atomic,sha,jsonfile,check
MANIFEST='f843f4aed936766e3b918327293d06d2ce42106149ecc129429a9e3dc52f9a36'
BASE_RUNNER='a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02'
def stamp():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def mem():return int(next(line for line in Path('/proc/meminfo').read_text().splitlines() if line.startswith('MemAvailable:')).split()[1])/1048576
def freeze(jar,commit,desired,receipt):
    check(sha(P/'manifest.json')==MANIFEST and sha(W/'runner-identity.json')==BASE_RUNNER,'Unregistered baseline or jobs')
    expected=jsonfile(W/'runner-identity.json')['files'];check(sha(jar)==desired and len(commit)==40,'Candidate source or digest differs from registration')
    t=P/'runs'/(commit[:12]+'-'+desired[:12])
    t.mkdir(parents=True,exist_ok=False)
    for sub in ('classes','results/incidents','logs','driver'):(t/sub).mkdir(parents=True)
    shutil.copyfile(jar,t/'candidate.jar');check(sha(t/'candidate.jar')==desired,'Candidate changed during freeze')
    shutil.copyfile(receipt,t/'build-receipt')
    shutil.copyfile(P/'CoveredReplay.java',t/'driver/CoveredReplay.java');shutil.copyfile(W/'runner/ExhaustiveNativeReplay.java',t/'driver/ExhaustiveNativeReplay.java')
    check(sha(t/'driver/ExhaustiveNativeReplay.java')==expected['runner/ExhaustiveNativeReplay.java'],'Ordered sequence helper differs')
    deps={str(x.relative_to(W/'frozen')):sha(x) for x in (W/'frozen/lib').glob('*.jar')}
    for k,v in deps.items():check(v==expected['frozen/'+k],'Changed runtime dependency')
    sources=list((t/'driver').glob('*.java'))
    subprocess.run(['javac','--release','17','-encoding','UTF-8','-cp',str(t/'candidate.jar')+':'+str(W/'frozen/lib/*'),'-d',str(t/'classes'),*sources],check=True)
    rolefiles=[P/'run.py',P/'recount.py',P/'prepare.py',W/'cohort/verify_inputs.py',W/'cohort/verify_results.py',W/'cohort/native_commitment.py']
    proof=dict(schema='acgn-candidate-historical-sidecar-v1',runId=str(uuid.uuid4()),registeredAt=stamp(),candidateCommit=commit,candidateJarSha256=desired,buildReceiptSha256=sha(t/'build-receipt'),
               inputManifestSha256=MANIFEST,baselineRunnerSha256=BASE_RUNNER,originalScoreRunId=jsonfile(P/'manifest.json')['originalScoreProducer'],
               candidateFiles={str(x.relative_to(t)):sha(x) for x in [*sources,*sorted((t/'classes').rglob('*.class'))]},orchestration={str(f.relative_to(W)):sha(f) for f in rolefiles},dependencies=deps)
    atomic(t/'identity.json',proof);print('FROZEN',t,sha(t/'identity.json'),flush=True);return t
def registered(t):
    h=jsonfile(t/'identity.json');check(h['inputManifestSha256']==sha(P/'manifest.json')==MANIFEST and h['baselineRunnerSha256']==sha(W/'runner-identity.json')==BASE_RUNNER,'Wrong original identity')
    check(sha(t/'candidate.jar')==h['candidateJarSha256'] and sha(t/'build-receipt')==h['buildReceiptSha256'],'Changed candidate')
    for prefix,files in [(W,h['orchestration']),(t,h['candidateFiles']),(W/'frozen',h['dependencies'])]:
        for f,v in files.items():check(sha(prefix/f)==v,'Changed registered '+f)
    return h
def position(t,s):
    dest=t/'results'/Path(s['path']).name;answer=0;extent=0
    if not dest.exists():return 0
    from recount import verdict
    with dest.open('rb') as f,(P/s['path']).open('rb') as jobs:
        while line:=f.readline():
            if not line.endswith(b'\n'):break
            orig=jobs.readline();check(orig and json.loads(line)['ordinal']==answer,'Wrong existing result');verdict(t,orig,json.loads(line))
            extent=f.tell();answer+=1
    if dest.stat().st_size!=extent:
        with dest.open('r+b') as f:f.truncate(extent)
    return answer
def run(t,maxworkers):
    from recount import audit_shard,recount
    ide=registered(t);idh=sha(t/'identity.json');m=jsonfile(P/'manifest.json')
    q=Queue();errs=collections.Counter();lock=Lock();shards=sorted(m['shards'],key=lambda s:(int(Path(s['path']).stem.rsplit('-',1)[1]),{'sat-control':0,'fixed':1,'zero':2,'paired':3}[s['kind']]))
    for s in shards:
        dest=t/'results'/Path(s['path']).with_suffix('.receipt.json').name
        if dest.exists():audit_shard(t,s,jsonfile(dest));continue
        q.put(s)
    flag=t/'control.json'
    if not flag.exists():atomic(flag,dict(workers=1,memoryGiBForExtra=8,minGiB=5.8))
    def worker(slot):
        proc=None;log=None
        try:
            while not q.empty():
                control=jsonfile(flag)
                if slot>=min(maxworkers,control['workers']) or mem()<(control['minGiB'] if slot==0 else control['memoryGiBForExtra']):
                    if proc:proc.stdin.close();proc.wait();proc=None;log.close();log=None
                    time.sleep(8);continue
                try:s=q.get_nowait()
                except Empty:return
                name=Path(s['path']).stem;src=P/s['path'];check(sha(src)==s['sha256'],'Changed job shard')
                if not proc:
                    log=(t/'logs'/f'worker-{slot}-{time.time_ns()}.log').open('wb')
                    command=['nice','-n','12','taskset','-c',str(29+slot),'java','-Dorg.slf4j.simpleLogger.defaultLogLevel=warn','-Xmx520m','-XX:+UseSerialGC','-XX:ActiveProcessorCount=1','-cp',str(t/'classes')+':'+str(t/'candidate.jar')+':'+str(W/'frozen/lib/*'),'is.fivefivefive.CanDis.CoveredReplay',str(W/'frozen/classified-data'),str(t/'results')]
                    proc=subprocess.Popen(command,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=log,text=True,bufsize=1)
                start=position(t,s);when=stamp()
                try:
                    proc.stdin.write(f'{name}\t{src}\t{start}\n');proc.stdin.flush();answer=json.loads(proc.stdout.readline())
                    check(answer==dict(shard=name,rows=s['rows']),'Incomplete worker acknowledgement')
                except (BrokenPipeError,json.JSONDecodeError) as e:
                    proc.wait();proc=None;log.close();log=None
                    with lock:
                        errs[name]+=1
                        if errs[name]>3:raise RuntimeError('Persistent worker failure at '+name) from e
                    q.put(s);continue
                output=t/'results'/(name+'.jsonl');rec=dict(shard=name,rows=s['rows'],inputSha256=s['sha256'],outputSha256=sha(output),candidateJarSha256=ide['candidateJarSha256'],identitySha256=idh,start=when,finish=stamp(),resumedRows=start,worker=slot)
                states=audit_shard(t,s,rec);rec['observed']=dict(states);atomic(t/'results'/(name+'.receipt.json'),rec)
                with lock:
                    closed=list((t/'results').glob('*.receipt.json'));ct=collections.Counter();observed=0
                    for x in closed:
                        d=jsonfile(x);ct.update(d['observed']);observed+=d['rows']
                    atomic(t/'progress.json',dict(at=stamp(),rows=observed,completedShards=len(closed),requiredShards=len(shards),recorded=ct,identity=idh))
        finally:
            if proc:
                proc.stdin.close();proc.wait()
            if log:log.close()
    with ThreadPoolExecutor(max_workers=maxworkers) as pool:
        fs=[pool.submit(worker,i) for i in range(maxworkers)]
        for f in as_completed(fs):f.result()
    report=recount(t);print(json.dumps(report,sort_keys=True),flush=True)
if __name__=='__main__':
    a=argparse.ArgumentParser(description=__doc__);a.add_argument('--candidate-jar',type=Path);a.add_argument('--commit');a.add_argument('--sha256');a.add_argument('--build-receipt',type=Path);a.add_argument('--resume',type=Path);a.add_argument('--workers',type=int,choices=(1,2,3),default=3)
    args=a.parse_args();root=args.resume or freeze(args.candidate_jar,args.commit,args.sha256,args.build_receipt);run(root,args.workers)
