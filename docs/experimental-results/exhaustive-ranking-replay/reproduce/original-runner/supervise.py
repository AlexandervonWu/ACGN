"""Run and resume each input shard with a warm, isolated measured-JAR JVM."""
import collections
import concurrent.futures
import csv
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import queue
import shutil
import signal
import subprocess
import sys
import threading
import time

ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'frozen'
COHORT=ROOT/'cohort'
RESULTS=ROOT/'results'
IDENTITY=ROOT/'runner-identity.json'
STOP=threading.Event()
LOCK=threading.RLock()
ACTIVE={}
HEAPS={}
PROCS={}
COMPLETE={}
TRIES=collections.Counter()
DEFERRED=collections.deque()
QUEUE=collections.deque()
CAUSES=collections.Counter()
START=time.monotonic()
AVAILABLE=list(sorted(os.sched_getaffinity(0)))


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def sha(p):
    with p.open('rb') as f:
        h=hashlib.sha256()
        for buf in iter(lambda:f.read(4*1024*1024),b''): h.update(buf)
        return h.hexdigest()


def atomic(p,v):
    tmp=p.with_name(p.name+'.tmp-'+str(os.getpid())+'-'+str(threading.get_ident()))
    with tmp.open('w') as f:
        json.dump(v,f,indent=2,sort_keys=True);f.write('\n');f.flush();os.fsync(f.fileno())
    tmp.replace(p)


def require(ok,msg):
    if not ok:raise RuntimeError(msg)


def resources():
    mem=int(next(line.split()[1] for line in Path('/proc/meminfo').read_text().splitlines() if line.startswith('MemAvailable:')))*1024
    return mem,shutil.disk_usage(ROOT).free


def settings():
    cfg=json.loads((ROOT/'runner-control.json').read_bytes())
    require(1<=cfg['workers']<=len(AVAILABLE) and 320<=cfg['heapMiB']<=1900 and 0<=cfg['referenceCache']<=256,'invalid resource config')
    return cfg


def checked(r):
    ok=(r['status']=='MATCHED' and r['reason']=='CHECKED_NATIVE_ACTIONS_EQUAL' and r.get('fastDistance')==r['expected']==r.get('certifiedDistance')
        and all(r.get(k) is True for k in ('endpointCorrespondenceChecked','sourceCertificatesChecked','fixedChoiceReplaysChecked','nativeSequencesEqual'))
        and r.get('fastSequenceSha256')==r.get('certifiedSequenceSha256') and len(r.get('fastSequenceSha256',''))==64)
    if 'orderedBlockEffectsEqual' in r:
        return ok and r['orderedBlockEffectsEqual'] is True and type(r.get('fastBlockCount')) is int and r['fastBlockCount']==r.get('certifiedBlockCount')
    return ok and type(r.get('fastActionCount')) is int and r['fastActionCount']==r.get('certifiedActionCount')


def inspect(s,clip=False):
    ledger=RESULTS/(s['id']+'.jsonl')
    counts=collections.Counter();n=0
    if not ledger.exists(): return n,counts
    with ledger.open('rb+' if clip else 'rb') as f,(COHORT/s['path']).open() as j:
        for line in f:
            if not line.endswith(b'\n'):
                require(clip,'Incomplete final line');f.seek(-len(line),os.SEEK_CUR);f.truncate();break
            row=json.loads(line); fields=j.readline().rstrip('\n').split('\t')
            require(len(fields)==8 and row['ordinal']==n and [row[k] for k in ('kind','left','leftPredicate','right','rightPredicate')]==[fields[i] for i in (0,1,2,4,5)] and row['expected']==int(fields[7]),'Invalid output identity '+s['id']+' row '+str(n))
            ok=checked(row)
            require(row['checked'] is ok,'Incorrect validation classification')
            if not ok:
                path=RESULTS/row['incidentPath']
                require(path.parent==RESULTS/'incidents' and sha(path)==row['incidentSha256'],'Corrupt incident object')
            counts[row['status'] if ok or row['status']!='MATCHED' else 'UNBOUND_MATCH']+=1;n+=1
    require(n<=s['rows'],'Oversized shard')
    return n,counts


def order(shards):
    groups=collections.defaultdict(collections.deque)
    for s in shards:groups[tuple(s['pool'])].append(s)
    # Interleave model families and prioritize large pools so costly tails start early.
    groups=sorted(groups.values(),key=lambda a:-len(a))
    while groups:
        for g in groups:yield g.popleft()
        groups=[g for g in groups if g]


def read_receipt(s):
    p=RESULTS/(s['id']+'.receipt.json')
    if not p.exists():return None
    r=json.loads(p.read_bytes())
    require(r['identitySha256']==RUN_HASH and r['inputSha256']==s['sha256'] and r['outputSha256']==sha(RESULTS/(s['id']+'.jsonl')) and r['rows']==s['rows'],'Invalid signed shard '+s['id'])
    return r


def launch(slot,heap,cache):
    log=(ROOT/'logs'/f'worker-{os.getpid()}-{slot}-{time.time_ns()}.log').open('x')
    cmd=['taskset','-c',str(AVAILABLE[slot]),'java','-Xms48m',f'-Xmx{heap}m','-XX:+UseSerialGC','-XX:ActiveProcessorCount=1',
         '-XX:+ExitOnOutOfMemoryError','-cp',f'{ROOT}/runner-classes:{DATA}/measured.jar:{DATA}/lib/*',
         'is.fivefivefive.CanDis.ExhaustiveNativeReplay',str(DATA/'classified-data'),str(RESULTS),str(cache)]
    proc=subprocess.Popen(cmd,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=log,text=True,bufsize=1)
    log.close()
    with LOCK:PROCS[slot]=proc;HEAPS[slot]=heap
    return proc


def retire(slot,proc):
    if proc is None:return
    if proc.poll() is None:
        proc.terminate()
        try:proc.wait(timeout=4)
        except subprocess.TimeoutExpired:proc.kill();proc.wait()
    proc.stdin.close();proc.stdout.close()
    with LOCK:PROCS.pop(slot,None);HEAPS.pop(slot,None)


def worker(slot,spec):
    proc=None;last=None;old_heap=old_cache=0
    try:
        while not STOP.is_set():
            cfg=settings()
            mem,free=resources()
            with LOCK:
                if slot>=cfg['workers'] or free<12*2**30 or (proc is None and mem<cfg['startAvailableGiB']*2**30):return
                if not QUEUE:return
                s=QUEUE.popleft();ACTIVE[slot]=s
            try:
                req_heap=max(cfg['heapMiB'],min(1700,600+420*(TRIES[s['id']]-1)) if TRIES[s['id']] else 0)
                if proc is None or req_heap!=old_heap or cfg['referenceCache']!=old_cache:
                    retire(slot,proc);proc=launch(slot,req_heap,cfg['referenceCache']);old_heap=req_heap;old_cache=cfg['referenceCache']
                require(sha(COHORT/s['path'])==s['sha256'],'Shard input drift '+s['id'])
                start,_=inspect(s,clip=True); stamp=now()
                proc.stdin.write(f"{s['id']}\t{COHORT/s['path']}\t{start}\n");proc.stdin.flush()
                outcome=proc.stdout.readline()
                if not outcome:
                    rc=proc.wait()
                    with LOCK:
                        if slot not in RETIRED:
                            TRIES[s['id']]+=1
                            print(now(),'JVM exited',slot,rc,s['id'],'attempt',TRIES[s['id']],flush=True)
                            require(TRIES[s['id']]<=4,'Repeated JVM loss on '+s['id'])
                        QUEUE.appendleft(s);ACTIVE.pop(slot,None)
                    return
                ret=json.loads(outcome);n,counts=inspect(s)
                require(ret['shard']==s['id'] and n==ret['rows']==s['rows'],'Incomplete shard '+s['id'])
                r=dict(shard=s['id'],identitySha256=RUN_HASH,jarSha256=spec['jarSha256'],rows=n,inputSha256=s['sha256'],
                       outputSha256=sha(RESULTS/(s['id']+'.jsonl')),statusCounts=dict(counts),startedAt=stamp,
                       finishedAt=now(),resumedRows=start,worker=slot,heapMiB=req_heap,referenceCache=cfg['referenceCache'],measurement=ret)
                atomic(RESULTS/(s['id']+'.receipt.json'),r)
                with LOCK:COMPLETE[s['id']]=r;ACTIVE.pop(slot,None)
            except Exception:
                with LOCK:ACTIVE.pop(slot,None)
                raise
    finally:
        retire(slot,proc)
        with LOCK:RETIRED.discard(slot)


def progress(spec):
    counts=collections.Counter()
    rows=0
    for r in COMPLETE.values():counts.update(r['statusCounts']);rows+=r['rows']
    running=[]
    for slot,s in sorted(ACTIVE.items()):
        path=RESULTS/(s['id']+'.jsonl')
        # Native workers flush complete rows at least every eight observations.
        n=0
        if path.exists():
            with path.open('rb') as f:
                for l in f:n+=l.endswith(b'\n')
        rows+=n;running.append(dict(slot=slot,shard=s['id'],rows=n,goal=s['rows']))
    mem,free=resources()
    return dict(at=now(),identitySha256=RUN_HASH,attemptedRows=rows,targetRows=spec['rows'],completedShards=len(COMPLETE),
                pendingShards=len(QUEUE),running=running,completedShardStatusCounts=dict(counts),hostAvailableBytes=mem,volumeFree=free)


def run(spec):
    global RUN_HASH
    RUN_HASH=sha(IDENTITY);m=json.loads((COHORT/'manifest.json').read_bytes())
    require(sha(COHORT/'manifest.json')==spec['inputManifestSha256'] and sha(DATA/'measured.jar')==spec['jarSha256'],'Manifest or JAR drift')
    for key,h in spec['files'].items():require(sha(ROOT/key)==h,'Frozen runner or library drift '+key)
    for s in order(m['shards']):
        r=read_receipt(s)
        if r:COMPLETE[s['id']]=r
        else:QUEUE.append(s)
    pool=concurrent.futures.ThreadPoolExecutor(max_workers=len(AVAILABLE));tasks={};tick=last_kill=0
    try:
        while not STOP.is_set():
            for slot,f in list(tasks.items()):
                if f.done():f.result();del tasks[slot]
            cfg=settings();mem,free=resources()
            require(free>10*2**30,'Disk under 10 GiB')
            with LOCK:
                if not QUEUE and not ACTIVE and not tasks:break
                if mem<cfg['retireAvailableGiB']*2**30 and time.monotonic()-last_kill>5 and PROCS:
                    victims=[i for i in PROCS if i not in RETIRED]
                    if victims:
                        i=max(victims);RETIRED.add(i);PROCS[i].terminate();last_kill=time.monotonic()
                        print(now(),'Retired slot for host memory pressure',i,mem,flush=True)
                elif QUEUE and mem>=cfg['startAvailableGiB']*2**30:
                    missing=[i for i in range(cfg['workers']) if i not in tasks]
                    for i in missing[:2]:tasks[i]=pool.submit(worker,i,spec)
                if time.monotonic()-tick>=15:
                    r=progress(spec);atomic(ROOT/'progress.json',r)
                    with (ROOT/'resources.jsonl').open('a') as f:f.write(json.dumps(r,separators=(',',':'))+'\n')
                    tick=time.monotonic()
            time.sleep(1)
        if STOP.is_set():return
        require(len(COMPLETE)==len(m['shards']),'Missing completed shard')
        r=progress(spec);require(r['attemptedRows']==m['rows'],'Cohort size drift')
        atomic(ROOT/'producer-complete.json',r)
    finally:
        STOP.set()
        with LOCK:
            for p in PROCS.values():
                if p.poll() is None:p.terminate()
        pool.shutdown(wait=True)


RETIRED=set()
if __name__=='__main__':
    lock=(ROOT/'supervisor.lock').open('a+');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    signal.signal(signal.SIGTERM,lambda signum,frame:STOP.set())
    run(json.loads(IDENTITY.read_bytes()))
